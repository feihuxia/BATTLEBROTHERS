this.raze_attached_location_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Settlement = null
	},
	function setSettlement( _s )
	{
		this.m.Flags.set("SettlementName", _s.getName());
		this.m.Settlement = this.WeakTableRef(_s);
	}

	function setLocation( _l )
	{
		this.m.Destination = this.WeakTableRef(_l);
		this.m.Flags.set("DestinationName", _l.getName());
	}

	function create()
	{
		this.contract.create();
		this.m.DifficultyMult = 0.85;
		this.m.Type = "contract.raze_attached_location";
		this.m.Name = "夷为平地";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		local s = this.World.EntityManager.getSettlements()[this.Math.rand(0, this.World.EntityManager.getSettlements().len() - 1)];
		this.m.Destination = this.WeakTableRef(s.getAttachedLocations()[this.Math.rand(0, s.getAttachedLocations().len() - 1)]);
		this.m.Flags.set("PeasantsEscaped", 0);
		this.m.Flags.set("IsDone", false);
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 600 * this.getPaymentMult() * this.getDifficultyMult() * this.getReputationToPaymentMult();

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
					"摧毁 " + this.Flags.get("DestinationName") + " 附近的 " + this.Flags.get("SettlementName")
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

				if (this.World.FactionManager.getFaction(this.Contract.getFaction()).getFlags().get("Betrayed") && this.Math.rand(1, 100) <= 75)
				{
					this.Flags.set("IsBetrayal", true);
				}
				else
				{
					this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.Peasants, this.Math.rand(90, 150));

					if (this.Math.rand(1, 100) <= 25)
					{
						this.Flags.set("IsMilitiaPresent", true);
						this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.Militia, this.Math.min(300, 80 * this.Contract.getReputationToDifficultyMult()));
					}
				}

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
					this.Contract.m.Destination.setFaction(this.Const.Faction.Enemy);
					this.Contract.m.Destination.setAttackable(true);
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onDestinationAttacked.bindenv(this));
				}
			}

			function update()
			{
				if (this.Flags.get("IsDone"))
				{
					if (this.Flags.get("IsBetrayal"))
					{
						this.Contract.setScreen("Betrayal2");
					}
					else
					{
						this.Contract.setScreen("Done");
					}

					this.World.Contracts.showActiveContract();
				}
			}

			function onEntityPlaced( _entity, _tag )
			{
				if (_entity.getTags().has("peasant") && this.Math.rand(1, 100) <= 75)
				{
					_entity.setMoraleState(this.Const.MoraleState.Fleeing);
					_entity.getBaseProperties().Bravery = 0;
					_entity.getSkills().update();
					_entity.getAIAgent().addBehavior(this.new("scripts/ai/tactical/behaviors/ai_retreat_always"));
				}

				if (_entity.getTags().has("peasant") || _entity.getTags().has("militia"))
				{
					_entity.setFaction(this.Const.Faction.Enemy);
					_entity.getSprite("socket").setBrush("bust_base_militia");
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				if (this.Contract.m.Destination.getTroops().len() == 0)
				{
					this.onCombatVictory("RazeLocation");
					return;
				}
				else if (!this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("IsAttackDialogTriggered", true);

					if (this.Flags.get("IsBetrayal"))
					{
						this.Contract.setScreen("Betrayal1");
					}
					else if (this.Flags.get("IsMilitiaPresent"))
					{
						this.Contract.setScreen("MilitiaAttack");
					}
					else
					{
						this.Contract.setScreen("DefaultAttack");
					}

					this.World.Contracts.showActiveContract();
				}
				else
				{
					local p = this.World.State.getLocalCombatProperties(this.Contract.m.Destination.getPos());
					p.CombatID = "RazeLocation";
					p.TerrainTemplate = this.Const.World.TerrainTacticalTemplate[this.Contract.m.Destination.getTile().Type];
					p.Tile = this.World.getTile(this.World.worldToTile(this.World.State.getPlayer().getPos()));
					p.PlayerDeploymentType = this.Flags.get("IsEncircled") ? this.Const.Tactical.DeploymentType.Circle : this.Const.Tactical.DeploymentType.Edge;
					p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Center;
					p.Music = this.Const.Music.CivilianTracks;
					p.IsAutoAssigningBases = false;

					foreach( e in p.Entities )
					{
						e.Callback <- this.onEntityPlaced.bindenv(this);
					}

					p.EnemyBanners = [
						"banner_noble_11"
					];
					this.World.Contracts.startScriptedCombat(p, true, true, true);
				}
			}

			function onActorRetreated( _actor, _combatID )
			{
				if (_actor.getTags().has("peasant"))
				{
					this.Flags.set("PeasantsEscaped", this.Flags.get("PeasantsEscaped") + 1);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "RazeLocation")
				{
					this.Contract.m.Destination.setActive(false);
					this.Contract.m.Destination.spawnFireAndSmoke();
					this.Flags.set("IsDone", true);
				}
				else if (_combatID == "Defend")
				{
					this.Flags.set("IsDone", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "RazeLocation")
				{
					this.Flags.set("PeasantsEscaped", 100);
				}
				else if (_combatID == "Defend")
				{
					this.Flags.set("IsDone", true);
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
				this.Contract.m.Destination.getSprite("selection").Visible = false;
				this.Contract.m.Home.getSprite("selection").Visible = true;
				this.Contract.m.Destination.setOnCombatWithPlayerCallback(null);
				this.Contract.m.Destination.setFaction(this.Contract.m.Destination.getSettlement().getFaction());
				this.Contract.m.Destination.clearTroops();
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					if (this.Flags.get("PeasantsEscaped") == 0)
					{
						this.Contract.setScreen("Success1");
					}
					else if (this.Math.rand(1, 100) >= this.Flags.get("PeasantsEscaped") * 10)
					{
						this.Contract.setScreen("Success2");
					}
					else
					{
						this.Contract.setScreen("Failure1");
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
			Text = "[img]gfx/ui/events/event_61.png[/img]{%employer%甩了甩袖子，然后压响自己的指关节。%SPEECH_ON%我想委托你一件十分困难的事情，因为我的家族不能和这件事有任何关系。%SPEECH_OFF%你点点头，佣兵总是被要求保守秘密。他继续说道，%SPEECH_ON%%settlementname%城镇太弱小，没法保护自己，大家都希望有人能赶走强盗。只有我们%noblehousename%家族能提供他们保护。很不幸，当地议会根本看不到这一点。他们都觉得自己能保护好那些人。我要证明他们都错了。\n\n 我希望你烧掉%settlementname%附近的%location%，杀了那儿的农民。记得要伪装成是强盗做的样子。你应该很熟悉他们的做法吧。现在……%SPEECH_OFF%%employer%靠过来，%SPEECH_ON%……我就直说了，你听清楚。一定不要留下任何活口，一个都不留！明白了吗？很好。完成后回来找我。%SPEECH_OFF%  |  %employer%盯着面前的卷轴，突然十分生气地把它们从桌子上推下去。%SPEECH_ON%%settlementname%议会认为他们能保护好自己的城镇不受强盗伤害，我就知道他们不行。就知道他们需要我的保护！而且我给的价格是那么的合理……%SPEECH_OFF%他冷静下来，盯着你。%SPEECH_ON%我知道了，我知道该怎么做，你……你应该很熟悉强盗的行为，对吧？当然。那么，你可不可以……去%settlement%外的%location%……做一些强盗的行径。当然，一定要看上去像是强盗做的……之后城镇肯定会让我去保护他们！他们就会安全了！%SPEECH_OFF%  |  %employer%双手撑着桌面，然后放在自己的额头上。他叹了口气。%SPEECH_ON%我对付%settlementname%那些人已经好多年了，如今我觉得自己有必要采取严厉措施，得到自己想要的。议会不会给我钱，让我保护村庄，因为他们觉得自己能做到。他们说已经很久没出事了。那如果……出事了呢？如果你去那边，假装成强盗，然后让他们知道，没有%noblehousename%，所有人都不会安全！当然，你绝不能把我们的谈话告诉任何人……你觉得如何，雇佣兵？%SPEECH_OFF%  |  %employer%盯着窗外，你坐在椅子上。%SPEECH_ON%起来，佣兵，我不喜欢低着头说话，我必须提高声音，接下来我告诉你的事情，其实我并不想那样做。%SPEECH_OFF%你站起来，凑过去。%SPEECH_ON%%settlementname%拒绝了由我提供保护的提议，他们决定自己处理。他们这样做不仅仅拒绝给%noblehousename%钱，更是侮辱了我们的名声。如果村庄拒绝我们的保护，其他人会怎么想？我希望你假扮成强盗，去那边给他们点教训，让他们知道没有%noblehousename%，情况会变成什么样子！当然，一定要十分谨慎。今天我们的谈话不能有第三个人知道。%SPEECH_OFF%  |  %employer%手里拿着一个苹果，不停用自己的手指摩擦着。%SPEECH_ON%我父亲以前经常对我说，如果你的名字不被人尊敬，那你就一无所有。很不幸，%settlementname%根本不尊重我们%noblehousename%。他们拒绝由我保护城镇的决定，侮辱了我的家族。我希望你给他们点教训。你假扮成强盗去那边，让他们知道没有%noblehousename%，世界会变成什么样子！当然，你一定要非常小心，佣兵。你绝对不能把今天的对话告诉给第三个人。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{咱们谈谈价格吧。 |  我们在谈多少克朗？ |  报酬多少？? |  给个好价钱，一切都可以做到。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不是我们的行当。 | 那不是为了%companyname%。}",
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
			ID = "DefaultAttack",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_16.png[/img]{你到达%location%。农民就像你想的那样外出工作。这就像在桶里叉鱼。现在唯一的问题是：你如何靠近？ |  %location% 比你想象地更平静。一些农民四处溜达，夹着镰刀，挥着锄头，不时地调侃一下这个那个。你听到他们的叫声和笑声。可惜他们剩下的日子不会有趣了。 |  你可以通过高高的野草看看%location%。有一些农民在走动，完全不知道像猫一样轻盈的毁灭穿过草地，到了他们的村落外面。扫描区域，开始策划下一步行动。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "包围他们！",
					function getResult()
					{
						this.Flags.set("IsEncircled", true);
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				},
				{
					Text = "从一边横扫！",
					function getResult()
					{
						this.Flags.set("IsEncircled", false);
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "MilitiaAttack",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_16.png[/img]{你到达%location%，立即告诉你的人趴下。农民正在准备之中，自卫队也是。这不是交易的一部分，你必须相应地重新评估形势。 |  当你靠近 %location%，%randombrother%回来向你报告。显然，不只是农民在那里。几个自卫队员在该地区。如果你要做事，就必须与他们战斗。现在怎么办？ |  自卫队！他们可不在计划之内！如果你想继续，你要同时处理他们和农民。该仔细想想了…… }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "包围他们！",
					function getResult()
					{
						this.Flags.set("IsEncircled", true);
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				},
				{
					Text = "从一边横扫！",
					function getResult()
					{
						this.Flags.set("IsEncircled", false);
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Done",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_02.png[/img]{屠杀成功了。你带上火把去那个地方，让它变成冒烟的废墟。 | 当你跨过和绕过农民的尸体，铜的气味弥漫在空中。你对你的工作的结果点头，然后看着%randombrother%下令。%SPEECH_ON%把它全烧掉。%SPEECH_OFF% | 他们的抵抗比预期的多一点，但最终你把他们都杀光了。或者，至少，你希望你杀光了。不想半途而废，你继续对看见的每一个房子放火。 | 你已经毁灭了%location%。它的居民被杀死，它的建筑被焚烧。任何佣兵的一天的工作的总和。 | 到处都是死人，他们的死的新鲜、香甜的气味已经发霉变质。不流连于恶臭味，你迅速点燃%location%并离开。 | ……并且“抵抗”因此被镇压。这里有几具尸体，那里又有几具尸体。你希望你已经杀光了他们所有人。剩下要做的就是把一切烧为灰烬然后离开。 | 嗯，这是你来到这里的目的。你让几个人以一种你觉得有“教育性的”的方式来展示尸体，然后让其他几个佣兵带上火把去看见的每一个建筑。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们在这里干完了。",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-5);
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"), 3, this.Contract.m.Settlement, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Betrayal1",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_78.png[/img]{你到达%location%，只有一群全副武装的人迎接你。他们其中一人站了出来，拇指插进了绑着剑的皮带里面。%SPEECH_ON%诶呀呀，你们还真是蠢。%employer%记性很好 - 他还没有忘掉你上次背叛了%faction%的事情。把这想成是…………一个小小的回礼好了。%SPEECH_OFF%一瞬间，所有中尉身后的人突了过来。武装起来，这是次埋伏！ |  你走进%location%，但村民们似乎准备好了：你看到门窗紧闭。正当你要命令\n\n他们的武装可比外行人好多了。实际上，他们举着%employer%的旗帜。你意识到中了圈套，这些人开始冲锋，你下令做好武装。 |  一个人在%location%外面的路上向你问好。他的武器很好，装甲很好，而且似乎很开心，当你靠近的时候咧嘴笑着。%SPEECH_ON%晚上好啊，佣兵们。%employer% 发来问候。%SPEECH_OFF%就在这时，一群的人从道路两侧涌出。有埋伏！那该死的贵族背叛了你！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).getFlags().set("Betrayed", false);
						local p = this.Const.Tactical.CombatInfo.getClone();
						p.CombatID = "Defend";
						p.TerrainTemplate = this.Const.World.TerrainTacticalTemplate[this.Contract.m.Destination.getTile().Type];
						p.Tile = this.World.getTile(this.World.worldToTile(this.World.State.getPlayer().getPos()));
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.Music = this.Const.Music.NobleTracks;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 150 * this.Contract.getReputationToDifficultyMult(), this.Contract.getFaction());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Betrayal2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{你在大腿上抹了抹剑，然后立刻收起了它。伏击者们以各种各样怪异的动作毫无生机地倒在了地上。%randombrother%走了过来，询问现在应该做什么。很显然%faction%对你已经不怎么友好了。 |  你将一具伏击者的尸体从脚边踢开。很显然从现在起%faction%已经不在友好名单上了。或许下次，当我保证过会为这些人完成什么事时，我得说到做到。 |  如果没有别的事，你可以从中得到的教训就是这些了：不要承诺你做不到的事情。这些地方的人对那些不能遵守约定的家伙可不友好…… |  你背叛了%faction%了，但那已经不重要了。他们背叛了你，这才是现在最重要的事情！从现在开始，你最好别再相信他们和那些举着他们旗帜的家伙了。 |  根据你脚边的尸体判断，%employer%显然已经对你很不待见了。不用说，一切是因为你之前干得事情-两面三刀，各种失败，乱找借口，或许还睡了贵族的女儿？你能想到的那些乱七八糟的事情已经够多了。现在更重要的是，你们之间的间隙可不是那么容易就能愈合的。你最好提防着点%faction%的人。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "他们这些该死的！",
					function getResult()
					{
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_61.png[/img]{你回去找%employer% 汇报消息。他坐回去，点了点头。%SPEECH_ON%他们全部？%SPEECH_OFF%你看看周围。%SPEECH_ON%你听说有人来了吗？%SPEECH_OFF%%employer%微笑着摇摇头。%SPEECH_ON%只有一些可怕事件的新闻。该死的强盗。%SPEECH_OFF%他打了个响指，一个人从黑暗中出来给你奖励。 |  %employer% 欢迎你的回来，给你喝一杯。他对着下令屠杀农民的人温暖的微笑}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{诚实的工作的诚实的报酬。 | 克朗就是克朗。}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess);
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
			ID = "Success2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_61.png[/img]{你进入%townname%，发现一群熟悉的农民在%employer%周围。你担心他们会认出你，所以待在视线外。他们哭喊着强盗摧毁了%location%。%employer%看起来很担忧。%SPEECH_ON%是吗？真是太糟了！我会调查的。大家不要怕，我会保护你们！!%SPEECH_OFF%他说完之后，一个守卫给你一袋克朗。 }",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{诚实的工作的诚实的报酬。 | 克朗就是克朗。}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnVictory);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractPoor, "Fulfilled a contract");
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
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_43.png[/img]{当你进入%employer%的住所，他转身把一幅画摔在桌子上。%SPEECH_ON%认识这个人吗？%SPEECH_OFF%你捡起它。图上的脸很像你自己。%employer%向后靠。%SPEECH_ON%他们知道有人雇佣袭击那地方。在我的人杀了你之前赶紧滚吧。%SPEECH_OFF%  |  %SPEECH_ON%幸存者！幸存者！我说什么什么，‘不留活口’，我想我说过的对吧？%SPEECH_OFF% 你点点头，%employer%对着桌子猛击}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "他们不会在%settlement%欢迎我们……",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail);
						this.Contract.m.Destination.getSettlement().getFactionOfType(this.Const.FactionType.Settlement).addPlayerRelation(this.Const.World.Assets.RelationAttacked, "Raided " + this.Flags.get("DestinationName"));
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			]
		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"location",
			this.m.Flags.get("DestinationName")
		]);
		_vars.push([
			"settlementname",
			this.m.Flags.get("SettlementName")
		]);
		_vars.push([
			"noblehousename",
			this.World.FactionManager.getFaction(this.m.Faction).getNameOnly()
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Destination != null && !this.m.Destination.isNull())
			{
				this.m.Destination.getSprite("selection").Visible = false;
				this.m.Destination.setFaction(this.m.Destination.getSettlement().getFaction());
				this.m.Destination.setOnCombatWithPlayerCallback(null);
				this.m.Destination.setAttackable(false);
				this.m.Destination.clearTroops();
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

		if (this.m.Destination == null || this.m.Destination.isNull() || !this.m.Destination.isActive())
		{
			return false;
		}

		if (this.m.Settlement == null || this.m.Settlement.isNull())
		{
			return false;
		}

		return true;
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

		if (this.m.Settlement != null && !this.m.Settlement.isNull())
		{
			_out.writeU32(this.m.Settlement.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local dest = _in.readU32();

		if (dest != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(dest));
		}

		local settlement = _in.readU32();

		if (settlement != 0)
		{
			this.m.Settlement = this.WeakTableRef(this.World.getEntityByID(settlement));
		}

		this.contract.onDeserialize(_in);
	}

});

