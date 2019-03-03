this.marauding_greenskins_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Objective = null,
		Target = null,
		IsPlayerAttacking = true,
		LastRandomEventShown = 0.0
	},
	function setObjective( _h )
	{
		if (typeof _h == "instance")
		{
			this.m.Objective = _h;
		}
		else
		{
			this.m.Objective = this.WeakTableRef(_h);
		}
	}

	function setOrcs( _o )
	{
		this.m.Flags.set("IsOrcs", _o);
	}

	function create()
	{
		this.contract.create();
		this.m.Type = "contract.marauding_greenskins";
		this.m.Name = "Marauding Greenskins";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
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

		local myTile = this.m.Origin.getTile();
		local orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getNearestSettlement(myTile);
		local goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getNearestSettlement(myTile);

		if (myTile.getDistanceTo(orcs.getTile()) + this.Math.rand(0, 8) < myTile.getDistanceTo(goblins.getTile()) + this.Math.rand(0, 8))
		{
			this.m.Flags.set("IsOrcs", true);
		}
		else
		{
			this.m.Flags.set("IsOrcs", false);
		}

		local bestDist = 9000;
		local best;
		local settlements = this.World.EntityManager.getSettlements();

		foreach( s in settlements )
		{
			if (s.isMilitary())
			{
				continue;
			}

			if (s.getID() == this.m.Origin.getID() || s.getID() == this.m.Home.getID())
			{
				continue;
			}

			local d = this.getDistanceOnRoads(s.getTile(), this.m.Origin.getTile());

			if (d < bestDist)
			{
				bestDist = d;
				best = s;
			}
		}

		if (best != null)
		{
			local distance = this.getDistanceOnRoads(best.getTile(), this.m.Origin.getTile());
			this.m.Flags.set("MerchantReward", this.Math.max(150, distance * 5.0 * this.getPaymentMult()));
			this.setObjective(best);
			this.m.Flags.set("MerchantID", best.getFactionOfType(this.Const.FactionType.Settlement).getRandomCharacter().getID());
		}

		this.m.Payment.Pool = 800 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

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
					"杀死%origin%周围的掠夺绿皮怪物"
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

				if (r <= 5 && this.World.Assets.getBusinessReputation() >= 2250)
				{
					if (this.Flags.get("IsOrcs") == true)
					{
						this.Flags.set("IsWarlord", true);
					}
					else
					{
						this.Flags.set("IsShaman", true);
					}
				}
				else if (r <= 10 && this.Contract.m.Objective != null)
				{
					this.Flags.set("IsMerchant", true);
				}

				local originTile = this.Contract.m.Origin.getTile();
				local tile = this.Contract.getTileToSpawnLocation(originTile, 5, 10);
				local party;

				if (this.Flags.get("IsOrcs"))
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).spawnEntity(tile, "Orc Marauders", false, this.Const.World.Spawn.OrcRaiders, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					party.setDescription("A band of menacing orcs, greenskinned and towering any man.");
					party.getLoot().ArmorParts = this.Math.rand(0, 25);
					party.getLoot().Ammo = this.Math.rand(0, 10);
					party.addToInventory("supplies/strange_meat_item");
					local enemyBase = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getNearestSettlement(this.Contract.getOrigin().getTile());
					party.getSprite("banner").setBrush(enemyBase.getBanner());
				}
				else
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).spawnEntity(tile, "Goblin Raiders", false, this.Const.World.Spawn.GoblinRaiders, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					party.setDescription("A band of mischievous goblins, small but cunning and not to be underestimated.");
					party.getLoot().ArmorParts = this.Math.rand(0, 10);
					party.getLoot().Medicine = this.Math.rand(0, 2);
					party.getLoot().Ammo = this.Math.rand(0, 30);
					local r = this.Math.rand(1, 4);

					if (r == 1)
					{
						party.addToInventory("supplies/strange_meat_item");
					}
					else if (r == 2)
					{
						party.addToInventory("supplies/roots_and_berries_item");
					}
					else if (r == 3)
					{
						party.addToInventory("supplies/pickled_mushrooms_item");
					}

					local enemyBase = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getNearestSettlement(this.Contract.getOrigin().getTile());
					party.getSprite("banner").setBrush(enemyBase.getBanner());
				}

				this.Contract.m.UnitsSpawned.push(party.getID());
				this.Contract.m.Target = this.WeakTableRef(party);
				party.setAttackableByAI(false);
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local roam = this.new("scripts/ai/world/orders/roam_order");
				roam.setPivot(this.Contract.m.Origin);
				roam.setMinRange(3);
				roam.setMaxRange(8);
				roam.setAllTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
				roam.setTerrain(this.Const.World.TerrainType.Shore, false);
				roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
				c.addOrder(roam);
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
				}

				this.Contract.m.Origin.getSprite("selection").Visible = true;
			}

			function update()
			{
				local playerTile = this.World.State.getPlayer().getTile();

				if (this.Contract.m.Target == null || this.Contract.m.Target.isNull() || !this.Contract.m.Target.isAlive())
				{
					if (this.Flags.get("IsMerchant") && this.Contract.m.Objective != null && !this.Contract.m.Objective.isNull())
					{
						this.Contract.setScreen("Merchant");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsOrcs"))
					{
						this.Contract.setScreen("BattleWonOrcs");
						this.World.Contracts.showActiveContract();
						this.Contract.setState("Return");
					}
					else
					{
						this.Contract.setScreen("BattleWonGoblins");
						this.World.Contracts.showActiveContract();
						this.Contract.setState("Return");
					}
				}
				else if (playerTile.getDistanceTo(this.Contract.m.Target.getTile()) <= 10 && this.Contract.m.Target.isHiddenToPlayer() && this.Time.getVirtualTimeF() - this.Contract.m.LastRandomEventShown >= 30.0 && this.Math.rand(1, 1000) <= 1)
				{
					this.Contract.m.LastRandomEventShown = this.Time.getVirtualTimeF();

					if (!this.Flags.get("IsBurnedFarmsteadShown") && playerTile.Type == this.Const.World.TerrainType.Plains || playerTile.Type == this.Const.World.TerrainType.Hills || playerTile.Type == this.Const.World.TerrainType.Highlands || playerTile.Type == this.Const.World.TerrainType.Steppe)
					{
						this.Flags.set("IsBurnedFarmsteadShown", true);
						this.Contract.setScreen("BurnedFarmstead");
						this.World.Contracts.showActiveContract();
					}
					else if (!this.Flags.get("IsCaravanShown") && playerTile.HasRoad)
					{
						this.Flags.set("IsCaravanShown", true);
						this.Contract.setScreen("DestroyedCaravan");
						this.World.Contracts.showActiveContract();
					}
					else if (!this.Flags.get("IsDeadBodiesOrcsShown") && this.Flags.get("IsOrcs") == true)
					{
						this.Flags.set("IsDeadBodiesOrcsShown", true);
						this.Contract.setScreen("DeadBodiesOrcs");
						this.World.Contracts.showActiveContract();
					}
					else if (!this.Flags.get("IsDeadBodiesGoblinsShown") && this.Flags.get("IsOrcs") == false)
					{
						this.Flags.set("IsDeadBodiesGoblinsShown", true);
						this.Contract.setScreen("DeadBodiesGoblins");
						this.World.Contracts.showActiveContract();
					}
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (this.Flags.get("IsWarlord") && !this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("IsAttackDialogTriggered", true);
					this.Const.World.Common.addTroop(this.Contract.m.Target, {
						Type = this.Const.World.Spawn.Troops.OrcWarlord
					}, false);
					this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
					this.Contract.setScreen("Warlord");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsShaman") && !this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("IsAttackDialogTriggered", true);
					this.Const.World.Common.addTroop(this.Contract.m.Target, {
						Type = this.Const.World.Spawn.Troops.GoblinShaman
					}, false);
					this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
					this.Contract.setScreen("Shaman");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					this.World.Contracts.showCombatDialog(_isPlayerAttacking);
				}
			}

		});
		this.m.States.push({
			ID = "Running_Merchant",
			function start()
			{
				this.Contract.m.Origin.getSprite("selection").Visible = false;

				if (this.Contract.m.Objective != null && !this.Contract.m.Objective.isNull())
				{
					this.Contract.m.Objective.getSprite("selection").Visible = true;
				}

				this.Contract.m.BulletpointsObjectives = [
					"去%objectivedirection%找%objective%的商人"
				];
				this.Contract.m.BulletpointsPayment = [];
				this.Contract.m.BulletpointsPayment.push("Get %reward_merchant% crowns once you arrive");
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Objective))
				{
					this.Contract.setScreen("Success2");
					this.World.Contracts.showActiveContract();
					this.Contract.setState("Return");
				}
			}

			function end()
			{
				if (this.Contract.m.Objective != null && !this.Contract.m.Objective.isNull())
				{
					this.Contract.m.Objective.getSprite("selection").Visible = false;
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
				this.Contract.m.BulletpointsPayment = [];

				if (this.Contract.m.Payment.Advance != 0)
				{
					this.Contract.m.BulletpointsPayment.push("Get " + this.Contract.m.Payment.getInAdvance() + " crowns in advance");
				}

				if (this.Contract.m.Payment.Completion != 0)
				{
					this.Contract.m.BulletpointsPayment.push("Get " + this.Contract.m.Payment.getOnCompletion() + " crowns on completion");
				}

				this.Contract.m.Home.getSprite("selection").Visible = true;
				this.Contract.m.Origin.getSprite("selection").Visible = false;
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer%无精打采地坐着，偶尔发出一两声叹息，告诉你今天过得如何。他在问你之前，用手按了按自己的太阳穴。%SPEECH_ON%一群绿皮怪物正在%origin%附近进行抢劫。他们无恶不作。{我们的人非常害怕，什么都做不了。| 我们有很多人四处游荡。| 没有报酬的话，我们是不会动手的。}你是阻止那些家伙的最后希望。如果他们想去哪儿就去哪儿，那我们永远别想重建了！%SPEECH_OFF%他慢慢闭上眼睛，叹了口气。%SPEECH_ON%他们是绿皮怪物。不管去哪儿都会留下痕迹。要找到他们并不难，对吧？杀了他们，为%origin%的人报仇！%SPEECH_OFF% | %employer%盯着窗外，问了个简单的问题。%SPEECH_ON%你知道哪些绿皮怪物会如何对待婴儿吗？%SPEECH_OFF%你转过头去，角落里的一个守卫耸耸肩。你提出问题。%SPEECH_ON%是的。%SPEECH_OFF%贵族点点头，回到桌子边坐下。%SPEECH_ON%他们正在进攻%origin%。你必须找到他们，杀了他们。我不能……他们不能……反正杀了他们吧，好吗？%SPEECH_OFF% | %employer%拿着一支蜡烛走到书边，他的眼睛里闪着光芒，看着一些你读不懂的文字。%SPEECH_ON%他们说绿皮怪物已经在这里生活很久很久了，你相信吗？%SPEECH_OFF%你耸耸肩，用自己知道的指示回答，%SPEECH_ON%如果你想在这个世界活下去，就必须战斗，绿皮怪物确实似乎已经生存很久了。%SPEECH_OFF%他点点头，似乎很欣赏你的观察力。%SPEECH_ON%他们正在抢劫%origin%。烧光遇到的所有东西，杀死每个人……这些都是非常显而易见的事情。还有，我需要你，佣兵，找到并杀了他们，你有兴趣吗？%SPEECH_OFF% | %employer%坐在椅子上笑了起来，他把脑袋埋在手里，像个小丑一样。这种样子并不好看。他看着你，眼神充满疲惫。%SPEECH_ON%绿皮怪物又抱走了，我不知道他们在哪儿，只知道他们去过哪儿。你认识那些标志，对吧？%SPEECH_OFF%你点点头回答道，%SPEECH_ON%他们留下了很大的足迹，不单单是他们的脚印。%SPEECH_OFF%他又笑起来，似乎很痛苦。%SPEECH_ON%我需要你做一些事情。你愿意吗？%SPEECH_OFF% | %employer%起来走到床边，摇了摇头，然后重新回到桌子边。他慢慢坐下来。%SPEECH_ON%一开始我听说是土匪，然后又听说是从海边来的掠夺者。之后幸存者们开口说话了，你知道问题所在了吧？%SPEECH_OFF%你耸耸肩。%SPEECH_ON%这重要吗？%SPEECH_OFF%他皱起眉头。%SPEECH_ON%绿皮怪物，佣兵。这就是他们的真实身份。他们在%origin%作恶，我希望你能组织他们，现在重要了吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{如果价格合适，我们可以去追捕它们。| 对抗绿皮怪物可不便宜。| 我们来谈谈钱的问题。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。| 我们还有其他事情要做。}",
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
			ID = "DestroyedCaravan",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_60.png[/img]{一辆拖车。很明显，外表不是很好看。马车已经翻了，驾驶员也被杀死了。你追着秃鹰寻找证据。就算大屠杀不足以证明是绿皮怪物干的，那些脚印绝对可以，你走对路了。| 要跟着绿皮怪物并不困难。你被一辆烧焦的马车绊倒。从火焰的痕迹看，还很新鲜，有些木头还烧着。商人们的尸体还很新鲜，似乎是被吓死的。继续前进，或许还能找到那群混蛋。| 有个人被吊在书上，好像是从天上掉下来，不小心挂上去的。树枝上还有两只死驴子。下面有一辆四脚朝天的马车，轮子已经四分五裂。货物散落得到处都是。一堆营火还燃着，但已经十分微弱，似乎很想在周围找点能继续存活下去的材料。\n\n 毫无疑问，这是绿皮怪物的杰作。你很快就能找到他们了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "肯定很接近了。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BurnedFarmstead",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_71.png[/img]{烟圈从农场的废墟中袅袅溢出。曾是前门的地方躺着一具尸体。但它有半截不见了。剩下的半截面目狰狞，被灼伤的手臂似乎在探出想要够些现已不在该处的什么东西，或者是某人。泥泞和草地中散布着一些脚印。绿皮怪物。你离得越来越近了。| 小农场毫无机会。到处都是被杀的农场工人，手中依然握着用作武器的甘草叉。其中一根叉子尖头还沾有血迹。但那绝对不是属于人类的血。你跟随踪迹，心里很清楚很快就会撞见造成这一切的凶手。| 一只死狗。又一只。要猜也是牧羊犬，虽然那惨状使其不易辨别。他们的主人离得不远——他们似乎在猎犬殿后抵抗时逃跑。不幸的是，足迹显示这些农民时撞见了绿皮怪物。牧羊犬们激烈反抗，而他们的主人却夺路而逃。\n\n你很近了。继续走你就会撞见那些混蛋了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "肯定很接近了。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "DeadBodiesOrcs",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_60.png[/img]{是不是兽人干的不难分辨：看起来是很不是精准？如果是的话那就不是兽人干的。你看到的是一堆尸体和残肢断臂，敌我都有。仅将这些部件拼接在一块就要花费一周的时间。如果你继续走，你很定很快会撞见一群兽人了。| 你发现一具被切成两半的尸体。另一具被拦腰截断的。又一具被拦胸粉碎的无头尸。一具则瘀紫且损伤严重，当你去调查时，发现其中的每块骨头都受挤压位移，彻底破碎。这是兽人的杰作。你很可能是在追踪他们。| 一具尸体被掰向后，头部触碰到脚跟。你发现另一具尸体胸口有一个大洞，而另一具则似乎是被某种锯齿状的粗糙物件开膛刨腹。就没有一具干净的。毫无疑问，这是兽人的杰作。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "看来我们是在追捕兽人。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "DeadBodiesGoblins",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_60.png[/img]{你发现一个靠着路标的人。当你询问他是否见过绿皮怪物时，他却只是前倾倒地。他的背后插有飞镖。那就清楚了。那同样还标明你是在追捕哥布林，而不是兽人。| 兽人不会这么玩。你发现了一大堆农民和他们的犬只惨死。但有点乱。这里有戳伤，那里则是小刺伤。到处散落着些飞镖。尖端沾有毒液。这是……哥布林的杰作。它们一定没走远。| 草地上躺着一具尸体，脖子上插有一只飞镖。面色发紫，舌头外吐。他手臂紧握，仿佛是在抓握自己。毫无疑问是肮脏致人麻痹的毒药所致。而且不是兽人，而是哥布林的杰作。它们肯定就在附近……}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "看来我们是在追捕哥布林。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BattleWonOrcs",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_81.png[/img]{当你的手下把最后一个兽人干掉后，你在周围查看了一下。绿皮怪物在这进行了激烈的战斗。该检查下战团并准备返回你的雇主%employer%那了。| %employer%的人如何也做不了你刚做的。只有%companyname%能够对付这些绿皮怪物。你对战团感到自豪，但不要表现出来。| 战斗结束，就像是他所下的几次赌注。你发现，原来把一个兽人的脑袋砍下来他就不再咬牙切齿了！你的雇主，%employer%，可能不在乎这样残忍的试验，但他绝对会就你今天完成的工作支付你报酬。| 兽人激烈反抗，在圣人看来或许可以称作正义。但他们没有%companyname%强，起码今天没有！| 你的雇主，%employer%，希望你杀了这些绿皮怪物，你也正是这么做的。现在是时候检查下队员然后准备返回去拿你辛苦赢取的报酬了。| 与兽人的战斗从来不是容易的活，这次也是。不过%employer%的报酬，会让%companyname%的辛苦容易承受些。| 你的雇主，%employer%，最好付给你足够的钱——这些家伙可不容易对付！检查队员并准备返回你的雇主那。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "回到%townname%去！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BattleWonGoblins",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_83.png[/img]{就哥布林们这么小的个子来说，它们显然算是很骁勇善战了！你的雇主，%employer%，应该会对你今天完成的工作很满意的。| 你听说人们取笑哥布林的体型。好吧，他们也许块头很小但他们很善于利用自己的优势。\n\n清点下你的手下，准备回去找你的雇主%employer%要你的酬劳。| 这些哥布林战斗得像饥饿的杂种狗。饥饿、狡猾、凶残的杂种狗。不幸的是他们的凶残没用对地方。不过，%employer%会对你的好消息很满意的。| 你不确定这对你的雇主%employer%来说算不算好事，不完全确定是不是还有哥布林。要是他知道的话，他会不会少付你些报酬？显然这些哥布林在你看来很废柴，但他们真的很善战。\n\n 不论如何，是时候清点下你的战团然后返回雇主那了。| 哥布林已死。多讨厌。你的雇主，%employer%，应该会对你今天完成的工作很满意的。| 一堆哥布林尸体，还没兽人狂战士的个子高。不过……他们绝对很善战！太可惜他们的努力浪费在了娇小的身躯中。话说回来，如果他们的智慧和狡猾处在一个兽人的躯壳中的话……我滴神，想想都可怕！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "回到%townname%去！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Warlord",
			Title = "攻击前……",
			Text = "[img]gfx/ui/events/event_49.png[/img]{当你靠近兽人战团时，你确定无疑看到了凶残军阀的轮廓。看来要对付这些绿皮怪物比你原先想的要更困难些。| 兽人群中有一只大军阀。即便如此也不会改变什么。好吧，略微有些改变，但最终目标还是一样的：杀光他们。| 多不幸的消息！你在一群兽人阵列中看到一只兽人军阀。不过，那是对军阀来说的。你确信他达到那级别费劲了心血。遗憾的是%companyname%要毁掉那一切了。| 绿皮怪物中的一个军阀！他的体型和咆哮声都让人不会看错——那响声在巨熊的笑声中依然清晰可闻！无论如何，绿皮怪物应该像剩余的人一样死掉。| 军阀。战争领主。一只可怕的兽人。他们你都听说过。绿皮怪物营地有着这样一只大家伙。他们中的一位领袖。他们最强的战士之一。那又如何？一点也不重要。当然不！一点点也没有。一切都将按计划进行。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Shaman",
			Title = "攻击前……",
			Text = "[img]gfx/ui/events/event_48.png[/img]{随着靠近，你看到一团奇怪的烟冒上来。那不是灰色，而是紫色，带有似乎活物的触须滑动缠绕。哥布林在这，而且他们之中还有一个萨满！| 萨满！走到哪你都能认出这种狡猾的哥布林——那骨质珠宝，那斜眼，那种在哥布林呆滞的脸上所找不到的智慧感。这些绿皮怪物很危险，注意！哦，注意脚下。敌人阵列中站着一只哥布林萨满！这是最危险的敌人！可别小瞧了他的小个子……| 你听说这些萨满的故事，他们能从人的耳朵里汲取梦境。你不确信那是不是真的，但你知道他们是很狡猾的战士，而你即将面对他们！| 一只地精萨满……到哪你都能认出那嶙峋的骨架，还有那伪装的斗篷！保持冷静继续——杀光这些绿皮怪物！| 萨满。一只地精萨满……你听说过他们“魔法”的恐怖故事，但不会出现在此时此地。准备集结进攻！| 一只地精萨满。你听说过这些肮脏的生物能够蛊惑人们的思想。你现在在想你的雇主%employer%，是不是被蛊惑着将你引到此处。\n\n……算了。显然不是，对吧？| 一只地精萨满！你听说过这些邪恶生物的故事。有一个说他们会把黄蜂塞进囚犯的耳朵里！有个人再几杯酒下肚后，告诉你他看过蜜蜂让人的脑袋变成蜂巢！打赌那蜂蜜让他的舌头更灵活了！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Merchant",
			Title = "战斗之后……",
			Text = "{战斗结束，你发现战争废墟中有个令人惊讶的俘虏：一个商人。他穿着浸染血渍的丝绸，满怀感激地向你靠近。他询问你是否能带他到%objective%。很显然，他在路上不安全。你耸耸肩看向了另一边。这个人很快加码，提议只要你能帮他他愿意付%reward_merchant%钱。那让你很喜欢……| 一个人从一堆死去的绿皮怪物里冒出来。他不是你的佣兵，而是一个手被绑在背后的商人。你询问他是怎么落入这些人手里，他耸耸肩，声称他很少见绿皮怪物囚禁犯人。他真走运。\n\n 这个人环顾四周然后开口道。%SPEECH_ON%我必须要感谢你，佣兵，但我必须得说继续走在这些道上让我感到很不安全。如果你们能将我安全送回%objective%，我愿付给你们%reward_merchant%克朗。你觉得可以吗？%SPEECH_OFF% | 战斗后，你发现一个商人旁边的死马上坐着一个商人。他的马被杀了，现在商人很不走运。他看着战场，然后重新看向你。他将手交叉在马鞍的圆头上，高声询问。%SPEECH_ON%战士长官，能否请您护送我到%objective%？如你所见，我这样走相当危险，战斗失利……那不是你们的错！没有，长官！然而，我真的必须要到达那座城镇。%SPEECH_OFF%他顿了顿在你面前晃了晃一个小袋子。%SPEECH_ON%这里有%reward_merchant%克朗给你。那样如何？%SPEECH_OFF% | 在你调查战场时，一个人朝你走来然后询问这发生了什么。你擦干剑上的血迹，叫他好好看看。他的视线里放松了些，不知出于何种原因，垫在脚尖向前倾。%SPEECH_ON%啊，绿皮怪物。真是可耻。好吧……%SPEECH_OFF%他重新站定。%SPEECH_ON%请稍等一会儿。绿皮怪物？他们在这里做什么？我的天呐，这些地方我怎么可能安全！士兵！如果你把我护送到%objective%，我会付你%reward_merchant%克朗。我向你保证离这不远，但我自己一个人去不了。%SPEECH_OFF%他往自己脑袋上比一个拇指然后指向死掉的绿皮怪物。%SPEECH_ON%没人能付得起那价钱，明白吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那好吧，我们带你去%objective%。",
					function getResult()
					{
						this.Contract.setState("Running_Merchant");
						return 0;
					}

				},
				{
					Text = "走吧，别挡我们的路。",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				if (this.Flags.get("IsOrcs"))
				{
					this.Text = "[img]gfx/ui/events/event_81.png[/img]" + this.Text;
				}
				else
				{
					this.Text = "[img]gfx/ui/events/event_22.png[/img]" + this.Text;
				}

				local merchant = this.Tactical.getEntityByID(this.Flags.get("MerchantID"));
				this.Characters.push(merchant.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你回到%employer%那把绿皮怪物的脑袋丢到了他桌子上。他赶紧溜开说道。%SPEECH_ON%什么情况？%SPEECH_OFF%你朝它点头，然后解释道那东西已经死了。他从口袋里抽出一张手帕然后开始擦拭血渍。%SPEECH_ON%是的，我看的出来。那些破事本该被留在这儿，而不是被带到我这来！该死的佣兵……你的报酬在那个角落。走的时候跟我的仆人打个招呼。得有人清理掉这些！%SPEECH_OFF% | 等你返回时，%employer%在享用一个女人。当你进入时她意味深长地笑着看你。他看到这些然后很快将她赶走，以免你这位真男人让她晕过去了。%SPEECH_ON%佣兵！有什么消息？%SPEECH_OFF%你从一个粗麻袋中拿出一颗绿皮怪物的脑袋。%employer%看着它，咬住嘴唇，又微笑又皱眉地，似乎想要对所看到的做些什么。%SPEECH_ON%对了……对了。对了，你的报酬在这，跟承诺的一样。%SPEECH_OFF%他留了个木箱子在桌上。%SPEECH_ON%等你走的时候把那姑娘带回来这里。%SPEECH_OFF% | 你把绿皮怪物的脑袋放到%employer%桌上。他挺直身子展开一幅卷轴，将其与桌上真的这个相比较。%SPEECH_ON%嗯，我得告诉学者们他们有些……出错了。%SPEECH_OFF%你询问哪里错了。%SPEECH_ON%他们把它们吐成灰色的了。这个显然是绿色的。%SPEECH_OFF%你高声问学者的笔还能是绿色的。男人咬着嘴唇点头说。%SPEECH_ON%对哦。有道理。门外的护卫会支付你报酬的。我来吧……标本。%SPEECH_OFF% | 你进门时%employer%旁边站着一个穿长袍的人。他的脸埋在卷轴中，甚至连瞥都没瞥你的到来。你耸耸肩，将绿皮怪物的脑袋从袋子里拿出来然后摆在%employer%的桌子上。现在引起了那个陌生人的注意，他还拿走了脑袋！他夺过脑袋立即冲出了房间，近乎发出令人眩晕的咆哮。你询问着是什么情况。%employer%笑了。%SPEECH_ON%学者对于你能不能回来一直很焦虑。他们已经等新的研究对象等好久了。%SPEECH_OFF%男人拿出一个挎包然后递给你。你数着钱询问那些书呆子是不是也会付你报酬。%employer%耸耸肩。%SPEECH_ON%如果你能抓到他们的话。而且我不是说身体上的抓到他们——那些人陷入思绪太深以至于他们觉得我们剩下的人都不存在！%SPEECH_OFF% | %employer%一手拿着一块石头另一只手上则有一只鸟。你问他在做什么。%SPEECH_ON%我在试图搞清楚哪个更值钱。手中的鸟，或者是……石头……等等……%SPEECH_OFF%你没工夫理会这些然后把绿皮怪物的脑袋摔在他桌上，询问这值多少钱。男人放走了鸟并把石头放在了书架上。他拿着该付你的报酬转过身来。%SPEECH_ON%我会出这么多钱……好奇心，我的问题终于得到解决了。你的报酬，跟承诺的一样。%SPEECH_OFF%你真的很好奇那个人是怎么抓住那只鸟的，但最终决定不再纠结。| %employer%在你回来时咳嗽发作。他看着你，手握拳头放在嘴前。%SPEECH_ON%确信你的到来是不是什么凶兆？%SPEECH_OFF%你耸耸肩然后把绿皮怪物脑袋放在他的桌上，解释道这些都被解决了。%employer%看着它。%SPEECH_ON%所以我的病是由其他原因造成的……但会是什么呢？{女人？很可能是女人。我们就实话说吧，红颜总是祸水。| 狗。人们说那些肮脏的杂种狗是疯狂的先兆。| 黑猫！是啊，当然了！我要杀光它们！| 孩子们。孩子们最近很吵。他们叽叽喳喳吵个不停是为了什么？| 或许是我之前吃的没熟透的肉……或者……不，我很确信是那个住在山上的疯女人。| 我确实在不知情的情况下吃了老鼠食用过的面包。要么是那个，要么是女人。你知道情况是什么样的，总是让我们染病，腐蚀我们，那些该死的娘们！}%SPEECH_OFF%男人要这嘴混，然后摇了摇头。%SPEECH_ON%啊，无所谓了。你的报酬在门外守卫那。跟承诺的数量一样，不过你还是数数保险。神知道我现在可能会数错！%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一次成功的狩猎。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Took care of marauding greenskins");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isGreenskinInvasion())
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
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Origin, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "%objective%…",
			Text = "[img]gfx/ui/events/event_20.png[/img]{安全抵达%objective%，商人转身向你致谢。他递给你一袋钱，跟承诺的一样， 然后快速进城去了。| %objective%是人们喜闻乐见的，对于商人来说也是——你护送的人大喊着，不知是因为还活着而狂喜还是因为因为赚了钱或者是无论其他什么的。他跑到附近的旅馆然后很快返回，手上拿着一袋钱。%SPEECH_ON%跟承诺的一样，给你，佣兵。我欠你那么多。%SPEECH_OFF%你狡黠地问男人会付多少钱。他笑了。%SPEECH_ON%我可不敢拿自己脑袋给自己脑袋标价格，因为我确信会有人要收的！%SPEECH_OFF%你点点头表示理解，对报酬相当满意。| 成功到达%objective%，商人支付给你原先承诺的报酬。然后他很快跑走了，然后想着要如何赚多少多少钱然后睡多少多少女人。| 你成功将商人送到了%objective%。他想你表示感谢然后急匆匆跑到了附近的一个酒馆。回来时他拿着一袋柚子般大的钱。他把它交给你。%SPEECH_ON%这是你的报酬，佣兵。我给你最由衷的感谢，当然了，还有这些钱。现在告辞了……%SPEECH_OFF%他整了整衬衫、裤子然后抬起下巴。%SPEECH_ON%……我要去挣钱了。%SPEECH_OFF%他转身离去了，脚步下散落着一些硬币。}",
			Image = "",
			List = [],
			Characters = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "这钱赚的真容易。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Flags.get("MerchantReward"));
						return 0;
					}

				}
			],
			function start()
			{
				local merchant = this.Tactical.getEntityByID(this.Flags.get("MerchantID"));
				this.Characters.push(merchant.getImagePath());
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Flags.get("MerchantReward") + "[/color] 克朗"
				});
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"objective",
			this.m.Objective != null ? this.m.Objective.getName() : ""
		]);
		_vars.push([
			"objectivedirection",
			this.m.Objective == null || this.m.Objective.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Objective.getTile())]
		]);
		_vars.push([
			"reward_merchant",
			this.m.Flags.get("MerchantReward")
		]);
	}

	function onOriginSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Origin.addSituation(this.new("scripts/entity/world/settlements/situations/greenskins_situation"));
		}
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

			if (this.m.Objective != null && !this.m.Objective.isNull())
			{
				this.m.Objective.getSprite("selection").Visible = false;
			}

			this.m.Origin.getSprite("selection").Visible = false;
			this.m.Home.getSprite("selection").Visible = false;
		}

		if (this.m.Origin != null && !this.m.Origin.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Origin.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(4);
			}
		}
	}

	function onIsValid()
	{
		if (this.m.Origin.getOwner().getID() != this.m.Faction)
		{
			return false;
		}

		return true;
	}

	function onIsTileUsed( _tile )
	{
		if (this.m.Objective != null && !this.m.Objective.isNull() && _tile.ID == this.m.Objective.getTile().ID)
		{
			return true;
		}

		return false;
	}

	function onSerialize( _out )
	{
		if (this.m.Target != null && !this.m.Target.isNull() && this.m.Target.isAlive())
		{
			_out.writeU32(this.m.Target.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		if (this.m.Objective != null && !this.m.Objective.isNull() && this.m.Objective.isAlive())
		{
			_out.writeU32(this.m.Objective.getID());
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

		local objective = _in.readU32();

		if (objective != 0)
		{
			this.m.Objective = this.WeakTableRef(this.World.getEntityByID(objective));
		}

		this.contract.onDeserialize(_in);
	}

});

