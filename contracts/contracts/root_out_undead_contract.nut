this.root_out_undead_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Objective1 = null,
		Objective2 = null,
		Target = null,
		Current = null,
		IsPlayerAttacking = false
	},
	function create()
	{
		this.contract.create();
		local r = this.Math.rand(1, 100);

		if (r <= 70)
		{
			this.m.DifficultyMult = this.Math.rand(95, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}

		this.m.Type = "contract.root_out_undead";
		this.m.Name = "根除不死族";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		if (this.m.Origin == null)
		{
			this.setOrigin(this.World.State.getCurrentTown());
		}

		local nearest_undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getNearestSettlement(this.m.Origin.getTile());
		local nearest_zombies = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getNearestSettlement(this.m.Origin.getTile());

		if (this.Math.rand(1, 100) <= 50)
		{
			this.m.Objective1 = this.WeakTableRef(nearest_undead);
			this.m.Objective2 = this.WeakTableRef(nearest_zombies);
		}
		else
		{
			this.m.Objective2 = this.WeakTableRef(nearest_undead);
			this.m.Objective1 = this.WeakTableRef(nearest_zombies);
		}

		this.m.Flags.set("Objective1Name", this.m.Objective1.getName());
		this.m.Flags.set("Objective2Name", this.m.Objective2.getName());
		this.m.Payment.Pool = 1500 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
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
					"摧毁 %objective1%",
					"摧毁 %objective2%",
					"返回 %townname%"
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
				this.Contract.m.Objective1.setLootScaleBasedOnResources(120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Objective1.setResources(120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Objective1.clearTroops();
				this.Contract.addUnitsToEntity(this.Contract.m.Objective1, this.Contract.m.Objective1.getDefenderSpawnList(), 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Objective1.setDiscovered(true);

				if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Objective1.getTags().get("IsEventLocation"))
				{
					this.Contract.m.Objective1.getLoot().clear();
				}

				this.World.uncoverFogOfWar(this.Contract.m.Objective1.getTile().Pos, 500.0);
				this.Contract.m.Objective2.setLootScaleBasedOnResources(120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Objective2.setResources(120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Objective2.clearTroops();
				this.Contract.addUnitsToEntity(this.Contract.m.Objective2, this.Contract.m.Objective2.getDefenderSpawnList(), 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Objective2.setDiscovered(true);

				if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Objective2.getTags().get("IsEventLocation"))
				{
					this.Contract.m.Objective2.getLoot().clear();
				}

				this.World.uncoverFogOfWar(this.Contract.m.Objective2.getTile().Pos, 500.0);
				local r = this.Math.rand(1, 100);

				if (r <= 10)
				{
					this.Flags.set("IsNecromancers", true);
				}
				else if (r <= 25)
				{
					this.Flags.set("IsBandits", true);
				}

				this.Flags.set("ObjectivesDestroyed", 0);
				this.Flags.set("Objective1ID", this.Contract.m.Objective1.getID());
				this.Flags.set("Objective2ID", this.Contract.m.Objective2.getID());
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [];

				if (this.Contract.m.Target != null && !this.Contract.m.Target.isNull() && this.Contract.m.Target.isAlive())
				{
					this.Contract.m.Target.getSprite("selection").Visible = true;
					this.Contract.m.BulletpointsObjectives.push("杀死逃跑的死灵巫师");
				}

				if (this.Contract.m.Objective1 != null && !this.Contract.m.Objective1.isNull() && this.Contract.m.Objective1.isAlive())
				{
					this.Contract.m.Objective1.getSprite("selection").Visible = true;
					this.Contract.m.BulletpointsObjectives.push("摧毁 %objective1%");
					this.Contract.m.Objective1.setOnCombatWithPlayerCallback(this.onCombatWithPlayer.bindenv(this));
				}

				if (this.Contract.m.Objective2 != null && !this.Contract.m.Objective2.isNull() && this.Contract.m.Objective2.isAlive())
				{
					this.Contract.m.Objective2.getSprite("selection").Visible = true;
					this.Contract.m.BulletpointsObjectives.push("摧毁 %objective2%");
					this.Contract.m.Objective2.setOnCombatWithPlayerCallback(this.onCombatWithPlayer.bindenv(this));
				}
			}

			function update()
			{
				if (this.Flags.get("ObjectiveDestroyed"))
				{
					this.Flags.set("ObjectiveDestroyed", false);

					if (this.Flags.get("IsBanditsCoop"))
					{
						this.Contract.setScreen("BanditsAftermathCoop");
					}
					else if (this.Flags.get("IsBandits3Way"))
					{
						this.Contract.setScreen("BanditsAftermath3Way");
					}
					else if (this.Flags.get("ObjectivesDestroyed") == 1)
					{
						this.Contract.setScreen("Aftermath1");
					}
					else
					{
						this.Contract.setScreen("Aftermath2");
					}

					this.World.Contracts.showActiveContract();
				}

				if (this.Flags.get("IsNecromancersSpawned"))
				{
					if (this.Contract.m.Target == null  ||  this.Contract.m.Target.isNull())
					{
						this.Contract.setScreen("NecromancersAftermath");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Contract.m.Target.getTile().getDistanceTo(this.World.State.getPlayer().getTile()) >= 9)
					{
						this.Contract.setScreen("NecromancersFail");
						this.World.Contracts.showActiveContract();
					}
				}

				if (!this.Flags.get("IsBandits")  ||  this.Flags.get("ObjectivesDestroyed") != 0)
				{
					if (this.Contract.m.Objective1 != null && !this.Contract.m.Objective1.isNull() && !this.Contract.m.Objective1.getTags().has("TriggeredContractDialog") && this.Contract.isPlayerNear(this.Contract.m.Objective1, 450))
					{
						this.Contract.m.Objective1.getTags().add("TriggeredContractDialog");
						this.Contract.setScreen("UndeadRepository");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Contract.m.Objective2 != null && !this.Contract.m.Objective2.isNull() && !this.Contract.m.Objective2.getTags().has("TriggeredContractDialog") && this.Contract.isPlayerNear(this.Contract.m.Objective2, 450))
					{
						this.Contract.m.Objective2.getTags().add("TriggeredContractDialog");

						if (this.Flags.get("IsNecromancers"))
						{
							this.Flags.set("IsNecromancersSpawned", true);
							this.Contract.setScreen("Necromancers");
							this.World.Contracts.showActiveContract();
						}
						else
						{
							this.Contract.setScreen("UndeadRepository");
							this.World.Contracts.showActiveContract();
						}
					}
				}
			}

			function onCombatWithPlayer( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
				this.Contract.m.Current = _dest;

				if (_dest != null && !_dest.getTags().has("TriggeredContractDialog") && this.Flags.get("IsBandits") && this.Flags.get("ObjectivesDestroyed") == 0)
				{
					_dest.getTags().add("TriggeredContractDialog");
					this.Contract.setScreen("Bandits");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					_dest.m.IsShowingDefenders = true;
					local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					p.EnemyBanners.push(_dest.getBanner());

					if (this.Flags.get("IsBandits") && this.Flags.get("ObjectivesDestroyed") == 0)
					{
						if (this.Flags.get("IsBanditsCoop"))
						{
							p.AllyBanners.push("banner_bandits_06");
							this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.BanditRaiders, 90 * this.Contract.getReputationToDifficultyMult(), this.Const.Faction.PlayerAnimals);
						}
						else
						{
							p.EnemyBanners.push("banner_bandits_06");
							this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.BanditRaiders, 90 * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getID());
						}
					}

					this.World.Contracts.startScriptedCombat(p, this.Contract.m.IsPlayerAttacking, true, true);
				}
			}

			function onLocationDestroyed( _location )
			{
				if (_location.getID() == this.Flags.get("Objective1ID"))
				{
					this.Contract.m.Objective1 = null;
					this.Flags.set("ObjectiveDestroyed", true);
					this.Flags.set("ObjectivesDestroyed", this.Flags.get("ObjectivesDestroyed") + 1);
				}
				else if (_location.getID() == this.Flags.get("Objective2ID"))
				{
					this.Contract.m.Objective2 = null;
					this.Flags.set("ObjectiveDestroyed", true);
					this.Flags.set("ObjectivesDestroyed", this.Flags.get("ObjectivesDestroyed") + 1);
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{你发现%employer%正在卷起一张地图，然后用蜡烛点燃了终端。火舌迅速升起，将纸张烧黑。他挥手示意你进来。%SPEECH_ON%对于军队来说坏地图就跟毒药一样。但是，一张好地图，就是黄金。%SPEECH_OFF%火焰舔舐起了他的手指，男人把纸张扔掉用脚踩灭了。他坐了下来，拿出了另一份卷轴，在桌子上摊开。这是，你见过的，最简洁漂亮的地图。%employer%使用两根棍子指出了两个不同的位置。%SPEECH_ON%“%objective1%”和“%objective2%”，两个神奇的名字。我的探子们就是说不死人在从这里面出来。大部分的怪兽都是从这出来的。去这两个地方，佣兵，帮忙终结这些可怕的东西。%SPEECH_OFF% |  你走进了%employer%的房间。他的将军们涨红了脸，一场没有结果的争执。贵族挥手示意你进来。%SPEECH_ON%啊，我想要跟他讲话的男人。伙计们，让开。%SPEECH_OFF%被凶狠地盯着，你走进了一群傲慢自大的指挥官中。%employer%将一张地图塞进了你的胸口。上面用圆圈还有潦草画就的叉骨骷髅圈出了两个位置。%SPEECH_ON%去这两个地方2，佣兵。“%objective1%”和“%objective2%”。我的文士相信这些地方是不死人狂潮的关键位置。我的指挥官们不这么认为，但是为什么不去看一下呢？如果你看见这些吓人的东西的话，杀了它们，摧毁它们的该死老巢，然后把你的英雄事迹的消息带给我。可以么？%SPEECH_OFF%  |  %employer%正在照料着他的花园。植物都已经枯萎了。他用手指擦去藤蔓上的灰烬。%SPEECH_ON%我伤心了，佣兵，事情变成这样子了，但是最起码我该死的食物不会复活吃我了。%SPEECH_OFF%你大笑着回应。%SPEECH_ON%给它点时间就行。我们可不知道一株植物会有什么样子的复仇心的。%SPEECH_OFF%贵族点了点头，就像你是一个哲学家而不是一个在开玩笑的佣兵一样。他朝你扔了一张地图。%SPEECH_ON%你会找到两个标记着的位置，“%objective1%”还有“%objective2%”。理论上，这两个地方都是不死人的巢穴。去那里，杀光它们，然后摧毁它们的家。或者说坟墓。深渊。不管是什么。%SPEECH_OFF%  |  一脸可怜相的一个农民，一个很普通的农名，在你进去的时候正好离开%employer%的房间。你的雇主挥了挥手要你去他的桌子上去。%SPEECH_ON%真高兴你在这里，佣兵，因为我有些任务给你。我的探子报告说对我和这片土地的人们有着非常重要意义的两个位置。“%objective1%”和“%objective2%”还有，理论上 ，这两个地方都有不死人出没。所以，你去那里调查一下怎么样？我说调查的意思是如果这些传闻是真的话就杀光它们然后告诉我这个好消息。%SPEECH_OFF%  |  你发现%employer%正在盯着他桌子上的一只死猫。猫东西胸口插了一把匕首，你意识到贵族手里拿着另一把。一个护卫站在旁边，剑拔了出来，旁边一个文士手里拿着羽毛笔和卷轴。所有人都慢慢放松下来知乎你走过了房间。刀剑都收了起来，笔都放下了。文士赶紧把猫拿走去做鬼知道的事情去了。%employer%坐了下来。%SPEECH_ON%佣兵,你好啊。我们是在做一次实验。我们不相信猫真的有九条命，但是在这个新的恐怖世界中他们有可能会有两条。但是原来，他们没有。他们就只有一条命。%SPEECH_OFF%贵族拿出了一张地图然后在桌子上摊开来。他指了指两个标记。%SPEECH_ON%“%objective1%”，还有这里的“%objective2%”。去这两个地方。如果我的探子是对的话，你将会在那里找到不死人。很多很多不死人。你要摧毁那里的一切东西，然后保证不死人被铲除的干干净净的。%SPEECH_OFF%  |  %employer%旁边站着一个风尘碌碌的斥候。开拓者正在吃东西喝水，补充在道路上疾驰损失的体力。%employer%给了你一张潦草写就的地图。%SPEECH_ON%“%objective1%”以及“%objective2%”。我们，我友善的探子，相信这些地方是不死人的巢穴，但是现在已经不是这样子了。各种不洁怪物都在从这些地出来。去那里，摧毁你看见的所有东西，然后像个英雄一样回来。%SPEECH_OFF%你耸了耸肩。%SPEECH_ON%%companyname%喜欢克朗而不是赞美。%SPEECH_OFF%  |  %employer%用一张地图迎接了你。%SPEECH_ON%“%objective1%”和“%objective2%”，认得这些地方吗？不，当然不了。但是我想要你去这两个地方，铲除那边徘徊着的一切邪恶生物，然后回来。很简单的，去不死人巢穴春游，对不对？%SPEECH_OFF%好吧。会出什么错？ |  %employer%问你怕不怕不死人。你耸了耸肩然后回答了。%SPEECH_ON%我害怕的就只是死的时候后悔想做的事情还没有做完。还有马也很可怕。%SPEECH_OFF%贵族笑了起来。%SPEECH_ON%好吧，好吧。地图给你。你会看见标记着“%objective1%”和“%objective2%”的位置。我的探子相信那些地方是不死人的巢穴。很符合逻辑，毕竟一开始死者就都是被安置在那里的。去这两个地方，消灭它们，然后回来拿报酬。是不是很简单？%SPEECH_OFF%  |  %employer%在门口拿着一张地图欢迎你。%SPEECH_ON%“%objective1%”和“%objective2%”，标记的很清楚了，看见了吗？我的探子们说可怕的邪恶生物正在那里出来。如果那是真的话，我需要一个无所畏惧的杀手去这两个地方摧毁那里的一切东西。我相信你就是这样一个人。是嘛？%SPEECH_OFF%   |  一个装备精良，但是满脸愁容的男人离开了%employer%的房间。当你进去的时候，贵族们挥手让你靠近他的桌子看地图。%SPEECH_ON%你不怕死人吧?亡灵呢？完美。“%objective1%”在这里，“%objective2%”在那里。去这两个地方，消灭他们，给那个刚刚走出这扇门的懦夫看看真正的男人的样子。%SPEECH_OFF%你举出了一根手指纠正他。%SPEECH_ON%一个真正的男人可以做的-为了合适的价格。%SPEECH_OFF%  |  %employer%用一个奇怪的问题作为开场迎接了你。%SPEECH_ON%有去过坟墓吗，佣兵？%SPEECH_OFF%在你回答之前，男人给自己倒了一杯酒然后闷了一大口，举出另一只手止住你。%SPEECH_ON%都是很神奇的东西。相当不自然其实是。什么样子的生物会带着自己死去的同类，然后去其他地方，找块好地方埋葬他们呢？华而不实。相当不合理。既然这样，死者复苏还有什么奇怪的？也许他们是因为我们打破了自然规律而来折磨我们的。%SPEECH_OFF%男人给了扔了一份卷轴，里面是一份笔迹工整的地图。有两个位置做了标记。%SPEECH_OFF%“%objective1%”还有“%objective2%”。我需要你去这两个地方，消灭它们，然后回来。对于你这种职业的人来说小菜一碟是不是？%SPEECH_OFF%  |  你发现%employer%摇着头在地图上书写着什么。%SPEECH_ON%“%objective1%”和“%objective2%”，离这不远的两个狗屎地方，需要有人去灭了那地方。当然了，它们是埋死人的地方，所以，有不死人。它们不肯给我们安宁，这些尸体能获得平静么？谁知道呢。不管怎么说，杀光他们，知道了吗？%SPEECH_OFF%  | %employer%在照料着十几只笼中之鸟。有些在他们的囚牢中扑来扇去，冲撞着铁笼。贵族捡起了一只死鸟，受到惊吓的鸟腿还在空中抽搐着。他把尸体扔给了你。%SPEECH_ON%我有一份任务给你，佣兵。“%objective1%”和“%objective2%”离这不远，需要有人去毁灭这些地方。我的探子已经汇报说这些地方是不死人的基地，有可能是个源头，如果这些尸体能够理解这种概念的话。%SPEECH_OFF%男人开始往牢笼中投掷鸟食。几只鸟儿盯着食物，决定不去吃，决定不去服从夺取了大自然能够给予的最大礼物的盗贼。但是，那些翅膀被剪短的鸟儿们，开始啄食了起来。%employer%转向你，拍手搓掉了手上的残渣。%SPEECH_ON%所以，达成共识了吗？%SPEECH_OFF%  |  你发现%employer%被他的卫兵们围了起来，所有人都盯着房间中央的一具尸体。在贵族向你打招呼之前你就先闻到了一股可怕的恶臭。尸体上散发出了一团瘴气，就像是风中的一股灰烬一样的暗灰色。%SPEECH_ON%佣兵！你来了真是太好了！尽可能无视这东西吧！我们有一个自杀了的卫兵，复活了。也许是一次精心策划的暗杀？这个世界上什么都有可能。来，我有东西要给你。%SPEECH_OFF%他挥手示意你上前，伸出的手里拿着一份卷轴。你拿了过去，是一张地图。男人解释说道。%SPEECH_ON%“%objective1%”和“%objective2%”，如果你认得出的话，我们相信不死人的巢穴就在这里。我需要一个你，呃，这样刚毅的男人去那里摧毁这两个地方。希望这能够提起你的兴趣。%SPEECH_OFF%  |  %employer%欢迎了你，但是一名卫兵用长杆利刃的剑刃挡住了你。贵族马上命令他的手下退下，这期间你保持着冷静。贵族道了歉。%SPEECH_ON%抱歉，但是所有人都很紧张。有一天其中一个人睡着的时候死了，然后，呃，他复活了。一个食尸鬼一样的咆哮怪物在一瞬间就杀死了三个人。%SPEECH_OFF%你擦了擦你的脸颊，想起来你反正也要刮胡子了。%employer%笑着点了点头。%SPEECH_ON%嗯，我就是喜欢你这一点，佣兵。永远好心情。看看我给你的地图。看见这些标点了吗？“%objective1%”和“%objective2%”，农民们都是这么称呼这些地点的。我们有理由相信两个地方都存在着影响着不死人大军的能量源。我需要一个像你这样果断坚决的人去那里消灭他们。你感兴趣了吗，佣兵？%SPEECH_OFF%  |  你发现%employer%靠在了他的凳子上面。他朝你扔了一份地图。%SPEECH_ON%好好读一下。看见“%objective1%”和“%objective2%”了吗？我的探子们相信他们是不死人的神奇力量来源。我想那里应该是有大量可以给不死人复生用的尸体而已。我需要你去这两个地方，消灭它们，然后回来。感兴趣吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{报酬有多少？ |  重点是报酬。}",
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
			ID = "UndeadRepository",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_57.png[/img]{战团闻到了一种熟悉的恶臭。%randombrother%提醒说他们肯定是接近巢穴了。你说他是个该死的天才，应该去为了人类去做发明。你几乎可以在战团的嘲笑声中听见他的沉默。 | 当你靠近你的目标的时候，越来越明显%employer%的预估是正确的。这恶臭很明确：不管是这地方死了什么东西都已经复苏了。 | 你发现一具尸体卡在树丛中，被树枝卡主的双手不停地以一种死物般的神态不停向前伸展着。%randombrother%靠近了几步，仔细保持着距离，然后用剑刺穿了它的头颅。他后退了一步，擦拭着武器，提醒战团肯定已经靠近你的目标了。 | 从腐烂尸体的难以忍受的气味以及它们制造出来的尸气来看，毫无疑问%objective%已经很近了。 | 你发现半个男人的身体在地上爬行着。它朝你伸出了手，无意识地呻吟着，对自己的新存在完全没有意识但是同时又渴望着终结你的存在。你一脚将它的头颅踩进了泥里面。它的咆哮模糊了起来，你小心地用一把匕首刺穿了它的耳孔。%randombrother%环顾四周。%SPEECH_ON%%objective%应该不远了。%SPEECH_OFF%  |  还看不见你的目的地，但是味道已经开始席卷而来，你希望这不是那里面的生物的味道。你让大伙为战斗做好准备。 |  %randombrother%指了指一群尸体挤在那里的道路，看上去是有史以来最古怪的死法了。你完全不知道发生了什么，但是尸体看上去已经死了很久了，但是又没有苍蝇或者其他动物的痕迹。你通知大伙目的地已经就在眼前，他们应该做好战斗准备。 |  战团碰到了一具手脚都带着镣铐的颤颤巍巍的尸体。活着时的囚禁在死后也没有终结，于是你就做了处刑者等了好久的事情，砍下了亡灵的头颅。%randombrother%询问你的目的地是不是就在附近，你点了点头。肯定是，%companyname%需要为这战斗做好准备。 | 你的目的地肯定不远了，战团一路上闻到的恶臭越来越浓了。不管是行尸还是有史以来拉肚子最严重的的人，%companyname%都应该做好准备。 | 死尸们一个接一个的来迎接你，一系列被轻而易举解决掉的线索将%companyname%带到了真正的目标。你们应该准备好战斗了，因为很快就要开始了。 | 一个老头向战团问好，说%objective%离这不远。你问他在这附近做什么。他耸了耸肩。%SPEECH_ON%老了呗，还能有啥？%SPEECH_OFF%  | %randombrother%嗅了嗅。%SPEECH_ON%我知道%randombrother2%的放屁有多臭，而且这不是他干的。%SPEECH_OFF%被侮辱了的佣兵耸了耸肩。%SPEECH_ON%厉害厉害，但是我觉得应该近了。我们肯定已经离%objective%很近了。%SPEECH_OFF%你点了点头然后告诉大家为接下来的战斗做好准备。 | 你发现一具双眼只剩两个黑洞的腐烂尸体敲打着一块大石头。它绕着石头走来走去，想要杀死它。%randombrother%一剑砍下了亡灵的头颅，就像是热刀砍黄油一样。他朝远处点了点头。%SPEECH_ON%%objective%已经很近了。%SPEECH_OFF%如果是这样的话，%companyname%应该准备好战斗了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "做好最坏的打算吧！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Aftermath1",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_46.png[/img]{这地方里面的邪灵已经散去了。你深深的吸了一口气，就像是第一次一样。但是空气本身已经因为你的胜利开始暖和了起来。只剩下%objective2%了。 | 最后的不死人也已经被铲除，你察觉到空气开始清新了起来，就像是早晨的浓雾被春季的阳光驱散了一样。景色的快速变化说明你已经清楚了此地的邪恶之物。现在只需要搞定%objective2%就能完成这份契约了。 |  此地的恶灵已经消散。下一个目标等着你。 | 这可怕的地方的恶灵已经驱散，契约里面只剩%objective2%了。 | 当最后一个亡灵也被干掉之后，你发现空气瞬间发生了变化。当你站在泥泞的世界中，那突如其来的干净感瞬间席卷了你。%randombrother%擦了擦额头。%SPEECH_ON%肯定已经结束了。去%objective2%了，对不？%SPEECH_OFF%  | 你进入了邪灵的领域，但是杀死了最后一只亡灵之后你周围的整个世界都突然光亮了起来，而且你脚下土地的气味也恢复了正常。现在这地方已经恢复平静，是时候去%objective2%那了。 | 这胜利很艰苦。亡灵和其他更加古代的恶灵在战场上徘徊。你希望%objective2%能够更轻松点，但是你对此表示怀疑。 | 你踢翻了一具古代死者的尸体。跟你自己完全不一样，这很有可能对于你认识的一切生命来说都是外星人。头颅形状诡异，就像是缩小的人类头颅一样，而且盔甲与武器看上去也诡异无比。\n\n 你让大伙做好了前往%objective2%的准备。 |  地表满是不死者的残骸。你踩过他们的尸体，发现你脚下的土地已经开始恢复正常，就像是土壤突然从躲藏的地方出现了，空气本身也更加干净了。也许恶灵真的已经离开了这个地方？不管怎么说，是时候去%objective2%，给他们友好的%companyname%牌治疗术了。 | 最后的不死人也被杀死了，你环顾战场。不止是一种死人，从他们各异的服装以及盔甲来看，很有可能甚至是来自不同年代的。游戏人穿着古代盔甲，而且杀人的时候也带着一种令人不安的统一感。\n\n %randombrother%靠了过来，说战团已经准备好前去%objective2%了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{胜利！ | 别活过来了！}",
					function getResult()
					{
						this.Contract.getActiveState().start();
						this.World.Contracts.updateActiveContract();
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Aftermath2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_46.png[/img]{%objective2% 已经变成废墟，但是从你的观点上来看这真是再好不过了。现在应该回%employer%那去领取你的报酬了。 | 你给了%objective2%一个正确的一击，将它从不死者的魔爪中夺了回来，送回了生者的世界。而且，你发现青草与树木都开始恢复了生机，而且一股欢快的轻风也吹拂了过来。%employer%应该知道这些事情，这样子你就能拿到你的报酬了。 | %objective2%里的黑暗已经被摧毁了。好吧，除了那些被深埋在废墟之下的存在之外。还是有一点黑暗的，主要是因为没光，而不是有邪恶力量。不管怎么说，你应该去告诉%employer%你做的事情。 | 看上去%companyname%胜利地站在废墟之上时%objective2%已经好了很多了。照你来看，应该找个画家来给你的丰功伟业画张画像。%randombrother%用靴子碾碎亡灵头颅的时候看上去异常地帅气。但是，%employer%付钱的时候肯定看上去更帅。最好回去了。 | %objective2%已经被摧毁，恶灵也已经已退散。希望这次是彻彻底底的，但是还是有可能它已经去了其他防卫薄弱的地方。说道这个，你最好回%employer%去索要你的报酬。 | %objective2%已经被铲平，所有居住于此的恶灵也已退散。空气更轻盈干净了。%employer%看见你和你的汇报应该会很开心的。 |  %companyname%胜利了，%objective2%的邪恶力量已经被击败，或者有可能是被驱赶到了其他地方。你愤世嫉俗的一部分心理希望是后者，因为这样子其他什么地方的贵族应该会想要你去铲除它们，这样子你就又能赚一笔了。一个邪恶驱散的循环骗局在你脑内成型，%randombrother%过来问是不是要回%employer%那里去了。你点点头。一步步来…… |  %objective2%和它里面所有可怕，残忍的居民都已被摧毁。看见战场上满是亡灵的新鲜尸体到古代死者沾满灰尘的盔甲还真是奇怪。尸体比一个古董店里面的种类都要多。\n\n 等战团搜刮干净战利品之后，就应该去%employer%那拿报酬了。 |  死去的亡灵和古代人散落在战场沙灰姑娘。死掉的不死人，真是奇怪的说法，对于像你这样的一个猎魔人来说。但是它们被杀死这一点已经证明了怪物们是能被组织的。你让战团准备好回%employer%那去要报酬。 | %objective2%已经被摧毁，说明就算是复生的死者都不能逃脱%companyname%带到战场上来的毁灭风暴。邪恶已经被铲除，你感觉文明与自然又回到了这个地方。空气异常轻盈。头顶，鸟儿们在天空中鸣叫着。小家伙也是，不只是想要找吃的的秃鹫。\n\n 你告诉战团拿走他们想要的东西然后准备回%employer%那去。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{胜利！ |  该回%townname%去了。}",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Necromancers",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_76.png[/img]{你发现远处有一些死灵法师。毫无疑问，这些家伙就是邪恶的化身。你可不能放过他们！ |  %randombrother%满头大汗地来到你身旁。%SPEECH_ON%长官，我们远处发现了一些意图不轨的人。%SPEECH_OFF%你拿起望远镜朝地平线看去，发现有一群身着灰衣且散发着不祥之气的人在快速行走着，如同急于爬上土堆的蚂蚁一般。你拍了拍那位佣兵的肩膀。%SPEECH_ON%好眼力。现在，你去通知其他人，就说我们要去狩猎几个死灵法师。%SPEECH_OFF%  |  你拿起望远镜朝四周望去，结果惊讶地发现有几个朝远处跑去的人影，他们还时不时地回头看，就好像你在追逐他们一样。为了能看得更清楚，你拉长了望远镜。黑暗的衣服，苍白的脸庞，白色的胡须，外加有邪教刻印的匕首……他们是死灵法师！为了让这片土地免受邪恶的侵害，你必须消灭他们。 |  %randombrother%报告说有一群古怪的人正在逃离%companyname%。你耸了耸肩并告诉他，见到佣兵团就逃走是很正常的事情。他点了点头，然后补充道。%SPEECH_ON%确实是这样，不过那群人都披着黑斗篷，而且他们之中还有一个看起来像是死尸的东西在行走。%SPEECH_OFF%这说的不就是死灵法师吗？我们战团必须要赶在他们逃走前追上去！ |  在你查看地图的时候，%randombrother%前来汇报侦查结果。%SPEECH_ON%我们发现了一群死灵法师，长官。他们看起来年纪很大，佩戴者奇怪的武器，眼睛还会发光，另外还有一些尸体随行。%SPEECH_OFF%如果他们真的是死灵法师，那这片土地上许多的邪恶行径都与他们相关。我们必须尽快铲除他们。 |  死灵法师！他们举止鬼祟，还有死尸和其他一些‘盟友’通行。我们必须尽快消灭他们！ |  死灵法师！他们会施展黑暗的法术，这片土地上的许多邪恶勾当都与他们有关。我们必须尽快消灭他们！ |  %randombrother%将一个望远镜递给你。你接过后朝他所指的方向看去。出现在你眼前的景象证实了他的报告：有死灵法师在远处活动，他们正顺着附近的山谷朝远离%companyname%的方向逃去。你收起望远镜，并吩咐佣兵们做好准备。这些死灵法师必须尽快被歼灭！",
			Image = "",
			List = [],
			Options = [
				{
					Text = "追上他们！",
					function getResult()
					{
						local tile = this.Contract.m.Objective2.getTile();
						local banner = this.Contract.m.Objective2.getBanner();
						this.Contract.m.Objective2.die();
						this.Contract.m.Objective2 = null;
						local playerTile = this.World.State.getPlayer().getTile();
						local camp = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getNearestSettlement(playerTile);
						local party = this.World.FactionManager.getFaction(camp.getFaction()).spawnEntity(tile, "Necromancers", false, this.Const.World.Spawn.UndeadScourge, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						party.getSprite("banner").setBrush(banner);
						party.getSprite("body").setBrush("figure_necromancer_01");
						party.setSlowerAtNight(false);
						party.setUsingGlobalVision(false);
						party.setLooting(false);
						this.Const.World.Common.addTroop(party, {
							Type = this.Const.World.Spawn.Troops.Necromancer
						}, false);
						this.Const.World.Common.addTroop(party, {
							Type = this.Const.World.Spawn.Troops.Necromancer
						}, true);
						this.Contract.m.UnitsSpawned.push(party);
						this.Contract.m.Target = this.WeakTableRef(party);
						party.setAttackableByAI(true);
						party.setFootprintSizeOverride(0.75);
						local c = party.getController();
						c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
						local roam = this.new("scripts/ai/world/orders/roam_order");
						roam.setPivot(camp);
						roam.setMinRange(1);
						roam.setMaxRange(10);
						roam.setAllTerrainAvailable();
						roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
						roam.setTerrain(this.Const.World.TerrainType.Shore, false);
						roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
						c.addOrder(roam);
						this.Contract.getActiveState().start();
						this.World.Contracts.updateActiveContract();
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "NecromancersFail",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_36.png[/img]{死灵法师们已经消失得无影无踪。现在已经不可能再追上他们了，除非出现奇迹。 |  你没能追上那些死灵法师。他们到底去哪里了？你无从得知。不过可以肯定的是，他们正在为下一项邪恶计划做准备。 |  怎么可能？你居然让那些死灵法师溜走了？只要他们还在世上逍遥法外，邪恶就会随他们一起蔓延。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "可恶，可恶，可恶啊！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to destroy strongholds of the undead scourge");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "NecromancersAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_46.png[/img]{死灵法师们已经被消灭了。无论他们在进行着怎样的邪恶计划，现在都已经被刀剑所斩除了。这片土地再也不会受到他们的威胁了。 |  死灵法师们都死了，他们终于去和自己召唤出来的尸体们团聚了。 |  你低头看着一位倒在地上的死灵法师。在生前，他为了实现自己的目的，可以残忍地唤回亡者。即使是现在，他依然以一种诡异的方式咧着嘴，似乎想要吐出另一个邪恶魔法。所幸的是，那已经成为了过去。无论生前残忍与否，他现在只不过是一个普通的死人。 |  你低头看着一位死灵法师宛如食尸鬼般的憔悴面孔。%randombrother%走过来朝那具尸体脸上啐了一大口唾沫。%SPEECH_ON%我一点儿也不怕他们，反正他们所有人都会下地狱。%SPEECH_OFF%你点了点头。就在那团唾沫流过死灵法师的脸颊时，你看到尸体的眼睛泛了一下红光。这个情况，你得最好不要让那位佣兵知道。 |  死灵法师已死，但他们眼中闪烁的微光却花了很长时间才暗淡下来。%randombrother%依然沉浸在胜利的喜悦中。%SPEECH_ON%瞧瞧这些家伙。现在全死光光了吧。%SPEECH_OFF%他弯下腰，用手撑住膝盖，对着其中一句尸体的脸吼道。%SPEECH_ON%你的那些死尸朋友都去哪了？嗯？哦，对啊，你现在也是个死尸啦！真可惜！%SPEECH_OFF%你让那位佣兵冷静下来，以防这些能操纵死亡的暗黑法师们设下了其他陷阱。 |  邪恶之徒已被斩杀。那些死灵法师在死掉后与那些他们生前操控的死尸看起来没什么两样。 |  死灵法师们都被杀死了，他们再也无法危害这片土地了。毫无疑问，你为这个世界清除了一害。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "这下可以稍微安心一些了。",
					function getResult()
					{
						this.Flags.set("IsNecromancers", false);
						this.Flags.set("IsNecromancersSpawned", false);
						this.Flags.set("ObjectivesDestroyed", this.Flags.get("ObjectivesDestroyed") + 1);
						this.Contract.m.Target = null;

						if (this.Flags.get("ObjectivesDestroyed") == 2)
						{
							this.Contract.setState("Return");
						}
						else
						{
							this.Contract.getActiveState().start();
							this.World.Contracts.updateActiveContract();
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Bandits",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_07.png[/img]{在前往%objective%的途中，你遇上了一群强盗。他们一句话都没说便亮出了武器，%companyname%的佣兵们也毫不示弱地拔出了武器。你伸出手来，拦住了摩拳擦掌的佣兵们，对方的首领也做出了相同的举动。场面上的紧张局势似乎稍有缓和。对方首领说话了。%SPEECH_ON%是我们先来这里的，所以这战利品是属于我们的。如果你们想硬抢，那我们随时奉陪！%SPEECH_OFF%看来他们只是想洗劫这里。那样的话，他们免不了要去消灭很多亡灵，这也不失为一件好事。或许你们双方可以合作？无论你怎样抉择，都必须抓紧时间，因为这里有不死生物出没！ |  一群强盗准备对%objective%发动进攻！他们朝你们了亮出了武器，并威胁要与你们战斗。但经过你的一番周旋，你发现他们只是想要洗劫这个宝库。或许%companyname%可以与他们合作？亦或者，干脆把他们连同不死生物一起都杀了，然后将一切据为己有。 |  就在你接近%objective%时，你遇上了一群强盗。他们准备发动进攻，不过不是对%companyname%，而是对这个宝库。看来他们的目的是这里的财宝。如果你挡了他们的财路，他们肯定不会放过你。或许你可以与他们合作，不过那样一来你将无法得到任何战利品。亦或者，你们可以干脆将这里所有能动的东西都杀光，让荣耀和财富归入自己囊中。不管怎样，你都必须尽快决定，因为这里有不死生物出没！ |  有强盗！他们数量不少、装备精良，并且已经做好了战斗的准备。所幸的是，他们想要下手的目标是%objective%。或许%companyname%可以与他们合作，不过那样一来这些强盗肯定会以大量的战利品分成作为条件。除此之外，你也可以选择杀光这里所有敌人然后独占所有的战利品。不管怎样，你都必须尽快决定，因为这里有不死生物出没！ |  你们遇上了一群装备精良的人。在他们看到你们后，立刻拔出了武器。%randombrother%也亮出了武器，并威胁要杀死最先动手的那个人。虽然场面一度十分紧张，但你和对方首领还是通过交涉稳定了局势。强盗首领解释说，他们来这里的目的只是为了掠夺%objective%的财宝。你可以和这些劫掠者们合作。但如果你想独占战利品，那就必须将他们和亡灵们一起杀死。 |  %randombrother%走到附近的树丛旁，松开裤带正准备小解。突然，他猛地跳了回来，连裤子都来不及提就拔出了武器。这时，一群强盗从树丛中走出，手上拿着明晃晃的武器，嘴上还骂骂咧咧的。%companyname%的佣兵们也用相同的方式回应了他们。他们的首领走了出来，举起双手，想要和佣兵们的领队，也就是你，进行交涉。\n\n 在经过一番交谈后，你得知他们来这里的目的是为了洗劫%objective%的财宝。你可以和他们一起和这里的不死生物战斗。但如果你拒绝合作，他们会连你和那些不死生物一起杀，因为他们是绝不会与佣兵平分战利品的。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们的目的是相同的。让我们合作吧！",
					function getResult()
					{
						this.Flags.set("IsBanditsCoop", true);
						this.Contract.m.Current.getLoot().clear();
						this.Contract.m.Current.setDropLoot(false);
						this.Contract.getActiveState().onCombatWithPlayer(this.Contract.m.Current, false);
						return 0;
					}

				},
				{
					Text = "我们可不是来这里和你们共享战利品的。准备受死吧！",
					function getResult()
					{
						this.Flags.set("IsBandits3Way", true);
						this.Contract.getActiveState().onCombatWithPlayer(this.Contract.m.Current, false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BanditsAftermathCoop",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_07.png[/img]{这里的邪恶已被消灭。在和强盗们瓜分了战利品后，你准备带领部队前往%objective2%，当然，这一点你是不会向那些强盗透露的。 |  在干掉最后一个不死生物后，你感觉到这里的空气变得清澈起来。毫无疑问，这表明你们已经消灭了徘徊在此的所有邪恶之物。你与强盗们瓜分了战利品。他们表现得十分趾高气昂，嚷嚷着如果没有他们，你们根本不可能撑过这场战斗。你本想告诉他们有关%objective2%的事情，可出于对他们自傲态度的厌恶，你最后还是选择不再与他们合作。 |  这里的邪恶已被扫除。接下来，还有%objective2%在等着你们。\n\n 你与那些强盗们瓜分了战利品，他们对这个结果感到很高兴。虽然他们嘴上没说，不过所有人都明白，要不是你们出现在了这里，他们肯定会死在那些不死生物手中。 |  在这里的邪恶被彻底清除后，契约中剩下的只有%objective2%了。至于那些强盗，他们得到了之前说好的那些战利品。他们还问你接下来要去哪里，你则表示无可奉告。 |  在最后一个亡灵被消灭后，你感到这里的空气一下子清净了不少。%randombrother%擦了擦额头上的汗珠。%SPEECH_ON%这可能是最后一个了。接下来，我们是要去%objective2%，对不对？%SPEECH_OFF%这时你看到一位强盗往这边走来，便示意这位佣兵不要继续说下去了。最好不要让这些混蛋知道我们的下一个目标。他们除了会跟我们抢战利品，其他一点用处都派不上。 |  就在你们将最后一个亡灵消灭后，原来萦绕在此的邪恶气场一下子消失了，秩序与光明得以回归。解决完这里的状况后，该是前往%objective2%的时候了。\n\n 强盗的首领朝你走了过来。他的手上拿着一个卷轴，上面记录者这次的分成清单。%SPEECH_ON%这真是一次愉快的合作啊，佣兵。%SPEECH_OFF%你告诉他，要不是有你们出现在这里，他和他那些愚蠢的手下肯定会死在这里。他耸了耸肩。%SPEECH_ON%人有缺陷也是很正常的。那我们后会有期？%SPEECH_OFF%你选择无视他，并转身召集你的部下们。 |  在经历了一场苦战后，胜利终于将临。战场上四处都是亡灵和其他怪物留下的尸体残骸。依照事先的约定，那些与你合作的那些强盗们在场上搜刮着属于他们的战利品。虽然你希望%objective2%能比之前的战斗更好解决，但你也明白那只不过是你的奢望罢了。 |  根据双方之前的约定，强盗们在战场上搜刮着属于他们的那份战利品。你让%randombrother%悄悄将佣兵们集合起来，并准备向%objective2%进发。他问你为什么要悄悄行动。%SPEECH_ON%因为我们不想看到那些没用的混蛋再次出现在我们的下一场战斗中，拿走本属于我们的战利品%SPEECH_OFF%那位佣兵点了点头。%SPEECH_ON%嗯，我也是这样想的。%SPEECH_OFF%  |  你让佣兵们做好前往%objective2%的准备。\n\n 这时，强盗首领向你走来。%SPEECH_ON%和你们合作真是愉快。顺便问一句，你们接下来准备去哪里？要去接着寻宝吗？%SPEECH_OFF%你转身一把抓住那个男人的衣服。%SPEECH_ON%我想我们双方都明白，谁才是在之前的战斗中出力的人。现在，你可以带着你的战利品滚了。毕竟那是我们约定好的。如果你还敢跟着我们，我绝对会把你们的战利品统统熔掉，然后灌进你那天杀的脑袋里，明白吗？%SPEECH_OFF%他一边点头，一边缩了回去，似乎在害怕你现在就兑现刚刚的承诺。 |  在最后一个不死生物被消灭后，你在战场上环顾了一圈。这里的死尸身着不同的衣物和盔甲，因此它们应该来自不同的地方，甚至是不同的时代。那些身穿古代盔甲的不死生物在之前的战斗中也表现出了相当强的战斗力。\n\n %randombrother%来到你身边，向你报告说战团已经做好向%objective2%进发的准备。那位强盗首领打断了你们的对话。%SPEECH_ON%在你们出发之前，我们要先划分好战利品，对吧？%SPEECH_OFF%你点了点头。毕竟那是之前就约定好的。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "胜利！",
					function getResult()
					{
						this.Flags.set("IsBanditsCoop", false);

						if (this.Flags.get("ObjectivesDestroyed") == 2)
						{
							this.Contract.setState("Return");
						}
						else
						{
							this.Contract.getActiveState().start();
							this.World.Contracts.updateActiveContract();
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BanditsAftermath3Way",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{在战场上，你发现了那位强盗首领的尸体。他的脸上充满了悔恨。那些因自己的错误决定而送命的人，多半都会露出这种表情。啊，总之，真是遗憾。你将佣兵们纠集起来，朝%objective2%进发。 |  强盗首领阵亡了，他的尸体就横躺在战场上。他有一半的脸已经不见了。没过多久，就有人在一个亡灵的口中找到了他缺失的脸。真遗憾。总之，该出发去%objective2%了。 |  在处理完那些不死生物，以及那些自以为能对抗%companyname%的愚昧强盗后，战团的目标就只剩下%objective2%了。 |  强盗们做出了一个错误的决定，他们居然敢与不死生物和%companyname%同时开战。他们的下场，自然是全灭。战斗结束后，你命令手下搜刮场上的战利品并准备向%objective2%进发。 |  在干掉最后一个不死生物后，你感觉到这里的空气变得清澈起来。毫无疑问，这表明你们已经消灭了徘徊在此的所有邪恶之物。可惜的是，那些胆敢与你做对的强盗们已经享受不到这一刻了。好吧。现在该去解决契约中剩下的%objective2%了。 |  这里的邪恶已被扫除。那些愚蠢而可怜的强盗们也遭遇了同样的下场。接下来，还有%objective2%在等着你们。 |  在消灭了最后一个亡灵以及最后一名愚蠢的强盗后，你松了一口气。这不仅仅是因为那些做出错误决定的强盗都得到了应有的下场，更是因为你将这里的邪恶之物悉数清除了。该出发去%objective2%了。 |  在经历了一场苦战后，胜利终于将临。那些不死生物确实很顽强。那些强盗则因自己的愚蠢而送了命。虽然你希望%objective2%能像那些傻瓜强盗一样好对付，但那几乎是不可能的。 |  你在一个亡灵的身上找到了强盗首领的尸体。%randombrother%走过来大笑着说。%SPEECH_ON%看来这就是他们的命。%SPEECH_OFF%你也大笑起来，然后让那位佣兵通知其他人做好出发去%objective2%的准备。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "那是他们应得的下场。",
					function getResult()
					{
						this.Flags.set("IsBandits3Way", false);

						if (this.Flags.get("ObjectivesDestroyed") == 2)
						{
							this.Contract.setState("Return");
						}
						else
						{
							this.Contract.getActiveState().start();
							this.World.Contracts.updateActiveContract();
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer%带着欢呼的女仆们，手持酒杯，迎接你进了他的房间。他真是这死尸横行的世界上一道光鲜的风景线。这位喝的醉醺醺的贵族将%reward_completion%克朗交到你手中，随后他的守卫便护送他离去了。 |  你进入%employer%的房间，看到有一男一女站在桌边上。桌上有个一动不动且肤色惨白的孩子。孩子的母亲在默哀之中，她的脸上写满了悲伤。你打破了房间内的沉默，向那位贵族报告说你的任务已经完成。他点了点头。%SPEECH_ON%我已经知道了。当你们回来的时候，传言就已经散播开了。或许，这片土地能再次获得生机，但那些死去的人，已经回不来了。你的酬劳就在那边的角落里放着，佣兵。%SPEECH_OFF%你走了过去，拿走了%reward_completion%克朗的报酬。在你离开房间的时候，%employer%依然在安慰那个女人。 |  一名守卫将你带到%employer%之中一个藏身处，那是一个相对狭小的房间。那位贵族正在埋头读着一个卷轴，但他在看到你的时候，脸上充满了惊讶。%SPEECH_ON%佣兵！我等你很久了！快进来。%SPEECH_OFF%他将手稿放在一边，并从地上捡起一个小包。%SPEECH_ON%这是我们先前说好的%reward_completion%克朗的报酬。有传言说，邪恶已经从这片土地上离去。虽然我不是很相信，但你的胜利无疑在这场战争中为我们带来了转机。做得好，佣兵。%SPEECH_OFF%  |  %employer%招手让你进入他的房间，他的另一只手上则拿着一个装着克朗的钱袋。%SPEECH_ON%你不用向我汇报了，佣兵，我的探子已经把所有的情况都告诉我了。这是我们之前说好的报酬。%SPEECH_OFF%  |  %employer%热情地欢迎了你，不过墙角处站着的一个书记官却怒气冲冲地盯着你，就好像你是和他抢食的拾荒者一样。当你正准备汇报你所取得的成果时，那位贵族摆了摆手。%SPEECH_ON%噢，佣兵，这片土地上发生的事情，我了如指掌。这%reward_completion%克朗是你应得的报酬。%SPEECH_OFF%那位书记官突然打断了%employer%的话。%SPEECH_ON%确实，邪恶已经被消灭了，事态正在朝好的方向发展！不过现在，请你赶快离开吧，佣兵。我们还有一些重要的事情要谈。%SPEECH_OFF%唔，当然。你拿上你的报酬离开了。 |  你在马厩里找到了%employer%。那里已经空空如也，就连马童也不见了。在看到你到来之后，他迅速上前握了握你的手。%SPEECH_ON%见到你真是太好了，佣兵。我已经听闻了你取得成功的消息。你让这片土地摆脱了邪恶的枷锁，让万物获得了新生。至少，现在我们又有希望了。去找远处那个守卫吧，他会带你去金库领取%reward_completion%克朗的报酬。%SPEECH_OFF%  |  你在一座新坟旁找到了%employer%。旁边坐着几个教堂司事，他们在轮流饮用一个羊皮袋中的水。那位贵族耸了耸肩。%SPEECH_ON%愿逝者安息。佣兵啊，你不仅将邪恶之源摧毁了，甚至可能把这片土地上的一部分邪恶也驱散了。愿神明能保佑我们。你的报酬就在金库里放着。他会带你去领之前说好的%reward_completion%克朗的报酬。%SPEECH_OFF%  |  你看到%employer%正在和一位药师说话。那位治疗师有一个放着尖锐工具的推车，其中的一些工具被斜放在一个盛有红色液体的水盆里。你打量了一下那位贵族，发现他的手臂上有一个伤口刚刚被缝合。他向你招了招手。%SPEECH_ON%我在狩猎野猪时碰上了一些意外，佣兵。%SPEECH_OFF%治疗师在清理完伤口后，便起身离去了，临走前还告诫那位贵族在一周内不要剧烈活动。%SPEECH_ON%好，好，不过，我还有一些事情要处理。首先就是你的事情，佣兵。你的报酬就在那边的角落，%reward_completion%克朗，这是我们当初说好的。没人知道那些邪恶的不死生物是否真正离开了这片土地，但你已经完成了你该做的事情。%SPEECH_OFF%  |  在你走进房间的时候，%employer%正在和一个女人说话。那女人说了一句让你莫名其妙的话。%SPEECH_ON%我的孩子终于可以安眠于地下了！他再也不会回来了！我真是太高兴了！%SPEECH_OFF%那位贵族握住了她的手，朝你点了点头。%SPEECH_ON%多亏了你，这片土地上的邪恶终于得到驱散。这%reward_completion%克朗，是你应得的，佣兵！%SPEECH_OFF%  |  你看到%employer%正在和一只毛茸茸的小狗玩耍。它在光滑的地面上奔跑，追逐着一根木棍。那位贵族将木棍扔到你脚下，那只小狗一下子就冲到你的靴子旁边。%SPEECH_ON%那只狗平时连动都不敢动，而现在，它现在根本消停不下来。我猜，这多半和你处理掉了那些不死生物有关，佣兵。干得漂亮。按照我们事先约定的，你会得到%reward_completion%克朗的报酬，或者你也可以把这只小狗带走。%SPEECH_OFF%你说你想带走这只小狗。贵族吃惊地向后退了一步。%SPEECH_ON%不，你还是拿钱吧。这只狗我还想留着。%SPEECH_OFF%汪。 |  你走进%employer%的房间，发现这个男人正在朝窗外看。他的脸上洋溢着希望。%SPEECH_ON%生命。无所不在的生命。%SPEECH_OFF%他转过身来，手上拿着一个小袋子。他走了过来，把那袋子放在了你的手上。%SPEECH_ON%这里面有%reward_completion%克朗。在处理不死生物这件事上，你干的不错，佣兵。但愿你的成果能让我们最终战胜邪恶。%SPEECH_OFF%  |  %employer%拿着一大瓶酒来迎接你。酒里有一股金属味，不过你并没有做出任何抱怨。那位贵族欢快地在桌子旁走来走去。%SPEECH_ON%做得好，佣兵。要是没有你，真不知道这片土地会变成什么样子。我一直在向神祈祷，希望终有一日，我们能彻底驱散所有的邪恶！%SPEECH_OFF%  |  你在%employer%的房间外遇上了一个守卫。他朝你看了几眼，尤其是仔细看了看你肩上的%companyname%徽章。%SPEECH_ON%这是给你的，佣兵。%employer%现在很忙，但他要我代替他向你表示感谢。%SPEECH_OFF%你得到了%reward_completion%克朗作为报酬。 |  在通往%employer%房间的走廊上，你遇到了一位皮肤光滑且苍白的司库。他迅速将手中的一袋克朗交给了你。%SPEECH_ON%这是我们之前说好的报酬。我的主人目前正忙着和他的书记官商量如何处理那些可怕的不死生物。%SPEECH_OFF%  |  在你找到%employer%的时候，他正在刮胡子。他的面前有一位疲惫且眉头紧锁的女人在给他端着镜子。%SPEECH_ON%哦，佣兵。哎呦。啊。%SPEECH_OFF%他将剃刀丢进了水盆中，然后急匆匆地走向自己的书桌。%SPEECH_ON%我的探子已经向我报告了你的成果。不仅如此，所有人的状况似乎都有改善！孩子的脸上再次出现了笑容，阳关也变得更加灿烂，农作物也应该会茁壮成长！大家都很高兴！%SPEECH_OFF%那个女人询问道自己现在是否能把镜子放下。那位贵族打了一个响指。%SPEECH_ON%你别插嘴。这是给你的，佣兵。一共%reward_completion%克朗，如我们之前约定的那样。%SPEECH_OFF%  |  你并没有在%employer%自己的房间里找到他，相反，你在一间用残缺的蜡烛照明的房间里找到了他。在这个令人压抑的房间里，你看到了一个人被锁链吊起来的人。从他的表情上看，他已经里离上吊自杀不远了。那位贵族背着双手站在房间里，而另一个头戴黑色兜帽的人则在一个装满刀具的托盘上挑选着什么。你轻轻咳嗽了一下。%employer%转过身来。%SPEECH_ON%啊，是你啊，佣兵！我正等着你呢！来，这是我们当初说好的%reward_completion%克朗。但愿这次，那些不死生物能彻底消失。不管怎样，你为这个世界对抗邪恶的战役中做出了重要的贡献。%SPEECH_OFF%}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Destroyed strongholds of the undead scourge");
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
			"objective1",
			this.m.Flags.get("Objective1Name")
		]);
		_vars.push([
			"objective2",
			this.m.Flags.get("Objective2Name")
		]);
		local distToObj1 = this.m.Objective1 != null && !this.m.Objective1.isNull() && this.m.Objective1.isAlive() ? this.m.Objective1.getTile().getDistanceTo(this.World.State.getPlayer().getTile()) : 9999;
		local distToObj2 = this.m.Objective2 != null && !this.m.Objective2.isNull() && this.m.Objective2.isAlive() ? this.m.Objective2.getTile().getDistanceTo(this.World.State.getPlayer().getTile()) : 9999;

		if (distToObj1 < distToObj2)
		{
			_vars.push([
				"objective",
				this.m.Flags.get("Objective1Name")
			]);
		}
		else
		{
			_vars.push([
				"objective",
				this.m.Flags.get("Objective2Name")
			]);
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Objective1 != null && !this.m.Objective1.isNull() && this.m.Objective1.isAlive())
			{
				this.m.Objective1.getSprite("selection").Visible = false;
				this.m.Objective1.setOnCombatWithPlayerCallback(null);
			}

			if (this.m.Objective2 != null && !this.m.Objective2.isNull() && this.m.Objective2.isAlive())
			{
				this.m.Objective2.getSprite("selection").Visible = false;
				this.m.Objective2.setOnCombatWithPlayerCallback(null);
			}

			if (this.m.Target != null && !this.m.Target.isNull() && this.m.Target.isAlive())
			{
				this.m.Target.getSprite("selection").Visible = false;
				this.m.Target.setOnCombatWithPlayerCallback(null);
			}

			this.m.Current = null;
			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return false;
		}

		if (this.m.IsStarted)
		{
			if (this.m.Objective1 == null  ||  this.m.Objective1.isNull()  ||  !this.m.Objective1.isAlive())
			{
				return false;
			}

			if (this.m.Objective2 == null  ||  this.m.Objective2.isNull()  ||  !this.m.Objective2.isAlive())
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
		if (this.m.Objective1 != null && !this.m.Objective1.isNull())
		{
			_out.writeU32(this.m.Objective1.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		if (this.m.Objective2 != null && !this.m.Objective2.isNull())
		{
			_out.writeU32(this.m.Objective2.getID());
		}
		else
		{
			_out.writeU32(0);
		}

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
		local obj1 = _in.readU32();

		if (obj1 != 0)
		{
			this.m.Objective1 = this.WeakTableRef(this.World.getEntityByID(obj1));
		}

		local obj2 = _in.readU32();

		if (obj2 != 0)
		{
			this.m.Objective2 = this.WeakTableRef(this.World.getEntityByID(obj2));
		}

		local target = _in.readU32();

		if (target != 0)
		{
			this.m.Target = this.WeakTableRef(this.World.getEntityByID(target));
		}

		this.contract.onDeserialize(_in);
	}

});

