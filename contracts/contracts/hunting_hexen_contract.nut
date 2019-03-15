this.hunting_hexen_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		Dude = null,
		IsPlayerAttacking = true
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.hunting_hexen";
		this.m.Name = "与女巫的契约";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 900 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		this.m.Flags.set("ProtecteeName", this.Const.Strings.CharacterNames[this.Math.rand(0, this.Const.Strings.CharacterNames.len() - 1)]);
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"呆在%townname%附近，保护%employer%的长子"
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

				if (r <= 20)
				{
					this.Flags.set("IsSpiderQueen", true);
				}
				else if (r <= 40)
				{
					this.Flags.set("IsCurse", true);
				}
				else if (r <= 50)
				{
					this.Flags.set("IsEnchantedVillager", true);
				}
				else if (r <= 55)
				{
					this.Flags.set("IsSinisterDeal", true);
				}

				this.Flags.set("StartTime", this.Time.getVirtualTimeF());
				this.Flags.set("Delay", this.Math.rand(10, 30) * 1.0);
				local envoy = this.World.getGuestRoster().create("scripts/entity/tactical/humans/firstborn");
				envoy.setName(this.Flags.get("ProtecteeName"));
				envoy.setTitle("");
				envoy.setFaction(1);
				this.Flags.set("ProtecteeID", envoy.getID());
				this.Contract.m.Home.setLastSpawnTimeToNow();
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Home != null && !this.Contract.m.Home.isNull())
				{
					this.Contract.m.Home.getSprite("selection").Visible = true;
				}

				this.World.State.setUseGuests(true);
			}

			function update()
			{
				if (!this.Contract.isPlayerNear(this.Contract.getHome(), 600))
				{
					this.Flags.set("IsFail2", true);
				}

				if (this.Flags.has("IsFail1") || this.World.getGuestRoster().getSize() == 0)
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.has("IsFail2"))
				{
					this.Contract.setScreen("Failure2");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.has("IsVictory"))
				{
					if (this.Flags.get("IsCurse"))
					{
						local bros = this.World.getPlayerRoster().getAll();
						local candidates = [];

						foreach( bro in bros )
						{
							if (bro.getSkills().hasSkill("trait.superstitious"))
							{
								candidates.push(bro);
							}
						}

						if (candidates.len() == 0)
						{
							this.Contract.setScreen("Success");
						}
						else
						{
							this.Contract.m.Dude = candidates[this.Math.rand(0, candidates.len() - 1)];
							this.Contract.setScreen("Curse");
						}
					}
					else if (this.Flags.get("IsEnchantedVillager"))
					{
						this.Contract.setScreen("EnchantedVillager");
					}
					else
					{
						this.Contract.setScreen("Success");
					}

					this.World.Contracts.showActiveContract();
				}
				else if (!this.TempFlags.has("IsEncounterShown") && this.Flags.get("StartTime") + this.Flags.get("Delay") <= this.Time.getVirtualTimeF())
				{
					this.TempFlags.set("IsEncounterShown", true);

					if (this.Flags.get("IsSpiderQueen"))
					{
						this.Contract.setScreen("SpiderQueen");
					}
					else if (this.Flags.get("IsSinisterDeal") && this.World.Assets.getStash().hasEmptySlot())
					{
						this.Contract.setScreen("SinisterDeal");
					}
					else
					{
						this.Contract.setScreen("Encounter");
					}

					this.World.Contracts.showActiveContract();
				}
				else if (!this.Flags.get("IsBanterShown") && this.Math.rand(1, 1000) <= 1 && this.Flags.get("StartTime") + 6.0 <= this.Time.getVirtualTimeF())
				{
					this.Flags.set("IsBanterShown", true);
					this.Contract.setScreen("Banter");
					this.World.Contracts.showActiveContract();
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getID() == this.Flags.get("ProtecteeID"))
				{
					this.Flags.set("IsFail1", true);
					this.World.getGuestRoster().clear();
				}
			}

			function onActorRetreated( _actor, _combatID )
			{
				if (_actor.getID() == this.Flags.get("ProtecteeID"))
				{
					this.Flags.set("IsFail1", true);
					this.World.getGuestRoster().clear();
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Hexen")
				{
					this.Flags.set("IsVictory", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Hexen")
				{
					this.Flags.set("IsFail2", true);
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
			//Text = "[img]gfx/ui/events/event_79.png[/img]{You find %employer% with a scapula around his neck, though its ordinary thaumaturgical arrangements have been replaced with garlic and onions. He has tears in his eyes.%SPEECH_ON%Oh sellsword am I glad to see you! Please, sit.%SPEECH_OFF%Ducking under herb-heavy streamers, you come and sit before the man. Your eyes slim and begin to water. He continues.%SPEECH_ON%Look, this is going to make me sound like the biggest goddam fool you\'ve ever come by, but listen. Many years ago my firstborn, %protectee%, came into this world clothed in illness. Desperate, I sought the aid of witches...%SPEECH_OFF%You hold up your hand. You ask him if he made a pact and if they\'re here to collect on the debt. The man nods.%SPEECH_ON%Aye. Eighteen years is what they promised and tonight is his eighteenth upon the earth. This is no simple task, sellsword. These women are dangerous beyond any steel\'s proper reckoning, and I wager they\'ll be all the more hellish once they learn I refuse to pay. Are you sure you wish to help me protect my child?%SPEECH_OFF%Wiping your eyes, you weigh the options... | %employer% is found in the corner of his room. He\'s contorted to look out the window like marmot from its warren. Seeing your shadow stretch over him, he leaps and clutches his chest. His wink of cowardice is no laughing matter, though, and he comes to you earnestly.%SPEECH_ON%Witches have hexed my family! Well, hexed my bloodline. Well, more specifically my firstborn, %protectee%. Many moons ago I struggled to put it in... you know, with the wife. I asked the witches for help and they brewed me something proper for the bedroom. Of course, witches being what they is, they\'re now back and asking to take my firstborn away!%SPEECH_OFF%You\'re amazed that witches would do that to him and express your sympathy. %employer% snaps at you.%SPEECH_ON%This is no joking matter! I need protection for my firstborn, are you willing to help save %protectee% or not?%SPEECH_OFF% | You find %employer% fervently flipping through books. It\'s in a manner which suggests he\'s pored over them previously and now he\'s just hurriedly hunting for any missed clue. There is none and he throws the tomes off his table with a burst of anger. Seeing you, he wipes his forehead and explains.%SPEECH_ON%I\'ve searched high and low for an answer, but it seems I will have to resort to steel. That would be your steel, sellsword. I\'ll be honest with you. I made dealings with witches many years ago to protect my firstborn, %protectee%, from a hellish fever. The child survived, but now those awful women are coming back and demand my child as payment.%SPEECH_OFF%You nod. This is almost as bad as the schemes of some loan sharks. He continues, poling a finger into the desk.%SPEECH_ON%I need you here, sellsword. I need a sword to protect %protectee% through the night, and to kill these damned wenches so that my bloodline can live on beyond this nightmare. Are you willing to help?%SPEECH_OFF%}",
Text = "[img]gfx/ui/events/event_79.png[/img]{%SPEECH_ON%多年前，我的长子是个早产儿，但是体弱多病，药石无医。绝望中，我寻求女巫的帮助...%SPEECH_OFF%  你问他是否签了协议，她们是否来这里收债? 他点头。%SPEECH_ON% 十八年是她们承诺的期限，今晚是他在地球上的第十八个年头。这不是一个简单的任务，剑士。这些女人是危险的，超出了任何合理计算，我敢打赌，一旦她们知道我拒绝付钱，她们就会更加疯狂。你能帮助我保护我的孩子吗？%SPEECH_OFF% }", 
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{为了对付这个敌人，你必须付给我们很多钱. | 用一袋克朗说服我这是值得的. | 我希望和这样的敌人战斗能得到丰厚的报酬.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{听起来这是你应该遵守的约定. | 不值得冒这个险. | 我不想让战队和这样的敌人扯上关系.}",
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
			ID = "Banter",
			Title = "沿路行走...",
			//Text = "[img]gfx/ui/events/event_79.png[/img]{%randombrother% 向你走来。他灵敏的耳朵听见了响动.%SPEECH_ON%嘿，队长。你见过他们中的任何一个漂亮的女人吗？?%SPEECH_OFF%听见这话, %randombrother2% 也靠了过来.%SPEECH_ON%嘿，据我所知，她们用眼光魅惑你，她们就是这样得到你的。她们用他们的魅力愚弄你，然后吃掉你的灵魂.%SPEECH_OFF%哈哈, %randombrother% 试图差掉掉落在 %randombrother2% 衣服上的口水.%SPEECH_ON% 她们必须去 %randomtown% 才能得到我的灵魂, 因为我已经被另外的女人所俘虏了.%SPEECH_OFF% | You\'re inspecting inventory when %randombrother% comes up. You\'d sent him to scout the lands and he\'s readied a report.%SPEECH_ON%Sir, nothing sighted as of yet, but I got talking to some of the locals. The way they have it, the witches make pacts with regular folk and then trade on the investment years later, usually with great interest. They said they can fool you into seeing them as licentious minxes. They can bed you right into the grave! I said that sounded like cicada cockamamie to me.%SPEECH_OFF%Nodding, you ask the man what the hell a cicada is. He laughs.%SPEECH_ON%Seriously? It\'s a kind of nut, sir.%SPEECH_OFF% | The brothers are idling the time away, bantering about women and witches alike and if there\'s any real significant difference at all. %randombrother% holds his hand out.%SPEECH_ON%Now in all seriousness, I\'ve heard tales of these wenches. They can put a hex on you to make you see things. They\'ll make you sign bloodpacts and if you don\'t pay they\'ll cut your kneecaps out and use them for divination. Hell, when I was a child, my neighbor made a deal with one and then he disappeared. I later saw a mysterious woman walking around with a fresh skull being used for a lantern!%SPEECH_OFF%%randombrother2% nods attentively.%SPEECH_ON%That\'s incredible, but does anybody know what a witch does?%SPEECH_OFF%}",
Text = "[img]gfx/ui/events/event_79.png[/img]{%randombrother% 向你走来。他灵敏的耳朵听见了响动.%SPEECH_ON%嘿，队长。你见过他们中的任何一个漂亮的女人吗？?%SPEECH_OFF%听见这话, %randombrother2% 也靠了过来.%SPEECH_ON%嘿，据我所知，她们用眼光魅惑你，她们就是这样得到你的。她们用他们的魅力愚弄你，然后吃掉你的灵魂.%SPEECH_OFF%哈哈, %randombrother% 试图差掉掉落在 %randombrother2% 衣服上的口水.%SPEECH_ON% 她们必须去 %randomtown% 才能得到我的灵魂, 因为我已经被另外的女人所俘虏了.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "保持专注,小伙子.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SpiderQueen",
			Title = " %townname% 附近",
			Text = "[img]gfx/ui/events/event_106.png[/img]{一个孤单的女人穿过小路，走到树缝间。她闲逛着，大腿在丝绸衣服上滑进滑出。她的皮肤一尘不染，翡翠色的眼睛凝视着红发之间，带着你小时候就没见过的放荡。你知道这个女人是个完美的女巫，在这个世界上是可怕的存在，她会引领你进入坟墓。这就是她所做的。你拔出你的剑，让她光荣地面对厄运。女巫的皮肤皱成了真正可怕的样子，她高兴得咯咯叫着。%SPEECH_ON%啊，有那么瞬间我拥有了你，但是小公鸡放松了，骄傲又回来了。你的气味真是太好闻了，剑士。我会拯救你.%SPEECH_OFF%在你问她什么意思之前，她站在花丛中间的那两棵树正伸展着蜘蛛一样的腿。巨大的黑球茎从灌木丛中冒出来，飞奔到下面的土地上，蜘蛛用饥饿地敲打着它们的下颌。女巫的手向上举起，手指像木偶一样舞动，指挥着天上的云.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器!",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Hexen";
						p.Entities = [];
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.Entities.push({
							ID = this.Const.EntityType.Spider,
							Variant = 0,
							Row = 1,
							Script = "scripts/entity/tactical/enemies/spider_bodyguard",
							Faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID(),
							Callback = null
						});
						p.Entities.push({
							ID = this.Const.EntityType.Spider,
							Variant = 0,
							Row = 1,
							Script = "scripts/entity/tactical/enemies/spider_bodyguard",
							Faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID(),
							Callback = null
						});
						p.Entities.push({
							ID = this.Const.EntityType.Hexe,
							Variant = 0,
							Row = 2,
							Script = "scripts/entity/tactical/enemies/hexe",
							Faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID(),
							function Callback( _e, _t )
							{
								_e.m.Name = "Spider Queen";
							}

						});
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Spiders, 50 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SinisterDeal",
			Title = " %townname% 附近",
			Text = "[img]gfx/ui/events/event_106.png[/img]{%randombrother% 吹口哨，向那些似乎不知从何而来，在战队面前晕倒的美丽的女士致敬。你把剑一横，刚要向前走一步，但在你开口之前，其中一个女人举着她的手，大步走向你。%SPEECH_ON%让我向你展示我真实的自我，佣兵.%SPEECH_OFF%她的手臂垂向两侧，变成灰色，像潮湿的杏仁皮一样皱缩着。曾经她的头发又亮又滑，现在一缕缕地垂下来，直到她那怪诞的头颅露出来为止. 她鞠了一躬，朝你仰起脸来，蜡黄色的笑容露在脸上.%SPEECH_ON%我们有强大的力量，佣兵，你一定看到了。我跟你做个交易.%SPEECH_OFF%她两手都拿着一个小瓶子，一只手拿着绿色的液体，另一只手拿着蓝色的液体。她微笑着，边说边用手指转动着.%SPEECH_ON%这是强化身体或精神的饮料。男人会为此而杀人。我赐你一个，换长子的命. 为一个陌生人你值得这样做? 你把你应得的那份给宰了，不是吗?你选择哪一边，佣兵，让我们完成这个契约，或者与我们对抗，用你和你兄弟们的生命做赌注，为了那些不记得你的脸的小个子。你选择如何选择？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我永远不会把那个男孩交给你，母夜叉.拿起武器!",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Hexen";
						p.Entities = [];
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.HexenAndNoSpiders, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				},
				{
					Text = "我想强化我的身体.",
					function getResult()
					{
						return "SinisterDealBodily";
					}

				},
				{
					Text = "我想强化我的精神.",
					function getResult()
					{
						return "SinisterDealSpiritual";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SinisterDealBodily",
			Title = " %townname% 附近",
			Text = "[img]gfx/ui/events/event_106.png[/img]{女巫微笑了.%SPEECH_ON%一个人如果没有一个能驾驭他的身体，那他就什么都不是。给你，佣兵。请不要浪费它.%SPEECH_OFF%她把瓶子扔给你。它在空中盘旋，闪烁着七彩的光芒，每一缕微弱的光线都像是从未播种的泥土中迸发出来的一朵小花。你抓住瓶子. 它在你手中振动，你的骨头疼痛慢慢消失，就好像你的拳头一直在沉睡，而你却不知道。当你想找个解释的时候女巫已经走了。只剩下一声孤独的呼喊，在遥远的地方呼啸而过，却无法确定它到底有多远. 毫无疑问， %employer%的长子已经遇害了.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail * 2, "Betrayed " + this.Contract.getEmployer().getName() + " and struck a deal with witches");
						this.World.Contracts.finishActiveContract(true);
						return;
					}

				}
			],
			function start()
			{
				local item = this.new("scripts/items/special/bodily_reward_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "SinisterDealSpiritual",
			Title = " %townname% 附近",
			Text = "[img]gfx/ui/events/event_106.png[/img]{女巫甩了甩手，手腕撞了一下，把绿色的小瓶顺手塞进了袖子里。她把剩下的蓝色小瓶递给你.%SPEECH_ON%你是个聪明人，佣兵。她粗声粗气地哼了一声，肥厚的鼻子缩成了一团，然后又耷拉下来.%SPEECH_ON%我确实感觉到你血液里有敏锐的头脑，佣兵。我几乎想把你的血留下来.%SPEECH_OFF%她的眼睛盯着你，就像一只猫盯着一只跨了界的蟋蟀，一只仍然敢动的蟋蟀。但她的笑容又回来了，更多的是口水而不是牙齿，更多的是黑色而不是粉色.%SPEECH_ON%好吧，一言为定。给你%SPEECH_OFF%她把瓶子扔向空中，当你捡起瓶子，回头一看，女巫们已经走了。你听到了可怕的折磨的微弱的呼喊，它的距离似乎既近又远, 你毫不怀疑%employer%的长子的消亡.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail * 2, "Betrayed " + this.Contract.getEmployer().getName() + " and struck a deal with witches");
						this.World.Contracts.finishActiveContract(true);
						return;
					}

				}
			],
			function start()
			{
				local item = this.new("scripts/items/special/spiritual_reward_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Encounter",
			Title = " %townname% 附近",
			Text = "[img]gfx/ui/events/event_106.png[/img]{%randombrother% 吹口哨，大喊大叫.%SPEECH_ON%我们的战队是个不错的…美丽的战队%SPEECH_OFF%一个放荡的女人正在接近战队。她迈着轻快的步子在地上走来走去，一只手指玩弄着耳朵，另一只手指捏着一块挂在她鼓鼓的胸前的石头。你拍拍佣兵的肩膀.%SPEECH_ON%那不是一个普通的女人.%SPEECH_OFF%话刚一出口，女人丰腴而年轻的五官就萎缩成斑驳的灰色，华贵的头发也从头上垂了下来，你现在看到的是一个母夜叉，咧嘴一笑，满是恶念。拿起武器! 保障 %protectee% 的安全! }",
			//| You spot a woman approaching the party. She\'s wearing bright red and a necklace sways over and between her ample bosom. It\'s quite the sight, but she is flawless and such a thing does not exist in this world.\n\nYou draw your sword. The lady sees the steel and then looks at you with a wily grin. Plots of hair fall from her head and what\'s left shrivels into grey wisps. Her skin shrinks into pale valleys and her fingernails grow so long they curl. She points a finger at you and screams that nobody will prevent the conclusion of the pact she\'s made. You yell out to the company to make sure %protectee% is kept out of harm\'s way. | A woman is spotted approaching the company. The sellswords are ensorcelled by her beauty, but you know better. You draw your sword and clang it loud enough to draw the ire of this supposed lady. She sneers and her lips snap back with a grin that goes from nearly ear to ear. Her skin tightens until it creases and turns a pale grey. She laughs and laughs as her hair falls out. The witch points a finger at you.%SPEECH_ON%Ah, I smell your ancestry, sellsword, but it matters not where you come from. The pact must be paid by the firstborn\'s blood and anyone who stands in our way will bleed in kind!%SPEECH_OFF%The company falls into formation and you tell %protectee% to keep his head down.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器!",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Hexen";
						p.Entities = [];
						p.Music = this.Const.Music.BeastsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.HexenAndNoSpiders, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Curse",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_124.png[/img]{当你返回去找%employer%，你发现%superstitious%盯着一个女巫。你可以看到那个该死的女人的嘴唇还在动，你冲了过去。她在诅咒你，你踢了她一脚。当她笑的时候，牙齿从撕裂的牙龈掉了下来。你拔出你的剑，刺进她的眼睛，让她永远安息。%superstitious%颤抖着说道。%SPEECH_ON%她知道我的一切!她什么都知道，队长!她知道一切!她知道我什么时候死，怎么死!%SPEECH_OFF%你告诉那人不要理会女巫对他说的每一个字。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "别多想了.",
					function getResult()
					{
						return "Success";
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Contract.m.Dude.getImagePath());
				local effect = this.new("scripts/skills/effects_world/afraid_effect");
				this.Contract.m.Dude.getSkills().add(effect);
				this.List.push({
					id = 10,
					icon = effect.getIcon(),
					text = this.Contract.m.Dude.getName() + " is afraid"
				});
				this.Contract.m.Dude.worsenMood(1.5, "Was cursed by a witch");

				if (this.Contract.m.Dude.getMoodState() <= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[this.Contract.m.Dude.getMoodState()],
						text = this.Contract.m.Dude.getName() + this.Const.MoodStateEvent[this.Contract.m.Dude.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "EnchantedVillager",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_124.png[/img]{当士兵们从战场上回复过来时，一个年轻的农民跑过田野，大声叫喊着。你转过身来，看见他扑倒在一个女巫面前，把她那阴森可怕的皮包骨头的身体抱了起来，紧紧地抱在他的怀里，前后摇晃着。他看见你，就破口大骂。%SPEECH_ON%你为什么要这么做?你们这些该死的混蛋!她两星期前嫁给了我，现在我必须埋葬她。我说带我一起走!你们这些野蛮人，你们来试试看吧!这个世界会把我们都埋葬，我的爱人!%SPEECH_OFF%你扬起眉毛。在你到达之前，这个人一定是被施了魔法，可能是他的跟班}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "可怜的傻瓜.",
					function getResult()
					{
						return "Success";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_124.png[/img]{战斗结束，%randombrother%来到你的身边。他说，%protectee%在战斗中死了。他说他的眼球和舌头都不见了，他的脸看起来像两块湿抹布叠在一起。现在没有必要回到%employer%身边。你低头看着%protectee%的尸体。眼球被猛拉了一下，像湿漉漉的岩石一样耷拉下来。他的脸被拉长成一个微笑，尽管这样说一点也不滑稽。%randombrother%询问战队是否应该返回给%employer%消息，你摇了摇头。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "狗屎!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to protect " + this.Contract.getEmployer().getName() + "\'s firstborn son");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Failure2",
			Title = "路上...",
			Text = "[img]gfx/ui/events/event_16.png[/img]{%employer% 付钱给你是为了保护 %protectee%. 当你离开时，长子很难保护。 %townname% 的村民把他交给了女巫. 别费事回去领报酬了. | 你是奉命留在 %townname% 保护 %protectee%  你忘了吗? 不用再回去了，长子肯定已经死了，或者更糟的是，被女巫们出于某种邪恶的目的带走了.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "哦,该死的.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to protect " + this.Contract.getEmployer().getName() + "\'s firstborn son");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success",
			Title = "当你返回...",
			//Text = "[img]gfx/ui/events/event_79.png[/img]{%employer% embraces %protectee%, holding the firstborn tight. He looks at you.%SPEECH_ON%So it\'s done then, all the witches are dead?%SPEECH_OFF%You nod. The townsman nods back.%SPEECH_ON%Thank you! Thank you, mercenary!%SPEECH_OFF%He points you to a chest in the corner of the room. It\'s full of your payment. | You return %protectee% to %employer%. The townsman and firstborn embrace like the telling of two separate dreams of identical circumstance, slowly coming together despite the appeals of reality. Finally, they hug and clench one another and pause to stare at one another to be sure it\'s all real. You tell %employer% that every witch is dead, but that he should keep the tale to himself. He nods.%SPEECH_ON%Spirits feed on hubris, I know that much, and I shall take this story to the grave. I thank you for what you\'ve done today, sellsword. I thank you to such lengths you could not possibly know. I\'ve but one way to express my appreciation.%SPEECH_OFF%He brings you a satchel of gold. The sight of the bag bulging with coin brings a warm smile to your face. | %protectee% runs from your side and into the arms of %employer%. The townsman looks over his firstborn\'s shoulders.%SPEECH_ON%So it\'s done then, we are free of the curse?%SPEECH_OFF%You shrug and respond.%SPEECH_ON%You\'re free of the witches.%SPEECH_OFF%The townsman purses his lips and nods.%SPEECH_ON%Well, that\'s good enough. Your payment is over there in the satchel, as much as promised.%SPEECH_OFF%}",
			Text = "[img]gfx/ui/events/event_79.png[/img]{你告诉雇主每个女巫都死了，但他应该把这件事保密。他点了点头。%SPEECH_ON%灵魂以狂妄为食，我知道这一点，我将把这个故事带入坟墓。谢谢你今天所做的一切，佣兵。我感谢你，感谢到你都不可能知道的程度。%SPEECH_OFF% | %protectee%从你身边跑到%employer%的怀里。那个城里人从他长子的肩膀上看过来。%SPEECH_ON%既然如此，我们摆脱诅咒了吗?%SPEECH_OFF%你耸耸肩回答。你摆脱了女巫的魔爪。那镇上人噘着嘴点点头。%SPEECH_ON%嗯，这已经足够好了。你的报酬就在那边的小提包里，和答应你的一样多。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "最后一切都解决了.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Protected " + this.Contract.getEmployer().getName() + "\'s firstborn son");
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
	}

	function onPrepareVariables( _vars )
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates_helpful = [];
		local candidates_bro1 = [];
		local candidates_bro2 = [];
		local helpful;
		local bro1;
		local bro2;

		foreach( bro in brothers )
		{
			if (bro.getBackground().isLowborn() && !bro.getBackground().isOffendedByViolence() && !bro.getSkills().hasSkill("trait.bright") && bro.getBackground().getID() != "background.hunter")
			{
				candidates_helpful.push(bro);
			}

			candidates_bro1.push(bro);

			if (!bro.getBackground().isOffendedByViolence() && bro.getBackground().isCombatBackground())
			{
				candidates_bro2.push(bro);
			}
		}

		if (candidates_helpful.len() != 0)
		{
			helpful = candidates_helpful[this.Math.rand(0, candidates_helpful.len() - 1)];
		}
		else
		{
			helpful = brothers[this.Math.rand(0, brothers.len() - 1)];
		}

		bro1 = candidates_bro1[this.Math.rand(0, candidates_bro1.len() - 1)];

		if (candidates_bro2.len() > 1)
		{
			do
			{
				bro2 = candidates_bro2[this.Math.rand(0, candidates_bro2.len() - 1)];
			}
			while (bro2.getID() == bro1.getID());
		}
		else if (brothers.len() > 1)
		{
			do
			{
				bro2 = brothers[this.Math.rand(0, brothers.len() - 1)];
			}
			while (bro2.getID() == bro1.getID());
		}
		else
		{
			bro2 = bro1;
		}

		_vars.push([
			"helpfulbrother",
			helpful.getName()
		]);
		_vars.push([
			"bro1",
			bro1.getName()
		]);
		_vars.push([
			"bro2",
			bro2.getName()
		]);
		_vars.push([
			"superstitious",
			this.m.Dude != null ? this.m.Dude.getName() : ""
		]);
		_vars.push([
			"direction",
			this.m.Target == null || this.m.Target.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Target.getTile())]
		]);
		_vars.push([
			"protectee",
			this.m.Flags.get("ProtecteeName")
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/abducted_children_situation"));
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.m.Home.getSprite("selection").Visible = false;
			this.World.State.setUseGuests(true);
			this.World.getGuestRoster().clear();
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

