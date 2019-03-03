this.investigate_cemetery_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		TreasureLocation = null,
		SituationID = 0
	},
	function setDestination( _d )
	{
		this.m.Destination = this.WeakTableRef(_d);
	}

	function create()
	{
		this.contract.create();
		this.m.Type = "contract.investigate_cemetery";
		this.m.Name = "守卫墓地";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		if (this.m.Destination == null  ||  this.m.Destination.isNull())
		{
			local myTile = this.World.State.getPlayer().getTile();
			local undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getSettlements();
			local lowestDistance = 9999;
			local best;

			foreach( b in undead )
			{
				local d = myTile.getDistanceTo(b.getTile());

				if (d < lowestDistance && (b.getTypeID() == "location.undead_graveyard"  ||  b.getTypeID() == "location.undead_crypt"))
				{
					lowestDistance = d;
					best = b;
				}
			}

			this.m.Destination = this.WeakTableRef(best);
		}

		this.m.Flags.set("DestinationName", this.m.Destination.getName());
		this.m.Payment.Pool = 550 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"保护 " + this.Flags.get("DestinationName")
				];

				if (this.Math.rand(1, 100) <= this.Const.Contracts.Settings.IntroChance)
				{
					this.Contract.setScreen("Intro");
				}
				else
				{
					this.Contract.setScreen("Task");
				}
			}

			function end()
			{
				this.World.Assets.addMoney(this.Contract.m.Payment.getInAdvance());
				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
				this.Contract.m.Destination.clearTroops();

				if (this.Contract.getDifficultyMult() < 1.15 && !this.Contract.m.Destination.getTags().get("IsEventLocation"))
				{
					this.Contract.m.Destination.getLoot().clear();
				}

				this.Contract.m.Destination.setLootScaleBasedOnResources(100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 60 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));
				local r = this.Math.rand(1, 100);

				if (r <= 10 && this.World.Assets.getBusinessReputation() > 500)
				{
					this.Flags.set("IsMysteriousMap", true);
					this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.BanditRaiders, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				}
				else if (r <= 40)
				{
					this.Flags.set("IsGhouls", true);
					this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.Ghouls, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				}
				else if (r <= 70)
				{
					this.Flags.set("IsGraverobbers", true);
					this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.BanditRaiders, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				}
				else
				{
					this.Flags.set("IsUndead", true);
					this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.Zombies, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				}

				this.Contract.m.Destination.resetDefenderSpawnDay();
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onDestinationAttacked.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Destination == null  ||  this.Contract.m.Destination.isNull())
				{
					if (this.Flags.get("IsUndead") && this.World.Assets.getBusinessReputation() > 500 && this.Math.rand(1, 100) <= 25 * this.Contract.m.DifficultyMult)
					{
						this.Flags.set("IsNecromancer", true);
						this.Contract.setScreen("Necromancer0");
						this.World.Contracts.showActiveContract();
					}

					this.Contract.setState("Return");
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				if (!this.Flags.get("IsAttackDialogShown"))
				{
					this.Flags.set("IsAttackDialogShown", true);

					if (this.Flags.get("IsGhouls"))
					{
						this.Contract.setScreen("AttackGhouls");
					}
					else if (this.Flags.get("IsGraverobbers"))
					{
						this.Contract.setScreen("AttackGraverobbers");
					}
					else if (this.Flags.get("IsUndead"))
					{
						this.Contract.setScreen("AttackUndead");
					}
					else if (this.Flags.get("IsMysteriousMap"))
					{
						this.Contract.setScreen("MysteriousMap1");
					}

					this.World.Contracts.showActiveContract();
				}
				else
				{
					this.World.Contracts.showCombatDialog();
				}
			}

		});
		this.m.States.push({
			ID = "Running_Necromancer",
			function start()
			{
				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onDestinationAttacked.bindenv(this));
				}

				this.Contract.m.BulletpointsObjectives = [
					"摧毁 " + this.Flags.get("DestinationName")
				];
			}

			function update()
			{
				if (this.Contract.m.Destination == null  ||  this.Contract.m.Destination.isNull())
				{
					this.Contract.setScreen("Necromancer3");
					this.World.Contracts.showActiveContract();
					this.Flags.set("IsNecromancerDead", true);
					this.Contract.setState("Return");
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				if (!this.Flags.get("IsAttackDialogShown"))
				{
					this.Flags.set("IsAttackDialogShown", true);
					this.Contract.setScreen("Necromancer2");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					this.World.Contracts.showCombatDialog();
				}
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"返回 " + this.Contract.m.Home.getName()
				];
				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					if (this.Flags.get("IsNecromancer"))
					{
						if (this.Flags.get("IsNecromancerDead"))
						{
							this.Contract.setScreen("Success3");
						}
						else
						{
							this.Contract.setScreen("Necromancer1");
						}
					}
					else if (this.Flags.get("IsUndead"))
					{
						this.Contract.setScreen("Success1");
					}
					else if (this.Flags.get("IsMysteriousMapAccepted"))
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							this.Contract.setScreen("Failure1");
						}
						else
						{
							this.Contract.setScreen("Failure2");
						}
					}
					else
					{
						this.Contract.setScreen("Success2");
					}

					this.World.Contracts.showActiveContract();
				}
			}

		});
	}

	function createScreens()
	{
		this.importScreens(this.Const.Contracts.NegotiationDefault);
		this.importScreens(this.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_20.png[/img]%employer%不安地上下徘徊，时不时地停下来和你说话。%SPEECH_ON%人们在骚乱！在坟场的坟墓发现被打开洗劫了。一些傻瓜说是死人从坟墓复活了——迷信的无稽之谈。显然是有些胆大的盗墓者来到%townname%为非作歹！%SPEECH_OFF%他愤怒地一拳打在桌子上。%SPEECH_ON%前往墓地，一劳永逸地结束这个麻烦！%SPEECH_OFF%  |  %employer% 做到椅子上，对着自己笑。%SPEECH_ON%不要惊慌，佣兵，但是他们说幽灵正在活动中！是的，没错，当地农民总是谈论幽灵哥布林什么的，把我的大好早晨都毁了。他们说这些所谓的生物把墓地翻个底朝天，掠夺坟墓扩大它们的军队之类的。显然，这只是一些想要盗墓的人挥舞铁锹造成的结果。我以前见过。%SPEECH_OFF%他低下头看着他的手，微微一笑。%SPEECH_ON%无论如何，我不能就此罢休，因为这些农民会一直烦我。放松，还有……你。我要你去墓地，清理任何麻烦。你要怎么做自己决定，但是我推荐你一个好方法，如果你明白我的意思……%SPEECH_OFF%  |  %employer%的桌上有一张墓地的地图。一半描绘的框框都被墨水填满。%SPEECH_ON%你在那看到的每个框框都被抢劫过了。他们每晚都来，而我每天晚上都抓不到他们。我在这里束手无策了，所以我决定结束这一切。我要你去墓地，杀死看到的每一个盗墓者。明白了吗？%SPEECH_OFF%  |  %employer%站在窗边，拿着一杯蜂蜜酒看窗外。他似乎没有特别关注什么事，甚至说话的口气都好像他一点都不关心这个话题。%SPEECH_ON%盗墓者正在掠夺墓地。再一次。我真的对你要求部队，佣兵，只要你去那里结束这愚蠢的事就好。去墓地杀了你能看到的盗墓者。明白了吗？很好。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "我们谈谈价格吧。",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "没兴趣。",
					function getResult()
					{
						this.World.Contracts.removeContract(this.Contract);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "AttackGhouls",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_69.png[/img]{嘎吱嘎吱。大声咀嚼。某人，或某物，享受大餐的窃笑。当你穿过墓地，偶然发现一处满是食尸鬼的墓地。他们围在你正在寻找的盗墓者的尸体旁。这可怕的怪物慢慢地转向你，看到新鲜的肉体，它们的红色眼睛都张大了。 |  成群的食尸鬼压倒了墓碑。他们似乎在吃大餐，有一些还在啃咬胳膊或腿，大概是盗墓者的四肢。 |  你听到一声刺耳的尖叫，迅速看向陵墓的一角，发现一个食尸鬼正把它的牙齿刺进一个人的脖子。野兽嘴里充满了鲜血，多到从鼻子流出来，看了你一眼。小食尸鬼包围它，它们的下一顿有着落了……}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "AttackGraverobbers",
			Title = "靠近……",
			Text = "[img]gfx/ui/events/event_57.png[/img]{那些盗墓者就在这里。你把他们抓了个正着，你的兄弟们拿着武器就翻过了墓碑。 |  走进墓地，你发现盗墓者正如%employer%所想的一样就在那里。他们也发现了你们。你的人拿出武器阻止他们逃跑。 |  当你走过墓碑，几个声音出现在陵墓的另一面。当你转过拐角，你发现一群人站在空的坟墓上。他们面前是空的棺材，几个人从中拿着珠宝。你命令你的手下冲上去。 |  %employer% 说得对：这里有盗墓者。你发现许多墓穴被翻了，坟墓都被挖掘。你沿着泥道发现挖掘工正在工作。%SPEECH_ON%不是故意要阻止你，伙计，但是%employer%付了很多钱要让这些人安息。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "AttackUndead",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_57.png[/img]{墓地模糊不清，不知是迷雾还是尸体散发的瘴气。等等…亡灵！准备迎战！ |  你发现一座墓碑下有个土堆。泥土如面包屑一般指向远方。没有铲子…空无一人…你一路追踪，遇到了一帮哀嚎的亡灵…饥肠辘辘地盯着你… |  一个人徘徊在墓碑深处。身影摇曳，似乎要倒下了。%randombrother%来到你身边，摇摇头。%SPEECH_ON%长官，那并非活人。那是行进中的亡灵。%SPEECH_OFF%他话刚说完，远方的陌生人就出现了，光照下，你发现他一半脸都没了。 |  你发现众多坟墓都是空的。不仅如此，而且还是从下方挖空的。这可不像是盗墓贼的杰作…}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "MysteriousMap1",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_57.png[/img]{你进入墓穴发现盗墓者就在%employer%预想的地方：深陷在别人的阴世里。抽出你的剑，告诉他们放下想要拿走的珠宝。他们其中一人站起来，举起双手，说道。%SPEECH_ON%在你杀死我们之前，我能说几句吗？我们有一张地图……我知道这听起来像个谎言，但听我说……我们有巨大宝藏的地图。你放我们走，我就给你。杀了我们，呃……你再无法见到它。你说什么？%SPEECH_OFF%  |  正如%employer%猜测的，有盗墓者在墓碑附近。你阻止他们挖掘，询问他们死前有没有什么遗言。其中一名男子恳求饶恕，说他有一张藏宝图，可以用来交换所有人的性命。 |  你偶然发现几个人试图打开一扇墓门。用你的到拍打靴子引起他们的注意。%SPEECH_ON%晚上好先生们。%employer% 派我来的。%SPEECH_OFF%其中一个人扔下工具。%SPEECH_ON%等一下！我们有一张地图……是的，一张地图！如果你放过我们，我一定会给你的！只要你放过我们！如果不的话……你就见不到地图，明白吗？%SPEECH_OFF%  |  你抢在盗墓者之前行动，在他们挥舞铁铲的时候拔出了剑。其中一个人，大概感觉一只脚已经踏进了坟墓，想要与你交易。显然，这人有一张神秘宝藏地图。你只要放了他们就能拿到地图。如果你杀了他们，地图也就没了，你也就再也找不到宝藏。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "杀了他们！",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				},
				{
					Text = "很好，交出地图，你就可以活着离开这个地方。",
					function getResult()
					{
						this.updateAchievement("NeverTrustAMercenary", 1, 1);
						local tile = this.Contract.getTileToSpawnLocation(this.World.State.getPlayer().getTile(), 8, 18, [
							this.Const.World.TerrainType.Shore,
							this.Const.World.TerrainType.Ocean,
							this.Const.World.TerrainType.Mountains
						], false);
						tile.clear();
						this.Contract.m.TreasureLocation = this.WeakTableRef(this.World.spawnLocation("scripts/entity/world/locations/undead_ruins_location", tile.Coords));
						this.Contract.m.TreasureLocation.onSpawned();
						this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).addSettlement(this.Contract.m.TreasureLocation.get(), false);
						this.Contract.m.TreasureLocation.addToInventory("loot/silverware_item");
						this.Contract.m.TreasureLocation.addToInventory("loot/silver_bowl_item");
						return "MysteriousMap2";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "MysteriousMap2",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_57.png[/img]{也许%employer% 只是想得到宝藏后杀人？这……有道理，对吧？你决定放了这些人交换到 %treasure_location% %treasure_direction% 的地图。 |  %employer% 没有提及这些人有一张地图……也许他想消除这些讯息？谁知道呢。但是财富的诱惑对你来说太大了，你觉得放了这些人交换信息。地图揭露了 %treasure_location%。它在你的位置的%treasure_direction%。 |  当你还是个孩子时，你常常去寻宝。有种……怪异地紧张感。你不知道为什么，重温冒险的诱惑让你放了他们。作为回报，他们给了你揭露%treasure_location%的地图，隐藏宝藏的位置……谁知道呢？你真正知道的是它在你的位置的%treasure_direction%。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "最好是值得的。",
					function getResult()
					{
						this.World.uncoverFogOfWar(this.Contract.m.TreasureLocation.getTile().Pos, 700.0);
						this.Contract.m.TreasureLocation.setDiscovered(true);
						this.World.getCamera().moveTo(this.Contract.m.TreasureLocation.get());
						this.Contract.m.Destination.fadeOutAndDie();
						this.Contract.m.Destination = null;
						this.Flags.set("IsMysteriousMapAccepted", true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Necromancer0",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_56.png[/img]{消灭了所有的不死族之后，你发现手里有一块布发着紫光。你不知道它是什么，但出于某种原因被吸引而留着它。%randombrother%认为这是愚蠢的，但他不是负责人。 |  战斗之后，%randombrother% 发现了一把铲子，带着一个燃烧过的符号。他想着%employer%，你的雇主是否可能知道一些。你也同意，带着金属废料看看当地人是否能认识。 |  随着怪物示弱，你把剑插回剑鞘，冲向战场。在搜索中，你找奇怪的乌鸦羽毛护身符和牛皮革。你把它放到口袋，想着%employer%，你的雇主，可能知道一些。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "是时候去拿我们的报酬了。",
					function getResult()
					{
						this.Flags.set("DestinationName", this.World.EntityManager.getUniqueLocationName(this.Const.World.LocationNames.NecromancerLair));
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Necromancer1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_63.png[/img]{返回%employer%，你快速解释没有盗墓者，只有一群不死族。他似乎感到震惊，但当你出示找到的神器时，他抿紧嘴巴郑重地点点头。%SPEECH_ON%那是……来自 %necromancer_location%。我们认为我们可以不理会那个地方，但看来我错了。去那儿，佣兵，去结束那里的恐怖！%SPEECH_OFF%这人降低了一点夸张。%SPEECH_ON%哦，当然我会付你另外%reward_completion% 克朗，加上原工作的%reward_completion%克朗。%SPEECH_OFF%  |  你发现%employer%在他的书房，庄严地喝酒。%SPEECH_ON%我已经听说消息了。死人在行走，哦，说出来都可怕！%SPEECH_OFF%你点头出示在墓地找到的神器。%SPEECH_ON%你对此有所了解吗？%SPEECH_OFF%他浏览着它，仿佛知道你已经拥有它了。%SPEECH_ON%是的，它属于%necromancer_location%。我们本来以为可以不理会来自那里的恐怖……看吧。也许你可以去那里？也许你可以摧毁%necromancer_location%，让我们摆脱这种恐怖？按照约定，这是你原先的钱款，但是如果你帮助我们处理%necromancer_location%，你会得到另外%reward_completion%克朗。听起来不错吧？%SPEECH_OFF%  |  你走进%employer%的房间，把神器摔在他的桌上。他用手拍开。%SPEECH_ON%你从哪得到的？%SPEECH_OFF%用手指指着它，你质问他。%SPEECH_ON%你知道墓地的不死族吗？%SPEECH_OFF%他不好意思地看别处，然后点点头。 %SPEECH_ON%是的……我知道。它们，还有神器，来自%necromancer_location%。某种黑暗术士住在那里，他一直给我们带来这些……问题，已经有段时间了。你能去摧毁它吗？这是你的原始合同钱款，但如果你能帮我们去除他，还会有大量的补偿。可以说……另外的%reward_completion% 克朗？%SPEECH_OFF%  |  你向%employer%解释，墓地没有盗墓者，也没有做这事的人类。在他开口之前，你出示神器，放在灯光下让他看到。他快速后退。%SPEECH_ON%放下！%SPEECH_OFF%像火的声音一样，他的叫喊点亮了神器，无痛地在你的指尖燃烧，只剩下旋转的灰烬。%employer%双手抱头。%SPEECH_ON%它来自%necromancer_location%。一个……死灵法师住在那里，他是操纵死人复活的傀儡师。雇佣兵，请你去摧毁它。我们会很仁慈的……%SPEECH_OFF%他停下来拿出一袋克朗。%SPEECH_ON%这些是我们最初同意的。但如果你杀了%necromancer_location% 的可怕人物，还有会其他%reward_completion%克朗等着你回来。%SPEECH_OFF%  |  你拿出在墓地找到的神器。%employer%一看到它就喘气，但他的表情很快变成忧郁的接受。%SPEECH_ON%我老实跟你说，佣兵。不远处的%necromancer_location% 住着一个死灵法师。%SPEECH_OFF%他拿出一袋克朗给你。%SPEECH_ON%这是原来的工作所得。不过，如果你现在去杀了这个邪恶的人，我会给你另外%reward_completion% 克朗。%SPEECH_OFF%他向后靠，看着很希望你能接受这些新条款。}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "很好，我们会杀死死灵法师。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Secured the cemetery");
						local tile = this.Contract.getTileToSpawnLocation(this.World.State.getPlayer().getTile(), 8, 15, [
							this.Const.World.TerrainType.Shore,
							this.Const.World.TerrainType.Ocean,
							this.Const.World.TerrainType.Mountains
						], false);
						tile.clear();
						this.Contract.m.Destination = this.WeakTableRef(this.World.spawnLocation("scripts/entity/world/locations/undead_necromancers_lair_location", tile.Coords));
						this.Contract.m.Destination.onSpawned();
						this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).addSettlement(this.Contract.m.Destination.get(), false);
						this.Contract.m.Destination.setName(this.Flags.get("DestinationName"));
						this.Contract.m.Destination.setDiscovered(true);
						this.Contract.m.Destination.clearTroops();
						this.Contract.m.Destination.setLootScaleBasedOnResources(115 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.Necromancer, 115 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());

						if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Destination.getTags().get("IsEventLocation"))
						{
							this.Contract.m.Destination.getLoot().clear();
						}

						this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
						this.Contract.m.Home.getSprite("selection").Visible = false;
						this.Flags.set("IsAttackDialogShown", false);
						this.Contract.setState("Running_Necromancer");
						return 0;
					}

				},
				{
					Text = "不，战团在这里做的已经够多了。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Secured the cemetery");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "Necromancer2",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_57.png[/img]{这位置如你想象的那么可怕，无可指责的事情，挥霍腐烂的顶点。你还没有发现死灵法师，所以最好小心前进…… |  %necromancer_location% 就在%employer%说的地方。你发现路上有一串的骨头。有一些还带着肉体，也许是死灵法术失误使得它没能从死亡变成不死。忽视恐怖，开始计划你的攻击…… |  像%necromancer_location% 这样的地方长满了高高的草丛、野草和变黑的树，甚至都不需要‘禁止入内’标识。但事实上却需要。它是按照骷髅图形来的，各种人和牲畜拼凑成的骨头的恐怖，十字架的炫光阻挡任何潜在的冒险家。蛞蝓爬进其眼窝，兵蚁随着肢体跳动。\n\n %randombrother%走上前，有点不安，问你希望如何攻击。 |  首先你找到一只啮齿动物、四肢张开，每只小手或脚用别针钉在木板上。还有一条狗，它的头用猫头替代了。你发誓当你走近时，怪物移动了，但也许你只是看到幻觉。然后……是人们。你已经无法用语言来描述他们发生了什么，但它是高耸的淤血奇迹，暴行的极致。\n\n%randombrother%走到你身边。%SPEECH_ON%我们来终结这个疯子。%SPEECH_OFF%是的。问题是，如何先攻击？}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备攻击。",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Necromancer3",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_56.png[/img]{%necromancer_location%被净化了。你现在几乎能感受到它的神圣，但记住你做这些是为了钱，不是为了正义。总之，不是说你会更喜欢后者。 |  死灵法师死了，你手里拿着他的头。现在该去告诉那个笨蛋%employer%了，他可以给你你所应得的。 |  这不是一场简单的战斗，但是%necromancer_location%被摧毁了。死灵法师死了，和人们一样，变成一堆肉体和骨头。奇怪的是他的巫术能复活死人，但是自己死的时候却不能施放。奇怪，但也幸运。以防万一，你拿走了这异教徒的头。 |  你杀了死灵法师，但是担心他的把戏可能超出坟墓，所以看下他的头装进麻袋。%employer%，你的雇主，应该很高兴看到它。 |  战争结束了，你把剑放在死灵法师的脖子上砍下他的头。这几乎太随意了，仿佛它就想被你拿着。不管怎样，你的雇主%employer%，会想要看到它作为你的功劳的证明。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "该去拿脑袋的赏金了。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer% 狡猾地笑着迎接你回来。%SPEECH_ON%讨厌的生意，不是吗？我已经听到了消息，这里消息总能传播地很快。可惜我们不得不这样做，不然谁知道你为对抗这些东西做了什么。\n\n嘿……你赚到钱了。%SPEECH_OFF%他指着角落的木箱子。%SPEECH_ON%那里就%reward_completion%克朗，我们说好的。%SPEECH_OFF%  |  %employer% 听着你的报告，然后慢慢地向后靠在椅子上。%SPEECH_ON%有很多传闻关于这些……事情。死人走路？%SPEECH_OFF%他盯着桌子，然后生气地看着你。%SPEECH_ON%胡说！我不相信。你会获得我们说好的%reward_completion% 克朗。你再也不能用这些谎话压榨我了！%SPEECH_OFF%你真应该带一个或两个头来，不过话说回来，死人头看起来就像不死族的头…… |  %employer% 听着你的不死族报告耸耸肩。%SPEECH_ON%真可惜。%SPEECH_OFF%他满不在乎地喝了一口酒，用手指着房间一角。%SPEECH_ON%你的钱在箱子里。%randomname%会送你走。%SPEECH_OFF%  |  %employer%扣紧自己的手，然后放在膝盖上。%SPEECH_ON%我已经听说了这些……事情。这些捣乱的怪物。听到它们来%townname%真不是个好消息，但如果他们要去哪儿，我想最好是墓地！总之比城市广场要好。%SPEECH_OFF%他紧张地对自己笑。%SPEECH_ON%%randomname%拿着钱站在我的门外。谢谢你，佣兵。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一笔数量可观的克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Secured the cemetery");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer% 欢迎你进入他的房间。%SPEECH_ON%你把他们全杀了吗？安全吗？%SPEECH_OFF%你耸耸肩。%SPEECH_ON%没人会随时挖坟墓。%SPEECH_OFF%  |  你发现%employer%坐落在椅子上，拿着烛光靠近陈旧的卷轴。他头也不抬地说着。%SPEECH_ON%我的问题，是你能对付吗？%SPEECH_OFF%你点点头。%SPEECH_ON%如果不能，我就不会站在这里了。%SPEECH_OFF%%employer% 手指了一下桌子的角落。%SPEECH_ON%你的钱。说好的%reward_completion%克朗。%SPEECH_OFF%  |  当你回到%employer%的房间，他在和他的人说着话。他走开他们来问你任务情况。你说又能够安全埋葬%townname%的深爱的人了。%employer%笑了。%SPEECH_ON%很好。很好。你的钱。%SPEECH_OFF%他打了个响指，一个手下走上前，给你一个袋子。里面是承诺过的%reward_completion%克朗。}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一笔数量可观的克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Secured the cemetery");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Success3",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你带着死灵法师的头回去找%employer%。难以置信，表面上看就是人类的头。%SPEECH_ON%就这是肮脏的生物用不死族骚扰我们的坟墓吗？%SPEECH_OFF%你点点头。这脸庞喘了一口气，%employer%跳开了。%SPEECH_ON%他还活着！%SPEECH_OFF%你耸耸肩，用匕首穿过脑壳。死灵法师的眼睛向上看着刀柄，他的牙齿随着笑声打颤，然后眼睛退回到眼框，微弱的红色烟雾藤蔓缠绕，然后没有更多东西了。%employer%，摇晃着坐下来，指向角落的袋子。这是你的报酬，挺重的。 |  当你走进%employer% 的书房，他正坐着，但是当他看到你手上的死灵法师的头，立即站起来往后退。%SPEECH_ON%我想……那是他？对吧？就是他？结束了？%SPEECH_OFF%你点点头，把这颗脑袋扔在他的桌子上。它转动脸庞，来回摇晃露出死一般地笑容。%employer%用书敲走它。%SPEECH_ON%很好。棒极了！按照约定，你的报酬……%SPEECH_OFF%他指向角落的{木箱子  |  大袋子}。你拿起钱数了数，然后离开了。} |  %employer% 抬头看。%SPEECH_ON%众神保佑，你手里的是死灵法师的头？%SPEECH_OFF%你点点头，把它扔在地板上。一只猫从书架上滑下来，过来挠这颗头。%employer%站起来从书架上拿下几本书，露出一个大盒子。他把盒子交给你。%SPEECH_ON%我一直为特殊时刻保留着这个，我想现在就是这时刻了。%SPEECH_OFF%你认为这会是一件物品，也许是护身符或神秘的东西，但其实只是一堆克朗。 |  回去找%employer%，你拿着死灵法师的头，而他快速要你交出来。毫不犹豫地这么做……\n\n%employer%用双手举起它，像研究生病的婴儿一样研究着它。过了一会儿，他把头放在破碎的三叉戟的把手上。%SPEECH_ON%我觉得放在那里好看。是的，你说呢？%SPEECH_OFF%这个男人把一个拇指放在巫师的苍白下巴上。你清了清嗓子询问报酬，%employer%示意他的一个守卫进来。带来一个袋子，你数了数有%reward_completion%克朗。你心满意足地留下%employer%……管他做什么。}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一笔数量可观的克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractPoor, "Secured the cemetery");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_63.png[/img]{%employer% is standing at the window when you enter.%SPEECH_ON%The songbirds seemed rather angry today. As though nothing they\'d say was worth saying. I thought that was interesting. Do you?%SPEECH_OFF%He suddenly turns toward you.%SPEECH_ON%Hmm, mercenary? No? My little birds told me that the graverobbers left town. Alive. Free to go where they please, free to return as they please. What an oddity, because usually dead men aren\'t free to do anything. What did I ask you to make those graverobbers?%SPEECH_OFF%You hesitate. The man answers for you.%SPEECH_ON%I wanted you to make them dead. Now they aren\'t. Now you don\'t get paid. Ah, how simple. And now? Now you get out of my house.%SPEECH_OFF%  |  %employer% laughs as you enter his room.%SPEECH_ON%I\'m honestly surprised you returned. I should find it insulting, really, that you\'d think I wouldn\'t know better. The graverobbers were spotted on the road. The graverobbers I asked you to kill. Remember that? Remember when I said go and kill them? I\'m sure you do. I\'m also sure you remember when I said that\'s what I was paying you for. So... no dead graverobbers...%SPEECH_OFF%He slams his desk with a fist.%SPEECH_ON%No pay! Now get out of my home!%SPEECH_OFF%  |  You find %employer% in his chair, rolling an empty goblet between his hands.%SPEECH_ON%It\'s not often I run across someone who tries to cheat me. That\'s what you were going to do, coming back here, right? I know the graverobbers aren\'t dead, sellsword. I\'m no fool. Leave my sight before I have my men butcher you.%SPEECH_OFF%  |  %employer% is reading a book when you enter his room.%SPEECH_ON%You have ten seconds to turn around and leave. Ten. Nine. Eight...%SPEECH_OFF%You realize he knows that the graverobbers were not taken care of.%SPEECH_ON%...four... three...%SPEECH_OFF%You turn and hastily leave the room.}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "该死的！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.Assets.addMoralReputation(-1);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationAttacked);
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Failure2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_63.png[/img]{%employer% 抿着嘴唇。%SPEECH_ON%你让我处于奇怪的境地，雇佣军。你告诉我盗墓者被处理了，但是……我没有证据。通常，死人会留下许多证据。特别是在死前草草杀害的。%SPEECH_OFF%他耸耸肩。%SPEECH_ON%我只付你一半的钱。你拿着钱离开。下次带证据来。如果你撒谎……好吧，我会自己弄明白的。%SPEECH_OFF%  |  你返回发现%employer%正前往花园。%SPEECH_ON%有时我种些蔬菜，但长出什么就是另外一回事了？到底怎么回事？我在骗自己吗？你想骗我？你说盗墓者都死了，但我的人搜索了墓地，没有发现证据。他们也没有发现盗墓者……%SPEECH_OFF%他举起一只手。%SPEECH_ON%别告诉我你用他们的尸体做了这事那事。所以这就是我们要做的，佣兵。我付你一半的钱，我要坐在这里知道你是否骗了我。听起来不错？很好。%SPEECH_OFF%  |  %employer% 微笑着听你告诉他他的问题已经解决。%SPEECH_ON%真是好消息。不幸的是，我的人侦察了墓地，没有发现盗墓者死亡的证据。有趣的发展，不过当我在查明真相的时候，我不会把你关在这里。那么……我会付你一半钱。下次带证据来。或者……不要撒谎。我不知道哪样适用于你。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "嗯。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractPoor);
						this.World.Assets.addMoralReputation(-1);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() / 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail);
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() / 2 + "[/color] 克朗"
				});
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"treasure_location",
			this.m.TreasureLocation == null  ||  this.m.TreasureLocation.isNull() ? "" : this.m.TreasureLocation.getName()
		]);
		_vars.push([
			"treasure_direction",
			this.m.TreasureLocation == null  ||  this.m.TreasureLocation.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.TreasureLocation.getTile())]
		]);
		_vars.push([
			"necromancer_location",
			this.m.Flags.get("DestinationName")
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/terrified_villagers_situation"));
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Destination != null && !this.m.Destination.isNull())
			{
				this.m.Destination.getSprite("selection").Visible = false;
				this.m.Destination.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}

		if (this.m.Home != null && !this.m.Home.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Home.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(3);
			}
		}
	}

	function onIsValid()
	{
		if (this.m.IsStarted)
		{
			if (this.m.Destination == null  ||  this.m.Destination.isNull()  ||  !this.m.Destination.isAlive())
			{
				return false;
			}

			return true;
		}
		else
		{
			if (this.m.Destination == null  ||  this.m.Destination.isNull())
			{
				return false;
			}

			return true;
		}
	}

	function onSerialize( _out )
	{
		if (this.m.Destination != null && !this.m.Destination.isNull())
		{
			_out.writeU32(this.m.Destination.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local destination = _in.readU32();

		if (destination != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}

		this.contract.onDeserialize(_in);
	}

});

