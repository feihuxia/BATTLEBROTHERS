this.roaming_beasts_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		IsPlayerAttacking = true
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.roaming_beasts";
		this.m.Name = "狩猎野兽";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
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
					"追捕 " + this.Contract.m.Home.getName() + "恐怖分子"
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

				if (r <= 5 && this.World.Assets.getBusinessReputation() > 500)
				{
					this.Flags.set("IsHumans", true);
				}
				else if (r <= 35)
				{
					this.Flags.set("IsGhouls", true);
				}
				else if (r <= 65)
				{
					if (this.Const.DLC.Unhold)
					{
						this.Flags.set("IsSpiders", true);
					}
				}

				local playerTile = this.World.State.getPlayer().getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 5, 10);
				local party;

				if (this.Flags.get("IsHumans"))
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).spawnEntity(tile, "Direwolves", false, this.Const.World.Spawn.BanditsDisguisedAsDirewolves, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					party.setDescription("A pack of ferocious direwolves on the hunt for prey.");
				}
				else if (this.Flags.get("IsGhouls"))
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Nachzehrers", false, this.Const.World.Spawn.Ghouls, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					party.setDescription("A flock of scavenging nachzehrers.");
				}
				else if (this.Flags.get("IsSpiders"))
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Webknechts", false, this.Const.World.Spawn.Spiders, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					party.setDescription("A swarm of webknechts skittering about.");
				}
				else
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Direwolves", false, this.Const.World.Spawn.Direwolves, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					party.setDescription("A pack of ferocious direwolves on the hunt for prey.");
				}

				party.setAttackableByAI(false);
				party.setFootprintSizeOverride(0.75);
				this.Contract.addFootPrintsFromTo(this.Contract.m.Home.getTile(), party.getTile(), this.Const.BeastFootprints, 0.75);
				this.Contract.m.Target = this.WeakTableRef(party);
				party.getSprite("banner").setBrush("banner_beasts_01");
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local roam = this.new("scripts/ai/world/orders/roam_order");
				roam.setPivot(this.Contract.m.Home);
				roam.setMinRange(2);
				roam.setMaxRange(8);
				roam.setAllTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
				roam.setTerrain(this.Const.World.TerrainType.Shore, false);
				roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
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
					if (this.Flags.get("IsHumans"))
					{
						this.Contract.setScreen("CollectingProof");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsGhouls"))
					{
						this.Contract.setScreen("CollectingGhouls");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsSpiders"))
					{
						this.Contract.setScreen("CollectingSpiders");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("CollectingPelts");
						this.World.Contracts.showActiveContract();
					}

					this.Contract.setState("Return");
				}
				else if (!this.Flags.get("IsWorkOfBeastsShown") && this.World.getTime().IsDaytime && this.Contract.m.Target.isHiddenToPlayer() && this.Math.rand(1, 1000) <= 1)
				{
					this.Flags.set("IsWorkOfBeastsShown", true);
					this.Contract.setScreen("WorkOfBeasts");
					this.World.Contracts.showActiveContract();
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (this.Flags.get("IsHumans") && !this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("IsAttackDialogTriggered", true);
					local troops = this.Contract.m.Target.getTroops();

					foreach( t in troops )
					{
						t.ID = this.Const.EntityType.BanditRaider;
					}

					this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
					this.Contract.setScreen("Humans");
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
					if (this.Flags.get("IsHumans"))
					{
						this.Contract.setScreen("Success2");
					}
					else if (this.Flags.get("IsGhouls"))
					{
						this.Contract.setScreen("Success3");
					}
					else if (this.Flags.get("IsSpiders"))
					{
						this.Contract.setScreen("Success4");
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
			Text = "[img]gfx/ui/events/event_43.png[/img]{当你等待%employer%来解释他需要你的服务来做什么的时候，你沉思在你一开始到达的时候这个居住地是多么的寂静和怪异。 %employer%提高他的嗓门 %SPEECH_ON%这个地方被众神诅咒了，被很多可怕的野兽困扰着！它们在晚上到来，带着发光的红眼睛，随意夺走生命。我们大多数的牛都死了，我担心一旦没有更多的牛，我们就将成为下一个被撕裂的对象。前几天，我们派我们最强的小伙子去找到并杀死野兽，但从那以后我们就再没听到过他们的消息。%SPEECH_OFF%他深深的叹气。%SPEECH_ON%跟着踪迹的方向，追上并杀死那些野兽，以便我们能再次和平的生活！我们不是有钱人，但所有人集资为你的服务付钱。%SPEECH_OFF%  |  当你找到%employer%的时候他正看着窗外。在他的手里有一个高脚杯 - 外面除了沉默之外什么都没有。他转向你，几乎忧郁。%SPEECH_ON%当你来到这里的时候，你有意识到它是多么的安静吗？%SPEECH_OFF%你说你有意识到，但你是个看上去很像的佣兵。你习惯了那样了。%employer%点了点头，喝了一口酒。%SPEECH_ON%啊，当然。不幸的是，并非人们怕你。这次不是。我们在过去几周已经有人被袭击了。某种野兽在到处乱跑，我们不知道它们是什么，只知道它们吃什么。当然，我们已经恳求我们的领主，但他没有做任何事情来帮助我们……%SPEECH_OFF%他的下一口喝了很久。当他喝完，他把目光投向你，手里拿着空杯子。%SPEECH_ON%你愿意去追捕这些怪物吗？拜托，佣兵，帮帮我们。%SPEECH_OFF%  |  当你找到%employer%，他正在听几个农民说话。当他们看见你，他们迅速离开，留下男人拿着一个背包在手里。他举起它。%SPEECH_ON%这里有克朗。那些人给我克朗去交给某个人，任何一个人，来帮助我们。人们正在消失，佣兵，和当他们被发现，他们……不只是死了，而且……被毁坏。弄得残缺不全。每个人都太害怕了，哪里都不敢去。%SPEECH_OFF%他凝视袋子里，然后看着你。%SPEECH_ON%我希望你对这个任务有兴趣。%SPEECH_OFF% | 你发现%employer%正在阅读一个卷轴。他把纸扔给你，要你读出那些名字。笔迹很难辨认，但不比名字本身更难。你停下并道歉，说你不是来自这些地区。那人点点头，收回卷轴。%SPEECH_ON%没关系，佣兵。如果你想知道，那些是上周死去的男人、女人和儿童的名字。%SPEECH_OFF%上周？在那个名单上有很多名字。那个男人，似乎读懂你，忧郁的点头。%SPEECH_ON%是啊，我们情况很差。这么多的生命失去了。我们相信这是肮脏的动物，超出我们的推理能力的野兽所为。很明显，我们想要你去找到并消灭它们。你会对这样一个任务感兴趣吗，佣兵？%SPEECH_OFF% | %employer%的脚下有几只狗，非常疲倦，舌头下垂着。%SPEECH_ON%它们花了过去的几天寻找失踪的人。看来人们消失到了只有神知道的地方。%SPEECH_OFF%他斜着身体抚摸一只猎犬，挠它的耳后。通常情况下，一只狗会对那个动作做出反应，但那个可怜的家伙几乎没有反应。%SPEECH_ON%人们不知道我知道的事，但是，那就是人们不只是消失……他们在被绑架。可怕的野兽正在活动，佣兵，而我需要你去追赶它们。该死，也许你甚至可以找到一两个镇民，虽然我表示怀疑。%SPEECH_OFF%几乎就在这时，一只狗发出一声长长的、疲惫的气喘声。 | %employer%带着一个附着一个卷轴的背包，但写在纸上的名字不是你的。他仔细掂量它，硬币的块状在他的手指周围弯曲，它们的叮当声变沉默。他转向你。%SPEECH_ON%你认出那个名字了吗？%SPEECH_OFF%你摇摇头。那个男人继续说。%SPEECH_ON%一周前我们派著名的%randomnoble%从这里的%direction% 去追捕一些在几周里一直在恐吓镇子和周围的农庄的邪恶的野兽。你知道为什么这个背包一直为我所有吗？%SPEECH_OFF%你耸耸肩回答。%SPEECH_ON%因为 他还没回来？%SPEECH_OFF%%employer%点了点头，放下背包。他坐在他的桌子的边缘。%SPEECH_ON%对。因为他还没回来。现在，你认为那是为什么？我认为是因为他已经死了，但让我们不要这么消极。我认为是因为野兽在那里需要更多。我认为他们需要像你这样的人，佣兵。你愿意帮助我们吗，既然这个贵族已经失败了？%SPEECH_OFF% | %employer%从他的书架上取下一本书。当他把它放在他的桌子上时，灰尘或者甚至是灰烬向外飞出。他打开它，拇指慢慢的一页一页翻。%SPEECH_ON%你相信有怪物吗，佣兵？我在诚实的问，因为我相信你对这个世界有比我更好的见识。%SPEECH_OFF%你点头说。%SPEECH_ON%不只是一种信仰，是的。%SPEECH_OFF%那个男人用拇指又翻了一页。他抬头看着你。%SPEECH_ON%嗯，我们相信怪物已经来到了%townname%。我们相信那就是人们失踪的原因。明白这事态会如何发展了吗？我需要你找到这些“虚构”的生物并像杀死任何其他的一样杀死它们。你有兴趣吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{这对你的价值是什么？ | %townname%准备好支付什么？ | 让我们谈谈报酬。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这听起来不像我们的工作。 | 祝你好运，但我们不会参与这个。}",
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
			ID = "Humans",
			Title = "攻击前……",
			Text = "[img]gfx/ui/events/event_07.png[/img]{这些根本不是野兽，而是披着狼皮的人类！目睹过这种罪恶的“真”面目，这些人对于你的敌人是他们都非常了解的对象而松了口气。 | 当你接近怪物，你意识到这些邪恶的生物根本不是野兽，而是伪装的人类！你不知道他们为什么玩这种装扮游戏，但他们在拔出武器。就你而言，野兽还是人类，他们都一样的死。 | 你偶然发现一个男人取下他肩上的狼头。他瞥了你一眼，伪装仍然在手里，然后迅速把它放回。你拔出你的剑。%SPEECH_ON%伪装有点迟了。%SPEECH_OFF%你的武器砍掉了那个人的面具，他踉跄后退。在你能刺穿他之前，他跑开，向一群同样偷偷摸摸的同伙那里冲。他们一见到你就拔出他们的武器。无论这些白痴为了什么原因在玩装扮游戏，现在都不重要了。 | 你偶然遇见一只死掉的野兽，背上插着几支箭。伤并不致命……当你用剑挑开这生物的鬃毛，头马上翻落，露出一个人类的身体。%SPEECH_ON%是你干的吗？%SPEECH_OFF%一个声音从前面打断。那里站着几个人在去除他们的伪装：正是你在追赶的野兽。带头的那个人提高他的嗓门。%SPEECH_ON%杀了他们！把他们都杀了！%SPEECH_OFF%不，这些仍然是野兽，只是比较软的一种。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备攻击！",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WorkOfBeasts",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_60.png[/img]{你在草地上发现一具尸体。通常，死人也没什么好惊讶的，到处都是人，所以看到尸体也只是时间问题。不过这具尸体背部有巨大的伤口痕迹及其器官失踪。\n\n%helpfulbrother% 走过来。%SPEECH_ON%器官不见了是狼造成的，甚至可能是兔子。什么，你没听说过真实的饥饿兔子？%SPEECH_OFF%他吐口水，咬着指甲。%SPEECH_ON%总之，这些痕迹，不是兔子或猎犬什么的造成的。是更大……更危险的东西。%SPEECH_OFF%你感谢他的敏锐观察力，告诉他加入队伍。 |  一个农民走向你，衣服破破烂烂的。他相当谦卑地用手盖住他的大腿根。%SPEECH_ON%长官，请看看这样的……恐怖。%SPEECH_OFF%当你问他在说什么的时候，他举起手，用屁\n\n一位农民靠近，抬起帽子露出眼睛。%SPEECH_OFF%  |  是野兽干的。如果你想要了解，我没有见过它们，但是我在你之前听说过山羊的大惨败。保持低调，远离视线对我来说挺好了。如果你是来找那些生物的，请快点，因为我不能在这样损失家畜了。%SPEECH_OFF%  }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们继续。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CollectingPelts",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_56.png[/img]{野兽被杀死，你命令人们带走它们的毛皮作为证据。你的雇主，%employer%，应该会很高兴见到它们。 | 已经杀死了这些邪恶的生物，你开始剥皮并倒卖它们。可怕的生物需要可怕的证据。你的雇主，%employer%，否则可能不相信你在这里的工作。 | 战斗结束了，你让人们开始收集毛皮，带回去给你的雇主%employer%。你的雇主，%employer%，没有证据可能不相信在这里发生的事。你命令人们开始收集毛皮、战利品、头皮，任何可能炫耀你在这里的的胜利的东西。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "让我们做完这个，我们有克朗可以拿。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CollectingProof",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{你的人带上了傻瓜伪装，免得你的雇主%employer%不相信你在这里做的事。 |  你的雇主可能不会相信这里发生了什么。你下令手下收集伪装。%bro1%，剥掉死者的面具，开始想。%SPEECH_ON%他们把自己打扮成那种东西吸引着我们，现在他们都死了。我希望他们不要认为这是个游戏。%SPEECH_OFF%%bro2% 在伪装的褶皱里清理他的刀刃。%SPEECH_ON%好吧，如果这是个游戏，我当然喜欢它。%SPEECH_OFF% }",
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
			ID = "CollectingGhouls",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_131.png[/img]{战斗结束，你走到死食尸鬼旁边跪下。如果不是因为锋利的蛀牙拦住，你可以轻易地吧头伸进凶兽的大嘴里。你没有欣赏眼前的牙齿故障，而是拿出小刀割下它的头，划开非常坚硬的皮肤外层，令人惊讶的是，轻易切开了肌肉和筋腱。你抬起头，命令%companyname%跟着做。毕竟%employer%会想要一些证据。 }",
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
			ID = "CollectingSpiders",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_123.png[/img]{你命令你的人在田野里搜寻并收集尽可能多的蜘蛛腿。有一些人犯了错误，触摸了Webknechts腿上的毛发，很快就开始抓挠，形成皮疹。  |  蜘蛛在地上向被垃圾一样丢弃，就像在阁楼的角落里一样。在死亡中，它们看起来像紧紧地扣在一起的巨大手套。你让那些人把蜘蛛腿扭成两半，当做证据。  |  雇佣军在田野里四处搜寻，在蜘蛛僵直的尸体上砍砍锯锯. }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "回到 %townname%去!",
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
			Text = "[img]gfx/ui/events/event_04.png[/img]{你回到 %employer% 那里，往他桌子上扔下了一条皮草。它软掉的斜支撑撞到了橡木的一边。男人举起了一块，然后松开看着它落下。%SPEECH_ON%我看出来你已经找到了我们想要的那些野兽了。%SPEECH_OFF%你告诉了他战斗的故事。他看上去很满意，从书架上拿出了一个小木箱子，然后给了你。%SPEECH_ON%%reward_completion%克朗，就跟之前同意的一样。%townname%的人们终于能够不再忍受那些可怕的怪物了。%SPEECH_OFF%  |  但你走进%employer%的房间时他瞬间就畏缩了一下。%SPEECH_ON%看在上帝的份上，你手里拿的是什么东西，佣兵？%SPEECH_OFF%你举起了一块皮草。黑色的血液从皮草脖子的位置上滴落到了地上。%SPEECH_ON%你要找的一个怪物。如果你需要其他的证据的话，都在外面了……%SPEECH_OFF%男人举起了他的手，止住了你。%SPEECH_ON%一个已经够了。雇佣兵，干得不错。你的赏金在%randomname%手里，你很有可能在大厅里见过的一个议员。他手里拿着一个恶心的杯子，他身上有%reward_completion%克朗，就跟约定好的一样。%SPEECH_OFF%男人再次看了那怪物一下，然后慢慢地摇了摇他的脑袋。%SPEECH_ON%愿死者安息，愿从这些可怕怪物爪子下逃离的幸存者们能获得安宁。%SPEECH_OFF%  |  %employer%给了你一杯欢迎的葡萄酒。%SPEECH_ON%喝吧，怪物猎人。%SPEECH_OFF%你很好奇他怎么已经知道成功了的。他打消了你的疑问。%SPEECH_ON%这片土地上全是我的眼线-不是间谍哦，只是平民们都很喜欢八卦而已。我自己就是！你做的很好，佣兵，喝一口吧。这葡萄酒相当不错。%SPEECH_OFF%没事的。但是你的%reward_completion%克朗酬劳比这要好多了。%employer%止住了你。%SPEECH_ON%就告诉一声，佣兵，那些怪物杀了这里的好多人。那些人有可能是害怕你，因为你是个佣兵，但是他们还是会永远感激你的。%SPEECH_OFF%你掂量了一下克朗。还真是不得了的感激之情…… |  %employer%后退了几步。%SPEECH_ON%啊，呃，你已经杀死了凶兽啊。你手里拿的还真是相当不错的皮草。%SPEECH_OFF%你把你带过来的东西甩了下来：一块厚实兽皮摔进了一团血肉毛发之中。那个男人，害怕而不敢靠近，扔了一个袋子给你。%SPEECH_ON%%reward_completion%克朗，就跟约定好的一样。我会把你的成功去通知大家的。总算能有安宁的日子了。%SPEECH_OFF%  |  %employer%坐在他的桌子旁，脚翘在一边。他的眼睛正盯着天花板，他的脸庞干枯萎缩。他看了看你。%SPEECH_ON%欢迎回来。我已经收到了消息……你与怪物们的战斗。%SPEECH_OFF%你点了点头，环顾四周 ，想要找到你的报酬。男人指了指大门。%SPEECH_ON%%randomname%，他是%townname%的一个议员，你的报酬就在他手里，他在外面。就跟约定的一样的%reward_completion%克朗。%townname%的人们，虽然他们有可能都害怕你，但是还是对你的到来欢呼雀跃的。谢谢你，佣兵。%SPEECH_OFF%  | 你回去的时候%employer%正好在喂他的狗。狗抛下了自己的骨头，跑过来嗅着你带过来的东西。男人指了指皮草。%SPEECH_ON%这是什么鬼东西？%SPEECH_OFF% 你耸了耸肩然后扔在他的桌子上。 狗用鼻子戳了戳皮草上的一只爪子，咆哮了一下，然后开始舔了起来。%employer%微微一笑，然后去了书架，拿出了一个木盒子然后交给了你。%SPEECH_ON%%reward_completion%克朗，对不对？你应该要知道你给%townname%的人们带来了安宁。%SPEECH_OFF%你点了点头。%SPEECH_ON%他们的愉悦能给我克朗吗？%SPEECH_OFF%%employer%对你贪婪的幽默感皱了皱眉。%SPEECH_ON%不，没有。日安，佣兵.%SPEECH_OFF%}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Rid the town of direwolves");
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
		this.m.Screens.push({
			ID = "Success2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer% 迎接了你.%SPEECH_ON%我已经听说了这个，美妙的消息.我相信这一点。一群强盗玩换装游戏。穿着狼皮的……狼？%SPEECH_ON%他朝你咧开嘴，以为你会对他那垃圾笑话表示认同。你耸耸肩。他也耸了耸肩。%SPEECH_ON%啊，好吧。你的报酬，%reward_completion%克朗，就在外面。我会告诉%townname%的人们他们害怕的怪物其实都是人的。%SPEECH_OFF%  |  你带着那些愚蠢强盗们的套装回去了。%employer%掂量着这伪装。%SPEECH_ON%有意思。真是做的不错。我都要夸奖这些强盗聪明了。%SPEECH_OFF%他捡起了一快面具然后端详着准备戴上，然后停顿了下来，意识到了自己不想被人看见这么做。他把面具放下来然后朝你笑了笑。%SPEECH_ON%不管怎么说，佣兵……做的好。你的%reward%克朗已经在门外等你了，在%townname%的议员身上。他会来找你的。%townname%的人们将会埋葬我们的逝者，我们终于获得了安宁。%SPEECH_OFF%  | %employer%因为你对真相的揭露大笑了气力啊。%SPEECH_ON%人？只是人吗？%SPEECH_OFF%你点了点头，想要让这男人谈论正经事情。%SPEECH_ON%他们杀死了很多农民，不管怎么说都是一群危险的家伙。%SPEECH_OFF%你的雇主点了点头。%SPEECH_ON%当然了，当然了！我不是想要贬低任何东西或者任何人的。不要自以为是，佣兵，那些死的都是我的朋友和邻居！不管怎么说，你做了我要求的东西，因此我对你十分感激。%SPEECH_OFF%他交给了你一袋克朗。你在离开前先点了点里面的%reward_completion%。男人朝你吼了一声。%SPEECH_ON%你肯定理解这可怕世界中的荒诞的，是吧？因为是我去参加了所有死者的葬礼。我不会皱着眉头进坟墓的，不管这个该死的地方有多么的可怕。%SPEECH_OFF%  |  你给%employer%看了这些作恶多端的强盗的证据。他翻看着伪装，将干掉的血液从他的手指上搓下去。%SPEECH_ON%这还真的是人血。你确定他们不是只是在恶作剧，而不是真的怪兽其实还在外面吗？%SPEECH_OFF%你咬了一下你的嘴唇，然后解释说他们攻击时使用的也是很逼真的武器。%employer%点了点头，看上去理解了，但是还是有点怀疑。%SPEECH_ON%好吧，我猜我可以先等着看这些怪物会不会再回来。如果它们回来的话么，这么说吧，一个被背叛的男人本身就能成为一头相当可怕的怪物，对不对？%SPEECH_OFF%你告诉男人快点付钱，他可以自己去等着看看他应不应该这么不相信人。他点了点头，将%reward_completion%克朗交给了你，然后示意你出门。%SPEECH_ON%我是真心希望你在说实话的，佣兵。%townname%需要从这该死的世界不停袭来的恐怖中获得安宁。%SPEECH_OFF%  |  %employer%手指摩挲着一件伪装的边缘。%SPEECH_ON%摸上去十分柔软。非常真实……%SPEECH_OFF%他看了看你。%SPEECH_ON%那么我得好奇是不是他们杀了最初的怪物，然后……决定穿上他们的毛皮来假装了？但是为什么呢？你觉得他们是被诅咒了吗？%SPEECH_OFF%你耸了耸肩然后回答。%SPEECH_ON%我能说的只有他们是穿着怪物的伪装，也有着怪物般的残忍之心。他们攻击了我们，然后为此付出了代价。你们本地人最近有发现过怪物吗？%SPEECH_OFF%男人拿出了一袋%reward_completion%克朗的帆布袋然后扔给了你。%SPEECH_ON%不，没有。事实上，他们已经开始再次出去了。我不是说出城，但是离开安全的家门对于很多人来说已经是不得了的努力了！你绝对是给我们带来了和平，佣兵，为此我们感谢你。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "野兽，人类……重要的是克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Rid the town of brigands masquerading as direwolves");
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
		this.m.Screens.push({
			ID = "Success3",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你发现 %employer%坐在他的月桂树上。 他站了起来然后拉上了裤子，一名仆人马上跑过来从他坐着的地方拿回了一个木桶。那可怜的仆人马上冲出了房间。%employer%指了指你手上荡着的食尸鬼头。%SPEECH_ON%那真是太恶心了。%randomname%，把这个男人的报酬给他。%reward%克朗，是不是？%SPEECH_OFF%  |  你将食尸鬼头颅放在了%employer%的桌子上。出于某种原因，它的脖子上还在渗着液体，滴在了橡木的侧边，男人凑了过去，手放在肚子上。%SPEECH_ON%食尸鬼？还有什么，幽灵吗？%SPEECH_OFF%男人自己笑了起来。%SPEECH_ON%对你来说真是没有什么困难的，佣兵。%SPEECH_OFF%他打了个响指然后一名仆人走了出来，给了你一袋%reward%克朗的帆布袋。 |  因为战斗与前往%employer%的地方的路上花费的时间，食尸鬼的断头上满是苍蝇，它的舌头被一群嗡嗡作响的黑球包裹住了。%employer%看了一眼就往嘴上盖了一块布条。%SPEECH_ON%好了，我懂了，请拿开它。%SPEECH_OFF%他挥了挥手手叫了一名守卫过来，他给了你一袋%reward%克朗。 |  眼神刚毅的%employer%向前靠了靠，好好看了看你带过来的食尸鬼脑袋。%SPEECH_ON%还真是不得了啊，佣兵。我很高兴你把它带给我了。%SPEECH_OFF%他向后靠了靠。%SPEECH_ON%放在我的桌子上就好。也许我可以用这东西去吓孩子们。那些小兔崽子日子过得太舒坦了我觉得。%SPEECH_OFF%他打了个响指，一名侍者走过来给了你%reward%克朗。 |  你将食尸鬼头带给了%employer%，他盯着那个头颅看了很久很久。%SPEECH_ON%那让我想起了某个人。我不要碰这东西，而且我不知道应不应该碰这东西。抱歉，佣兵，我浪费了你的时间而没有付钱。佣人，过来给这个男人他的钱！%SPEECH_OFF%就跟约定好的一样拿到了钱。 |  %employer%拿起了食尸鬼的头颅然后举了起来。几只喵喵叫的猫咪突然从不知道什么地方窜了出来，在它下面来回打转着，就像秃鹫在尸体上空盘旋一样。他将头颅扔出了窗外，猫们跟了出去。%SPEECH_ON%做得好，佣兵。%reward%克朗，就跟约定好的一样。%SPEECH_OFF%  |  你将食尸鬼的头颅放在了%employer%的桌子上。他看着餐盘旁边的头颅，窥视了一下头颅，然后再看了看你。%SPEECH_ON%我在吃饭，佣兵。%SPEECH_OFF%被恶心到的男人将餐盘推开时银器发出了清脆的碰撞声。一名仆人将食物匆匆忙忙收走了，也许是想要之后自己吃掉。%employer%拿出了一个口袋，然后放在了桌子上。%SPEECH_ON%%reward%克朗，就跟约定好的一样。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一次成功的狩猎。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Rid the town of nachzehrers");
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
		this.m.Screens.push({
			ID = "Success4",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你进入 %employer%的办公室，身上背着死蜘蛛。那人尖叫着，椅子在地板上向后一甩，发出一阵巨响。他跳起来，从桌上拿出一把奶油刀。你把死去的蜘蛛从肩上扔下来，它在地上咔嗒作响。镇上的人慢慢地走了过来。他把奶油刀包在一块面包里摇了摇头.%SPEECH_ON%老天爷，你差点让我心脏病发作.%SPEECH_OFF%点头，你告诉那个人，要想压扁这些野兽，需要一只大靴子。他点点头.%SPEECH_ON%这是当然， 你能够得到 %reward_completion% 克朗的报酬. 而且，拜托，离开的时候带上那不干净的东西.%SPEECH_OFF%  |  你进入 %employer%的办公室. 几只狗，总是神秘的那种，在你的腿上跑来跑去，嗅着蜘蛛的尸体，它们的鼻子皱着，扯开，但总是回来找更多的。那人正在写笔记，他简直不敢相信自己的眼睛。他放下羽毛笔。%SPEECH_ON%那是一只巨大的蜘蛛吗?%SPEECH_OFF%你点头。他微笑着把羽毛笔拿回来。.%SPEECH_ON%也许我应该建议你带一只很大的靴子.  你能够得到 %reward_completion% 克朗的报酬. 然后，带走它.%SPEECH_OFF%  |  当你带着一只巨大的死蜘蛛进入他的房间并把尸体扔到地板上时，他正在举办一个生日聚会。它毛茸茸的头发嘶嘶地划过石头，它的八条腿像一些恐怖的家具一样倒立着，它斜着走，从书架的一角滑下来，它的脚趾和尖刺，好像准备突袭。当所有人尖叫着跑出门外或是从最近的开着的窗户中偷窥时，混乱爆发了。镇长独自站在空荡荡的房间里，嘴唇紧闭.%SPEECH_ON%真的有必要吗？%SPEECH_OFF%你点点头，告诉他雇佣你是必要的，而支付你的薪水仍然是非常必要的。%SPEECH_ON%你的包裹在那边，里面有 %reward_completion% 克朗, 按照约定。现在把这可怕的东西弄出去，告诉那些人，聚会没有结束.%SPEECH_OFF% }",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "A successful hunt.",
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
					text = "你获得了 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
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
			this.m.Target == null || this.m.Target.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Target.getTile())]
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

