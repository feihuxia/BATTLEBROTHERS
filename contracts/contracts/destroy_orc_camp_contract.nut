this.destroy_orc_camp_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Dude = null,
		Reward = 0
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.destroy_orc_camp";
		this.m.Name = "摧毁兽人营地";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		local camp = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getNearestSettlement(this.m.Origin.getTile());
		this.m.Destination = this.WeakTableRef(camp);
		this.m.Flags.set("DestinationName", this.m.Destination.getName());
		this.m.Payment.Pool = 900 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		local r = this.Math.rand(1, 3);

		if (r == 1)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else if (r == 2)
		{
			this.m.Payment.Completion = 1.0;
		}
		else if (r == 3)
		{
			this.m.Payment.Completion = 0.5;
			this.m.Payment.Count = 0.5;
		}

		local maximumHeads = [
			20,
			25,
			30
		];
		this.m.Payment.MaxCount = maximumHeads[this.Math.rand(0, maximumHeads.len() - 1)];
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

				this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.OrcRaiders, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.setLootScaleBasedOnResources(115 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));
				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
				this.Flags.set("HeadsCollected", 0);

				if (this.World.FactionManager.getFaction(this.Contract.getFaction()).getFlags().get("Betrayed") && this.Math.rand(1, 100) <= 75)
				{
					this.Flags.set("IsBetrayal", true);
				}
				else
				{
					local r = this.Math.rand(1, 100);

					if (r <= 5)
					{
						this.Flags.set("IsSurvivor", true);
					}
					else if (r <= 15 && this.World.Assets.getBusinessReputation() > 800)
					{
						if (this.Contract.getDifficultyMult() >= 0.95)
						{
							this.Flags.set("IsOrcsAgainstOrcs", true);
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
					if (this.Flags.get("IsSurvivor") && this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.Contract.setScreen("Volunteer1");
						this.World.Contracts.showActiveContract();
						this.Contract.setState("Return");
					}
					else if (this.Flags.get("IsBetrayal"))
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
				if (this.Flags.get("IsOrcsAgainstOrcs"))
				{
					if (!this.Flags.get("IsAttackDialogTriggered"))
					{
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.setScreen("OrcsAgainstOrcs");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "OrcAttack";
						p.Music = this.Const.Music.OrcsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
						p.IsAutoAssigningBases = false;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.OrcRaiders, 150 * this.Contract.getReputationToDifficultyMult(), this.Const.Faction.Enemy);
						this.World.Contracts.startScriptedCombat(p, false, true, true);
					}
				}
				else
				{
					local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					p.CombatID = "OrcAttack";
					p.Music = this.Const.Music.OrcsTracks;
					this.World.Contracts.startScriptedCombat(p, true, true, true);
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

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_combatID == "OrcAttack" || this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull() && this.World.State.getPlayer().getTile().getDistanceTo(this.Contract.m.Destination.getTile()) <= 1)
				{
					if (_actor.getFaction() == this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getID())
					{
						this.Flags.set("HeadsCollected", this.Flags.get("HeadsCollected") + 1);
					}
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
		this.importScreens(this.Const.Contracts.NegotiationPerHead);
		this.importScreens(this.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_61.png[/img]{%employer%愤怒地喘着粗气。%SPEECH_ON%该死的。%SPEECH_OFF%他走到窗边，看向外面。%SPEECH_ON%我最近举办了一场骑士比武，但却产生了一些小争议。现在，除非我解决这个小问题，否则我的骑士们都不会为我工作了。%SPEECH_OFF%你问他是否想雇佣佣兵来解决这场贵族的纷争。那个男人大笑起来。%SPEECH_ON%当然不想，卑微的家伙。我需要你前往%origin%%direction%方向去解决一些正在搭建营地的绿皮怪物。他们一直威胁着那块区域，所以我想请你帮帮这个忙。你对此有兴趣吗？还是我得去找找别的佣兵？%SPEECH_OFF%  |  %employer%将脚架在了桌子上。%SPEECH_ON%你对那些绿皮怪物有什么看法吗，佣兵？%SPEECH_OFF%你摇了摇头，而那个男人歪着脑袋说道。%SPEECH_ON%有趣。大部分人会说自己害怕他们，或是说那群家伙是杀人不眨眼的残暴野兽。而你……与众不同。我喜欢。怎么说，你愿意去%origin%%direction%方向到那个被叫做%location%的地方吗？我们在那里发现了一大群需要驱赶的兽人。%SPEECH_OFF%  |  %employer%的桌子上正趴着一只小猫。他抚摸着它，蜷缩着的小猫突然低叫一声，咬了那个男人一口，然后从你进来的门跑了出去。%employer%捂着自己的手指。%SPEECH_ON%该死的动物。刚才还腻着你，然后就，唉……%SPEECH_OFF%他吮吸着手指上流下的鲜血。你问他自己是否需要回避一下，好让他处理伤口。%SPEECH_ON%别逗，佣兵。不，我只想让你去%origin%%direction%解决那里的绿皮怪物。我们需要摧毁他们，粉碎他们，怎么着都行，只要让他们‘消失’就好。你能帮上这个忙吗？%SPEECH_OFF%  |  %employer%一边卷起手中的卷轴，一边诉说了自己目前的困境。%SPEECH_ON%贵族间的斗争真是让我头痛死了，战士。不幸的是，一群兽人正好挑这个时候入侵了这些地方。他们在%origin%的%direction%d搭建营地。我无法一边处理家族纷争一边去解决那群怪物，因此，佣兵，我希望你能对此有所兴趣。%SPEECH_OFF%  |  %employer%上下打量着你。%SPEECH_ON%你有本事解决绿皮怪物吗？还有你的那群手下呢？%SPEECH_OFF%你点了点头，假装这件事就跟吃饭喝水一样简单。%employer% 笑了起来。%SPEECH_ON%很好，因为我们在%origin%%direction%方向上发现了很多那种家伙。去消灭他们吧。很简单，对吗？我就知道能引起你这种……自信者的兴趣。%SPEECH_OFF%  |  %employer%正在用一些农民们梦寐以求的食物喂着他的狗。他抹了抹手上的油脂。%SPEECH_ON%这种垃圾食物竟然是我的厨师做的，你能信？可怕。恶心。%SPEECH_OFF%你点了点头，装作似乎拿这种优质食物喂狗是这世界上再普通不过的事情了。%employer%将目光看向了他的桌子。%SPEECH_ON%总之，给我提供肉食的人报告说有一群绿皮怪物正在屠杀他们的牛群。很显然，那些家伙的营地就在%origin%%direction%方向上。如果你有兴趣的话，我希望你能去那边消灭他们。%SPEECH_OFF%  |  你发现%employer%正盯着几份卷轴。他瞥了你一眼，然后请你坐下。%SPEECH_ON%很高兴你来了，雇佣兵。这些地方遇到了绿皮怪物的侵扰 - 他们在%direction%方向上搭建了一个营地。%SPEECH_OFF%他放下了其中一份卷轴。%SPEECH_ON%而我也没有足够的钱让我的手下去办这件事。骑士是更加……昂贵的存在。而你，正好合适做这份工作。你怎么说？%SPEECH_OFF%  |  你进入%employer%办公室的时候，刚好有一群人离开了。那些人是骑士，他们的剑鞘在身边叮当作响。%employer%对你的到来表示了欢迎。%SPEECH_ON%别管他们。他们只想知道我上个雇佣的人发生了什么。%SPEECH_OFF%你抬了抬眉毛。那个男人摆了摆手。%SPEECH_ON%哦，别给我露出那种表情，佣兵。你应该很了解的，有时候一个人的水平不济也就意味着……%SPEECH_OFF%你什么话都没说，短暂的沉默后，向他点了点头。%SPEECH_ON%很好，很高兴你能够理解。现在谈谈正事吧，我们在%origin%%direction%方向上发现了一群绿皮怪物。他们在那里搭建了个营地，如果自我上次，呃，派人手过去后，他们还没换地方的话。你有兴趣帮我去消灭他们吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{跟兽人战斗可不便宜。 |  我相信你会为此慷慨解囊的。 |  我们来谈谈钱的问题。}",
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
			ID = "OrcsAgainstOrcs",
			Title = "攻击前……",
			Text = "[img]gfx/ui/events/event_49.png[/img]{当你下令发动攻击时，突然发现了一群兽人……彼此间打了起来？那群绿皮怪物似乎分成了两个阵营，而他们解决纷争的办法就是把意见不合者撕成两半。真是可怕的暴力。你本打算等他们打完了再上，结果有两个兽人莫名其妙地打到了你的身边，突然间所有兽人都看向了你。唔，现在可别想跑了……拿起武器！ |  你下令让%companyname%发动攻击，想要先发制人。但却发现他们正全副武装着！而且……互相厮打着？\n\n这群兽人撕裂着对手的身躯，敲碎对手的头颅。看起来似乎是发生了某种内部纷争。很遗憾你没等那些残暴的兽人们解决完他们的纷争，现在，准备迎战吧！ |  兽人们正在内斗！你似乎遇上了一群彼此间产生纷争的绿皮怪物。互相厮杀的兽人，多么罕见的景象！集合你的手下，你或许只需要解决这场斗争的胜利者就行了。 |  老天，你没想到兽人的数量竟会那么多！不过幸运的是，他们似乎在内斗。你不知道这种情况是因为他们之间产生了分歧还是这仅仅是一场醉酒后的狂欢。无论如何，你现在都被卷入其中了！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备迎战！",
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
			Text = "[img]gfx/ui/events/event_78.png[/img]{当你解决了最后一只兽人，突然出现了一队全副武装的人。他们的中尉站了出来，拇指插进了绑着剑的皮带里面。%SPEECH_ON%诶呀呀，你们还真是蠢。%employer%记性很好 - 他还没有忘掉你上次背叛了%faction%的事情。把这想成是…………一个小小的回礼好了。%SPEECH_OFF%一瞬间，所有中尉身后的人突了过来。武装起来，这是次埋伏！ |  将兽人的血从剑上擦去之后，你突然发现了一队向你走来的人。他们带着%faction%的旗帜，而且正在拔出武器。当那些人开始冲锋，你突然意识到这是次埋伏。他们先让你跟兽人厮杀一番，才进来解决残局，狗娘养的！来吧！ |  一个男人朝你走了过来。他的武器很好，装甲很好，而且似乎很开心，当靠近的时候咧嘴笑着。%SPEECH_ON%晚上好啊，佣兵们。绿皮怪物那事做的不错嘛？%SPEECH_OFF%他停了一会，褪去笑容。%SPEECH_ON%%employer% 向你问好。%SPEECH_OFF%说时迟那时快，一队人从路边冲了出来。埋伏！那该死的贵族背叛了你！ |  战斗还没有结束，一队穿着%faction%颜色盔甲的人在你身后排开，双方对峙着。他们的领袖打量着你。%SPEECH_ON%等我从你那夺走那把剑，我得好好欣赏欣赏。%SPEECH_OFF%你耸了耸肩问为什么会有这次埋伏。%SPEECH_ON%%employer%不会忘记那些背叛他或他的家族之人。你只需要知道那一点。其他废话并不能改变你必死的命运。%SPEECH_OFF%那么就拿起武器战斗吧！ | 你的人冲进了兽人营地，但是什么也没有发现。突然，几个陌生人出现在你身后，那队伍的中尉恶意地向前走了几步。他的布衣上带着%employer%的印记。%SPEECH_ON%真可惜那些兽人没有解决你们。如果你是在好奇我为什么会出现，告诉你，这是你欠%faction%的债。你保证过要完成任务。但是你没能遵守约定。现在你得死。%SPEECH_OFF%你拔出剑，将剑刃砍向中尉。%SPEECH_ON%看上去%faction%又要有一个完不成的任务了。%SPEECH_OFF%}",
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
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 140 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.getFaction());
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
			Text = "[img]gfx/ui/events/event_32.png[/img]{战斗结束了，你搜寻着兽人营地。在废墟之中，你发现了完全不可用的重型盔甲以及人类武器。不幸的是，你无法查明这些东西的主人是谁了。 |  当兽人被屠戮殆尽后，你检查了一下他们的营地。满是粪便。真的，地上全是翔。那些该死的东西一点也不懂卫生。%randombrother%踉跄了一脚，于是把鞋子在帐篷杆子上蹭着。%SPEECH_ON%长官，我们是要离开了还是要继续搜寻……？%SPEECH_OFF%你已经看、闻够了。 | 兽人营地就是满目疮痍的下流废土。你可以闻到他们性爱和排泄的味道。难怪他们这么好战，他们根本不懂任何文明的概念。 |  兽人营地已经被摧毁了，你决定花点时间打扫战场。在一处营火的灰烬中你发现了几具人类尸体。从他们的武器来看，似乎是跟你一样的雇佣兵。真是可惜……他们的装备全都烧烂了。 | 你的几个佣兵走过了兽人营地的废墟。他们捡拾着，翻找着有用物品。%randombrother%将他满是血污的剑收了进去。%SPEECH_ON%这里啥也没有，长官。%SPEECH_OFF%你点了点头，让队伍做好回%employer%那的准备。 |  战斗已经结束了，你在营地转悠着，想要找出点有用的东西。你没有发现任何值得带走的东西，但是你发现了一堆死去的骑士。他们满是蛆虫的苍白脸孔说明他们已经在这地方有一会了。谁知道兽人对他们做了什么。}",
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
			ID = "Volunteer1",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_32.png[/img]{战斗已经结束了，但是你还是能听见尖叫。你告诉%randombrother%闭上他的嘴，因为他平时就喜欢嚷嚷吵吵，但是他摇了摇头，说不是他发出的声音。突然，一个被锁链拷住的男人从兽人营地的灰烬中站了起来。%SPEECH_ON%晚上好啊，好心的先生们！我相信你们救了我。%SPEECH_OFF%他踉跄着向前，身后激起了一堆灰烬。%SPEECH_ON%真是太谢谢了，我想要报答你们。你们是雇佣兵，对吗？如果是那样的话，我想要为你战斗。%SPEECH_OFF%他从地上捡起了一把剑，在手里把玩着，熟练的就像是用了一辈子的武器一样。一个有趣的提议变得更加有趣了…… | 当你在清洗剑刃时，一个声音从倒塌的兽人帐篷中传了出来。%SPEECH_ON%谢天谢地，你做到了！%SPEECH_OFF%你看着一个微笑着的男人走了出来。%SPEECH_OFF%你救了我！我想要报答你对我的帮助！%SPEECH_OFF%他伸出了他的手，停了一会，然后收了回去。%SPEECH_OFF%我是说为你战斗！我想要为你作战，先生！如果你可以做成这种事情，那肯定你们的战团很不得了，是不是？%SPEECH_OFF%嗯哼，一次有趣的提议。你扔了一把武器给他，他轻松接住了。他把玩着剑柄，翻转着想要把剑收入看不见的剑鞘中一样。%SPEECH_ON%我叫%dude_name%。%SPEECH_OFF% | 一个衣衫褴褛，身着破烂铠甲的男人朝你跑了过来。他的手被反绑在了背后。%SPEECH_ON%你成功了！难以置信！抱歉，请原谅我的无礼我一天前被兽人抓住了，我们本想要摧毁这营地。当你出现之前，我以为他们就要把我烤了呢。我看准时机跑了出来，但是我觉得加入你们的队伍应该不错。%SPEECH_OFF%你要那男人直接说重点。他照做了。%SPEECH_ON%我想要为你而战，先生。我有经验 -有在领主的军队里待过，做过佣兵，还有……其他。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "欢迎来到战团！",
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
					Text = "你得另寻机会了。",
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
				this.Contract.m.Dude.setStartValuesEx(this.Const.CharacterVeteranBackgrounds);

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
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你回到了%employer%那里，汇报了你的情况。他挥挥手。%SPEECH_ON%拜托，佣兵。我早就知道了。你难道不知道我在这些地方有探子的吗？%SPEECH_OFF%他朝桌边的一个袋子示意了一下。你拿掉之后男人敲了敲台子。%SPEECH_ON%那报酬应该可以了，现在请离开我的视线。%SPEECH_OFF%  |  你给%employer%展示了一个兽人头颅。他盯着那东西，然后盯着你。%SPEECH_ON%有趣。所以我相信你已经完成了我的要求？%SPEECH_OFF%你点了点头。男人微笑了起来，交出了一个装有%reward%克朗的木箱子。%SPEECH_ON%就知道我可以相信你，佣兵。%SPEECH_OFF%  |  当你回来之后%employer%一直盯着你。%SPEECH_ON%我已经听说了你的所作所为%SPEECH_OFF%他声音带着奇怪的味道，让你迅速回想了一遍你过去一周做的所有事情。在那里的是个贵族女人吗…………不，不可能啊。%SPEECH_ON%兽人已经死了。做的好，佣兵。%SPEECH_OFF%他递给你一袋%reward%克朗的袋子，你放松了下来。 |  你进入了%employer%的房间，坐了下来，给自己倒了一杯葡萄酒。贵族盯着你。%SPEECH_ON%我得说那还真是过分，如果我心情好的话就是吊刑，如果心情不好那就是火刑了。%SPEECH_OFF%你喝完之后将兽人的头颅甩在了男人的桌子上。酒杯翻到，滚到了一边。%employer%往后退，然后镇定了下来。%SPEECH_ON%啊，很好，还真是值得喝一杯。反正那也不是我最好的酒。我的守卫%randomname%在外面等着你。他手上有我们之前约定的%reward%克朗。%SPEECH_OFF%  |  你举起了一个兽人头颅给%employer%看。绿色的下颚张开，舌头卷在獠牙之间。%employer%点了点头，然后动了动手。%SPEECH_ON%行行好，我晚上不想做噩梦，拿走那东西。%SPEECH_OFF%你做到了。男人摇了摇他的头。%SPEECH_ON%这些日子里面一想到这种东西就在附近，我就根本没办法安眠。不管怎么说，你的%reward%克朗已经在门外等你了，在我的一个守卫身上。感谢你的努力，佣兵。%SPEECH_OFF%  |  你到了%employer%的房间之后发现他正在一份卷轴上面画着。他盯着你，羊皮纸边缘缩了回去。%SPEECH_ON%我的女儿觉得她是个艺术家，你敢信吗？%SPEECH_OFF%他给你看了看卷轴。是一个看起来像%employer%的男人的还不错的画像。那人影正对一个绞刑吏。%employer%笑了起来。%SPEECH_ON%傻女孩。%SPEECH_OFF%他把卷轴卷了起来，扔到一边。%SPEECH_ON%不管怎么说，我的探子们已经告诉了我你的事迹。我们约定好的报酬。%SPEECH_OFF%}",
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
						this.World.Assets.addMoney(this.Contract.m.Reward);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Destroyed an orc encampment");
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
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion() + this.Flags.get("HeadsCollected") * this.Contract.m.Payment.getPerCount();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] 克朗"
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
		_vars.push([
			"dude_name",
			this.m.Dude == null ? "" : this.m.Dude.getNameOnly()
		]);
		_vars.push([
			"reward",
			this.m.Reward
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

