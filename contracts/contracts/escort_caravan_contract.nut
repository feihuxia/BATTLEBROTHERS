this.escort_caravan_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Caravan = null,
		NobleHouseID = 0,
		NobleSettlement = null,
		IsEscortUpdated = false
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.escort_caravan";
		this.m.Name = "护送车队";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		local nobleHouses = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);

		foreach( i, h in nobleHouses )
		{
			if (h.getSettlements().len() == 0)
			{
				continue;
			}

			if (this.m.Home.getOwner() != null && this.m.Home.getOwner().getID() == h.getID())
			{
				nobleHouses.remove(i);
				break;
			}
		}

		if (nobleHouses.len() != 0)
		{
			this.m.NobleHouseID = nobleHouses[this.Math.rand(0, nobleHouses.len() - 1)].getID();
		}

		local name = this.Const.Strings.CharacterNames[this.Math.rand(0, this.Const.Strings.CharacterNames.len() - 1)] + " von " + this.World.FactionManager.getFaction(this.m.NobleHouseID).getNameOnly();
		this.m.Flags.set("NobleName", name);
		local settlements = this.World.EntityManager.getSettlements();
		local bestDist = 9000;
		local best;

		foreach( s in settlements )
		{
			if (!s.isDiscovered() || !s.isMilitary())
			{
				continue;
			}

			if (s.getID() == this.m.Destination.getID())
			{
				continue;
			}

			if (s.getOwner() != null && s.getOwner().getID() == this.m.NobleHouseID)
			{
				local d = this.getDistanceOnRoads(s.getTile(), this.m.Home.getTile());

				if (d < bestDist)
				{
					bestDist = d;
					best = s;
				}
			}
		}

		if (best != null)
		{
			this.m.NobleSettlement = this.WeakTableRef(best);
			this.m.Flags.set("NobleSettlement", best.getID());
		}

		this.contract.start();
	}

	function setup()
	{
		local settlements = this.World.EntityManager.getSettlements();
		local candidates = [];

		foreach( s in settlements )
		{
			if (s.getID() == this.m.Origin.getID())
			{
				continue;
			}

			if (!s.isDiscovered())
			{
				continue;
			}

			if (!s.isAlliedWith(this.getFaction()))
			{
				continue;
			}

			if (this.m.Origin.isIsolated() || s.isIsolated() || !this.m.Origin.isConnectedToByRoads(s) || this.m.Origin.isCoastal() && s.isCoastal())
			{
				continue;
			}

			local d = this.m.Origin.getTile().getDistanceTo(s.getTile());

			if (d <= 12 || d > 100)
			{
				continue;
			}

			local distance = this.getDistanceOnRoads(this.m.Origin.getTile(), s.getTile());
			local days = this.getDaysRequiredToTravel(distance, this.Const.World.MovementSettings.Speed * 0.6, true);

			if (days > 7 || distance < 15)
			{
				continue;
			}

			if (this.World.getTime().Days <= 10 && days > 4)
			{
				continue;
			}

			if (this.World.getTime().Days <= 5 && days > 2)
			{
				continue;
			}

			candidates.push(s);
		}

		if (candidates.len() == 0)
		{
			this.m.IsValid = false;
			return;
		}

		this.m.Destination = this.WeakTableRef(candidates[this.Math.rand(0, candidates.len() - 1)]);
		local distance = this.getDistanceOnRoads(this.m.Origin.getTile(), this.m.Destination.getTile());
		local days = this.getDaysRequiredToTravel(distance, this.Const.World.MovementSettings.Speed * 0.6, true);

		if (days >= 5)
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}
		else if (days >= 2)
		{
			this.m.DifficultyMult = this.Math.rand(95, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(70, 85) * 0.01;
		}

		this.m.Payment.Pool = this.Math.max(150, distance * 6.0 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult());
		local r = this.Math.rand(1, 3);

		if (r == 1)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else if (r == 2)
		{
			this.m.Payment.Count = 0.25;
			this.m.Payment.Completion = 0.75;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		local maximumHeads = [
			15,
			20,
			25,
			30
		];
		this.m.Payment.MaxCount = maximumHeads[this.Math.rand(0, maximumHeads.len() - 1)];
		this.m.Flags.set("HeadsCollected", 0);
		this.m.Flags.set("Distance", distance);
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"在 %days% 天内护送车队至%direction%的%objective% ",
					"按照约定的方式给于报酬"
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

				if (r <= 5)
				{
					if (this.World.Assets.getBusinessReputation() > 700)
					{
						this.Flags.set("IsStolenGoods", true);
						this.Flags.set("IsEnoughCombat", true);

						if (this.Contract.m.Home.getOwner() != null)
						{
							this.Contract.m.NobleHouseID = this.Contract.m.Home.getOwner().getID();
						}
						else if (this.Contract.m.Destination.getOwner() != null)
						{
							this.Contract.m.NobleHouseID = this.Contract.m.Destination.getOwner().getID();
						}
						else
						{
							local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
							this.Contract.m.NobleHouseID = nobles[this.Math.rand(0, nobles.len() - 1)].getID();
						}
					}
				}
				else if (r <= 10)
				{
					if (this.World.Assets.getBusinessReputation() > 1000 && this.Contract.getDifficultyMult() >= 0.95)
					{
						this.Flags.set("IsVampires", true);
						this.Flags.set("IsEnoughCombat", true);
					}
				}
				else if (r <= 15)
				{
					this.Flags.set("IsValuableCargo", true);
				}
				else if (r <= 20)
				{
					if (this.Contract.m.NobleHouseID != 0 && this.Flags.has("NobleName") && this.Flags.has("NobleSettlement"))
					{
						this.Flags.set("IsPrisoner", true);
					}
				}
				else if (this.Contract.getDifficultyMult() < 0.95 || this.World.Assets.getBusinessReputation() <= 500 || this.Contract.getDifficultyMult() <= 1.1 && this.Math.rand(1, 100) <= 20)
				{
					this.Flags.set("IsEnoughCombat", true);
				}

				this.Contract.spawnCaravan();
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
				this.World.State.setCampingAllowed(false);
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

				if (this.Contract.m.Payment.Count != 0)
				{
					if (this.Contract.m.BulletpointsObjectives.len() >= 2)
					{
						this.Contract.m.BulletpointsObjectives.remove(1);
					}

					this.Contract.m.BulletpointsObjectives.push("每个头颅获得报酬 (%killcount%/%maxcount%)");
				}

				this.World.State.setEscortedEntity(this.Contract.m.Caravan);
			}

			function update()
			{
				if (this.Contract.m.Caravan == null || this.Contract.m.Caravan.isNull() || !this.Contract.m.Caravan.isAlive() || this.Contract.m.Caravan.getTroops().len() == 0)
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (!this.Contract.m.IsEscortUpdated)
				{
					this.World.State.setEscortedEntity(this.Contract.m.Caravan);
					this.Contract.m.IsEscortUpdated = true;
				}

				this.World.State.setCampingAllowed(false);
				this.World.State.getPlayer().setPos(this.Contract.m.Caravan.getPos());
				this.World.State.getPlayer().setVisible(false);
				this.World.Assets.setUseProvisions(false);
				this.World.getCamera().moveTo(this.World.State.getPlayer());

				if (!this.World.State.isPaused())
				{
					this.World.setSpeedMult(this.Const.World.SpeedSettings.EscortMult);
				}

				this.World.State.m.LastWorldSpeedMult = this.Const.World.SpeedSettings.EscortMult;

				if (this.Flags.get("IsFleeing"))
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
					return;
				}
				else if (this.Contract.isPlayerAt(this.Contract.m.Destination))
				{
					if (this.Flags.get("IsCaravanHalfDestroyed"))
					{
						this.Contract.setScreen("Success2");
					}
					else
					{
						this.Contract.setScreen("Success1");
					}

					this.World.Contracts.showActiveContract();
				}
				else if (!this.Flags.get("IsEnoughCombat"))
				{
					if (this.Contract.spawnEnemies())
					{
						this.Flags.set("IsEnoughCombat", true);
					}
				}
				else
				{
					local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);
					local numParties = 0;

					foreach( party in parties )
					{
						numParties = ++numParties;
						numParties = numParties;
					}

					if (numParties > 2)
					{
						return;
					}

					if (this.Flags.get("IsStolenGoods") && this.World.State.getPlayer().getTile().HasRoad)
					{
						if (!this.TempFlags.get("IsStolenGoodsDialogTriggered") && this.Contract.getDistanceToNearestSettlement() >= 6 && this.Math.rand(1, 1000) <= 1)
						{
							this.TempFlags.set("IsStolenGoodsDialogTriggered", true);
							this.Contract.setScreen("StolenGoods1");
							this.World.Contracts.showActiveContract();
						}
					}
					else if (this.Flags.get("IsVampires") && !this.World.getTime().IsDaytime)
					{
						if (!this.TempFlags.get("IsVampiresDialogTriggered") && this.Contract.getDistanceToNearestSettlement() >= 6 && this.Math.rand(1, 1000) <= 2)
						{
							this.TempFlags.set("IsVampiresDialogTriggered", true);
							this.Contract.setScreen("Vampires1");
							this.World.Contracts.showActiveContract();
						}
					}
					else if (this.Flags.get("IsValuableCargo"))
					{
						if (!this.TempFlags.get("IsValuableCargoDialogTriggered") && this.Contract.getDistanceToNearestSettlement() >= 6 && this.Math.rand(1, 1000) <= 1)
						{
							this.TempFlags.set("IsValuableCargoDialogTriggered", true);
							this.Contract.setScreen("ValuableCargo1");
							this.World.Contracts.showActiveContract();
						}
					}
					else if (this.Flags.get("IsPrisoner"))
					{
						if (!this.TempFlags.get("IsPrisonerDialogTriggered") && this.Contract.getDistanceToNearestSettlement() >= 6 && this.Math.rand(1, 1000) <= 1)
						{
							this.TempFlags.set("IsPrisonerDialogTriggered", true);
							this.Contract.setScreen("Prisoner1");
							this.World.Contracts.showActiveContract();
						}
					}
				}
			}

			function onCombatVictory( _combatID )
			{
				this.Flags.set("IsEnoughCombat", true);

				if (_combatID == "StolenGoods")
				{
					this.Flags.set("IsStolenGoods", false);
					this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).addPlayerRelation(this.Const.World.Assets.RelationAttacked, "Killed some of their men");
				}
				else if (_combatID == "Vampires")
				{
					this.Flags.set("IsVampires", false);
				}

				this.start();
				this.World.State.getWorldScreen().updateContract(this.Contract);
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.Flags.set("IsEnoughCombat", true);
				this.Flags.set("IsFleeing", true);
				this.Flags.set("IsStolenGoods", false);
				this.Flags.set("IsVampires", false);

				if (_combatID == "StolenGoods")
				{
					this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).addPlayerRelation(this.Const.World.Assets.RelationAttacked, "Attacked some of their men");
				}

				if (this.Contract.m.Caravan != null && !this.Contract.m.Caravan.isNull())
				{
					this.Contract.m.Caravan.die();
					this.Contract.m.Caravan = null;
				}

				this.start();
				this.World.State.getWorldScreen().updateContract(this.Contract);
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getType() == this.Const.EntityType.CaravanDonkey && _actor.getWorldTroop() != null && _actor.getWorldTroop().Party.getID() == this.Contract.m.Caravan.getID())
				{
					this.Flags.set("IsCaravanHalfDestroyed", true);
				}
				else
				{
					this.Contract.addKillCount(_actor, _killer);
				}
			}

			function end()
			{
				this.World.State.setCampingAllowed(true);
				this.World.State.setEscortedEntity(null);
				this.World.State.getPlayer().setVisible(true);
				this.World.Assets.setUseProvisions(true);

				if (!this.World.State.isPaused())
				{
					this.World.setSpeedMult(1.0);
				}

				this.World.State.m.LastWorldSpeedMult = 1.0;

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
				}

				this.Contract.clearSpawnedUnits();
			}

		});
		this.m.States.push({
			ID = "Running_Prisoner",
			function start()
			{
				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.NobleSettlement != null && !this.Contract.m.NobleSettlement.isNull())
				{
					this.Contract.m.NobleSettlement.getSprite("selection").Visible = true;
				}

				this.Contract.m.BulletpointsObjectives = [
					"将%noble%安全返回至%nobledirection%的%noblesettlement%"
				];
				this.Contract.m.BulletpointsPayment = [];
				this.Contract.m.BulletpointsPayment.push("Get a reward once you arrive");
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.NobleSettlement))
				{
					if (this.Flags.get("IsPrisonerLying"))
					{
						this.Contract.setScreen("Prisoner4");
					}
					else
					{
						this.Contract.setScreen("Prisoner3");
					}

					this.World.Contracts.showActiveContract();
				}
			}

		});
	}

	function createScreens()
	{
		this.importScreens(this.Const.Contracts.NegotiationPerHeadAtDestination);
		this.importScreens(this.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_98.png[/img]{温暖的火焰照亮了%employer%的书房。他让你坐下并给了你一杯酒，你欣然接受。%SPEECH_ON%佣兵，你知道近些日子路途有多艰险吗？%SPEECH_OFF%神明在上，这酒真不错啊。你点点头，尝试掩盖住自己的震惊。%employer%微笑着继续说道。%SPEECH_ON%很好，那你就能明白我交给你的这项任务了。我的车队一路上需要有人护送。很简单，对吧？你有时间吗？如果有咱们就商量商量。%SPEECH_OFF%  |  你发现%employer%在研究桌子上的几张地图。他手指在一张又一张地图上比划着。%SPEECH_ON%车队需要有人护送。危不危险？当然。所以才需要你啊，佣兵。怎么样，感兴趣吗？%SPEECH_OFF%  |  %employer%叉起双臂，噘着嘴。%SPEECH_ON%通常来说，我不会将护送车队的任务交给佣兵，但是人手有点不在状态—恶心，醉酒，纵欲…我觉得你能做到。重要的是我有批货物要送往%objective%，我需要有人保护。有兴趣吗？%SPEECH_OFF%  |  %employer%看着窗外的人群将货物装上马车。说话的时候都没看你一眼。%SPEECH_ON%我有批重要的货物需要送往%objective%。不幸的是，竞争对手出价比我高，抢走了当地的车队保镖。现在我需要你的帮忙。如果你感兴趣，咱们就来商量下价钱吧。%SPEECH_OFF%  |  %employer%拿出一个箱子放在桌子上。当他打开时，其中的纸张就像兔子般几乎想要蹦走重获自由。他抓过一张展开。一边写着合同，另一边有一幅地图。%SPEECH_ON%佣兵，真的很简单。我有批…特别的货物需要送往%objective%。货物我有了，但是我缺少保镖。如果你不介意当一段时间的车队保镖，那咱俩就商量商量价钱吧。%SPEECH_OFF%  |  你看向%employer%的窗外，一群人正给马车装货。%employer%手中拿着两杯酒加入了你。你接过一杯，一口喝完。他盯着你。%SPEECH_ON%这酒可不便宜。你应该慢慢品尝其中的滋味。%SPEECH_OFF%你耸耸肩。%SPEECH_ON%抱歉。能再给我一杯重新尝尝吗？%SPEECH_OFF%%objective%转身来到桌子旁。%SPEECH_ON%所以，我需要有人将车队护送至%objective%。很简单，对吧？如果感兴趣的话，能得到不少的克朗。%SPEECH_OFF%  |  %employer%看着自己的一些书，仔细斟酌着如何才算是好生意。%SPEECH_ON%我有批货物得送往%objective%，而且很快就要出发了。我需要一帮强大的剑士帮我将其安全送到目的地。这活儿你接吗？%SPEECH_OFF%  |  %employer%直入正题。%SPEECH_ON%我有批…好吧，是什么货物就不关你的事了。目的地是%objective%，而且我也是普通人，很担心路上的强盗。我需要你确保车队能安然无恙地抵达目的地。怎么样，有兴趣吗？%SPEECH_OFF%  |  %employer%看向窗外。%SPEECH_ON%会有强盗是显而易见的，而且天知道还会有什么麻烦，而且他们都喜欢出没在路上。之前走霉运后，我以前的车队保镖对这活儿没兴趣了。现在我需要人手护送我的货物。下一个目的地是%objective%。如果有酬金的话，你愿意接下这活儿吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{咱们谈谈价格吧。 |  多少克朗？ |  酬金有多少？}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{没兴趣。 |  我们不接这样的活儿。}",
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
			ID = "StolenGoods1",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_78.png[/img]{一群悬挂着%noblehousename%旗帜的人出现在路上。他们的马在一边，缰绳在泥土中。似乎他们在等你。其中一人背着手向前。%SPEECH_ON%朋友，你运输的是盗窃物品。这些东西是属于%noblehousename%的。立刻交出来，否则后果自负。%SPEECH_OFF%嗯，你早该知道%employer%运送的东西有问题。 |  数人站在路上。他们悬挂着%noblehousename%的旗帜，可能来者不善。他们的副官来到你们所有人面前。%SPEECH_ON%各位好！不幸的是，你们护送的货物是从%noblehousename%偷窃的。请离开车队，回头该去哪就去哪吧。只有这样才不会丢了小命。不然今天就死在这里吧。%SPEECH_OFF%  |  好吧，看来%employer%并没有对你道出全部的实情：一群%noblehousename%的人会质问你为何护送从他们身上偷窃的货物。他们的副官朝你们大喊。%SPEECH_ON%如果还想看到明天的太阳，就各回各家去。我明白你们只是履行职责。但是，你们的职责就是服从我。只要照做，你们今天就能保住小命，这点我可以保证。%SPEECH_OFF%  |  一人站在路上，似乎没有离开的迹象。车夫扯住缰绳，就在这时，一群全副武装的人都出现在了路上。他们佩戴者%noblehouse%的标志。%SPEECH_ON%那么，这就是%noblehousename%的货物了。你们运送的货物是我们家族的财产。如果还想活命，就交出来吧。如果小命都不想要了，好吧，那就尽管无视我的话来试试吧。%SPEECH_OFF%%randombrother%走向你，悄悄地说话。%SPEECH_ON%我们就不该相信%employer%那个鼠辈。%SPEECH_OFF%  |  你真该逼得更近点，了解到底在护送什么。路上出现了一群人，要求你交出车队，然后滚蛋。当你询问来人身份时，他们宣称来自%noblehousename%并且你运送的货物都是一周前被偷走的。他们的副官提出和平的解决办法。%SPEECH_ON%离开，你们就能保住小命。我对你们没有任何疑虑，只是你们的委托人而已。但是，若是阻拦我们，那你们就去死吧。不要因为不属于自己的货物而丢掉小命。这不值得。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Banner = "",
			Options = [
				{
					Text = "我不这么认为。若有需要，我们将守护它。",
					function getResult()
					{
						return "StolenGoods2";
					}

				},
				{
					Text = "付给咱们的薪酬还不足以与%noblehousename%作对。干掉他们。",
					function getResult()
					{
						return "StolenGoods3";
					}

				}
			],
			function start()
			{
				this.Banner = this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).getUIBannerSmall();

				if (this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).getPlayerRelation() >= 80)
				{
					this.Options.push({
						Text = "你的大人们不会感激他们的盟友，%companyname%这种耽搁的。",
						function getResult()
						{
							return "StolenGoods4";
						}

					});
				}
			}

		});
		this.m.Screens.push({
			ID = "StolenGoods2",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_78.png[/img]{你点点头。%SPEECH_ON%听起来很不错，但是很不幸，我们收钱就是护送这批货物的，而不是弄清楚它的主人是谁。%SPEECH_OFF%副官也理解地点点头。%SPEECH_ON%那就没办法了。%SPEECH_OFF%他拔出剑。你也拔出武器。那人举起手，准备下达命令。%SPEECH_ON%变成这样真是可惜了。冲锋！%SPEECH_OFF%  |  你拔出剑。%SPEECH_ON%我来这儿可不是在贵族之间下赌注的。我的任务是将车队护送至%objective%。如果你想挡道的话，那就试试吧，看来今天有人要丢掉小命了。%SPEECH_OFF%  |  你手指向车队。%SPEECH_ON%%employer%的命令是将货物送往目的地。那也是我的任务。%SPEECH_OFF%你看着副官，慢慢抽出自己的剑。他也点点头拔出武器。%SPEECH_ON%局势变成这样真是可惜了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Banner = "",
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "StolenGoods";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.IsAutoAssigningBases = false;
						p.TemporaryEnemies = [
							this.Contract.m.NobleHouseID
						];

						foreach( e in p.Entities )
						{
							if (e.Faction == this.Contract.getFaction())
							{
								e.Faction = this.Const.Faction.PlayerAnimals;
							}
						}

						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.m.NobleHouseID);
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
				this.Banner = this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "StolenGoods3",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_78.png[/img]{虽然%employer%不会喜欢这样，但是如果运送的是赃物，那他本该告诉你。你一挥手，命令手下的人走开。那些人立马来到车队旁，而无助的临时工和商人看着他们卸货。 |  你不打算为了毫不在意的货物而经历一场恶战。于是走向一边让他们取走属于他们的货物。%randombrother%说这一状况肯定不会让%employer%满意的。你点点头。%SPEECH_ON%那是他的问题。%SPEECH_OFF%  |  你不会护送赃物，也不会与毫无纠葛的贵族死斗。你无视几名商人的反抗，走向一边，让车队和货物归还至原有的主人。其中一名商人挥舞着拳头，大喊着你没有履行合约，%employer%肯定不会满意的。}",
			Image = "",
			List = [],
			Banner = "",
			Options = [
				{
					Text = "倒霉。",
					function getResult()
					{
						this.Flags.set("IsStolenGoods", false);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to protect a caravan");
						this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).addPlayerRelation(this.Const.World.Assets.RelationNobleContractPoor, "Cooperated with their soldiers");
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.updateAchievement("NeverTrustAMercenary", 1, 1);
				this.Banner = this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "StolenGoods4",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_78.png[/img]{你告诉他们自己与%noblehousename%是好友，并且无意破坏这段友谊。其中一人顿了顿。%SPEECH_ON%该死，虽然他有可能在撒谎，但是如果情况属实…那真是不值得。咱们离开这里吧。%SPEECH_OFF%  |  你简明扼要地告诉他们自己与%noblehousename%相当熟悉，甚至说出了几名后裔的名字。他们放下剑，不想让局势变得更加恶化。在这个世界，小心驶得万年船。 |  你告诉他们自己与%noblehousename%关系不错。他们要求证据，而你说出了知道的贵族名字，还包括一些人的特殊癖好。证据充足—来袭者放下武器，让你离开。}",
			Image = "",
			List = [],
			Banner = "",
			Options = [
				{
					Text = "我们继续！",
					function getResult()
					{
						this.Flags.set("IsStolenGoods", false);
						return 0;
					}

				}
			],
			function start()
			{
				this.Banner = this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "ValuableCargo1",
			Title = "营地…",
			Text = "[img]gfx/ui/events/event_55.png[/img]{当车队停下休息时，%randombrother%抓着你的胳膊，秘密地带着你来到一辆马车后面。他四处张望，确保没人后便揭开一个箱子的盖子。里面有着宝石，在黑暗处显得熠熠发光。他关上盖子。%SPEECH_ON%你想干嘛？这可是一大笔钱。%SPEECH_OFF%  |  当车队停下来修理车轮时，车轴突然断裂，整辆马车倾向一边。一个木箱哗啦啦的散落在地上，盖子也打开了。你拿着锤子上前钉住，突然间你发现有很多宝石散落在盒子外面。%randombrother%也看到了，然后手摸向武器。%SPEECH_ON%长官，呃，这声音还真响啊。咱们是悄悄地，还是…？%SPEECH_OFF%  |  车队领袖开始尖叫。你看着他追赶并拦截下一个试图跑掉的人。两人在地上纠缠着，拳打脚踢间，一个棕色袋子飞了出来。它落在你脚边，宝石也滚了出来。%randombrother%俯下身子捡起了几颗。他站得笔直，另一只手放在武器上。他盯着你。%SPEECH_ON%你懂的，这里还有很多可以…%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "赶紧滚回去工作，不然我暴揍你。我们还得履行合约。",
					function getResult()
					{
						this.Flags.set("IsValuableCargo", false);
						return 0;
					}

				},
				{
					Text = "终于，幸运女神对我们微笑了。我们自己取走这些宝石！",
					function getResult()
					{
						return "ValuableCargo2";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ValuableCargo2",
			Title = "营地…",
			Text = "[img]gfx/ui/events/event_50.png[/img]{一名车队保镖走上前。%SPEECH_ON%嘿，哥们，咱们赶紧上路吧？%SPEECH_OFF%你向自己手下点点头。他也点点头，然后迅速转身，将匕首刺穿保镖的头颅。战团剩余人瞬间明白状况，于是麻利的拔出武器，向保镖发起攻击。他们毫无还手之力，杀戮过后，你就是珍贵宝石的新主人了。 |  你无法抵制宝石的诱惑！你迅速点头，命令%companyname%杀掉所有保镖。鉴于他们如此相信你，因此过程很快，有几个人死去的时候仍质问着为什么要背叛他们。 |  宝石的价值可比什么合约带来的酬劳值钱多了。你大声呼喊，命令%companyname%杀掉所有的保镖。他们迅速且毫不犹豫，而那些卫兵行动迟缓，一脸懵逼。不消片刻，你就坐拥这些宝石了。%employer%肯定会暴跳如雷，但是去他妈的，现在宝石是你的了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "这些玩意可比得上不少的克朗。",
					function getResult()
					{
						this.Flags.set("IsValuableCargo", false);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationBetrayal, "Slaughtered a caravan tasked to protect");
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.Assets.addMoralReputation(-10);
						this.Contract.m.Caravan.die();
						this.Contract.m.Caravan = null;
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				local n = this.Math.min(this.Math.max(1, this.World.Assets.getBusinessReputation() / 1000), 3) + 1;

				for( local i = 0; i != n; i = i )
				{
					local gems = this.new("scripts/items/trade/uncut_gems_item");
					this.World.Assets.getStash().add(gems);
					this.List.push({
						id = 10,
						icon = "ui/items/" + gems.getIcon(),
						text = "你获得了" + gems.getName()
					});
					i = ++i;
				}
			}

		});
		this.m.Screens.push({
			ID = "Prisoner1",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_53.png[/img]{当沿着车队走的时候，你遇到几名卫兵在朝一个笼子吐口水。其中有一个衣衫褴褛，双脚泥泞的人。他透过囚笼发现了你。%SPEECH_ON%佣兵，求你了！我是%noblehousename%的%noble%。你杀掉这些人就能得到奖赏！%SPEECH_OFF%其中一名卫兵大笑。%SPEECH_ON%雇佣兵，别听他鬼扯。%SPEECH_OFF%  |  你走过一辆马车，突然之间有什么东西抓住了你的胳膊。你手握着剑转过身，然后紧握的手缩进黢黑的马车中。你谨慎地解开篷布，发现有个上着枷锁的人在里面。他声音中透着恐惧，似乎嘴中突出的第一个词是水。%SPEECH_ON%雇佣兵，别在意我衣衫褴褛，我是%noblehousename%的%noble%。杀掉所有卫兵，还我自由，确保我能回家。只要你能做到，奖赏是肯定少不了的。%SPEECH_OFF%一名卫兵打断了他的话，那阶下囚缩进了牢笼中。卫兵大笑。%SPEECH_ON%那个小王八蛋又四处散步谎言了？雇佣兵，咱们走，前面的路还远着呢。%SPEECH_OFF%  |  你听到一辆马车中传出了干呕声。调查中，你发现了一个衣衫褴褛的人倒在地上，旁边有个笑着的卫兵。%SPEECH_ON%再敢那么和我说话，我就打烂你的牙齿。囚犯，明白了？%SPEECH_OFF%倒下的人点点头，往后挪了挪。看到你时，他微弱地点点头。%SPEECH_ON%雇佣兵，我是%noblehousename%的%noble%。你肯定听说过我的名字。如果你杀掉这群弱鸡，那么我将确保你能得到大笔的奖赏。%SPEECH_OFF%卫兵露出紧张的笑容。%SPEECH_ON%雇佣兵，别听信他的谣言！%SPEECH_OFF%  |  %SPEECH_ON%雇佣兵！我能和你说说话吗？%SPEECH_OFF%你转身惊讶的发现一辆马车中有个人。他身上有着枷锁。%SPEECH_ON%我是%noblehousename%的%noble%。显而易见，我有了点麻烦，但是那也没关系，对吧？杀掉这些卫兵，将我送回家族。与其拿什么护送狗屁车队的钱，还不如听我的，钱肯定会更多。%SPEECH_OFF%一名卫兵大笑着走上前来。%SPEECH_ON%哟，这小流氓又开始满嘴胡话了、佣兵，无视他的胡扯。好了，继续干正事了。%SPEECH_OFF%  |  你听到明显的枷锁声，叮当作响，让人觉得有人能轻易逃跑。但是反而一个明显囚禁住的人恳求着你。%SPEECH_ON%终于能和你搭上话了。雇佣兵，听着，虽然有点难以置信，但是我的确是%noblehousename%的%noble%。虽然我不知道这些人抓走我的原因，但是这些无关紧要。重要的是你的名头不能白白玷污，尤其是所谓的‘雇佣’。如果你杀掉这些卫兵，然后带我回家，你绝对能拿到一大笔钱！%SPEECH_OFF%一名卫兵走上前来。%SPEECH_ON%闭嘴，小王八蛋！雇佣兵，别理他。好了，咱们还有活儿要做。%SPEECH_OFF%  |  当车队稍作休息时，你发现一个人在马车床铺上晃荡着双腿。但是并没有自由可言—双脚上有着枷锁，双臂的情况也差不多。他看到你了。%SPEECH_ON%你认识我？我是%noblehousename%的%noble%，一名颇有价值的囚犯，肯定听闻过我的名字吧。但要是重获自由，那我的价值就更大了。杀掉这些卫兵，带我回家，那样你会拥有数不清的克朗！%SPEECH_OFF%一名卫兵走上前，用剑鞘敲了下他的胫骨。%SPEECH_ON%你，闭嘴！好了，雇佣兵，咱们马上又要上路了。这小王八蛋别放在心上。他只会满口胡话。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "别浪费口舌。我他妈才不在乎你是谁。",
					function getResult()
					{
						this.Flags.set("IsPrisoner", false);
						return 0;
					}

				},
				{
					Text = "最好是值得的。等我还你自由，你得确保履行诺言。",
					function getResult()
					{
						this.updateAchievement("NeverTrustAMercenary", 1, 1);
						return "Prisoner2";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Prisoner2",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_60.png[/img]{你吐了口唾沫，清清嗓子，然后迅速地拔出剑，干掉了车队卫兵。%randombrother%看到之后便命令剩余的%companyname%照做。当你手下的人发起攻击时，车队卫兵还没弄清局势，真是场短暂而困惑的屠杀。\n\n 那名囚犯重获自由后便不停的感谢你，并让你带路。%SPEECH_ON%一旦我们抵达%noblesettlement%，看到我微笑而充满生气的脸庞，你就准备迎接克朗雨吧！%SPEECH_OFF%  |  你拔出剑，朝卫兵的脸劈去。他转身逃跑，你的剑落在他的头骨上，碎骨中夹杂着脑浆，就像爆裂的蛋奶酥一样。%randombrother%看到后，便招呼战团其余人战斗。他们很快就干掉了车队卫兵。当你释放%noble%后，他指向一条路。%SPEECH_ON%前往%noblesettlement%，我的家族将赐予你不可想象的奖励！%SPEECH_OFF%  |  当车队卫兵转身时，你拔出一把匕首，瞬间刺向腋窝处，径直捅向心脏。他低沉一哼便倒在地上。其他卫兵看到了，下一刻便看到你的剑将他开肠破肚。他大喊着，然而这次声音却传了出去。战斗瞬间爆发，但是战争的天平并非平衡，%companyname%很快干掉了车队卫兵。\n\n 一切完事后，%noble%重获自由。他揉了揉发紫的手腕，指向%noblesettlement%。%SPEECH_ON%前进吧，等我回到家族，你就能得到不菲的赏金了！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我已经看到自己的腰包填满克朗了！",
					function getResult()
					{
						this.Flags.set("IsPrisoner", false);
						this.Flags.set("IsPrisonerLying", this.Math.rand(1, 100) <= 33);
						this.Contract.setState("Running_Prisoner");
						this.World.State.setCampingAllowed(true);
						this.World.State.getPlayer().setVisible(true);
						this.World.Assets.setUseProvisions(true);

						if (!this.World.State.isPaused())
						{
							this.World.setSpeedMult(1.0);
						}

						this.World.State.m.LastWorldSpeedMult = 1.0;
						this.Contract.m.Caravan.die();
						this.Contract.m.Caravan = null;
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationAttacked, "Slaughtered a caravan tasked to protect");
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.Assets.addMoralReputation(-5);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Prisoner3",
			Title = "在%noblesettlement%",
			Text = "[img]gfx/ui/events/event_31.png[/img]{你抵达%noblesettlement%。一名装备精良的卫兵看到了%noble%，立刻喊出命令，很快传遍了镇子。很快，几匹马疾驰而来，骑手迅速下马。看来那人并没有撒谎。%reward%将许诺的奖赏交给了你。 |  还没进入%noblesettlement%，几名骑兵就来到面前。身后随风飞舞的是皇家旗帜。不远处也有一支装备精良的分遣队。他们不假思索地欢迎那名囚犯的归来。其中一人从欢迎的狂热中冷静下来，将奖赏交给了你。他们说出身低微者唯一的责任就是包住这些高贵血统的脑袋。好吧。 |  虽然囚犯并没有撒谎，但是你瞬间明白得守住自己社会上的地位：一名重装卫兵将奖励交给你。即使你拯救了其血脉，似乎%noblehousename%并无意与你亲自攀谈。就是这样。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "至少酬金不错。",
					function getResult()
					{
						this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).addPlayerRelation(this.Const.World.Assets.RelationFavor, "Freed an imprisoned member of the house");
						this.World.Assets.addMoney(3000);
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得了[color=" + this.Const.UI.Color.PositiveValue + "]3000[/color]克朗的奖励"
				});
				this.List.push({
					id = 10,
					icon = "ui/icons/relations.png",
					text = "你的关系对象" + this.World.FactionManager.getFaction(this.Contract.m.NobleHouseID).getName() + " improve"
				});
			}

		});
		this.m.Screens.push({
			ID = "Prisoner4",
			Title = "在%noblesettlement%",
			Text = "[img]gfx/ui/events/event_31.png[/img]{当你靠近%noblesettlement%时，%noble%猛冲向灌木丛后。%SPEECH_ON%抱歉，亲爱的朋友，我得解决下生理问题。%SPEECH_OFF%你点点头，然后等着。等着。等着。你猛然意识到不对劲，拔腿冲向灌木丛，却发现那人消失的无影无踪，而且鞋子上还有翔。 |  %noble%让你停下来。他冲向小溪河床。%SPEECH_ON%伙计，稍等片刻。让我梳洗下，这样家人就不会看到我如此狼狈了！%SPEECH_OFF%有理。你让他自便，但是回来时，却发现他不见了。你跟随着泥泞的足迹，来到山上。另一边是一片农地，长着浓密的作物，那骗子能轻易溜走。%randombrother%来到你身边。%SPEECH_ON%操蛋。%SPEECH_OFF%真特娘的操蛋。 |  前往%noblesettlement%的路上有几名农民。他们在互相理发，而这似乎引起了%noble%的注意。%SPEECH_ON%抱歉，伙计，我得清理下。你懂的，可不能让家里的老太太看到我这个样子。%SPEECH_OFF%你点头同意，于是去清点库存打发时间。当你回来询问农民那名贵族的踪迹时。其中一人盯着你。%SPEECH_ON%我可没看到什么贵族。%SPEECH_OFF%你解释道他衣衫褴褛，快速描述了下。他们耸耸肩。%SPEECH_ON%我看到那乞丐跑到远处的田地，然后翻身上马，跑得越来越远。我们看到他一路大笑，还以为脑子出问题了。%SPEECH_OFF你充满怒气。 |  你将%noble%带到了%noblesettlement%。当走进镇里时，他几乎全身颤抖。%SPEECH_ON%啊，我有点小紧张。%SPEECH_OFF%虽然卫兵都不认识他，但是鉴于他的穿着，也是可以理解的。你上前让一名装备精良的卫兵找来贵族的人。他转向你，挺拔笔直的身子几乎纹丝不动。%SPEECH_ON%所为何事？%SPEECH_OFF%你转身指向那人。%SPEECH_ON%卧槽，就是…那个…呃…%SPEECH_OFF%%noble%消失的无影无踪。你环顾四周。一名乡下姑娘吸引了%randombrother%的注意，而战团其他人四处毫无目的的乱逛。居民来来往往，这骗子很容易混进人群消失不见。你捏紧拳头。卫兵推开你。%SPEECH_ON%若是没有事情，那就离开吧，否则就别怪我们动粗了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Damnit!",
					function getResult()
					{
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Vampires1",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_33.png[/img]{当车队停下稍作整顿时，你听到奇怪的声音，就像是有人在啃着苹果，吸吮着汁液。你四处走动，来到马车末端，发现一个苍白的身影伏在死掉卫兵的身上，而且那奇怪生物的獠牙刺入了那人的脖子中。你能看到每口都带着血肉，那生物狞笑着喝着鲜血。\n\n 你拔出剑，呼喊着招呼雇佣兵。%SPEECH_ON%肮脏的野兽！兄弟们，准备作战！%SPEECH_OFF%  |  盒子盖左右移动。你盯着它，与一名车队卫兵交换了下眼神。%SPEECH_ON%你们还运送犬类？%SPEECH_OFF%突然间，盖子爆裂打开，一股强大的力量将其撕成了碎片。一只生物呜咽着从盒子里冲出，手臂交叉放在胸膛上。面容苍白，皮肤紧绷，明显冷冰冰的。那是…\n\n 车队的护卫边跑边喊着。%SPEECH_ON%货物跑了！货物跑了！%SPEECH_OFF%货物？谁敢把这么恐怖的东西称作‘货物’？ |  你看到其中一名车队护卫将一只猫抱离了箱子。那只猫在空中挣扎着，然而生气地抓向抱它的人。你对此产生了兴趣，走上前问那人在做什么。他搜了搜肩，抬起盒子的盖子把猫扔了进去。%SPEECH_ON%我在喂它。%SPEECH_OFF%那只猫尖叫着，不停地抓挠着盒子，但很快你就听不到它的声音了。就在车队护卫转身的时候，盒子的盖子突然被掀开了，你看到一只灰白色的生物以迅雷不及掩耳之势冲向了那名护卫。它露出尖牙咬向了他的脖子。护卫的脖子变成了紫色，很快又变得苍白，他用力捂着伤口止血，额头爆出的青筋清晰可见。\n\n 你后退了一步，拔出了武器，并令你的手下保持警惕。 |  就在你们休息的时候，一位年轻的车队护卫悄悄地走向了你。%SPEECH_ON%你好佣兵，想看点有意思的东西吗？%SPEECH_OFF%你正好无聊，所以你就答应了。他把你领到了一辆货车旁，掀开了其中一只盒子的盖子。你看见里面有一个灰白色的身影，双臂交叉放在胸前，脸色苍白，似乎正在沉睡。你吓得向后跳了一步，因为那可不是什么普通的尸体。车队护卫大笑起来。%SPEECH_ON%怎么，你害怕死人吗？%SPEECH_OFF%就在那时，那个身影突然伸出了手臂，把那个年轻人拖入了盒子中。你没有去救那个蠢货，而是转向跑向了你的战场兄弟们，与此同时，周围其他盒子的盖子也都被掀了起来。 |  你在路边休息的时候，突然听到车队某处传来了一声惨叫。你拔出了武器，冲向了叫声传来的地方。一位车队护卫无力地走向你，紧捂着自己的脖子。他瞪着双眼，愣愣地张着嘴巴。%SPEECH_ON%它们跑出来了！它们跑出来了！%SPEECH_OFF%另一名护卫冲了过来，然后他根本就没有停下来的意思。你抬头往前看去，发现一群灰白色的生物正在护卫间肆虐着，身上披着黑色的披风，不停地收割着生命。在它们注意到你之前，你已经转身让战团作好了迎战的准备。 |  趁车队休息的时候，你走到了货物旁，检查它们有没有绑好。而来到最后一辆货车处时，你发现车子已经倾倒在地，运货的牲口已经死了。旁边还倒着两名护卫。他们浑身苍白，还保持着生前的动作。你抬起头来，发现了一群满脸血色的生物正伏在货车上面，嘴中还叼着一具尸体。\n\n%randombrother%拿着武器，走到你身边，把你推向了后方。%SPEECH_ON%快去警告其他人，大人！%SPEECH_OFF%现在也只有这么办了。你用尽浑身力气大叫着，让你的其他手下做好战斗准备。 |  就在你趁空去方便的时候，一声惨叫吓得你浑身哆嗦了一下。你提起裤子，跑向了叫声传来的地方。在那里你发现了一位惊慌失措而被自己绊倒的车队护卫。在他身后，你看到了一种浑身苍白的生物，正在擦拭嘴间的鲜血。而货车上的盒子也都被打开了，里面爬出了更多类似的生物，它们的双眼充斥着杀戮的欲望。\n\n 你立刻警告了其他手下，做好战斗准备。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "防守车队",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "Vampires";
						p.Music = this.Const.Music.UndeadTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Center;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Vampires, 80 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getID());
						this.World.Contracts.startScriptedCombat(p, false, false, false);
						return 0;
					}

				},
				{
					Text = "逃命吧！快跑！快跑！",
					function getResult()
					{
						this.Contract.m.Caravan.die();
						this.Contract.m.Caravan = null;
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to protect a caravan");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_04.png[/img]{到达%objective%，商队领队转向你，手里拿着一个大包。%SPEECH_ON%谢谢你把我们送到这里，佣兵。%SPEECH_OFF%你拿着这个把它交给%randombrother%。他说完后点点头。商队领队微笑着。%SPEECH_ON%也谢谢你没有背叛我们、屠宰我们的人。%SPEECH_OFF%雇佣军以奇怪的方式得到感谢。 |  到达%objective%之后，商队的货车将立即被卸载，他们的商品被带到附近的仓库。清理完之后，领队给你一袋克朗，感谢你保护他们一路安全。 |  %objective%用一群寻求工作的短工迎接你。商队领队给人们发放克朗，他们的脏手去车卸下货物。领队完成了与人群的事之后，转向你。他有手里拿着一个背包。%SPEECH_ON%这是给你的，雇佣军。%SPEECH_OFF%你拿着。一些短工看着这场金钱交易，就像猫盯着悬挂着的老鼠一样。 |  你做到了，完成了对%employer%的承诺把商队送到了。商队领袖用克朗感谢你。看起来他很感激还活着这个事实，简短地告诉了你他被土匪伏击的故事。你点点头，略微对他发生的事表示回应。 |  车队进入%objective%，每辆车的轮子装模作样地在干泥地上滚动着。商队开始卸载货物，一些人在赶走乞丐。领队给你一个袋子，仅此而已。他忙于工作，没有跟你多说什么。沉默是表示感激。 |  到达%objective%之后，商队领队开始谈话，仿佛你们两个有什么共同点。他说起自己年轻的时候，当时他还是个能做这做那的有活力的年轻人。他显然错过了很多战斗。真是遗憾。你厌倦了他的谈话，要他付钱，然后离开这个可怜的地方。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一笔数量可观的克朗。",
					function getResult()
					{
						local money = this.Contract.m.Payment.getOnCompletion() + this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected");
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(money);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Protected a caravan as promised");
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
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
				});
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/well_supplied_situation"), 3, this.Contract.m.Destination, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你不得不怀疑%objective%这样的地方是否值得付出生命。你到达了那里，但不是所有的车子都做到了。商队领袖走过来，手里的袋子比预想的要轻。%SPEECH_ON%我想支付你更多钱，佣兵，因为我知道这个世界的完美并不容易，但是%employer%坚持要我根据损失作出削减。你真的理解？%SPEECH_OFF%他似乎害怕你将对他进行报复，但你只是拿上钱离开了。生意就是生意。 |  到达%objective%之后，商队领队转向你，手里拿着袋子。%SPEECH_ON%比你预想的要轻。%SPEECH_OFF%是的。他继续道。%SPEECH_ON%不是每辆车都挺过来了。%SPEECH_OFF%没有。%SPEECH_ON%我只是%employer%的信使。别杀我。%SPEECH_OFF%你不会的。虽然……不。 |  到达%objective%之后，该商队领队手开始卸载货物。他们缺了几个人，还少了几辆车。领队带着你的报酬来跟你说明情况。%SPEECH_ON%%employer%让我根据到达的商品付你钱。不幸的是，我们损失了一些……%SPEECH_OFF%你点点头，拿走了钱。生意就是生意。 |  当你达到%objective%的时候，商队领队都快哭出来了。他说他失去了一些人，损失的车辆也会给他们的未来造成很大困难。你不在乎，但你还是点头给他支持。%SPEECH_ON%不管怎样我想我该谢谢你，佣兵。毕竟我们没有都死了。不幸的是……我只能付你这么多了。%employer%要求损失从你的所得中扣除，%SPEECH_OFF%Y你再次点头，拿走了你的报酬。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "不太顺利……",
					function getResult()
					{
						local money = this.Contract.m.Payment.getOnCompletion() + this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected");
						money = this.Math.floor(money / 2);
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(money);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractPoor, "Protected a caravan, albeit poorly");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				local money = this.Contract.m.Payment.getOnCompletion() + this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected");
				money = this.Math.floor(money / 2);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() / 2 + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "战斗之后",
			Text = "[img]gfx/ui/events/event_60.png[/img]{你在信任你的行商浪人和商人的陪伴下开始了旅程。如今他们的尸体倒了满地，伸着手，指尖爬满了苍蝇。阳光会让你的失败散发出毁灭性的气味。该往前走了。 |  货车压在他们身边。躯干和四肢四碎零落。废墟中传来一声呻吟，但之后你再也听不到了——这是垂死的声音。暗影在草地上形成波纹，你上方是不断增加的秃鹰群。最好还是让它们饱餐一顿吧，因为你也没有别的选择。 |  雇佣你的商人倒在你脚边。他并不能算是脸朝地的，因为他的脸其实已经不存在了。地上鲜血四溅，你控制不住地凝视着自己的失败。你的手下发现有人在抽搐，但你很清楚。已经无法挽回了。商队里其他人更加惨不忍睹。没必要继续停留。 |  战斗平息，你发现商人靠在翻倒的货车上。他瞪着眼睛，绝望地捂着裂开的脖子。鲜血从他指缝里喷涌而出，你什么都来不及做，他就死了。你想要救他，可是太晚了。呆滞的双眼看着你。%randombrother%，你的一个手下，合上了它们，然后站起来去搜查商队剩下的东西。 |  你在货车的残骸中蹒跚而行。不难看出来：商人的头好像被某种柜子砸到了——也许就是他在激烈战斗中找的保护。唉，商队里就没个像样子的人了。即便以你的标准来看，战斗也极为激烈，造成的屠杀甚至让你不少兄弟恶心。如果噩梦降临，那就让它降临吧。这是你的失败应得的结果。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "见鬼！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to protect a caravan");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function addKillCount( _actor, _killer )
	{
		if (_killer != null && _killer.getFaction() != this.Const.Faction.Player && _killer.getFaction() != this.Const.Faction.PlayerAnimals)
		{
			return;
		}

		if (this.m.Flags.get("HeadsCollected") >= this.m.Payment.MaxCount)
		{
			return;
		}

		if (_actor.getXPValue() == 0)
		{
			return;
		}

		if (_actor.getType() == this.Const.EntityType.GoblinWolfrider || _actor.getType() == this.Const.EntityType.Wardog || _actor.getType() == this.Const.EntityType.ArmoredWardog || _actor.getType() == this.Const.EntityType.SpiderEggs || this.isKindOf(_actor, "lindwurm_tail"))
		{
			return;
		}

		if (!_actor.isAlliedWithPlayer() && !_actor.isResurrected())
		{
			this.m.Flags.set("HeadsCollected", this.m.Flags.get("HeadsCollected") + 1);
		}
	}

	function spawnCaravan()
	{
		local faction = this.World.FactionManager.getFaction(this.getFaction());
		local party = faction.spawnEntity(this.m.Home.getTile(), "Trading Caravan", false, this.Const.World.Spawn.CaravanEscort, this.m.Home.getResources() * 0.4);
		party.getSprite("banner").Visible = false;
		party.getSprite("base").Visible = false;
		party.setMirrored(true);
		party.setDescription("A trading caravan from " + this.m.Home.getName() + " that is transporting all manner of goods between settlements.");
		party.setMovementSpeed(this.Const.World.MovementSettings.Speed * 0.6);
		party.setLeaveFootprints(false);

		if (this.m.Home.getProduce().len() != 0)
		{
			for( local j = 0; j != 3; j = j )
			{
				party.addToInventory(this.m.Home.getProduce()[this.Math.rand(0, this.m.Home.getProduce().len() - 1)]);
				j = ++j;
			}
		}

		party.getLoot().Money = this.Math.rand(0, 100);
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(this.m.Destination.getTile());
		move.setRoadsOnly(true);
		local unload = this.new("scripts/ai/world/orders/unload_order");
		local despawn = this.new("scripts/ai/world/orders/despawn_order");
		local wait = this.new("scripts/ai/world/orders/wait_order");
		wait.setTime(4.0);
		c.addOrder(move);
		c.addOrder(unload);
		c.addOrder(wait);
		c.addOrder(despawn);
		this.m.Caravan = this.WeakTableRef(party);
	}

	function spawnEnemies()
	{
		local tries = 0;
		local myTile = this.m.Destination.getTile();
		local tile;

		while (tries++ == 0)
		{
			local tile = this.getTileToSpawnLocation(myTile, 7, 11);

			if (tile.getDistanceTo(this.World.State.getPlayer().getTile()) <= 6)
			{
				continue;
			}

			local nearest_bandits = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getNearestSettlement(tile);
			local nearest_goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getNearestSettlement(tile);
			local nearest_orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getNearestSettlement(tile);

			if (nearest_bandits == null && nearest_goblins == null && nearest_orcs == null)
			{
				this.logInfo("no enemy base found");
				return false;
			}

			local bandits_dist = nearest_bandits != null ? nearest_bandits.getTile().getDistanceTo(tile) + this.Math.rand(0, 10) - 5 : 9000;
			local goblins_dist = nearest_goblins != null ? nearest_bandits.getTile().getDistanceTo(tile) + this.Math.rand(0, 10) : 9000;
			local orcs_dist = nearest_orcs != null ? nearest_bandits.getTile().getDistanceTo(tile) + this.Math.rand(0, 10) : 9000;
			local party;
			local origin;

			if (bandits_dist <= goblins_dist && bandits_dist <= orcs_dist)
			{
				party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).spawnEntity(tile, "Brigands", false, this.Const.World.Spawn.BanditRaiders, this.Math.rand(80, 100) * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				party.setDescription("A rough and tough band of brigands preying on the weak.");
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

				origin = nearest_bandits;
			}
			else if (goblins_dist <= bandits_dist && goblins_dist <= orcs_dist)
			{
				party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).spawnEntity(tile, "Goblin Raiders", false, this.Const.World.Spawn.GoblinRaiders, this.Math.rand(80, 100) * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				party.setDescription("A band of mischievous goblins, small but cunning and not to be underestimated.");
				party.getLoot().ArmorParts = this.Math.rand(0, 10);
				party.getLoot().Medicine = this.Math.rand(0, 2);
				party.getLoot().Ammo = this.Math.rand(0, 30);
				local r = this.Math.rand(1, 4);

				if (r == 1)
				{
					party.addToInventory("supplies/strange_meat_item");
				}
				else if (r == 2)
				{
					party.addToInventory("supplies/roots_and_berries_item");
				}
				else if (r == 3)
				{
					party.addToInventory("supplies/pickled_mushrooms_item");
				}

				origin = nearest_goblins;
			}
			else
			{
				party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).spawnEntity(tile, "Orc Marauders", false, this.Const.World.Spawn.OrcRaiders, this.Math.rand(80, 100) * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				party.setDescription("A band of menacing orcs, greenskinned and towering any man.");
				party.getLoot().ArmorParts = this.Math.rand(0, 25);
				party.getLoot().Ammo = this.Math.rand(0, 10);
				party.addToInventory("supplies/strange_meat_item");
				origin = nearest_orcs;
			}

			party.getSprite("banner").setBrush(origin.getBanner());
			party.setAttackableByAI(false);
			local c = party.getController();
			local intercept = this.new("scripts/ai/world/orders/intercept_order");
			intercept.setTarget(this.World.State.getPlayer());
			c.addOrder(intercept);
			this.m.UnitsSpawned.push(party.getID());
			return true;
		}

		return false;
	}

	function onPrepareVariables( _vars )
	{
		local days = this.getDaysRequiredToTravel(this.m.Flags.get("Distance"), this.Const.World.MovementSettings.Speed * 0.6, true);
		_vars.push([
			"objective",
			this.m.Destination == null || this.m.Destination.isNull() ? "" : this.m.Destination.getName()
		]);
		_vars.push([
			"direction",
			this.m.Destination == null || this.m.Destination.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Destination.getTile())]
		]);
		_vars.push([
			"noblehouse",
			this.World.FactionManager.getFaction(this.m.NobleHouseID).getName()
		]);
		_vars.push([
			"noble",
			this.m.Flags.get("NobleName")
		]);
		_vars.push([
			"noblesettlement",
			this.m.NobleSettlement == null || this.m.NobleSettlement.isNull() ? "" : this.m.NobleSettlement.getName()
		]);
		_vars.push([
			"nobledirection",
			this.m.NobleSettlement == null || this.m.NobleSettlement.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.NobleSettlement.getTile())]
		]);
		_vars.push([
			"killcount",
			this.m.Flags.get("HeadsCollected")
		]);
		_vars.push([
			"days",
			days <= 1 ? "a day" : days + " days"
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.World.State.setCampingAllowed(true);
			this.World.State.setEscortedEntity(null);
			this.World.State.getPlayer().setVisible(true);
			this.World.Assets.setUseProvisions(true);

			if (!this.World.State.isPaused())
			{
				this.World.setSpeedMult(1.0);
			}

			this.World.State.m.LastWorldSpeedMult = 1.0;

			if (this.m.Destination != null && !this.m.Destination.isNull())
			{
				this.m.Destination.getSprite("selection").Visible = false;
			}

			if (this.m.NobleSettlement != null && !this.m.NobleSettlement.isNull())
			{
				this.m.NobleSettlement.getSprite("selection").Visible = false;
			}
		}
	}

	function onIsValid()
	{
		if (this.m.Destination == null || this.m.Destination.isNull() || !this.m.Destination.isAlive() || !this.m.Destination.isAlliedWith(this.getFaction()))
		{
			return false;
		}

		return true;
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

		if (this.m.Caravan != null && !this.m.Caravan.isNull())
		{
			_out.writeU32(this.m.Caravan.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		_out.writeU32(this.m.NobleHouseID);
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local destination = _in.readU32();

		if (destination != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}

		local caravan = _in.readU32();

		if (caravan != 0)
		{
			this.m.Caravan = this.WeakTableRef(this.World.getEntityByID(caravan));
		}

		this.m.NobleHouseID = _in.readU32();

		if (!this.m.Flags.has("Distance"))
		{
			this.m.Flags.set("Distance", 0);
		}

		if (!this.m.Flags.has("HeadsCollected"))
		{
			this.m.Flags.set("HeadsCollected", 0);
		}

		this.contract.onDeserialize(_in);

		if (this.m.Flags.has("NobleSettlement"))
		{
			local e = this.World.getEntityByID(this.m.Flags.get("NobleSettlement"));

			if (e != null)
			{
				this.m.NobleSettlement = this.WeakTableRef(e);
			}
		}
	}

});

