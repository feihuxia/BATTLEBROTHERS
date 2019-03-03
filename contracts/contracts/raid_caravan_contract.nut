this.raid_caravan_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		LastCombatTime = 0.0
	},
	function setEnemyNobleHouse( _h )
	{
		this.m.Flags.set("EnemyNobleHouse", _h.getID());
	}

	function create()
	{
		this.contract.create();
		this.m.Type = "contract.raid_caravan";
		this.m.Name = "劫掠商队";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 800 * this.getPaymentMult() * this.getDifficultyMult() * this.getReputationToPaymentMult();

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		local myTile = this.World.State.getPlayer().getTile();
		local enemyFaction = this.World.FactionManager.getFaction(this.m.Flags.get("EnemyNobleHouse"));
		local settlements = enemyFaction.getSettlements();
		local lowest_distance = 99999;
		local highest_distance = 0;
		local best_start;
		local best_dest;

		foreach( s in settlements )
		{
			if (s.isIsolated())
			{
				continue;
			}

			local d = s.getTile().getDistanceTo(myTile);

			if (d < lowest_distance)
			{
				lowest_distance = d;
				best_dest = s;
			}

			if (d > highest_distance)
			{
				highest_distance = d;
				best_start = s;
			}
		}

		this.m.Flags.set("InterceptStart", best_start.getID());
		this.m.Flags.set("InterceptDest", best_dest.getID());
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"劫掠从%start%到%dest%的商队",
					"返回%townname%"
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
				local r = this.Math.rand(1, 100);
				this.Flags.set("Survivors", 0);

				if (r <= 10)
				{
					this.Flags.set("IsBribe", true);
					this.Flags.set("Bribe1", this.Contract.beautifyNumber(this.Contract.m.Payment.Pool * (this.Math.rand(70, 150) * 0.01)));
					this.Flags.set("Bribe2", this.Contract.beautifyNumber(this.Contract.m.Payment.Pool * (this.Math.rand(70, 150) * 0.01)));
				}
				else if (r <= 15)
				{
					if (this.Contract.getDifficultyMult() >= 1.0)
					{
						this.Flags.set("IsSwordmaster", true);
					}
				}
				else if (r <= 20)
				{
					if (this.Contract.getDifficultyMult() >= 1.0)
					{
						this.Flags.set("IsUndeadSurprise", true);
					}
				}
				else if (r <= 25)
				{
					this.Flags.set("IsWomenAndChildren", true);
				}
				else if (r <= 35)
				{
					this.Flags.set("IsCompromisingPapers", true);
				}

				local enemyFaction = this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse"));
				local best_start = this.World.getEntityByID(this.Flags.get("InterceptStart"));
				local best_dest = this.World.getEntityByID(this.Flags.get("InterceptDest"));
				local party = enemyFaction.spawnEntity(best_start.getTile(), "Caravan", false, this.Const.World.Spawn.NobleCaravan, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.getSprite("base").Visible = false;
				party.getSprite("banner").setBrush(enemyFaction.getBannerSmall());
				party.setMirrored(true);
				party.setVisibleInFogOfWar(true);
				party.setImportant(true);
				party.setDiscovered(true);
				party.setDescription("A caravan with armed escorts transporting something worth protecting between settlements.");
				party.setAttackableByAI(false);
				party.getTags().add("ContractCaravan");
				this.Contract.m.Target = this.WeakTableRef(party);
				this.Contract.m.UnitsSpawned.push(party);
				party.getLoot().Money = this.Math.rand(50, 100);
				party.getLoot().ArmorParts = this.Math.rand(0, 10);
				party.getLoot().Medicine = this.Math.rand(0, 2);
				party.getLoot().Ammo = this.Math.rand(0, 20);
				local r = this.Math.rand(1, 6);

				if (r == 1)
				{
					party.addToInventory("supplies/bread_item");
				}
				else if (r == 2)
				{
					party.addToInventory("supplies/roots_and_berries_item");
				}
				else if (r == 3)
				{
					party.addToInventory("supplies/dried_fruits_item");
				}
				else if (r == 4)
				{
					party.addToInventory("supplies/ground_grains_item");
				}
				else if (r == 5)
				{
					party.addToInventory("supplies/pickled_mushrooms_item");
				}

				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local move = this.new("scripts/ai/world/orders/move_order");
				move.setDestination(best_dest.getTile());
				move.setRoadsOnly(true);
				local despawn = this.new("scripts/ai/world/orders/despawn_order");
				c.addOrder(move);
				c.addOrder(despawn);
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Target != null && !this.Contract.m.Target.isNull())
				{
					this.Contract.m.Target.getSprite("selection").Visible = true;
					this.Contract.m.Target.setOnCombatWithPlayerCallback(this.onTargetAttacked.bindenv(this));
					this.Contract.m.Target.setVisibleInFogOfWar(true);
				}
			}

			function update()
			{
				if (this.Contract.m.Target == null || this.Contract.m.Target.isNull())
				{
					if (this.Flags.get("IsWomenAndChildren"))
					{
						this.Contract.setScreen("WomenAndChildren1");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsCompromisingPapers"))
					{
						this.Contract.setScreen("CompromisingPapers1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setState("Return");
					}
				}
				else if (this.Contract.isEntityAt(this.Contract.m.Target, this.World.getEntityByID(this.Flags.get("InterceptDest"))))
				{
					this.Contract.setScreen("Failure3");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerAt(this.Contract.m.Target))
				{
					this.onTargetAttacked(this.Contract.m.Target, false);
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (!this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("IsAttackDialogTriggered", true);

					if (this.Flags.get("IsBribe"))
					{
						this.Contract.setScreen("Bribe1");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsSwordmaster"))
					{
						this.Contract.setScreen("Swordmaster");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsUndeadSurprise"))
					{
						this.Contract.setScreen("UndeadSurprise");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.onTargetAttacked(_dest, true);
					}
				}
				else if (this.Time.getVirtualTimeF() >= this.Contract.m.LastCombatTime + 5.0)
				{
					local enemyFaction = this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse"));
					enemyFaction.setIsTemporaryEnemy(true);
					this.Contract.m.LastCombatTime = this.Time.getVirtualTimeF();
					this.World.Contracts.showCombatDialog(_isPlayerAttacking);
				}
			}

			function onActorRetreated( _actor, _combatID )
			{
				if (!_actor.isNonCombatant() && _actor.getFaction() == this.Flags.get("EnemyNobleHouse") && this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("Survivors", this.Flags.get("Survivors") + 1);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.Contract.m.LastCombatTime = this.Time.getVirtualTimeF();
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"将%randomitem%还给%townname%"
				];
				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					if (this.Flags.get("IsCompromisingPapers"))
					{
						if (this.Flags.get("IsExtorting"))
						{
							this.Contract.setScreen("CompromisingPapers2");
							this.World.Contracts.showActiveContract();
						}
						else
						{
							this.Contract.setScreen("CompromisingPapers3");
							this.World.Contracts.showActiveContract();
						}
					}
					else if (this.Flags.get("Survivors") == 0)
					{
						this.Contract.setScreen("Success1");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Math.rand(1, 100) < this.Flags.get("Survivors") * 15)
					{
						this.Contract.setScreen("Failure1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("Failure2");
						this.World.Contracts.showActiveContract();
					}
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{你坐在 %employer% 的位子上，在你面前折叠一张地图。他的手指指着在一条绘制得很差的路上。%SPEECH_ON%一辆货车沿着这条路线行进。我需要它被攻击，但是等一下！%SPEECH_OFF%他举起手指.%SPEECH_ON%我需要它看起来像强盗的作品。没人知道它的毁灭是我命令的，明白吗？%SPEECH_OFF%  |  %employer% 解释说他需要一辆货车被毁。你问，为什么像他这样的贵族会有这样的任务要完成，但这个人缺乏解释的耐心。他的要求很简单，摧毁货车，杀死那里的所有人。它必须看起来像 {强盗  |  毁灭者  |  流浪者  |  绿皮}所为, 否则贵族可能会被定罪。%SPEECH_ON%你领会精神了吗，剑士？当然了。你是个聪明人，对吧?%SPEECH_OFF% }",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{这对你有什么价值？ |  我们来谈谈报酬。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这听起来可不像是我们的活。 |  我不这么认为。}",
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
			ID = "Bribe1",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_41.png[/img]{在接近商队时，其中一位守卫看到了你然后所有人都抽出了武器。一个人手臂扬在空中大喊着，让所有人放下武器。他手中有个袋子，沉甸甸满是%bribe%克朗，并说道只要你能放他们走就给你。你说出内心疑惑，为什么你要接受贿赂，反正杀光他们还是能拿走前。男人耸耸肩说道。%SPEECH_ON%好吧，显然这样你就省得麻烦还要‘杀’我们了，因为我们不会不战而降。拿着它走吧,佣兵。%SPEECH_OFF%  |  当你的人靠近商队，其中一位守卫发现了你并吹响号角来提醒其他人。很快，整个护卫队都站在了你的面前，做好作战准备。马车队头目穿过队伍举着手说道。%SPEECH_ON%先住手，士兵们！佣兵，我想和你做笔交易。你拿着这袋%bribe%克朗离开这样就不需要有人死在这。%SPEECH_OFF%你开口回应，但男人举起一根手指继续说道。%SPEECH_ON%哇哦，考虑清楚了，雇佣兵。你不再有先发制人的优势而我雇佣了这些人来保护我的马车是有原因的—他们是杀手，和你一样的杀手。%SPEECH_OFF%  |  随着你人马的靠近，商队的毁灭似乎也近在咫尺。不幸的是，其中一位雇佣兵失足从起伏的树枝上滑下然后蹦蹦跳跳从小山坡上滚下。骚乱足以让整个马车队知道你的存在，而你看着武装护卫过来见你。他们的中尉在两方之间，手伸在空中说道。%SPEECH_ON%等等。等一下。在我们开始杀戮之前，我们先聊聊，如何？我这有%bribe%克朗。%SPEECH_OFF%男人握着一个袋子朝你挥了挥。%SPEECH_ON%拿着钱离开，我们则继续赶路。没必要陷入僵局，对吧？要我说这交易很公平，佣兵，因为你不能再突袭了—现在是真正男人间的对决。所以你怎么说？%SPEECH_OFF%  |  在你的属下准备对商队发动突袭时，一个看守马车的守卫发现了他们。他赶忙跑向警钟处，在%randombrother%刺进他脑袋之前发起警报。不幸的是，涌出来一大群守卫，他们都抽出武器。他们的头头就在他们身后，准备发射进攻命令。%SPEECH_ON%上啊，兄弟们！先等等。我们先聊聊……别这么暴力来解决这争端。%SPEECH_OFF%他瞥了眼死去的守卫。%SPEECH_ON%好吧，为了我们剩下的人。我手上有%bribe%克朗。是你的了，伏击者、刺客、或者无论你怎么自居，只要你收下然后离开。我也建议你这么做—你现在没了先发制人的优势而我给这些人很不错的报酬让他们来保护我的货物，明白吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{那就这样吧。把钱交出来。 |  很公平，我们接受。}",
					function getResult()
					{
						return "Bribe2";
					}

				},
				{
					Text = "这不是私人恩怨，但商队必须死。你也一样。",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Bribe2",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_41.png[/img]{在你起身准备离开之际，商队头头抓着你的手臂。%SPEECH_ON%嘿，我有些好奇，而我猜你有答案。%SPEECH_OFF%你愤怒地拜托他的手臂。他向你道歉，但很快问道。%SPEECH_ON%我想知道是谁派你来的。再加%bribe2%克朗可以让你松口吗？%SPEECH_OFF%  |  商队头头在你离开之前抓住你。%SPEECH_ON%我很好奇，佣兵，而我知道你有答案：是谁派你来的？%SPEECH_OFF%你看了看四周。他笑了然后拍拍你的肩膀。%SPEECH_ON%显然，我不会白让你回答的。再加%bribe2%克朗如何？只要只言片语说出人们称之为‘名字’的东西就行了。那么给我个名字怎么样，雇佣兵。%SPEECH_OFF%  |  头头在你离开之前叫住你。他双手交叉，脚无意识地踢着石头。%SPEECH_ON%你知道的，我还不能放你走。有一些相关信息我想要知道，而我愿意给你%bribe2%克朗，只要你开口。%SPEECH_OFF%你看了看四周，确保周围没有伏击等着你。然后你转向那个男人点点头。%SPEECH_ON%你想要知道是谁派我来的。%SPEECH_OFF%头头微笑着紧握双手。%SPEECH_ON%兄弟，你真是个明白人！是的！我想知道！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{那把钱拿过来吧。 |  非常好，虽然这不影响大局。 |  更棒了。}",
					function getResult()
					{
						return "Bribe3";
					}

				},
				{
					Text = "我不会这么背弃我们的信誉的，我们会走的。",
					function getResult()
					{
						return "Bribe4";
					}

				}
			],
			function start()
			{
				this.World.Assets.addMoney(this.Flags.get("Bribe1"));
				this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail * 2);
				this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得了 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Flags.get("Bribe1") + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "Bribe3",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_41.png[/img]{拿上这些克朗，然后把名字给了头头：%employer%。他舌头跳动就好像某种毒坚果。%SPEECH_ON%%employer%。%employer%！是的，就是他。%employer%，就像某种……好吧，我不想用脏话污了你的耳朵。谢谢你，佣兵，并向你告别。%SPEECH_OFF%你点点头离开了。 |  装上这些额外的克朗，你告诉了头头那个名字：%employer%。那个男人一听到就笑了然后不住点头好像早就猜到了。%SPEECH_ON%你做的很好，佣兵。也是神奇的一天啊，对吧？你显示来到这里朝我挥刀弄枪，几分钟后，我们就达成协议准备离开了。你果真是个生意人。你的才能放在剑上而不是笔上真是可惜了。再见祝好。%SPEECH_OFF%  |  {滴水之恩当涌泉相报。 |  你敬我一尺我敬你一丈。}你接受了他的提议并把%emloyer%的计划全部说了出来。商队头头郑重地点头。%SPEECH_ON%我们生意人不像你们那样用武器，但相信我，就跟凶手一样。祝好，佣兵。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "不用杀任何人就拿到报酬。我可以试着习惯的。",
					function getResult()
					{
						this.World.Contracts.removeContract(this.Contract);
						return 0;
					}

				}
			],
			function start()
			{
				this.World.Assets.addMoney(this.Flags.get("Bribe2"));
				this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail * 2);
				this.World.FactionManager.getFaction(this.Contract.getFaction()).getFlags().set("Betrayed", true);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得了 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Flags.get("Bribe2") + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "Bribe4",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_41.png[/img]{你让他走开。他已经够幸运的了。那个男人点点头，尽管他狭长的面庞已经表达得很清楚他拒绝的意思。 |  你摇摇头。%SPEECH_ON%我会放你走的，但我不能接受这么多。我还需要%employer%的提议，明白吗？%SPEECH_OFF%男人点点头。%SPEECH_ON% 明智的决定，尽管很明显对我来说很不利。不过，我能理解，佣兵。愿旧神与你的旅途同在。我们会再见的，希望会是更好的情况！%SPEECH_OFF%  |  背叛%employer%可能不是最好的选择你这么说道。他点点头表示理解。%SPEECH_ON% 好吧，没事。我不怪你留一手，但真希望你能对他们也这样。祝好，雇佣兵。%SPEECH_OFF%} ",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们要走了！",
					function getResult()
					{
						this.World.Contracts.removeContract(this.Contract);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Swordmaster",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_35.png[/img]{准备攻击商队时, %randombrother% 站到你这边，指着车里的一个男人。%SPEECH_ON%知道那是谁吗?%SPEECH_OFF%你摇摇头.%SPEECH_ON% 那是 %swordmaster% 剑圣.%SPEECH_OFF%你所看到的只是一个普通的男人。那人解释说，他是一位著名的剑术大师，杀死了数不清的人。他竖起大拇指。%SPEECH_ON%仍然想攻击?%SPEECH_OFF%  |  你透过大篷车上的玻璃，发现一张熟悉的脸: %swordmaster%. 你看到的男子在%randomtown% 参加了一个竞技比赛. 如果你没记错的话，他赢了，而且是一个胳膊绑在背后。任何在马背上遇见他的人都很快被杀死，因为他表现出了高超的剑术。这个人很危险，应该小心接近。  }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备迎战！",
					function getResult()
					{
						local unit = clone this.Const.World.Spawn.Troops.Swordmaster;
						unit.Faction <- this.Contract.m.Target.getFaction();
						this.Contract.m.Target.getTroops().push(unit);
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "UndeadSurprise",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_29.png[/img]{发起进攻，你的人从草地上跳出。大篷车警卫看起来很害怕。在他们身后是一群群看起来花哨的生物。可以肯定地说，这将是最奇怪的会面 |  %companyname% 冲向大篷车，拔出武器，前几个人放慢了速度，指出有一个更大的军队从另一边接近大篷车。好好观察一下，你会发现有一群不死族正聚集在这个地方！  }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备迎战！",
					function getResult()
					{
						local enemyFaction = this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse"));
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "UndeadSurprise";
						p.Music = this.Const.Music.UndeadTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.TemporaryEnemies = [
							this.Flags.get("EnemyNobleHouse")
						];
						p.AllyBanners = [
							this.World.Assets.getBanner()
						];
						p.EnemyBanners = [
							enemyFaction.getBannerSmall(),
							this.Const.ZombieBanners[0]
						];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Necromancer, 100 * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WomenAndChildren1",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_97.png[/img]{当你们的人清理战场上的伤员时, %randombrother% 带着一队妇女和儿童来到你身边。你举起你的剑问这是什么.%SPEECH_ON%看来他们带着家人来了。你想让我们做什么?%SPEECH_OFF%如果你让他们走，他们很有可能传播你在这里的消息。如果你杀了他们，好吧，那就要付出沉重的代价…  |  赢了这场战斗，你们的人散开去收货，确保每一个大篷车的货物都完好无损。不幸的是，不是你遇到的每个人都死了——也不是所有人都是成年人。一大群妇女和儿童从战斗的废墟中冒出来，带着一只受伤狗的虚弱慢慢地接近。有些人身上沾满了鲜血. %randombrother% 问他们应该怎么做？%SPEECH_ON%我们应该让他们走，因为，好吧，看看他们。但是…他们可能会告诉别人。你知道女人和她们的大嘴.%SPEECH_OFF%雇佣军们紧张地笑了。其中一个女人抱着她的胸部.%SPEECH_ON%我们不能分辨灵魂的好坏，我们发誓!%SPEECH_OFF% }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们已经收了钱要杀光所有人，那就是我们要做的。",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-5);
						return "WomenAndChildren2";
					}

				},
				{
					Text = "管它呢 — 放了他们。",
					function getResult()
					{
						this.World.Assets.addMoralReputation(2);
						this.Flags.set("Survivors", this.Flags.get("Survivors") + 3);
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WomenAndChildren2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_60.png[/img]{你向 %randombrother%点头示意. 他走上前去，手里拿着武器，用一把锋利的刀砍下一个女人的头。鲜血喷涌而出，她的孩子们被鲜血遮蔽了双眼，看不到其余的景色。当你的兄弟们穿过惊恐的人群时，尖叫声逐渐消失，他们的数量逐渐减少变成零星的呜咽声。你的人反复检查他们的工作，直到受害者安静下来，寂静开始滴落。  |  你快速地挥了一下手，下达了命令。 %randombrother% 不需要花时间就可以把一把刀子刺进孩子的脸中，把孩子钉在母亲的子宫中，然后向上切开，以此来宣告生命的终结。其余的人都散开了，有些人不情愿，而另一些人却虔诚地祈祷着.\n\n 当恐怖弥漫在空气中时，你能感受到一些雇佣军的感觉，这是一种令人厌恶的事情。暴力使一切变得简单，一个高潮接一个的高潮，你知道，无论是在哪一种情况下，无论是谁在那一种情况下，都是失败者。  |  不幸的是，没有人能被允许生存。你发出命令，雇佣军就开始执行任务。一个女人走过来，似乎弄错了方向，向最近的城镇跑去。%randombrothe%的回答是用石头把她的头敲碎。受惊吓的孩子们散开成一团，让你想起了猎兔的日子。跑的最快的雇佣军负责追捕，剩下的留在后面善后。这真是一个可怕的景象.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Well, it\'s not a pretty job, but that\'s what we\'re being paid for.",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CompromisingPapers1",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_60.png[/img]{当大篷车燃烧的时候，你的人从残骸中挑选战利品. %randombrother% 拿着一些信件来找你.%SPEECH_ON%先生，这些可能有点意思.%SPEECH_OFF%你打开其中一个并阅读. %employer% 有一个非常，非常别具一格的动机来攻击这辆特殊的马车。如果有人知道这些细节，那将是一件很遗憾的事…  |  马车还在燃烧，你来到一个木头箱子前，把它踢开。信件弹出，展开，在风中散开。你抓到一封然后阅览。这是一份关于收入的报告 - 有关于 %employer% 的领地. 这似乎揭示了这个人的财务。如果你愿意，你可以用这个对付他…  |  你在大篷车的废墟里发现了一堆文件。其中一卷揭示了 %employer% 的罪行。很有可能，他知道这文件在这大篷车中。这一定是他让你攻击的原因…也可以用来对付他。你怀疑他期望它落入你手中。毕竟你只是一把愚蠢的剑...}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "跟其他东西一起烧掉。",
					function getResult()
					{
						this.Flags.set("IsCompromisingPapers", false);
						this.Contract.setState("Return");
						return 0;
					}

				},
				{
					Text = "好发现，我要留下这些。",
					function getResult()
					{
						this.Flags.set("IsCompromisingPapers", true);
						this.Contract.setState("Return");
						return 0;
					}

				},
				{
					Text = "我们的雇主得额外付钱才能拿到这些.",
					function getResult()
					{
						this.Flags.set("IsCompromisingPapers", true);
						this.Flags.set("IsExtorting", true);
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CompromisingPapers2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_63.png[/img]{你回到%employer%那里并拿出了文件。他几乎立刻就能认出其中一封信上的印章.%SPEECH_ON%那……那是什么?%SPEECH_OFF%你放下文件，正要解释，那人猛地一跃，试图把它们从你身上抢走。当你后退时，他摔倒了。他直起腰来，似乎要保持镇静.%SPEECH_ON%好的，剑士。我知道这是怎么回事。你还想要多少？%SPEECH_OFF%关上门，你们两个商量起来.  |   欢迎你回来，%employer%手里拿着两杯酒转身，但他的笑容很快就消失了.%SPEECH_ON%你手里拿着什么？你从哪儿弄来的？?%SPEECH_OFF%你把其中一份指控文件塞进口袋，点头回答.%SPEECH_ON%我想你知道我从哪儿弄来的。我想你很清楚这是怎么回事。现在。。。我们谈生意吧，是的 %SPEECH_OFF% |  你走进 %employer% 的房间，把指控文件扔到他的桌子上。他看着它们然后大笑.%SPEECH_ON%我才意识到我犯了个错误!%SPEECH_OFF%他把文件弄碎，塞进桌子底下。作为回报，你笑着又找出了一份.%SPEECH_ON%你觉得我这么蠢?%SPEECH_OFF%那个人很快把他撕碎的文件拿出来，盯着它们看。他意识到你只放了一页，剩下的只是空白。你露齿而笑，你制定了基本规则.%SPEECH_ON%既然我知道这些对你有多重要，那就让我们谈正事吧，好让他们都能回到你身边?%SPEECH_OFF%那人坐在座位上点头。他拿出一个装着克朗的私人包包，放在桌上，然后向入口方向示意. |  当你返回时 %employer% 立即注意到你带来的文件上的印章。他房间里有几个守卫，但很快就被赶出去，让他们把兔子从花园里抓回来。他关上门转向你.%SPEECH_ON% 我已经被你抓住把柄了.%SPEECH_OFF%你点头。那人舔了舔嘴唇。%SPEECH_ON%好吧。那些文件上的任何东西都不能离开这个房间。你要多少钱?}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "双倍的报酬。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() * 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail * 2, "Extorted Money");
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
					text = "你获得了 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() * 2 + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "CompromisingPapers3",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_63.png[/img]{你回来见 %employer%, 他看起来很愤怒.%SPEECH_ON%你知道人们都在谈论你所做的，对吗？ %SPEECH_OFF%微笑着，你拿出信件.%SPEECH_ON%你愿意他们谈这个吗?%SPEECH_OFF%那人几乎喘不过气来.%SPEECH_ON%好吧，你在敲诈我吗？%SPEECH_OFF%你把文件放在他的桌子上和他握手.%SPEECH_OFF%  |  %employer% 把你送到他的房间.%SPEECH_ON%农民们在谈论你。那辆大篷车里的人逃走了，在他们还有呼吸的时候，他们觉得可以说出他们所经历的一切。%SPEECH_OFF%你点头同意.%SPEECH_ON%这是可以理解的.%SPEECH_OFF%那个人咆哮着指你，但你却把指控文件抛向他脸上。他沉默不语地站了起来.%SPEECH_ON%我……我知道了你想要更多的报酬?%SPEECH_OFF%你把文件扔给他.%SPEECH_ON%不，你忘了我的一个错误，我忘了你的一个失误。很公平，对吧?%SPEECH_OFF%那人急忙把文件塞进大衣里，点了点头。}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Procured compromising papers");
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
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer%欢迎你回来。他坐在椅子上，正拿着一杯酒。你能感觉到酒水的流动，%SPEECH_ON%嘿，佣兵，知道大家都在谈论你吗？%SPEECH_OFF%他盯着你，你并没有畏缩。他突然笑了起来。%SPEECH_ON%他们根本不知道自己谈论的是你呢。他们还以为那些事情是强盗干的。%SPEECH_OFF%他喝了一口酒。%SPEECH_ON%不管怎样，离胜利又近了一步，但是你做的很好。我的守卫拿着奖励在外面等你。%SPEECH_OFF%  |  你回去找%employer%，发现他正在和狗玩。他摸了摸它们的耳朵，然后看着你。%SPEECH_ON%哟，这不是大家都在谈论的佣兵嘛。%SPEECH_OFF%他笑着看着你，然后把狗赶走了。%SPEECH_ON%啊，没人知道你干了那些事，不过大家都在谈论。他们都以为是强盗干的……我觉得这就很好了。这是你的报酬。%SPEECH_OFF%他指着桌子上的一个木箱子。上面还有狗毛，里面有%reward%克朗。 |  %employer%正在和一些外人交谈。他点点头，仔细倾听他们的担忧。他答应给他们很多东西，给他们答案。他们一离开，他就靠着你的肩膀，%SPEECH_ON%那些农民，他们都在谈论你。他们以为是强盗做的，我很担心他们的说法。%SPEECH_OFF%他停了下来，似乎在思考整件事情，然后耸耸肩。%SPEECH_ON%算了，我觉得都一样。他们不知道和我有关，这就行了。%SPEECH_OFF%他递给你装着%reward%克朗的袋子，%SPEECH_ON%干得好。%SPEECH_OFF%  |  %employer%正在和守卫交谈，他们收到行进的命令后离开了。他看着他们离开，然后转身对着你。%SPEECH_ON%佣兵……你让几个商队的人逃走了，知道吗？我现在只能假装是强盗袭击了道路，然后派几个人去处理后事。真是让人意想不到啊！%SPEECH_OFF%他笑了起来，摆了摆手。%SPEECH_ON%他们不知道这和我有关系，这是你的报酬，下次做得好一点，行吗？%SPEECH_OFF%他给你一个装着%reward%克朗的袋子。}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Destroyed a caravan");
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
			ID = "Failure1",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你返回，发现%employer%正坐在他的桌子旁，在他面前拱着手，他的拇指插在他的额头上。当他开始说话，他的双手向前放下。%SPEECH_ON%你让……他们活下来了……%SPEECH_OFF%你举起一根手指辩解：并不是他们所有人都活下来了。%SPEECH_ON%以众神的永恒的力量的名义，我到底为什么雇用你？%SPEECH_OFF%他停顿一下，然后耸耸肩。%SPEECH_ON%好吧，我会给你我们同意的一半的酬劳。你的确摧毁了马车队，毕竟，我承认。%SPEECH_OFF% | %employer%欢迎你的归来，他的脚放在他的桌上，他沾满烂泥的鞋底滴着污水问候你。%SPEECH_ON%那么，佣兵，向我解释，我为什么雇佣你？%SPEECH_OFF%他伸出一只手，仿佛在说，“说吧。”你说你是被雇来消灭一个商队并且不留幸存者。那个男人举起一根手指。%SPEECH_ON%重复最后那部分。%SPEECH_OFF%你做。那个男人咧着嘴笑，对他自己很满意，但笑容随后因为你的失败而消失。%SPEECH_ON%好吧，你没有做到我要求的事。没关系。你的确做了……其中的一些，我想。商队被消灭了……%SPEECH_OFF%他耸了耸肩，扔给你一个背包。这是欠你的一半。你觉得那好过什么都没有。 | 当你返回，%employer%正在和他的守卫谈话。他把他们打发走，虽然有一个在大厅外面徘徊，他的眼睛时不时的刺探你。你拖出一把%employer%的椅子，但他叫你继续站着。%SPEECH_ON%这会很剪短。你没有做到我要求的所有的事，佣兵。人们在谈论，在谈论你。如果我要求你杀掉所有的目击者，他们怎么可能在谈论你？有点好奇，不是吗？我想这是因为你没杀掉所有那些目击者，这意味着你没有做到我要求的事。%SPEECH_OFF%他停顿一下，在额头摩擦两个指节。%SPEECH_ON%好吧，我会这么做。我会给你一半我们同意的酬劳。一半给你，因为你消灭了商队，一半给我，因为我得花钱掩盖。希望你没意见。%SPEECH_OFF%守卫斜视。你点头收下酬劳。 | %employer%招手让你进去。他正和一个抄写员一起站着，那个抄写员看起来准备好了编造一个故事。你的雇主交叉着他的双臂。%SPEECH_ON%人们正在谈论你做的事……%SPEECH_OFF%那个男人对抄写员做手势，出人意料的是，抄写员没有开始写。%SPEECH_ON%我不得付一些钱让人们闭嘴，明白吗？所以那就意味着你只能得到我们同意的酬劳的一半。%SPEECH_OFF%年长的抄写员咧嘴笑。你注意到他的手指上的一枚戒指。它看起来是新铸造的。%employer%几乎皱着眉，但抄写员没有写任何东西，你把那视为一个好迹象。你收下你的酬劳离开。 | 当你到达，一群咧着嘴笑的男人正离开%employer%的房间。他要你关上你身后的门，然后立即开口说话。%SPEECH_ON%认出那些面孔了吗？他们是发现了你做过的事的人。你知道让他们闭嘴花了多少克朗吗？你知道那些克朗是从哪里来吗？%SPEECH_OFF%你耸耸肩。男人继续说。%SPEECH_ON%你来付，当然。你只会得到一半。你知道为什么吗？%SPEECH_OFF%你点头。生意就是生意。当你转身离开，%employer%抓住你。%SPEECH_ON%别想杀死那些男人来得到你的报酬的另一半，佣兵！%SPEECH_OFF%可恶。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "糟得不能再糟了...",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() / 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to destroy a caravan without letting anyone escape");
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
					text = "你获得了[color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() / 2 + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "Failure2",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你返回，发现%employer%正坐在他的桌子旁，他的肘放在桌子的边缘，前臂竖起，他的拇指插在他的额头上。当他开始说话，他的双手向前放下。%SPEECH_ON%你让……他们活下来了……%SPEECH_OFF%你举起一根手指辩解：并不是他们所有人都活下来了。%SPEECH_ON%以众神的永恒的力量的名义，我到底为什么雇用你？%SPEECH_OFF%他停顿一下，然后发怒。%SPEECH_ON%好像我在乎似的？你让他们中足够多的人活下来了，而那是这个被神抛弃的村子的话题。滚出我的视线，在我的守卫之一干掉你之前。%SPEECH_OFF%  | %employer%的脚底欢迎你的归来，他的双腿放在他的桌子上。你注意到他的靴子上有血。%SPEECH_ON%那么，佣兵，向我解释，我为什么雇用你？%SPEECH_OFF%他伸出一只手，仿佛在说，“说吧。”你说你是被雇来消灭一个商队并且不留幸存者。那个男人举起一根手指。%SPEECH_ON%重复最后那部分。%SPEECH_OFF%你做。那个男人咧着嘴笑，对他自己很满意。%SPEECH_ON%好吧，你没有做到我要求的事。那么，你在这里干什么？我要叫来我的一个守卫，还是你自愿退下？因为你和我不再有生意了。%SPEECH_OFF%  | 当你返回，%employer%正在和他的守卫谈话。他打发几个离开，命令那群人中最高大的那个待在原地。当你进入，他扫视你。\n\n你拖出一把%employer%的椅子，但他叫你继续站着。%SPEECH_ON%这会很剪短。你没有做到我要求的所有的事，佣兵。人们在谈论，在谈论你。如果我要求你杀掉所有的目击者，他们怎么可能在谈论你？有点好奇，不是吗？我最后记得的是，一个死的目击者根本不说话，那让我相信这些证人还活着。确实奇怪，因为那不是我付钱让你做的事。现在在我要我的守卫拔出他的剑在这里刺穿你之前，你为什么不转身滚出我的视线呢？%SPEECH_OFF% | %employer%招手让你进去。他正和一个抄写员一起站着，那个抄写员看起来准备好了编造一个故事。你的雇主交叉着他的双臂。%SPEECH_ON%人们正在谈论你做的事……%SPEECH_OFF%那个男人对抄写员做手势，出人意料的是，抄写员没有开始写。%SPEECH_ON%我不得付一些钱让人们闭嘴，明白吗？所以那就意味着你只能得到我们同意的酬劳的一半。%SPEECH_OFF%年长的抄写员咧嘴笑。你注意到他的手指上的一枚戒指。它看起来是新铸造的。%employer%几乎皱着眉，但抄写员没有写任何东西，你把那视为一个好迹象。你收下你的酬劳离开。 | 当你到达，一群咧着嘴笑的男人正离开%employer%的房间。他问你关上在你身后的门，但在那之前一个守卫走进来。他和%employer%互相点了点头，交换了眼色，然后你关上门。你的雇主坦率的说。%SPEECH_ON%认出那些刚刚走出这里的人了吗？他们是发现了你做过的事的人。你知道让他们闭嘴花了多少克朗吗？你知道那些克朗是从哪里来吗？%SPEECH_OFF%你耸耸肩。男人继续说。%SPEECH_ON%你来付，当然。要让他们的嘴巴闭上，我不得不支付很多钱。%SPEECH_OFF%你点头。生意就是生意，在这种情况下，你什么都得不到。当你转身离开，%employer%抓住你。%SPEECH_ON%别想杀死那些男人来得到你的报酬，佣兵！%SPEECH_OFF%可恶。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "去他妈的合同!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to destroy a caravan without letting anyone escape");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Failure3",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_75.png[/img]{你返回，发现%employer%正坐在他的桌子旁，他的肘放在桌子的边缘，前臂竖起，他的拇指插在他的额头上。当他开始说话，他的双手向前放下。%SPEECH_ON%你让……他们活下来了……%SPEECH_OFF%你举起一根手指辩解：并不是他们所有人都活下来了。%SPEECH_ON%以众神的永恒的力量的名义，我到底为什么雇用你？%SPEECH_OFF%他停顿一下，然后发怒。%SPEECH_ON%好像我在乎似的？你让他们中足够多的人活下来了，而那是这个被神抛弃的村子的话题。滚出我的视线，在我的守卫之一干掉你之前。%SPEECH_OFF%  | %employer%的脚底欢迎你的归来，他的双腿放在他的桌子上。你注意到他的靴子上有血。%SPEECH_ON%那么，佣兵，向我解释，我为什么雇用你？%SPEECH_OFF%他伸出一只手，仿佛在说，“说吧。”你说你是被雇来消灭一个商队并且不留幸存者。那个男人举起一根手指。%SPEECH_ON%重复最后那部分。%SPEECH_OFF%你做。那个男人咧着嘴笑，对他自己很满意。%SPEECH_ON%好吧，你没有做到我要求的事。那么，你在这里干什么？我要叫来我的一个守卫，还是你自愿退下？因为你和我不再有生意了。%SPEECH_OFF%  | 当你返回，%employer%正在和他的守卫谈话。他打发几个离开，命令那群人中最高大的那个待在原地。当你进入，他扫视你。\n\n你拖出一把%employer%的椅子，但他叫你继续站着。%SPEECH_ON%这会很剪短。你没有做到我要求的所有的事，佣兵。人们在谈论，在谈论你。如果我要求你杀掉所有的目击者，他们怎么可能在谈论你？有点好奇，不是吗？我最后记得的是，一个死的目击者根本不说话，那让我相信这些证人还活着。确实奇怪，因为那不是我付钱让你做的事。现在在我要我的守卫拔出他的剑在这里刺穿你之前，你为什么不转身滚出我的视线呢？%SPEECH_OFF% | %employer%招手让你进去。他正和一个抄写员一起站着，那个抄写员看起来准备好了编造一个故事。你的雇主交叉着他的双臂。%SPEECH_ON%人们正在谈论你做的事……%SPEECH_OFF%那个男人对抄写员做手势，出人意料的是，抄写员没有开始写。%SPEECH_ON%我不得付一些钱让人们闭嘴，明白吗？所以那就意味着你只能得到我们同意的酬劳的一半。%SPEECH_OFF%年长的抄写员咧嘴笑。你注意到他的手指上的一枚戒指。它看起来是新铸造的。%employer%几乎皱着眉，但抄写员没有写任何东西，你把那视为一个好迹象。你收下你的酬劳离开。 | 当你到达，一群咧着嘴笑的男人正离开%employer%的房间。他问你关上在你身后的门，但在那之前一个守卫走进来。他和%employer%互相点了点头，交换了眼色，然后你关上门。你的雇主坦率的说。%SPEECH_ON%认出那些刚刚走出这里的人了吗？他们是发现了你做过的事的人。你知道让他们闭嘴花了多少克朗吗？你知道那些克朗是从哪里来吗？%SPEECH_OFF%你耸耸肩。男人继续说。%SPEECH_ON%你来付，当然。要让他们的嘴巴闭上，我不得不支付很多钱。%SPEECH_OFF%你点头。生意就是生意，在这种情况下，你什么都得不到。当你转身离开，%employer%抓住你。%SPEECH_ON%别想杀死那些男人来得到你的报酬，佣兵！%SPEECH_OFF%可恶。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "去他妈的合同！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to destroy a caravan");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"bribe",
			this.m.Flags.get("Bribe1")
		]);
		_vars.push([
			"bribe2",
			this.m.Flags.get("Bribe2")
		]);
		_vars.push([
			"start",
			this.World.getEntityByID(this.m.Flags.get("InterceptStart")).getName()
		]);
		_vars.push([
			"dest",
			this.World.getEntityByID(this.m.Flags.get("InterceptDest")).getName()
		]);
		_vars.push([
			"swordmaster",
			this.Const.Strings.CharacterNames[this.Math.rand(0, this.Const.Strings.CharacterNames.len() - 1)]
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Target != null && !this.m.Target.isNull())
			{
				this.m.Target.getSprite("selection").Visible = false;
				this.m.Target.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (this.World.FactionManager.isGreaterEvil())
		{
			return false;
		}

		return true;
	}

	function onSerialize( _out )
	{
		if (this.m.Target != null && !this.m.Target.isNull())
		{
			_out.writeU32(this.m.Target.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local target = _in.readU32();

		if (target != 0)
		{
			this.m.Target = this.WeakTableRef(this.World.getEntityByID(target));
		}

		this.contract.onDeserialize(_in);
	}

});

