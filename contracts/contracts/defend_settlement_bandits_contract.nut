this.defend_settlement_bandits_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Reward = 0,
		Kidnapper = null,
		Militia = null
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.defend_settlement_bandits";
		this.m.Name = "Defend settlement";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 5.0;
		this.m.MakeAllSpawnsResetOrdersOnContractEnd = false;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 700 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

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
					"保卫%townname%和它的郊区"
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
				local nearestBandits = this.Contract.getNearestLocationTo(this.Contract.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getSettlements());
				local nearestZombies = this.Contract.getNearestLocationTo(this.Contract.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getSettlements());

				if (nearestZombies.getTile().getDistanceTo(this.Contract.m.Home.getTile()) <= 20 && nearestBandits.getTile().getDistanceTo(this.Contract.m.Home.getTile()) > 20)
				{
					this.Flags.set("IsUndead", true);
				}
				else
				{
					local r = this.Math.rand(1, 100);

					if (r <= 20)
					{
						this.Flags.set("IsKidnapping", true);
					}
					else if (r <= 40)
					{
						if (this.Contract.getDifficultyMult() >= 0.95)
						{
							this.Flags.set("IsMilitia", true);
						}
					}
					else if (r <= 50  ||  this.World.FactionManager.isUndeadScourge() && r <= 70)
					{
						if (nearestZombies.getTile().getDistanceTo(this.Contract.m.Home.getTile()) <= 20)
						{
							this.Flags.set("IsUndead", true);
						}
					}
				}

				local number = 1;

				if (this.Contract.getDifficultyMult() >= 0.95)
				{
					number = number + this.Math.rand(0, 1);
				}

				if (this.Contract.getDifficultyMult() >= 1.1)
				{
					number = number + 1;
				}

				local locations = this.Contract.m.Home.getAttachedLocations();
				local targets = [];

				foreach( l in locations )
				{
					if (l.isActive() && !l.isMilitary() && l.isUsable())
					{
						targets.push(l);
					}
				}

				number = this.Math.min(number, targets.len());
				this.Flags.set("ActiveLocations", targets.len());

				for( local i = 0; i != number; i = i )
				{
					local party;

					if (this.Flags.get("IsUndead"))
					{
						party = this.Contract.spawnEnemyPartyAtBase(this.Const.FactionType.Zombies, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					}
					else
					{
						party = this.Contract.spawnEnemyPartyAtBase(this.Const.FactionType.Bandits, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					}

					party.setAttackableByAI(false);
					local c = party.getController();
					c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
					c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
					local t = this.Math.rand(0, targets.len() - 1);

					if (i > 0)
					{
						local wait = this.new("scripts/ai/world/orders/wait_order");
						wait.setTime(4.0 * i);
						c.addOrder(wait);
					}

					local move = this.new("scripts/ai/world/orders/move_order");
					move.setDestination(targets[t].getTile());
					c.addOrder(move);
					local raid = this.new("scripts/ai/world/orders/raid_order");
					raid.setTime(40.0);
					raid.setTargetTile(targets[t].getTile());
					c.addOrder(raid);
					targets.remove(t);
					i = ++i;
				}

				this.Contract.m.Home.setLastSpawnTimeToNow();
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.Home.getSprite("selection").Visible = true;
				this.World.FactionManager.getFaction(this.Contract.getFaction()).setActive(false);
			}

			function update()
			{
				if (this.Contract.m.UnitsSpawned.len() == 0  ||  this.Flags.get("IsEnemyHereDialogShown"))
				{
					local isEnemyGone = true;

					foreach( id in this.Contract.m.UnitsSpawned )
					{
						local p = this.World.getEntityByID(id);

						if (p != null && p.isAlive() && p.getDistanceTo(this.Contract.m.Home) <= 1200.0)
						{
							isEnemyGone = false;
							break;
						}
					}

					if (isEnemyGone)
					{
						if (this.Flags.get("HadCombat"))
						{
							this.Contract.setScreen("ItsOver");
							this.World.Contracts.showActiveContract();
						}

						this.Contract.setState("Return");
						return;
					}
				}

				if (!this.Flags.get("IsEnemyHereDialogShown"))
				{
					local isEnemyHere = false;

					foreach( id in this.Contract.m.UnitsSpawned )
					{
						local p = this.World.getEntityByID(id);

						if (p != null && p.isAlive() && p.getDistanceTo(this.Contract.m.Home) <= 700.0)
						{
							isEnemyHere = true;
							break;
						}
					}

					if (isEnemyHere)
					{
						this.Flags.set("IsEnemyHereDialogShown", true);

						foreach( id in this.Contract.m.UnitsSpawned )
						{
							local p = this.World.getEntityByID(id);

							if (p != null && p.isAlive())
							{
							}
						}

						if (this.Flags.get("IsUndead"))
						{
							this.Contract.setScreen("UndeadAttack");
						}
						else
						{
							this.Contract.setScreen("DefaultAttack");
						}

						this.World.Contracts.showActiveContract();
					}
				}
				else if (this.Flags.get("IsKidnapping") && !this.Flags.get("IsKidnappingInProgress") && this.Contract.m.UnitsSpawned.len() == 1)
				{
					local p = this.World.getEntityByID(this.Contract.m.UnitsSpawned[0]);

					if (p != null && p.isAlive() && !p.isHiddenToPlayer() && !p.getController().hasOrders())
					{
						local c = p.getController();
						c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(true);
						c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(true);
						this.Contract.m.Kidnapper = this.WeakTableRef(p);
						this.Flags.set("IsKidnappingInProgress", true);
						this.Flags.set("KidnappingTooLate", this.Time.getVirtualTimeF() + 60.0);
						this.Contract.setScreen("Kidnapping1");
						this.World.Contracts.showActiveContract();
						this.Contract.setState("Kidnapping");
					}
				}

				if (this.Flags.get("IsMilitia") && !this.Flags.get("IsMilitiaDialogShown"))
				{
					this.Flags.set("IsMilitiaDialogShown", true);
					this.Contract.setScreen("Militia1");
					this.World.Contracts.showActiveContract();
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.Flags.set("HadCombat", true);
			}

			function onCombatVictory( _combatID )
			{
				this.Flags.set("HadCombat", true);
			}

		});
		this.m.States.push({
			ID = "Kidnapping",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"营救被俘虏的囚犯",
					"返回 " + this.Contract.m.Home.getName()
				];
				this.Contract.m.Home.getSprite("selection").Visible = false;
				this.World.FactionManager.getFaction(this.Contract.getFaction()).setActive(false);

				if (this.Contract.m.Kidnapper != null && !this.Contract.m.Kidnapper.isNull())
				{
					this.Contract.m.Kidnapper.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.m.Kidnapper == null  ||  this.Contract.m.Kidnapper.isNull()  ||  !this.Contract.m.Kidnapper.isAlive())
				{
					if (this.Time.getVirtualTimeF() - this.World.Events.getLastBattleTime() <= 5.0)
					{
						this.Flags.set("IsKidnapping", false);
						this.Contract.setScreen("Kidnapping2");
					}
					else
					{
						this.Contract.setScreen("Kidnapping3");
					}

					this.World.Contracts.showActiveContract();
					this.Contract.setState("Return");
				}
				else if (this.Contract.m.Kidnapper.isHiddenToPlayer() && this.Time.getVirtualTimeF() > this.Flags.get("KidnappingTooLate"))
				{
					this.Contract.setScreen("Kidnapping3");
					this.World.Contracts.showActiveContract();
					this.Contract.setState("Return");
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.Flags.set("HadCombat", true);
			}

			function onCombatVictory( _combatID )
			{
				this.Flags.set("HadCombat", true);
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
				this.World.FactionManager.getFaction(this.Contract.getFaction()).setActive(true);

				if (this.Contract.m.Kidnapper != null && !this.Contract.m.Kidnapper.isNull())
				{
					this.Contract.m.Kidnapper.getSprite("selection").Visible = false;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					local locations = this.Contract.m.Home.getAttachedLocations();
					local numLocations = 0;

					foreach( l in locations )
					{
						if (l.isActive() && !l.isMilitary() && l.isUsable())
						{
							numLocations = ++numLocations;
							numLocations = numLocations;
						}
					}

					if (numLocations == 0  ||  this.Flags.get("ActiveLocations") - numLocations >= 2)
					{
						if (this.Flags.get("IsKidnapping") && this.Flags.get("IsKidnappingInProgress"))
						{
							this.Contract.setScreen("Failure2");
						}
						else
						{
							this.Contract.setScreen("Failure1");
						}
					}
					else if (this.Flags.get("ActiveLocations") - numLocations >= 1)
					{
						if (this.Flags.get("IsKidnapping") && this.Flags.get("IsKidnappingInProgress"))
						{
							this.Contract.setScreen("Success4");
						}
						else
						{
							this.Contract.setScreen("Success2");
						}
					}
					else if (this.Flags.get("IsKidnapping") && this.Flags.get("IsKidnappingInProgress"))
					{
						this.Contract.setScreen("Success3");
					}
					else
					{
						this.Contract.setScreen("Success1");
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
			Text = "[img]gfx/ui/events/event_20.png[/img]{%employer%正看向窗外。他挥手致意你跟他一起。%SPEECH_ON%看看这些人。%SPEECH_OFF%下面有一群人，为各自的悲伤恸哭。%SPEECH_ON%强盗们现在在这些地方游荡，而人们相信他们马上要集结大批人马来攻击我们。%SPEECH_OFF%他拉起窗帘并点上一根蜡烛。他开口了，呼吸中闪烁着火焰。%SPEECH_ON%我们需要你来保护我们，雇佣兵。如果你能阻止这些强盗，你会获得丰厚的报酬。你有兴趣吗？%SPEECH_OFF%  |  几个农民在房间大厅外徘徊。你可以听到他们的呼喊声，那是一种焦虑的语调。%employer%倒了杯酒手臂颤抖着抿了一口。%SPEECH_ON% 我就跟你说白了吧，佣兵。我们说到非常多报告，说强盗要来攻击这座小镇了。如果你想知道，这些报告来自死去的妇女和儿童。显然，这些报告的严重性不言而喻。所以，问题是，你会保护我们吗？%SPEECH_OFF%  |  %employer%正在他的位置上看着一些文件。你坐了下来并询问他想要什么。%SPEECH_ON%你好，佣兵。我们遇到了麻烦，我在想你……会很擅长搞定。%SPEECH_OFF%你让他打开天窗说亮话，而这时他跳了起来。%SPEECH_ON%强盗们烧毁了镇外的房屋和茅舍。新消息称他们准备更大规模、更贪婪地进攻。我需要你来阻止他们。你能完成这项任务吗？%SPEECH_OFF%  |  %employer%正盯着他的书架背对着你。他阴沉地说着。%SPEECH_ON%没多少人能读这些真是太遗憾了。或许如果他们受过更好教育的话我们就能克服现在的麻烦。又或者那只会更糟。%SPEECH_OFF%他摇着头转过身来。%SPEECH_ON%有一群强盗马上要来袭击我们。佣兵，我需要你来阻止他们。我的书显然什么也做不了。如果报酬合适，这点我可以保证，你同意吗？%SPEECH_OFF%  |  %employer%手上拿了两页纸。上面有两张面部素描。%SPEECH_ON%这两个是我们前几天抓的。吊死他们，烧掉尸体。%SPEECH_OFF%你耸了耸肩。%SPEECH_ON%祝贺你？%SPEECH_OFF%男人不是很高兴。%SPEECH_ON%现在我们得到消息他们的强盗朋友要来向我们寻仇了！是的，我们需要你的帮助来击退他们。你有兴趣吗？%SPEECH_OFF%  |  你适应%employer%的房间，就坐，手指划过木框。是上等的橡木。一件值得坐的椅子。%SPEECH_ON%很高兴你感到舒服，佣兵，但我显然不。我们说到非常多警告，说大群强盗要来攻击我们的小镇了。我们的防御很薄弱，但并不差钱。显然，这是你来这的原因，你有兴趣吗？%SPEECH_OFF%  |  %employer%把杯子摔倒墙上。它散开、转动并旋转，葡萄酒点缀在你的脸颊。%SPEECH_ON%流浪汉！强盗！掠夺者！这没有尽头！%SPEECH_OFF%他心不在焉地递给你一张纸巾。%SPEECH_ON%现在我收到消息说大群这些暴徒正在赶来，意欲将我们的城镇夷为平地！好吧，我为他们准备了：你。你意下如何，佣兵？你会保护我们吗？%SPEECH_OFF%  |  %employer%房间外能听到一些悲痛的妇女哭声。他转向你。%SPEECH_ON%听到了吗？那就是强盗来之后会发生的事。他们奸淫偷盗，烧杀抢掠。%SPEECH_OFF%你点了点头。毕竟，这就是盗贼的方式。%SPEECH_ON%现在腹地的几个农民说这帮暴徒正准备大规模突袭我们村庄。你必须要帮帮我们，佣兵。呵呵，当然我会说‘必须’。我的意思是如果你帮我们的话，我们会支付丰厚的报酬的……%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{%townname%准备为他们的安危支付多少呢？ |  这对你们来说可值一大笔钱啊，对吗？}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{恐怕你就要靠自己了。 | 你还有更重要的事情要处理。 | 祝你好运，但跟我们无关。}",
					function getResult()
					{
						if (this.Math.rand(1, 100) <= 60)
						{
							this.World.Contracts.removeContract(this.Contract);
							return 0;
						}
						else
						{
							return "Plea";
						}
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "Plea",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_43.png[/img]{当你拒绝着离开 %employer%，你来到屋外却发现一群农民围站成一圈。每个人都拿着某种奇物，那种外行能找得到的财富：土鸡、便宜的项链、破旧的衣服、锈迹斑驳的铁匠齿轮，以及诸如此类等等等等。手臂下塞着土鸡的人向前一步，%SPEECH_ON%求求你！你不能走！你一定要救救我们！%SPEECH_OFF%%randombrother%笑了笑，但你不得不承认这些可怜的民众知道一些撩拨人的心弦。或许你真的应该留下来救他们？ |  当你离开%employer%来到屋外，却只发现一个妇女跟一个暴民在追逃，在她腿间是一个吸啜乳房的婴儿。%SPEECH_ON%雇佣兵，求求你，你不能这样丢下我们啊！这个镇需要你！这个孩子需要你！%SPEECH_OFF%她停了下来，然后撩下衬衫的另一边，显露出相当淫荡、诱人的诱惑。%SPEECH_ON%我需要你……%SPEECH_OFF%呢举起一只手，既是阻止她也是擦拭你突然汗湿的额头。或许帮帮这一对可怜人也不是那么糟糕？ | 准备离开%townname%，一只小狗跑向你然后吠着舔你的靴子。后面追逐者一个更小的孩子，真的是在追逐它的尾巴。孩子摔倒在杂种狗身上然后用手臂环在尿布的毛上。%SPEECH_ON%哦 {马利  |  阿黄  |  Jo-Jo}，我如此爱你！%SPEECH_OFF%一幅强盗屠杀孩童和他宠物的画面划过你的脑海。比起对付寻常盗贼的警长和治安官你有更重要的事要做，但狗狗只是一直舔着小男孩的脸蛋，而这个小男孩看着又是如此开心。%SPEECH_ON%哈哈！我们会永永远远这样生活下去，不是吗？永永远远！%SPEECH_OFF%该死。 | 在你离开%employer%住所时一个男人走向你。%SPEECH_ON%先生，我听说你拒绝了那个人的提议。我只想说，那太遗憾了。我还以为这世上还是有很多好人的，但似乎是我错了。祝您的旅途顺利，我也希望你在旅途中为我们祈祷。%SPEECH_OFF%",
			Image = "",
			List = [],
			ShowEmployer = false,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{该死，我们不能就这样看着这些人死去。 | 好吧，好吧，我们不会离开%townname%。那么，至少聊聊报酬吧。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{我敢肯定你会渡过难关的。让路。 | 我不会为了某些要饿死的农民拿%companyname%冒险。}",
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
			ID = "UndeadAttack",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_29.png[/img]{ 站岗时，一个疯狂的农民向你跑来。他发呆着，上气不接下气。手臂撑在膝盖上，终于开口：%SPEECH_ON%死人……他们来了！%SPEECH_OFF%你凝视着他，确实看到远处一群相当苍白的生物拖着脚往这边前来。 |  不是强盗，而是不死族！在等待暴徒和恶棍进程时，你却看到一大群步履蹒跚的生物朝你的方向走来。目标变了可不意味着合同也跟着改变—做好准备！ | 城镇教堂中发出警钟声响。你听着钟声望向地平线。钟声继续着。一个当地人站在你身旁。%SPEECH_ON%一下…两下…三下钟声…四下…%SPEECH_OFF%他开始冒汗。然后在最后一次钟声后他瞪大双眼。%SPEECH_ON%那是……那不可能。%SPEECH_OFF%你询问他在怕什么。他退了回去。%SPEECH_ON%死人又出现了！%SPEECH_OFF%好极了，你还以为这合同会简单呢。 | 不死族呻吟着进入视线。这没有强盗—或许这些污秽的生物没写在合同上—但合同上写的是：保护城镇！}",
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
			ID = "DefaultAttack",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_07.png[/img]强盗出现了！准备战斗，保护小镇！",
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
			ID = "ItsOver",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_22.png[/img]{战斗结束了，空闲下来的人们抓紧开始休息。%employer% 正等着你返回小镇。 |  在战斗结束后，你环视着散落在战场四处的尸体。那是一副令人厌恶的景象，但出于某种原因，这种景象却激励了你。这布满死尸的恐怖丘陵只会让你重新振作起来，你还未向这糟糕的世界屈服。%employer%那样的人应该来看看这样的景象，但是他是不会来的，所以得换作你去找他。 |  血肉残肢散布在战场各处，几乎已经无法辨别出那些肢体到底是属于谁的了。黑色的秃鹰在空中盘旋着，徘徊着的阴影覆盖在了死者之上，那些食腐的鸟类正等待着哀悼者的离去。%randombrother%走到你的身边，询问现在是否开始返回%employer%那里。你点了点头，转过了身子，不再去看那片战场。 |  这片废墟堆满了死尸。那些死者还维持着生前的姿态，只不过他们的动作是永久地固定了，他们的生命在那场意外中落下了帷幕。%randombrother%走了过来，问你是否没事。说实话，你自己也不清楚，你现在唯一想做的就是去见%employer%。 |  畸形的人体和扭曲的尸体散布在战场各处，他们根本不清楚自己是如何在战斗中变成了这样的结果。孤零零的脑袋散落在战场之上，在战斗中，无论是人类还是兽人，都不会浪费力气去将别人的脖子完全砍断，因此，这些脑袋只会是被又快又锋利的剑刃斩下的。你心中有一部分想赶快结束这场纷争，但另一部分却希望趁机去解决你的对手。\n\n %randombrother%走了过来，向你询问接下来的命令。你转身向%companyname%下令，准备返回%employer%。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们退回城镇大厅！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ItsOverDidNothing",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_30.png[/img]空气中充满烟雾，烟雾和灼烧木材的苛性气味。%townname%的民众把所有的希望都寄托在雇佣%companyname%上，这是个致命的错误。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "那没有如愿……",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Militia1",
			Title = "在%townname%",
			Text = "[img]gfx/ui/events/event_80.png[/img]{在为防御%townname%做准备之时， 当地民兵来到你身侧。他们服从你的命令，只希望你把他们派去最需要他们的地方。 |  看来当地民兵已经加入了战斗！一群衣衫褴褛的男人，不过他们会派上用场的。现在的问题是，把他们派去哪里呢？ | %townname%民兵已经加入战斗！尽管装备糟糕，他们还是很希望守卫家园和茅舍的。他们服从你的命令，相信你会把他们派到最需要他们的地方。 | 这场战斗中你不是孤军奋战！%townname%民兵已加入。他们渴望战斗并询问哪里最需要他们。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "排好队，你们听从我的指令。",
					function getResult()
					{
						return "Militia2";
					}

				},
				{
					Text = "去守卫%townname%城镇大厅。",
					function getResult()
					{
						local home = this.Contract.m.Home;
						local party = this.World.FactionManager.getFaction(this.Contract.getFaction()).spawnEntity(home.getTile(), home.getName() + " Militia", false, this.Const.World.Spawn.Militia, home.getResources() * 0.7);
						party.getSprite("banner").setBrush(home.getBanner());
						party.setDescription("Brave men defending their homes with their lives. Farmers, craftsmen, artisans - but not one real soldier.");
						this.Contract.m.Militia = this.WeakTableRef(party);
						local c = party.getController();
						local guard = this.new("scripts/ai/world/orders/guard_order");
						guard.setTarget(home.getTile());
						guard.setTime(300.0);
						local despawn = this.new("scripts/ai/world/orders/despawn_order");
						c.addOrder(guard);
						c.addOrder(despawn);
						return 0;
					}

				},
				{
					Text = "去守卫%townname%郊区。",
					function getResult()
					{
						local home = this.Contract.m.Home;
						local party = this.World.FactionManager.getFaction(this.Contract.getFaction()).spawnEntity(home.getTile(), home.getName() + " Militia", false, this.Const.World.Spawn.Militia, home.getResources() * 0.7);
						party.getSprite("banner").setBrush(home.getBanner());
						party.setDescription("Brave men defending their homes with their lives. Farmers, craftsmen, artisans - but not one real soldier.");
						this.Contract.m.Militia = this.WeakTableRef(party);
						local c = party.getController();
						local locations = home.getAttachedLocations();
						local targets = [];

						foreach( l in locations )
						{
							if (l.isActive() && !l.isMilitary() && l.isUsable())
							{
								targets.push(l);
							}
						}

						local guard = this.new("scripts/ai/world/orders/guard_order");
						guard.setTarget(targets[this.Math.rand(0, targets.len() - 1)].getTile());
						guard.setTime(300.0);
						local despawn = this.new("scripts/ai/world/orders/despawn_order");
						c.addOrder(guard);
						c.addOrder(despawn);
						return 0;
					}

				},
				{
					Text = "去找个地方藏起来别挡道。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Militia2",
			Title = "在%townname%",
			Text = "[img]gfx/ui/events/event_80.png[/img]既然你决定了要接收一些当地人，他们询问你该如何武装自己来应对即将到来的战斗。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿上弓，你从后方射箭。",
					function getResult()
					{
						for( local i = 0; i != 4; i = i )
						{
							local militia = this.World.getGuestRoster().create("scripts/entity/tactical/humans/militia_guest_ranged");
							militia.setFaction(1);
							militia.setPlaceInFormation(19 + i);
							militia.assignRandomEquipment();
							i = ++i;
						}

						return 0;
					}

				},
				{
					Text = "拿上剑和盾牌，你去前线作战。",
					function getResult()
					{
						for( local i = 0; i != 4; i = i )
						{
							local militia = this.World.getGuestRoster().create("scripts/entity/tactical/humans/militia_guest");
							militia.setFaction(1);
							militia.setPlaceInFormation(19 + i);
							militia.assignRandomEquipment();
							i = ++i;
						}

						return 0;
					}

				},
				{
					Text = "按你们自己喜欢的方式武装自己。",
					function getResult()
					{
						for( local i = 0; i != 4; i = i )
						{
							local militia;

							if (this.Math.rand(0, 1) == 0)
							{
								militia = this.World.getGuestRoster().create("scripts/entity/tactical/humans/militia_guest");
							}
							else
							{
								militia = this.World.getGuestRoster().create("scripts/entity/tactical/humans/militia_guest_ranged");
							}

							militia.setFaction(1);
							militia.setPlaceInFormation(19 + i);
							militia.assignRandomEquipment();
							i = ++i;
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "MilitiaVolunteer",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_80.png[/img]{战斗结束了，其中一位协助防御的民兵亲自找到你，弯低身子献上他的剑。%SPEECH_ON%先生，我和%townname%的时光到头了。但%companyname%的英勇真的太了不起了。如果您允许，我希望与您和您的士兵并肩作战。%SPEECH_OFF%  |  随着战斗的结束，其中一位%townname%民兵表示愿意加入%companyname%并为之作战。部分原因可能是他对雇佣兵团的作战折服，还一部分可能是应征入伍的小镇防御无论是经济上还是身体上都不太健康。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "欢迎加入%companyname%！",
					function getResult()
					{
						return 0;
					}

				},
				{
					Text = "这不是你能待的地方。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Kidnapping1",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_30.png[/img]{就在你搜索那些强盗时，一位农民跑了过来，告诉你有一群暴徒攻击了附近的居民，而且带走了一群人质。你怀疑地摇了摇头。他们是如何溜进来做这种事情的呢？那个农民也摇了摇头。%SPEECH_ON%我以为你们是来帮助我们的。为什么不做点事情呢？%SPEECH_OFF%你问那些强盗是否走远了。农民摇了摇头。看来你还有机会救回他们。 |  一个衣衫褴褛手拿破旧草叉的人向你的战团飞奔而来。他伏在你的脚边嚎啕大哭。%SPEECH_ON%那些强盗攻击了我们！你跑哪去了？他们杀了那些人…烧了一些…还有…他们挟持走了一些人！求求您，快去救他们吧！%SPEECH_OFF%你看了眼%randombrother%然后点了点头。%SPEECH_ON%让大家都做准备。我们需要在那些暴徒逃走前追上他们。%SPEECH_OFF%  |  你望向远方，寻找了那些流浪汉的踪迹。忽然，%randombrother%走到了你的身边，旁边还带着一个女人。她说暴徒们已经攻击杀害了大量农民而且抓走了那些没杀死的。佣兵点了点头。%SPEECH_ON%看来他们悄悄地溜过了我们，大人。%SPEECH_OFF%你现在只有一个选择 - 把那些被俘虏的人救回来！ |  让你的战团在%townname%附近扎营，等待强盗的袭击。你觉得这不是件困难的事情，但是一个农民却突然发疯似的闯入了你的营地。农民解释道掠夺者已经袭击了郊外。他们残杀着无辜的人们，然后，他们还掳走了一些男人，女人，和小孩。那个男人，不知道是因为喝多了还是惊吓过度，口齿不清地恳求着。%SPEECH_ON%把……把他们救回来，行吗？%SPEECH_OFF%  |  继续看着，一些愤怒的农民气势汹汹地向你走来。%SPEECH_ON%我以为只要付给你们钱，你们就会保护我们！然而你们人呢！%SPEECH_OFF%他们浑身沾满了鲜血。有些人甚至衣不遮体。一个女人吊死了一只野兽太过气愤以致于不在乎这无理行径。你走上前询问具体的情况。一个男人在胸口附近握着一根手杖，解释道掠夺者和暴徒已经攻击完并前往了附近的小村庄。他们屠戮了能看到的所有人，他们的杀戮欲满足后，还尽可能多地掳走了很多囚犯。\n\n你点点头。%SPEECH_ON%我们会把他们救回来的。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们去救他们！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Kidnapping2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{你收起了武器，并让%randombrother%去释放那些俘虏。那些还没反应过来的农民们接连被从皮绳，铁链和狗笼中放了出来。他们感谢你的及时赶到，还有你对强盗的反击。 |  强盗们被一个男人屠杀了。你派出手下去营救那些还活着的农民。每一位死里逃生的幸存者们拥抱着彼此，疯狂而开心地大哭着。 |  在杀死附近最后一个强盗后，你让手下去营救那些被流浪汉抓去的俘虏。每位幸存者都会走到你的面前，有些亲吻你的手，有些亲吻你的脚。你让他们返回%townname%，因为你也会那样做。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "看来都结束了。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Kidnapping3",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_53.png[/img]{很不幸，那些强盗带着俘虏离开了。愿诸神现在与那些可怜的灵魂同在。 |  你没能做到 - 你没能拯救那些可怜的农民。现在只有诸神知道他们身上会发生什么了。 |  不幸的是，那些掠夺者带着人类俘虏离开了。那些可怜人现在只能靠自己了。不过根据那些你听过的传言，你明白那些人是不会有好结果的。 |  那些强盗带着他们的俘虏逃走了。虽然你不知道那些可怜人以后会怎么样，但你清楚一定不会是什么好事。奴役。折磨。死亡。你不知道哪样是最糟糕的。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{在%townname%他们不会喜欢的…… | 或许他们能被召回……}",
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
			Text = "[img]gfx/ui/events/event_04.png[/img]{你回到了%employer%那儿，看起来相当得意。%SPEECH_ON%工作完成。%SPEECH_OFF%他点点头，倒了一杯没什么必要的酒给你。%SPEECH_ON%很好。小镇永远感激你的帮助。他们……用物质表达了谢意。%SPEECH_OFF%他用手势示意房间角落。你看到那里有成堆的克朗。%SPEECH_ON%%reward%克朗，正如我们的协议。再次感谢，雇佣兵。%SPEECH_OFF%  |  %employer%用一杯酒欢迎你的回归。%SPEECH_ON%喝吧，雇佣兵，这是你赢来的。%SPEECH_OFF%它的味道……很特别。傲慢，如果有这种味道的话。你的雇主从桌边转过身，高兴地坐下。%SPEECH_ON%你按照承诺保护了小镇！我大为震动。%SPEECH_OFF%他点着头，用酒杯指指橱柜。%SPEECH_ON%相当震动。%SPEECH_OFF%你打开橱柜，看到里面成堆的克朗。 |  %employer%欢迎你进他房间。%SPEECH_ON%我从窗口看到了，你知道吗？全部看到了。好吧，看到了一部分。我想是好的部分。%SPEECH_OFF%你扬起眉毛。%SPEECH_ON%哦，别那么看我。我感觉还不错。我们活着，对吧？我们，好人。%SPEECH_OFF%另一边眉毛也扬起来。%SPEECH_ON%好吧……总之，你的报酬，按照协议。%SPEECH_OFF%他给了你一箱%reward%克朗。 |  你回到%employer%那儿，发现他的房间几乎都收拾好了，一切就绪，准备离开。你产生了一点滑稽的担忧。%SPEECH_ON%准备去别的地方了？%SPEECH_OFF%他坐在椅子上。%SPEECH_ON%我有自己的怀疑，雇佣兵。你能怪我吗？对于值得之物，你不该怀疑我的支付能力。%SPEECH_OFF%他在桌上摆摆手。角落里有个起伏的金币堆。%SPEECH_ON%%reward%克朗，按照协议。%SPEECH_OFF%  |  %employer%在你进门的时候从椅子上站了起来。他鞠了一躬，有几分怀疑，却也十分真诚。他对着窗点点头，那里传来农民快乐的喧闹声。%SPEECH_ON%你听到了吗？这是你赢得的，雇佣兵。这里的人爱着你。%SPEECH_OFF%你点点头，但人民的爱不是你来这里的原因。%SPEECH_ON%我还赢得了什么？%SPEECH_OFF%%employer%笑了。%SPEECH_ON%直接的家伙。我想这就是你占优势的原因。当然，这是你赢来的。%SPEECH_ON%他把一个木箱放在桌上，打开了它。克朗的闪光温暖了你的心。 |  你进门的时候，%employer%正盯着窗。他头低到了手边，几乎处于睡梦状态。你打断了他的沉思。%SPEECH_ON%在想我？%SPEECH_OFF%他咯咯笑着，抓紧了胸口。%SPEECH_ON%你确实是我梦中之人，雇佣兵。%SPEECH_OFF%他走到房间那头，从书架上拿下一个箱子。放到桌上的时候打开了它。你的脸就被克朗照亮了。%employer%笑了。%SPEECH_ON%现在是谁做梦了？%SPEECH_OFF%  |  你进门的时候%employer%正在桌边。%SPEECH_ON%我看到了一大部分。杀戮，还有死亡。%SPEECH_OFF%你坐了下来。%SPEECH_OFF%希望你喜欢这场表演。不过这可不是免费欣赏的。%SPEECH_OFF%他点点头，拿出一个背包给了你。%SPEECH_OFF%我愿意出钱再看一次，但我不确定%townname%还想不想看。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{%companyname%会好好利用它的。 |  辛苦一天的报酬。}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Defended the town against brigands");
						this.World.Contracts.finishActiveContract();

						if (this.Flags.get("IsUndead") && this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_30.png[/img]{%employer%指着窗外欢迎你归来。%SPEECH_ON%你看到了？从这么远的距离。%SPEECH_OFF%你加入了他的阵营。他问。%SPEECH_ON%你看到了什么？%SPEECH_OFF%视野内烟雾弥漫。你告诉他，你看到的就是这样。%SPEECH_OFF%对，烟雾。我不是雇佣你来让强盗放火的，明白了吗？当然……镇上大部分人还是正直的……%SPEECH_OFF%他把一个背包扔到你怀里。%SPEECH_OFF%祝你好运，雇佣兵。还不够好。%SPEECH_OFF%  |  你回到%employer%那儿，他看起来高兴又悲伤，仿佛介于醉酒和清醒之间。这可不是你想要看见的模样。%SPEECH_OFF%你做得很好，雇佣兵。有传言说你把那群强盗的皮都剥了。还有传言说他们烧了我们的一部分郊区。%SPEECH_OFF%你电头。没必要为遮掩不住的事撒谎。%SPEECH_OFF%你会拿到报酬的，不过你要理解，重建那些地方需要钱。显然，这些钱都要从你口袋里出……%SPEECH_OFF%  |  你回来的时候，%employer%懒散地坐在椅子上。%SPEECH_ON%大多数%townname%很高兴，但有些就不怎么乐意了。你猜猜哪些是不高兴的？%SPEECH_OFF%强盗确实毁了我们郊区不少地方，这是个夸张的问题。%SPEECH_ON%我需要资金重建被那些掠夺者破坏的地方。我想你肯定理解，那么，你报酬减少的原因……%SPEECH_OFF%你耸耸肩。就是这样。 |  %employer%在书架旁。他拿出一本书，翻转过来打开。放在桌上。%SPEECH_ON%上面有数字。我想你读不懂，不过它们的意思是：强盗毁掉了小镇一部分区域，我现在需要资金重建。很不幸，我手上没那么多钱。你肯定能理解这种困境。%SPEECH_ON%你点头，说出了明显事实。%SPEECH_ON%钱要从我的报酬里扣吧。%SPEECH_ON%他点点头，慷慨地拿出一袋钱放在桌上，你的注意力全到那上面去了。争论报酬完全没有意义。你拿起钱袋离开了。}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{这只是我们说好的一半！ |  就这样了...}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() / 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractPoor, "Defended the town against brigands");
						this.World.Contracts.finishActiveContract();

						if (this.Flags.get("IsUndead") && this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion() / 2;
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] 克朗"
				});
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"), 3, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Success3",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你回到了%employer%那儿，看起来相当得意。%SPEECH_ON%工作完成。%SPEECH_OFF%他点点头，倒了一杯没什么必要的酒给你。%SPEECH_ON%很好。小镇永远感激你的帮助。他们……用物质表达了谢意。%SPEECH_OFF%他用手势示意房间角落。你看到那里有成堆的克朗。%SPEECH_ON%%reward%克朗，正如我们的协议。再次感谢，雇佣兵。哦，还有，关于那些农民……真可惜……%SPEECH_OFF%  |  %employer%用一杯酒欢迎你的回归。%SPEECH_ON%喝吧，雇佣兵，这是你赢来的。%SPEECH_OFF%它的味道……很特别。傲慢，如果有这种味道的话。你的雇主从桌边转过身，高兴地坐下。%SPEECH_ON%你按照承诺保护了小镇！我大为震动。%SPEECH_OFF%他点着头，用酒杯指指橱柜。%SPEECH_ON%相当震动。%SPEECH_OFF%你打开橱柜，看到里面成堆的克朗。%SPEECH_ON%我为遇难的农民感到惋惜。我做了相应的调整……%SPEECH_OFF%  |  %employer%欢迎你进他房间。%SPEECH_ON%我从窗口看到了，你知道吗？全部看到了。好吧，看到了一部分。我想是好的部分。%SPEECH_OFF%你扬起眉毛。%SPEECH_ON%哦，别那么看我。我感觉还不错。我们活着，对吧？我们，好人。%SPEECH_OFF%另一边眉毛也扬起来。%SPEECH_ON%好吧……总之，你的报酬，按照协议。我听说有几个农民被抓走了。所以扣除了一些。那部分钱会交给幸存者。%SPEECH_OFF%他给了你一箱%reward%克朗。 |  你回到%employer%那儿，发现他的房间几乎都收拾好了，一切就绪，准备离开。你产生了一点滑稽的担忧。%SPEECH_ON%准备去别的地方了？%SPEECH_OFF%他坐在椅子上。%SPEECH_ON%我有自己的怀疑，雇佣兵。你能怪我吗？对于值得之物，你不该怀疑我的支付能力。%SPEECH_OFF%他在桌上摆摆手。角落里有个起伏的金币堆。%SPEECH_ON%比说好的前少了不少克朗。你知道被强盗带走的农民会是什么下场吗？我扣除报酬是有原因的。%SPEECH_OFF%  |  你进门的时候%employer%从椅子上站了起来。他鞠了一躬，有几分怀疑，却也十分真诚。他对着窗点点头，那里传来农民快乐的喧闹声。%SPEECH_ON%你听到了吗？这是你赢得的，雇佣兵。这里的人爱着你。%SPEECH_OFF%你点点头，但人民的爱不是你来这里的原因。%SPEECH_ON%我还赢得了什么？%SPEECH_OFF%%employer%笑了。%SPEECH_ON%直接的家伙。我想这就是你占优势的原因。当然，这是你赢来的。好吧，少了点。你让强盗抓走了农民，肮脏的勾当，不？%SPEECH_OFF%他把一个木箱放到桌上，打开了它。克朗的闪光温暖了你的心。 |  你进门的时候，%employer%正盯着窗。他头低到了手边，几乎处于睡梦状态。你打断了他的沉思。%SPEECH_ON%在想我？%SPEECH_OFF%他咯咯笑着，抓紧了胸口。%SPEECH_ON%你确实是我梦中之人，雇佣兵。%SPEECH_OFF%他走到房间那头，从书架上拿下一个箱子。放到桌上的时候打开了它。你的脸就被克朗照亮了。%employer%露出了一丝笑意，但它瞬间消失了。%SPEECH_ON%比你期待的少了点？你没能阻止强盗带走的那些农民的家人会拿到那些钱。我想你肯定能理解。%SPEECH_OFF%  |  你进门的时候%employer%正在桌边。%SPEECH_ON%我看到了一大部分。杀戮，还有死亡。%SPEECH_OFF%你坐了下来。%SPEECH_OFF%希望你喜欢这场表演。不过这可不是免费欣赏的。%SPEECH_OFF%他点点头，拿出一个背包给了你。%SPEECH_OFF%我愿意出钱再看一次，但我不确定%townname%还想不想看。当然，被强盗抓走的可怜镇民一点都不想有这种遭遇。%SPEECH_OFF%你看了看袋子，发现里面的克朗比期望中要少。}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{这只是我们说好的一半！ |  就这样了...}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() / 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractPoor, "Defended the town against brigands");
						this.World.Contracts.finishActiveContract();

						if (this.Flags.get("IsUndead") && this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion() / 2;
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] 克朗"
				});
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"), 3, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Success4",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_30.png[/img]{%employer%指着窗外欢迎你归来。%SPEECH_ON%你看到了？从这么远的距离。%SPEECH_OFF%你加入了他的阵营。他问。%SPEECH_ON%你看到了什么？%SPEECH_OFF%视野内烟雾弥漫。你告诉他，你看到的就是这样。%SPEECH_OFF%对，烟雾。我不是雇佣你来让强盗放火的，明白了吗？当然……镇上大部分人还是正直的……%SPEECH_OFF%他把一个背包扔到你怀里。%SPEECH_OFF%祝你好运，雇佣兵。还……不够好。我为那些被强盗抓走的农民感到惋惜。%SPEECH_OFF%  |  你回到%employer%那儿，他看起来高兴又悲伤，仿佛介于醉酒和清醒之间。这可不是你想要看见的模样。%SPEECH_OFF%你做得很好，雇佣兵。有传言说你把那群强盗的皮都剥了。还有传言说他们烧了我们的一部分郊区。%SPEECH_OFF%你电头。没必要为遮掩不住的事撒谎。%SPEECH_OFF%你会拿到报酬的，不过你要理解，重建那些地方需要钱。还有你没能阻止强盗带走的那些人呢？他们的家人也需要帮助。显然，这些钱都要从你口袋里出……%SPEECH_OFF%  |  你回来的时候，%employer%懒散地坐在椅子上。%SPEECH_ON%大多数%townname%很高兴，但有些就不怎么乐意了。你猜猜哪些是不高兴的？%SPEECH_OFF%强盗确实毁了我们郊区不少地方，这是个夸张的问题。%SPEECH_ON%我需要资金重建被那些掠夺者破坏的地方。我还需要钱帮助幸存者。我想你肯定理解，那么，你报酬减少的原因……%SPEECH_OFF%你耸耸肩。就是这样。 |  %employer%在书架旁。他拿出一本书，翻转过来打开。放在桌上。%SPEECH_ON%上面有数字。我想你读不懂，不过它们的意思是：强盗毁掉了小镇一部分区域，我现在需要资金重建。很不幸，我手上没那么多钱。你肯定能理解这种困境。%SPEECH_ON%你点头，说出了明显事实。%SPEECH_ON%钱要从我的报酬里扣吧。还有那些你没能阻止强盗抓走的人？他们有家人。有幸存者。他们也会拿到我们‘协议’的一部分钱。%SPEECH_OFF%他点点头，慷慨地拿出一袋钱放在桌上，你的注意力全到那上面去了。争论报酬完全没有意义。你拿起钱袋离开了。}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{这只是我们说好的一半！ |  就这样了...}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() / 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(0);
						this.World.Contracts.finishActiveContract();

						if (this.Flags.get("IsUndead") && this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion() / 2;
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] 克朗"
				});
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"), 3, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_30.png[/img]{当你走进%employer%房间时，他让你关上身后的门。门闩的声音刚落下，那人就扑头盖脸地向你道出污言秽语，你几乎都反应不过来。他的语气逐渐平静，而措辞也恢复常态。%SPEECH_ON%外围被摧毁地精光。你觉得我雇佣你到底是干嘛的？滚。%SPEECH_OFF%  |  当你进来时，%employer%猛地甩开酒杯。窗户外满是喧闹的生气农夫。%SPEECH_ON%听到了吗？雇佣兵，要是我付你钱，他们就要我的脑袋了。你只有一个任务，一个！保护这座镇子。而你还没有做到。现在还有件事你能做到，而且还是免费的：滚出我的视线。%SPEECH_OFF%  |  %employer%拍向桌子。%SPEECH_ON% 你还回来了，你在期待什么？真是让我惊讶。小镇一半着火了，而另一半已经化为了灰烬。雇佣兵，雇佣你不是让你产生硝烟和荒芜的。赶紧给我离开这里。%SPEECH_OFF%  |  当你回去找%employer%时，他手中正拿着一杯麦芽酒。手微微摇动着。脸色酡红。%SPEECH_ON% 我费了好大劲儿才克制住不将这玩意泼向你的脸。 %SPEECH_OFF% 以防万一，他一大口将酒喝光了。然后砸向桌子。%SPEECH_ON% 整个镇子都期待你能保护他们。但是强盗蜂拥而至外围，他妈的就像观光度假一样！我又不是做强盗旅游生意的，雇佣兵。赶紧给我滚！%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{这个该死的乡巴佬！ |  我们应该提前多要点报酬…… |  妈的！}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to defend the town against brigands");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"), 3, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Failure2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_30.png[/img]{当你走进%employer%房间时，他让你关上身后的门。门闩的声音刚落下，那人就扑头盖脸地向你道出污言秽语，你几乎都反应不过来。他的语气逐渐平静，而措辞也恢复常态。%SPEECH_ON%外围被摧毁地精光。还有人被弄得不知死活！你觉得我雇佣你到底是干嘛的？滚。%SPEECH_OFF%  |  当你进来时，%employer%猛地甩开酒杯。窗户外满是喧闹的生气农夫。%SPEECH_ON%听到了吗？雇佣兵，要是我付你钱，他们就要我的脑袋了。你只有一个任务，一个！保护这座镇子。而你还没有做到。见鬼，你连被抓的农夫都没救下来！现在还有件事你能做到，而且还是免费的：滚出我的视线。%SPEECH_OFF%  |  %employer%拍向桌子。%SPEECH_ON% 你还回来了，你在期待什么？真是让我惊讶。小镇一半着火了，而另一半已经化为了灰烬。幸存者跟我说他们的家人被绑架了！你知道被抓的人会怎么样吗？雇佣兵，雇佣你不是让你产生硝烟和荒芜的。赶紧给我离开这里。%SPEECH_OFF%  |  当你回去找%employer%时，他手中正拿着一杯麦芽酒。手微微摇动着。他血气上涌。%SPEECH_ON% 我费了好大劲儿才克制住不将这玩意泼向你的脸。%SPEECH_OFF% 以防自己被怒火冲昏头脑，他一大口将酒喝光了。然后砸向桌子。%SPEECH_ON% 整个镇子都期待你能保护他们。但是强盗蜂拥而至外围，他妈的就像观光度假一样！我又不是做强盗旅游生意的，雇佣兵。给我马不停蹄地滚！%SPEECH_OFF%  |  你进%employer%房间的时候，他笑了。%SPEECH_ON%镇子外围都毁了。%townname%的镇民躁动不安，至少幸存者都很生气。还有什么？你让那群禽兽抓走了我们不少人！%SPEECH_OFF%他摇着头，指着门。%SPEECH_ON%我不知道你觉得我给你报酬的原因是什么，反正不是这个。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{这个该死的乡巴佬！ |  我们应该提前多要点报酬…… |  妈的！}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to defend the town against brigands");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"), 3, this.Contract.m.Home, this.List);
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"reward",
			this.m.Reward
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			local s = this.new("scripts/entity/world/settlements/situations/raided_situation");
			s.setValidForDays(4);
			this.m.SituationID = this.m.Home.addSituation(s);
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.World.FactionManager.getFaction(this.getFaction()).setActive(true);
			this.m.Home.getSprite("selection").Visible = false;

			if (this.m.Kidnapper != null && !this.m.Kidnapper.isNull())
			{
				this.m.Kidnapper.getSprite("selection").Visible = false;
			}

			if (this.m.Militia != null && !this.m.Militia.isNull())
			{
				this.m.Militia.getController().clearOrders();
			}

			this.World.getGuestRoster().clear();
		}
	}

	function onIsValid()
	{
		local nearestBandits = this.getNearestLocationTo(this.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getSettlements());
		local nearestZombies = this.getNearestLocationTo(this.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getSettlements());

		if (nearestZombies.getTile().getDistanceTo(this.m.Home.getTile()) > 20 && nearestBandits.getTile().getDistanceTo(this.m.Home.getTile()) > 20)
		{
			return false;
		}

		local locations = this.m.Home.getAttachedLocations();

		foreach( l in locations )
		{
			if (l.isUsable() && l.isActive() && !l.isMilitary())
			{
				return true;
			}
		}

		return false;
	}

	function onSerialize( _out )
	{
		this.m.Flags.set("KidnapperID", this.m.Kidnapper != null && !this.m.Kidnapper.isNull() ? this.m.Kidnapper.getID() : 0);
		this.m.Flags.set("MilitiaID", this.m.Militia != null && !this.m.Militia.isNull() ? this.m.Militia.getID() : 0);
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.contract.onDeserialize(_in);
		this.m.Kidnapper = this.WeakTableRef(this.World.getEntityByID(this.m.Flags.get("KidnapperID")));
		this.m.Militia = this.WeakTableRef(this.World.getEntityByID(this.m.Flags.get("MilitiaID")));
	}

});

