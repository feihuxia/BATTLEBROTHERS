this.free_greenskin_prisoners_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Dude = null,
		BattlesiteTile = null
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.free_greenskin_prisoners";
		this.m.Name = "释放绿皮的囚犯";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		if (this.m.BattlesiteTile == null  ||  this.m.BattlesiteTile.IsOccupied)
		{
			local playerTile = this.World.State.getPlayer().getTile();
			this.m.BattlesiteTile = this.getTileToSpawnLocation(playerTile, 6, 12, [
				this.Const.World.TerrainType.Shore,
				this.Const.World.TerrainType.Ocean,
				this.Const.World.TerrainType.Mountains
			], false);
		}

		this.m.Payment.Pool = 1350 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
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

		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"搜索 %direction% 的 %origin%战场寻找线索",
					"释放你找到的任何囚犯"
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
				if (this.Contract.m.BattlesiteTile == null  ||  this.Contract.m.BattlesiteTile.IsOccupied)
				{
					local playerTile = this.World.State.getPlayer().getTile();
					this.Contract.m.BattlesiteTile = this.getTileToSpawnLocation(playerTile, 6, 12, [
						this.Const.World.TerrainType.Shore,
						this.Const.World.TerrainType.Ocean,
						this.Const.World.TerrainType.Mountains
					], false);
				}

				local tile = this.Contract.m.BattlesiteTile;
				tile.clear();
				this.Contract.m.Destination = this.WeakTableRef(this.World.spawnLocation("scripts/entity/world/locations/battlefield_location", tile.Coords));
				this.Contract.m.Destination.onSpawned();
				this.Contract.m.Destination.setFaction(this.Const.Faction.PlayerAnimals);
				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
				this.World.Assets.addMoney(this.Contract.m.Payment.getInAdvance());
				local r = this.Math.rand(1, 100);

				if (r <= 5)
				{
					this.Flags.set("IsSurvivor", true);
				}
				else if (r <= 10)
				{
					this.Flags.set("IsLuckyFind", true);
				}
				else if (r <= 15)
				{
					this.Flags.set("IsAccident", true);
				}
				else if (r <= 35)
				{
					if (this.Contract.getDifficultyMult() > 0.85)
					{
						this.Flags.set("IsScouts", true);
					}
				}

				r = this.Math.rand(1, 100);

				if (r <= 50)
				{
					this.Flags.set("IsEnemyCamp", true);

					if (this.Math.rand(1, 100) <= 20 && this.Contract.getDifficultyMult() < 1.15)
					{
						this.Flags.set("IsEmptyCamp", true);
					}
				}
				else
				{
					this.Flags.set("IsEnemyParty", true);
				}

				if (this.Math.rand(1, 100) <= 20)
				{
					this.Flags.set("IsAmbush", true);
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
				}
			}

			function update()
			{
				if (!this.TempFlags.get("IsBattlefieldReached") && this.Contract.isPlayerAt(this.Contract.m.Destination))
				{
					this.TempFlags.set("IsBattlefieldReached", true);
					this.Contract.setScreen("Battlesite1");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsScoutsDefeated"))
				{
					this.Flags.set("IsScoutsDefeated", false);
					this.Contract.setScreen("Battlesite2");
					this.World.Contracts.showActiveContract();
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Scouts")
				{
					this.World.Contracts.removeContract(this.Contract);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Scouts")
				{
					this.Flags.set("IsScoutsDefeated", true);
				}
			}

		});
		this.m.States.push({
			ID = "Pursuit",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"跟随绿皮的足迹到达战场",
					"释放你找到的任何囚犯"
				];

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;

					if (this.Flags.get("IsEmptyCamp"))
					{
						this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onDestinationAttacked.bindenv(this));
					}
				}
			}

			function update()
			{
				if ((this.Contract.m.Destination == null  ||  this.Contract.m.Destination.isNull()) && !this.Flags.get("IsEmptyCamp"))
				{
					this.Contract.setScreen("Battlesite3");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsAmbush") && !this.Flags.get("IsAmbushTriggered") && !this.TempFlags.get("IsAmbushTriggered") && this.Contract.m.Destination.isHiddenToPlayer() && this.Contract.getDistanceToNearestSettlement() >= 5 && this.Math.rand(1, 1000) <= 2)
				{
					this.TempFlags.set("IsAmbushTriggered", true);
					this.Contract.setScreen("Ambush");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsAmbushDefeated"))
				{
					this.Contract.setScreen("AmbushFailed");
					this.World.Contracts.showActiveContract();
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Ambush")
				{
					this.Flags.set("IsAmbushTriggered", true);
					this.World.Contracts.removeContract(this.Contract);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Ambush")
				{
					this.Flags.set("IsAmbushTriggered", true);
					this.Flags.set("IsAmbushDefeated", true);
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				this.Contract.setScreen("EmptyCamp");
				this.World.Contracts.showActiveContract();
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"和被释放的囚犯返回 " + this.Contract.m.Home.getName()
				];

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(null);
				}

				this.Contract.m.Home.getSprite("selection").Visible = true;
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{当你找到%employer%时，他正揪着一名歇斯底里声音嘶哑农民的耳朵。显而易见，绿皮怪物掠夺了附近的一座村庄并且带着囚犯跑了。贵族立刻找上了你：将那些人带回来…当然是有赏金的。 |  当你走进%employer%的房间时，他正盯着一些地图。他身边的数名指挥官正用棍棒在纸质地形图上点点画画。当他看见你时便立刻示意你上前来。%SPEECH_ON%佣兵，我们遇到麻烦了。想必你也注意到了，绿皮怪物一直掠夺这片土地，但是最近据报告称，他们夺走了一些囚犯。虽然尚不清楚他们的目的，但是我们知道他们最后出现的地点。如果你前往那里，或许能得到些许有关他们如今行踪的线索。希望这能让你感兴趣，佣兵。%SPEECH_OFF%  |  你看到%employer%和一名农民在谈话。几名卫兵拉着农民的手臂，很明显是被拽到贵族身前的。你本以为是农民犯罪了，但结果%employer%和贱民说话的方式就是如此。据消息称，绿皮怪物掠夺了当地并且带走了一批囚犯。他们留下了不少线索，应该不难追踪，至于是否接下任务就看你自己了。 |  %employer%耷拉在椅子上。%SPEECH_ON%人民逐渐对我失去了信心。有谣言称，绿皮怪物不仅仅掠夺村庄，而且还带走了囚犯。这就更糟糕了！但是如果有人助我一臂之力将那些人弄回来，人们可能又会开始相信我了。佣兵，你意下如何，愿意帮我找到那些失踪的可怜人吗？当然了，钱不会少你的。%SPEECH_OFF%  |  %employer%正与一名指挥官交谈着。%SPEECH_ON%无须担心，我们会夺回他们的。%SPEECH_OFF%一看到你贵族就迅速告诉你与绿皮怪物爆发了大战，而且据报告称，囚犯被夺走了。指挥官手插在腰带上，上前一步，一柄大剑叮当作响。%SPEECH_ON%佣兵，要是你能带回那些人那就太好了。%SPEECH_OFF%  |  %employer%正与一名指挥官争论着。%SPEECH_ON%听着，我们不能再派人出去了。%SPEECH_OFF%指挥官指了指你。%SPEECH_ON%那他呢？%SPEECH_OFF%很快你获悉了局势：此处%direction%与绿皮怪物爆发了大战，并且囚犯被带走了。%employer%没有足够的人手了，需要你这样的自由人帮忙做事。 |  你发现%employer%正盯着一张地图。他用手指了指某处。%SPEECH_ON%此处%direction%与绿皮怪物爆发了一场大战。我们有理由相信囚犯在他们手中—而且你应该能将他们抢回来。%SPEECH_OFF%  |  一名卫兵拄着拐杖蹒跚着向你走来。他腿上的鲜血在石质地板上流了一地。%SPEECH_ON%你是%companyname%的人，对吧？%employer%让我与你碰个面。%SPEECH_OFF%他解释道，此处%direction%与绿皮怪物爆发了大战，而且带走了一批囚犯。你问他为什么没有得到医疗救援。%SPEECH_ON%我，呃，我是逃兵。这是我的惩罚。无论如何，医师说我只有不到一个月的时间了。看到这个了？很恶心吧？%SPEECH_OFF%他小心翼翼地抬起腿。绷带周围都是绿色的脓包。真是恶心啊。 |  %employer%正在从爱犬口中夺走一个墨水瓶。%SPEECH_ON%笨狗，吞下那玩意你就死翘翘了，难道就不懂吗？%SPEECH_OFF%贵族看到你便挺直了身躯。%SPEECH_ON%佣兵！艰难时期见到你真是太好了。这里%direction%的地方与绿皮怪物爆发了大战，而且指挥官报告说那些蛮子带走了一些囚犯！我需要你这样的人救回他们。%SPEECH_OFF%当你在考虑时，那只狗一口吞下了墨水瓶，然后立即开始呕吐。伴随着黑色呕吐物出来了。一支羽毛笔就躺在呕吐物总。%employer%难以置信地举起手。%SPEECH_ON%我找这玩意花了一个钟头！该死的笨狗，羽毛笔是我的最爱！%SPEECH_OFF%  |  你看到%employer%打开了一张卷轴。他认真地地读着，而沉思的文士看向他的身后。贵族一把将纸甩在桌子上，挥手示意你进来。%SPEECH_ON%这里的%direction%与绿皮怪物爆发了一场大战，并且那些蛮子带走了囚犯！囚犯啊，你敢信？%SPEECH_OFF%你还没搭上话，%employer%就继续说道。%SPEECH_ON%听着，我已经没有多余的人手了，但是如果那些绿皮怪物真的抢走了囚犯，那或许我能信赖你这样有能力的人将他们夺回来？%SPEECH_OFF%  |  %employer%的一名指挥官在屋外与你见面。他交给你一卷写有指示的卷轴。据报告称，这里的%direction%爆发了大战，绿皮怪物带走了一些囚犯。%employer%想夺回那些人，但是并没有多余的人手了。指挥官揣着双臂放在胸前。%SPEECH_ON%如果你想谈谈看的话，我的主子已经授予了我权力。%SPEECH_OFF%  |  %employer%正在屋子里追着一只猫，直到猫爬上了屋顶才停了下来，猫紧紧地抓着窗户架。贵族抬头怒视着它。%SPEECH_ON%气死我了，任何谩骂都无法描述我对那该死东西的憎恨。%SPEECH_OFF%他转头看到了你。%SPEECH_ON%佣兵！真是让我望穿秋水！我需要帮忙，当然不是那该死的猫了。这里的%direction%，我的兵蛋子与绿皮怪物爆发了一场大战。报告上说那群蛮子夺走了一些囚犯。而我觉得你是夺回他们的合适人选。%SPEECH_OFF%猫咪叫着弓着身子。%employer%来回踱步，一根手指指出。%SPEECH_ON%你麻溜的给我跳下来！快点！%SPEECH_OFF%  |  一群指挥官站在%employer%身边。身前的桌子上摆着一颗头颅。%employer%看向你。%SPEECH_ON%这里的%direction%一支小队与绿皮怪物爆发了战斗。如果你还没注意到的话，那么结果是我们输了。并且他们夺走了一些囚犯，我很想将他们救回来。佣兵，我觉得你是这项任务的完美人选，你意下如何？%SPEECH_OFF%  |  %employer%身边站着一名瘦弱的小孩，他拿出了地图并叙说了亲眼见到的事情：这里的%direction%，一支小队与绿皮怪物爆发了战斗并且输了。那些蛮子然后带着一些囚犯离开了。%employer%转头看向你。%SPEECH_ON%这样啊，如果这个瘦猴子农民所言属实，那我们得夺回那些人。佣兵，你意下如何？有兴趣营救我的士兵么？%SPEECH_OFF%  |  %employer%正与一名哭泣的指挥官说着话。%SPEECH_ON%那这么说的话，这里的%direction%，你们遇到了一群绿皮怪物，然后战败了，而你就逃掉了，眼睁睁看着自己的手下成为阶下囚？%SPEECH_OFF%指挥官点点头。%employer%示意卫兵上前。%SPEECH_ON%毫无荣誉感的懦夫没有资格待在这里，把他带走！而你，佣兵！我需要强者去营救那些俘虏！%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{我相信你会维持慷慨解囊的。 |  那就来谈谈价钱吧。 |  只要价钱合理，什么都能做。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。 |  我们需要去别的地方。}",
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
			ID = "Battlesite1",
			Title = "战斗地点…",
			Text = "[img]gfx/ui/events/event_22.png[/img]{未闻其味，先闻其声，辛勤劳作的苍蝇嗡嗡作响。残尸遍野，满是昆虫，人类与绿皮怪物战斗的地方堪称瘟疫散播点，其中都能感受到对胜利的孤注一掷，但实际上双方都是输家。你挥手赶走密集的苍蝇，命令%companyname%开始寻找幸存者或线索。 |  浮尸遍野。到处都是马匹。一匹马惊慌逃窜至远方，仿佛突然发了狂。内脏的气味变了。每走一步都会踏入一片血泊。%randombrother%拿起一块布放在鼻子边。%SPEECH_ON%长官，我们会开始寻找线索，但是会有不少困难。%SPEECH_OFF%  |  硝烟寥寥，鲜血与土壤混合而成的血泥。你站在战场上，命令雇佣兵分头寻找线索。%randombrother%盯着一个被断草叉刺穿的绿皮怪物，而兽人自己则用锈蚀的剑刃看中了凶手的头颅。他摇了摇头。%SPEECH_ON%好了。‘线索’，这么一目了然，还用动脑子想吗。%SPEECH_OFF%你提醒他，绿皮怪物掳走了一些人，而%companyname%是来营救他们的。 |  %randombrother%望向战场。%SPEECH_ON%这鬼地方真的会有幸存者？%SPEECH_OFF%说实话，这地方就像是一颗尸体巨球从天而降，血染大地，简直快不认识这个地方了。尸体的惨死方式五花八门，有嘴巴大张的兽人，仿佛在永恒的怒吼，缺胳膊少腿的男人女人。尸体堆下的战马腿剪刀般矗立在空中，就像某种兽性爆发的诡异图腾。虽然不确定是否战俘被带离了这里，你仍然下令%companyname%开始寻找。 |  从这离开的俘虏就像是离开九幽深渊的恶魔。死者的肢体缠结不清，骨刺突出，让人难以相信会有幸存者。就仿佛一大群人和野兽站在一起，然后一块极具毁灭性的巨石装上他们所有人，于是酿造了眼前的惨剧。简直难以以一言蔽之。%randombrother%拿起一块布，低头看了看，挥手赶走眼前的苍蝇。%SPEECH_ON%好吧，看来我们得开始寻找踪迹了。呃，但是可做不出任何保证。%SPEECH_OFF%  |  尸海中寻找踪迹无异于大海捞针。%randombrother%双手放到伸手，大笑中充满了怀疑。%SPEECH_ON%这人间惨剧会有幸存者就够稀奇了，更别说被带走当俘虏了。%SPEECH_OFF%你耸耸肩，给%companyname%下达了寻找线索的命令。 |  你感觉这地方曾是逃亡情侣和玩心重孩童的静谧地点。现在土地变得泥泞不堪，而尸体到处都是，这场混乱终幕留下的足迹也十分的多。%randombrother%摸了摸眉毛。%SPEECH_ON%真是狗屎。好吧，看来我们得四处找找有没有足迹了。%SPEECH_OFF%  |  你发现了战场。%randombrother%身子后仰，眼前的惨像让他发笑。%SPEECH_ON%天啊，到底什么鬼？搞没搞错！%SPEECH_OFF%先是爆发了大战。人类与野兽间的。极度的绝望。濒死之人又拉上了不少垫背的。然后又是倾盆大雨。完全变成了泥泞。真正大屠杀的血腥之地。而你，雇佣兵，见证者，在血腥泥泞中清理寻觅，在全然的毁灭中核算。你摇摇头，开始下达命令。%SPEECH_ON%我们是来寻找线索的。别放过任何离开这里的足迹。活下来的一方肯定带走了俘虏。%SPEECH_OFF%  |  放眼望去，几乎全是断肢残臂。这一切表明人类和野兽曾经在这里相遇，而其野蛮行为让勇士们不再完整。%randombrother%动了下棍子末端插着的鞋子，结果一只脚从中滑了出来。他摇摇头。%SPEECH_ON%好了，我们要开始寻找线索了，但要是真有幸存者，那我真是见了鬼了，更别说还带走俘虏了。%SPEECH_OFF%  |  %randombrother%看向战场。%SPEECH_ON%该死。%SPEECH_OFF%你找到了战争中留下的遗体，残缺不全的绿皮怪物和人类，简直是一场鲜血仪式。马儿都在一边，看着这景象，仿佛好奇中又充满了纠结。当你的手下开始寻找线索时，那些马儿一哄而散。你下达了命令。%SPEECH_ON%记住了，那些绿皮怪物带走了俘虏！兄弟们，寻找足迹。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "别放过任何角落！",
					function getResult()
					{
						if (this.Flags.get("IsAccident"))
						{
							return "Accident";
						}
						else if (this.Flags.get("IsLuckyFind"))
						{
							return "LuckyFind";
						}
						else if (this.Flags.get("IsSurvivor") && this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
						{
							return "Survivor";
						}
						else if (this.Flags.get("IsScouts"))
						{
							return "Scouts";
						}
						else
						{
							return "Battlesite2";
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Battlesite2",
			Title = "战斗地点…",
			Text = "[img]gfx/ui/events/event_22.png[/img]{%randombrother%发现了一串足迹一路延伸至战场之外。%companyname%应该跟着这些足迹！ |  发现了一组足迹一路延伸至战场之外。有人类的，也有兽人的。如果跟着足迹应该就能找到俘虏。 |  %randombrother%蹲下身子，示意你过来看看。他指向地上的图像。%SPEECH_ON%长官，你觉得这些像什么？%SPEECH_OFF%你看到了大小不一的鞋印。而且还有一些边上有小点点的小脚印。你依次猜测道。%SPEECH_ON%人类，兽人，哥布林。如果我们跟着这些，或许就能找到那些俘虏。%SPEECH_OFF%  |  你相当偶然地发现了一些脚印。就肥大的脚趾和没有穿鞋的形状来看，应该是兽人留下的。然而旁边还有些立刻就能识别出来的足迹。%randombrother%走上前来。%SPEECH_ON%长官，看来那就是我们线索了。跟着这些应该很快就能找到那些俘虏了。%SPEECH_OFF%  |  你蹲下身子看向那些足迹。人类，兽人，哥布林。全都是刚留下不久的。跟着足迹应该就能找到俘虏。 |  不少兽人足迹一路延伸至战场之外。还有些人类足迹，都是刚留下不久的。%randombrother%吐了口唾沫点点头。%SPEECH_ON%那应该就是我们寻找的。跟着这些可能就能找到那些俘虏。他们或许都死了，就像我那在岩层滑动中惨死的外婆一样，但仍然值得找找看。%SPEECH_OFF%  |  %randombrother%发现了有力证据：一些人类和野兽足迹，一路延伸至战场之外。如果%companyname%跟着这些，那么应该很快就能找到俘虏。 |  远处走来一个拿着干草叉的男人，将棍子插在地上，在山上撑起了自己的身体。他向你大喊，你慢吞吞地走上前。看到你靠近，他咧开了笑容。%SPEECH_ON%你是在寻找俘虏吧？%SPEECH_OFF%他将麦秆放在本该有牙齿的地方。他指了指。%SPEECH_ON%远方的泥泞路上有足迹。虽然不知道那些蛮子留下自己踪迹线索的原因，但是正是这样他们才是蛮子，对吧。%SPEECH_OFF%你感谢农夫的帮助，并且正如他所说，你很快找到了足迹。%companyname%跟随足迹应该就能找到俘虏了。 |  在战场上搜索了时候，%randombrother%被吓到了，一个小孩双手放在头边从一具尸体后跳了出来，就像某种会吃人的恶心植物。佣兵拔出武器。%SPEECH_ON%小王八羔子，你会付出代价的！%SPEECH_OFF%你拦下了雇佣兵，问那孩子在干什么。小家伙耸耸肩。%SPEECH_ON%玩呗。你难道就不想知道那些绿皮生物去哪了吗？%SPEECH_OFF%你当然想知道。孩子带着你找到一些足迹，人类，兽人和哥布林的。全都是刚留下没多久的。你让小孩赶紧回家，这里并不安全。他眼睛咕溜转着。%SPEECH_ON%{天啊，先生，你这‘感谢’还真是慷慨呢。 |  好吧，先生，不客气。我本以为出来是找点乐子，看来自己的真正目的是等你出现了。 |  真是太棒了，还以为这就能远离烦人的老妈，结果无处不在这样的人。}%SPEECH_OFF%  |  就当你快失去信心的时候，一个拿着篮子的年轻少女出现了。她从死人身上捡起了破布，走的时候还绞干了里面的鲜血。你问她是否看到了什么。她点点头。%SPEECH_ON%那是当然了，毕竟我又没瞎，对吧？而且我还记得些东西，对你应该有些帮助，先生，你应该在找那些绿皮混球带走的俘虏吧。%SPEECH_OFF%你点点头，问他们去哪了。她指了指山下。%SPEECH_ON%看到那小路了吗？痕迹就在那里。那些蛮子留下了不少自己行踪的线索。就我来说不会跟着他们，但你看起来挺壮的。那是什么布料？%SPEECH_OFF%她指向%companyname%的旗帜。你耸耸肩。她也耸耸肩。%SPEECH_ON%还挺不错的。要是你看到类似的东西，就来告诉我，可以吗？我正在做一件婚纱。%SPEECH_OFF%  |  一个男人像个士兵走着，屁股后头还挂着一串摇来晃去的死鱼。他看到你便停了下来。%SPEECH_ON%我来猜猜看，你是在找那些俘虏的去向吧？%SPEECH_OFF%你点点头问他是否知道他们的行踪。虽然他摇摇头，但是指了指自己的脚。%SPEECH_ON%先生，不清楚。但是这儿有踪迹。看，人类和绿皮怪物。应该和他们有关吧，你不觉得么？%SPEECH_OFF%的确有关系。你命令%companyname%做好行军的准备。 |  虽然战场上毫无线索，但外部区域有：你发现了一些踪迹，有着人类和绿皮怪物的痕迹。无疑跟着这些东西能找到俘虏，或者至少能找到掳走他们的人。 |  %randombrother%招呼着你。他脚下有一些大大小小的脚印。这些痕迹一路从战场延伸向外。雇佣兵看向你。%SPEECH_ON%这些肯定就是他们的足迹了，俘虏的，兽人了，那些很小的肯定是哥布林留下的。%SPEECH_OFF%你点点头，招呼%companyname%准备跟着这些足迹。 |  %randombrother%在战场外部发现了一些足迹。你前来审查，他依次指向了大小不一的足迹。%SPEECH_ON%那些应该是兽人了，这些应该是哥布林的，而还有些，应该就是我们要找的俘虏。%SPEECH_OFF%你同意他的想法。如果%companyname%跟着这些足迹，应该就有可能找到俘虏一行人。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "行动吧！",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						local playerTile = this.World.State.getPlayer().getTile();
						local nearest_goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getNearestSettlement(playerTile);
						local nearest_orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getNearestSettlement(playerTile);
						local camp;

						if (nearest_goblins.getTile().getDistanceTo(playerTile) <= nearest_orcs.getTile().getDistanceTo(playerTile))
						{
							camp = nearest_goblins;
						}
						else
						{
							camp = nearest_orcs;
						}

						if (this.Flags.get("IsEnemyParty"))
						{
							local tile = this.Contract.getTileToSpawnLocation(playerTile, 10, 15);
							local party = this.World.FactionManager.getFaction(camp.getFaction()).spawnEntity(tile, "Greenskin Horde", false, this.Const.World.Spawn.GreenskinHorde, 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
							party.getSprite("banner").setBrush(camp.getBanner());
							party.setDescription("A horde of greenskins marching to war.");
							this.Contract.m.UnitsSpawned.push(party);
							party.getLoot().ArmorParts = this.Math.rand(0, 25);
							party.getLoot().Ammo = this.Math.rand(0, 10);
							party.addToInventory("supplies/strange_meat_item");
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
						}
						else
						{
							this.Contract.m.Destination = this.WeakTableRef(camp);
							camp.clearTroops();

							if (this.Flags.get("IsEmptyCamp"))
							{
								camp.setResources(0);
								this.Contract.m.Destination.setLootScaleBasedOnResources(0);
							}
							else
							{
								this.Contract.m.Destination.setLootScaleBasedOnResources(120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());

								if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Destination.getTags().get("IsEventLocation"))
								{
									this.Contract.m.Destination.getLoot().clear();
								}

								camp.setResources(this.Math.min(camp.getResources(), 80 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));
								this.Contract.addUnitsToEntity(camp, this.Const.World.Spawn.GreenskinHorde, 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
							}
						}

						this.Contract.addFootPrintsFromTo(playerTile, this.Contract.m.Destination.getTile(), this.Const.OrcFootprints, 0.75);
						this.Contract.setState("Pursuit");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Battlesite3",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_53.png[/img]{绿皮怪物被打败了，你走进他们的营地，发现了蒙着眼睛被关起来的囚犯。你让雇佣兵放了他们。那些囚犯以为自己死定了，他们留着泪，感谢你们的相救。不足为奇，真的。 |  绿皮怪物被打败了，你迅速进入他们的营地。你发现囚犯们都挤在一个帐篷里，没有穿衣服。他们自由之后几乎说不出话来，但眼睛里流露出经历过的恐惧之情。%randombrother%拿来毯子裹住他们，为了你的雇主%employer%返程。 |  绿皮怪物已经被打败，你和大家开始穿越他们的营地。你听到一个帐篷里传来尖叫声。%randombrother%打开帐篷，发现一个哥布林正在一群挤作一团、赤身裸体的人面前挥舞着烙铁。佣兵砍掉它的脑袋，它甚至没意识到发生了什么事情。囚犯大声哭了出来，多谢你救了他们。你的雇主，%employer%感到十分高兴，因为至少有的人可以回家了。 |  绿皮怪物被打败了，你和%companyname%赶紧跑到营房。你发现一个哥布林正在戳一个已经被折磨至死的人。%randombrother%抓着哥布林，一剑刺穿了他的脑袋。你跟着血迹找到了附近的一个帐篷，发现一群蒙着眼睛的人挤在一起。他们听到你的声音之后赶紧避开，不过你说你是来救他们的。这些可怜的家伙受了不少苦。带他们回到你的雇主%employer%那儿，他们回家之后一定能很快恢复。 |  那些绿皮怪物不可能突然跳出来了，因为它们全都死了。\n\n你命令大家开始搜索营房，寻找囚犯。很快%randombrother%就发现他们挤在一个帐篷里。他们受到了不少折磨，但还活着。一些人对你表示了感谢，更多的人感谢旧神。该死的神又抢走了你的风头。不管怎样，你的雇主%employer%会非常开心。 |  %companyname%很快就处理了绿皮怪物，然后冲到他们的营房。那儿充满了恐怖的氛围。有些人被棍子串在一起，有些人被挂在巨大的长杆上，放在空中。还好，希望还是存在的，你找到了那些囚犯。他们受到了严重的虐待，但还活着。 |  绿皮怪物被打败了。你进入他们的营房，发现到处都充满了恐惧。一些人被剥了皮，挂在荆棘和树枝上。有些人的内脏被取走，脸上还保留着临死前的奇怪表情。浅沟里找到了更多人，他们的脸浸泡在水里，背上绑着石头，溺死在深一英寸的水里。\n\n不仅仅你，还有其他人，都在担心可能没有幸存者了。这种恐惧不能继续扩大。很不幸，%randombrother%叫你去一个帐篷。你发现一些囚犯挤成一团，没有穿任何衣服，他们看到你出现后瑟瑟发抖。你让%companyname%给他们穿上衣服，给他们吃的，然后回到雇主%employer%那儿。 |  %companyname%很轻松就干掉了绿皮怪物，然后进入它们的营房。在那里，你发现人们被做成了神圣的图腾，用骨头做成了方尖碑，用头骨做成了石冢。%randombrother%让你去一个帐篷里面。你赶紧跑过去，发现了一些囚犯，所有人单独关在装着倒刺的笼子里。你们小心翼翼地把所有人放出来，他们公开表达了自己所经历的恐惧。你向他们保证，很快就能带他们回家。 |  打败绿皮怪物后，你赶紧来到他们的营地寻找囚犯。他们被一条长长的链子锁着。一个眼睛歪曲，手已经变得畸形的兽人想混在人群中逃走。%randombrother%赶紧冲过去用棍子打在它的脑袋上。它倒在地上，滚到一块石头上。那个畸形的怪物从嘴里说出一些十分粗俗不堪的话语。%randombrother%犹豫了一下，兽人的眼睛看到了一个自己从未见过的世界，然后咬咬牙，提着它的脑袋撞了上去。\n\n你放开囚犯，他们说自己刚要被部落叛徒运走。不管怎样，他们现在已经得救了，%employer%会十分高兴！ |  绿皮怪物已经被打败，囚犯们也从营房被救了出来。每个囚犯都经历了不少恐惧，就算那些一言不发的人也开始喋喋不休地说起来。你的雇主%employer%肯定会非常开心。 |  你的雇主%employer%或许不会相信发生的事情，不过打败绿皮怪物后，你冲到他们的营房，成功救出了囚犯！他们不是很健康，不过见到%companyname%而不是拿着火把和斧头的兽人出现，还是大大松了口气。 |  打败绿皮怪物后，%companyname%迅速来到营房。你发现囚犯们全部被绑在一根逗熊棒上。一只死掉的熊躺在地上，还有几个被殴打得很严重的人。那些用自己双手杀死熊的人，应该尽快送到%townname%的雇主那里。 |  %companyname%打败了绿皮怪物，冲进营房寻找囚犯。你不知道战士们是否能再次战斗，不过希望%employer%能好好对待他们。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们此行达到了目的。该回%townname%去了！",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Scouts",
			Title = "战斗地点…",
			Text = "[img]gfx/ui/events/event_49.png[/img]{你在尸体周围寻找线索的时候，突然遭到了一群绿皮怪物的攻击。他们可能是来掠夺战场的。你命令大家摆好阵型，那些野蛮人也一样。 |  一个绿皮怪物侦查阵营想掠夺战场，但是却遇到了%companyname%。准备战斗！ |  搜索区域寻找线索的时候，一群绿皮怪物和%companyname%相遇了。他们可能是来掠夺的，不过你决定让它们也变成躺在地上的尸体。 |  %companyname%正在寻找线索，突然一群绿皮怪物回到了战场！ |  你把一具尸体翻过来，一个哥布林斜眼看着你。你用脚踢了踢尸体，它咆哮着抓住你的腿。它没死！你在前方看到一群绿皮怪物正盯着你。哥布林尖叫着撤退，你也迅速后退，命令%companyname%摆好阵型。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						local tile = this.World.State.getPlayer().getTile();
						local p = this.Const.Tactical.CombatInfo.getClone();
						p.TerrainTemplate = this.Const.World.TerrainTacticalTemplate[tile.TacticalType];
						p.Tile = tile;
						p.CombatID = "Scouts";
						p.Music = this.Const.Music.GoblinsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						local nearest_goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getNearestSettlement(tile);
						local nearest_orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getNearestSettlement(tile);
						local camp;

						if (nearest_goblins.getTile().getDistanceTo(tile) <= nearest_orcs.getTile().getDistanceTo(tile))
						{
							camp = nearest_goblins;
						}
						else
						{
							camp = nearest_orcs;
						}

						p.EnemyBanners.push(camp.getBanner());
						p.Entities = [];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.GreenskinHorde, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Survivor",
			Title = "战斗地点…",
			Text = "[img]gfx/ui/events/event_22.png[/img]{%randombrother%正在搜查尸体，突然跳开。%SPEECH_ON%先生！这儿还有活口！%SPEECH_OFF%你赶紧跑过去，发现一个人从尸体中爬出来。他虚弱地站起来，沾满鲜血的脸在阳光下显得瑟瑟发抖。他说自己战斗时就在这儿，想结束这场战争。很明显，他会免费加入%companyname%！ |  在战场搜索尸体的时候，你突然听到尸体下方传来尖叫。%randombrother%翻开尸体，发现一个人笑着看着你。%SPEECH_ON%旧神啊，我还以为自己死定了。%SPEECH_OFF%你问他是否参加了这场战斗，他说是。他伸出一只手，你把他拉了出来。他出来后整理了下自己肩膀上的血迹。看到%companyname%的旗帜后，他问你是否还能收下一个人。%SPEECH_ON%我还有未完成的事情，你肯定理解的。%SPEECH_OFF%  |  你之前以为这里全都是死人。%randombrother%却在一堆尸体下找到了一个幸存者。你走过去，看到一名战士摇摇晃晃地站在一堆尸体上。他找准方位后似乎松了口气。%SPEECH_ON%啊，我认得那个符号。你们是%companyname%。先生们，这里已经没我什么事了，我非常喜欢清理混乱。可以让我加入你们吗？%SPEECH_OFF%  |  一名幸存者的脑袋从兽人尸体下伸出来。他大口喘着气，%randombrother%和你把他拉了出来。%randombrother%给了他一瓶水，你问还有没有其他幸存者。他耸耸肩。.%SPEECH_ON%他们之前都在尖叫，不过现在没声了。你们是%companyname%吗？%SPEECH_OFF%他擦了擦嘴，指着战团的旗帜。你点点头。他也点头回应，然后又喝了一口水。%SPEECH_ON%雇佣兵，这儿已经没我什么事了，我想问一句，我能加入你们战团吗？%SPEECH_OFF%  |  你找到了一名幸存者！有个人从尸体堆中爬了出来，就像一条从烂苹果中爬出来的虫子。他擦了擦脸上的血迹，然后笑出声来。%SPEECH_ON%我待在下面的时候，想着绿皮怪物可能还会回来，见到你们真是太好了，天呐！%SPEECH_OFF%%randombrother%给了他一瓶水，你问他是否还有其他幸存者。他点点头。%SPEECH_ON%嗯，他们被当成囚犯抓走了，只有旧神知道他们发生了什么事。那是%companyname%的标志吗？我可以加入战团吗？你应该也注意到了，这儿已经没我什么事了。%SPEECH_OFF%  |  一个人从尸体堆中站了出来，似乎等你们很久了。%randombrother%受到惊吓地跳回去，拔出武器。幸存者友好地挥挥手，%SPEECH_ON%不得不说，没想到你们会出现。我还以为绿皮怪物会回来掠夺剩下的东西。那是%companyname%的旗帜吗？%SPEECH_OFF%你告诉他是的。他拍了拍手走上前来，被头骨和四肢绊倒，从尸体堆上滑了下来。%SPEECH_ON%运气真是太好了！我正好需要一套新装备，我很想加入你们的战团！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "欢迎加入%companyname%！",
					function getResult()
					{
						this.World.getPlayerRoster().add(this.Contract.m.Dude);
						this.World.getTemporaryRoster().clear();
						this.Contract.m.Dude.onHired();
						this.Contract.m.Dude = null;
						return "Battlesite2";
					}

				},
				{
					Text = "不可能。滚吧。",
					function getResult()
					{
						this.World.getTemporaryRoster().clear();
						this.Contract.m.Dude = null;
						return "Battlesite2";
					}

				}
			],
			function start()
			{
				local roster = this.World.getTemporaryRoster();
				this.Contract.m.Dude = roster.create("scripts/entity/tactical/player");
				this.Contract.m.Dude.setStartValuesEx(this.Const.CharacterVeteranBackgrounds);
				this.Contract.m.Dude.setHitpointsPct(0.6);

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
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Head).removeSelf();
				}

				if (this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Body) != null)
				{
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Body).setArmor(this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Body).getArmor() * 0.33);
				}

				if (this.Contract.m.Dude.getTitle() == "")
				{
					this.Contract.m.Dude.setTitle("the Survivor");
				}

				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Accident",
			Title = "战斗地点…",
			Text = "[img]gfx/ui/events/event_22.png[/img]{穿过战场根本不是一件安全的事情，%hurtbro%弄伤自己之后说了这句话。 |  %hurtbro%脚下一滑，摔倒在一堆武器上。他又受伤了。 |  很不幸，%hurtbro%摔倒在一堆被鲜血染红的淤泥里，而且脸朝下，正好倒在兽人战士的胃里。他受了一些伤。 |  战斗结束后，战场十分危险。%hurtbro%滑倒了。受了一点轻伤，他会没事的。 |  你就知道会有个白痴摔倒：%hurtbro%踩到一个护盾，然后从尸体上滑了下来。他刚好滑倒在一堆武器上，并且承受了一定的后果。 |  %hurtbro%大声叫着。%SPEECH_ON%嘿，看看这个！%SPEECH_OFF%他跳到湖墩上，然后从尸体堆上滑下来。很不幸，有个兽人的手拦住了护盾，他转了个圈，他从护盾上摔下来，正好落在一堆武器上。他发出痛苦的呻吟。%randombrother%叫着，%SPEECH_ON%{我看到你在那儿做了什么。 |  你这个白痴，没有姑娘会因此看上你的。}%SPEECH_OFF%  |  %hurtbro%捡起一把生锈的兽人长剑拿在手里把玩。很不幸，他被兽人绊倒，然后摔下去的时候把自己给割伤了。那白痴会随着时间痊愈的。 |  你看着%hurtbro%试着各种兽人武器。你刚转身，那白痴就把自己给弄伤了。你转身看到他倒在地上呻吟着。不是很严重，不过你真希望那些白痴能小心点。 |  尽管你叫他们小心，可%hurtbro%还是摔倒，正好和一个兽人面对面，他也很可能摔倒在武器上。他受伤了，但不足以致命。 |  %hurtbro%捡起一个小哥布林，把它当做木偶一样玩耍。雇佣兵塔上护盾，向后飞过去的时候，绿皮怪物肯定非常生气，死掉的哥布林在空中翻了个跟斗。佣兵受伤了，不过不致命。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "小心一点。",
					function getResult()
					{
						this.Contract.m.Dude = null;
						return "Battlesite2";
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
			ID = "LuckyFind",
			Title = "战斗地点…",
			Text = "[img]gfx/ui/events/event_22.png[/img]{你觉得大家在战场上找不到什么东西，可是%randombrother%似乎找到了一件强力的武器！ |  搜索战场的时候，%randombrother%找到了一件制作精良的武器，这件武器不知是如何从屠杀中保存完整的！ |  找到了一件强力武器！%randombrother%轻率地拿起武器让大家看看。 |  %randombrother%在一堆武器中寻找着。你让他趁自己的胳膊还没被削掉，赶紧停手。他突然挺直身子，手里拿着奇怪的战场遗物。%SPEECH_ON%啊哈，先生，现在呢？%SPEECH_OFF%好吧，这次是他赢了。 |  你警告大家注意从战场离开的痕迹，不过%randombrother%开始清理尸体，想找点什么东西。你刚准备说他这样会弄伤自己，他突然跳起来，手里拿着一件非常漂亮的武器。你对他竖起大拇指，%SPEECH_ON%干得好，佣兵！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "是个不错的发现。",
					function getResult()
					{
						return "Battlesite2";
					}

				}
			],
			function start()
			{
				local item;
				local r = this.Math.rand(1, 10);

				if (r == 1)
				{
					item = this.new("scripts/items/weapons/greatsword");
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/weapons/greataxe");
				}
				else if (r == 3)
				{
					item = this.new("scripts/items/weapons/billhook");
				}
				else if (r == 4)
				{
					item = this.new("scripts/items/weapons/noble_sword");
				}
				else if (r == 5)
				{
					item = this.new("scripts/items/weapons/warbrand");
				}
				else if (r == 6)
				{
					item = this.new("scripts/items/weapons/two_handed_hammer");
				}
				else if (r == 7)
				{
					item = this.new("scripts/items/weapons/greenskins/orc_axe_2h");
				}
				else if (r == 8)
				{
					item = this.new("scripts/items/weapons/greenskins/orc_cleaver");
				}
				else if (r == 9)
				{
					item = this.new("scripts/items/weapons/greenskins/named_orc_cleaver");
				}
				else if (r == 10)
				{
					item = this.new("scripts/items/weapons/greenskins/named_orc_axe");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + this.Contract.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Ambush",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_48.png[/img]{你跟着痕迹，突然发现了一个绿皮怪物从树林里跳出来大声尖叫着。接着更多绿皮怪物把你包围起来。埋伏！ |  你跟着痕迹，发现了一些东西。你蹲下来清理着灰尘和树叶。有痕迹指着完全相反的方向。留下痕迹的人肯定又返回了，这意味着……\n\n%randombrother%结束了你的思考，伸手大叫着，%SPEECH_ON%有埋伏！绿皮怪物！%SPEECH_OFF%  |  你跟着两条痕迹，突然它们向不同的方向分开了。你跟着痕迹，发现它们消失在了丛林里。你叹了口气，让大家准备战斗。你刚说完，一群绿皮怪物就从出现了！ |  事情没有表面那么简单……你刚刚这样想，一个瞪大眼睛，皮肤被晒伤的%randombrother%大叫起来，%SPEECH_ON%这是个陷阱！%SPEECH_OFF%绿皮怪物不停地从树林出现。有埋伏！你赶紧命令大家摆好阵型。 |  道路的痕迹十分清晰，老实说，你觉得这样有点太简单了，刚刚这样想，突然一个绿皮怪物从旁边的树丛跳出来大叫着。接着道路两边出现了更多绿皮怪物做同样的事情。这是个陷阱！准备战斗！ |  你发现痕迹出现分叉。有一条继续向前，其他的分开进了树丛。你很快就知道发生了什么事情：你让大家摆好阵型。正在这时，一群绿皮怪物从树林里大叫着出现，准备伏击%companyname%。准备战斗！ |  痕迹在你脚下消失了，你知道这意味着什么。你高声让大家摆好阵型。绿皮怪物尖叫着从树林里出现。有埋伏！ |  痕迹继续向前，不过你发现旁边有干扰的迹象。你让大家停下，并蹲下调查。你扒开叶子和泥土，发现一条通往相反方向的痕迹。绿皮怪物又回去了……%randombrother%大声叫着，%SPEECH_ON%有埋伏！有埋伏！%SPEECH_OFF%你转过身去，发现绿皮怪物尖叫着，拿着武器从树林里出现。你迅速命令大家摆好阵型。准备战斗！}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						local tile = this.World.State.getPlayer().getTile();
						local p = this.Const.Tactical.CombatInfo.getClone();
						p.TerrainTemplate = this.Const.World.TerrainTacticalTemplate[tile.TacticalType];
						p.Tile = tile;
						p.CombatID = "Ambush";
						p.Music = this.Const.Music.GoblinsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Center;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
						local nearest_goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getNearestSettlement(tile);
						p.EnemyBanners.push(nearest_goblins.getBanner());
						p.Entities = [];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.GoblinRaiders, 125 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "AmbushFailed",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_53.png[/img]{埋伏部队被打败了，你去到了绿皮怪物的营地，发现囚犯们被遮住了眼睛关在了囚笼里面。你让雇佣兵放了他们。那些囚犯以为自己死定了，他们留着泪，感谢你们的相救。不足为奇，真的。 |  绿皮怪物被打败了，你迅速进入他们的营地。所有徘徊着的绿皮怪物都迅速跑走了，抛下了一切东西。你发现囚犯们都挤在一个帐篷里，没有穿衣服。%randombrother%拿来毯子裹住他们，所有人准备返回你的雇主%employer%那。他们自由之后几乎说不出话来，但眼睛里流露出经历过的恐惧之情。 |  绿皮怪物已经被打败，你和大家开始调查他们的营地。你突然听见了一顶帐篷中传来的人类尖叫声。%randombrother%打开帐篷，发现一个哥布林正在一群挤作一团、赤身裸体的人面前挥舞着烙铁。佣兵一击砍飞了那怪物的头颅。囚犯大声哭了出来，多谢你救了他们。你的雇主，%employer%感到十分高兴，因为至少有的人可以回家了。 |  埋伏被打败了，你和%companyname%冲进了绿皮怪物营房。你发现一个哥布林正在戳一个已经被折磨至死的人。%randombrother%抓起了那低能怪物用拳斗打死了它。你搜寻了附近的一顶帐篷之后发现了一群眼睛被遮住的人们挤在了一个角落。他们听到你的声音之后赶紧避开，不过你说你是来救他们的。这些可怜的家伙受了不少苦。带他们回到你的雇主%employer%那儿，他们回家之后一定能很快恢复。 |  绿皮怪物不可能再来了，因为它们全都死了。\n\n你命令大家开始搜索营房，寻找囚犯。很快%randombrother%就发现他们挤在一个帐篷里。他们受到了不少折磨，但还活着。一些人对你表示了感谢，更多的人感谢旧神。该死的神又抢走了你的风头。你的雇主%employer%肯定会非常开心。 |  %companyname%很快就处理了绿皮怪物，然后冲到他们的营房。你发现营火上有一个在被灸烤着的男人尸体。树上还挂着一个双脚都被砍掉的。附近一顶帐篷传来的尖叫声吸引了你的注意力，你在那里发现了一群挤在一起，乞求让他们饮水的男人。你的人开始分发净水，照料起他们的伤口。他们应该嫩巩固自己走回%employer%和自己的房子去。 | 埋伏已经被解决，你们迅速扫荡着绿皮怪物们的营地。你发现了少数几个剩下来的，其中包括了一只想要跟一群战利品骷髅爱爱的哥布林。%randombrother%让怪物用怪物自己的头颅满足了自己。\n\n没过多久你就发现了一群挤在羊皮帐篷里面的囚犯们。其中一个哭喊了出来。%SPEECH_ON%我就知道古神们会回应我们的祈祷的！%SPEECH_OFF%你问他古神们会不会顺便解开他们。这个有趣的，哲学性的问题在%randombrother%冲进来释放了所有囚犯的时候还没有被回答。不管怎么说。不管是谁还是什么东西救了这些人，%employer%都会开心的。 | 绿皮怪物已经溃败，你和%companyname%横扫他们的营地，杀死了找到的每一个散兵游勇。地上一个大坑中的囚犯都释放了，看上去他们在自己的屎尿里面呆了许多天。他们亲吻了大地，然后感谢了你的营救。%employer%一定会对这样的事情感到高兴的。 | 埋伏已经被处理了，但是囚犯们呢？你迅速冲进了被遗弃的绿皮怪物营房，发现囚犯们都被绑在了一根根的柱子上面。不幸的是，有个人已经被折磨至死了。从他还在滴血的伤口来看，你就晚了一步。但是其他的囚犯还是兴奋的尖叫了出来。一个接一个的他们亲吻了你脚下的土地。但是，现在不是自我感觉良好的时候。%employer%会用他自己的感谢方式报答你的：一大堆克朗。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们此行达到了目的。该回%townname%去了！",
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
			ID = "EmptyCamp",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_53.png[/img]{你手拿宝剑冲进绿皮怪物的营房，但是发现整个地方都已经被抛弃了。炊事工具都被打翻在地，还有他们刚刚扔下的新篝火的痕迹。%randombrother%打开了一顶羊皮帐篷，发现囚犯们都挤成了一团。他们一看见你就赞美起了古神。%employer%应该会对这结果很满意的，而且绿皮怪物没有战斗就撤退了，你对这一点也很开心。 | 绿皮怪物的营地被遗弃了。你发现猪猡被烧焦的残骸从被踢翻的烧烤坑上掉了出来。他们肯定是匆匆茫茫离开的。\n\n%randombrother%呼唤着你。囚犯们都站在地上的一个大坑里面，水已经齐腰深。一扇尖刺木门挡住了他们与自由的之间的道路，尽管上面缠绕着的带血布条表明最起码有一人尝试逃脱过。你迅速掀起了盖子，帮助他们逃了出来。向下看，你发现了一具泡在水里的尸体。不是所有人都能活着回来，但是能有活人回来%employer%应该会非常高兴的。 |  你冲进了绿皮怪物的营地，发现帐篷都被撕裂了，而且有一大堆杂乱的脚印通向了远方。他们是在匆忙间就抛弃了这处营地。%randombrother%笑了起来。%SPEECH_ON%看上去他们是知道%companyname%要来了。%SPEECH_OFF%突然，其中一顶帐篷中发出了一声尖叫。你冲进去，发现一个神智狂乱的男人被四肢叉开绑在了地上，角落里面一群眼睛被遮住的人挤在了一起。囚犯。缺掉的手指，脚趾，眼睛，鼻子，四肢，被绿皮怪物抓住的时间的印记。你摇了摇头，命令手下开始照料他们。%employer%看见这些人还活着应该会很高兴的，但是这些男人绝对已经坏掉了。 | 绿皮怪物们的营地是空的。几只黑色的大鸟鸣叫争夺着一些剩余的食物残渣，野狗们看见你就四散逃走了。你的手下开始搜索怪物们留下来的羊皮帐篷。一开始所有人什么都没有找到，直到你的脚突然踩进了一块奇怪的凹槽。你蹲下去，拂开了伪装，一扇活板门。打开之后你发现了一个被绿皮怪物改造成垂直型牢房的井槽。囚犯们像火绒一样挤在了一起，被水泡烂的枯萎脸庞看着突然的光芒。%randombrother%低头看去，咕哝了起来。%SPEECH_ON%好吧，他们还活着。我去拿点绳子来。%SPEECH_OFF%  | 脚印指向了营地外。从脚印间的间隔以及四散的垃圾来看，他们应该是匆匆茫茫离开的。%randombrother%呼喊你。他站在一顶帐篷外面，手掀开了帐篷。等你到那里的时候，你看见了被当成是囚犯室的内部。所有人都赤身裸体地被绑在地上，耳朵被树枝钉在了地上，眼睛都被蒙上了。看上去他们已经被折磨到知道除非被要求，否则不要动的地步了。一堆人类四肢堆在了角落，看上去有什么东西在用他们的头颅制作原始的艺术品。你摇了摇头。%SPEECH_ON%放开他们，给他们水喝。%employer%大概还希望能够把这些人弄回来，但是这跟我想的一样。%SPEECH_OFF%  | 绿皮怪物们已经放弃了他们的营地。你清楚这是为什么，但是很有可能是他们的探子发现了你的战团然后做了在能跑的时候先跑了的决定。\n\n所有人都收到了去寻找囚犯的命令，不一会他们就有了发现：一顶羊皮帐篷里面的男人全都挤在了一根杆子下面，他们的手被绑住了，头全被埋进了土里。他们嘴里都咬着一根呼吸用的稻草。%randombrother%赶快跑了过去，把他们的脑袋举了出来。每个人的脸都憋的青紫，但是他们都还活着，而且这折磨已经结束了。%employer%看见这些人还活着肯定很高兴。 |  营房空无一人。%randombrother%捡起了一口被翻到的大锅，里面的泔水比菜还多。他马上扔掉了，摇了摇头。%SPEECH_ON%火还在烧。他们是匆匆茫茫走的。%SPEECH_OFF%你点了点头，命令手下散开去寻找囚犯。你发出命令没多久就听见了附近帐篷中传来的尖叫声。你在里面发现了囚犯们-那些活下来的囚犯们。帐篷一边的活人们都一丝不挂挤在了一起。你的视线转向另一边的血泊，一个处决台，一柄染血大锤，几句像被用作书签的花朵一样头部被掐掉的尸体。%employer%没办法要回所有的手下了。 |  进入绿皮怪物营地之后，{你发现了一只哥布林在往一只麻布口袋里面塞骨头。它马上丢掉了自己的东西。%randombrother%冲了过去，用剑刺穿了那怪物。 | 你发现了一只受伤的兽人依靠在一根杆子上面。他的呼吸很沉重，但是%randombrother%快速的一刀确保了那怪物完全不会再呼吸了。}剩下来的营地似乎空无一人，这个绿皮怪物是最后一个剩下的。你发现囚犯们都在一顶帐篷里面。它们的眼睛都被遮住了，而且有几个都缺了手指或者脚趾。%employer%会很高兴的。 |  营房已经被遗弃了，但是囚犯们都被留了下来。你救了他们，或者说是救了还活着的：有些人的手指和脚趾都已经被割掉了，其他人呼吸都是通过鼻子原来在的位置上的一个洞。但是他们还活着。活着才重要，对不对？ |  你进入了一处匆忙间被丢弃的营地。绿皮怪物们很有可能是看见了%companyname%于是决定提前撤退。谢天谢地的是，囚犯们都还活着。他们像是一名神域贤者面前的贱民们一样跪倒在你脚下，赞美着古神。你给了可怜的幸存者们净水，然哦户准备返回%employer%处。 |  你们在营地中发现了一只孤零零的兽人.它依靠着关押囚犯的牢笼旁休憩着。其中一个囚犯将链条捆在了绿皮怪物的脖子上，勒着它，看守与囚犯在一场最具讽刺性的搏斗中战斗着。%randombrother%赶了过去，一剑刺穿了兽人的眼睛，释放了囚犯。囚犯们冲出囚笼，亲吻大地，欢呼跳跃。一个举止轻浮的男人解释说绿皮怪物们都匆匆茫茫离开了，看上去他们是被吓坏了。你垫了点头，然后手指过肩头，指着 %companyname的徽章。%SPEECH_ON%他们做的很对。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们此行达到了目的。该回%townname%去了！",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
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
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer% 迎接你进入了他的房间。%SPEECH_ON%我好好看了看囚犯们。或者该说剩下来的部分。他们简直不成人形了，但是你做的很好。%reward_completion%克朗，是嘛？%SPEECH_OFF%  |  %employer%在他的房间里面踱着步，偶尔往窗户外面眺望着。下面的广场里面，囚犯们正在接受着治疗。他摇了摇头。%SPEECH_ON%我真的从来没有想过他们还能有人活着回来。你做的很好，·佣兵。%SPEECH_OFF%他朝你扔了一袋装有%reward_completion%克朗的袋子。 |  %employer%本人正在帮忙喂囚犯吃东西。他对他们说着温柔的话语。看见你之后，他将这任务交给了一名侍从然后将你带到了一遍。%SPEECH_ON%听着，我知道那些人现在已经彻底一点用也没有了。绿皮怪物们是没有杀死他们，但是他们已经做到了这一点。他们的身体还在，但是灵魂已经破碎。不管怎么样。你做了我要求的事情。那边的守卫会给你%reward_completion%克朗的。我不知道你是怎么做下去的，佣兵。每天要经历这种事情。但是我感谢你的帮助。%SPEECH_OFF%  | %employer%盯着窗户外面，他的身影被透过薄薄的窗户的日光笼罩着。下面的广场上，人们正在照料自由了的囚犯们。他摇了摇头，然后走到了桌子前。%SPEECH_ON%看见人们变成那样真是太难受了。%SPEECH_OFF%拿出了一袋装有%reward_completion%克朗的帆布袋推给了你，他继续说道。%SPEECH_ON%但是你带他们回了家，佣兵，那才是最重要的。没有人该死在那些蛮子的营地里面。%SPEECH_OFF%  |  %employer%翻阅着一系列卷轴。一名文士站在一边，低头摩挲着手里的念珠。当你进入房间的时候他们偶读看着你。你报告囚犯们都已经被救出。贵族摊开了一条卷轴，然后像文士点了点头，他给了你%reward_completion%克朗。%employer%拍了拍他的手。%SPEECH_ON%我希望那些人都安全回来了。%SPEECH_OFF%当你开口想要说有些人没有时，贵族打断了你。%SPEECH_ON%我不需要听人演讲，佣兵。我还有事情要做。%SPEECH_OFF%文士温和地笑着把你赶了出去。 |  囚犯们被带去了治疗师那边，料理着他们可怕的伤口。不幸的是，看不见的伤疤才是真正会困扰这些人一辈子的顽疾。但是%employer%看上去很开心。%SPEECH_ON%他们能回来真是太好了。我自己是从来没有想过他们还能回来的。你的天赋真是世间少有，佣兵。%SPEECH_OFF%世间少有，有可能吧，但是跟其他的佣兵做的并不差别：你要求薪酬。这提醒让贵族打了一记响指。一名守卫急匆匆地拿来了%reward_completion%克朗。 |  你护送被解救的人们进入了%townname%。%employer%站在阳台上鼓掌。%SPEECH_ON%做的好，做得好！卫兵！%SPEECH_OFF%一名穿着盔甲的男人冲进来给了你%reward_completion%克朗。 |  被解救的囚犯们被带到了一群老治疗师那里，那些老头老太自己看上去就像是在绿皮怪物营房里面住了一辈子样。受伤的战士们由老人家们照料着。%employer%看上去很开心，亲自给了你一袋装有%reward_completion%克朗的袋子。%SPEECH_ON%你知道吗，我们几个贵族还打了个小赌这些人能不能活着回来。我压在了你身上，佣兵。我就知道你可以做到的！我挣的钱比我刚付了你的还要多！是不是太好笑了？%SPEECH_OFF%  |  你和%employer%看着自由了的囚犯们被带入了药剂师的店铺。贵族们失望地耸了耸肩。%SPEECH_ON%该死的。%SPEECH_OFF%这可不是你想要见到的反应。他靠了过来，偷偷低语道。%SPEECH_ON%我们在打赌那些人能不能回来。你做的好事让我损失了一大笔克朗，佣兵。%SPEECH_OFF%你点了点头，然后伸出了一只手。%SPEECH_ON%好的，到了你再损失%reward_completion%克朗的时候了。%SPEECH_OFF%  |  %employer%在门口微笑地迎接了你，然后给了一袋%reward_completion%克朗。%SPEECH_ON%我们本来会期待着会有失望的，佣兵。我，其他贵族，还有村民们。没人想到这些人能回来，但是他们还是回来了。%SPEECH_OFF%  |  %employer%亲自负责照料着那些囚犯们，贵族散发着净水，食物以及绷带。看上去与其说是诚信做的还不如说是为了作秀才做的。%employer%看着你就走了过来，吧手背在你衣袖上擦了擦。%SPEECH_ON%呃，有个人的血都流到我身上来了。你的%reward_completion%克朗，佣兵。没想到你能成功，看看。说实话的话不知道他们还有什么用，但是这件事情本身还是有意义的。%SPEECH_OFF%奇怪的是，你感觉有种冲动想要告诉他不要太诚实。 | 你帮助被解救的囚犯们穿越了%townname%的大门。%employer%正在和一群随行的卫兵在药剂师的门口等着。他们帮忙照料着人们。贵族们派了一名手里拿着%reward_completion%克朗的文士找你。 |  你在%employer%的房间找到了他。一个体态轻盈的女子正在认真地用研钵研磨药草。完全没有看你一眼，她转向了贵族，把碗伸了出去。%SPEECH_ON%这应该能帮你的斜支撑硬起来。%SPEECH_OFF%%employer%踮起脚越过她的肩膀看着你。%SPEECH_ON%佣兵！见到你真是太高兴了！囚犯们都被救出来了？%SPEECH_OFF%你汇报了发生的一切。贵族给女人手里塞了%reward_completion%克朗的金币。%SPEECH_ON%把这个男人的报酬交给他，女士。%SPEECH_OFF%  |  你带领着被救出来的囚犯们穿过了%townname%的大门。A crowd of women await them, the wives wrapping their arms around their husbands, the widows collapsing to their knees.\n\n%employer%走了过来，每只手里抱着一个妹纸。他点了点头.%SPEECH_ON%真是可惜了，话说，你的报酬是 %reward_completion%克朗对吗？%SPEECH_OFF%}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Freed prisoners from greenskins");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isGreenskinInvasion())
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
		if (this.m.BattlesiteTile == null  ||  this.m.BattlesiteTile.IsOccupied)
		{
			local playerTile = this.World.State.getPlayer().getTile();
			this.m.BattlesiteTile = this.getTileToSpawnLocation(playerTile, 6, 12, [
				this.Const.World.TerrainType.Shore,
				this.Const.World.TerrainType.Ocean,
				this.Const.World.TerrainType.Mountains
			], false);
		}

		_vars.push([
			"location",
			this.m.Destination == null  ||  this.m.Destination.isNull() ? "" : this.m.Destination.getName()
		]);
		_vars.push([
			"dude_name",
			this.m.Dude == null ? "" : this.m.Dude.getNameOnly()
		]);
		_vars.push([
			"hurtbro",
			this.m.Dude == null ? "" : this.m.Dude.getName()
		]);

		if (this.m.Destination == null)
		{
			_vars.push([
				"direction",
				this.m.BattlesiteTile == null ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.BattlesiteTile)]
			]);
		}
		else
		{
			_vars.push([
				"direction",
				this.m.Destination == null  ||  this.m.Destination.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Destination.getTile())]
			]);
		}
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
		if (!this.World.FactionManager.isGreenskinInvasion())
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

