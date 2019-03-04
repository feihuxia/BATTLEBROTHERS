this.find_artifact_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Dude = null,
		IsPlayerAttacking = false
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.find_artifact";
		this.m.Name = "搜寻队";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		local myTile = this.World.State.getPlayer().getTile();
		local undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getSettlements();
		local highestDistance = 0;
		local best;

		foreach( b in undead )
		{
			if (b.isLocationType(this.Const.World.LocationType.Unique))
			{
				continue;
			}

			local d = myTile.getDistanceTo(b.getTile()) + this.Math.rand(0, 45);

			if (d > highestDistance)
			{
				highestDistance = d;
				best = b;
			}
		}

		this.m.Destination = this.WeakTableRef(best);
		this.m.Flags.set("DestinationName", this.m.Destination.getName());
		local nemesisNames = [
			"the Raven",
			"the Fox",
			"the Bastard",
			"the Cat",
			"the Lion",
			"the General",
			"the Robber Baron",
			"the Rook"
		];
		local nemesisNamesC = [
			"The Raven",
			"The Fox",
			"The Bastard",
			"The Cat",
			"The Lion",
			"The General",
			"The Robber Baron",
			"The Rook"
		];
		local nemesisNamesS = [
			"Raven",
			"Fox",
			"Bastard",
			"Cat",
			"Lion",
			"General",
			"Robber Baron",
			"Rook"
		];
		local n = this.Math.rand(0, nemesisNames.len() - 1);
		this.m.Flags.set("NemesisName", nemesisNames[n]);
		this.m.Flags.set("NemesisNameC", nemesisNamesC[n]);
		this.m.Flags.set("NemesisNameS", nemesisNamesS[n]);
		this.m.Payment.Pool = 1900 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		local r = this.Math.rand(1, 2);

		if (r == 1)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else if (r == 2)
		{
			this.m.Payment.Completion = 1.0;
		}

		this.m.Flags.set("Score", 0);
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"%direction% 处的 %objective% 取回古董"
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
					this.Flags.set("IsLost", true);
				}

				r = this.Math.rand(1, 100);

				if (r <= 20)
				{
					if (!this.Flags.get("IsLost"))
					{
						this.Flags.set("IsScavengerHunt", true);
					}
				}
				else if (r <= 25)
				{
					this.Flags.set("IsTrap", true);
				}
				else if (r <= 30)
				{
					this.Flags.set("IsTooLate", true);
				}

				if (!this.Contract.m.Destination.getTags().get("IsEventLocation"))
				{
					this.Contract.m.Destination.getLoot().clear();
				}

				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
				this.Contract.m.Destination.setLootScaleBasedOnResources(130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.clearTroops();
				this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));

				if (!this.Flags.get("IsLost") && !this.Flags.get("IsTooLate"))
				{
					this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.UndeadArmy, 130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				}

				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onDestinationAttacked.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Destination == null  ||  this.Contract.m.Destination.isNull())
				{
					if (this.Flags.get("IsTrap") && !this.Flags.get("IsTrapShown"))
					{
						this.Flags.set("IsTrapShown", true);
						this.Contract.setScreen("Trap");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsScavengerHunt") && !this.Flags.get("IsScavengerHuntShown"))
					{
						this.Flags.set("IsScavengerHuntShown", true);
						this.Contract.setScreen("ScavengerHunt");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("SearchingTheRuins");
						this.World.Contracts.showActiveContract();
					}
				}
				else if (this.Flags.get("IsLost") && !this.Flags.get("IsLostShown") && this.Contract.isPlayerNear(this.Contract.m.Destination, 500))
				{
					this.Flags.set("IsLostShown", true);
					local brothers = this.World.getPlayerRoster().getAll();
					local hasHistorian = false;

					foreach( bro in brothers )
					{
						if (bro.getBackground().getID() == "background.historian")
						{
							hasHistorian = true;
							break;
						}
					}

					if (hasHistorian)
					{
						this.Contract.setScreen("AlmostLost");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("Lost");
						this.World.Contracts.showActiveContract();
					}
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				if (!this.Flags.get("IsAttackDialogShown"))
				{
					this.Flags.set("IsAttackDialogShown", true);

					if (this.Flags.get("IsTooLate"))
					{
						this.Contract.setScreen("TooLate1");
					}
					else
					{
						this.Contract.setScreen("ApproachingTheRuins");
					}

					this.World.Contracts.showActiveContract();
				}
				else
				{
					_dest.m.IsShowingDefenders = true;
					this.World.Contracts.showCombatDialog();
				}
			}

		});
		this.m.States.push({
			ID = "Running_TooLate",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"抓住 %nemesis% 并取回古董"
				];

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onCombatWithNemesis.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Destination == null  ||  this.Contract.m.Destination.isNull())
				{
					this.Contract.setScreen("TooLate3");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatWithNemesis( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;

				if (!this.TempFlags.get("IsAttackDialogWithNemesisShown"))
				{
					this.TempFlags.set("IsAttackDialogWithNemesisShown", true);
					this.Contract.setScreen("TooLate2");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					properties.Music = this.Const.Music.NobleTracks;
					properties.Entities.push({
						ID = this.Const.EntityType.BanditLeader,
						Variant = 0,
						Row = 2,
						Script = "scripts/entity/tactical/enemies/bandit_leader",
						Faction = _dest.getFaction(),
						Callback = this.onNemesisPlaced.bindenv(this)
					});
					properties.EnemyBanners = [
						this.Const.PlayerBanners[this.Flags.get("NemesisBanner") - 1]
					];
					this.World.Contracts.startScriptedCombat(properties, true, true, true);
				}
			}

			function onNemesisPlaced( _entity, _tag )
			{
				_entity.setName(this.Flags.get("NemesisNameC"));
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

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(null);
				}
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{你找到了%employer%，他正看着一堆地图，用各种各样的工具测绘着它们。他抬起了头，表面上带着制图员式的严肃表情。%SPEECH_ON%我的文士给我带来了这些地图，说他们找到了一个叫‘%objective%’的地方。据说在它的走廊，或是大厅，呃，也可能是别的地方，隐藏着某种强大的力量。%SPEECH_OFF%你抬了抬眉毛，而那男人继续说着。%SPEECH_ON%听着，我的文士十分相信那种力量能帮助我们对付这场不死者灾祸。但他们还告诉我别的人也在搜索它。我需要你先他们一步取得那份力量。.%SPEECH_OFF%  |  %employer%向你打了个招呼，同时展开了一份地图，地图很大，从他的脑袋处一直伸展到脚趾。他用手指捏住地图的一遍，指在了某个地点上。%SPEECH_ON%瞧见这个了吗？这叫‘%objective%’。我对那个地方……了解得并不多。我只知道还有别的人前往了那里，据说是在搜索某种具有强大力量的器具。我的文士相信这个东西能帮助我们对付不死者的灾祸。很显然，我希望你能早别人一部取得那件东西！%SPEECH_OFF%  |  %employer%拿过来一张地图，指出了一的地点。%SPEECH_ON%这个就是所谓的\'%objective%\'了。据说也有别的人在寻找那里。我的文士们，相信那里有着某种器具，能帮助我们对付不死者灾祸。这个区域遍布着危险，而且我相信你也会碰上其他搜寻者。去那里把东西带给我，我会给你丰厚的奖励。%SPEECH_OFF%  |  当你见到%employer%时，他急忙把你招到身边，并给你看了一本书。你在书中看到了一种从未见过的语言，不过上面有一份很清晰的地图，地图上有个地点被重点圈了起来。%employer%点了点那里。%SPEECH_ON%我需要你去那里，佣兵。他们把那叫做‘%objective%’。我的文士们说那里有某种器具，拥有着强大的力量，能帮助我们对付不死者灾祸。当然，那样的器具可不会就大咧咧地放在那里任人拿取。我估计那件器具的巨大力量会吸引很多人和生物在其附近徘徊的！你需要去把它带回来。%SPEECH_OFF%  |  %employer%把你迎了进去，很快向你说了一个叫作‘%objective%’的地方，一个坐落在%direction%方向上的可怕地点。%SPEECH_ON%我的文士说这个区域藏有某种强大的器具，能帮助我们对付不死者灾祸。当然，他们也可能是想研究它才这么跟我说。至少现在，我是相信他们的。我需要你把它找回来。巨大的力量总会非常吸引人，所以我估计那里应该会有别的什么的存在，明白了吗？去把它带回给我，我会给你丰厚的报酬。%SPEECH_OFF%  |  你发现一名文士在%employer%的耳边不停地低语着什么，那名贵族也时不时地点点头。在看到你后，他立刻把情况跟你解释了一遍。%SPEECH_ON%佣兵！我得到了……一个消息，%direction%方向上，有个地方藏着某种拥有巨大力量的器具，而我们很需要它。我认为它也许能帮助我们对付不死者灾祸。当然，如果那东西真有这么强大的力量，我认为其他人也会去搜寻的！因此，速度也是非常关键的。我希望你去那里把东西找回来。%SPEECH_OFF%  |  你看到%employer%时，他正站在自己的私人墓地中。 他站在一个墓碑前。%SPEECH_ON%每天晚上，我都在担心这些墓碑下面的祖先们会活过来，来指责我的过错并毁灭我。%SPEECH_OFF%他转过身，看向了你。说完，他把你带进了家中，你看到里面有一位老人正趴在桌子上钻研了大量的书籍。%employer%让你去跟那个老人交谈一下，然后站在了门口。你坐在了老人的眼前，放下了他的羽毛笔。%SPEECH_ON%{我的大人让我把所知的一切都告诉你。我在%direction%方向上一个叫作‘%objective%’的地方发现了一件拥有强大力量的器具。我认为这个器具包含的力量能对付不死者……复活的问题。同时我相信这个消息并不是那么地隐秘。你需要去那里，击退其他的搜索者，并把那件器具带回来。 |  欢迎，雇佣兵。我并不经常用你这样职业的人来解决我自己的问题。一本好书，一个安静的夜晚，就能满足我了，但现在可不行。我们需要你前往%direction%，去一个叫作‘%objective%’的地方。我们有理由相信在那里或许能发现帮助我们解决不死者问题的方法。当然，那种力量总会吸引很多人。你动作要快，把那东西带回来，以免落入他人之手。}%SPEECH_OFF%  |  一名文士站在%employer%身边。两人都正看着一张纸。当你接近时，他们慢慢地将那张纸推向了你。那是一份地图，文士在上面指出了一个地点，他们相信那里藏有一件器具，拥有强大的力量，能够对付不死者的灾祸。%employer%认为还会有其他人在寻找它，所以你的动作必须迅速。 |  你发现%employer%正在与文士谈话，两人都看着一本书，蜡烛在他们面前摇曳着。当抬头看到你后，领主马上把情况向你解释了一遍：他们发现了一个藏有强大器具的地点，那件器具拥有的力量能帮助对付不死者的灾祸。%employer%附和地点了点头。%SPEECH_ON%我们有理由相信搜索那件器具的人绝对不止你一个，而且那地方绝对充满了危险。%SPEECH_OFF%  |  %employer%拿起了一个火把，把你带入了墓穴。你在阴影中看到了鬼一般的雕像，贵族的火把也不断地摇曳着。他在一个雕像面前停下脚步。%SPEECH_ON%这是我的父亲。来，靠近点听。%SPEECH_OFF%你把耳朵凑了过去，似乎听到了某种抓挠的声音。%employer%摇了摇头。%SPEECH_ON%我的文士们发现了一个藏有强大器具的地点。它在%direction%方向上一个叫作‘%objective%’的地方。那东西或许有解决这个问题的力量。当然，这样的力量总会吸引很多人。我们估计那器具附近会碰到很多形形色色的人或生物。去吧，佣兵，把它带给我，你将获得奖励。%SPEECH_OFF%他将火把转向了棺材，那里传出了一种温和的吼叫声。%SPEECH_ON%为了我们，也是为了他们。%SPEECH_OFF%  |  %employer%和他的文士将你带入了墓穴。你在哪里找到了一口被打开的棺材。两名卫兵手持长矛，与一名恶鬼般腐烂的女子僵持着。她朝着他们嘶吼咆哮着，当火光照耀出她枯萎的身躯时她的牙齿因为空咬咯嗒作响。%employer%转向你。%SPEECH_ON%我们不知道是什么导致这种情况的，但是我们觉得%direction%的叫做%objective%的位置有可能有答案。那里应该有蕴含某种力量的法器，我需要你把它带回来。我的文士建议你应该准备应对一些未知的危险。%SPEECH_OFF%不死者的小女孩低吼着，蹒跚着往前走去，将刀刃刺入了自己的身体。文士点了点头，%employer%继续道。%SPEECH_ON%如果它能解决这种折磨，天知道还能解决什么样的问题。",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{我相信你会为这趟危险的旅程提供充分的报酬的。 |  那是段很长的旅程，报酬最好丰厚些。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。 |  路途太长了。 |  我们还有更紧急的事情要处理。 |  我们需要去别的地方。}",
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
			ID = "ApproachingTheRuins",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_57.png[/img]{对，废墟。看看%employer% 和他的愚蠢文士是否知道自己在说些什么。 |  你来废墟。没有很多让你担心的了。你告诉%companyname%做好最坏的打算。 |  最终，你到达了所谓的伟大神器的家。该看看%employer% 和他的文士是否真的知道自己在说些什么了。 |  废墟斜站着，倒塌成另一边废墟。几乎不出所料，一群蝙蝠尖叫着出来了。%randombrother%弯腰，其他人发出笑声。 |  你发现 %objective%，站在附近的一座山上。往下看，你可以明白为什么它隐藏了这么久，在这样一个无害的位置。甚至在这里你都可以听到风侵蚀石料的声音。 |  你到达 %objective%， %randombrother% 就像你期望的一样评估它。%SPEECH_ON%看起来无聊得要死。我们继续吧，好吗？%SPEECH_OFF%希望他是对的。 |  %randombrother% 挺直身体。%SPEECH_ON%见鬼，我想就是它。%SPEECH_OFF%他盯着一堆废墟，而实际上似乎就是%objective%。他拍手和摩擦双手。%SPEECH_ON%我们开始动手吧。如果有巫妖在那里，我发誓我会在死了之后抱怨很久。%SPEECH_OFF%  |  %randombrother% 在远处的%objective%往下看。%SPEECH_ON%你觉得谁在下面呢？我觉得%employer%在愚弄我们。我们要去那里，受到一群美丽女人的欢迎。对我们这些勤劳的人的奖励，你知道吗？%SPEECH_OFF%出于某种原因，你不觉得会是这样。 |  %objective% 在不远处。从这里你只能看到倾斜的石雕工艺，但是气味能传播到很远。%randombrother% 遮住他的鼻子。%SPEECH_ON%闻起来像我姑姑的屎。如果那个女巫在那里，我也不会惊讶。%SPEECH_OFF%  |  靠近%objective%，你告诉你的人准备战斗。谁知道禁地里有什么在等待着%companyname%！ |  当你靠近 %objective%，听到轻柔的低语。%SPEECH_ON%{进去。进去。这是最好的。你会喜欢这里的，你会的。我们同意。是的。请快点。我们不能再等了！ |  你不是第一个。你不是第一个。你不会是最后一个。你不会是最后一个。 |  愚蠢的人，你觉得你的想法是你自己的？ |  你的人会背叛你。他们相信你没用。转回去，你这哭哭啼啼的昆虫。 |  你在这里。你会永远在这里。 |  啊，更多人类。在这种状态下，我简直受不了你的气味。你在给我呼吸的空气下毒。让我来。我要腐烂你的肚子，你会变得更好…… |  你敢来这里很勇敢，但是你只是个标本。恐惧将填满你的心，直到没有更多的空间。然后你会死。就是这样。 |  靠近小人类。这里就是我一直想让你来的地方。 |  是的！你终于来了！看到你真好，人类，真是太好了！ |  啊，另一只残忍的野兽在靠近。真是件愚蠢的小事。是的，非常愚蠢。我们该怎么办？当然让它进来。当然！}%SPEECH_OFF%%randombrother% 将一只手指放进他的耳朵。%SPEECH_ON%你说什么，先生？%SPEECH_OFF%你摇摇头，赶紧告诉他们做好准备。 |  当你靠近 %objective%，听到轻柔的低语。%SPEECH_ON%{进去。进去。这是最好的。你会喜欢这里的，你会的。我们同意。是的。请快点。我们不能再等了！ |  你不是第一个。你不是第一个。你不会是最后一个。你不会是最后一个。 |  愚蠢的人，你觉得你的想法是你自己的？ |  你的人会背叛你。他们相信你没用。转回去，你这哭哭啼啼的昆虫。 |  你在这里。你会永远在这里。 |  啊，更多人类。在这种状态下，我简直受不了你的气味。你在给我呼吸的空气下毒。让我来。我要腐烂你的肚子，你会变得更好…… |  你敢来这里很勇敢，但是你只是个标本。恐惧将填满你的心，直到没有更多的空间。然后你会死。就是这样。 |  靠近小人类。这里就是我一直想让你来的地方。 |  是的！你终于来了！看到你真好，人类，真是太好了！ |  啊，另一只残忍的野兽在靠近。真是件愚蠢的小事。是的，非常愚蠢。我们该怎么办？当然让它进来。当然！}%SPEECH_OFF%%randombrother% 将一只手指放进他的耳朵。%SPEECH_ON%你说什么，先生？%SPEECH_OFF%你摇摇头，赶紧告诉他们做好准备。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "时刻警惕！",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SearchingTheRuins",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_57.png[/img]{你终于得到了神器。它的重量似乎不在你手里，就像它应该很重，但是有什么东西让它变得很轻。你装起它，准备回去找你的雇主，%employer%。 |  你现在拿到了一直在找的神器。如果你很诚实，这就有点失望了。你有点希望它能给你巨大的力量，但实际上它静静地躺在你的手里。也许你只是不是命中注定的人。 |  你拿走神器，无视它发出的柔和嗡嗡声，准备返回%employer%。 |  你拿走神器，好好看了看它。%randombrother% 背着手走来走去。%SPEECH_ON%见鬼，那丑陋的东西没那么珍贵。%SPEECH_OFF%  |  你把神器拿在手里掂量重量。它由轻变重，然后又变轻。真够奇怪，所以你把它快速放入包里。 |  %randombrother% 看着神器，然后你把它带走。%SPEECH_ON%看起来不像。%SPEECH_OFF%你告诉他很多有力量的东西看起来都不太像。他坐在那里思考。%SPEECH_ON%我的父亲一点都不像是没事，我想你是对的。%SPEECH_OFF%  |  你把神器给%randombrother%。他拿起它。%SPEECH_ON%如果我现在把它砸了，你会生气吗？%SPEECH_OFF%你盯着那个人。%SPEECH_ON%是的，有点。但是也许里面会有小恶魔找你麻烦，因为你破坏了他们的家。谁知道呢对吧？%SPEECH_OFF%雇佣兵迅速把神器放进包里。 |  你看着神器。它一动不动，没有你所期待的巨大力量，但是这才是最令人不安的部分。你把它快速放进包里。 |  你把神器放进书包，只因为它的光芒和呼唤你。打开袋子，你看到两个红点也在看着你。%randombrother% 问你是否没事。你快速关上背包，点点头。 |  你终于拿到了神器。它不发光，不发出嗡嗡声，甚至看起来都没那么漂亮。你不知道这有什么大惊小怪的。但如果%employer%要为此付钱，那就是他的事了。 |  好吧，你获得了神器。%randombrother% 走过去，挠挠头。%SPEECH_ON%这么多人就为了这小东西而死？%SPEECH_OFF%神器咯咯响，咆哮的声音回答。%SPEECH_ON%他们没有死。他们永远和我在一起。%SPEECH_OFF%雇佣兵跳回去。%SPEECH_ON%你知道吗？我没听到。我不知道那是什么。我不在乎。不。只是回去吃硬面包，过着无聊的生活，非常谢谢你。%SPEECH_OFF%  |  你拿着神器，在之间使用布料，让它的力量渗入你的肉体。当然，它只是像华丽的大块石头，但小心驶得万年船。%employer%看到它应该会很高兴，他可以随意地拿着它。 |  神器看起来很奇怪，但也没什么不寻常。据你所知，这是别人当做虔诚对象的东西。%randombrother%盯着它。%SPEECH_ON%老实说，我有比这更漂亮的东西。%SPEECH_OFF%你警告他，如果神器真的有力量，他可能会为此评价付出代价。他耸耸肩。%SPEECH_ON%虽然不能改变事情的事实。%SPEECH_OFF%  |  你举起遗物，它突然变重，又落了回来。当你把它放低到脚下，它变轻，仿佛希望被重新拾取。你感觉很奇怪，所以你迅速把它装好，准备回去找%townname%的%employer%。 |  你终于获得了神器。当%randombrother%靠近的时候你盯着它。%SPEECH_ON%那就是%employer%想要的？我本可以制作那样的东西，给我们省去所有的麻烦。%SPEECH_OFF%你把神器放进包里回应道。%SPEECH_ON%我想他最终会知道它是假的。%SPEECH_OFF%雇佣兵伸出手指。%SPEECH_ON%关键词：最终。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们得到了此行来这要拿的东西。该回去了！",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.setState("Return");
			}

		});
		this.m.Screens.push({
			ID = "AlmostLost",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_42.png[/img]{行军时，历史学家%historian%看见你盯着地图。他要求看一看，你同意了。男子拿着它，然后合上了。%SPEECH_ON%我们走错路了。%employer%的文士一定弄错了。看到这个符号了？它实际意味着...%SPEECH_OFF%他停下了，明白不管他对你说什么都没有意义。他笑了。%SPEECH_ON%好的，基本上我们得走这边。%SPEECH_OFF%他拿出一根羽毛笔，作出更正。 |  历史学家%historian%在看%employer%给你的地图。他停顿了一下，问道。%SPEECH_ON%你说是贵族的文士创造了地图？因为都是错的。看。%SPEECH_OFF%他指给你看。%SPEECH_ON%他们误解了语言。这不是字母，是信仰的符号。这些不是字，是谜题。如果你正确地解释它们，就会带你来这里。%SPEECH_OFF%他指着一个与你想去的完全不同的地方。似乎%companyname%西药修正它的航线。 |  历史学家%historian% 盯着地图摇摇头。%SPEECH_ON%长官，我们走错路了。%employer%的文士误解了这里的符号。我们要改变方向。%SPEECH_OFF%你想要质疑这人的假设，但你宁愿相信跟着 %companyname%的吃苦耐力的历史学家，也不要相信在贵族高塔里胡编乱造的老家伙。 |  %historian% 拿出 %employer% 给你的地图查看。%SPEECH_ON%是的，不，我们走错路了。看到这个了吗？字母在这里有起有落，从右到左。这是个字谜，贵族的文士们错误地以为自己已经解决了。%SPEECH_OFF%你问这是否意味着你走错路了。%historian% 点点头。%SPEECH_ON%是的。幸好我在这里不是吗？%SPEECH_OFF%  |  你看着%employer%给你的地图。它充满了许多你看不懂的怪异符号，仿佛有人涂鸦了整个语言。历史学家%historian% 走过去，吃着他的午饭。他咀嚼着说道。%SPEECH_ON%地图错了。%SPEECH_OFF%你将面包屑从地图上抹去，问他是什么意思。他笑了。%SPEECH_ON%我的意思是地图错了。%employer%的文士不知道他们在看什么。看到那里的岩层了吗？那才是我们要去的地方。这个不错，你要来点吗？%SPEECH_OFF%他让你吃一口，但你拒绝了。%SPEECH_ON%这是你的损失。我应该去告诉人们我们要改变方向吗？%SPEECH_OFF%你叹了口气，点点头。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "有用的知识。",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						local myTile = this.World.State.getPlayer().getTile();
						local undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getSettlements();
						local lowestDistance = 9999;
						local best;

						foreach( b in undead )
						{
							if (b.isLocationType(this.Const.World.LocationType.Unique))
							{
								continue;
							}

							local d = myTile.getDistanceTo(b.getTile()) + this.Math.rand(0, 25);

							if (d < lowestDistance)
							{
								lowestDistance = d;
								best = b;
							}
						}

						this.Contract.m.Destination = this.WeakTableRef(best);
						this.Flags.set("DestinationName", this.Contract.m.Destination.getName());
						this.Contract.m.Destination.setDiscovered(true);
						this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
						this.Contract.m.Destination.clearTroops();
						this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));
						this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.UndeadArmy, 130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						this.Contract.getActiveState().start();
						this.World.Contracts.updateActiveContract();
						this.Contract.m.Dude = null;
						return 0;
					}

				}
			],
			function start()
			{
				local brothers = this.World.getPlayerRoster().getAll();
				local candidates = [];

				foreach( bro in brothers )
				{
					if (bro.getBackground().getID() == "background.historian")
					{
						candidates.push(bro);
					}
				}

				this.Contract.m.Dude = candidates[this.Math.rand(0, candidates.len() - 1)];
			}

		});
		this.m.Screens.push({
			ID = "Lost",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_42.png[/img]你到达了你应该去的地方。不过……这里什么都没有。你看着地图，发现你们走错了那里。显然，有两个岩层形状像{握着一把剑的人  |  教会受到旧神的攻击 |  带有人脸的巨大土豆 |  美丽窈窕的女人  | 狗遛着人  |  一只熊用后腿直立起来，推翻一个小女孩想喝碗里的汤  |  一个年轻人看天上的云彩，用石头遮住一块就像兔子一样，但是%randombrother%说像狗，只有你们两个认识到你们正在辩论一堆岩石云是什么样子，而它们同时被一个岩石云的观察者盯着}。你在地图上做笔记，走向真正的阵地，希望这次误入歧途没有丢失太多时间。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Damnit!",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						local myTile = this.World.State.getPlayer().getTile();
						local undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getSettlements();
						local lowestDistance = 9999;
						local best;

						foreach( b in undead )
						{
							if (b.isLocationType(this.Const.World.LocationType.Unique))
							{
								continue;
							}

							local d = myTile.getDistanceTo(b.getTile()) + this.Math.rand(0, 25);

							if (d < lowestDistance)
							{
								lowestDistance = d;
								best = b;
							}
						}

						this.Contract.m.Destination = this.WeakTableRef(best);
						this.Flags.set("DestinationName", this.Contract.m.Destination.getName());
						this.Contract.m.Destination.setDiscovered(true);
						this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
						this.Contract.m.Destination.clearTroops();
						this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));
						this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.UndeadArmy, 130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						this.Contract.m.Destination.setLootScaleBasedOnResources(130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());

						if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Destination.getTags().get("IsEventLocation"))
						{
							this.Contract.m.Destination.getLoot().clear();
						}

						this.Contract.getActiveState().start();
						this.World.Contracts.updateActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "TooLate1",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_57.png[/img]当你进入一个房间，希望找到遗物，你看到的只有一个空座和一张纸条。上面写道：%SPEECH_ON%{看来你的走狗又迟到了，%employer%。还记得你以前和我一起工作吗？这就是你得到的！ |  啊哈！是的，我写了那个，这就是我所说的当我看到那个，我再次领先了你，%employer%！可惜你走廉价路线，雇了一堆不知名的雇佣兵。祝你下一次好运。 |  如果你正在看这个，那你太慢了，%employer%错误地雇佣了你而不是我。唉，我拿到了遗物。现在回到你的雇主那里解释你是怎么输的。 |  如果你看到这个，那么你很可能是%employer%放弃了我而雇佣的雇佣兵。看看他犯了多大的错误！你是多么慢啊！你的脑袋可能受到了重击，都不能好好看这个。 |  你好雇佣兵，很遗憾我不能亲自在那里看你阅读这个的时候的表情了。我们不能总是得到我们想要的。事实上文物在我手里而不是在你手里应该很能证明这一点了。祝你下次好运，失败者，向%employer%转达我的问候。}%SPEECH_OFF%底部署名是‘%nemesis%’。\n\n 你不知道那是谁，但他现在已经是个死人了。散乱的脚印提示了这家伙去了哪里。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "一个意想不到的转折！",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						local playerTile = this.World.State.getPlayer().getTile();
						local camp = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getNearestSettlement(playerTile);
						local tile = this.Contract.getTileToSpawnLocation(playerTile, 8, 14);
						local party = this.World.FactionManager.getFaction(camp.getFaction()).spawnEntity(tile, this.Flags.get("NemesisNameC"), false, this.Const.World.Spawn.Mercenaries, 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						local n = 0;

						do
						{
							n = this.Math.rand(1, this.Const.PlayerBanners.len());
						}
						while (n == this.World.Assets.getBannerID());

						party.getSprite("banner").setBrush(this.Const.PlayerBanners[n - 1]);
						this.Flags.set("NemesisBanner", n);
						this.Contract.m.UnitsSpawned.push(party);
						party.getLoot().Money = this.Math.rand(50, 100);
						party.getLoot().ArmorParts = this.Math.rand(0, 10);
						party.getLoot().Medicine = this.Math.rand(0, 2);
						party.getLoot().Ammo = this.Math.rand(0, 20);
						local r = this.Math.rand(1, 6);

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
						else if (r == 5)
						{
							party.addToInventory("supplies/pickled_mushrooms_item");
						}

						this.Contract.m.Destination = this.WeakTableRef(party);
						party.setAttackableByAI(false);
						party.setFootprintSizeOverride(0.75);
						local c = party.getController();
						c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
						local roam = this.new("scripts/ai/world/orders/roam_order");
						roam.setPivot(camp);
						roam.setMinRange(5);
						roam.setMaxRange(10);
						roam.setAllTerrainAvailable();
						roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
						roam.setTerrain(this.Const.World.TerrainType.Shore, false);
						roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
						c.addOrder(roam);
						this.Contract.addFootPrintsFromTo(playerTile, this.Contract.m.Destination.getTile(), this.Const.GenericFootprints, 0.75);
						this.Contract.setState("Running_TooLate");
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "TooLate2",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_07.png[/img]{跟着脚印，你追上了%nemesis%和他的人。你知道就是他们，因为他们中最大的蠢货拿着遗物。看来这家伙会支持他的侮辱：他被一群武装的战士包围了。你应该谨慎靠近。 |  %nemesisC% 没那么难找到，侮辱消息可能使他落得如此。但如果不出意外，他受到很好的保护。武装人员包围了这个混蛋，而他贪婪地盯着他手里的文物。要拿到神器，%companyname%应该想出如何最好地处理这个情况。 |  你发现一个男人盯着文物。一定是%nemesis%！当你想要跳出去杀了他，%randombrother%抓住你的衬衫，把你拉回来。他指着前面，有一组武装的守卫。%companyname%应小心处理这个情况。 |  跟踪足迹并不难。你最初这么认为是因为这个 %nemesisS% 是蠢货，但事实证明他只是有着良好的保护。你发现他拿着遗物，被一群良好武装的守卫包围着。暴力是你来这里的目的，但也许还有其他方法？ |  你发现 %nemesis% 拿着遗物。他是个看上去很容易的目标，因为他留下了大量脚印，不管是出于无知还是过分自信。当你拔出剑，%randombrother%按住你的手。他向前点点头。\n\n 你看着一群人靠近 %nemesis%，要求命令。他们是他的守卫，他们有很好的武装。拿回神器可能需要超出你预想的杀戮。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "你犯了一个大错，就是向%companyname%挑战。你的最后一个人。",
					function getResult()
					{
						this.Contract.getActiveState().onCombatWithNemesis(this.Contract.m.Destination, false);
						return 0;
					}

				},
				{
					Text = "没有人需要死在这里。神器交换%bribe%克朗，你怎么说？",
					function getResult()
					{
						return this.Math.rand(1, 100) <= 50 ? "TooLateBribeRefused" : "TooLateBribeAccepted";
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "TooLate3",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_11.png[/img]{你最终拿到了神器。它的重量似乎不在你手里，就像它应该很重，但是有什么东西让它变得很轻。你装起它，准备回去找%employer%。 |  你现在拿到了一直在找的神器。如果你很诚实，这就有点失望了。你有点希望它能给你巨大的力量，但实际上它静静地躺在你的手里。也许你只是不是命中注定的人。 |  你拿走神器，无视它发出的柔和嗡嗡声，准备返回%employer%。 |  你拿走神器，好好看了看它。%randombrother% 背着手走来走去。%SPEECH_ON%见鬼，那丑陋的东西没那么珍贵。%SPEECH_OFF%  |  你把神器拿在手里掂量重量。它由轻变重，然后又变轻。真够奇怪，所以你把它快速放入包里。 |  %randombrother% 看着神器，然后你把它带走。%SPEECH_ON%看起来不像。%SPEECH_OFF%你告诉他很多有力量的东西看起来都不太像。他坐在那里思考。%SPEECH_ON%我的父亲一点都不像是没事，我想你是对的。%SPEECH_OFF%  |  你把神器给%randombrother%。他拿起它。%SPEECH_ON%如果我现在把它砸了，你会生气吗？%SPEECH_OFF%你盯着那个人。%SPEECH_ON%是的，有点。但是也许里面会有小恶魔找你麻烦，因为你破坏了他们的家。谁知道呢对吧？%SPEECH_OFF%雇佣兵迅速把神器放进包里。 |  你看着神器。它一动不动，没有你所期待的巨大力量，但是这才是最令人不安的部分。你把它快速放进包里。 |  你把神器放进书包，只因为它的光芒和呼唤你。打开袋子，你看到两个红点也在看着你。%randombrother% 问你是否没事。你快速关上背包，点点头。 |  你终于拿到了神器。它不发光，不发出嗡嗡声，甚至看起来都没那么漂亮。你不知道这有什么大惊小怪的。但如果%employer%要为此付钱，那就是他的事了。 |  好吧，你获得了神器。%randombrother% 走过去，挠挠头。%SPEECH_ON%这么多人就为了这小东西而死？%SPEECH_OFF%神器咯咯响，咆哮的声音回答。%SPEECH_ON%他们没有死。他们永远和我在一起。%SPEECH_OFF%雇佣兵跳回去。%SPEECH_ON%你知道吗？我没听到。我不知道那是什么。我不在乎。没用。只是回去吃硬面包，过着无聊的生活，非常谢谢你。%SPEECH_OFF%  |  你拿着神器，在之间使用布料，让它的力量渗入你的肉体。当然，它只是像华丽的大块石头，但小心驶得万年船。%employer%看到它应该会很高兴，他可以随意地拿着它。 |  神器看起来很奇怪，但也没什么不寻常。据你所知，这是别人当做虔诚对象的东西。%randombrother%盯着它。%SPEECH_ON%老实说，我有比这更漂亮的东西。%SPEECH_OFF%你警告他，如果神器真的有力量，他可能会为此评价付出代价。他耸耸肩。%SPEECH_ON%虽然不能改变事情的事实。%SPEECH_OFF%  |  你举起遗物，它突然变重，又落了回来。当你把它放低到脚下，它变轻，仿佛希望被重新拾取。你感觉很奇怪，所以你迅速把它装好，准备回去找%employer%。 |  你终于获得了神器。当%randombrother%靠近的时候你盯着它。%SPEECH_ON%那就是%employer%想要的？我本可以制作那样的东西，给我们省去所有的麻烦。%SPEECH_OFF%你把神器放进包里回应道。%SPEECH_ON%我想他最终会知道它是假的。%SPEECH_OFF%雇佣兵伸出手指。%SPEECH_ON%关键词：最终。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们得到了此行来这要拿的东西。该回去了！",
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
			ID = "TooLateBribeRefused",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_07.png[/img]{盗贼头目笑着摇摇头。%SPEECH_ON%你是真的……我是说，认真的？%SPEECH_OFF%他走向前继续说道。%SPEECH_ON%我想那值得一试，但答案是否定的。%SPEECH_OFF%他慢慢抽出剑。他将剑指向你，剑身发出金属光辉。%SPEECH_ON%绝不。%SPEECH_OFF%  |  你尝试贿赂但未被接收。盗贼们不但拒绝了，他们还采取了进攻！很显然，这些盗贼还是有些尊严的！ |  盗贼头目嘲笑道。%SPEECH_ON%贿赂？不。我们不是大老远受这么多罪来做这么笔小买卖的。嘿伙计们，让他们再受受罪怎么样？%SPEECH_OFF%这群破坏者欢呼着抽出武器。他们的头目剑指%companyname%说道。%SPEECH_ON%准备受死吧，雇佣兵们。%SPEECH_OFF%  |  你提出贿赂但很快被拒绝。破坏者领袖和你点了点头。起码一件事情清楚了：你们谁也不想空手而归。准备战斗！ |  强盗挤作一团然后低声交谈着。最终，其中的头目走了出来，捶胸顿足地走向前。他摇了摇头。%SPEECH_ON%我们恭敬地拒绝你的提议。现在，请让我们通过，要么接受战斗。%SPEECH_OFF%%employer%可不是付钱让你空手而归的。你下令%companyname%列队。强盗叹息着抽出剑。%SPEECH_ON%那就动手吧！%SPEECH_OFF%  |  破坏者们嘲笑你的提议。似乎他们同样将其作为示弱的信号因为他们全都抽出了武器。你原以为提议很合理，但似乎这些人希望用极致价格出售这样物品。那就这样吧。准备战斗！ |  盗贼头目笑道。%SPEECH_ON%你的提议很有意思，但我要拒绝。我觉得我们都很清楚这个小遗物不止那个价，而且显然比你能提供的任何东西都要值钱。现在给我让开。%SPEECH_OFF%%companyname%开始列队，抽出武器。%randombrother%吐了口口水道。%SPEECH_ON%我们可以杀光他们，长官，请下令吧。%SPEECH_OFF%你极信任%companyname%因为那就是暴力的宗教。该将我们所布道的付诸实践了！ |  强盗们将手伸进袋子然后掏出一颗脑袋。那是一种骇人的灰色，且随着他握在指尖的头发旋转着。%SPEECH_ON%上一个挡我们道的人就是这样的下场。我们恭敬地拒绝你的提议，佣兵。现在离开这儿否则我的友善也将总结与此。%SPEECH_OFF%你笑着回应道。%SPEECH_ON%我们是%companyname%，太遗憾了在我杀光你们之后没有人会知道你们是谁因为你们没的咆哮了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.Contract.getActiveState().onCombatWithNemesis(this.Contract.m.Destination, false);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "TooLateBribeAccepted",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_07.png[/img]{讨论一阵后，盗贼们同意了你的提议。你递过克朗而他们也递过遗物。比料想的要简单得多。 |  强盗们谈论着，挤在一起且不时探出头来看看你。这是场奇怪的折磨，考虑到几分钟后你们将可能依据他们的决定相互厮杀。最终，他们散开来了，他们的领袖招呼你过去。%SPEECH_ON%我们的雇主不会开心的，但那些钱显然不够。就是这么着，佣兵。%SPEECH_OFF%  |  破坏者们为了你的提议而争论。有人说他们的雇主发现他们空手而归将会非常不开心，而其他人则表示不值得为之送命。最终后者赢了。你用钱交换来了遗物。 |  如果你打交道的是一群有操守的人他们可能会试图与%companyname%作战，但你所面对的本身就是一群盗贼，他们可跟操守搭不上边。他们同意交出遗物换钱。 |  盗贼头目抽出剑。%SPEECH_ON%你真的认为我们会接受那……%SPEECH_OFF%他的胸膛突然被一柄长剑刺穿，在他说完那句话前血浆喷涌而出。盗贼转回视线看向杀他的人，后者将靴子踩在他背上并且踢掉了他的剑。杀手抹干净自己的武器。%SPEECH_ON%我们可不要为了那杂种去死。我们同意你的提议，佣兵。%SPEECH_OFF%  |  盗贼之中出现了争论。有些人认为他们可以干掉你，而其他人则更清楚%companyname%的为人，后一派对于任何战争的反感都相当强烈。最终，他们达成协议：接受贿赂。 |  你提议支付报酬换遗物在盗贼中激起了相当大的争论。他们激烈地争论着，但他们的视线似乎都标明他们把你视作最具威胁的存在。最终，他们散开来同意了你的条件。你很开心没有引发流血事件。 |  盗贼嘲笑道。%SPEECH_ON%你认为我们能空手返回恩人那吗？%SPEECH_OFF%你伸手拂过头发回应道。%SPEECH_ON%没有回音啊，是吗？%SPEECH_OFF%每个贼都警惕地后退了一步。他们的领袖摇晃着脑袋然后突然点了一下头。%SPEECH_ON%该死，佣兵，你让我们陷入这样的困境。但没事，我们接受。%SPEECH_OFF%遗物成功转交暴力冲突被避免。 |  盗贼头目转向人群然后诚挚地问道。%SPEECH_ON%你们怎么看，兄弟们，觉得我们能干的过他们吗？%SPEECH_OFF%一个人耸耸肩。%SPEECH_ON%我觉得我们可以收下那笔钱。%SPEECH_OFF%另一个人尖声叫嚷道。%SPEECH_ON%这本来是一场探险，我们收的钱可不足以为了这该死的遗物死在这。%SPEECH_OFF%慢慢地，强盗达成协议：他们愿意接受贿赂而不是被屠杀。怎么看都是机智的选择。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "你们做出了正确的决定。",
					function getResult()
					{
						this.Contract.m.Destination.getController().getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
						return "TooLate3";
					}

				}
			],
			function start()
			{
				local bribe = this.Contract.beautifyNumber(this.Contract.m.Payment.Pool * 0.4);
				this.World.Assets.addMoney(-bribe);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]" + bribe + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "Trap",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_12.png[/img]{你跨过一张绊网并让%hurtbro%小心点。但他并没有如你所说，因为大意踩中了陷阱。 |  废墟地面布满了明显的陷阱和致命的玩意。你们成功穿过了大多数这些东西，直到%hurtbro%认为已经安全突然前冲。古代机械被触发，你以为整个地方都要你在头顶坍塌了。幸运的是，只有那个雇佣兵因为他的轻率付出了代价。 |  废墟布满陷阱，而%hurtbro%成功触发了其中一个。 |  %hurtbro%的脚踩在一块砖上，一下掉了下去。古代机械装置在墙后轰隆作响而天花板也开始崩溃。尽管吵闹声很大，陷阱自身还是相当小的，而佣兵也不至于丧命。 |  墙上的符号通过图画清楚刻画出古代的深谋远虑。不幸的是，那些简笔画太过潦草以至于在辨识清楚它是警告符号之前已经太迟了：%hurtbro%闯入了一个陷阱，并且由于你糟糕的翻译技能吃了很多亏。 |  你本该知道地更清楚些：废墟布满陷阱而%hurtbro%恰巧踩中了一个。他能活下来，而且从现在起你会更安全。 |  %hurtbro%触发了一个陷阱，并且由于他的粗心大意吃了很多亏。 |  很久，很久以前，有个人坐下来制作一个陷阱。而今天，%hurtbro%正好踩中了它。 |  你触发了一个绊网并且听到墙壁随着古代机械似乎拥有了生命力。你急速低头，一位自己安全了，转身却看到%hurtbro%承受了陷阱的冲击伤害。啊呀…… |  你看到地面上的绊网笑了。好险，古代陷阱，差一点——突然，%hurtbro%就这么从你身边走过然后触发了陷阱。这白痴能活命，但有的疼了。 |  %hurtbro%的口哨和语调传到废墟深处，但回声似乎相当遥远，仿佛是墙壁某处的打嗝声。你告诉大家待在原地，但吹口哨的家伙还继续往前走然后一下子掉到一个坑里。你冲到坑边看到他躲过了一些尖刺。 |  在废墟中走的时候，%hurtbro%触发了一个陷阱，使他垂直落到地面之下。他掉落在更低的一个平面，那上面布满一个个洞。尖刺从下面冒出来，但速度很慢，足以让那家伙来得及躲闪。感激的是，陷阱没有按正确顺序触发所以你能把佣兵从那救出来。 |  在蜿蜒穿过这迷惑的废墟中时，%hurtbro%突然掉出视线。你冲过去看到他差点掉进相同的陷阱：一个满是脆脆的蛇皮的洞坑。感激的是，蛇现在没在其中，但那一摔也够让这倒霉佣兵疼上一阵了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "小心一点！",
					function getResult()
					{
						this.Contract.m.Dude = null;
						return "SearchingTheRuins";
					}

				}
			],
			function start()
			{
				local brothers = this.World.getPlayerRoster().getAll();
				local bro = brothers[this.Math.rand(0, brothers.len() - 1)];
				local injury = bro.addInjury(this.Const.Injury.Accident1);
				this.Contract.m.Dude = bro;
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = bro.getName() + " suffers " + injury.getNameOnly()
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "ScavengerHunt",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_57.png[/img]{你在废墟中找到一张地图，上面似乎显示遗物其实位于这里%direction%叫做%objective%的废墟中。 |  不幸的是，遗物不在这。调查显示你来这是来错了：你在找的东西实际上在%direction%的%objective%中。 |  情况是，你来错地方了。你和你的属下尽全力解密墙上的语言并与地图上的相比较。过了一段时间，你发现你在找的遗物更倾向于位于%direction%一个叫%objective%的地方。 |  %randombrother%给你拿来了地图然后小声诅咒道。%SPEECH_ON%长官，我们似乎来错地方了。看这个。%SPEECH_OFF%你们一起研究了下后发现遗物最有可能是位于%direction%一个叫做%objective%的地方。 |  你原本希望能一趟找到遗物，但那现在是不可能了。经过仔细的调查，战团逐渐发现自己来错地方了。他们要去到%direction%的%objective%。 |  错误的废墟。墙上的一些引导标识和显然这里并没有遗物的情形跟你表达了同样一个意思。经过仔细的推断，你发现遗物实际上是在%direction%的%objective%。 |  穿过废墟却一无所获，你逐渐发现自己是来错地方了。你和%randombrother%研究了好一会儿地图，然后发现遗物实际上是在%direction%一个叫做%objective%的地方。 |  %randombrother%发现一个被数枚陷阱触发的尖刺钉住的人。他腐烂露出骨头的手中握有一张地图。你看了地图意识到，就像这个人一样，你来到了错误的废墟。遗物实际上是在%direction%的%objective%中。好消息是这个胆小的探险家在你之前来的这里！ |  发现一具尸体缩成一团处在通往空矮墙前几步的位置。你认为那是遗物原本应该在的位置，但它并不在那。死人身上似乎也没有。%randombrother%在尸体衣服上找到一张折叠的地图。那通往%direction%一个叫做%objective%的地方。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备继续上路，伙计们！",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Destination = null;
				local myTile = this.World.State.getPlayer().getTile();
				local undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getSettlements();
				local lowestDistance = 9999;
				local best;

				foreach( b in undead )
				{
					if (b.isLocationType(this.Const.World.LocationType.Unique))
					{
						continue;
					}

					local d = myTile.getDistanceTo(b.getTile()) + this.Math.rand(0, 35);

					if (d < lowestDistance)
					{
						lowestDistance = d;
						best = b;
					}
				}

				this.Contract.m.Destination = this.WeakTableRef(best);
				this.Flags.set("DestinationName", this.Contract.m.Destination.getName());
				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
				this.Contract.m.Destination.clearTroops();
				this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));
				this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.UndeadArmy, 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.getActiveState().start();
				this.World.Contracts.updateActiveContract();
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer%的门开着，你走了进去。他转头带着“怎么了？”的疑问之意注视了你很久。你拿出遗物。贵族突然跳起来。%SPEECH_ON%你找到它了！古神保佑！我来看看！%SPEECH_OFF%遗物被转交，%employer%瞪大了眼睛。你询问酬劳的事，但他仿佛已经进入了另一个世界，好像被吸进遗物中了一样。他的其中一个文士从阴暗角落中走出。他递给你一包%reward_completion%钱。%SPEECH_ON%你可以走了，雇佣兵。我的主人和我还有其他要事要处理。%SPEECH_OFF%  |  %employer%深陷于椅子中，或许是在思考更深层次的问题。他的一个守卫告诉他你到了，重复了3遍贵族才抬起头。他盯着你，然后盯着遗物。他从椅子上起身，仿佛是被某种看不见的力量刺激唤回生机。他拿着遗物然后转来转去，冲到桌子前将其放好然后蹲在其跟前，几乎是俯卧着，用异样的热情观察着它。守卫教给你一袋%reward_completion%钱。%SPEECH_ON%你最好离开这，佣兵。%SPEECH_OFF%  |  %employer%的一个文士在贵族房外欢迎你。他满嘴酸儒味开口道。%SPEECH_ON%那是遗物吗？是吗？%SPEECH_OFF%你交出一个装有遗物的袋子。文士的手指像鸟嘴勾住虫子般扣住遗物。%SPEECH_ON%拿过来！给我！拿着，拿上钱然后离开！%SPEECH_OFF%他将一袋%reward_completion%钱丢到你手上然后迅速进到%employer%的房间。 |  一群文士在%employer%的房内等待。贵族自己则睡在床上，面朝天花板，手臂放于两侧仿佛人体模型的半成品。其中一个文士走向前。%SPEECH_ON%遗物，把它拿过来。%SPEECH_OFF%这相当古怪，但你确信那不会吵醒沉睡的陛下。你询问酬劳。另一个文士扔了一袋%reward_completion%钱给你，袋子滑到石制地面上。%SPEECH_ON%现在把遗物放在地上然后离开。%SPEECH_OFF%你收下钱走了。 |  你发现%employer%在迎合一群贵族。他透过他们的脑袋监视着你，然后继续攀谈然后告辞。他溜到房间这边笑声跟你打招呼。%SPEECH_ON%拿到遗物了吗？%SPEECH_OFF%你把东西交给他，他咧嘴而笑。他给了你一袋%reward_completion%钱。%SPEECH_ON%辛苦了，佣兵，但你该走了。这不是你的人。那也不是我的。%SPEECH_OFF%他朝你眨了眨眼然后发出嘘声赶你走。 |  一个文士在%employer%房间外拦下了你。他手指捻嘴唇摇着头然后将你带入大厅。老者站在火盆前，快速扫视周围然后拉下一个火把。%SPEECH_ON%推墙，佣兵。%SPEECH_OFF%你照做了。其中一块完全不是石头，而是木头。它滑开了然后你走了过去。%employer%和一堆书待在里面，奇怪的物品散落在这个昏暗、用蜡烛照明的房间中。他弯折手指，你则递过遗物。作为回报，你收到一袋%reward_completion%钱。贵族停顿了下，然后看着他的抄写员说道。%SPEECH_ON%等等，这地方本应是个秘密，你在干什么？%SPEECH_OFF%老人尴尬地皱起嘴巴。贵族按了按额头说道。%SPEECH_ON%该死。好吧，只能再叫泥瓦匠过来了。%SPEECH_OFF%  |  你找到%employer%然后把遗物交给他。他给了你一袋%reward_completion%钱然后就这样完成了交易。好吧，还真是虎头蛇尾。 |  %employer%站在几个几个指挥官前。他们看着你进来，贵族拿出手叉在桌前。你慢慢走向前然后将遗物放在他的手掌中。他收下了，仔细端详着，然后瞥了你一眼。他抓住手指。%SPEECH_ON%付给他钱。%SPEECH_OFF%其中一位指挥官给了你一袋%reward_completion%钱然后你很快被领出房间。 |  一个非常像%employer%的人在贵族的房间等待着你。他让你交出遗物，你照做了。男人停了下来，握住他，他的眼睛看向四周。最终，他将其放在地上然后大喊起来。%SPEECH_ON%似乎好了！%SPEECH_OFF%突然，真正的%employer%在房间一旁出现，小心地走向前。%SPEECH_ON%抱歉这么喜剧，但这里有你无法理解的力量。%SPEECH_OFF%你怀疑遗物能像潜在杀手一样活过来，但你显然不会质疑贵族疯狂的想法。你接受了%reward_completion%并开心地离开。 |  %employer%在房外见你。他面色通红满是汗水且几乎是守着门一样。%SPEECH_ON%晚上好，佣兵。你拿到我所要求的的东西了吗？%SPEECH_OFF%你交过遗物。男人露齿而笑然后给了你一袋%reward_completion%钱。他转身返回房间，然后顿了顿。%SPEECH_ON%嘿，离开这。我可不是付钱让你站在那看着我的。%SPEECH_OFF%你点头离开。你离开时，听到房门打开以及一阵女人的声音从门缝流出。 |  其中一个%employer%守卫把你带到花园，贵族正在照料自己的农作物。他正在教一个男孩修剪西红柿。%SPEECH_ON%茎干，白痴！剪这里，懂了吗？你戳食物干嘛？永远不要戳食物！佣兵！%SPEECH_OFF%陛下看到你后站直了身子。他把男孩推开然后过来问你是否拿到了遗物。你递过遗物然后收到了%reward_completion%钱回报。贵族点点头。%SPEECH_ON%干得不错，佣兵。我都快对个体做事的能力失去信心了。我敢肯定你能理解。%SPEECH_OFF%贵族肩膀后面的男孩正在暗杀另一株植物。你缓缓点头。 |  你把遗物交给%employer%。他眉头紧锁地盯着它，愤怒地在桌上转动手指。%SPEECH_ON%嗯，应该就是它了。有点失望，但协议鬼协议。%SPEECH_OFF%他小气地将一袋%reward_completion%钱滑到你手中。 |  %employer%欢迎你进房间，给了你一杯酒。你喝着酒，然后一位文士走过来拿走了遗物。他走到房间一边开始测量、称重，甚至……尝味？你无论那里所发生的一切然后开始询问你的报酬。%employer%露齿而笑。%SPEECH_ON%你正在喝它呢！%SPEECH_OFF%你酒杯还在唇边停了下来。贵族笑了。%SPEECH_ON%开个玩笑，佣兵，放松！给，跟约定的一样，%reward_completion%钱。%SPEECH_OFF%  |  你打开%employer%的门发现贵族和几个文士正站在桌前。形状奇怪的烧瓶、长颈瓶摆满了桌子，其中一些里面甚至颜色古怪。其中一位文士急忙跑向你然后在他异常宽大的袖子中伸出手，犹如长蛇出洞。他用一只手拿走遗物，另一只则将一袋%reward_completion%钱丢到你的胸口。%employer%挥手示意你离去。%SPEECH_ON%你可以走了，佣兵，你完成了我们所要求的的，这就行了。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一笔数量可观的克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Procured an artifact important for the war effort");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isUndeadScourge())
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
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"hurtbro",
			this.m.Dude == null ? "" : this.m.Dude.getName()
		]);
		_vars.push([
			"historian",
			this.m.Dude == null ? "" : this.m.Dude.getNameOnly()
		]);
		_vars.push([
			"objective",
			this.m.Flags.get("DestinationName")
		]);
		_vars.push([
			"nemesis",
			this.m.Flags.get("NemesisName")
		]);
		_vars.push([
			"nemesisS",
			this.m.Flags.get("NemesisNameS")
		]);
		_vars.push([
			"nemesisC",
			this.m.Flags.get("NemesisNameC")
		]);
		_vars.push([
			"bribe",
			this.beautifyNumber(this.m.Payment.Pool * 0.4)
		]);
		_vars.push([
			"direction",
			this.m.Destination == null  ||  this.m.Destination.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Destination.getTile())]
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Destination != null && !this.m.Destination.isNull())
			{
				this.m.Destination.getSprite("selection").Visible = false;
				this.m.Destination.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return false;
		}

		return true;
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
		local destination = _in.readU32();

		if (destination != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}

		this.contract.onDeserialize(_in);
	}

});

