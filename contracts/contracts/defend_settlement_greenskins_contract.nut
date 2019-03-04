this.defend_settlement_greenskins_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Reward = 0,
		Kidnapper = null,
		Militia = null
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.defend_settlement_greenskins";
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
					"保护 %townname% 及其郊区免受袭击"
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
				local nearestOrcs = this.Contract.getNearestLocationTo(this.Contract.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getSettlements());
				local nearestGoblins = this.Contract.getNearestLocationTo(this.Contract.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getSettlements());

				if (nearestOrcs.getTile().getDistanceTo(this.Contract.m.Home.getTile()) + this.Math.rand(0, 6) <= nearestGoblins.getTile().getDistanceTo(this.Contract.m.Home.getTile()) + this.Math.rand(0, 6))
				{
					this.Flags.set("IsOrcs", true);
				}
				else
				{
					this.Flags.set("IsGoblins", true);
				}

				if (this.Math.rand(1, 100) <= 25 && this.Contract.getDifficultyMult() >= 0.95)
				{
					this.Flags.set("IsMilitia", true);
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

					if (this.Flags.get("IsGoblins"))
					{
						party = this.Contract.spawnEnemyPartyAtBase(this.Const.FactionType.Goblins, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					}
					else
					{
						party = this.Contract.spawnEnemyPartyAtBase(this.Const.FactionType.Orcs, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
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

						if (this.Flags.get("IsGoblins"))
						{
							this.Contract.setScreen("GoblinsAttack");
						}
						else
						{
							this.Contract.setScreen("OrcsAttack");
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
			Text = "[img]gfx/ui/events/event_20.png[/img]{你看到%employer%的时候，他满头大汗，正用一块漂亮的绣花布料擦拭着，但仿佛仍然无济于事。%SPEECH_ON%雇佣兵，看到你真是太好了！求求你，求你进来听听我要说的话吧。%SPEECH_OFF%你小心走进房间坐下，立刻环视四周，确保没人躲在门后或是墙边的书架后。%employer%在桌上摊开一张地图。%SPEECH_OFF%看到这些绿色标记了吗？这是我的侦察兵侦察到的绿皮怪物的行迹。有时候他们会向我报告，有时候他们根本无法报告。那些侦察兵就……噗，不见了。但是要知道他们遇上了什么事也不太费脑子，对吗？%SPEECH_OFF%你问他想要什么。他一拍地图，手落在%townname%上。%SPEECH_ON%你看不到吗？他们从这儿涌来，我需要你帮我们防守！%SPEECH_OFF%  |  你找到%employer%的时候，他正不安地抠着手指。这会儿他都把它们折断了，抠得血肉模糊。%SPEECH_ON%你能来太好了，雇佣兵。我实话告诉你把，绿皮怪物来了。%SPEECH_OFF%你用一只手比了比高度，问他是哪种绿皮怪物，是这么大的，还是……嗯，这么大的。%employer%耸耸肩。%SPEECH_ON%我不知道。我的侦察兵不停失踪，而来的村民又不是确切的目击证人。你只需要知道我们需要你的帮助，因为绿皮怪物是从这里过来的。%SPEECH_OFF%  |  %employer%浑浑噩噩地倒进椅子里。他翻阅着桌上摊开的书本。%SPEECH_ON%你听说过众名之战吗？大概10年前，兽人涌入人类土地，人类拿起武器走上了战场，反抗了他们。%SPEECH_OFF%你点点头，对这场战斗，和它结束的战争十分了解。他继续道。%SPEECH_ON%不幸的是，我们有证据表明他们又卷土重来了。绿皮怪物，不明类型，不明高度也不明种类，但他们确实来了。%SPEECH_OFF%他把剩下的酒丢回去，像是喝断头酒一样咽下嘴里的酒。%SPEECH_ON%你会留下来保护我们吗？当然，我们会给你合理的价钱。我还没忘记你的职业。%SPEECH_OFF%  |  你进门的时候%employer%正在窗边。%SPEECH_ON%你听到了吗？%SPEECH_OFF%街上的人群发出的冷漠的呻吟和恐惧的哭喊混合在一起。%SPEECH_ON%这就是绿皮怪物带来的声音。%SPEECH_OFF%他关上窗，转向你。%SPEECH_ON%我知道这有些过分，但我们有钱，所以我就厚着脸皮说了。你愿意保护%townname%吗？%SPEECH_OFF%  |  你找到%employer%的时候，他正努力安抚民众。%SPEECH_ON%大家冷静！冷静！%SPEECH_OFF%有人扔出一颗洋葱，熏得人落泪的腐烂蔬菜正中他的额头。另一个人迅速冲过去捡起来咬了一口。%employer%在人群中发现了你。%SPEECH_OFF%雇佣兵！太好了，你来了！%SPEECH_OFF%他努力挤出人群。他贴到你耳边说话，却还是要用喊的才能让你听清。%SPEECH_ON%我们有钱！我们有你需要的东西！保护这个镇子，别让它被绿皮怪物毁掉！%SPEECH_OFF%  |  %employer%的手下匆忙逃离前搜查了他的房间，拿走了卷轴和书籍。他本人就坐在椅子上，研究地图的时候偶尔喝一口酒杯里的酒。他招手让你进来。%SPEECH_ON%坐吧。别管我的员工。%SPEECH_OFF%你照做了，不过要无视周围的怒气有点困难。%employer%坐了回去，手摸着腹部。%SPEECH_ON%我想你注意到了这里的异常。这是因为我们发现了一大群绿皮怪物，而他们正朝这儿来，破坏了路上的一切。显然，我希望你能保护%townname%别让我们变成作家的注解？%SPEECH_OFF%  |  你进入了%employer%的住处，不受控制地注意到地板上全是泥巴，他的座位被点了火。他不少手下抱着卷轴匆匆来去。那么多纸堆在那里你几乎看不到他们脑袋了。你看到%employer%站在混乱中心，指挥手下做这做那。你走向他，他简单地点点头。%SPEECH_OFF%绿皮怪物来了什么种类？我不知道。我只知道如果我不能守卫这座小镇的话会发生什么，这也是我们做预先准备的原因。%SPEECH_OFF%你点头回应，然后问他还想要什么。%SPEECH_OFF%当然是帮助我们对抗绿皮怪物。当然，我们会给你很多钱。%SPEECH_OFF%  |  农夫们聚到了%employer%的住所。他们抱着满怀的东西，每走一步都会掉下点什么，但他们心情急切，甚至懒得去捡。%employer%透过窗户看到了你，挥手示意你从侧门进来。你偷偷溜进去，他一屁股跌坐在椅子上，给你倒了杯酒。%SPEECH_OFF%绿皮怪物来了，我认为保卫%townname%的人手不足。我想要你帮助我们保证%townname%的安全，让它不受绿皮怪物的威胁。 %SPEECH_OFF%  |  有个人站在%employer%的住所外，两块画着图的木板挂在他身上。每块板上都写着灾难预言家的预言。你无视了他，走进屋子。%employer%站在那儿，笑着摇头。%SPEECH_OFF%那家伙站在那里没有错。我的侦察兵报告说绿皮怪物往这里来有段时间了。如今侦察兵已经有整整一星期没消息了，可能是被绿皮怪物杀害了吧。现在普通镇民跑到我这里来讲外面怎么样，有多少可怕生物冲这里来的恐怖故事了。%SPEECH_OFF%他转向你，咧嘴而笑，笑容中流露出疯狂来。%SPEECH_ON%你觉得我跟你做个交易让那些灾难预言家闭嘴怎么样？你会帮我们保护%townname%吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{%townname%准备为他们的安危支付多少呢？ |  这对你们来说可值一大笔钱啊，对吗？ |  对抗绿皮怪物可不便宜。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{恐怕你要靠自己了。 |  这对%companyname%来说恐怕太少了。 | 祝你好运，但跟我们无关。}",
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
			Text = "[img]gfx/ui/events/event_43.png[/img]{拒绝并离开了%employer%后，你遇到了一个晃着脑袋大笑的人。%SPEECH_ON%嘿，那些绿皮怪物可不在那边，除非，你本就打算当个懦夫逃跑。%SPEECH_OFF%你拔出了你的剑，剑鞘发出了一阵悦耳的摩擦声。那个人大笑着。%SPEECH_ON%哦，你要拿那玩意儿作甚？砍了我吗？没问题。尽管来吧。我敢说，你能比在对付那些绿皮怪时做得更好。%SPEECH_OFF%一这时一个女人冲了出来，将他拉了回去。%SPEECH_ON%快去把孩子接来，行吗？我们要马上离开这里！%SPEECH_OFF%那对男女互相推搡着离开了，但你仍然无法释怀那个乡巴佬对你的控诉。 |  农民们已经打包好了行李，准备离开%townname%。一些人瞥视着你，而其中一位拿着拐杖的老头甚至向你走了过来。%SPEECH_ON%瞧见了吗，现在这世道就是这样！正直的人们都死了，只有那些所谓的剑士懦夫般地活了下来。%SPEECH_OFF%%randombrother%向前踏出了一步，挥舞着武器似乎是想痛下杀手。%SPEECH_ON%你竟敢侮辱%companyname%？我要先割了你的舌头，再砍了你的脑袋，老家伙！%SPEECH_OFF%你抓住了那个佣兵的肩膀。这些人现在最不需要的东西就是暴力了，但那个人说话的声音很大。你想知道有谁听到了他话，而又有谁会将他说的话散布出去。 |  就在你准备走回战团的时候，一个女人紧紧地拽住了你。%SPEECH_ON%大人，求你了！你不能就这样抛弃我们！你清楚那些绿皮怪物会对我们做什么的！%SPEECH_OFF%你当然明白这些，但并没有说出来。那个女人跪了下来，抱住了你的双腿。你摆脱了她的束缚。她不管不顾地纠缠了你一段时间，弄得自己满身是泥，然后停了下来，开始哭泣。%SPEECH_ON%你不明白那是怎样的情形。那对我们，对我来说，都不会是什么好事。%SPEECH_OFF%看在众神的份上，那可真可怜，而你也发现自己的内心中对他们产生了一丝怜悯。 |  当你拒绝并离开%employer%时，一个男人从他的住所中走了出来。他的手轻轻抚摸着身边的鸡，眼中噙着泪水。%SPEECH_ON%大人，如果您愿意留下的话，这就是您的了。%SPEECH_OFF%那个农民亲吻了一下身边的鸡。那只鸡咯咯乱叫着，似乎也并不在乎其拥有者脸上悲痛的表情。%SPEECH_ON%留下来拯救这座小镇。这是您的了。请留下来，求您了。%SPEECH_OFF%哦小子，就这样吗？ |  一位头发散乱，年纪很大的老头朝你走来。%SPEECH_ON%你决定不帮忙吗？我想我也不能因此责怪你。%SPEECH_OFF%他向站在附近的一些农民挥了挥手。他们拿着几只箱子，里面装满了各种物品，有发霉的蔬菜，一两只鸡，或是又小又瘦的羔羊。%SPEECH_ON%那些人希望你能留下来帮忙。但我明白你为什么不想留下来。我曾参加过众名之战。我知道跟那些野兽作战是一种怎样的感觉。我不会责怪你。一个人要提起很大的勇气才敢去面对它们。是的，是的，大人，我不会责怪你，一点儿也不会。%SPEECH_OFF%他慢慢地跛着脚走了回去，你发现他的一条腿是用木头替代了。一些小孩子跑向了他，而他与身边的农民们交谈了起来。他回头看了你一眼，然后又转过头去，摇了摇头。你感受到一阵悲伤和失望的气息向你席卷而来。}",
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
			ID = "OrcsAttack",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_49.png[/img]绿皮怪物出现了！准备战斗，保护小镇！",
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
			ID = "GoblinsAttack",
			Title = "%townname%附近",
			Text = "[img]gfx/ui/events/event_48.png[/img]绿皮怪物出现了！准备战斗，保护小镇！",
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
			Text = "[img]gfx/ui/events/event_22.png[/img]{战斗结束了。%employer%非常高兴能再次见到你。 |  战斗结束了，空闲下来的人们抓紧开始休息。%employer% 正等着你返回小镇。 |  在战斗结束后，你环视着散落在战场四处的尸体。那是一副令人厌恶的景象，但出于某种原因，这种景象却激励了你。这布满死尸的恐怖丘陵只会让你重新振作起来，你还未向这糟糕的世界屈服。%employer%那样的人应该来看看这样的景象，但是他是不会来的，所以得换作你去找他。 |  血肉残肢散布在战场各处，几乎已经无法辨别出那些肢体到底是属于谁的了。黑色的秃鹰在空中盘旋着，徘徊着的阴影覆盖在了死者之上，那些食腐的鸟类正等待着哀悼者的离去。%randombrother%走到你的身边，询问现在是否开始返回%employer%那里。你点了点头，转过了身子，不再去看那片战场。 |  这片废墟堆满了死尸。那些死者还维持着生前的姿态，只不过他们的动作是永久地固定了，他们的生命在那场意外中落下了帷幕。%randombrother%走了过来，问你是否没事。说实话，你自己也不清楚，你现在唯一想做的就是去见%employer%。 |  畸形的人体和扭曲的尸体散布在战场各处，他们根本不清楚自己是如何在战斗中变成了这样的结果。孤零零的脑袋散落在战场之上，在战斗中，无论是人类还是兽人，都不会浪费力气去将别人的脖子完全砍断，因此，这些脑袋只会是被又快又锋利的剑刃斩下的。你心中有一部分想赶快结束这场纷争，但另一部分却希望趁机去解决你的对手。\n\n %randombrother%走了过来，向你询问接下来的命令。你转身向%companyname%下令，准备返回%employer%。}",
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
			Text = "[img]gfx/ui/events/event_30.png[/img]{就在你搜索那些绿皮怪物时，一位农民跑了过来，告诉你有一群兽人攻击了附近的居民，而且他们似乎扣留了很多人质。你怀疑地摇了摇头。那些畜生是如何溜进来做这种事情的呢？那个农民也摇了摇头。%SPEECH_ON%我以为你们是来帮助我们的。为什么不做点事情呢？%SPEECH_OFF%你问那些绿皮怪物是否走远了。那农民耸了耸肩，不过他认为那些家伙并没有走远。看来在那些被扣押的人们遭罪前你仍有机会救出他们。 |  一个衣衫褴褛手拿破旧草叉的人向你的战团飞奔而来。他伏在你的脚边嚎啕大哭。%SPEECH_ON%那些绿皮怪物攻击了我们！哦，他们跟我爷爷说得一样可怕！你们人去哪儿了？他们残杀着居民……还用火焚烧他们……而且……我想他们还吃人……哦，天啊。但那还不是最糟的！那些绿皮怪物还俘虏了一些可怜的家伙！求求您，快去救他们吧！%SPEECH_OFF%你看了眼%randombrother%然后点了点头。%SPEECH_ON%让大家都做准备。我们需要在那些肮脏的野兽逃走前追上他们。%SPEECH_OFF%  |  你望向远方，寻找了那些绿皮怪物的踪迹。忽然，%randombrother%走到了你的身边，旁边还带着一个女人。他把她推上前来，然后点了点头。她紧抓着前襟，一边啜泣着一边讲述了那些野兽是如何发动攻击，如何毁灭了附近的村落。她说他们不仅残杀无辜，甚至还抓了一些人当作俘虏。佣兵点了点头。%SPEECH_ON%看来他们悄悄地溜过了我们，大人。%SPEECH_OFF%你现在只有一个选择 - 把那些被俘虏的人救回来！ |  让你的战团在%townname%附近扎营，等待绿皮怪物的袭击。你觉得这不是件困难的事情，但是一个农民却突然发疯似的闯入了你的营地。他说那些肮脏的掠夺者已经袭击了内地的一个小村庄。他们残杀着无辜的人们，然后，为了满足之后的嗜血欲望，他们还掳走了一些男人，女人，和小孩。那个农民，不知道是因为喝多了还是惊吓过度，口齿不清地恳求着。%SPEECH_ON%把……把他们救回来，行吗？%SPEECH_OFF%  |  一些愤怒的农民气势汹汹地向你走来。%SPEECH_ON%我以为只要付给你们钱，你们就会保护我们！然而你们人呢？%SPEECH_ON%他们浑身沾满了鲜血。有些人甚至衣不遮体。其中一个男人用手臂顶着自己的胸口。而手臂上的手已经不见了。你走上前询问具体的情况。一个女人走了上来，脚边还蜷缩着一个小孩。她歇斯底里地喊道。%SPEECH_ON%具体情况？你们这些该死的佣兵！当然是那些绿皮怪物，还能有什么情况？你们本应该来保护我们，然而就在你们安稳地躺在床上的时候，那群怪物袭击了我们！我们这些人是跑出来了，而那些没跑出来的人都被那群野兽给俘虏了！你知道那些被抓去的人会遇上什么样的情况吗？虽然我不知道，但我肯定那些怪物是不会邀请他们去唱歌吃饭的！\n\n 你让那个喋喋不休的女人闭上嘴好好休息去。%SPEECH_ON%我们会把他们救回来的。%SPEECH_OFF%}",
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
			Text = "[img]gfx/ui/events/event_22.png[/img]{你收起了武器，并让%randombrother%去释放那些俘虏。那些还没反应过来的农民们接连被从皮绳，铁链和狗笼中放了出来。他们对你的及时赶到表示万分感谢。其中有一人抓挠着刚才被链子拷住的地方。%SPEECH_ON%谢谢你，佣兵。%SPEECH_OFF%他又向旁边一个被绑在火堆上干瘪的漆黑尸体点了点头。%SPEECH_ON%只可惜你没能及时救到她。她原本可是个大美人。现在，看看她的样子吧。%SPEECH_OFF%那男人冷笑了一声，然后痛哭了起来。 |  该死的绿皮怪物们被杀死了。你派出手下去营救那些还活着的农民。每一位死里逃生的幸存者们拥抱着彼此，疯狂而开心地大哭着。 |  在杀死最后一个绿皮怪物后，你让手下去营救那些俘虏。每位幸存者都会走到你的面前，有些亲吻你的手，有些亲吻你的脚。你让他们返回%townname%的市政厅，而且你也会向那里进发。 |  在杀死最后一个绿皮怪物后，你让手下去营救那些俘虏。他们颤颤巍巍地从囚笼中爬了出来，完全处于震惊之中，在看到战场的景象时甚至连站都站不稳了。有一些人在挖掘那些绿皮怪物的营房。你看着他们，其中一位{man  |  woman}拾起了一堆冒烟，焦黑的骨头。他们盯着那些残骸，将其放了下来，然后站起身走进了荒野。}",
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
			Text = "[img]gfx/ui/events/event_53.png[/img]{很不幸，那些绿皮怪物带着俘虏离开了。愿诸神现在与那些可怜的灵魂同在。 |  你没能做到 - 你没能拯救那些可怜的农民。现在只有诸神知道他们身上会发生什么了。事实上，你明白他们会怎么样，但是你只能装作不知道，因为只有如此，你晚上才能睡得安稳。 |  不幸的是，那些肮脏的野兽带着人类俘虏离开了。那些可怜人现在只能靠自己了。不过根据那些你听过的传言，你明白那些人是不会有好结果的。 |  那些绿皮怪物带着他们的俘虏逃走了。虽然你不知道那些可怜人以后会怎么样，但你清楚一定不会是什么好事。奴役。折磨。死亡。你不知道哪个是最糟糕的结果。 |  那些绿皮怪物带着他们的俘虏逃走了。你希望那些可怜人能交上好运，但身边低嚎的寒风提醒着你，无论是希望还是祈祷，都无法拯救那些可怜的灵魂。 |  那些绿皮怪物跑走了。地面上残留的人骨和血肉痕迹让你明白，自己已经失败了。 |  你从一堆骨头上捡起了一片衣服的碎片。%SPEECH_ON%好吧，该死。%SPEECH_OFF%这里遗留的\xfffd食物\xfffd残羹的痕迹延伸向了远处。那些绿皮怪物逃走了，那些俘虏们也不见了。 |  %randombrother%招呼着你。当你来到他身边时，他指向了地面上的一堆屎。你耸了耸肩。%SPEECH_ON%是的。很臭。然后呢？%SPEECH_OFF%他踢了踢里面的一个白色物体，从粪便中捡起了一个类似骨头的东西。%SPEECH_ON%这是人类的骨头。他们在吃俘虏，大人。%SPEECH_OFF%你看向了草地，发现了更多的残骸。足迹延伸向了远方，很显然那些绿皮怪物逃离了你的追踪。你叹了口气，通知手下准备离开。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{%townname%的人是不会喜欢这个消息的…… |  我希望他们死时不用承受太多的痛苦。}",
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
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer%欢迎了你的回归，并奖励了您一箱%reward%克朗。%SPEECH_ON%这是你应得的，佣兵，我非常赞同这点。小镇的所有人都非常感激你。%SPEECH_OFF%他停顿了下来，发现你正盯着那个装备克朗的箱子。虽然战斗很凶险，但回报也很丰厚。你希望能得到更多。有时作为雇佣兵追求金钱的本质真的让你感到很心烦。 |  你发现%employer%正在喂他的那几条狗。他不停地抚摸着那条正在进食的狗的脑袋。%SPEECH_ON%我真的想过放弃。%SPEECH_OFF%他最后抚摸了一下狗，然后抬头看向你。%SPEECH_ON%谢谢你，雇佣兵。你不仅是保护了这个小镇，还保护了一种生活方式，没有你，我们都会就此死去，甚至更糟的是，亲眼目睹那地狱般的景象。%SPEECH_OFF%你点了点头，走上前去抚摸其中的一条狗，但是它却朝你怒目而视，咆哮了起来。%employer%笑了起来。%SPEECH_ON%请原谅它的无礼。%SPEECH_OFF%  |  %employer%他招来了一群男人和女人站在了自己的周围当你走进房间时，他们诡异地一齐转向了你。他们盯了你一会儿，然后爆发出一阵欢呼，冲过来拥抱你，激动地大哭着。摆脱他们后，你发现%employer%站在那里，手中拿着一个挎包。%SPEECH_ON%这是为了奖励你拯救了%townname%，佣兵。说实话，这并不是很多，但是这是我们能拿出的所有了。%SPEECH_OFF%  |  %employer%在你回来时正在看向窗外。外面，民兵们不停地来回奔波着，而居民们正拥抱着彼此。%SPEECH_ON%没有一个绿皮怪物进入到了城镇中来。.%SPEECH_OFF%他笑着递过一包物品。%SPEECH_ON%这些是你应得的，佣兵。%SPEECH_OFF%  |  你发现%employer%并不是很轻松：整个小镇都因庆祝而骚动了起来。人们迅速地给鸟禽拔着毛，而其中有些鸟禽试图逃离此处，披着散乱的毛在大街上乱跑，而小孩子们也争相追逐着它们。庆典中%employer%偷偷靠近了你。%SPEECH_ON%虽然我们还有很多需要哀悼的事情，但还是明天再办吧。今天，我们庆祝生命，还有你的伟大事迹，佣兵。%SPEECH_OFF%那家伙递过一个装着物品的袋子，放在了你的手中。 |  你发现%employer%正在整理书橱。他似乎在补充商品，像一位店主一样在仔细计算着自己的货物。他被你身后门关上的声音吓得跳了起来。%SPEECH_ON%啊，佣兵！你吓到我了。%SPEECH_OFF%他从其中一个书橱上拿下了一个箱子，然后将它交给了你%SPEECH_ON%我本打算带上这些书和卷轴逃跑呢。现在，多亏了你，我就不用那么做了。%SPEECH_OFF%他笑了一下，但笑容很快就消失了。%SPEECH_ON%不过并不是所有人能幸运地看到这天，看到你的胜利。今晚我必须要看到那些死者得到安葬。%SPEECH_OFF%}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Defended the town against greenskins");
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
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] 克朗"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_30.png[/img]{%employer%低头挡住了自己的脸。你指向他的窗外。%SPEECH_ON%小镇已经被拯救了，你为什么还要哭泣呢？%SPEECH_OFF%他抬起头看向你。%SPEECH_ON%是的，大部分人的确是活下来了。但这并不代表那群绿皮怪物没对这座小镇造成伤害。%SPEECH_OFF%他把桌子上一个装着物品的箱子向你推了过来，然后用手指顶住了眉头。%SPEECH_ON%很抱歉破坏了你的心情，但我相信你一定能理解我内心的感受，佣兵。至少，我希望你能够理解。%SPEECH_OFF%你的确理解，但却装作毫不在乎。 |  你发现%employer%正在他的住所后面。他手中正拿着一个铁铲，正在埋葬一些农民。附近还堆积了一些新挖出的泥土。%SPEECH_ON%见到你真高兴，佣兵。%SPEECH_OFF%他用铁铲支撑着自己。%SPEECH_ON%我只是在，呃，埋葬一些没能幸存下的人。不可否认，你干得很棒，不过还是有很多人没能活下来。我不是在责怪你，那些绿皮怪物是可怕的对手，能有这样的结果我已经很满意了。%SPEECH_OFF%你点了点头，他随即也向你点头示意。他从一堆沾满泥土的铲子中拾起了一只挎包。当他把包扔过来时，上面还抖落了一些泥土。你接住了挎包，再次向他点了点头，然后离开了。离开时，你仍能听见那铁铲插入泥土的声音。 |  你回来时%employer%正在研究地图。他用手指点着地图上的地点，然后口中念念有词。%SPEECH_ON%这个地方沦陷了。这个地方被烧尽了。这些人已经死了。我们在树林中发现了这些家伙。我想他们本是准备躲起来的，但是他们之中却有一个婴儿。我怀疑他们就是因此而死的。%SPEECH_OFF%他身子微微前倾，手指敲击着桌面。%SPEECH_ON%你做得很好，佣兵，但并不是所有人都活了下来。不过事情已经如此，就像他们说的，我不能因此责怪你。更何况我和其他人的命都是你救的。%SPEECH_OFF%他向你扔来了一袋克朗。你接住后向他点了点头。事情已经如此了，更重要的是，今天的收获还是不错的。 |  你发现%employer%正在慢慢地浏览着一份很长的卷轴。他点着头低声道。%SPEECH_ON%你知道看那些死去邻居的名字是种什么样的感觉吗？%SPEECH_OFF%你知道，但是你不想打断他。%SPEECH_ON%这是一种奇怪的感觉。我明明认识他们，但现在，我却无法想起他们的长相。我只认得出他们的名字，这些字母，跟其他字母也没有不一样的地方。他们现在只存在于词汇表中了。我想，这就是的所谓的记忆吧。%SPEECH_OFF%他抬头看向你，将卷轴扔向一旁，然后拿给你一袋克朗。%SPEECH_ON%该死的，我可不想破坏你的心情，佣兵。这些是我们说好的奖励。%SPEECH_OFF%  |  %employer%正在用画笔指着一个男人。他们的画布是用厚厚的纸片混合而成的，看起来似乎是某种玻璃。你对此很好奇，问这是什么情况。%SPEECH_ON%我正在铭记这场战斗。纪念它。%SPEECH_OFF%他指着画中一栋正在燃烧的建筑。%SPEECH_ON%看到那个了吗？当你去跟那群绿皮怪物战斗时，他们烧毁了那个地方。还有那里也是。我们要铭记这一切，以免遗忘了这一切。%SPEECH_OFF%他递给你一袋克朗，然后重新回去作画了。你看着那副画，并没有在里面找到你战团的身影。}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractPoor, "Defended the town against greenskins");
						this.World.Contracts.finishActiveContract();
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
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer%欢迎了你的回归，并奖励了您一箱%reward%克朗。%SPEECH_ON%这是你应得的，佣兵，我非常赞同这点。不幸的是，绿皮怪物们绑走了一些你的手下。我扣除了一些你的报酬，弥补给那些相信你却牺牲了的人。%SPEECH_OFF%他停了下来，发现你正盯着那只箱子。你点了点头，表示理解农民们的困境，同时意识到争吵不会对你的未来发展有任何帮助。 |  你发现%employer%正在喂他的那几条狗。他不停地抚摸着那条正在进食的狗的脑袋。%SPEECH_ON%我真的想过放弃。%SPEECH_OFF%他最后抚摸了一下狗，然后抬头看向你。%SPEECH_ON%但我们并不是所有人都活了下来。你的奖励就放在角落，但要比我们说好的少一些。我必须弥补那些牺牲者，我相信你一定能对此表示理解。%SPEECH_OFF%  |  %employer%\'招来了一群男人和女人站在了他的周围。当你走进房间时，他们诡异地一齐转向了你。%employer%正在发给他们克朗。他一边发，一边跟你交谈起来。%SPEECH_ON%你的报酬放在外面我的一位守卫处。报酬不会多，因为我得取出一部分去弥补那些在战斗中牺牲的人。%SPEECH_OFF%你瞥了一眼那些逗留在房间中的可怜人们。他们一定是被那群绿皮怪物掳走的人的亲友。 |  当你回来时，%employer%正在看向窗外。外面，民兵们不停地来回奔波着，而居民们正拥抱着彼此。%SPEECH_ON%虽然城镇幸免于难，但我必须很遗憾地告诉你，接下来几天路上的行人会更少了。%SPEECH_OFF%他笑着递过一包物品，似乎比说好的要轻上许多。%SPEECH_ON%这些是你应得的，佣兵。但并不是所有人都幸存了下来。那些被绿皮怪物抓走的人身后还有家庭，而我必须在这可怕的日子里照顾那些家庭。%SPEECH_OFF%  |  你发现%employer%并不是很轻松：整个小镇都因庆祝而骚动了起来。人们迅速地给鸟禽拔着毛，而其中有些鸟禽试图逃离此处，披着散乱的毛在大街上乱跑，而小孩子们也争相追逐着它们。庆典中%employer%偷偷靠近了你。那家伙递过一个装着物品的袋子，放在了你的手中。%SPEECH_ON%并不是所有人都那么开心，佣兵。比如那些你没能拯救的可怜的被绑架者？他们身后还有家庭，而我从你的报酬中抽取了一部分用来照顾他们。我相信你能理解这点的。%SPEECH_OFF%  |  你发现%employer%正在整理一个书架。他似乎在补充商品，像一位店主一样在仔细计算着自己的货物。他被你身后门关上的声音吓得跳了起来。%SPEECH_ON%啊，佣兵！你吓到我了。%SPEECH_OFF%他从其中一个书橱上拿下了一个箱子，然后将它交给了你%SPEECH_ON%我本打算带上这些书和卷轴逃跑呢。现在，多亏了你，我就不用那么做了。%SPEECH_OFF%他笑了一下%SPEECH_ON%不过并不是所有人能幸运地看到这天。当地人告诉了我，那些绿皮怪物绑走了一些我们的人，而你没能救下他们。我不是在责怪你，但是我相信你能理解我得从你的报酬中抽出一部分，用来照顾他们的家人。%SPEECH_OFF%}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractPoor, "Defended the town against greenskins");
						this.World.Contracts.finishActiveContract();
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
			Text = "[img]gfx/ui/events/event_30.png[/img]{%employer%欢迎你的归来，不过给你的报酬比预想的要少。他解释道。%SPEECH_ON%小镇的边缘地带几乎被毁掉了，而且有很多人被那些怪物给掳走了。我很抱歉，佣兵，但我需要钱来修整这个小镇。如果你想的话可以威胁我，但事实就是如此。%SPEECH_OFF%你决定接受这样的结果。 |  你发现%employer%正在调查小镇。郊区的一些地方燃烧着火焰，黑色的烟雾飘向了天空。疲劳的农民们费力地行走在道路上。他们尽力带上了自己的物资，有些人还搀着一些身受重伤的人。%employer%朝这样的情景点了点头。%SPEECH_ON%这场战斗造成了很大的破坏，佣兵。你我都清楚我给你报酬是为了拯救这个小镇，保护这些人的安全。虽然你并没有完全做到，但至少我们现在安然无恙，所以你仍能拿到一部分奖励。%SPEECH_OFF%他递给你一袋克朗。的确，这数量比说好的要少上许多，但为了以后的发展，你并不想对此再做什么争论。 |  %employer%正看向他的窗外。他一手拿着卷轴，一手拿着笔，正在做着记录。他没有抬起头，而与你交谈起来。%SPEECH_ON%唔，起码我们还活着，这点很不错。不好的是，火灾肆虐着我们的郊区，而且那群绿皮怪物还掳走了一些居民。%SPEECH_OFF%最后，他放下了笔，慢慢抬起头看向你。%SPEECH_ON%你的报酬放在大厅里。比你预期的要少。如果你对此有什么意见，我愿意倾听。%SPEECH_OFF%你明白多说无益，拿着报酬离开了。}",
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
			Text = "[img]gfx/ui/events/event_30.png[/img]{当你走进%employer%房间时，他让你关上身后的门。门闩的声音刚落下，那人就扑头盖脸地向你道出污言秽语，你几乎都反应不过来。他的语气逐渐平静，而措辞也恢复常态。%SPEECH_ON%外围被摧毁地精光。你觉得我雇佣你到底是干嘛的？滚。%SPEECH_OFF%  |  当你进来时，%employer%猛地甩开酒杯。窗户外满是喧闹的生气农夫。%SPEECH_ON%听到了吗？雇佣兵，要是我付你钱，他们就要我的脑袋了。你只有一个任务，一个！保护这座镇子。而你还没有做到。现在还有件事你能做到，而且还是免费的：滚出我的视线。%SPEECH_OFF%  |  %employer%拍向桌子。%SPEECH_ON% 你还回来了，你在期待什么？真是让我惊讶。小镇一半着火了，而另一半已经化为了灰烬。雇佣兵，雇佣你不是让你产生硝烟和荒芜的。赶紧给我离开这里。%SPEECH_OFF%  |  当你回去找%employer%时，他手中正拿着一杯麦芽酒。手微微摇动着。脸色酡红。%SPEECH_ON% 我费了好大劲儿才克制住不将这玩意泼向你的脸。 %SPEECH_OFF% 以防万一，他一大口将酒喝光了。然后砸向桌子。%SPEECH_ON% 整个镇子都期待你能保护他们。但是强盗蜂拥而至外围，他妈的就像观光度假一样！雇佣兵，我做生意又不是为了让那群绿皮怪物好好享乐摧毁我的镇子的。赶紧给我滚！%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{这个该死的乡巴佬！ |  我们应该提前多要点报酬…… |  妈的！}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to defend the town against greenskins");
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
			Text = "[img]gfx/ui/events/event_30.png[/img]{找不到%employer%。 一名卫兵向你走来。%SPEECH_ON% 如果你在找老板，那最好还是放弃吧。镇子大半都被毁了，他正在想法子处理。%SPEECH_OFF% 你询问酬金的事。那人爆发出阴郁，粗野的大笑。%SPEECH_ON%酬金？抱歉，雇佣兵渣滓。没办好事，他才不会付钱。总之那笔钱会用在镇子上。%SPEECH_OFF%  |  你在%townname%废墟中寻找%employer%。找到了，他正在从冒着烟的房屋废墟中搬出尸体。他将一具烧焦的尸体放在脚下，眼神锐利如剑般地盯着你。%SPEECH_ON% 雇佣兵，你想干嘛？可别说酬金的事，因为这糟糕的结果我可不会付钱的。%SPEECH_OFF%  |  发现%employer%时，他正看着窗外。远方是一片火海，犹如两轮烈日当空。看到你时，他摇摇头。%SPEECH_ON% 该死，你在这干嘛？咱们的协定是付钱让这座小镇化为灰烬？雇佣兵，好像不是这样的吧。你走吧。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{这个该死的乡巴佬！ |  我们应该提前多要点报酬…… |  妈的！}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to defend the town against greenskins");
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
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/greenskins_situation"));
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

		if (this.m.Home != null && !this.m.Home.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Home.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(4);
			}
		}
	}

	function onIsValid()
	{
		local nearestOrcs = this.getNearestLocationTo(this.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getSettlements());
		local nearestGoblins = this.getNearestLocationTo(this.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getSettlements());

		if (nearestOrcs.getTile().getDistanceTo(this.m.Home.getTile()) > 20 && nearestGoblins.getTile().getDistanceTo(this.m.Home.getTile()) > 20)
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

