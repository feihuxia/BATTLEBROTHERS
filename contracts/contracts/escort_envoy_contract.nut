this.escort_envoy_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.escort_envoy";
		this.m.Name = "护送使者";
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

		local settlements = this.World.EntityManager.getSettlements();
		local candidates = [];

		foreach( s in settlements )
		{
			if (s.getID() == this.m.Home.getID())
			{
				continue;
			}

			if (!s.isDiscovered() || s.isMilitary())
			{
				continue;
			}

			if (s.getOwner() == null || s.getOwner().getID() == this.getFaction())
			{
				continue;
			}

			if (s.isIsolated() || !this.m.Home.isConnectedTo(s) || this.m.Home.isCoastal() && s.isCoastal())
			{
				continue;
			}

			candidates.push(s);
		}

		this.m.Destination = this.WeakTableRef(candidates[this.Math.rand(0, candidates.len() - 1)]);
		local distance = this.getDistanceOnRoads(this.m.Home.getTile(), this.m.Destination.getTile());
		this.m.Payment.Pool = this.Math.max(250, distance * 7.0 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult());

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		local titles = [
			"the Envoy",
			"the Emissary"
		];
		this.m.Flags.set("EnvoyName", this.Const.Strings.CharacterNames[this.Math.rand(0, this.Const.Strings.CharacterNames.len() - 1)]);
		this.m.Flags.set("EnvoyTitle", titles[this.Math.rand(0, titles.len() - 1)]);
		this.m.Flags.set("DestinationName", this.m.Destination.getName());
		this.m.Flags.set("Bribe", this.beautifyNumber(this.m.Payment.Pool * this.Math.rand(75, 150) * 0.01));
		this.m.Flags.set("EnemyName", this.m.Destination.getOwner().getName());
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"护送 %envoy% %envoy_title% 到 " + this.Contract.m.Destination.getName() + " 位于 %direction%"
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
					if (this.Contract.getDifficultyMult() >= 1.0)
					{
						this.Flags.set("IsShadyDeal", true);
					}
				}

				local envoy = this.World.getGuestRoster().create("scripts/entity/tactical/humans/envoy");
				envoy.setName(this.Flags.get("EnvoyName"));
				envoy.setTitle(this.Flags.get("EnvoyTitle"));
				envoy.setFaction(1);
				this.Flags.set("EnvoyID", envoy.getID());
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.Destination.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.World.getGuestRoster().getSize() == 0)
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerAt(this.Contract.m.Destination))
				{
					this.Contract.setScreen("Arrival");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsShadyDeal"))
				{
					if (!this.Flags.get("IsShadyDealAnnounced"))
					{
						this.Flags.set("IsShadyDealAnnounced", true);
						this.Contract.setScreen("ShadyCharacter1");
						this.World.Contracts.showActiveContract();
					}
					else if (this.World.State.getPlayer().getTile().HasRoad && this.Math.rand(1, 1000) <= 1)
					{
						local enemiesNearby = false;
						local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);

						foreach( party in parties )
						{
							if (!party.isAlliedWithPlayer)
							{
								enemiesNearby = true;
								break;
							}
						}

						if (!enemiesNearby && this.Contract.getDistanceToNearestSettlement() >= 6)
						{
							this.Contract.setScreen("ShadyCharacter2");
							this.World.Contracts.showActiveContract();
						}
					}
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getID() == this.Flags.get("EnvoyID"))
				{
					this.World.getGuestRoster().clear();
				}
			}

		});
		this.m.States.push({
			ID = "Waiting",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"等待 " + this.Contract.m.Destination.getName() + "直到%envoy% %envoy_title%完事"
				];
				this.Contract.m.Destination.getSprite("selection").Visible = true;
			}

			function update()
			{
				this.World.State.setUseGuests(false);

				if (this.Contract.isPlayerAt(this.Contract.m.Destination) && this.Time.getVirtualTimeF() >= this.Flags.get("WaitUntil"))
				{
					this.Contract.setScreen("Departure");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"护送 %envoy% %envoy_title% 返回 " + this.Contract.m.Home.getName()
				];
				this.Contract.m.Destination.getSprite("selection").Visible = false;
				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				this.World.State.setUseGuests(true);

				if (this.World.getGuestRoster().getSize() == 0)
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					this.Contract.setScreen("Success1");
					this.World.Contracts.showActiveContract();
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getID() == this.Flags.get("EnvoyID"))
				{
					this.World.getGuestRoster().clear();
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
			Text = "[img]gfx/ui/events/event_63.png[/img]{%employer%旁边站了一个男人。当你调整角度之后还是看不清他的脸孔，他做了一样的事情，就是不想让你看见。%SPEECH_ON%拜托，佣兵。这个是 %envoy%。你不需要看清楚他。我只需要你把他弄到%objective%去。他要去那里说服他们加入我们的事业。当然了，%enemynoblehouse%不会同意这事情，所以一定要低调。%SPEECH_OFF%你点了点头，你明白家族之间的尔虞我诈。%SPEECH_ON%很好，佣兵。好了，你感兴趣吗？%SPEECH_OFF%  |  一个男人就像是从%employer%房间的阴影中变了出来一样，朝你走了过来，他伸出了手。你握了握，他开始介绍自己。%SPEECH_ON%卧室受雇于%employer%的%envoy%。我们已经……%SPEECH_OFF%%employer%走了进来。%SPEECH_ON%我需要你把这男人送到%objective%去。那里是%enemynoblehouse%的领地，所以需要一定的隐蔽活动。所以需要你们。你只需要确保这个男人能到那里。然后，把他带回来，你就可以拿走报酬了。那与你的工作经验相符吗？%SPEECH_OFF%  |  %employer%往你胸口扔了一份卷轴。%SPEECH_ON%有一个使者在我门外。他叫做%envoy%，他要去%objective%说服那里的人加入。%SPEECH_OFF%拿走这份卷轴，你询问了最明显的问题：那里是%enemynoblehouse%的领地%employer%点了点头。%SPEECH_ON%是的，那里是的。所以你出现了，而且你不是我的人。没必要引发一场战争，对不对？我只需要你们把%envoy%弄到那里，然后再把他弄回来。如果你感兴趣的话我们可以开始谈数目了，把卷轴交给使者然后就可以出发了。%SPEECH_OFF%  |  看着地图，%employer%问你对政治有没有兴趣。你耸了耸肩，他点了点头。%SPEECH_ON%我也是这么想。好吧，不幸的是，我有一些政治上的事情需要你去做，我需要你去护送一个叫%envoy%的使者。他要去%objective%…………，做一点政治上的事情，说服那里的人加入我们，完全不是什么会让你晚上睡不着的事情。当然了，那里不是我们的领地，所以我要雇佣一个像你这样的不知名的人。实话实话，不是冒犯。%SPEECH_OFF%你挥挥手。%employer%继续说了下去。%SPEECH_ON%好了，如果你感兴趣的话，把这男人弄到那里然后把他弄回来。听上去很简单，是不是?你甚至都不用说一句话！%SPEECH_ON%  |  %employer%研究这一份地图，基本上是再看他与%enemynoblehouse%之间表示边境的颜色。他将拳头砸在了他们那边的领土。%SPEECH_ON%好了，佣兵。我需要一些壮士去护送%envoy%，他是我的使者。他要去%objective%，如果你懂政治形势的话就知道那里不在我的掌控之下。%SPEECH_OFF%你点了点头，让贵族知道你理解他的意思。%SPEECH_ON%你把他弄过去，等他演讲完，你把他送回来。你就只是一个跟着他转悠的无主保镖，懂了吗？所以如果你感兴趣的话我们就来谈一下报酬。%SPEECH_OFF%  |  %employer%将一张皱巴巴的纸头扔在他的桌子上，很明显是写满坏消息的卷轴。%SPEECH_ON%我女儿要出嫁了，但是我没有足够的纳税地来给他们举办庆典。%SPEECH_OFF%你一点也不关心这事情，你暗示那男人直接说重点。%SPEECH_ON%好吧，好吧。直截了当，我需要你护送我的一个使者%envoy%，到%objective%。他回去那里说服人们加入我们的阵营。因为那小地方是%enemynoblehouse%的零度，所以最好假定他们看见我们进入肯定不会开心。所以我要雇你，无名佣兵，去照顾我的使者。%SPEECH_OFF%男人将手放在了膝盖上。%SPEECH_ON%这小小的赌局有勾起你的兴趣吗?你要做的就是送他来回而已。轻轻松松拿钱，轻轻松松！%SPEECH_OFF%  |  读着卷轴，%employer%突然笑了起来，无法自制。%SPEECH_ON%好消息，佣兵！%enemynoblehouse%的人们不再接受他们的统治了！%SPEECH_OFF%你抬起了一边眉毛，滑稽地点了点头。从凳子跳到了桌子上，男人摊开了一张地图，继续说着。%SPEECH_ON%更好的消息是我现在有一个叫%envoy%的使者要去%objective%做点……演讲。当然了，前路漫漫，满是盗贼，和更可恶的%enemynoblehouse%领主们，所以这男人需要保护！然后就需要你了。你要做的就只是把他送过去然后再带回来。%SPEECH_OFF%  |  %employer%旁边站了一个男人。他握了握你的手，介绍自己是个使者，叫%envoy%。你询问这男人的目的，%employer%立即解释起来。%SPEECH_ON%他要去%objective% -%enemynoblehouse%的领土。我们有可能可以说服那里的人们加入我们的阵营。现在你已经了解这个人和他的任务，你肯定明白为什么你会在这里而不是我的人了吧。\n\n我不要你把这个男人弄到%objective%去然后，等他弄完事情以后，把他带回来。之后，你拿报酬。做吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{咱们谈谈价格吧。 | 这事对你值多少？ | 报酬多少？}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{你得另寻帮手了。 |  我们不接这样的活儿。}",
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
			ID = "Arrival",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_20.png[/img]{你到达了%objective%。%envoy_title%%envoy%走进了一幢建筑中，静静地关上了背后的大门。你靠在墙边，等着他。几个农名走过。鸟儿在鸣叫。你有段时间没注意到他们唱歌了。\n\n看来得花点时间。或许你该趁此为回去的路上准备点补给？ | 使者进入到%objective%的议会大楼。你将他安全送达，现在剩下的就交给他了。你一度靠在窗户上倾听着谈话。那人巧舌如簧，召集所有人投身于自己的大业中，这点可比你这些雇佣兵做的好多了。大使透过窗户看到你，微微挥手示意你离开。你躲开等他完事。 | 数名穿着讲究的人欢迎你来到%objective%。他们询问%envoy%%envoy_title%是否和你在一起。他点头与议员迅速低语几句。他们都点点头，然后很快所有人都进入了当地的酒馆。你在外面等着。或许你该趁此为回去的路上准备点补给？ | %employer%怀疑%objective%会致力于他的视野得到了证实：外面街上已经聚集了一大群人。一排卫兵站在一幢大型建筑外，用长矛将人群推回。一名富人探出窗户试图用话语让人群散开，但是满腔愤怒已经让他们充耳不闻。%envoy%轻松从人群溜出，与几名穿着斗篷的议员见面。他们溜进附近的建筑物内，而你在外等着。 | %objective%看起来很沮丧—街上都是农民，要么怒气冲冲，要么无所事事。这都不是健康社区的好兆头。%envoy%  %envoy_title%走进当地酒馆，那儿挤作一团的人谨慎地迎接他。他挥手示意你离开，因此你在外面等他完事。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "{别花太长时间。 |  我们会在附近。}",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.World.getGuestRoster().get(0).getImagePath());
				this.Flags.set("WaitUntil", this.Time.getVirtualTimeF() + this.Math.rand(20, 60) * 1.0);
				this.Contract.setState("Waiting");
			}

		});
		this.m.Screens.push({
			ID = "Departure",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_20.png[/img]{使者一会儿就出来了。你询问是否有麻烦了，他说没有。该回去找%employer%了。 | 门打开了，使者也走了出来。他让你带路回家。 | 使者很快就出来了。他说已经完事了，得回去找%employer%了。 | %envoy%急匆匆地回到你身边。他说得尽管回去找%employer%。 | 当使者回来时，他说谈话顺利，而且你得尽快送他去找%employer%。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "{终于，咱们走吧！ | 怎么花了这么久？}",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.World.getGuestRoster().get(0).getImagePath());
				this.Contract.setState("Return");
			}

		});
		this.m.Screens.push({
			ID = "ShadyCharacter1",
			Title = "在%townname%",
			Text = "[img]gfx/ui/events/event_51.png[/img]{正当要离开城镇时，一个身披斗篷的人前来和你谈话。他将脸埋在阴影处，你只能时不时地看到牙齿和尖下巴。%SPEECH_ON%雇佣兵，当时机来临时，你能做出其他选择吗？%SPEECH_OFF%还没回答，他就不见了。 | 当准备离开时，一个人撞到了你。他并没有道歉，反而躲在在长长的黑色斗篷中凝视着。%SPEECH_ON%做出决定的时刻终将来临。留下战斗，或者离开，这样还能看到明天的太阳。第二个选择将为你带来黄金，而第一个选择只会有一把铲子等着你…%SPEECH_OFF%你伸手去抓那人，但是他闪身后退，恰好融入一群路过的平民之中。 | 当你准备离开%townname%时，一个身着黑色斗篷的人来到你面前。他眼睛没有看着你，只是说着话。%SPEECH_ON%我的雇主在等着你。%employer%雇佣你是聪明之举。但是，时机来临时，你得做出选择…到底踏上哪条路？%SPEECH_OFF%你让那人带着预言滚去其他地方。 | 当你准备离开%employer%时，一个身着黑衣的人打断了你。他望向你身后，然后悄悄说道。%SPEECH_ON%虽然%employer%给你不少钱，但是我认识个更阔绰的金主。时机来临就要把握好了…%SPEECH_OFF%陌生人后退一步，溜进门后。当你打开追赶时，他已经不见了。只有一个厨房帮手站在里面，似乎{他  |  他}什么都没看到。 | 手头上接着%employer%的任务，你准备出发了。当准备补给时，一个身着斗篷的陌生人来到身前。说话的声音就像有砂石在喉咙中。%SPEECH_ON%佣兵，很多鸟儿盯着你呢。下一步该怎么做可得仔细了。你还有脱身的机会。等时机来临时，我们仅仅让你不要插手就好。%SPEECH_OFF%你拔出剑威胁那人，但是他随着飘舞的斗篷溜进了一群农民中，而你突然拔出武器似乎吓到了他们。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "{这就有趣了… | 看来会有麻烦了。}",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "ShadyCharacter2",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_07.png[/img]{路上时，一群全副武装的人突然冒了出来。你似乎见过其中一个可疑的身影。他们宣称要从你手中抢走使者。作为回报，你将得到总计%bribe%的克朗。\n\n否则的话，好吧，他们就得强行带走他了…… |  你才刚听到熟悉的声音 — 听使者的戏谑，无视它，希望他能独自走进树林再也别回来 — 突然一群全副武装的人给了你一个惊喜。你之前碰到的陌生人跟他们站在一起。他们说必须要交出使者。作为回报，你将得到总计%bribe%的克朗。但是，如果你拒绝的话，他们还是会将他带走，只不过是用更暴力的手段。\n\n在你考虑选择时，使者第一次陷入了完全的沉默。 |  上路后，一群全副武装的男子出现并阻挡了你的去路。你认出其中站着那个之前遇到的陌生人。他们让你交出使者，并伸出大袋克朗，他们声称共有%bribe%。他们还抽出了武器，暗示假如你拒绝他们也做好准备好了应对之策。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "能白拿钱何必还要流血呢？成交。",
					function getResult()
					{
						return "ShadyCharacter3";
					}

				},
				{
					Text = "如果想要抓他，那就自己来拿吧。",
					function getResult()
					{
						return "ShadyCharacter4";
					}

				}
			],
			function start()
			{
				this.Characters.push(this.World.getGuestRoster().get(0).getImagePath());
				this.Flags.set("IsShadyDeal", false);
			}

		});
		this.m.Screens.push({
			ID = "ShadyCharacter3",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_04.png[/img]{在你仔细考虑选择时，使者来到你身边，低语道。%SPEECH_ON%你一定不会让他们把我带走吧，对吗？%employer%可是付了你一大笔钱来保证我的安全的。%SPEECH_OFF%你点点头，伸手拍在他肩膀上回复道。%SPEECH_ON%你说的对。他确实付了一大笔钱。但他们付的更多。%SPEECH_OFF%说完，你把他推到了前面。他抗拒着，但那只是让他死得更快些。血溅了一地，而当剑被抽出时，一堆内脏随之而出。神秘的陌生人递给你承诺的一袋克朗。%SPEECH_ON%谢谢，佣兵。%SPEECH_OFF%  |  你盯着使者然后看了看神秘人，朝他们点了点头。他攥着你的衣领祈求道。%SPEECH_ON%不，不可以！你承诺%employer%要保证我安全的！%SPEECH_OFF%你交出了使者。他们当即杀死了他，他跪倒在地，抚着鲜血喷涌的伤口。杀手们踢了踢他，嘲笑着看使者慢慢僵直，死去。那个男人递给你一袋钱然后拍打你的肩膀说道。%SPEECH_ON%谢谢你的配合，佣兵。你还真没辜负你的头衔。%SPEECH_OFF%  |  你看向使者摆了摆手说道。%SPEECH_ON%我是个佣兵，钱才是王道。%SPEECH_OFF%使者大声疾呼，但一个男子拿了把小十字弓在他眉心射了一箭，刺穿了他的脑袋，包裹在脑浆中。神秘人扔给你一袋克朗。%SPEECH_ON%这对大家来说是悲哀还是好事呢？%SPEECH_OFF%你点了点克朗回答道。%SPEECH_ON%当你的人给使者头骨上来了一箭之后时两者皆有。现在只是好事了。%SPEECH_OFF%神秘人挖苦地笑了。%SPEECH_ON%真是遗憾。我个人有不同的见解。他们说还有戏剧性。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "{有钱拿。 |  大家都好。}",
					function getResult()
					{
						this.World.FactionManager.getFaction(this.Contract.getFaction()).getFlags().set("Betrayed", true);
						this.World.Assets.addMoney(this.Flags.get("Bribe"));
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to protect an envoy");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.updateAchievement("NeverTrustAMercenary", 1, 1);
				this.Characters.push(this.World.getGuestRoster().get(0).getImagePath());
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Flags.get("Bribe") + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "ShadyCharacter4",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_50.png[/img]{你一只手将使者推到身后，另一只手抽出剑。神秘人点点头然后缓慢退到站线后。%SPEECH_ON%太遗憾了，但我还是要把他带走。你一定能理解的。%SPEECH_OFF%  |  神秘人伸出一只手，手指卷曲仿佛是要将使者从你这卷走。而与此相反，你将使者推到了战线后。陌生人随即点了点头。%SPEECH_ON%情理之中。但不太可行。我们各自为主，佣兵。你要忠诚，而我也是。就让站到最后的强者来告诉后人吧。%SPEECH_OFF%  |  使者恳求你，但你叫他闭嘴然后转头面对杀手军团。%SPEECH_ON%使者会活着从这里走出去。%SPEECH_OFF%神秘陌生人点点头退到站线之后。%SPEECH_ON%我能理解。生意就是生意，现在，我们该干活了。%SPEECH_OFF%他的手下走向前，抽出武器。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Mercs";
						p.Entities = [];
						p.Parties = [];
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Mercenaries, 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.World.getGuestRoster().get(0).getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你返回%employer%, 特使和你一起。%SPEECH_ON%Ah, 佣兵，我知道你按照我的要求做了。还有你，特使……？%SPEECH_OFF%%envoy% 走到贵族的耳边低语。他向后靠，点点头。%SPEECH_ON%很好，很好。我们来谈谈……哦，雇佣军，你的钱在外面等着你。问问守卫就行了。%SPEECH_OFF%两人转身走开。你走到大厅，一个魁梧的男人在那里给你一袋%reward_completion%克朗。 |  返回%employer%, 特使离开你身边，快速、安静地告诉那人一些消息。%employer%点点头，没有发表任何看法，只是对着附近的守卫打个响指。武装的男子走上前给你一个袋子。你接过它抬头一看，贵族和特使都走了。 |  一直保护着%envoy% 的安全，特使谢谢你的服务。%employer% 不是很友好，无视你去和神秘使者交谈了。当你在等着薪水的时候，一个守卫悄悄过来把木箱子仍在你的怀里。%SPEECH_ON%里面是%reward_completion% 克朗。你愿意的话可以数一下。%SPEECH_OFF%  |  你知道一些%employer%的鬼鬼祟祟的小代表在镇子做的事。特使和雇主互相问候并立即交谈着，靠进并压低他们的声音。当你走上去询问薪水的事情，一个守卫拦住你，把一个袋子扔进你怀里。承诺的%reward_completion% 克朗。由于对政治没有兴趣，你没有停留很长时间去看那两个人想干什么。 |  %employer% 张开双臂欢迎你。%SPEECH_ON%Ah，你保护着%envoy%的安全！%SPEECH_OFF%他拥抱特使，但只和你握手，同时递过来一包克朗。%SPEECH_ON%我就知道我可以信任你，雇佣军。有请……%SPEECH_OFF%他指向门。你起身离开，留下这两个人说话。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "获得很多克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Safely escorted an envoy");
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
			Title = "战斗之后",
			Text = "[img]gfx/ui/events/event_60.png[/img]{特使没有活下来。%employer% 可以接受各种损失，但是对此事他不会感到开心的。不要再让他失望。 |  不幸的是，%envoy% %envoy_title% 死在你的脚下。真是可怕的命运！好了。未来最好不要再让%employer%失望。 |  好吧，你看到了吗：特使已经死了。你唯一的工作就是保持他的呼吸。现在，他不呼吸了。你不需要与%employer%交谈就能知道他不会对此开心的。 |  你答应过保护特使的安全的。受到更多伤害比彻底死亡还难，似乎你完全搞砸了这个任务。 |  保护特使。让特使活下去。特使一定要活下去。嘿，我是一名特使，我很重要，不能死！\n\n 这些话一定被当做耳旁风了，因为特使真的死了。 |  当全世界想要一个人死，就很难让他活着。不幸的是，%envoy% %envoy_title%没能走完他的旅程。%employer% 对此不会高兴的。}",
			Image = "",
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "该死的！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to protect an envoy");
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
			"objective",
			this.m.Flags.get("DestinationName")
		]);
		_vars.push([
			"bribe",
			this.m.Flags.get("Bribe")
		]);
		_vars.push([
			"envoy",
			this.m.Flags.get("EnvoyName")
		]);
		_vars.push([
			"envoy_title",
			this.m.Flags.get("EnvoyTitle")
		]);
		_vars.push([
			"enemynoblehouse",
			this.m.Flags.get("EnemyName")
		]);
		_vars.push([
			"direction",
			this.m.Destination != null && !this.m.Destination.isNull() ? this.Const.Strings.Direction8[this.m.Home.getTile().getDirection8To(this.m.Destination.getTile())] : ""
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.m.Destination.getSprite("selection").Visible = false;
			this.m.Home.getSprite("selection").Visible = false;
			this.World.State.setUseGuests(true);
			this.World.getGuestRoster().clear();
		}
	}

	function onIsValid()
	{
		if (this.World.FactionManager.isCivilWar())
		{
			return false;
		}

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
			local settlements = this.World.EntityManager.getSettlements();
			local hasPotentialDestination = false;

			foreach( s in settlements )
			{
				if (!s.isDiscovered() || s.isMilitary() || s.isIsolated())
				{
					continue;
				}

				if (s.getOwner() == null || s.getOwner().getID() == this.getFaction())
				{
					continue;
				}

				hasPotentialDestination = true;
				break;
			}

			if (!hasPotentialDestination)
			{
				return false;
			}

			return true;
		}
	}

	function onIsTileUsed( _tile )
	{
		if (this.m.Destination != null && !this.m.Destination.isNull() && _tile.ID == this.m.Destination.getTile().ID)
		{
			return true;
		}

		return false;
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

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local dest = _in.readU32();

		if (dest != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(dest));
		}

		this.contract.onDeserialize(_in);
	}

});

