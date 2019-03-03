this.break_greenskin_siege_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Troops = null,
		IsPlayerAttacking = true,
		IsEscortUpdated = false
	},
	function create()
	{
		this.contract.create();
		local r = this.Math.rand(1, 100);

		if (r <= 70)
		{
			this.m.DifficultyMult = this.Math.rand(90, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}

		this.m.Type = "contract.break_greenskin_siege";
		this.m.Name = "突破围城";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		this.m.MakeAllSpawnsResetOrdersOnContractEnd = false;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		if (this.m.Home == null)
		{
			this.setHome(this.World.State.getCurrentTown());
		}

		this.m.Flags.set("ObjectiveName", this.m.Origin.getName());
		local nearest_orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getNearestSettlement(this.m.Origin.getTile());
		this.m.Flags.set("OrcBase", nearest_orcs.getID());
		local nearest_goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getNearestSettlement(this.m.Origin.getTile());
		this.m.Flags.set("GoblinBase", nearest_goblins.getID());
		this.m.Payment.Pool = 1500 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

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
					"行军到 %objective%",
					"打破绿皮怪物的围城"
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
				local okLocations = 0;

				foreach( l in this.Contract.m.Origin.getAttachedLocations() )
				{
					if (l.isActive())
					{
						okLocations = ++okLocations;
						okLocations = okLocations;
					}
				}

				if (okLocations < 3)
				{
					foreach( l in this.Contract.m.Origin.getAttachedLocations() )
					{
						if (!l.isActive() && !l.isMilitary())
						{
							l.setActive(true);
							okLocations = ++okLocations;
							okLocations = okLocations;

							if (okLocations >= 3)
							{
								break;
							}
						}
					}
				}

				local faction = this.World.FactionManager.getFaction(this.Contract.getFaction());
				local party = faction.spawnEntity(this.Contract.getHome().getTile(), this.Contract.getHome().getName() + " Company", true, this.Const.World.Spawn.Noble, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.getSprite("banner").setBrush(faction.getBannerSmall());
				party.setDescription("Professional soldiers in service to local lords.");
				this.Contract.m.Troops = this.WeakTableRef(party);
				party.getLoot().Money = this.Math.rand(50, 200);
				party.getLoot().ArmorParts = this.Math.rand(0, 25);
				party.getLoot().Medicine = this.Math.rand(0, 5);
				party.getLoot().Ammo = this.Math.rand(0, 30);
				local r = this.Math.rand(1, 4);

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

				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local move = this.new("scripts/ai/world/orders/move_order");
				move.setDestination(this.Contract.getOrigin().getTile());
				c.addOrder(move);
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
				}

				this.World.State.setEscortedEntity(this.Contract.m.Troops);
			}

			function update()
			{
				if (this.Flags.get("IsContractFailed"))
				{
					this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
					this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Company broke a contract");
					this.World.Contracts.finishActiveContract(true);
					return;
				}

				if (this.Contract.m.Troops != null && !this.Contract.m.Troops.isNull())
				{
					if (!this.Contract.m.IsEscortUpdated)
					{
						this.World.State.setEscortedEntity(this.Contract.m.Troops);
						this.Contract.m.IsEscortUpdated = true;
					}

					this.World.State.setCampingAllowed(false);
					this.World.State.getPlayer().setPos(this.Contract.m.Troops.getPos());
					this.World.State.getPlayer().setVisible(false);
					this.World.Assets.setUseProvisions(false);
					this.World.getCamera().moveTo(this.World.State.getPlayer());

					if (!this.World.State.isPaused())
					{
						this.World.setSpeedMult(this.Const.World.SpeedSettings.FastMult);
					}

					this.World.State.m.LastWorldSpeedMult = this.Const.World.SpeedSettings.FastMult;
				}

				if ((this.Contract.m.Troops == null || this.Contract.m.Troops.isNull() || !this.Contract.m.Troops.isAlive()) && !this.Flags.get("IsTroopsDeadShown"))
				{
					this.Flags.set("IsTroopsDeadShown", true);
					this.World.State.setCampingAllowed(true);
					this.World.State.setEscortedEntity(null);
					this.World.State.getPlayer().setVisible(true);
					this.World.Assets.setUseProvisions(true);

					if (!this.World.State.isPaused())
					{
						this.World.setSpeedMult(1.0);
					}

					this.World.State.m.LastWorldSpeedMult = 1.0;
					this.Contract.setScreen("TroopsHaveDied");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerNear(this.Contract.m.Origin, 1200))
				{
					if (this.Contract.m.Troops == null || this.Contract.m.Troops.isNull())
					{
						this.Contract.setScreen("ArrivingAtTheSiegeNoTroops");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("ArrivingAtTheSiege");
						this.World.Contracts.showActiveContract();
					}

					this.World.State.setCampingAllowed(true);
					this.World.State.setEscortedEntity(null);
					this.World.State.getPlayer().setVisible(true);
					this.World.Assets.setUseProvisions(true);

					if (!this.World.State.isPaused())
					{
						this.World.setSpeedMult(1.0);
					}

					this.World.State.m.LastWorldSpeedMult = 1.0;
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.Flags.set("IsContractFailed", true);
			}

		});
		this.m.States.push({
			ID = "Running_BreakSiege",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"摧毁所有绿皮怪物攻城器械",
					"摧毁%objective%周围所有绿皮怪物攻城器械"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = false;
				}

				foreach( id in this.Contract.m.UnitsSpawned )
				{
					local e = this.World.getEntityByID(id);

					if (e != null)
					{
						e.getSprite("selection").Visible = true;

						if (e.getTags().has("SiegeEngine"))
						{
							e.setOnCombatWithPlayerCallback(this.onCombatWithSiegeEngines.bindenv(this));
						}
					}
				}
			}

			function update()
			{
				if (this.Contract.m.UnitsSpawned.len() == 0)
				{
					this.Contract.setScreen("TheAftermath");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.m.Origin == null || this.Contract.m.Origin.isNull() || !this.Contract.m.Origin.isAlive())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatWithSiegeEngines( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
				local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
				p.Music = this.Const.Music.GoblinsTracks;
				p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Edge;
				p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
				p.EnemyBanners = [
					this.World.getEntityByID(this.Flags.get("GoblinBase")).getBanner()
				];
				this.World.Contracts.startScriptedCombat(p, this.Contract.m.IsPlayerAttacking, true, true);
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"返回 " + this.Contract.m.Home.getName()
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = false;
				}

				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					this.Contract.setScreen("Success1");
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer%递给你一杯酒。%SPEECH_ON%干。%SPEECH_OFF%你几乎闻到了他嘴里发出的臭气。你一口气把酒喝完，对他点点头。他也点头回应。%SPEECH_ON%绿皮怪物到处都是，他们似乎想夺走%objective%。%SPEECH_OFF%他又倒满一杯酒，喝下去，然后又倒一杯。%SPEECH_ON%如果它倒下，这个地区也会随之倒下。我不知道你对过去十年发生的事情知道多少，还有上次那些野人的事情，这儿的人都不想再发生那种事了。如今线人告诉我说，围攻刚刚开始，那些绿皮怪物并没有佣金全力，也就是说，我们可以现在发起攻击，在情况失控前先发制人。如果你感兴趣，我当然十分希望这样，我希望你去突破围攻！%SPEECH_OFF%  |  守卫聚集在%employer%身边。他们摘下头盔，脑袋已经被汗水浸透，有的人甚至还在颤抖。%employer%在绝望的人群中发现了你，挥手让你上前。%SPEECH_ON%佣兵！我有一些……特别可怕的消息。或许你已经知道了，我就直说了吧：绿皮怪物已经入侵，并且正威胁占领%objective%。他们正在发动围攻个，不过有消息说，他们并没有出动全力。我希望趁现在情况还没失控，你能去打败他们。%SPEECH_OFF%  |  %employer%旁边站着几个抄写员。他们窃窃私语，贵族对他们说的一切都只是点点头。最后，%employer%把注意力放在你身上，%SPEECH_ON%佣兵，你以前突破过围攻吗？%objective%目前正在被绿皮怪物围攻。他们很快就会蹂躏那里，或许会危及整个地区！之后……呃，你肯定知道十年前发生的事情吧。%SPEECH_OFF%抄写员一致点点头，然后低下脑袋。%employer%继续说着，%SPEECH_ON%你觉得呢，对这个任务感兴趣吗？%SPEECH_OFF%  |  %employer%焦急地欢迎了你。%SPEECH_ON%我们遇到了难题，佣兵，需要你的帮助！%objective%受到了绿皮怪物的围攻，而我的部队人手不够。不过你应该对这个任务感兴趣，是吧？我会给你报酬的。%SPEECH_OFF%  |  %employer%双手支撑着桌子站着。他的肩膀缩成一团，就像乌鸦盯着猎物一样。他摇了摇头。%SPEECH_ON%佣兵，我需要更多人手，帮忙对付绿皮怪物Udine%objective%的围攻。你感兴趣吗？我必须马上知道答案。%SPEECH_OFF%  |  %employer%站在你面前。他脸上有汗水，露出一个近乎疯狂的笑容。%SPEECH_ON%佣兵！很高兴你到这儿来了！据说绿皮怪物正在围攻%objective%，我需要你的帮助！你感兴趣吗？我希望你能马上回答。%SPEECH_OFF%  |  你发现%employer%的身子陷入椅子里，似乎希望椅子能把他埋起来，然后永远和这个世界隔离开一样。他慵懒地指着桌上的一张地图。%SPEECH_ON%据说绿皮怪物回来了，正在围攻%objective%。我需要尽量多召集人手前去解决那边的危机。报酬很丰厚，你加入吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{拯救%objective%对你来说值多少钱？ |  突破围攻是%companyname%能做到的事情。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。 |  我们还有其他事情要做。}",
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
			ID = "PreparingForBattle",
			Title = "在%townname%……",
			Text = "[img]gfx/ui/events/event_78.png[/img]{你离开%employer%的地方，召集战团。骑士和战士们都聚集在你身边。几个人挤在一位圣人身边，默默地准备着死亡。%SPEECH_ON%一定要预定才行。%SPEECH_OFF%%randombrother%说着站在你身边。他对你露出一个假笑。%SPEECH_ON%怎么，太暗了？%SPEECH_OFF%  |  %employer%住所外面到处都是战士。有些人把补给品搬到马车上，有些人在磨武器，有些侍从抱着盔甲来来回回跑个不停。你看着大家，让他们准备好。%randombrother%点点头。%SPEECH_ON%这次会有朋友加入我们吧？%SPEECH_OFF%  |  %employer%房间外面有很多战士，大厅里也有许多。你经过一个又一个房间，里面挤满了瑟瑟发抖的女人和小孩，还有又聋又瞎的老人。在外面，你必须穿过一群抱着盔甲来回跑动的侍从。%companyname%在等你。%SPEECH_ON%我们开始吧。这些人已经做好了战斗的准备，我们刚刚才结束一场战斗，对吧？%SPEECH_OFF%  |  离开%employer%的房间之后，你发现%randombrother%在等你。他看着大家忙碌地准备着战斗：侍从们抱着武器和盔甲，有人把补给放到马车上，圣人正在平息年轻人心中的恐惧。你告诉佣兵稍作准备，你会和大家一起去突破围攻。 |  你走出去，发现%employer%的人正在准备。他们正在把装备搬到马车上，一名圣人走过来。女人，小孩，还有老人都退到一旁。%companyname%尽职地站着。你前去通知他们即将到来的任务。 |  你退到一旁，发现%employer%的战士正在准备战斗。孩子们玩着战争游戏，四处奔跑，肆意欢笑着，根本没有意识到事情的严重性。已经失去过丈夫的女人们显得十分悲伤。你穿过队伍找到%companyname%，告诉他们任务详情。 |  %employer%的战士们正在准备战斗。年轻人十分紧张，假装用勇气和笑容隐藏自己的恐惧。老兵们开始自己的任务，从脸上的表情来看，他们在战场失去了自己的朋友。还有那些疯狂、嗜血的人，他们在战争来临时显得有些头晕。你经过他们身边，通知%companyname%该做什么。 |  出去之后，你发现%employer%的战士们正在准备出发。一大堆武器可供人们挑选。这种现象非常奇怪，显示了缺乏组织。可能不是最好的迹象，你把这件事放在脑后，去通知%companyname%新的合约。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "走吧！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TroopsHaveDied",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]所有贵族战士都在围攻途中死去。他们死总比你们死要好。%companyname%继续向%objective%前进。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们必须继续。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ArrivingAtTheSiege",
			Title = "%objective%附近……",
			Text = "[img]gfx/ui/events/event_68.png[/img]{你终于到达了围攻地。绿皮怪物围绕着%objective%，你看着他们用战争武器向空中投射燃烧的石头。整个村子一半都着火了，你看到有人来回跑动，想扑灭身上的火。贵族战士的中尉命令你去攻击攻城武器。接着你加入支援，消灭剩下的野蛮人。 |  %objective%就像一团巨大的篝火。你看着那些绿皮怪物的围攻武器造成巨大的爆炸，天空中到处都是黑色的石头，死牛，还有燃烧的木头。贵族战士的中尉命令你去消灭攻城武器。他和他的人会攻击绿皮怪物军队的核心，你带着两个人去支援，干掉所有掉队的家伙。 |  围攻仍在继续，%objective%仍在坚守。你似乎来得十分及时，因为绿皮怪物正在用它们的攻城武器发起猛烈的攻势，再过几个小时，这座城镇可能就不复存在了。看到这种场面之后，贵族战士的中尉命令你去消灭攻城武器。他和他的人会攻击绿皮怪物军队的核心，你带着两个人去支援，干掉所有幸存者。 |  还没看到现场的情况，你就听到的轰炸的声音。武器发出的炮弹飞向空中，发出狂风一般的声音，降落的声音代表了残酷的结果。你爬上山顶，想看清楚%objective%的情况。这里被绿皮怪的围攻武器包围，不停发射石头，死牛，还有人类尸体，那群混蛋逮着什么就发射什么。\n\n贵族战士中尉走到你身边，对你说着他的计划。你去侧面攻击围攻武器。他和他的人会攻击绿皮怪物军队的中心，成功后，你带着两个人去支援，干掉剩下的家伙。 |  有个年轻女人紧紧抱着她的孩子坐在路边。虽然她极力用头发遮盖，但还是可以看到脑袋旁边已经结痂的血痕。她说，如果你想去%objective%，最好快点。绿皮怪物正在布置围攻武器，准备进行强力轰炸。你和贵族战士继续前进，给那个女人留下一袋面包。\n\n 爬上另一座山之后，你看到的景象验证了之前那个女人说的话。贵族战士中尉迅速发布命令。你和%companyname%攻击攻城武器，其他战士攻击绿皮怪物军队的中心。这些任务完成后，你们汇合去消灭剩下的家伙。 |  你和贵族战士爬上里%objective%最近的山。城镇虽然还在，但已经差不多快变成废墟了。绿皮怪物不断用它们的围攻武器进行轰炸，而且似乎没完没了。\n\n 贵族战士的中尉命令你去侧翼攻击攻城机器。同时，战士们攻击军队的中心。任务完成后，你们汇合一起消灭剩下的幸存者。 |  你发现一位老人推着马车走在路上。上面躺着一个断腿的年轻人。他晕过去了，手紧紧抓住受伤的膝盖。老人说%objective%就在那座山对面，并且受到了围攻武器的轰炸，如果你们想采取行动，最好加快速度。%companyname%和战士们继续向前，老人推着车也走开了。\n\n 老人没有说谎：%objective%正在燃烧，并且受到了围攻武器的轰炸，很快就会变成废墟。贵族战士中尉看到这种景象后，迅速制定了一个计划：%companyname%去侧翼攻击围攻武器，其他战士去对付绿皮怪物军队。任务完成后，你们汇合一起消灭剩下的幸存者。 |  你在路上发现了一群野狗。它们绕开你们，不过你发现它们夹着尾巴，头也低着。它们迅速跑了过去，没有丝毫逗留。\n\n 登上小山之后，你看到了一切混乱产生的源头：绿皮怪物正在用它们的围攻武器轰炸%objective%。贵族战士中尉点了点头，迅速制定了计划。%companyname%从侧翼攻击围攻武器。任务完成后，回来和战士们回合，继续从这里前进。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备好上战场了！",
					function getResult()
					{
						this.Contract.setState("Running_BreakSiege");
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.spawnSiege();
			}

		});
		this.m.Screens.push({
			ID = "ArrivingAtTheSiegeNoTroops",
			Title = "%objective%附近……",
			Text = "[img]gfx/ui/events/event_68.png[/img]{你终于见到 %objective% 了，它在恐怖海峡。那些绿皮的攻城车正在轰炸这个小镇。你命令%companyname%准备行动：你从侧面攻击那支军队，直接攻击引擎。 |  我们所有的士兵都牺牲了，你要独自去%objective%了。那些绿皮怪物还在用围城武器攻击那个可怜的小镇。你觉得最好的行动方案就是从侧面攻击这些野蛮人，同时破坏他们的攻城车。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备好上战场了！",
					function getResult()
					{
						this.Contract.setState("Running_BreakSiege");
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.spawnSiege();
			}

		});
		this.m.Screens.push({
			ID = "SiegeEquipmentAhead",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_68.png[/img]{绿皮怪物已经在附近装备好一些攻城武器。你必须摧毁他们才能突破重围！ |  你的手下看见附件有一些攻城装备。那个绿皮怪物肯定在准备刺杀。你必须摧毁他们才能突破重围！",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Engage!",
					function getResult()
					{
						this.Contract.getActiveState().onCombatWithSiegeEngines(null, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Shaman",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_48.png[/img]{在你靠近那些攻城的哥布林时，你看到在他们的队列中看到一个特别的轮廓。那是萨满。你命令你的手下准备妥当。 |  在那些哥布林中间有一个很显眼的特别的轮廓。你听到一个恐怖的声音在发号施令，那种声音根本不能称之为一种语言。那个邪恶的生物身上用一些奇怪的植物装饰着，那似乎是一串动物骨头做的项链。%SPEECH_ON%那是个萨满。%SPEECH_OFF%%randombrother% 说他一过来%SPEECH_ON%我就会给其他的兄弟发警告。%SPEECH_OFF%  |  %randombrother%出去侦查回来了。他告诉你们那个哥布林萨满是和那些入侵的绿皮怪物一起来的。那个人看起来有些生气。%SPEECH_ON%我很乐意是杀掉几个哥布林，但是这次那些讨厌的家伙会让我们很头疼的。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Engage!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Warlord",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_49.png[/img]{你靠近那些围城的绿皮怪物时，你看到一个你无法忽视的东西：一个巨大雄伟的兽人军阀。那个讨厌的家伙转过身来用他的兽语发号施令的时候，他的盔甲在闪着光，他的话让他的同伴也就是那些绿皮怪物一时间热血沸腾，但没多久就消退了。你告诉%randombrother%把消息散布出去，让大家都准备好。 | 当你靠近那些来攻城的人的时候，你发现一个高大的野兽般的兽人军阀的轮廓。就算距离隔得这么远，你还是能听到他发号施令的声音。这场战争突然变得有趣起来了。 | 你慢慢靠近攻城的绿皮怪物，但听到的之后那个兽人军阀的咆哮声。他发号施令的声音很难听但很响亮。他的出现让当前的任务有一些小小的改变，你这样通知了你的人。 |  %randombrother%出去侦查回来了。他说在绿皮怪物的营房里有一个兽人军阀。真是个坏消息。但现在知道还有时间准备，总比不知道就贸然闯进去被抓要强。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Engage!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TheAftermath",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_22.png[/img]{战斗已经结束了，绿皮怪物被打的落花流水。%objective%被救了出来，%employer%肯定会很高兴。你跨过堆积成山的尸体，那些尸体有些是人，有些是野兽，但现在都归尘土了，你要把那些逝去的兄弟的尸体带回去。 | 尸体就那么杂乱地堆在战场，成群的苍蝇已经聚集在这里开始忙碌起来了。 你把你的手下聚集起来，准备回去找%employer%要你的酬劳。 |  objective%救出来了！剩下的还有什么呢。你的目光所及之处，都是死去的或者垂死的士兵和绿皮怪物。多么残酷的景象。你命令%companyname%准备回去找%employer%要你的酬劳。 | 一堆堆的尸体堆了两层，三层，甚至四层那么高。发现有些幸存者被埋在这堆6英尺高的尸体下面。真是惨不忍睹。更惨的是一些伤兵和垂死之人在呼喊着希望有人来救他们。要在成千上万的尸体找到他们就像大海捞针一样。你转过身去，让%companyname%的手下集合。%employer%在等待你们回去的时候肯定是很开心的。 |  你们赢得并结束了这场战争，你看到拿着矛穿着铠甲的战士们在战场上十分谨慎地奔跑着。他们利用武器可及的距离安全派遣那些受伤躺在地上的绿皮怪物。其他的士兵瘫坐在地上，喝着水，清洗他们脸上的鲜血。你现在没时间休息了，你必须尽快集合你的佣兵然后回去找%employer%。 |  鲜血让土地变得泥泞不堪，你的靴子也陷入这深深的泥泞中。尸横遍野，血肉模糊，五马分尸。身首异处，死不瞑目。断裂的箭，折断的长矛，被抛弃的剑。那些破碎的盔甲在脚下沙沙的响。这真是一场苦战，它必定会给后人留下一些印记。\n\n %objective%被救了出来，你把%companyname%聚集起来回去找%employer%要那笔丰厚的酬劳。 |  战争结束了，士兵们还在找那些活下来的绿皮怪物，一个一个地砍掉他们的头。 他们在效仿那些被赶走的野蛮人，用矛刺穿那些怪物的头，然后把他们举得老高。你没时间看戏。%objective%被救了出来，你会因此得到报酬。%companyname%迅速集合回去找%employer%要报酬。 |  战争结束了，你小心翼翼地走过战场。每具尸体都在诉说着它们是怎么变成这样的。他们有些被从后面刺杀，有些被砍掉了头，还有些连内脏都被挖了出来，抓着自己的内脏都惊呆了，好像看到了不该看的东西一样。跟寻常的战场一样，没什么新鲜的，只不过发生在不同的地方而已。最重要的是%objective%还活着。你让%companyname%集合回去找%employer%要报酬。 |  %randombrother%来到你身边。他拿着一只绿皮怪物的头，然后把它扔掉，好像那里的其他东西瞬间就黯然失色了。他把他的手放在臀部，向着战场点了点头。%SPEECH_ON%那真是了不起。.%SPEECH_OFF%尸体堆了三层甚至四层，就那么杂乱地堆在地上。四肢扭曲，面部痉挛，鲜血直流。大家穿过那里，因为腿部受伤鲜血直流，最后就好像他们在河床中穿行一样。%objective%，这感觉虽然很强烈，但对你来说只要还能活着站在这里就足够了。%companyname%现在应该回去要他们的报酬了。 |  尽管绿皮怪物一直坚守，但你们还是突破重围了。你目光所及之处，都是人和野兽的尸体，这决定能满足你对战场的所有想象。 |  %randombrother%来到你身边。他举起一只绿色怪兽的尸体到他的肩膀，然后把它像湿抹布一样扔了。%SPEECH_ON%真是一场大战啊，长官。%SPEECH_OFF%你向他点头然后命令他让其他人准备好。%employer%听到%objective%还活着肯定会高兴坏了。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "胜利！",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{几个中尉跟在你身后一起去见%employer%。.他们汇报了消息，然后你的雇主飞快地点了点头，给了你一大包克朗。在你离开的时候他的中尉十分嫉妒地盯着你。 |  你们已经突破重围了，你这样告诉你的%employer%。他点了点头，然后给你了一包克朗。%SPEECH_ON%他们会他谈起你的。我是说，那些人还没出生。%SPEECH_OFF%。你把你们突破重围的消息告诉了%employer%。他站起来和你握手。%SPEECH_ON%以旧神的名义，你今天的贡献会被永远铭记的！%SPEECH_OFF%但你就在想，这种台词不是一般用于某个人牺牲然后归于尘土的时候嘛。不管怎样，你拿了酬劳，历史啊遗产什么的就留给那些哲学家去说吧。 |  %employer%很高兴地欢迎你回来，他飞快地奔向你，差点儿被他的只够绊倒了。%SPEECH_ON%雇佣军，我已经听说了那个好消息！你们已经突破重围了，所以你获得了丰厚的报酬！%SPEECH_OFF%他桌上放着一个很重的箱子。你拿起钱数了数，然后离开了。 | %employer%当你进去的时候，%employer%正坐在桌子后面。%SPEECH_ON%进来吧，英雄。你的名字旁边会刻什么字呢？%SPEECH_OFF%你问 他接下来要干什么。%SPEECH_ON%佣兵，请。不要那么谦虚嘛。你的成就值得我们还未出世的后人称道！%SPEECH_OFF%你点了点头。%SPEECH_ON%是的，当然了。真是太棒了。我的钱在哪儿？%SPEECH_OFF%你的雇主说在钱包里。他也朝你点了点头，然后递给你一个挎包。%SPEECH_ON%你肯定是一个身兼多职的人。这对你来说只是件小事儿，但对我们来说可是了不得的大事儿！%SPEECH_OFF%  |  当你进去的时候%employer%低头看着他的脚。他的情妇藏在他的桌子下，他没有试图把她藏起来。.%SPEECH_ON%欢迎回来，佣兵！你的报酬在那个角落。那边的那个角落。仔细数数。%SPEECH_OFF%拿着你的报酬就离开吧。%employer%叫住你，对你竖起一个大拇指。%SPEECH_ON%顺便说一句，做得好。%SPEECH_OFF%你点了点头然后就离开了。 | 你去%employer%的房间的时候有几个中尉跟在你身后。那个人一看到你的报酬就站了起来，但马上又挥手示意让他的手下离开。他们遵守命令慢吞吞地离开了。你摇了摇头。%SPEECH_ON%他们也付出了很多。%SPEECH_OFF%%employer% 挥手示意让你走。%SPEECH_ON%我当然知道，但他们已经有工资了。但你不同，你和我是签了合同的，现在你完成了这份合同。顺便跟你说一声，你最好不要让其他人看到你的报酬。%SPEECH_OFF%你自己拿好你的报酬就行了。这肯定会引起其他人的嫉妒的，所以你出去的时候就把钱藏得好好的。",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "%objective%救出来了",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Broke siege of " + this.Flags.get("ObjectiveName"));
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isGreenskinInvasion())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCriticalContract);
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
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "%objective%周围",
			Text = "[img]gfx/ui/events/event_68.png[/img]{你来得太晚了，%objective%已经躺在废墟里面了。那些绿皮怪物凭着高超的策略占领了城墙。闻到这种味道，不难猜到里面的人都被杀光了。 |  %companyname% 没有即使突破重围，所以现在%objective%付出了惨重的代价。他们以为你们是去就他们的，但是你杀了他们。如果说还有什么好消息的话，那就是所有人都死了，没人抱怨你的失败了。你的雇主，%employer%却不同。那些贵族对你的不作为肯定很愤怒。 |  %objective%被占领了~兽人将可怕的战争机器开到城墙边，摧毁了防御。恶毒的绿皮怪物席卷了整个城镇，他们看到一个杀一个，要么就是把他们抓去了上帝才知道在哪儿的地方。你的雇主，%employer%对你这次失败的行动感到很愤怒。 | 你没有即使把%objective%救出来。绿皮怪物在前门大肆杀戮，然后，整个镇子里的人都被杀光了。考虑到你没有完成%employer%要求的事情，他对这个结果不高兴是很正常的。 |  因为你的无所作为，%objective%落到了绿皮怪物的手里！希望上帝能对他的臣民仁慈一点，不要指望%employer%会对这个结果满意。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "%objective%沦陷了。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to break the siege of " + this.Flags.get("ObjectiveName"));
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function spawnSiege()
	{
		if (this.m.Flags.get("IsSiegeSpawned"))
		{
			return;
		}

		this.m.SituationID = this.m.Origin.addSituation(this.new("scripts/entity/world/settlements/situations/besieged_situation"));
		local originTile = this.m.Origin.getTile();
		local orcBase = this.World.getEntityByID(this.m.Flags.get("OrcBase"));
		local goblinBase = this.World.getEntityByID(this.m.Flags.get("GoblinBase"));
		local numSiegeEngines;

		if (this.m.DifficultyMult >= 1.15)
		{
			numSiegeEngines = this.Math.rand(1, 2);
		}
		else
		{
			numSiegeEngines = 1;
		}

		local numOtherEnemies;

		if (this.m.DifficultyMult >= 1.25)
		{
			numOtherEnemies = this.Math.rand(2, 3);
		}
		else if (this.m.DifficultyMult >= 0.95)
		{
			numOtherEnemies = 2;
		}
		else
		{
			numOtherEnemies = 1;
		}

		for( local i = 0; i < numSiegeEngines; i = i )
		{
			local tile;
			local tries = 0;

			while (tries++ < 500)
			{
				local x = this.Math.rand(originTile.SquareCoords.X - 2, originTile.SquareCoords.X + 2);
				local y = this.Math.rand(originTile.SquareCoords.Y - 2, originTile.SquareCoords.Y + 2);

				if (!this.World.isValidTileSquare(x, y))
				{
					continue;
				}

				tile = this.World.getTileSquare(x, y);

				if (tile.getDistanceTo(originTile) <= 1)
				{
					continue;
				}

				if (tile.Type == this.Const.World.TerrainType.Ocean)
				{
					continue;
				}

				if (tile.IsOccupied)
				{
					continue;
				}

				break;
			}

			local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).spawnEntity(tile, "Siege Engines", false, this.Const.World.Spawn.GreenskinHorde, this.Math.rand(100, 120) * this.getDifficultyMult() * this.getReputationToDifficultyMult());
			this.m.UnitsSpawned.push(party.getID());
			party.setDescription("A horde of greenskins and their siege engines.");
			local numSiegeUnits = this.Math.rand(3, 4);

			for( local j = 0; j < numSiegeUnits; j = j )
			{
				this.Const.World.Common.addTroop(party, {
					Type = this.Const.World.Spawn.Troops.GreenskinCatapult
				}, false);
				j = ++j;
			}

			party.updateStrength();
			party.getLoot().ArmorParts = this.Math.rand(0, 15);
			party.getLoot().Ammo = this.Math.rand(0, 10);
			party.addToInventory("supplies/strange_meat_item");
			party.getSprite("body").setBrush("figure_siege_01");
			party.getSprite("banner").setBrush(goblinBase != null ? goblinBase.getBanner() : "banner_goblins_01");
			party.getSprite("banner").Visible = false;
			party.getSprite("base").Visible = false;
			party.setAttackableByAI(false);
			party.getTags().add("SiegeEngine");
			local c = party.getController();
			c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
			c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
			local wait = this.new("scripts/ai/world/orders/wait_order");
			wait.setTime(9000.0);
			c.addOrder(wait);
			i = ++i;
		}

		local targets = [];

		foreach( l in this.m.Origin.getAttachedLocations() )
		{
			if (l.isActive() && l.isUsable())
			{
				targets.push(l);
			}
		}

		if (targets.len() == 0)
		{
			foreach( l in this.m.Origin.getAttachedLocations() )
			{
				if (l.isUsable())
				{
					targets.push(l);
				}
			}
		}

		for( local i = 0; i < numOtherEnemies; i = i )
		{
			local tile;
			local tries = 0;

			while (tries++ < 500)
			{
				local x = this.Math.rand(originTile.SquareCoords.X - 4, originTile.SquareCoords.X + 4);
				local y = this.Math.rand(originTile.SquareCoords.Y - 4, originTile.SquareCoords.Y + 4);

				if (!this.World.isValidTileSquare(x, y))
				{
					continue;
				}

				tile = this.World.getTileSquare(x, y);

				if (tile.getDistanceTo(originTile) <= 1)
				{
					continue;
				}

				if (tile.Type == this.Const.World.TerrainType.Ocean)
				{
					continue;
				}

				break;
			}

			local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).spawnEntity(tile, "Greenskin Horde", false, this.Const.World.Spawn.GreenskinHorde, this.Math.rand(90, 110) * this.getDifficultyMult() * this.getReputationToDifficultyMult());
			this.m.UnitsSpawned.push(party.getID());
			party.setDescription("A horde of greenskins marching to war.");
			party.getLoot().ArmorParts = this.Math.rand(0, 15);
			party.getLoot().Ammo = this.Math.rand(0, 10);
			party.addToInventory("supplies/strange_meat_item");
			party.getSprite("banner").setBrush(orcBase != null ? orcBase.getBanner() : "banner_orcs_01");
			local c = party.getController();
			local raidTarget = targets[this.Math.rand(0, targets.len() - 1)].getTile();
			c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
			local raid = this.new("scripts/ai/world/orders/raid_order");
			raid.setTime(30.0);
			raid.setTargetTile(raidTarget);
			c.addOrder(raid);
			local destroy = this.new("scripts/ai/world/orders/destroy_order");
			destroy.setTime(60.0);
			destroy.setSafetyOverride(true);
			destroy.setTargetTile(originTile);
			destroy.setTargetID(this.m.Origin.getID());
			c.addOrder(destroy);
			i = ++i;
		}

		if (this.m.Troops != null && !this.m.Troops.isNull())
		{
			local c = this.m.Troops.getController();
			c.clearOrders();
			local intercept = this.new("scripts/ai/world/orders/intercept_order");
			intercept.setTarget(this.World.getEntityByID(this.m.UnitsSpawned[this.m.UnitsSpawned.len() - 1]));
			c.addOrder(intercept);
			local guard = this.new("scripts/ai/world/orders/guard_order");
			guard.setTarget(originTile);
			guard.setTime(120.0);
		}

		this.m.Origin.spawnFireAndSmoke();
		this.m.Origin.setLastSpawnTimeToNow();
		this.m.Flags.set("IsSiegeSpawned", true);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"objective",
			this.m.Flags.get("ObjectiveName")
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.World.State.setCampingAllowed(true);
			this.World.State.setEscortedEntity(null);
			this.World.State.getPlayer().setVisible(true);
			this.World.Assets.setUseProvisions(true);

			if (!this.World.State.isPaused())
			{
				this.World.setSpeedMult(1.0);
			}

			this.World.State.m.LastWorldSpeedMult = 1.0;

			if (!this.m.Flags.get("IsSiegeSpawned"))
			{
				this.spawnSiege();
			}

			foreach( id in this.m.UnitsSpawned )
			{
				local e = this.World.getEntityByID(id);

				if (e != null && e.isAlive())
				{
					e.setAttackableByAI(true);

					if (e.getTags().has("SiegeEngine"))
					{
						local c = e.getController();
						c.clearOrders();
						local wait = this.new("scripts/ai/world/orders/wait_order");
						wait.setTime(120.0);
						c.addOrder(wait);
					}
				}
			}

			if (this.m.Origin != null && !this.m.Origin.isNull())
			{
				this.m.Origin.getSprite("selection").Visible = false;
			}

			if (this.m.Home != null && !this.m.Home.isNull())
			{
				this.m.Home.getSprite("selection").Visible = false;
			}
		}

		if (this.m.Origin != null && !this.m.Origin.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Origin.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(2);
			}
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isGreenskinInvasion())
		{
			return false;
		}

		local numAttachments = 0;

		foreach( l in this.m.Origin.getAttachedLocations() )
		{
			if (l.isActive() && l.isUsable())
			{
				numAttachments = ++numAttachments;
				numAttachments = numAttachments;
			}
		}

		if (numAttachments < 2)
		{
			return false;
		}

		return true;
	}

	function onSerialize( _out )
	{
		if (this.m.Troops != null && !this.m.Troops.isNull())
		{
			_out.writeU32(this.m.Troops.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local troops = _in.readU32();

		if (troops != 0)
		{
			this.m.Troops = this.WeakTableRef(this.World.getEntityByID(troops));
		}

		this.contract.onDeserialize(_in);
	}

});

