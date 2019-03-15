this.hunting_unholds_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		Dude = null,
		IsPlayerAttacking = true
	},
	function setEnemyType( _t )
	{
		this.m.Flags.set("EnemyType", _t);
	}

	function create()
	{
		this.contract.create();
		this.m.Type = "contract.hunting_unholds";
		this.m.Name = "狩猎巨魔";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
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
					"狩猎" + this.Contract.m.Home.getName()+"的巨魔"
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

				if (r <= 40)
				{
					this.Flags.set("IsDriveOff", true);
				}
				else if (r <= 50)
				{
					this.Flags.set("IsSignsOfAFight", true);
				}

				this.Flags.set("StartTime", this.Time.getVirtualTimeF());
				local playerTile = this.World.State.getPlayer().getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 6, 12, [
					this.Const.World.TerrainType.Mountains
				]);
				local nearTile = this.Contract.getTileToSpawnLocation(playerTile, 4, 8);
				local party;

				if (this.Flags.get("EnemyType") == 0)
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Unholds", false, this.Const.World.Spawn.UnholdBog, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				}
				else if (this.Flags.get("EnemyType") == 1)
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Unholds", false, this.Const.World.Spawn.UnholdFrost, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				}
				else
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Unholds", false, this.Const.World.Spawn.Unhold, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				}

				party.setDescription("One or more lumbering giants.");
				party.setAttackableByAI(false);
				party.setFootprintSizeOverride(0.75);
				party.getTags().set("IsUnholds", true);
				this.Contract.addFootPrintsFromTo(nearTile, party.getTile(), this.Const.BeastFootprints, 0.75);
				this.Contract.m.Target = this.WeakTableRef(party);
				party.getSprite("banner").setBrush("banner_beasts_01");
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
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
					if (this.Flags.get("IsSignsOfAFight"))
					{
						this.Contract.setScreen("SignsOfAFight");
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
					this.Flags.set("IsBanterShown", true);
					this.Contract.setScreen("Banter");
					this.World.Contracts.showActiveContract();
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (this.Flags.get("IsDriveOff") && !this.Flags.get("IsEncounterShown"))
				{
					this.Flags.set("IsEncounterShown", true);
					local bros = this.World.getPlayerRoster().getAll();
					local candidates = [];

					foreach( bro in bros )
					{
						if (bro.getBackground().getID() == "background.beast_hunter" || bro.getBackground().getID() == "background.wildman" || bro.getSkills().hasSkill("trait.dumb"))
						{
							candidates.push(bro);
						}
					}

					if (candidates.len() == 0)
					{
						this.World.Contracts.showCombatDialog(_isPlayerAttacking);
					}
					else
					{
						this.Contract.m.Dude = candidates[this.Math.rand(0, candidates.len() - 1)];
						this.Contract.setScreen("DriveThemOff");
						this.World.Contracts.showActiveContract();
					}
				}
				else if (!this.Flags.get("IsEncounterShown"))
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
					if (this.Flags.get("IsDriveOffSuccess"))
					{
						this.Contract.setScreen("SuccessPeaceful");
					}
					else
					{
						this.Contract.setScreen("Success");
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
			Text = "[img]gfx/ui/events/event_79.png[/img]{当你进入%employer%的房间时，你发现那个男人弯腰站在他的窗前，几乎是在秘密地向外张望。他的眼睛又细又长。他拉起窗帘，转头看着你。%SPEECH_ON%你没有碰巧看到一个非常愤怒的女人朝我走来，是吗？啊，别想了。看看这个.%SPEECH_OFF%他把打开的画卷扔给你。有一幅粗略的图画，画的是一个男人弓着背，伏在蚂蚁或昆虫身上。你不能辨别真伪。%SPEECH_ON%当地农民报告牲畜丢失。他们发现的只是足印，足印大到足以让一个人躺进棺材。听上去像是道听途说和流言蜚语，可能是竞争对手试图隐瞒他们的错误，但我会让你相信的。搜索周围的土地，看看你发现了什么。如果你遇到一个真正的巨魔，我想你知道该怎么做.%SPEECH_OFF% | 你发现%employer%坐在他的办公桌旁，似乎和一半的市民在会面。他们弯腰在卷轴上，在纸上画画，画出一幅像巨人或长着角的胖男人的画。%employer%给你一张更清晰生动的画纸，上面是怪物的容貌。%SPEECH_ON%这些绅士告诉我，一个巨人正在逼近。我不想让我的市民担忧，所以我请求你的服务，剑士。钱在桌子上，你所要做的就是搜索%townname%周围的区域并找到这个野兽。你意下如何？%SPEECH_OFF% | 你发现%employer%真在躲避一群农民。他们带着干草叉和未点燃的火把进入他的房间，考虑到全木结构，他必须不断警告他们不要点燃。看到你，%employer%像一个溺水的人一样喊着要一条木筏。%SPEECH_ON%剑士！上帝保佑你到这里来。这些好人说有一只野兽在村里.%SPEECH_OFF%一个农民把他的干草叉跺到地上.%SPEECH_ON%不，不是普通的野兽，而是怪物呀！巨人！一个巨大的欧拉巨魔。在那里。就在那里。我看见了.%SPEECH_OFF%一声叹气，%employer%又插嘴了。%SPEECH_ON%非常好。所以，我愿意给你钱来寻找这个巨人。你能胜任这项任务吗？%SPEECH_OFF% }",
			//| %employer% is at his desk with his head in his hands. He\'s mumbling to himself.%SPEECH_ON%Monster this, beast that. \'Oh my chicken got taken\', oh maybe you should consider putting it in a pen you damned piece of - oh hi sellsword!%SPEECH_OFF%The man rises from his chair and throws you a piece of paper. There\'s a crude drawing of a large headed beast on it.%SPEECH_ON%Folks are reporting there\'s a giant roaming around these parts. I\'ll pay good money to see these reports investigated properly, and of course good money to see the beast slain properly as well. Are you up for it? Please say yes.%SPEECH_OFF% | %employer% reluctantly welcomes you into his room, pretending that he doesn\'t need your help, thought it\'s clear he\'d rather not want it at all.%SPEECH_ON%Ah, mercenary. It\'s not often a place such as %townname% would seek out men of your ilk, but I\'m afraid there have been sightings of unholds scouring these lands, stealing enough livestock that the townsfolk have put in the coin to fetch a man such as yourself. Are you interested in hunting down this foul creature?%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{和巨人战斗的价格可不便宜. | 只要你开价合适，我们 %companyname% 会帮助你的. | 让我们谈谈价格.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这听起来不像是什么好工作. | 不值得为这事冒险.}",
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
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_71.png[/img]{%randombrother% 侦察归来。他报告说，附近的一个农场被毁，屋顶上有一个洞被炸开，就像有人在踢一堆蚂蚁。你问是否有幸存者。他点了点头.%SPEECH_ON%当然有。一个拒绝说话的年轻小伙子。一个女人不停地叫我滚蛋。除了他们,没有人了。他们是环境和好运的幸存者。这个世界不会允许他们在这里呆太久%SPEECH_OFF%你告诉佣兵，让他自己做出判断，让战队重新前进. }",
			//| You find a half a cow beside the path. It has not been butchered so much as pulled apart unevenly and with great violence. Much of its innards have slopped to the ground in a pile. Footprints the size of graves lead away. The trail of carnage goes through a fence which lays sundered and further down the way you can see the wreckage of a barn. %randombrother% laughs.%SPEECH_ON%All we\'re missing is a giant pile of shit.%SPEECH_OFF%You tell him to check his boot. | A few peasants on the road warn you off.%SPEECH_ON%Get on out of here! That armor won\'t save you from a single lick!%SPEECH_OFF%You ask them about the unhold and they garner up a great description of a monstrous giant which tore through the land not long ago. It appears you\'re on the right track. | The unhold has left a giant mess in its wake. Stomped livestock, others broke apart and slurped like honeysuckles. Chickens mill about pecking the ground, a farmer keeping watch of them. He nods.%SPEECH_ON%Just missed the show.%SPEECH_OFF%Looks like you\'re getting close.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "他们离这不远了.",
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
			Text = "[img]gfx/ui/events/event_104.png[/img]{每一个巨魔都是不可估量的巨大。他们被前来与他们战斗的蚂蚁弄糊涂了。一个人挠挠头，愉快地打了个嗝，用牛血把战队弄得满脸雀斑。然而，他们似乎认出了你拔出的剑，它的闪光把他们从酣睡中唤醒。在他们的脚上踏出惊天动地的响声之后，他们大步向前，把你从这片土地上赶出去}",
				//The unholds in part remind you of any group of laborers, circled around a dead fire, rubbing their bellies and looking like boulders there hunched on the ground. Of course, your arrival brings them to their feet and destroys any notion that you\'ve anything resembling them at all, except maybe similarly sized third legs. The beasts growl and stomp, but they do not attack. They throw their hands out and try and shoo you away. But the %companyname% didn\'t come this far to quit. You draw your sword and lead the men forward. | Each unhold is enormous beyond measure. They\'re bewildered at the ants come to do battle with them. One scratches his head and blithely belches, freckling the company with bovine blood. They seem to recognize the steel of your drawn sword, though, and the flash of it wakes them from their satiated slumbers. After earthshaking stomps of their feet, they stride forward to run you from the land or into it. | The %companyname% stacked from leg to head still would not size up to a single unhold. Yet here you stand, waving a sword and ready to combat the tremendous monsters. They regard you with incredulous stares, not quite sure what to make of these tiny creatures so willing to confront them. One scratches his belly and flakes of molted skin the size of dogs come twirling down. Well, there\'s no point dwelling on it any longer. You order the company forward! | The unhold sniff you out and come charging across the land to meet the %companyname%. They look like toddlers the size of mountains, legs awkwardly trundling forward yet each step sends tremors through the earth, their maws agape and slobbering for a meal. You calmly draw out your sword and put the men into formation.}",
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
			ID = "DriveThemOff",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_104.png[/img]{当你让士兵们排成队形时，%shouter%从你身边跑过去，径直朝打开的门跑去。他又叫又叫，他的手臂像被钩子钩住的海怪一样扑腾着。您不确定是否应该允许这种情况继续下去...}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "攻击他们!",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				},
				{
					Text = "%shouter% 知道他在干什么.",
					function getResult()
					{
						if (this.Math.rand(1, 100) <= 35)
						{
							return "DriveThemOffSuccess";
						}
						else
						{
							return "DriveThemOffFailure";
						}
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "DriveThemOffSuccess",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_104.png[/img]{%shouter%像一条狂吠的狗，跑到巨魔的脚边，发出一种返祖的尖叫，声音嘶哑得让人怀疑是不是地球上的每一位祖先都听到了它的叫声。巨魔开始时好像要挡住它，然后开始后退，越来越远，直到消失!他们都消失了}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "别再回来了！",
					function getResult()
					{
						this.Contract.m.Target.die();
						this.Contract.m.Target = null;
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Contract.m.Dude.getImagePath());
				this.Contract.m.Dude.improveMood(3.0, "Managed to drive off unholds all by himself");

				if (this.Contract.m.Dude.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[this.Contract.m.Dude.getMoodState()],
						text = this.Contract.m.Dude.getName() + this.Const.MoodStateEvent[this.Contract.m.Dude.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "DriveThemOffFailure",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_104.png[/img]{%shouter%像一条狂吠的狗，跑到巨魔的脚边，发出一种返祖的尖叫，声音嘶哑得让人怀疑是不是地球上的每一位祖先都听到了它的叫声。巨魔伸手抓住了他，把他甩在地上，%shouter%发出了痛苦的喊叫.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "到此为止.",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, false);
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Contract.m.Dude.getImagePath());
				local injury;

				if (this.Math.rand(1, 100) <= 50)
				{
					injury = this.Contract.m.Dude.addInjury(this.Const.Injury.BluntBody);
				}
				else
				{
					injury = this.Contract.m.Dude.addInjury(this.Const.Injury.BluntHead);
				}

				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = this.Contract.m.Dude.getName() + " suffers " + injury.getNameOnly()
				});
				this.Contract.m.Dude.worsenMood(1.0, "Failed to drive off unholds all by himself");

				if (this.Contract.m.Dude.getMoodState() <= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[this.Contract.m.Dude.getMoodState()],
						text = this.Contract.m.Dude.getName() + this.Const.MoodStateEvent[this.Contract.m.Dude.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Victory",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_113.png[/img]{你命令那些被你杀死的巨魔，拿出他们能证明自己的战利品，也许是你自己的东西。如果人能用牛做皮革，那么肯定有什么东西配得上这些巨人?无论如何%employer%都在等你. | 当最后一个巨魔被杀, %employer% 现在应该在等你回来. 他的城镇将永远安全，不再需要像你这样的佣兵。你老是想着这件事，直到你笑得前仰后合，你的男人们都不明白。你告诉他们忽略它，把他们集合起来，准备返程.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "获得报酬的时间到了.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SignsOfAFight",
			Title = "战斗之后...",
			Text = "[img]gfx/ui/events/event_113.png[/img]{With the giants slain, you get the men ready for a return to %employer%, but %randombrother% fetches your attention with a bit of quiver in his throat. You head on over to see him standing before one of the felled unholds. He points across its flesh which has been torn asunder in slices and hangs like the ears of a corn stalk. The damage is far beyond the ability of your own weaponry. The sellsword turns and looks past you with his eyes widening.%SPEECH_ON%What do you imagine did that?%SPEECH_OFF%Further along the skin are concave scars shaped like saucers with punctures rent right into the holes. You climb atop the unhold and crank your sword into one of these divots, wrenching free a tooth about the length of your forearm. Along its edges are barbs, teeth upon teeth it seems. The men see this and start muttering amongst themselves and you wished you\'d never saw it at all for you\'ve no sense to make of it.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "野外黑暗而又恐怖.",
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
			ID = "Success",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_79.png[/img]{%employer%欢迎你的归来，自从你离开后，他还没有听到过任何有关房屋被拆的消息。你点了点头，拿出证据来说明原因，当你把被杀死的巨人的尸体扔到他的地板上时，他们光滑的尸体在飞溅。木头被弄脏了，好像你铺开了地毯似的。市长噘起嘴唇。该死的，佣兵?你扬起头，挑了挑眉毛。那人垂下双手，微微鞠了一躬。%SPEECH_ON%啊,没烦恼!一切都好!在这里，你的回报正如所承诺的！%SPEECH_OFF% }",
			//| You return to %employer% and find the man reading stories to children. He rends his hand through the air and growls like a beast. Knocking on the door, you intrude upon the theater.%SPEECH_ON%Aye, and then the ever honorable sellswords slew the monster!%SPEECH_OFF%The children cheer at your timely arrival. The mayor stands and gives you the promised reward, declaring he had a scout following your every move and he\'s already heard the reports of your success. He asks if you\'ll stick around and tell the tale for the kiddos. You tell him you don\'t work for free and leave the room. | You have to root about the town a while to find %employer%, the man himself found kept up in his room by a young lass who hides beneath the sheets you caught them in. The mayor gets dressed with no hesitation as to his own nakedness. He pitches a coin toward the girl and then speaks to you.%SPEECH_ON%Aye, sellsword, I\'ve been expecting you! Your reward, as promised!%SPEECH_OFF%He gives you the satchel, but a coin slips free and runs between the floorboards. The man purses his lips a moment then runs back to the girl and snatches the coin out of her hands and drops it in the satchel. | %employer% is found arguing with peasants about unpaid taxes and how the lords of the land will get their coin one way or another. The arrival of an armed fellow such as yourself is rather apropos and sends the peons scuttling for their coin purses. You tell them to quiet down and then address the mayor to get your money. He fetches it from a drawer, pausing only to fill it to the brim by taking a coin from a peasant, and then he hands it over to you.%SPEECH_ON%Appreciate your work, sellsword.%SPEECH_OFF% | You report to %employer% of your doings and he is, surprisingly not incredulous in the least.%SPEECH_ON%Aye, I had a scout tracking your company and he\'d beaten you back to town. Every word you say mirrors his. Your pay, as promised.%SPEECH_OFF%He hands you a satchel.}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Rid the town of unholds");
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
			ID = "SuccessPeaceful",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_79.png[/img]{%employer% 把他的手指举到眼角，然后向前指。。%SPEECH_ON%让我把话说清楚，你的一个佣兵向巨人们喊了一声撤退?%SPEECH_OFF%你点了点头，告诉他他们去的方向，很重要的是，要远离城镇。市长向后靠在椅子上。%SPEECH_ON%好吧。我想现在不是我的问题了。不管他是死了还是走了，我想都是一样的。%SPEECH_OFF%他递给你一个小提包，但把手放在上面。%SPEECH_ON%你知道，如果你在说谎，我会把这里的每一个克朗都收回来的%SPEECH_OFF%}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Rid the town of unholds");
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
			"shouter",
			this.m.Dude != null ? this.m.Dude.getName() : ""
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
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/unhold_attacks_situation"));
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

