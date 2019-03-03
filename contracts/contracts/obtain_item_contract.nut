this.obtain_item_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		RiskItem = null,
		IsPlayerAttacking = false
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.obtain_item";
		this.m.Name = "获得遗物";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		local camp = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getNearestSettlement(this.m.Home.getTile());
		this.m.Destination = this.WeakTableRef(camp);
		this.m.Flags.set("DestinationName", camp.getName());
		local items = [
			"Fingerbone of Sir Gerhardt",
			"Blood Vial of the Holy Mother",
			"Shroud of the Founder",
			"Elderstone",
			"Staff of Foresight",
			"Seal of the Sun",
			"Starmap Disc",
			"Forefathers\' Scroll",
			"Petrified Almanach",
			"Coat of Sir Istvan",
			"Staff of Golden Harvests",
			"Prophet\'s Pamphlets",
			"Forefathers\' Standard",
			"Seal of the False King",
			"Flute of the Debaucher",
			"Dice of Destiny",
			"Fetish of Fertility"
		];
		this.m.Flags.set("ItemName", items[this.Math.rand(0, items.len() - 1)]);
		this.m.Payment.Pool = 500 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

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
					"在%location%获得%item%"
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
				this.Contract.m.Destination.clearTroops();
				this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.UndeadArmy, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.setLootScaleBasedOnResources(100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());

				if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Destination.getTags().get("IsEventLocation"))
				{
					this.Contract.m.Destination.getLoot().clear();
				}

				this.Contract.m.Destination.setDiscovered(true);
				this.Contract.m.Destination.m.IsShowingDefenders = false;
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
				local r = this.Math.rand(1, 100);

				if (r <= 10)
				{
					this.Flags.set("IsRiskReward", true);
					local i = this.Math.rand(1, 6);
					local item;

					if (i == 1)
					{
						item = this.new("scripts/items/weapons/ancient/ancient_sword");
					}
					else if (i == 2)
					{
						item = this.new("scripts/items/weapons/ancient/bladed_pike");
					}
					else if (i == 3)
					{
						item = this.new("scripts/items/weapons/ancient/crypt_cleaver");
					}
					else if (i == 4)
					{
						item = this.new("scripts/items/weapons/ancient/khopesh");
					}
					else if (i == 5)
					{
						item = this.new("scripts/items/weapons/ancient/rhomphaia");
					}
					else if (i == 6)
					{
						item = this.new("scripts/items/weapons/ancient/warscythe");
					}

					this.Contract.m.RiskItem = item;
				}

				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"在%origin%%direction%的%location%获得%item%"
				];

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.m.IsShowingDefenders = false;
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onDestinationAttacked.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Destination == null || this.Contract.m.Destination.isNull())
				{
					if (this.Flags.get("IsRiskReward"))
					{
						this.Contract.setState("Return");
					}
					else
					{
						this.Contract.setScreen("LocationDestroyed");
						this.World.Contracts.showActiveContract();
					}
				}
				else if (this.TempFlags.get("GotTheItem"))
				{
					this.Contract.setState("Return");
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;

				if (!this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("IsAttackDialogTriggered", true);

					if (this.Flags.get("IsRiskReward"))
					{
						this.Contract.setScreen("RiskReward");
					}
					else
					{
						this.Contract.setScreen("SearchingTheLocation");
					}

					this.World.Contracts.showActiveContract();
				}
				else
				{
					local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					properties.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
					properties.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
					properties.EnemyBanners.push(this.Contract.m.Destination.getBanner());
					this.World.Contracts.startScriptedCombat(properties, _isPlayerAttacking, true, true);
				}
			}

			function end()
			{
				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull() && this.Contract.m.Destination.isAlive())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(null);
					this.Contract.m.Destination = null;
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
					if (this.Flags.get("IsFailure"))
					{
						this.Contract.setScreen("Failure1");
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
			Text = "{[img]gfx/ui/events/event_43.png[/img]%employer%欢迎你并送你到%townname%广场。那里有一个农民聚会，但当他们看到你时他们的样子和说话的口气仿佛是一直在等你。他们大多数用叙述语交谈：和任何人一样高！穿戴的护甲是你从未见过的！矛跟小贩的嘴一样锋利！你举起手然后询问他们在说些什么。%employer%笑了。%SPEECH_ON%这的人说他们在这的%direction%一个叫%location%的地方看到了些奇怪的东西。通常，他们不会无缘无故去到那里。他们在找叫做%item%的东西，那是一种对小镇很重要的遗物，人们通过它来祈求食物和庇护。%SPEECH_OFF%其中一位农民开口道。%SPEECH_ON%我们也是在他的授意下找寻那样物件的！%SPEECH_OFF%%employer%点点头。%SPEECH_ON%当然了。但他们没有找到，或许你能继续他们的事业？为我找到这种遗物，我会付给你一大笔报酬。对他们的童话故事没有兴趣。我敢肯定没什么好担心的。%SPEECH_OFF%  |  [img]gfx/ui/events/event_62.png[/img]%employer%欢迎你进他的房间然后给你倒了一杯水。他羞怯地笑着递过杯子。%SPEECH_ON%要有酒我肯定用酒招待你，但你也知道现在的情况。%SPEECH_OFF%他抿了一口然后清了清嗓子。%SPEECH_ON%当然了，我唯一不缺的就是钱，否则我们也没必要谈了，对吧？我要去去到那个叫做%location%的地方，那就在这的%direction%，然后取回叫做%item%的遗物。相当简单，不是吗？%SPEECH_OFF%你询问遗物有什么用。男人解释道。%SPEECH_ON%居民向其祈祷。他们透过它获得安宁，求雨，草山羊什么的，我也不管。他们对其有信仰然后让他们保持上进心。光哪一点就足够了%SPEECH_OFF%  |  [img]gfx/ui/events/event_62.png[/img]你走进%employer%的房间发现那个男人盯着腹地的一幅地图。他摇了摇头。%SPEECH_OFF%看到那边那个地方了吗？那是%location%。%townname%过去曾信奉叫%item%的遗物，但居民说它消失了，好吧，不知出于什么原因他们认为它在那。我没人能雇佣和查看，因为道路太危险了而我也承受不起失败，但佣兵你，似乎可以胜任这项任务。你能去那里找到%item%吗？SPEECH_OFF%  |  [img]gfx/ui/events/event_43.png[/img]你发现%employer%在跟一群农民讲话。看到你后，他让所有人都安静。%SPEECH_ON%嘘嘘，所有人都安静。这里这个人能解决我们的问题。%SPEECH_OFF%居民把你带到一边。%SPEECH_ON%佣兵，我们有点麻烦。我得找个遗物，某种叫%item%的东西。我其实并不真的在乎，但这些人信奉他祈求春雨和冬天的庇护。自然地，它消失了。不知出于何种原因人们认为他消失了现在自己跑到一个叫做%location%的地方。没人愿意去那里，但是你会去的，对吗？当然了，价钱要合适。%SPEECH_OFF%  |  [img]gfx/ui/events/event_62.png[/img]你发现%employer%在和一个身穿宽大斗篷的督伊德教和尚。角作头盔，熊皮作护甲，鹿蹄在胸前的项链上晃荡。他真是耀眼。%employer%看到你，招呼你进来。%SPEECH_ON%佣兵！很高兴见到你——%SPEECH_OFF%德鲁伊在谈话中把男人推到一边。他声音颤抖地跟你讲话，好像是从洞穴深处传出似得。%SPEECH_ON%佣兵，哈！显然你是有信仰的人了，不是吗？我们%townname%掉了样%item%。这件遗物对我们非常重要，因为我们是透过它与古神对话，回应我们的祈祷。它被偷走了，用某种办法，到了%location%。去那里将其取回来。%SPEECH_OFF%你看了眼点头的%employer%。%SPEECH_ON%对的，就是他说的那样。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{你能来找到我们是做对了。我们来安坦报酬吧。 |  那就来谈谈价钱吧。 |  听起来很简单。报酬有多少？}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{没兴趣。 | 你还有更重要的事情要处理。 |  你肯定还能找到其他人来做这事的。}",
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
			ID = "SearchingTheLocation",
			Title = "%location%",
			Text = "[img]gfx/ui/events/event_73.png[/img]{你没怎么进到废墟，只是像一只想往上爬的蝙蝠一样蹒跚过石料。来到斜坡底部，你发现数以百计的黏土灌和古老的战车比木头还多，金属水盆里塞满了锈迹斑驳的盾牌和长矛。%randombrother%拿了一根火炬并照着墙壁。巨幅壁画延伸其上，那是你从未听闻的描绘战场的伟大艺术作品。每走一步都似乎揭露出另一场古代胜利，直到最终，你来到了一副巨大的地图画前。你在那看到一片由一个帝国统治的大陆，中部镀金，边界则涂黑了。\n\n %randombrother%手握%item%走过。你点点头并告诉他该走了。当你俩转身时，有个人一手持矛一手持盾站在那里。随后另一个人加入了他，然后又一个，他们的脚步撞击着石制地面。你朝佣兵大喊着叫他走，而你俩都很快逃离废墟，死神在后面追赶。\n\n 你转到外面然后下令手下准备战斗。在第一个佣兵还没来得及抽出剑前，一群全副武装的士兵从废墟中冒出来，开始列阵，然后将矛头指向你。他们的中尉用腐烂的手指指着，然后用一种细碎在胸腔深处的声音开口道。%SPEECH_ON%帝国崛起。伪王必须死。%SPEECH_OFF%  |  通往废墟的洞只够大到供一人穿过。你担心所有人都挤在一块堵牢洞口那你就得像在隧道中杀老鼠一样杀%companyname%了。相反地，你只派了%randombrother%，谁知道他有什么目的，而你所相信能照顾自己的人什么都可能发生。\n\n 几分钟后你听到他挣扎着爬出来——声音相当匆忙。他大喊着呼救，而你和其他雇佣兵们则将手伸入洞中。他抓住了你们的手，然后你们一起将他拉了出来。他拿到了%item%，但表情非常恐惧。他转过身然后匆忙起身。%SPEECH_ON%快！拿起武器！%SPEECH_OFF%当雇佣兵们看进洞中看是否有其他东西跟出来时，你询问这位兄弟到底看到了什么。他摇了摇头。%SPEECH_ON%不知道，长官。那是我从未见过的人的陵墓。到处都是护甲和长矛，以及覆盖整个世界的伟大帝国的壁画！从地面到天花板！还有……然后他们开始从墙壁上走下来。我尽最快速度离开那儿然后……%SPEECH_OFF%他还没说完，洞中的碎石开始变形移动。飞沙卷石，然后突然间都往外冲，一股邪恶力量站在那——身负铠甲还有一群全副武装，持矛持盾的列队士兵迈着整齐的步伐缓慢前进。他们的领袖直指向你。%SPEECH_ON%帝国崛起。伪王必须死。%SPEECH_OFF%你从未听过的战斗言语并立即让你的人准备作战。 |  你带着%randombrother%冒险闯入废墟。%item%很容易找，说起来有点太容易了，但其他东西吸引了你的注意。石制地面上散落着瓶罐。每一块陶器都是放置长矛的容器，而护盾则挂在墙壁的挂钩上，似乎太过年老和锈迹斑驳以至于连蜘蛛网都挂不住。突然间，%randombrother%抓住你的手。%SPEECH_ON%长官。有麻烦了。%SPEECH_OFF%他指向大厅，你看到有个人站在那里，他的行动迅速，仿佛要从盔甲中冲破出来。突然间，他抬起头盯着你。尽管他站的很远，他的声音仿佛就在你耳边。%SPEECH_ON%伪王胆敢入侵这里？帝国将会再次崛起，但首先你必须死。%SPEECH_OFF%这些无疑是战斗宣言，而你抓着佣兵然后快速逃离。没跑出多远雇佣兵就立即抽出武器：跟在你后面是一群你从未见过的士兵队列。他们像龟壳一样列队向前，他们将盾牌举在一起来为全体单位提供保护。基于废墟中同伴的情况，你确信无疑他们是来杀你和整个战团的！ |  你进入废墟轻而易举地找到了%item%。当你转身时，一个身着锈迹盔甲的高个男子站在那里，手持长矛盯着你。他挥着长矛。%SPEECH_ON%伪王必须死。%SPEECH_OFF%长矛刺向前。%randombrother%跳起来将其打向地面，矛尖爆裂落下几块火星落到地面上。你看向这个不死者，一只虫子从他的鼻孔中爬出。它又开口了。%SPEECH_ON%伪王必须……%SPEECH_OFF%你快速抽剑，砍掉了远古尸体的脑袋。头骨和其上的头盔发出哗啦啦的响声然后掉落在地上。在你还没来得及调查，%randombrother%抓着你然后叫你逃跑：更多的不死者正在从墙内出现，摆脱陵墓埋葬的控制。\n\n 一旦来到外面，你立即下令剩下的战团列阵。 |  你派了一些人进入废墟找寻%item%。他们很快返回，这很反常，因为他们平日最好偷懒磨洋工。还好，他们中有一个人手上拿着遗物。不幸的是，他们看着像是见了鬼一样。他们不需要解释恐惧来源因为一群蹦跳着、盔甲叮当作响的不死者正从废墟中冒出来并将矛头指向了战团。 |  到达废墟后，你原想着会有一些强盗。相反的是，取回%item%简直轻而易举。至少，你是这么认为的，直到一群全副武装大喊着“伪王”并意欲取你头颅的不死者冒出来。准备迎战！ |  找到并装好%item%比预想的要简单得多。找到一群不死者身穿锈迹斑驳的护甲并手持长矛，排列紧密阵型，他们比这个国度薪水最高的军队还要有素……始料未及。准备迎战！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.TempFlags.set("GotTheItem", true);
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination, false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "LocationDestroyed",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_46.png[/img]{战斗结束而且也得到了%item%，你告诉人们准备回去找%employer%。虽然尚不能完全确认攻击你们的东西或人，但是是时候领赏了。 |  战斗结束了，你看了看攻击者。他们身着你不认识的盔甲。%randombrother%尝试扒下其中一具尸体的头盔，但是完全是徒劳。他怀疑地看着尸体。%SPEECH_ON%就像是黏住了一样，或者已经浑然一体了。%SPEECH_OFF%你让手下们整顿下，准备回去找%employer%了。无论这些人是什么身份，反正你得到%item%的任务已经完成了。现在该回去领赏了。 |  你得到了%item%，但代价是遇到了从未见过的邪恶。身着护甲，虽然看上去死了，但却仍阵型紧密的行动着。%randombrother%举起%item%，不知道接着该怎么做。你说该回去找%employer%了。 |  你看了看%item%，那些人就是因为这个攻击你的。至少你是这么觉得的。虽然敌军队长似乎说了些什么，但是你不记得了。好了，该回去找%employer%领赏了。 |  发生的事情让你完全摸不着头脑。%randombrother%询问你是否知道他们说了些什么。%SPEECH_ON%长官，似乎他们的目标是你。%SPEECH_OFF%你点点头，说自己不太确定身着盔甲的人说了些什么，但是无关紧要。%item%已经到手了，该回去找%employer%领赏了。 |  虽然%item%到手了，但代价是什么呢？奇怪的人，如果他们还能被叫做人的话，攻击了你的战团而且你绝对其中一人指出了你，仿佛你犯下了某种超越时空的罪恶。好吧。你不是那种会纠结这些事情的人。你来此的目的是遗物，而如今已经拿到手了，该回去找%employer%领赏了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "咱们回去吧。",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "RiskReward",
			Title = "%location%",
			Text = "[img]gfx/ui/events/event_57.png[/img]{你走进%location%，环顾四周。不一会儿，%randombrother%指向%item%，那遗物就在石台上，上面布满了苔藓和蜘蛛网。他也指了指房间另一边的某个东西：高大的雕像上装饰着十分好看的%risk%。\n\n其他地方看起来破败不堪，似乎随时就会倒塌。%risk%的效果令人生疑。 |  %item%看似很普通，但是房间里有样东西吸引了你的注意力。巨大雕像的旁边有一个奇特的%risk%。当然，那么问题就来了，这玩意到底在这干嘛的？虽然你心中所想的是拿走这东西，但理智告诉你可能这样做并非明智。 |  好吧，你找到了%item%。比想象中的简单。但是还有个东西。你发现一座高达人像上装饰着熠熠闪光的%risk%。那东西就在那里，虽然你不太确定有这么个东西的雕像有什么用。那么问题就来了，为什么？ |  虽然轻轻松松就找到了%item%，但是正当你准备拿走城镇居民的遗物时，你发现了高大的不详人像，上面装饰着散发着光芒的%risk%。心头冒出的第一个想法就是派一名雇佣兵去拿走那玩意，但突然你心头满是对这玩意为什么在这的疑惑。}或许%companyname%就应该执行本来的任务？",
			Image = "",
			List = [],
			Options = [
				{
					Text = "只拿走%item%。",
					function getResult()
					{
						return "TakeJustItem";
					}

				},
				{
					Text = "既然都来了，那么也拿走%risk%吧。",
					function getResult()
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "TakeRiskItemBad";
						}
						else
						{
							return "TakeRiskItemGood";
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TakeJustItem",
			Title = "%location%",
			Text = "[img]gfx/ui/events/event_57.png[/img]%employer%让你取回%item%，这也正是你要做的。%randombrother%同意这方法。%SPEECH_ON%我觉得我们该不去管%risk%。这陷阱真是太显而易见了。%SPEECH_OFF%  |  %randombrother%摇着头，嘲笑你的犹豫不决。%SPEECH_ON%你竟然害怕一尊大雕像？长官，还以为你胆子大得很呢。%SPEECH_OFF%  |  你取走遗物后，%randombrother%用手肘捅了捅你。%SPEECH_ON%某人竟然害怕大雕像啊？拜托，就让我去拿走那玩意吧。拿完就跑，很快的！%SPEECH_OFF%你善意的提醒雇佣兵谁才是老大，以免他又随便开玩笑。 |  遗物已经到手了，%randombrother%点点头。%SPEECH_ON%长官，不错啊。咱们还是别管%risk%了。那亮闪闪的东西就是个麻烦。这样做无异于傻瓜在大海中追求美女！%SPEECH_OFF%  |  %randombrother%盯着%risk%吐了口唾沫，清了清嗓子，用手搓了搓凌乱的脸。%SPEECH_ON%是啊。咱们就别管那玩意了吧。要是在森林中发现一堆黄金，我估计会再三考虑。这里也是一样。%SPEECH_OFF%  |  %randombrother%同意你的决定。%SPEECH_ON%没错，咱们就别管%risk%了。世界上的所有东西都是有代价的。而且那玩意还亮闪闪的，那代价就更别说了。长官，算了吧。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "已经够简单了。",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "TakeRiskItemGood",
			Title = "%location%",
			Text = "[img]gfx/ui/events/event_57.png[/img]{已经搞到%item%了，要不%risk%也拿走吧。%randombrother%走向前，小心翼翼地从雕像上取下那玩意。那玩意松动后，佣兵停了下来，摆出了战斗的姿势，还以为那雕像会活过来一样。但是，什么都没发生。他紧张地笑了起来。%SPEECH_ON%小菜一碟啊！%SPEECH_OFF%人们都松了口气，你告诉大伙儿准备回去找%employer%了。 |  你得到了%item%，看了看%risk%，心想要不一起都拿走算了。你爬上雕像，盯着它的脸部。无论身份如何，他们有着轮廓分明的颧骨和下巴。你目光从其面容挪开，拿走了%risk%，等待会发生的事情。但什么都没发生。%randombrother%大笑。%SPEECH_ON%你要‘欢迎’雕像吗？%SPEECH_OFF%你拍了拍雕像头部，然后爬了下来。战团该回去找%employer%了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "已经够简单了。",
					function getResult()
					{
						this.Contract.m.RiskItem = null;
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				this.World.Assets.getStash().add(this.Contract.m.RiskItem);
				this.List.push({
					id = 10,
					icon = "ui/items/" + this.Contract.m.RiskItem.getIcon(),
					text = "你获得了" + this.Contract.m.RiskItem.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "TakeRiskItemBad",
			Title = "%location%",
			Text = "[img]gfx/ui/events/event_73.png[/img]{你让%randombrother%爬上雕像取走%risk%。佣兵在雕像上的时候，你发现%employer%丢失的小玩意在石台上颤颤巍巍的。你伸出手，试图稳住它，但毫无作用，反而像灰尘般在你指尖散开了。粉末在你胳膊处涌动，仿佛烟雾构成的蛇。你跳开了，而那烟朝雕像射去，径直进入眼部，而后散发着明亮的红光。石头破裂，开始粉碎。佣兵跳开了。附近墙壁上浮现了奇怪的形状，雕像破碎而诞生了这些身披盔甲的奇怪之人，并且肩膀上还有着长矛。\n\n 你命令所有人准备战斗！ |  %risk%这样的东西怎么能拒绝。你爬上雕像想去取走，但是手指刚碰到金属，耳边就传来了隆隆声，而且雕像开始颤抖。%randombrother%大喊大叫，而你转过头。他指向%item%，那玩意在你眼前分解了！它变成了粉末，而你只能看到一缕如有生命般的烟雾，在房间中飘荡着，而后迅速绕过你的脸，进入雕像的鼻子内。雕像眼睛散发出红光，你立马就跳开了。一名佣兵来到你身边，手中就握着武器。%SPEECH_ON%长官，长官！看！%SPEECH_OFF%墙壁上浮现了不少形状。雕像蹒跚向前走着，就像老人指尖控制下的提线木偶。每座雕像慢慢地摆脱了石头外壳，最终呈现为披甲持矛的奇怪之人。你迅速命令佣兵们准备战斗，无论这些玩意是什么，肯定不是什么好玩意！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Rally!",
					function getResult()
					{
						this.Contract.m.RiskItem = null;
						this.Flags.set("IsFailure", true);
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination, false);
						return 0;
					}

				}
			],
			function start()
			{
				this.World.Assets.getStash().add(this.Contract.m.RiskItem);
				this.List.push({
					id = 10,
					icon = "ui/items/" + this.Contract.m.RiskItem.getIcon(),
					text = "你获得了" + this.Contract.m.RiskItem.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer%与你在城镇中心见面。你交出了%item%，而他捧在怀里，仿佛丢失许久的婴儿。片刻尴尬时刻后，他举起遗物，让居民们都看看。他们欢呼不已。说真的，欢呼了好久。你不得不用手肘捅了捅%employer%，提醒他别忘了赏金。 |  你发现%employer%在猪舍里闲逛着。他踹了踹附近的肥猪，但是猪毫不在意，仍然全神贯注地吃着饲料。你清了清嗓子。%employer%转过身，看到遗物时，仿佛眼睛都发光了。他跳过一头猪，拿走了%item%。他朝附近的居民大喊大叫，并且感谢神明的慈悲。自然而然地，没有一个人感谢你。你不得不提醒%employer%别忘了许诺的克朗。钱拿到手后，你迅速离开了。 |  你发现%employer%正在城镇中心，双臂伸向天空，双眼紧闭，嘴中还咕哝着祷告词。居民都在他身边，双膝下跪，做着同样的事情。你捡起一块石头，向风向标扔去。哐当声和锈蚀的旋转声引起了所有人的注意。\n\n你举起遗物以便所有人都能看到。%employer%跳了起来，拿走了%item%。人们都愉悦地大喊大叫，都说好事来了。酬劳拿到手了，你心想：这的确是个好事。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "如今居民们似乎都很有精神劲儿。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Obtained " + this.Flags.get("ItemName"));
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
				local reward = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + reward + "[/color] 克朗"
				});
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/high_spirits_situation"), 3, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_43.png[/img]{%townname%居民都焦急地等待你的回归。可惜啊，因为你没能取回他们迫切需要的遗物。%employer%与你在入口处见面，低声和你说道。%SPEECH_ON%看来你没能得到%item%。%SPEECH_OFF%你极力解释发生的事情，但他似乎全然没听。%SPEECH_ON%无关紧要，雇佣兵。显然我不能给你钱，而居民也不会在乎你的缺点，除非他们都失心疯了。他们依赖神像在这个世界上找到慰藉。我不得不采取自己的方法了，祈祷会奏效的。祝你一天愉快。%SPEECH_OFF%  |  %employer%与你见面了，旁边还有一大群鹅。他十分随意的撒着饲料，一个男孩时不时地会跑过来抓走一只，然后送去屠宰。看到你，他脸上露出了热情的笑容，但激动之色很快就消失了。%SPEECH_ON%我没看到遗物。看到你没搞到手？%SPEECH_OFF%你只能点点头。你敞开双臂，似乎十分疑惑。%SPEECH_ON%那你来干嘛？居民们都认识你。他们知道你去寻找那东西了。趁他们还没发现你没能拿来神像前，你赶紧走吧。%SPEECH_OFF%  |  你空手回到%employer%身边。他拉着你悄悄说道。%SPEECH_ON%你为什么回来了？你难道不明白居民对神像有多期待吗？没有它的话，他们就没有信仰了。信仰强烈之人需要寄托信仰的东西。如果没有这种东西的话，他只能信仰自己。而且，就像盯着镜子的丑陋暴君，我们不想在神像不在的时候目睹到愤怒和疑惑。佣兵，你走吧，趁居民们还没发现你空手而归。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "好吧…",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to obtain " + this.Flags.get("ItemName"));
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
			"location",
			this.m.Flags.get("DestinationName")
		]);
		_vars.push([
			"direction",
			this.m.Destination == null || this.m.Destination.isNull() || !this.m.Destination.isAlive() ? "" : this.Const.Strings.Direction8[this.m.Home.getTile().getDirection8To(this.m.Destination.getTile())]
		]);
		_vars.push([
			"item",
			this.m.Flags.get("ItemName")
		]);
		_vars.push([
			"risk",
			this.m.RiskItem != null ? this.m.RiskItem.getName() : ""
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Destination != null && !this.m.Destination.isNull() && this.m.Destination.isAlive())
			{
				this.m.Destination.getSprite("selection").Visible = false;
				this.m.Destination.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (this.m.IsStarted)
		{
			if (this.m.Destination == null || this.m.Destination.isNull() || !this.m.Destination.isAlive())
			{
				return false;
			}

			return true;
		}
		else
		{
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

		if (this.m.RiskItem != null)
		{
			_out.writeBool(true);
			_out.writeI32(this.m.RiskItem.ClassNameHash);
			this.m.RiskItem.onSerialize(_out);
		}
		else
		{
			_out.writeBool(false);
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

		local hasItem = _in.readBool();

		if (hasItem)
		{
			this.m.RiskItem = this.new(this.IO.scriptFilenameByHash(_in.readI32()));
			this.m.RiskItem.onDeserialize(_in);
		}

		this.contract.onDeserialize(_in);
	}

});

