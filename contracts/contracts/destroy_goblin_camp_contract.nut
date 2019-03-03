this.destroy_goblin_camp_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.destroy_goblin_camp";
		this.m.Name = "摧毁哥布林营地";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		local camp = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getNearestSettlement(this.World.State.getPlayer().getTile());
		this.m.Destination = this.WeakTableRef(camp);
		this.m.Flags.set("DestinationName", this.m.Destination.getName());
		this.m.Payment.Pool = 900 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		local r = this.Math.rand(1, 2);

		if (r == 1)
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
					"摧毁%origin%以 %direction%方向的" + this.Flags.get("DestinationName")
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

				if (this.Contract.getDifficultyMult() < 1.15 && !this.Contract.m.Destination.getTags().get("IsEventLocation"))
				{
					this.Contract.m.Destination.getLoot().clear();
				}

				this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.GoblinRaiders, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.setLootScaleBasedOnResources(110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));
				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);

				if (this.World.FactionManager.getFaction(this.Contract.getFaction()).getFlags().get("Betrayed") && this.Math.rand(1, 100) <= 75)
				{
					this.Flags.set("IsBetrayal", true);
				}
				else
				{
					local r = this.Math.rand(1, 100);

					if (r <= 20 && this.World.Assets.getBusinessReputation() > 1000)
					{
						if (this.Contract.getDifficultyMult() >= 0.95)
						{
							this.Flags.set("IsAmbush", true);
						}
					}
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
				if (this.Contract.m.Destination == null || this.Contract.m.Destination.isNull())
				{
					if (this.Flags.get("IsBetrayal"))
					{
						if (this.Flags.get("IsBetrayalDone"))
						{
							this.Contract.setScreen("Betrayal2");
							this.World.Contracts.showActiveContract();
						}
						else
						{
							this.Contract.setScreen("Betrayal1");
							this.World.Contracts.showActiveContract();
						}
					}
					else
					{
						this.Contract.setScreen("SearchingTheCamp");
						this.World.Contracts.showActiveContract();
						this.Contract.setState("Return");
					}
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				if (this.Flags.get("IsAmbush"))
				{
					if (!this.Flags.get("IsAttackDialogTriggered"))
					{
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.setScreen("Ambush");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Ambush";
						p.Music = this.Const.Music.GoblinsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Center;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.GoblinRaiders, 50 * this.Contract.getReputationToDifficultyMult(), this.Contract.m.Destination.getFaction());
						this.World.Contracts.startScriptedCombat(p, false, false, false);
					}
				}
				else
				{
					this.World.Contracts.showCombatDialog();
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Betrayal")
				{
					this.Flags.set("IsBetrayalDone", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Betrayal")
				{
					this.Flags.set("IsBetrayalDone", true);
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
			Text = "[img]gfx/ui/events/event_61.png[/img]{你进去的时候，%employer%正在阅读一份卷轴。你随意地向你摆了摆手，似乎把你当成了一名侍者。你用剑鞘敲了敲墙。那个男人抬起头来，之后马上放下了手中的卷轴。%SPEECH_ON%啊，佣兵！见到你真是太高兴了。我有个特别的问题想问你。%SPEECH_OFF%他停顿了一下，似乎想看看你的反应。而你什么话也没说，他只能尴尬地继续说下去。%SPEECH_ON%是的，当然了，是关于任务的问题。在 %origin%的%direction%方向上有一群哥布林建立了一个据点。我本想带着我手下的骑士们去解决他们，但却发现，那群家伙似乎没能力去‘击杀’那群哥布林。真是够呛。我觉得他们只是不想死在那群肮脏的矮子们的手中罢了。荣誉，英勇什么的，都是放屁。%SPEECH_OFF%他假笑着举起了手。%SPEECH_ON%但对于你来说，只要钱管够，没什么事是做不到的吧？%SPEECH_OFF%  |  %employer%正在对房间中另一个人破口大骂。等他冷静下来后，他向你打了个招呼。%SPEECH_ON%我的老天，见到你真是太高兴了。你知道让那些‘忠诚’的手下去杀些哥布林是多么困难的事吗？%SPEECH_OFF%他朝地上啐了一口，然后用袖子擦了擦嘴。%SPEECH_ON%很显然这不是什么崇高的任务。他们觉得欺负那群矮小的残废不是什么光荣的事情。你敢信？有人告诉我，一位出生高贵的贵族，从生下来就明白什么是‘崇高’。总之不管了，佣兵。我需要去%origin%的%direction%方向，消灭那群搭建营地的哥布林。你能帮助我吗？%SPEECH_OFF%  |  %employer%正在不停地把剑拔出剑鞘又插入剑鞘。他每次把剑插入前似乎都会看一眼剑刃上自己的倒影。%SPEECH_ON%那群农民又来烦我了。他们说有一群哥布林在%origin%的%direction%一个叫做%location%的地方搭建了营地。他们还把一具小男孩的尸体搬到了我的脚边，脖子上还插着支毒箭，这让我不得不相信他们说的话。%SPEECH_OFF%他猛地将剑插入了剑鞘。%SPEECH_ON%你能帮我去解决这个麻烦吗？%SPEECH_OFF%  |  你进入房间的时候，喝醉的%employer%正红着脸，猛地把酒杯一砸。%SPEECH_ON%佣兵，是吗？%SPEECH_OFF%他的手下点了点头。那名贵族笑了起来。%SPEECH_ON%哦。很好。又有更多人来送死了。%SPEECH_OFF%他停顿了一下，然后突然大笑起来。%SPEECH_ON%我只是开个玩笑，真好笑，对吗？%origin%的%direction%方向上有一群哥布林给我们带来了麻烦。我需要你去解决他们，你-打嗝-愿意吗？还是我得去找别人来办这事儿……我的意思是……%SPEECH_OFF%他又喝了一口酒。 |  你进入的时候%employer%正拿着两个卷轴对比着。%SPEECH_ON%最近我收到的税款有点少了。真可惜，不过我想这对你来说是个不错的消息，因为我可付不起让那群所谓的‘忠诚’骑士帮我去办事。%SPEECH_OFF%他把卷轴放到了一边，双手交叉搭在了桌子上。%SPEECH_ON%我的探子们汇报说%origin%的%direction%方向上一个叫%location%的地方发现了一群搭建了营地的哥布林。我需要你去那里帮我做我那群手下不愿意做的事情。%SPEECH_OFF%  |  你进去的时候%employer%正在掰面包，不过他可没有与你分享的意思。他把面包的两端沾了沾杯子里的酒，然后塞进了嘴里。他一边咀嚼一边口齿不清地说道。%SPEECH_ON%很高兴见到你，佣兵。我需要你去解决%origin%的%direction%方向上的一群哥布林。我本想派我手下的骑士去，但是他们，呃，似乎认为自己比较重要一点，不愿意去做这种事情。我相信你是能够理解的。%SPEECH_OFF%他把剩下的面包塞入了那张丑陋的嘴巴。过了一会儿，他突然噎住了，而在那一刻，你考虑着是否应该关上门结束这场对话。很不幸，他痛苦的呻吟声引起了警卫的注意，他冲到那名贵族的身边，拍打着他的胸口，成功让他吐出了噎住的食物。 |  当你找到%employer%时，他正一边咒骂一边驱赶着几位骑士。当他看到你后，立刻冷静了下来。%SPEECH_ON%佣兵！很高兴见到你！见到你就是比见到那群自称为‘男人’的家伙强。%SPEECH_OFF%他坐了下来，给自己倒了杯酒。他先抿了一口，盯着酒杯，然后将其一饮而尽。%SPEECH_ON%我那所谓的忠诚部下拒绝去清除%origin%的%direction%方向上的那群哥布林。他们说可能会被伏击，下毒，还有其他各种各样的借口……%SPEECH_OFF%他一边说着一边又开始了咒骂。%SPEECH_ON%W唔……-打嗝-，你懂我的意思，对吗？你知道我想让你去做什么，对吗？当-当然了，-打嗝-，我需要你帮我再倒杯酒！哈，开个玩笑。去杀了那些哥布林，可以吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{跟哥布林战斗可不便宜。 |  我相信你会为此慷慨解囊的。 |  我们来谈谈钱的问题。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。 |  我们还有其他事情要做。}",
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
			ID = "Ambush",
			Title = "靠近营地……",
			Text = "[img]gfx/ui/events/event_48.png[/img]{你进入了哥布林的营地，发现里面空无一物。但你很清楚 - 你知道自己已经踏入了陷阱当中。不一会儿，那群该死的绿皮怪物们就包围了你们。你发出了最响亮的战吼，让你的手下们准备开战！ |  那群哥布林戏耍了你！他们离开了营地并在周围埋伏了起来，包围了你。认真备战，因为这个包围圈可不容易脱离。 |  你本应该清楚：你们已经踏入了陷阱之中！他们包围了战团，用看待宰羔羊的眼神盯着你们！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "当心！",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Betrayal1",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_78.png[/img]{当你解决了最后一只哥布林后，突然出现了一支全副武装的队伍。他们的中尉站了出来，拇指插进了绑着剑的皮带里面。%SPEECH_ON%诶呀呀，你们还真是蠢。%employer%记性很好 - 他还没有忘掉你上次背叛了他的事情。把这想成是…………一个小小的回礼好了。%SPEECH_OFF%一瞬间，所有中尉身后的人突了过来。武装起来，这是次埋伏！ |  将哥布林的血从剑上擦去之后，你突然发现了一支正向你走来的队伍。他们带着%employer%的旗帜，而且正在拔出武器。当那些人开始冲锋，你突然意识到这是次埋伏。他们先让你跟哥布林厮杀一番，才进来解决残局，狗娘养的！来吧！ |  一个男人朝你走了过来。他的武器很好，装甲很好，而且似乎很开心，当靠近的时候咧嘴笑着。%SPEECH_ON%晚上好啊，佣兵们。绿皮怪物那事做的不错嘛？%SPEECH_OFF%他停了一会，褪去笑容。%SPEECH_ON%%employer% 向你问好。%SPEECH_OFF%说时迟那时快，一队人从路边冲了出来。埋伏！那该死的贵族背叛了你！ |  一队穿着%faction%颜色盔甲的人在你身后排开，盯着你的战团。他们的头领打量着你。%SPEECH_ON%我要从你冰冷的尸体上夺走那把剑。%SPEECH_OFF%你耸了耸肩，问他为什么要伏击你们。%SPEECH_ON%%employer%不会忘记那些背叛他或家族的人。你只需要知道那一点。其他废话并不能改变你必死的命运。%SPEECH_OFF%那么就拿起武器战斗吧！ | 你的人冲进了哥布林的营地，但是什么也没有发现。突然，一群穿着%faction%阵营颜色盔甲的人出现在了你的身后，那支队伍的中尉不怀好意地走上前来。他的布衣上带着%employer%的印记。%SPEECH_ON%真可惜那些哥布林没能解决你们。如果你是在好奇我为什么会出现，告诉你，这是你欠%employer%的债。你保证过要完成任务。但是你没能遵守约定。好了，去死吧。%SPEECH_OFF%你拔出剑，砍向中尉。%SPEECH_ON%看来%employer%又要有一个失败的任务了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).getFlags().set("Betrayed", false);
						local tile = this.World.State.getPlayer().getTile();
						local p = this.Const.Tactical.CombatInfo.getClone();
						p.TerrainTemplate = this.Const.World.TerrainTacticalTemplate[tile.TacticalType];
						p.Tile = tile;
						p.CombatID = "Betrayal";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 140 * this.Contract.getReputationToDifficultyMult(), this.Contract.getFaction());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Betrayal2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{你在大腿上抹了抹剑，然后立刻收起了它。伏击者们以各种各样怪异的动作毫无生机地倒在了地上。%randombrother%走了过来，询问现在应该做什么。很显然%faction%对你已经不怎么友好了。 |  你将一具伏击者的尸体从脚边踢开。很显然从现在起%faction%已经不在友好名单上了。或许下次，当我保证过会为这些人完成什么事时，我得说到做到。 |  如果没有别的事，你可以从中得到的教训就是这些了：不要承诺你做不到的事情。这些地方的人对那些不能遵守约定的家伙可不友好…… |  你背叛了%faction%了，但那已经不重要了。他们背叛了你，这才是现在最重要的事情！从现在开始，你最好别再相信他们和那些举着他们旗帜的家伙了。 |  根据你脚边的尸体判断，%employer%显然已经对你很不待见了。不用说，一切是因为你之前干得事情-两面三刀，各种失败，乱找借口，或许还睡了贵族的女儿？你能想到的那些乱七八糟的事情已经够多了。现在更重要的是，你们之间的间隙可不是那么容易就能愈合的。你最好提防着点%faction%的人。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "赚钱可真不容易……",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SearchingTheCamp",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_83.png[/img]{杀死最后一个哥布林后，你搜索了他们的营地。他们似乎很喜欢分类-饰品和工具被分成了好几堆，这些东西都能被当做武器使用。只需要把它们放到废墟中央处装满毒药的锅子里沾一下就行。你踢翻了它，下令返回至你的雇主，%employer%那里。 |  那些哥布林很狡猾，然而你还是成功消灭了他们。他们的营地着起了大火，你下令返程，准备把这个好消息带给%employer%。 |  虽然那群矮小的绿皮怪物的打法非常凶悍，但是你的战团更胜一筹。在杀死最后一个哥布林后，你开始搜查他们的营地。很显然他们并不是独自前来的-有证据表明在刚才战斗的时候有一些哥布林逃跑了。或许是他们的家人？孩子？不管怎样，是时候回去找%employer%，那个雇佣你的人了。 |  啊，漂亮的一战。%employer%一定会喜欢这个消息的。 |  怪不得没人想和哥布林战斗，他们战斗力可不像他们的身高那般不起眼。很可惜他们并不是心智正常的人类，但或许这样才是最好的，这种残暴只能存在于如此瘦小的物种之中！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "是时候去拿我们的报酬了。",
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
			Text = "[img]gfx/ui/events/event_04.png[/img]{你进入了%employer%的房间，将几个哥布林的脑袋扔在了地上。他瞥了一眼。%SPEECH_ON%哈，他们的确比那些文士们说得要大上一些。%SPEECH_OFF%然后你汇报了摧毁那个营地的经过。那位贵族点了点头，摸了摸下巴。%SPEECH_ON%很好。这些是你的报酬。%SPEECH_OFF%你递过一袋装着%reward_completion%克朗的袋子。 |  你进去的时候%employer%正在朝一只小猫扔石头。他瞥了你一眼，而那只可怜的生物就趁机从窗户逃走了。那位贵族又追着它扔了几块，还好所有的石头都落空了。%SPEECH_ON%很高兴见到你，佣兵。我的探子们已经把你的情况汇报给我了。这些就是我们说好的报酬。%SPEECH_OFF%他从桌子上推过一只装着%reward_completion%克朗的木箱。 |  你回来时%employer%正在嗑坚果。他把坚果壳扔在地上，一边咀嚼一边口齿不清地说道。%SPEECH_ON%哦，很高兴再见到你。这么说你应该是成功了吧，对吗？%SPEECH_OFF%你举起了手中几个缠在一起的哥布林的头颅。它们扭曲在一起，空洞的眼神凝视着房间内部。那男人别过头去。%SPEECH_ON%拜托，我们可是高贵的人。快把它拿开。%SPEECH_OFF%你耸了耸肩，把它们交给了等在外面的%randombrother%。%employer%绕过了他的桌子，将一只小包交到了你的手中。%SPEECH_ON%%reward_completion%克朗，我们说好的。干得好，佣兵。%SPEECH_OFF%  |  当%employer%看到你拿着哥布林的脑袋走进来时，他笑了起来。%SPEECH_ON%老天，伙计，别把那种东西拿进来。拿去喂狗吧。%SPEECH_OFF%他有点喝醉了。你不确定他是看到你成功归来而高兴还是因喝了酒而飘飘欲仙。%SPEECH_ON%你的报酬是-打嗝-%reward_completion%克朗，对吗？%SPEECH_OFF%你本想稍稍‘调整’下数值，但外面的守卫听到了你们的对话，并向你摇了摇头。好吧，那就%reward_completion%克朗吧。  |  你回来的时候，%employer%的大腿上正坐着一个女人。具体地说，她正弯着腰，而他正高举着双手。他们停了下来，一齐看向你，然后她迅速地躲到了桌子底下去，而他整理了下衣服。%SPEECH_ON%佣兵！见到你真是太高兴了！这么说你已经成功消灭了那些绿皮怪物，对吗？%SPEECH_OFF%那位躲在桌子下的可怜女人偷偷露出了脑袋，而正在汇报事情经过的你努力让自己不去注意她的存在。他拍了拍手，似乎想站起来，然而却意识到这并不方便。%SPEECH_ON%如果你不介意的话，你那%reward_completion%克朗的报酬正放在我身后的书架上。%SPEECH_OFF%你去拿报酬的时候他还尴尬的笑了笑。}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Destroyed a goblin encampment");
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
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Origin, this.List);
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"location",
			this.m.Destination == null || this.m.Destination.isNull() ? "" : this.m.Destination.getName()
		]);
		_vars.push([
			"direction",
			this.m.Destination == null || this.m.Destination.isNull() ? "" : this.Const.Strings.Direction8[this.m.Origin.getTile().getDirection8To(this.m.Destination.getTile())]
		]);
	}

	function onOriginSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Origin.addSituation(this.new("scripts/entity/world/settlements/situations/greenskins_situation"));
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

		if (this.m.Origin != null && !this.m.Origin.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Origin.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(4);
			}
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

			if (this.m.Origin.getOwner().getID() != this.m.Faction)
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

