this.hunting_webknechts_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		Dude = null,
		IsPlayerAttacking = false
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.hunting_webknechts";
		this.m.Name = "狩猎蜘蛛";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 450 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

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
					"狩猎 " + this.Contract.m.Home.getName()+"的蜘蛛"
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

				if (r <= 10)
				{
					if (this.Contract.getDifficultyMult() >= 0.9)
					{
						this.Flags.set("IsOldArmor", true);
					}
				}
				else if (r <= 20)
				{
					this.Flags.set("IsSurvivor", true);
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
				local x = this.Math.max(3, playerTile.SquareCoords.X - 9);
				local x_max = this.Math.min(mapSize.X - 3, playerTile.SquareCoords.X + 9);
				local y = this.Math.max(3, playerTile.SquareCoords.Y - 9);
				local y_max = this.Math.min(mapSize.Y - 3, playerTile.SquareCoords.Y + 9);
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

				local tile = this.Contract.getTileToSpawnLocation(playerTile, numWoods >= 12 ? 6 : 3, 9, disallowedTerrain);
				local party;
				party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Webknechts", false, this.Const.World.Spawn.Spiders, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.setDescription("A swarm of webknechts skittering about.");
				party.setAttackableByAI(false);
				party.setFootprintSizeOverride(0.75);

				for( local i = 0; i < 2; i = i )
				{
					local nearTile = this.Contract.getTileToSpawnLocation(playerTile, 4, 5);

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
				c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				local roam = this.new("scripts/ai/world/orders/roam_order");
				roam.setNoTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Forest, true);
				roam.setTerrain(this.Const.World.TerrainType.LeaveForest, true);
				roam.setTerrain(this.Const.World.TerrainType.AutumnForest, true);
				roam.setMinRange(1);
				roam.setMaxRange(1);
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
					if (this.Flags.get("IsOldArmor") && this.World.Assets.getStash().hasEmptySlot())
					{
						this.Contract.setScreen("OldArmor");
					}
					else if (this.Flags.get("IsSurvivor") && this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.Contract.setScreen("Survivor");
					}
					else
					{
						this.Contract.setScreen("Victory");
					}

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
					this.Contract.setScreen("Encounter");
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
			Text = "[img]gfx/ui/events/event_43.png[/img]{%employer% 把你送到他的房间. 你注意到，有两个武装的人员冷酷地盯着窗户，保持警惕，尽管其中一个家伙显然靠着墙睡着了。你问市长他想要什么？%SPEECH_ON%城里的居民报告说，怪物带走了孩子和狗等。这些报告听起来谈论的很像是蜘蛛。巨型蜘蛛，正如我父亲所说，如果它是真的，那么它们很可能在某些地方筑巢，我需要你找到并摧毁它。你有兴趣吗，剑士?%SPEECH_OFF% | 当你进入%employer%的房间时，你发现那个男人弯腰站在他的窗前，几乎是在秘密地向外张望。他的眼睛又细又长。他拉起窗帘，转头看着你。%SPEECH_ON%巨大的蜘蛛在我的眼皮底下，偷走牲畜、宠物。我不想把我的士兵们带到那些地方，但我在这里已经无计可施了。我需要杀死这些可怕的生物，把它们的巢摧毁。有了适当的奖励，你会感兴趣吗？%SPEECH_OFF% | 你到了%employer%那里，你的影子吓到了那个人。他笔直地坐在书桌前抬起头来。%SPEECH_ON%啊，真是太吓人了。别介意，剑士，尽管你已经够吓人了，但这地方的大蜘蛛更吓人。我有理由相信这些故事，因为我去了一个农庄，看到了巨大的蜘蛛网和被吃掉的牲畜。我需要一个了解绝对暴力的人，我需要一个这样的人来找到怪物的巢穴并终结它们. 你有兴趣吗?%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{你能凑多少克朗? | 让我们谈谈报酬. | 让我们谈谈能得到多少克朗.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这听起来不像是我们的工作.}",
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
			Text = "[img]gfx/ui/events/event_25.png[/img]{你偶然遇见一头死牛，牛的肉被吸到骨头里，但它的皮却没有晒干的痕迹. %randombrother% 蹲下来，用手指在一堆伤口中摸索。他点头.%SPEECH_ON%毫无疑问，这是巨蛛的作品。它们毒死了牛，然后用牛身体喂养自己。一具新鲜的尸体意味着他们就在附近…%SPEECH_OFF% | 你发现一具被网包裹的尸体挂在一棵树上. 你把网剪掉。一个孩子的身体滑了出来，瘫倒在地。他的脸皮紧贴着骨头，苍白的头盖骨，眼珠从眼窝深处探出头来。舌头也同样萎缩，鼻子几乎都没有了.%SPEECH_ON%好吧，我不会自欺欺人。如果这对你们是一种安慰的话，那男孩在这种状态之前就死了。巨蛛的穿刺带着剧毒，没有一个孩子能活得长久.%SPEECH_OFF%那好。是找到这些怪物的时候了. | 你发现一个小伙子躲在一辆翻过来的手推车下面。他拒绝出来，他的小脑袋像贝壳上的珍珠一样向外凝视。你问他在干什么。他疯狂地解释说他在躲避蜘蛛，你应该马上离开.%SPEECH_ON%离开我的手推车，这是我的.%SPEECH_OFF% 你挥舞着剑，告诉他你要找的是蜘蛛。那男孩盯着你看。他点点头.%SPEECH_ON%这是一个该死的坏主意，先生。不，我不知道它们去了哪里。我和一辆货车一起来的。你看到货车了吗?不，我想你不会看到的，因为他们变成蜘蛛的沙拉了，所以在它们看到你和我说话之前赶紧走吧!%SPEECH_OFF%手推车啪的一声关上了。你不介意把它抬起来，尽管你离开时踢了它一脚.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "小心行动.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Encounter",
			Title = "当你靠近...",
			Text = "[img]gfx/ui/events/event_110.png[/img]{蜘蛛的巢穴是一个白色的土坑。在它的边缘有些细丝，一丝微风的吹拂过后能隐约可见. 随着你的同伴向里走去，蛛网开始散开，就好像你走进了冬天，漫天雪花。蛛网中严密的包裹物显现出来：鹿、狗、没有生命迹象的人，都紧紧地绑在白色蛛茧中。一个黑影在岩石后面悠闲地走着，两腿蹲在地上，脸伏在外面，好像那肮脏的克里丁人. 一只手被像一个奶嘴一样从它的下颌骨中吸进和吸出。你来对地方了. | 蜘蛛的巢穴是无声无息的，雇佣军到来的嘈杂声，金属的叮当声在他们的进入地过程中尤为明显.\n\n 你发现一个倒挂在树上的人，他的全身都结了茧，只剩下被细丝拉长的脸。他要求你把他眼皮上的蛛网割开。他的眼皮慢慢合上，干裂的眼皮在几天内第一次合上。但突然他睁开眼，那人尖叫起来。茧在他的腰上冒泡，撕开，一股微小的黑蜘蛛奔涌而出。当蛛群吞噬他时，这个人的身体剧烈地摇晃着，他那咯咯作响的尖叫声充斥着蜘蛛的叫声，蜘蛛的叫声充满了他的肺，他在垂死的时候咳嗽出来。你被吓坏了，你后退一步，只看到一大群大得多的蜘蛛从树周围冒出来！ | 巢穴是一个容易找到的地方，到处是一片寒冷的冬季景观，从每棵树、每片树林、每一寸地方都可以看到白色的斑驳的蛛丝。你和兄弟们进入这里，拔出武器，在那里你遇到了被包裹的尸体，他们的身体被炸开并变黑，一大群蜘蛛在器官上吮吸.\n\n  你抬头一看，周围树木的枝条间闪着红眼，整个蛛形植物园都活了，它的守卫们蹲在灌木丛中，蹲着的腿和枝条一模一样，敌人就躲在眼前。当一棵树完全展开，树枝上挂满了蜘蛛，你刚才还再想如何找到它们，现在看来简直是自寻烦恼!}",
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
			ID = "Victory",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_123.png[/img]{最后一只蜘蛛被处理了，它的腿像是要永远地抓住杀死它的武器。你对雇佣军的好兄弟们点头确认，然后命令把整个地方都烧了。火势迅速蔓延到整个地区，把细丝桥烧裂。整个巢穴在地狱中被吞噬，在它的深处，你听到了蜘蛛的尖叫声. | 你走近最后一只蜘蛛，凝视着它可怕的内脏。它有一副邪恶的下颌骨作为护牙套，嘴本身就是一条缝，缝里布满锋利的牙齿，可以撕碎任何试图逃跑的东西。\n\n 你命令把整个蜘蛛巢都放火烧掉。当火焰升起时，在某个地方传来了蜘蛛的叫声。 | 你准备好了一份给%employer%的报告，但是首先要把整个蜘蛛巢都烧掉。雇佣军战队站在火焰前，听着蜘蛛的尖叫声，有些还嘲笑那些腿上挂着火焰四处飞来飞去的小虫子。 }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "让我们把这件事做完吧，我们还有克朗要拿.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "OldArmor",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_123.png[/img]{根除了蜘蛛的威胁，你就可以让雇佣军们简单地搜索这些生物的巢穴，尽管雇佣军被命令永远不要独自游荡。你也在搜索，%randombrother%在你身边。你发现一棵树没有被网碰过。当你绕圈时，你发现一具骑士的尸体。他的手放在一把断了的剑的把手上，另一只手完全不见了，只剩下手腕上的袖子，残缺不全的手臂蜷缩着。尸体躺在自己做的棺材里，一个像变质的大黄茎和腐烂的甲壳的灌木丛里，破碎的尸体陷在洞穴里，散发着有毒的气味。%randombrother%说了一句话%SPEECH_ON%真丢脸。我敢打赌，无论他是谁，他都是战队历史上的耻辱。%SPEECH_OFF%实际上，这看起来就像是一个伟大的战士的终结。你想埋葬他，但你没有时间。你告诉%randombrother%从尸体中取出他能得到的物品并准备报告给%employer%。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "回到 %townname%!",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				local item;
				local r = this.Math.rand(1, 2);

				if (r == 1)
				{
					item = this.new("scripts/items/armor/decayed_reinforced_mail_hauberk");
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/armor/decayed_coat_of_scales");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了 " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Survivor",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_123.png[/img]{战斗结束后，你会发现一个人被绑在茧里。他一半的身体被纤维束住，更多的像碎布衣服一样从臀部垂下。似乎蜘蛛在%companyname%到来时就离开了他。他看到你非常高兴。%SPEECH_ON%嘿，这里。是不是雇佣兵？是的，我明白了。你需要克朗，所以你来到了这里，救我出来你就能得到克朗.%SPEECH_OFF%你问那个人，如果你砍掉他会得到什么。他抬起头，整个身体开始颤抖。%SPEECH_ON%是的，好问题！好吧，你现在可能看不到克朗，但我是一个卖宝剑的人，你难道不知道我的商店？把我砍倒，你的战队就再也见不到我这么能干的人了。也就是说，你能拥有我.%SPEECH_OFF%你释放了那个人并讨论在返回%employer%之前该怎么做.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "欢迎加入本战队!",
					function getResult()
					{
						this.World.getPlayerRoster().add(this.Contract.m.Dude);
						this.World.getTemporaryRoster().clear();
						this.Contract.m.Dude.onHired();
						this.Contract.m.Dude = null;
						return 0;
					}

				},
				{
					Text = "你得去别处碰碰运气.",
					function getResult()
					{
						this.World.getTemporaryRoster().clear();
						this.Contract.m.Dude = null;
						return 0;
					}

				}
			],
			function start()
			{
				local roster = this.World.getTemporaryRoster();
				this.Contract.m.Dude = roster.create("scripts/entity/tactical/player");
				this.Contract.m.Dude.setStartValuesEx([
					"retired_soldier_background"
				]);

				if (!this.Contract.m.Dude.getSkills().hasSkill("trait.fear_beasts") && !this.Contract.m.Dude.getSkills().hasSkill("trait.hate_beasts"))
				{
					this.Contract.m.Dude.getSkills().add(this.new("scripts/skills/traits/fear_beasts_trait"));
				}

				this.Contract.m.Dude.getBackground().m.RawDescription = "你发现%name%被挂在树上，他是一个雇佣队派来杀死蜘蛛的最后一个幸存者。你救了他之后他加入了战队.";
				this.Contract.m.Dude.getBackground().buildDescription(true);
				this.Contract.m.Dude.worsenMood(0.5, "Lost his previous company to webknechts");
				this.Contract.m.Dude.worsenMood(0.5, "Almost consumed alive by webknechts");

				if (this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
				{
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand).removeSelf();
				}

				if (this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
				{
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand).removeSelf();
				}

				if (this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Head) != null)
				{
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Head).setArmor(this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Head).getArmor() * 0.33);
				}

				if (this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Body) != null)
				{
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Body).setArmor(this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Body).getArmor() * 0.33);
				}

				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Success",
			Title = "当你回来...",
			Text = "[img]gfx/ui/events/event_85.png[/img]{%employer% 在镇子门口遇见你，他旁边有一群人. 他热情地欢迎你，说他有一个侦察兵跟着你，他看到了整个战斗的展开。在他把你的奖赏交给你之后，镇上的居民一个接一个地走了出来，他们中的许多人都不愿直视你的眼睛，但他们提供了一些礼物，以感谢你们解除了蜘蛛的恐怖威胁。 | %employer% 欢迎你回来，用他热烈的掌声，就好像你刚带来了一只火鸡，而不是你胜利的证据。在付给你约定的报酬之后，你听到了一些令人惊讶的消息。市长说，一个失散的城镇居民的财产不能适当地处理，而且，作为进一步的感谢，你可以自由地拿走剩下的。}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Rid the town of webknechts");
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
				local food;
				local r = this.Math.rand(1, 3);

				if (r == 1)
				{
					food = this.new("scripts/items/supplies/cured_venison_item");
				}
				else if (r == 2)
				{
					food = this.new("scripts/items/supplies/pickled_mushrooms_item");
				}
				else if (r == 3)
				{
					food = this.new("scripts/items/supplies/roots_and_berries_item");
				}

				this.World.Assets.getStash().add(food);
				this.List.push({
					id = 10,
					icon = "ui/items/" + food.getIcon(),
					text = "你获得 " + food.getName()
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

