this.hunting_schrats_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		Dude = null,
		IsPlayerAttacking = false
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.hunting_schrats";
		this.m.Name = "鬼魅森林";
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

		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"追捕在 " + this.Contract.m.Home.getName()+"的树林里杀人的人"
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
					this.Flags.set("IsDirewolves", true);
				}
				else if (r <= 25)
				{
					this.Flags.set("IsGlade", true);
				}
				else if (r <= 30)
				{
					this.Flags.set("IsWoodcutter", true);
				}

				this.Flags.set("StartTime", this.Time.getVirtualTimeF());
				local disallowedTerrain = [];

				for( local i = 0; i < this.Const.World.TerrainType.COUNT; i = i )
				{
					if (i == this.Const.World.TerrainType.Forest || i == this.Const.World.TerrainType.LeaveForest || i == this.Const.World.TerrainType.AutumnForest)
					{
					}
					else
					{
						disallowedTerrain.push(i);
					}

					i = ++i;
				}

				local playerTile = this.World.State.getPlayer().getTile();
				local mapSize = this.World.getMapSize();
				local x = this.Math.max(3, playerTile.SquareCoords.X - 11);
				local x_max = this.Math.min(mapSize.X - 3, playerTile.SquareCoords.X + 11);
				local y = this.Math.max(3, playerTile.SquareCoords.Y - 11);
				local y_max = this.Math.min(mapSize.Y - 3, playerTile.SquareCoords.Y + 11);
				local numWoods = 0;

				while (x <= x_max)
				{
					while (y <= y_max)
					{
						local tile = this.World.getTileSquare(x, y);

						if (tile.Type == this.Const.World.TerrainType.Forest || tile.Type == this.Const.World.TerrainType.LeaveForest || tile.Type == this.Const.World.TerrainType.AutumnForest)
						{
							numWoods = ++numWoods;
							numWoods = numWoods;
						}

						y = ++y;
						y = y;
					}

					x = ++x;
					x = x;
				}

				local tile = this.Contract.getTileToSpawnLocation(playerTile, numWoods >= 12 ? 6 : 3, 11, disallowedTerrain);
				local party;
				party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Schrats", false, this.Const.World.Spawn.Schrats, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.setDescription("A creature of bark and wood, blending between trees and shambling slowly, its roots digging through the soil.");
				party.setAttackableByAI(false);
				party.setFootprintSizeOverride(0.75);

				for( local i = 0; i < 2; i = i )
				{
					local nearTile = this.Contract.getTileToSpawnLocation(playerTile, 4, 7, disallowedTerrain);

					if (nearTile != null)
					{
						this.Contract.addFootPrintsFromTo(nearTile, party.getTile(), this.Const.BeastFootprints, 0.75);
					}

					i = ++i;
				}

				this.Contract.m.Target = this.WeakTableRef(party);
				party.getSprite("banner").setBrush("banner_beasts_01");
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local roam = this.new("scripts/ai/world/orders/roam_order");
				roam.setPivot(this.Contract.m.Home);
				roam.setMinRange(5);
				roam.setMaxRange(10);
				roam.setNoTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Forest, true);
				roam.setTerrain(this.Const.World.TerrainType.SnowyForest, true);
				roam.setTerrain(this.Const.World.TerrainType.LeaveForest, true);
				roam.setTerrain(this.Const.World.TerrainType.AutumnForest, true);
				c.addOrder(roam);
				this.Contract.m.Home.setLastSpawnTimeToNow();
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
			}

			function update()
			{
				if (this.Contract.m.Target == null || this.Contract.m.Target.isNull() || !this.Contract.m.Target.isAlive())
				{
					this.Contract.setScreen("Victory");
					this.World.Contracts.showActiveContract();
					this.Contract.setState("Return");
				}
				else if (!this.Flags.get("IsBanterShown") && this.Contract.m.Target.isHiddenToPlayer() && this.Math.rand(1, 1000) <= 1 && this.Flags.get("StartTime") + 10.0 <= this.Time.getVirtualTimeF())
				{
					local tileType = this.World.State.getPlayer().getTile().Type;

					if (tileType == this.Const.World.TerrainType.Forest || tileType == this.Const.World.TerrainType.LeaveForest || tileType == this.Const.World.TerrainType.AutumnForest)
					{
						this.Flags.set("IsBanterShown", true);
						this.Contract.setScreen("Banter");
						this.World.Contracts.showActiveContract();
					}
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (!this.Flags.get("IsEncounterShown"))
				{
					this.Flags.set("IsEncounterShown", true);

					if (this.Flags.get("IsDirewolves"))
					{
						this.Contract.setScreen("Direwolves");
					}
					else
					{
						this.Contract.setScreen("Encounter");
					}

					this.World.Contracts.showActiveContract();
				}
				else
				{
					this.World.Contracts.showCombatDialog(_isPlayerAttacking);
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
					this.Contract.setScreen("Success");
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
			//Text = "[img]gfx/ui/events/event_62.png[/img]{You find a town board littered with notes written in cheap scrap or even on leaves and held there with the most rusted of nails. %employer% sidles up to you.%SPEECH_ON%We\'ve been waiting for a man of your sort, sellsword. Folks keep going missing in the woods and I\'ve no recourse in getting them back. I\'ve heard tales of trees on the move and killing the lumberjacks hacking at their trunks, but who knows if any of that\'s true. I need your company to head into the woods and find out what\'s causing all this carnage. Are you interested?%SPEECH_OFF% | %employer% is rolling a piece of bark between his fingers like a gambler\'s coin. He sighs and throws it across his table.%SPEECH_ON%I\'ve been receiving stories about lumberjacks and peddlers going missing in the woods. Some say the trees are coming alive to have their revenge, but that sounds like hogwash to me. Either way, a sum of coin has been readied to help \'solve\' this issue and I\'m willing to dispense it. What say you, sellsword, are you interested in finding whatever monsters are hounding this town?%SPEECH_OFF% | There\'s a pile of sawdust on %employer%\'s desk and his eyes are intently staring into the mound. He waves you in without breaking his glare, and speaks all the same.%SPEECH_ON%The local lumberjacks are reporting that men are going missing in the woods. They say the trees are up to it, something about monsters made of wood and roots. Parts of me believe they\'re hiding a murder and won\'t fess to the crime, but then maybe the spooky stories are true. Either way, I\'ve coin to see it to an end and you\'re just the man the task, yeah?%SPEECH_OFF% | Entering %employer%\'s room, your foot clips a slat of chopped wood. It tumbles over and falls flat edged, the round trunk and its bark now up at you. The mayor claps his hands.%SPEECH_ON%So it didn\'t move! Ah, you\'re probably wondering what I\'m on about. Here.%SPEECH_OFF%He throws you a drawing of what looks like a tree with arms. He goes on.%SPEECH_ON%I\'ve word from the roads that the trees are coming alive. Even have a trusted friend who works as a lumberjack said, straight faced, that some spiritual beast in the trees had taken the wood and roots and wielded them as weapons. Whatever is out there, I need a set of killers to seek it out. Are you and your company up for the task?%SPEECH_OFF% | %employer% is found sitting on a trunk of a tree while surrounded by peasants. After a few minutes he throws his hands out.%SPEECH_ON%See! Ain\'t nothing wrong! It\'s a tree! A tree, see?%SPEECH_OFF%The peasants are not convinced and go on about monsters in the forest shaped like the woods themselves. Sighing, %employer% throws his hand out to you.%SPEECH_ON%Fine, we\'ll hire some mercenaries? Does that suit everyone? What say you, sellsword. We\'ve coin to pay and murderous trees for you to hunt. Sound good?%SPEECH_OFF%}",
			Text = "[img]gfx/ui/events/event_62.png[/img]{你发现城市的公告板上到处都是用廉价的废料甚至树叶写的便条，上面的钉子锈迹斑斑。%employer%悄悄走近你。%SPEECH_ON%我们一直在等一个像你这样的人，佣兵。人们老是在树林里失踪，我没有办法把他们找回来。我听说过树木在移动中杀死砍树的伐木工的故事，但谁知道这些是不是真的。我需要你的同伴到树林里去找出是什么造成了这场大屠杀。你感兴趣吗?%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{当然感兴趣. | 我们谈谈报酬吧. | 让我们谈谈价格吧. | 这值得你为此付出. | 那么，在森林里疯狂地追逐？数数克朗吧. | 如果价格合适我们 %companyname% 会帮助你的.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这听起来不像是好工作. | 我不会带领人们在森林里追逐野兽. | 我不这么认为. | 我说不，男人们更喜欢血肉之敌.}",
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
			Title = "路上...",
			Text = "[img]gfx/ui/events/event_25.png[/img]{在森林里猎杀杀人树木的战队越来越紧张。每一根树枝的裂缝都有拔剑的人，当一片落叶落进衬衫的后襟时，其中一人尖叫起来。你的敌人已经不用做任何事情就能得分了。}",
//			| The forest is making the men uneasy. You tell them to shape up for the enemy is out there one way or another, and it is not worth being fearful of that which is certain. It is you who shall be feared, the %companyname%, and these damned murderous trees will be wishing you were simple lumberjacks by the time you\'re done with them! | %randombrother% heaves his weapon over his shoulders and totters on with his arms swinging around dramatically. He\'s sizing up the forest foliage.%SPEECH_ON%Hey cap\', what you say we smash up one of these trees here and call it a day! Pitch \'em a pile of chopped wood and mulch and ain\'t no one gonna know the difference when it\'s all said and told. If they ask questions just tell \'em the bark had some bite!%SPEECH_OFF%The men laugh and you tell the sellsword you\'ll take his idea into consideration.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "注意你的脚下.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Encounter",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_107.png[/img]{当站在周围看了看地面时，%randombrother%喊远处有什么东西在动。当你走到他身边时，他把手指伸进树叶里，拔出了剑。一棵大树正朝你走来，像一位老人在图书馆熟悉的走廊里那样左右摇晃着。你拔出自己的剑，命令士兵们排成队形 | %randombrother% 正坐在一棵倒下来的树上，突然跳了起来，大叫着抓住了他的武器。你往下看，看到那棵树自己升到了空中，一簇簇的泥土如雨一样下落，留下一条又大又湿的沟壑，仿佛它已经在那里扎根了好多年。它靠在健康的同胞身上，就像醉汉靠在朋友的肩膀上一样。它慢慢地扭动着身子，一双绿色的眼睛从树干深处向外一闪，它那锋利的枝条也随着它转动着，伸展开来，它们的影子像一张网一样落在这群人身上。你拿起剑命令士兵们排成队形.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "冲锋!",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Direwolves",
			Title = "当你靠近...",
			Text = "[img]gfx/ui/events/event_118.png[/img]{你看到一对绿色的眼睛在远处闪闪发光。毫无疑问看到了那些蠢货，所以你命令你的人悄悄地向他们爬去。登上山顶，你发现一棵树的树干被冰原狼包围着。他们蹲在树下，像骑士宣誓效忠。你的到来并不是没有被注意到，因为树人向前倾着身子，发出了一声看似古老的低吟。树根上的生物咆哮着，转身好像在发号施令。您不知道如何理解这种树状的忠诚，但是 %companyname% 会打败它们.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "冲锋!",
					function getResult()
					{
						this.Contract.addUnitsToEntity(this.Contract.m.Target, this.Const.World.Spawn.Direwolves, 70 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Victory",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_121.png[/img]{这些树人被杀死了，它们的残骸现在看起来就像普通的树木. 你为向报告%employer%在收集证据 . | 你盯着一棵被砍倒的树人，然后又盯着一棵被砍倒的树。在这两者之间，你几乎看不出有什么不同，这让你思考那些你这辈子从没想过的问题树人和树的区别。没有人去细想这样的事情，你命令公司拿树枝作为战斗的证据，并准备返回 %employer%. | 这些树人被砍倒了，每一个都搭在其他的树叶上，就像在中场间休息的斗殴者。你走到一棵树的树根下，仔细地看了看，但现在它看起来和周围的其他树没什么不同。你命令公司拿走他们能拿的战利品向 %employer% 报告.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "就这么定了.",
					function getResult()
					{
						if (this.Flags.get("IsGlade") && this.World.Assets.getStash().hasEmptySlot())
						{
							return "Glade";
						}
						else if (this.Flags.get("IsWoodcutter") && this.World.Assets.getStash().hasEmptySlot())
						{
							return "DeadWoodcutter";
						}
						else
						{
							return 0;
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Glade",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_121.png[/img]{当你离开战场时，%randombrother%说周围的树木看起来相当成熟。你转过身来，就发现他说的确实是对的:一大片美丽的树木成了这些蠢人的主人，想必是有充分的理由选择它们的。如果树人把它当作一个好的家，那么它肯定意味着木头很好。你命令这些人利用这片空地，在时间和精力允许的情况下砍倒尽可能多的树。收获的木材确实很好。当你离开临时的伐木场时，天开始下雨了.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "返回 %townname%!",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				local item = this.new("scripts/items/trade/quality_wood_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + item.getName()
				});
				item = this.new("scripts/items/trade/quality_wood_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "DeadWoodcutter",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_121.png[/img]{就在你要离开的时候，一道闪光映入了你的眼帘。你转过身来，来到一只树人的树干前。斧头嵌在木头里。青苔早已长满了刀柄，然而金属没有一点瑕疵，一点锈也没有。刮去苔藓，你发现树人的指尖仍然紧紧地握着。手腕在树干处变成了一根木脉。你沿着这条路走到一张木头脸，上面有一个扭曲的鼻子，就像一张被时间独自融化的褐色蜡脸。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "返回 %townname%!",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				local item;
				local r = this.Math.rand(1, 4);

				if (r == 1)
				{
					item = this.new("scripts/items/weapons/woodcutters_axe");
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/weapons/hand_axe");
				}
				else if (r == 3)
				{
					item = this.new("scripts/items/weapons/fighting_axe");
				}
				else if (r == 4)
				{
					item = this.new("scripts/items/weapons/greataxe");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Success",
			Title = "On your return...",
			//Text = "[img]gfx/ui/events/event_62.png[/img]{You find %employer% carving a toy out of wood. He blows the shavings off his desk and claps the sawdust from his fingers. He sets the toy up on its legs, shaped like a knight that\'s eaten too many sweets, but it promptly falls over. Sighing, he turns to you for help. You pull the schrat\'s head into the room and let it rock back and forth on the floor til it rests upon one of its horns. The mayor nods.%SPEECH_ON%Quite good, sellsword.%SPEECH_OFF%He fetches your promised reward. | %employer% is shocked at your return, and shocked at the schrat\'s remains which you have brought upon his doorstep. He looks down at it, ever incredulous as to its source. Like a cat pawing at a bug\'s shorn wings he rummages the pile with his foot.%SPEECH_ON%I\'d no imagination of you bringing these back, but damned if you didn\'t find and kill those bastard trees. Well, I\'ll fetch your reward.%SPEECH_OFF%He brings you the contracted coin as promised. | %employer% is running a carver down the arm of a wooden chair when you find him. He looks up at your arrival and you present the remains of a schrat. The man gets up and takes a piece, coming to sit in his chair to get a good look at it, but his chair blows apart beneath his arse and claps the boards against the ground with a tremendous clatter as if his original designs all along were to export a great cacophony. %employer% throws his tools in a fit.%SPEECH_ON%By the gods I\'ll, well, I\'d best not make myself a savage and threaten them. Suppose doing that got me to this state in the first place.%SPEECH_OFF%You nod, stating it\'s unwise to anger the old gods. You also suggest that it is unwise to let a sellsword go unpaid for his work. The mayor jumps to his feet and runs to get a satchel of coin.%SPEECH_ON%Of course, mercenary! You need not lecture me on such matters!%SPEECH_OFF% | %employer% is found beneath a copse of trees. He\'s got his hands over his belly and he\'s staring at the sky. A smile crosses his face and he points up at a cloud as though someone should be beside him to witness, but he\'s all by himself and says nothing. You throw a chunk of schrat at his feet and ask if he has your payment. He turns over a satchel that had heretofore gone unseen.%SPEECH_ON% A couple of lumberjacks saw you in battle with them and told me the tale, already. I\'d not thought the schrats entirely real. Deadly trees seem like a superstition for children, but I suppose I\'ve things to learn yet. Good work, sellsword.%SPEECH_OFF%}",
			Text = "[img]gfx/ui/events/event_62.png[/img]{%SPEECH_ON%几个伐木工人看见你和它们在战斗，就已经告诉我了。我不认为那些笨蛋完全是真的。致命的树木对孩子们来说似乎是迷信，但我想我还需要学习一些东西。做的好,佣兵。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一次成功的狩猎.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Rid the town of living trees");
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
			"direction",
			this.m.Target == null || this.m.Target.isNull() ? "" : this.Const.Strings.Direction8[this.m.Home.getTile().getDirection8To(this.m.Target.getTile())]
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/disappearing_villagers_situation"));
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

