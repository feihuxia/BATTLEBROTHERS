this.big_game_hunt_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Size = 0,
		Dude = null
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.big_game_hunt";
		this.m.Name = "猎杀大赛";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 5.0;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
		this.m.MakeAllSpawnsResetOrdersOnceDiscovered = true;
		this.m.DifficultyMult = 1.0;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function setup()
	{
		local r = this.Math.rand(1, 100);

		if (r <= 40)
		{
			this.m.Size = 0;
			this.m.DifficultyMult = 0.75;
		}
		else if (r <= 75 || this.World.getTime().Days <= 30)
		{
			this.m.Size = 1;
			this.m.DifficultyMult = 1.0;
		}
		else
		{
			this.m.Size = 2;
			this.m.DifficultyMult = 1.2;
		}
	}

	function start()
	{
		if (this.m.Home == null)
		{
			this.setHome(this.World.State.getCurrentTown());
		}

		local maximumHeads;
		local priceMult = 1.0;

		if (this.m.Size == 0)
		{
			local priceMult = 1.0;
			maximumHeads = [
				15,
				20,
				25,
				30
			];
		}
		else if (this.m.Size == 1)
		{
			local priceMult = 4.0;
			maximumHeads = [
				10,
				12,
				15,
				18,
				20
			];
		}
		else
		{
			local priceMult = 8.0;
			maximumHeads = [
				8,
				10,
				12,
				15
			];
		}

		this.m.Payment.Pool = 1250 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult() * priceMult;
		this.m.Payment.Count = 1.0;
		this.m.Payment.MaxCount = maximumHeads[this.Math.rand(0, maximumHeads.len() - 1)];
		local settlements = this.World.FactionManager.getFaction(this.m.Faction).getSettlements();
		local other_settlements = this.World.EntityManager.getSettlements();
		local regions = this.World.State.getRegions();
		local candidates_first = [];
		local candidates_second = [];

		foreach( i, r in regions )
		{
			local inSettlements = 0;
			local nearSettlements = 0;

			if (r.Type == this.Const.World.TerrainType.Snow || r.Type == this.Const.World.TerrainType.Mountains)
			{
				continue;
			}

			foreach( s in settlements )
			{
				local t = s.getTile();

				if (t.Region == i + 1)
				{
					inSettlements = ++inSettlements;
					inSettlements = inSettlements;
				}
				else if (t.getDistanceTo(r.Center) <= 20)
				{
					local skip = false;

					foreach( o in other_settlements )
					{
						if (o.getFaction() == this.getFaction())
						{
							continue;
						}

						local ot = o.getTile();

						if (ot.Region == i + 1 || ot.getDistanceTo(r.Center) <= 10)
						{
							skip = true;
							break;
						}
					}

					if (!skip)
					{
						nearSettlements = ++nearSettlements;
						nearSettlements = nearSettlements;
					}
				}
			}

			if (nearSettlements > 0 && inSettlements == 0)
			{
				candidates_first.push(i + 1);
			}
			else if (inSettlements > 0 && inSettlements <= 1)
			{
				candidates_second.push(i + 1);
			}
		}

		local region;

		if (candidates_first.len() != 0)
		{
			region = candidates_first[this.Math.rand(0, candidates_first.len() - 1)];
		}
		else if (candidates_second.len() != 0)
		{
			region = candidates_second[this.Math.rand(0, candidates_second.len() - 1)];
		}
		else
		{
			region = settlements[this.Math.rand(0, settlements.len() - 1)].getTile().Region;
		}

		this.m.Flags.set("Region", region);
		this.m.Flags.set("HeadsCollected", 0);
		this.m.Flags.set("StartDay", 0);
		this.m.Flags.set("LastUpdateDay", 0);
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Flags.set("StartDay", this.World.getTime().Days);
				this.Contract.m.BulletpointsObjectives.clear();

				if (this.Contract.m.Size == 0)
				{
					this.Contract.m.BulletpointsObjectives.push("猎杀冰原野狼、蜘蛛和食尸鬼");
				}
				else if (this.Contract.m.Size == 1)
				{
					this.Contract.m.BulletpointsObjectives.push("猎杀梦魇、巨魔和女巫");
				}
				else
				{
					this.Contract.m.BulletpointsObjectives.push("猎杀巨蛇和树人");
				}

				this.Contract.m.BulletpointsObjectives.push("在 %worldmapregion% 的%regiontype% 区域和周围搜索");
				this.Contract.m.BulletpointsObjectives.push("在任意时间内返回 %townname% 获取报酬");

				if (this.Contract.m.Size == 0)
				{
					this.Contract.setScreen("TaskSmall");
				}
				else if (this.Contract.m.Size == 1)
				{
					this.Contract.setScreen("TaskMedium");
				}
				else
				{
					this.Contract.setScreen("TaskLarge");
				}
			}

			function end()
			{
				this.World.Assets.addMoney(this.Contract.m.Payment.getInAdvance());
				this.Flags.set("StartDay", this.World.getTime().Days);
				local action = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getAction("send_beast_roamers_action");
				local options;

				if (this.Contract.m.Size == 0)
				{
					options = action.m.BeastsLow;
				}
				else if (this.Contract.m.Size == 1)
				{
					options = action.m.BeastsMedium;
				}
				else
				{
					options = action.m.BeastsHigh;
				}

				local nearTile = this.World.State.getRegion(this.Flags.get("Region")).Center;

				for( local i = 0; i < 3; i = i )
				{
					for( local tries = 0; tries++ < 1000;  )
					{
						if (options[this.Math.rand(0, options.len() - 1)](action, nearTile))
						{
							local party = action.getFaction().getUnits()[action.getFaction().getUnits().len() - 1];
							party.setAttackableByAI(false);
							this.Contract.m.UnitsSpawned.push(party.getID());
							local footPrintsOrigin = this.Contract.getTileToSpawnLocation(nearTile, 4, 8);
							this.Contract.addFootPrintsFromTo(footPrintsOrigin, party.getTile(), this.Const.BeastFootprints, party.getFootprintsSize());
							break;
						}
					}

					i = ++i;
				}

				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives.clear();

				if (this.Contract.m.Size == 0)
				{
					this.Contract.m.BulletpointsObjectives.push("猎杀 %worldmapregion% 的 %regiontype% 及周围的恐狼、巨蛛、吸血鬼  (%killcount%/%maxcount%)");
				}
				else if (this.Contract.m.Size == 1)
				{
					this.Contract.m.BulletpointsObjectives.push("猎杀 %worldmapregion% 的 %regiontype% 及周围的梦魇、巨魔和女巫 (%killcount%/%maxcount%)");
				}
				else
				{
					this.Contract.m.BulletpointsObjectives.push("猎杀 %worldmapregion% 的 %regiontype% 及周围的巨蛇和树人 (%killcount%/%maxcount%)");
				}

				this.Contract.m.BulletpointsObjectives.push("在任意时间内返回 %townname% 获取报酬");
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home) && this.Flags.get("HeadsCollected") != 0)
				{
					if (this.Contract.m.Size == 0)
					{
						this.Contract.setScreen("SuccessSmall");
					}
					else if (this.Contract.m.Size == 1)
					{
						this.Contract.setScreen("SuccessMedium");
					}
					else
					{
						this.Contract.setScreen("SuccessLarge");
					}

					this.World.Contracts.showActiveContract();
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_killer != null && _killer.getFaction() != this.Const.Faction.Player && _killer.getFaction() != this.Const.Faction.PlayerAnimals)
				{
					return;
				}

				if (this.Flags.get("HeadsCollected") >= this.Contract.m.Payment.MaxCount)
				{
					return;
				}

				if (this.Contract.m.Size == 0)
				{
					if (_actor.getType() == this.Const.EntityType.Ghoul || _actor.getType() == this.Const.EntityType.Direwolf || _actor.getType() == this.Const.EntityType.Spider)
					{
						this.Flags.set("HeadsCollected", this.Flags.get("HeadsCollected") + 1);
					}
				}
				else if (this.Contract.m.Size == 1)
				{
					if (_actor.getType() == this.Const.EntityType.Alp || _actor.getType() == this.Const.EntityType.Unhold || _actor.getType() == this.Const.EntityType.UnholdFrost || _actor.getType() == this.Const.EntityType.UnholdBog || _actor.getType() == this.Const.EntityType.Hexe)
					{
						this.Flags.set("HeadsCollected", this.Flags.get("HeadsCollected") + 1);
					}
				}
				else if (_actor.getType() == this.Const.EntityType.Lindwurm && !this.isKindOf(_actor, "lindwurm_tail") || _actor.getType() == this.Const.EntityType.Schrat)
				{
					this.Flags.set("HeadsCollected", this.Flags.get("HeadsCollected") + 1);
				}
			}

			function onCombatVictory( _combatID )
			{
				this.start();
				this.World.State.getWorldScreen().updateContract(this.Contract);
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.start();
				this.World.State.getWorldScreen().updateContract(this.Contract);
			}

		});
	}

	function createScreens()
	{
		this.importScreens(this.Const.Contracts.NegotiationPerHead);
		this.importScreens(this.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "TaskSmall",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_63.png[/img]{你进入 %employer% 的房间. 那人用孔雀羽毛剔着手指。他对你的出现表现的很轻蔑.%SPEECH_ON%我的警卫已经通知我说你对猎兽感兴趣，我很高兴你这么做。工资将按人头计算。野兽，蜘蛛，吃尸体的东西，这类我确信对你来说没有问题，但是当地人害怕面对这些。如果你像人们所说的那样擅长工作，那么你就不应该敷衍地接受这份工作。首先它们出现在离这儿 %worldmapregion% %distance% %direction% .%SPEECH_OFF% | %employer% 欢迎你进入他的房间。他拿了一份文件给你.%SPEECH_ON%啊，那你是来狩猎野兽的。我以为你是个…%SPEECH_OFF%他捏了捏你衬衫的一边，笑了.%SPEECH_ON%好吧，尽管如此，野兽正在破坏乡村，我很乐意付给你一笔可观的钱来狩猎它们。当然，工资是按人头付的，如果你的那把刀刃锋利，你就可以赚很多钱. 它们出现在离这儿 %worldmapregion% %distance% %direction% . 在那里你会发现各种各样的八条腿的怪物和毛茸茸的怪物。无论是什么都会吓到一个普通农民，但对你来说没什么可怕的，你这个大块头.%SPEECH_OFF% | 你会发现 %employer% 赤脚站在桌子上，一群女人在修剪。他们用拇指从他的脚趾间塞进厚厚的泥土，就像是某个异像怪兽的诞生仪式。你清了清喉咙。那人惊异地清了清喉咙.%SPEECH_ON%啊，是的，剑士。在这里，如果你感兴趣的话，我有一个任务给你.%SPEECH_OFF%他轻蔑地把一份文件扔到你脚边，上面写着杀野兽的必要性。蜘蛛、恐狼。没什么可怕的. 它们出现在离这儿 %worldmapregion% %distance% %direction% . %SPEECH_ON%工资将按人头计算，希望这很适合你.%SPEECH_OFF% | %employer% 在与一群农民会面. 他说，怪物正在把内陆腹地撕成碎片。一个农夫插嘴.%SPEECH_ON%野兽，许多的野兽：用后腿走路的狼，蜘蛛，巨大的，吃尸体的东西，臭气熏天.%SPEECH_OFF%贵族挥手.%SPEECH_ON%是的，是的，够了。剑士，我需要你出去追捕这些生物. 它们出现在离这儿 %worldmapregion% %distance% %direction% . 带它们的头来, 我将会为每个头买单.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{它们值多少克朗? | 我可以被说服以合适的价格. | 继续. | 安全对你来说值多少钱?}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{路太远了，不适合我的口味. | 我们不打算到%worldmapregion%处追捕. | 那不是我们要找的那种工作.}",
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
			ID = "TaskMedium",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_63.png[/img]{当你进去时 %employer% 正在看书。他抬头向你挥手.%SPEECH_ON%把蜡烛拿来.%SPEECH_OFF%你从墙上取下火炬，扔向贵族.%SPEECH_ON%我说的是蜡烛，不是火炬！你的目的是什么，烧掉所有我的书？就呆在原地。看，这些地方的人都在谈论我多年没听说过的邪恶。那些以你的灵魂为食的生物，大到一个男人都能藏在胡须里的巨人，当然，最糟糕的是那些只知道自己漂亮的漂亮女人.%SPEECH_OFF%你对最后一个不太确定，但别跟她们说话。贵族继续解释说，你要杀死你在他的王国里找到的所有这些笨蛋. 他们现在位于 %worldmapregion% 的 %direction%, 但是你可以在它们可能藏匿的地方任意猎杀它们. | 你发现 %employer% 的办公室里有很多穿黑斗篷的人. 他们叫你过来，你很不情愿。贵族问你是否知道像僵尸这样的怪物，或是以灵魂为食的生物。在你回答之前，他挥手.%SPEECH_ON%没关系. 我需要一些武装人员去 %worldmapregion% 的 %direction% 看看有没有什么奇怪的事情发生. 如果它不是有心跳的人，杀了它。带头回来。回到我身边。我会为每一个头颅付给你丰厚的报酬。如果它们存在.%SPEECH_OFF% | %employer% 两只手都在掂量文件的轻重，他盯着桌子上的第三个卷轴看也不看。最后，他甩了两个，把最后一个拆开。他看着你.%SPEECH_ON%有消息说有怪兽出没。是吃牛和孩子的巨人。在这些地方有很多关于一个漂亮女人的说法. 我不知道她是不是一个邪恶的生物，但这美丽的女人居住 %worldmapregion% 的 %direction% 对我来说很麻烦.%SPEECH_OFF%你点头. %SPEECH_ON%你能带你的人到这片土地上，找出真相和虚构之间的界线吗？如果你发现有什么东西，发出嘶嘶声，或是其他非人生物的话，杀了那该死的东西，把它的头拿给我.%SPEECH_OFF% | %SPEECH_ON% 我听人说在 %worldmapregion% 的 %direction% 有谋杀案发生。 然后那些人就完全消失了。这不是好兆头。我不知道这是不是邪教或怪物的责任，但我需要一些武装人员去这片土地，驱除他们。如果你杀死他们，那就把它的头带给我，我将为此付出丰厚的代价.%SPEECH_OFF% | %employer% 站在梯子顶上，在他所拥有的最高的架子上翻来翻去。他摇摇头，招手让你进来.%SPEECH_ON%我根本不知道我在找什么.%SPEECH_OFF%你点头。那人爬了下来.%SPEECH_ON%很有趣，雇佣兵。你看，我听到了混乱的消息在 %worldmapregion% %distance% %direction%  绝对恐怖的怪物出现了. 巨人，幽灵等等。我需要你带上你的人去平息那些事情。把你发现的任何非人的怪物的头带给我。我会给你很好的报酬的.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{它们值多少克朗? | 我可以被说服以合适的价格. | 继续. | 安全对你来说值多少钱?}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{路太远了，不适合我的口味. | 我们不打算到%worldmapregion%处追捕. | 那不是我们要找的那种工作.}",
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
			ID = "TaskLarge",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_63.png[/img]{%employer%坐在办公桌旁。房间里没有人。有一个座位供你坐。他俯身向前，%SPEECH_ON%我的家乡有着某种传说。我父亲遇到了这个传说，还有我父亲的父亲。我们不知道传说是从哪里传来的。我希望在自己的有生之年看到这个传奇，现在我觉得我已经看到了。在梦中，就在昨晚. %SPEECH_OFF% 听到这个，你坐在座位的边缘，因为中间有一个洞。你点了点头，他继续说。%SPEECH_ON%前往%worldPretion% %direction%。我相信传说是真的，一只巨大的野兽在这些土地上游荡。也许不止一个！不管有多少，我需要最有经验的剑士来寻找它。带上他的头，你会得到丰厚的回报。你愿意吗？%SPEECH_OFF% | 您进入了%employer%的房间。他给你一个文件，上面有一个你看不懂的符号。贵族说这是一段传奇。他双臂张开。%SPEECH_ON%树那么大的野兽在这片土地上游荡，我相信是真的。 它在 %direction%  %worldmapregion%. 那里的农民不相信有大怪物。但我想相信. 我想近距离看一次，这就是我为什么把你召集到这里来的原因。到那可怕的地方去，看看有没有人被杀，把它的头放在我脚前.%SPEECH_OFF% | %employer% 欢迎你到他的房间做生意.%SPEECH_ON%我听到一些消息关于 %direction%  %worldmapregion%. 我记录了无数关于巨兽在那片土地上漫游的传言，我相信他们的每一句话。蛇和树一样大！不管他们是谁，我要你杀了他们，把他们的头给我。或者鳞片，树枝，不管什么。我会为你带来的每一件东西付钱。你对此感兴趣吗？%SPEECH_OFF% }",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{它们值多少克朗? | 我可以被说服以合适的价格. | 继续. | 安全对你来说值多少钱?}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{路太远了，不适合我的口味. | 我们不打算到%worldmapregion%处追捕. | 那不是我们要找的那种工作.}",
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
			ID = "SuccessSmall",
			Title = "当你返回...",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你回来后把这些凶残的家伙扔到%employer%的地板上. 他抬起头来.%SPEECH_ON%这不够。把钱拿给这人，找个仆人来收拾这烂摊子.%SPEECH_OFF% | %employer% 欢迎你回来，尽管他保持距离。他盯着你的货物.%SPEECH_ON%一次合适的回程，剑士。我会让我的手下数数人头，按照我们的协议付给你钱.%SPEECH_OFF% | 这是为 %employer% 而杀的 . 他点头，挥手示意你把它们带走.%SPEECH_ON%很感激，但我不需要再看那些可怕的东西了. %randomname%,到这儿来，把钱拿走.%SPEECH_OFF% }",
//| %employer% welcomes you back and looks over your wares.%SPEECH_ON%Absolutely disgusting. Splendid! Here is your pay, as agreed upon.%SPEECH_OFF% | You show the heads to %employer% who counts them with a wiggling finger and his lips whispering numbers. Finally, he straightens up.%SPEECH_ON%I don\'t have time for this shite. %randomname%, yes you servant, get over here and count these heads and pay the sellsword the agreed amount for each.%SPEECH_OFF% | %employer% is eating an apple as he walks over to see what you\'ve returned with. He stares into the satchel of ghastly beast heads. He takes a huge bite of the apple.%SPEECH_ON%Ehpressive rehsalts, sehswahrd.%SPEECH_OFF%He quickly chews and swallows in a big gulp.%SPEECH_ON%See my servant standing idly yonder with the purse. He\'ll pay out what you are owed.%SPEECH_OFF%The nobleman tosses the half-eaten apple and fetches himself another. | %employer% has a child with him when you enter his room. The kiddo rushes to see what you\'ve brought, then retreats in a screaming fit. The nobleman nods.%SPEECH_ON%Suppose that means you got what I paid you for. My servant %randomname% will count the heads and pay what you are owed.%SPEECH_OFF% | You lug the heads into %employer%\'s room. He raises an eyebrow.%SPEECH_ON%Did you have to drag those all the way in here? Look, you\'ve left a stain! Why didn\'t you just fetch a servant, that\'s what they\'re there for. By the old gods the smell is worse than the stains!%SPEECH_OFF%The nobleman snaps his fingers at a man standing with a purse.%SPEECH_ON%%randomname%, count the heads and see to it that the sellsword gets his pay.%SPEECH_OFF% | You unfurl the sack of heads and let them pile onto %employer%\'s floor. He stands up.%SPEECH_ON%That\'s not on the rug, is it?%SPEECH_OFF%A servant runs over and kicks the heads apart. He quickly shakes his head no. The nobleman nods and slowly sits down.%SPEECH_ON%Good. You there, %randomname%, get to counting and then pay this mess making sellsword his dues. And by the way, mercenary, take it easy on the presentation next time, alright?%SPEECH_OFF% | You lug a satchel of beast scalps and heads into %employer%\'s room. Popping the lid, you start to tip it forward. A servant\'s eyes go wide and he rushes forward, slamming into the satchel and tilting it back over. The lid clatters closed over his fingers and he chokes down a yelp.%SPEECH_ON%Thank you, mercenary, but the noble sir would prefer we count these without spilling them all over the floor. I will add up the totals and pay you once I am finished.%SPEECH_OFF% | %employer% reviews your handiwork.%SPEECH_ON%Impressive. Disgusting. Not you, the beasts. I mean you\'re a filthy sort, sellsword, but these foul beasts are the antithesis of hygiene.%SPEECH_OFF%You don\'t know what that word means, or the other one for that matter. You simply ask that he count the heads and give you what you\'re owed. | %employer% counts the heads and then leans backs. He shrugs.%SPEECH_ON%I thought they\'d be scarier.%SPEECH_OFF%You mention that they\'ve but a slightly different affect on one\'s courage when still attached to the beastly torsos. The nobleman shrugs again.%SPEECH_ON%I suppose so, but my mother lost her head to an executioner\'s blade and she looked all the scarier settin\' in that basket staring up at the world.%SPEECH_OFF%You don\'t know what to say to that. You ask the man to pay you what you\'re owed. | %employer% eyes the beastly heads you\'ve deposited upon his floor. A servant with a broom counts them one by one, subtracting from one pile to add to another. When he\'s finished the accounting he reports his numbers and the nobleman nods.%SPEECH_ON%Good work, sellsword. The servant will fetch your pay.%SPEECH_OFF%The lowborn sighs and puts the broom away. | %employer% opens the satchel of beastly scalps and skulls. He purses his lips, sniffs, and claps it back closed. The nobleman instructs one of his servants to count out the remains and pay you according to the agreement.%SPEECH_ON%A good job, sellsword. The townsfolk are grateful that I paid you to take care of this.%SPEECH_OFF% | %employer% whistles as he stares at your collection of skulls and scalps.%SPEECH_ON%That\'s a hell of a sigh if there ever was one. For work of this nasty nature I should consider paying you extra, which I won\'t, but the thought crossed my mind and that\'s what really counts.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一次成功的狩猎.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.Assets.addMoney(this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected"));
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Hunted beasts around " + this.World.State.getRegion(this.Flags.get("Region")).Name);
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				local money = this.Contract.m.Payment.getOnCompletion() + this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected");
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "SuccessMedium",
			Title = "当你返回...",
			//Text = "[img]gfx/ui/events/event_04.png[/img]{You come back and dump the beastly heads onto %employer%\'s floor. He looks up from his desk.%SPEECH_ON%Well that was unwarranted. Fetch the man his money, and fetch a servant to clean this mess.%SPEECH_OFF% | %employer% welcomes your return, though he keeps his distance. He\'s staring at your cargo.%SPEECH_ON%A fitting return, sellsword. I\'ll have one of my men count the heads and pay you according to our agreement.%SPEECH_OFF% | The slayings are produced for %employer%\'s approval. He nods and waves you away.%SPEECH_ON%Appreciated, but I need not look at those ghastly things a moment longer. %randomname%, come hither and pay this sellsword his money.%SPEECH_OFF% | %employer% welcomes you back and looks over your wares.%SPEECH_ON%Absolutely disgusting. Splendid! Here is your pay, as agreed upon.%SPEECH_OFF% | You show the heads to %employer% who counts them with a wiggling finger and his lips whispering numbers. Finally, he straightens up.%SPEECH_ON%I don\'t have time for this shite. %randomname%, yes you servant, get over here and count these heads and pay the sellsword the agreed amount for each.%SPEECH_OFF% | %employer% is eating an apple as he walks over to see what you\'ve returned with. He stares into the satchel of ghastly beast heads. He takes a huge bite of the apple.%SPEECH_ON%Ehpressive rehsalts, sehswahrd.%SPEECH_OFF%He quickly chews and swallows in a big gulp.%SPEECH_ON%See my servant standing idly yonder with the purse. He\'ll pay out what you are owed.%SPEECH_OFF%The nobleman tosses the half-eaten apple and fetches himself another. | %employer% has a child with him when you enter his room. The kiddo rushes to see what you\'ve brought, then retreats in a screaming fit. The nobleman nods.%SPEECH_ON%Suppose that means you got what I paid you for. My servant %radomname% will count the heads and pay what you are owed.%SPEECH_OFF% | You lug the heads into %employer%\'s room. He raises an eyebrow.%SPEECH_ON%Did you have to drag those all the way in here? Look, you\'ve left a stain! Why didn\'t you just fetch a servant, that\'s what they\'re there for. By the old gods the smell is worse than the stains!%SPEECH_OFF%The nobleman snaps his fingers at a man standing with a purse.%SPEECH_ON%%randomname%, count the heads and see to it that the sellsword gets his pay.%SPEECH_OFF% | You unfurl the sack of heads and let them pile onto %employer%\'s floor. He stands up.%SPEECH_ON%That\'s not on the rug, is it?%SPEECH_OFF%A servant runs over and kicks the heads apart. He quickly shakes his head no. The nobleman nods and slowly sits down.%SPEECH_ON%Good. You there, %randomname%, get to counting and then pay this mess making sellsword his dues. And by the way, mercenary, take it easy on the presentation next time, alright?%SPEECH_OFF% | You lug a satchel of beast scalps and heads into %employer%\'s room. Popping the lid, you start to tip it forward. A servant\'s eyes go wide and he rushes forward, slamming into the satchel and tilting it back over. The lid clatters closed over his fingers and he chokes down a yelp.%SPEECH_ON%Thank you, mercenary, but the noble sir would prefer we count these without spilling them all over the floor. I will add up the totals and pay you once I am finished.%SPEECH_OFF% | %employer% reviews your handiwork.%SPEECH_ON%Impressive. Disgusting. Not you, the beasts. I mean you\'re a filthy sort, sellsword, but these foul beasts are the antithesis of hygiene.%SPEECH_OFF%You don\'t know what that word means, or the other one for that matter. You simply ask that he count the heads and give you what you\'re owed. | %employer% counts the heads and then leans backs. He shrugs.%SPEECH_ON%I thought they\'d be scarier.%SPEECH_OFF%You mention that they\'ve but a slightly different affect on one\'s courage when still attached to the beastly torsos. The nobleman shrugs again.%SPEECH_ON%I suppose so, but my mother lost her head to an executioner\'s blade and she looked all the scarier settin\' in that basket staring up at the world.%SPEECH_OFF%You don\'t know what to say to that. You ask the man to pay you what you\'re owed. | %employer% eyes the beastly heads you\'ve deposited upon his floor. A servant with a broom counts them one by one, subtracting from one pile to add to another. When he\'s finished the accounting he reports his numbers and the nobleman nods.%SPEECH_ON%Good work, sellsword. The servant will fetch your pay.%SPEECH_OFF%The lowborn sighs and puts the broom away. | %employer% opens the satchel of beastly scalps and skulls. He purses his lips, sniffs, and claps it back closed. The nobleman instructs one of his servants to count out the remains and pay you according to the agreement.%SPEECH_ON%A good job, sellsword. The townsfolk are grateful that I paid you to take care of this.%SPEECH_OFF% | %employer% whistles as he stares at your collection of skulls and scalps.%SPEECH_ON%That\'s a hell of a sigh if there ever was one. For work of this nasty nature I should consider paying you extra, which I won\'t, but the thought crossed my mind and that\'s what really counts.%SPEECH_OFF%}",
Text = "[img]gfx/ui/events/event_04.png[/img]{你回来后把这些凶残的家伙扔到%employer%的地板上. 他抬起头来.%SPEECH_ON%这不够。把钱拿给这人，找个仆人来收拾这烂摊子.%SPEECH_OFF% | %employer% 欢迎你回来，尽管他保持距离。他盯着你的货物.%SPEECH_ON%一次合适的回程，剑士。我会让我的手下数数人头，按照我们的协议付给你钱.%SPEECH_OFF% | 这是为 %employer% 而杀的 . 他点头，挥手示意你把它们带走.%SPEECH_ON%很感激，但我不需要再看那些可怕的东西了. %randomname%,到这儿来，把钱拿走.%SPEECH_OFF% }",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一次成功的狩猎.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.Assets.addMoney(this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected"));
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Hunted beasts around " + this.World.State.getRegion(this.Flags.get("Region")).Name);
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				local money = this.Contract.m.Payment.getOnCompletion() + this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected");
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "SuccessLarge",
			Title = "当你返回...",
			//Text = "[img]gfx/ui/events/event_04.png[/img]{You lug the remains of your hunt into %employer%\'s room. He jumps back as though you\'d mastered the beast itself and ridden it to conquer. Clutching his chest, the nobleman sets back down.%SPEECH_ON%By the old gods, sellsword, if you weren\'t such a fool you would have left that in the yard and fetched me to walk on down.%SPEECH_OFF%Shrugging, you ask about your pay. He asks how you killed it. You return to the issue of pay. The nobleman purses his lips.%SPEECH_ON%Alright. Servant! Get this obstinate beastslayer his coin.%SPEECH_OFF% | You drag the beastly remains into the yard and call up to %employer%. He comes to the window and looks down for a long time.%SPEECH_ON%Real or are you having a joke?%SPEECH_OFF%Sighing, you unsheathe your sword and plunge it into a large eyeball. With a pop it deflates and spews a yellow film all over the dirt. The nobleman whistles and clucks his tongue.%SPEECH_ON%By the old gods if you haven\'t done it! I will have a servant fetch your pay right this moment!%SPEECH_OFF% | You draft a donkey into service and have it help pull the slain abhorrence into town. It regards its crooked and unworldly luggage with a flick of an ear and a mute stare. %employer% meets you outside his domain. He stands aside the monstrous remains with his chin in the nook of a finger and thumb.%SPEECH_ON%Incredible. I can\'t imagine what it looked alive and fighting.%SPEECH_OFF%Nodding, you let the man know that there are no doubt more like it out there and he should come along the next time you take up a hunt. He shakes his head.%SPEECH_ON%I shall pass on that offer, sellsword. Here is your pay, and I order you to give that donkey back to its owner.%SPEECH_OFF%A farmer strides up wiping his forehead with a cloth.%SPEECH_ON%It\'s called a hinny and if you wanted to borrow the damned thing you could have just asked!%SPEECH_OFF% | You chop up the beastly remains and drag them piecemeal into %employer%\'s room. He puts a cloth to his nose as the cadaver piles up.%SPEECH_ON%So the myths are true. The beasts are real.%SPEECH_OFF%A few servants put the chunks back together, giving a misshapen image of the monstrosity which slides apart every time they let their hands go of the flesh. The nobleman nods and snaps his fingers.%SPEECH_ON%Get the mercenary his pay and fetch my advisers.%SPEECH_OFF% | One of %employer%\'s stands aside with a burin, ready to chisel away into the beastly remains. He grins widely and wildly.%SPEECH_ON%The family name can be down the bone, and used as a helve for an axe of sword.%SPEECH_OFF%You tell both the men they aren\'t touching a damned thing lest they pay you. The nobleman grins.%SPEECH_ON%No need to be testy, mercenary. I have a servant fetching your pay this moment. And if you dare raise a word in that tone again I\'ll have your tongue, slayer of monsters or no.%SPEECH_OFF%You demonstrate patience with your hand to your pommel and a countdown in your head. Thankfully for everyone involved, the servant arrives before it hits zero. | %employer% claps like a child at the demonstration of the beastly remains.%SPEECH_ON%The stories told of my doings will be great. I shall make helves and handles out of these bones, and tell stories of how I claimed the monstrous heads.%SPEECH_OFF%You nod. Sounds great. Not like the history books were going to record your name anyway. You ask for your pay. Nodding and not taking his eyes off the creature, %employer% snaps his fingers.%SPEECH_ON%Servants! Get the man his coin!%SPEECH_OFF%}",
Text = "[img]gfx/ui/events/event_04.png[/img]{你把剩下的猎杀物拖进了%employer%的房间。他立马后跳，好像你已经掌控野兽，并骑着它去威胁自己。贵族紧紧抓住胸口，退后了。%SPEECH_ON%上帝呀，剑士，如果你不是傻瓜，你怎么会把它留在院子里，这让我怎么办？%SPEECH_OFF%耸耸肩，你问起你的报酬。他问你是怎么杀死它们的。你又把问题绕回到报酬上来。贵族皱起眉头。%SPEECH_ON%说得好。仆人！把这个顽固的杀狗人的硬币给他。免得我说话不算数%SPEECH_OFF% | 你把那些残存的畜生拖进院子里，然后叫来了%employer%。他走到窗前，俯视了很长一段时间 %SPEECH_ON%这是真的，还是你在开玩笑？%SPEECH_OFF% 你拔出剑，刺入一只野兽的眼睛中。砰的一声，它泄气了，喷出一层黄色的粘液。贵族松了口气，咕噜咕噜地吞咽口水。%SPEECH_ON%老天爷在上！我马上请一个仆人来拿你的报酬！百分之百%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一次成功的狩猎.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.Assets.addMoney(this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected"));
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Hunted beasts around " + this.World.State.getRegion(this.Flags.get("Region")).Name);
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				local money = this.Contract.m.Payment.getOnCompletion() + this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected");
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] Crowns"
				});
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		local dest = this.World.State.getRegion(this.m.Flags.get("Region")).Center;
		local distance = this.World.State.getPlayer().getTile().getDistanceTo(dest);
		distance = this.Const.Strings.Distance[this.Math.min(this.Const.Strings.Distance.len() - 1, distance / 30.0 * (this.Const.Strings.Distance.len() - 1))];
		_vars.push([
			"killcount",
			this.m.Flags.get("HeadsCollected")
		]);
		_vars.push([
			"noblehousename",
			this.World.FactionManager.getFaction(this.m.Faction).getNameOnly()
		]);
		_vars.push([
			"worldmapregion",
			this.World.State.getRegion(this.m.Flags.get("Region")).Name
		]);
		_vars.push([
			"direction",
			this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(dest)]
		]);
		_vars.push([
			"distance",
			distance
		]);
		_vars.push([
			"regiontype",
			this.Const.Strings.TerrainShort[this.World.State.getRegion(this.m.Flags.get("Region")).Type]
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		return true;
	}

	function onIsTileUsed( _tile )
	{
		return false;
	}

	function onSerialize( _out )
	{
		_out.writeU8(this.m.Size);
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.m.Size = _in.readU8();
		this.contract.onDeserialize(_in);
	}

});

