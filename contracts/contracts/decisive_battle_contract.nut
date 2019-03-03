this.decisive_battle_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Warcamp = null,
		WarcampTile = null,
		Dude = null,
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

		this.m.Type = "contract.decisive_battle";
		this.m.Name = "战斗";
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

		if (this.m.WarcampTile == null)
		{
			local settlements = this.World.EntityManager.getSettlements();
			local lowest_distance = 99999;
			local best_settlement;
			local myTile = this.m.Home.getTile();

			foreach( s in settlements )
			{
				if (this.World.FactionManager.isAllied(this.getFaction(), s.getFaction()))
				{
					continue;
				}

				local d = s.getTile().getDistanceTo(myTile);

				if (d < lowest_distance)
				{
					lowest_distance = d;
					best_settlement = s;
				}
			}

			this.m.WarcampTile = myTile.getTileBetweenThisAnd(best_settlement.getTile());
			this.m.Flags.set("EnemyNobleHouse", best_settlement.getOwner().getID());
		}

		this.m.Flags.set("CommanderName", this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)]);
		this.m.Payment.Pool = 1600 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
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

		this.m.Flags.set("RequisitionCost", this.beautifyNumber(this.m.Payment.Pool * 0.25));
		this.m.Flags.set("Bribe", this.beautifyNumber(this.m.Payment.Pool * 0.35));
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"前往军营向%commander%报告",
					"在战斗中帮助军队对抗 %feudfamily%"
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
				this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse")).addPlayerRelation(-99.0, "Took sides in the war");

				if (this.Contract.m.WarcampTile == null)
				{
					local settlements = this.World.EntityManager.getSettlements();
					local lowest_distance = 99999;
					local best_settlement;
					local myTile = this.Contract.m.Home.getTile();

					foreach( s in settlements )
					{
						if (this.World.FactionManager.isAllied(this.Contract.getFaction(), s.getFaction()))
						{
							continue;
						}

						local d = s.getTile().getDistanceTo(myTile);

						if (d < lowest_distance)
						{
							lowest_distance = d;
							best_settlement = s;
						}
					}

					this.Contract.m.WarcampTile = myTile.getTileBetweenThisAnd(best_settlement.getTile());
				}

				local tile = this.Contract.getTileToSpawnLocation(this.Contract.m.WarcampTile, 1, 12, [
					this.Const.World.TerrainType.Shore,
					this.Const.World.TerrainType.Ocean,
					this.Const.World.TerrainType.Mountains,
					this.Const.World.TerrainType.Forest,
					this.Const.World.TerrainType.LeaveForest,
					this.Const.World.TerrainType.SnowyForest,
					this.Const.World.TerrainType.AutumnForest,
					this.Const.World.TerrainType.Swamp
				], true, false, true);
				tile.clear();
				this.Contract.m.WarcampTile = tile;
				this.Contract.m.Warcamp = this.WeakTableRef(this.World.spawnLocation("scripts/entity/world/locations/noble_camp_location", tile.Coords));
				this.Contract.m.Warcamp.onSpawned();
				this.Contract.m.Warcamp.getSprite("banner").setBrush(this.World.FactionManager.getFaction(this.Contract.getFaction()).getBannerSmall());
				this.Contract.m.Warcamp.setFaction(this.Contract.getFaction());
				this.Contract.m.Warcamp.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Warcamp.getTile().Pos, 500.0);
				local r = this.Math.rand(1, 100);

				if (r <= 40)
				{
					this.Flags.set("IsScoutsSighted", true);
				}
				else
				{
					this.Flags.set("IsRequisitionSupplies", true);
					r = this.Math.rand(1, 100);

					if (r <= 33)
					{
						this.Flags.set("IsAmbush", true);
					}
					else if (r <= 66)
					{
						this.Flags.set("IsUnrulyFarmers", true);
					}
					else
					{
						this.Flags.set("IsCooperativeFarmers", true);
					}
				}

				r = this.Math.rand(1, 100);

				if (r <= 40)
				{
					if (this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse")).getSettlements().len() >= 2)
					{
						this.Flags.set("IsInterceptSupplies", true);
						local myTile = this.Contract.m.Warcamp.getTile();
						local settlements = this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse")).getSettlements();
						local lowest_distance = 99999;
						local highest_distance = 0;
						local best_start;
						local best_dest;

						foreach( s in settlements )
						{
							if (s.isIsolated())
							{
								continue;
							}

							local d = s.getTile().getDistanceTo(myTile);

							if (d < lowest_distance)
							{
								lowest_distance = d;
								best_dest = s;
							}

							if (d > highest_distance)
							{
								highest_distance = d;
								best_start = s;
							}
						}

						this.Flags.set("InterceptSuppliesStart", best_start.getID());
						this.Flags.set("InterceptSuppliesDest", best_dest.getID());
					}
				}
				else if (r <= 80)
				{
					this.Flags.set("IsDeserters", true);
				}

				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"前往军营向%commander%报告"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp) && !this.Flags.get("IsWarcampDay1Shown"))
				{
					this.Flags.set("IsWarcampDay1Shown", true);
					this.Contract.setScreen("WarcampDay1");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Running_WaitForNextDay",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"在军营里待命，等待传唤"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp))
				{
					if (this.World.getTime().Days > this.Flags.get("LastDay"))
					{
						if (this.Flags.get("NextDay") == 2)
						{
							this.Contract.setScreen("WarcampDay2");
						}
						else
						{
							this.Contract.setScreen("WarcampDay3");
						}

						this.World.Contracts.showActiveContract();
					}
				}
			}

		});
		this.m.States.push({
			ID = "Running_Scouts",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"拦截最后一次在军营%direction%方向上看到的%feudfamily%侦察兵",
					"不留活口"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onCombatWithScouts.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Destination == null || this.Contract.m.Destination.isNull())
				{
					if (this.Flags.get("IsScoutsFailed"))
					{
						this.Contract.setScreen("ScoutsEscaped");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("ScoutsCaught");
						this.World.Contracts.showActiveContract();
					}
				}
				else if (this.Flags.get("IsScoutsRetreat"))
				{
					this.Flags.set("IsScoutsRetreat", false);
					this.Contract.m.Destination.die();
					this.Contract.m.Destination = null;
					this.Contract.setScreen("ScoutsEscaped");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatWithScouts( _dest, _isPlayerAttacking = true )
			{
				local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
				properties.CombatID = "Scouts";
				properties.Music = this.Const.Music.NobleTracks;
				properties.EnemyBanners = [
					this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse")).getBannerSmall()
				];
				this.World.Contracts.startScriptedCombat(properties, _isPlayerAttacking, true, true);
			}

			function onActorRetreated( _actor, _combatID )
			{
				if (_combatID == "Scouts")
				{
					this.Flags.set("IsScoutsFailed", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Scouts")
				{
					this.Flags.set("IsScoutsRetreat", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_ReturnAfterScouts",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"返回军营"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp) && !this.Flags.get("IsReportAfterScoutsShown"))
				{
					this.Flags.set("IsReportAfterScoutsShown", true);
					this.Contract.setScreen("WarcampDay1End");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Running_Requisition",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"征用军营%direction%方向上位于%objective%的物资"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Destination) && !this.TempFlags.get("IsReportAfterRequisitionShown"))
				{
					this.TempFlags.set("IsReportAfterRequisitionShown", true);
					this.Contract.setScreen("RequisitionSupplies2");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsRequisitionRetreat") && !this.Flags.get("IsRequisitionCombatDone"))
				{
					this.Flags.set("IsRequisitionCombatDone", true);
					this.Contract.setScreen("BeatenByFarmers");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsRequisitionVictory") && !this.Flags.get("IsRequisitionCombatDone"))
				{
					this.Flags.set("IsRequisitionCombatDone", true);
					this.Contract.setScreen("PoorFarmers");
					this.World.Contracts.showActiveContract();
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Ambush" || _combatID == "TakeItByForce")
				{
					this.Flags.set("IsRequisitionRetreat", true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Ambush" || _combatID == "TakeItByForce")
				{
					this.Flags.set("IsRequisitionVictory", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_ReturnAfterRequisition",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"返回军营"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp))
				{
					if (this.Flags.get("IsInterceptSupplies") || this.Flags.get("IsDeserters"))
					{
						this.Contract.setScreen("WarcampDay1End");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("WarcampDay2End");
						this.World.Contracts.showActiveContract();
					}
				}
			}

		});
		this.m.States.push({
			ID = "Running_InterceptSupplies",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"拦截%supply_start%至%supply_dest%的补给线路"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setVisibleInFogOfWar(true);
				}
			}

			function update()
			{
				if (this.Flags.get("IsInterceptSuppliesSuccess"))
				{
					this.Contract.setScreen("SuppliesIntercepted");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.m.Destination == null || this.Contract.m.Destination != null && this.Contract.m.Destination.isNull())
				{
					this.Flags.set("IsInterceptSuppliesFailure", true);
					this.Contract.setScreen("SuppliesReachedEnemy");
					this.World.Contracts.showActiveContract();
				}
			}

			function onPartyDestroyed( _party )
			{
				if (_party.getTags().has("ContractSupplies"))
				{
					this.Flags.set("IsInterceptSuppliesSuccess", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_ReturnAfterIntercept",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"返回军营"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp))
				{
					this.Contract.setScreen("WarcampDay2End");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Running_Deserters",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"跟随足迹接近逃兵",
					"说服他们回来或杀死他们"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Flags.get("IsDesertersFailed"))
				{
					if (this.Contract.m.Destination != null)
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
					}

					this.Contract.setState("Running_ReturnAfterIntercept");
				}
				else if (this.Contract.m.Destination == null || this.Contract.m.Destination != null && this.Contract.m.Destination.isNull())
				{
					this.Contract.setScreen("DesertersAftermath");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerNear(this.Contract.m.Destination, this.Const.World.CombatSettings.CombatPlayerDistance / 2) && !this.TempFlags.get("IsDeserterApproachShown"))
				{
					this.TempFlags.set("IsDeserterApproachShown", true);
					this.Contract.setScreen("Deserters2");
					this.World.Contracts.showActiveContract();
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Deserters")
				{
					this.Flags.set("IsDesertersFailed", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_FinalBattle",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"为 %noblehouse% 赢得战斗"
				];
			}

			function update()
			{
				if (this.Flags.get("IsFinalBattleLost") && !this.Flags.get("IsFinalBattleLostShown"))
				{
					this.Flags.set("IsFinalBattleLostShown", true);
					this.Contract.m.Warcamp.die();
					this.Contract.m.Warcamp = null;
					this.Contract.setScreen("BattleLost");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsFinalBattleWon") && !this.Flags.get("IsFinalBattleWonShown"))
				{
					this.Flags.set("IsFinalBattleWonShown", true);
					this.Contract.m.Warcamp.die();
					this.Contract.m.Warcamp = null;
					this.Contract.setScreen("BattleWon");
					this.World.Contracts.showActiveContract();
				}
				else if (!this.TempFlags.get("IsFinalBattleStarted"))
				{
					this.TempFlags.set("IsFinalBattleStarted", true);
					local tile = this.Contract.getTileToSpawnLocation(this.Contract.m.Warcamp.getTile(), 3, 12, [
						this.Const.World.TerrainType.Shore,
						this.Const.World.TerrainType.Ocean,
						this.Const.World.TerrainType.Mountains,
						this.Const.World.TerrainType.Forest,
						this.Const.World.TerrainType.LeaveForest,
						this.Const.World.TerrainType.SnowyForest,
						this.Const.World.TerrainType.AutumnForest,
						this.Const.World.TerrainType.Swamp,
						this.Const.World.TerrainType.Hills
					], false);
					this.World.State.getPlayer().setPos(tile.Pos);
					this.World.getCamera().moveToPos(this.World.State.getPlayer().getPos());
					local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					p.CombatID = "FinalBattle";
					p.Music = this.Const.Music.NobleTracks;
					p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
					p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
					p.Entities = [];
					p.AllyBanners = [
						this.World.Assets.getBanner(),
						this.World.FactionManager.getFaction(this.Contract.getFaction()).getBannerSmall()
					];
					p.EnemyBanners = [
						this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse")).getBannerSmall()
					];
					local allyStrength = 90;

					if (this.Flags.get("IsRequisitionFailure"))
					{
						allyStrength = allyStrength - 20;
					}

					if (this.Flags.get("IsDesertersFailed"))
					{
						allyStrength = allyStrength - 20;
					}

					this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, allyStrength * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.getFaction());
					p.Entities.push({
						ID = this.Const.EntityType.Knight,
						Variant = 0,
						Row = 2,
						Script = "scripts/entity/tactical/humans/knight",
						Faction = this.Contract.getFaction(),
						Callback = this.Contract.onCommanderPlaced.bindenv(this.Contract)
					});
					local enemyStrength = 150;

					if (this.Flags.get("IsScoutsFailed"))
					{
						enemyStrength = enemyStrength + 25;
					}

					if (this.Flags.get("IsInterceptSuppliesFailure"))
					{
						enemyStrength = enemyStrength + 25;
					}

					this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, enemyStrength * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Flags.get("EnemyNobleHouse"));
					this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Mercenaries, 60 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Flags.get("EnemyNobleHouse"));
					p.Entities.push({
						ID = this.Const.EntityType.Knight,
						Variant = 0,
						Row = 2,
						Script = "scripts/entity/tactical/humans/knight",
						Faction = this.Flags.get("EnemyNobleHouse"),
						Callback = null
					});
					this.Contract.setState("Running_FinalBattle");
					this.World.Contracts.startScriptedCombat(p, false, true, true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "FinalBattle")
				{
					this.Flags.set("IsFinalBattleLost", true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "FinalBattle")
				{
					this.Flags.set("IsFinalBattleWon", true);
				}
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"返回 " + this.Contract.m.Home.getName() + "获得报酬"
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer%把你迎了进去。他穿着盔甲，虽然他的指挥官们似乎正试图说服他其实是不用做任何实际战斗的。尽管那个男人很热情地欢迎了你，但他立刻就开始向你解释他的实际需求了。%SPEECH_ON%我们准备了结这场愚蠢的战争。我们的大军正在%direction%方向上集结。我需要你去那里与%commander%见面。他会向你解释其他事情的。如果你帮我们解决了这个问题，我保证你会满意自己的报酬的，佣兵。%SPEECH_OFF%  |  你走进了%employer%的房间，发现他正在把%feudfamily%的旗帜喂给他的狗。那些杂种恶狠狠地撕碎了它。%employer%抬头看向了你。%SPEECH_ON%啊，佣兵。很高兴你终于来了。我需要你去%direction%方向上见一见%commander%。我们正准备发起最后一战，而我相信你这样的人一定能帮上很大忙的。其他的我说不好，但我能明白地告诉你，这些战争的终末总是会非常的壮观。还有你的报酬，也会非常壮观。%SPEECH_OFF%  |  你走进了%employer%的房间，看到他正被他的将军们围在中间。他们低头看着地图，眼前是一大群代表敌人的标志物。那名贵族看向了你。%SPEECH_ON%啊，佣兵。我需要你去这里。%SPEECH_OFF%他在地图上插了一根棍子。%SPEECH_ON%并与%commander%会面。我们准备彻底了结这场战争，而你的帮助将是至关重要的。%SPEECH_OFF%你点了点头，但并没有离开。那人抬了抬眉毛，伸出了手指。%SPEECH_ON%哦是的，你也能获得大笔报酬！这点不会弄错的。%SPEECH_OFF%  |  你无法进入%employer%的房间。他的一名指挥官拿着一张地图和合约走到外面与你见面。他解释道一场大战即将来临，而他们需要你的帮助。如果你接受，则要去%direction%方向上的%commander%那里，等待进一步的指令。 |  %employer%房间外的一名守卫拦住了你。他盯着你%companyname%的徽章，直接跟你说道。%SPEECH_ON%我受命要把这个交给你。%SPEECH_OFF%他把一副卷轴拍在了你的胸口上。上面写着，一场大战即将来临，如果你想提供帮助，就去%commander%的营地等待进一步的指令。你问他是否能跟守卫或%employer%商量商量报酬方面的问题。守卫重重地咽了口气，一滴汗珠从他的脸颊处滑落。%SPEECH_ON%如果你真的想讨价还价，那就跟我来说吧。%SPEECH_OFF%  |  %employer%向了打了个招呼并把你带到外面的私人训犬师处。他走过的时候狗群顺从地坐在一边。他轻轻抚摸过这些顺从的宠物们的头。%SPEECH_ON%%commander%正带领我的人前往%direction%，他跟我报告说很可能会爆发一场大战。%SPEECH_OFF%那名贵族顿了顿，转身看向了你。%SPEECH_ON%他认为这样能终结与%feudfamily%的战争。所以我想让你去那里帮忙，去帮助他解决这场纷争。%SPEECH_OFF%  |  你与%employer%在房间中见面了，里面挤满了他的将军们。他的指挥官们疑惑地盯着你，然后他把你引到了角落中，轻轻地跟你说道。%SPEECH_ON%不用管他们。我们长话短说吧，我的一支军队在%commander%的带领下正在往%direction%方向进军。我需要你去跟他汇合然后等待进一步指示。我的指挥官们认为很快就会爆发最终决战了，我们得把握住所有的助力。如果这场战斗真的能了结这场战争，那之后我会根据你的表现给你提供相应的报酬的。%SPEECH_OFF%  |  一名守卫将你引入了%employer%的房间，进去后你看到他正被一群争吵的将军们包围着。他们彼此大喊大叫着，打乱了地图上的各种标志物，让这场军事会议变得混乱不堪。%employer%站了起来，与你进行了私下交谈。%SPEECH_ON%不用管他们。那群人这么激动是因为现在我们很可能马上就能结束与%feudfamily%的这场该死的战争了。%commander%和我的大部分军队正在%direction%方向上进行修整。他发来请求，希望能得到尽可能多的援军，包括雇佣兵。如果你能去那里提供些帮助，了结这场战争，我会给你提供相应报酬的，佣兵。%SPEECH_OFF%  |  %employer%把你带到了外面的某个猪栏处。而你发现那些猪正在吃一具尸体。而附近，一些山羊正在吃一面%feudfamily%的旗帜。%employer%转向了你，咧嘴笑道。%SPEECH_ON%那家伙是一名间谍，你应该明白这种事是怎么处理的吧。总之，%commander%向我报告说，他认为与%feudfamily%的决战即将来临。他向我请求尽可能多的帮助，而我也正计划给他派去援军。如果你能去那里，与他见面，帮上些忙，那么我就会给你提供充足的奖励。%SPEECH_OFF%  |  你与%employer%的一名守卫见了面，那名守卫将你带到了他的所在之处。他正待在某个远离喧嚣的小屋中。他正在跃动的蜡烛火焰下阅读着书籍。他并没有看你，开口道。%SPEECH_ON%你好，佣兵。我的指挥官，%commander%，向我报告说，%feudfamily%的军队正在集结。他认为我们有机会一劳永逸地结束这场战争。%SPEECH_OFF%那名贵族舔了下手指，慢慢地翻过一页书。他继续说道。%SPEECH_ON%我想让你去加入他。当然，你会获得相应的回报的，我想应该会是丰厚的报酬。%SPEECH_OFF%  |  %employer%的一名守卫将你带到了塔顶，那名贵族正在那里等你。他看向了你。%SPEECH_ON%这里的风景挺不错的吧，对吗？%SPEECH_OFF%你看了看四周。视野非常开阔，底下的人也显得非常渺小。一架驴拉的小货车正在进入%townname%塔楼，做着某种生意。你耸耸肩。%employer%点了点头。%SPEECH_ON%我看到你很喜欢这样的风景，但现在我们有事情要谈，恐怕没闲工夫继续欣赏下去了。那么，亲爱的佣兵，我们现在开始谈吧。我的一位指挥官报告说%feudfamily%的军队正在集结。他认为我们或许可以借此机会发动一场大决战结束这场战争。你明白了吗？%SPEECH_OFF%你点了点头。他继续说道。%SPEECH_ON%如果一切顺利，事后我会给你足够的报酬的。我不清楚之前你有没有做过这样的事情，佣兵，但只要你办得好，任何有理智的人都会对你慷慨解囊的。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "一场大战，你觉得呢？",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{我不会让%companyname%屈从于任何人。 |  我必须拒绝。 |  我们需要去别的地方。}",
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
			ID = "WarcampDay1",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_96.png[/img]{你到达了搭满帐篷的营地，找到了%commander%。他把你迎入帐中，里面到处都是地图，他在这堆地图中安排他的军队，以及那些%feudfamily%军队可能会出现的地方。%SPEECH_OFF%欢迎，佣兵。你来的很及时。%SPEECH_OFF%  |  %commander%的军营充斥着无聊的人。他们有的在搅拌炖肉，有的在打牌。而最能让人激动的活动是一只甲虫和蠕虫之间的战斗，不过参加战斗的两者似乎都提不起兴致。%commander%亲自欢迎了你，将你迎入了帐中，里面到处都是地图和制定计划的工具。 |  你走进了%commander%的帐篷，发现了一群不怎么热情的人。其中一人开口道。%SPEECH_ON%你可不是我们想要的姑娘。%SPEECH_OFF%其他士兵们大笑了起来。%randombrother%用怒吼回应了他们。%SPEECH_ON%我们只是刚刚享用完你们的老妈。%SPEECH_OFF%说完双方都拔出了武器。%commander%匆忙走了进来，阻止了这场纷争。他把你带进了他的帐篷中。%SPEECH_ON%很高兴你能来到这里，不过如果我们想赢得战争的话，你的人得稍稍收敛一些。%SPEECH_OFF%  |  你进入了%commander%的营地，发现他正在参加一场甲虫比赛。他们为厮打在一起的两只甲虫欢呼不已。士兵们的欢呼声越来越大。%commander%看到了你，他带你穿过人群进入了帐篷中。%SPEECH_ON%很高兴你能来这里，佣兵。我现在有些事情要交给你。%SPEECH_OFF%  |  在到达%commander%的军营后，你发现人群正在为一位骑着驴几乎全裸的女人欢呼雀跃着。女人路过之处，那些男人们很快就硬了起来。%randombrother%问你他是否也能加入其中。你也想去，所以，当然了可以了。就在那时，%commander%抓住了你。他把你带进了他的帐篷。%SPEECH_ON%相信我，你不会想去看的。%SPEECH_OFF%然而你并不是很相信他。 |  %commander%的军营把地面弄得泥泞不堪。他们砍倒了附近所有的树木，歪歪扭扭地搭建起一片小帐篷。所见之处都是帐篷。火焰照亮了路边，仿若照亮夜空的星光。\n\n 你与%commander%在他的帐篷中见了面，里面到处都是地图，还站着一些等待命令的副官。 |  军营里充斥着叮叮当当的声音。铁匠在修理装备，厨师在烧着些看起来很可怖的菜，而士兵们正在搭建他们的帐篷。你在%commander%的帐篷中与他见了面。金属的碰撞声被他副官们的争吵声所替代。他摇了摇头。%SPEECH_ON%临近大战时，他们总会这么紧张。不用管他们。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "你需要%companyname%去做什么？",
					function getResult()
					{
						if (this.Flags.get("IsScoutsSighted"))
						{
							return "ScoutsSighted";
						}
						else
						{
							return "RequisitionSupplies1";
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WarcampDay1End",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_96.png[/img]{你回到了军营，让你的手下们好好休息一下。谁知道明天会遇到什么事。 |  虽然%commander%的命令已经完成了，但明天一定还有更多事情要做。趁现在快去休息一下吧！ |  军营与你离开的时候并没有发生任何改变。你不清楚这到底是好是坏。明天一定会遇到更多的麻烦事，因此你命令%companyname%去好好休息一番。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "好好休息，我们稍后还会有事要做的。",
					function getResult()
					{
						this.Flags.set("LastDay", this.World.getTime().Days);
						this.Flags.set("NextDay", 2);
						this.Contract.setState("Running_WaitForNextDay");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ScoutsSighted",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_54.png[/img]%commander% 解释了情况。%SPEECH_ON%{我们的侦察兵已定位到对方侦察兵。不幸的是，我没有给他们配备武装所以他们已经请求了支援。敌军在这的%direction%。杀光他们然后%feudfamily%将会失去对我方行踪的掌控。 |  我的一些开拓者已经定位了部分这里%direction%的%feudfamily%的侦察兵位置。他们在四处搜查我方主力部队，但他们不会找到的，因为你将去杀光他们。明白了吗？ | %feudfamily%的侦察兵在%direction%被发现。我需要你在他们发现我们或者把过去几天得知的情报报告出去之前去杀光他们。 | 战场上，情报就是生命线。而我最近得知情报%feudfamily%的侦察兵就潜行在这的%direction%。如果我能得知他们的情报并销毁他们对我们所掌握的请把，那我们就能在战斗中获取极大的优势。}%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "战团将立即出发。",
					function getResult()
					{
						this.Contract.setState("Running_Scouts");
						return 0;
					}

				}
			],
			function start()
			{
				local playerTile = this.Contract.m.Warcamp.getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 5, 8);
				local party = this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse")).spawnEntity(tile, "Scouts", false, this.Const.World.Spawn.Noble, 60 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.getSprite("banner").setBrush(this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse")).getBannerSmall());
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
				roam.setPivot(this.Contract.m.Warcamp);
				roam.setMinRange(4);
				roam.setMaxRange(9);
				roam.setAllTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
				roam.setTerrain(this.Const.World.TerrainType.Shore, false);
				roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
				c.addOrder(roam);
			}

		});
		this.m.Screens.push({
			ID = "ScoutsEscaped",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{不幸的是，有一个以上侦察兵成功逃离战场。无论他们掌握了何种情报，现在都已落入%feudfamily%手中。 | 真他妈该死！一些侦察兵成功逃脱，毫无疑问他们将返回%feudfamily%。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Damnit!",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterScouts");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ScoutsCaught",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{所有侦察兵已被消灭。他们所获取的情报也跟他们一起死去了。这将会是接下来这场战斗的巨大优势。 | 侦察兵已死，他们所掌握的情报也不会再见天日了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "胜利！",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterScouts");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "RequisitionSupplies1",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_96.png[/img]{%commander% sighs and begins to talk.%SPEECH_ON%I don\'t mean to waste your talents, sellsword, but I need someone to go out and requisition food supplies for the army. We are running low on supplies and need all the help we can get.%SPEECH_OFF%Hey, if you\'re getting paid then it is no insult to you.  |  %commander% stuffs a dried leaf behind his lip and crosses his arms.%SPEECH_ON%Hell, I know you\'re here to fight. I know you\'re here to kill men and get paid well for doing it. But right now, my army needs to be fed and to get fed I need someone to go out there and get the food.%SPEECH_OFF%He goes to one of his maps and points down at it.%SPEECH_ON%I need you to visit these farmers and load up their food. They will be expecting you so there shouldn\'t be any problems. Consider this an easy day before the battle, yeah?%SPEECH_OFF%  |  %commander% points at a scroll laid across one of his maps. There are numbers down it, and the numbers are shrinking the lower they get down the page.%SPEECH_ON%We are running low on food supplies. We usually requisition stores by visiting the farmers %direction% of here. I need you to go down there and pick more up. They\'ll be expecting you there shouldn\'t be any problems.%SPEECH_OFF%  |  You look down at a plate with a dried loaf of bread on it. There\'s meat on the plate next to it, half-eaten, the rest taken to by the flies. A well-fed, healthy dog wags its tail in one of the corners. %commander% walks around to one of his maps.%SPEECH_ON%We\'re running very low on food stores. If my men go hungry, they won\'t fight, and if they won\'t fight then we lose!%SPEECH_OFF%You nod. The math checks out. He continues.%SPEECH_ON%We\'ve been taking food from farmers %direction% of here for some time now. I need you to go there and do the same. One of my guards will get you a list of things to get. The farmers themselves will not oppose you. They know what happens if they do.%SPEECH_OFF%  |  You see a studious man in the corner of the tent. He\'s running a dried quill pen down a scroll, shaking his head all the while. Suddenly, he rises to his feet and hands the page to %commander%. The commander nods a few times then looks at you.%SPEECH_ON%This might seem beneath some mercenaries, but I need the %companyname% to visit the farms %direction% of here and \'requisition\' the foods that they have. It will not be the first time our army has made requests of these farmers. The last time we went, they tried to resist but, well, lessons were learned. My scribe will write down everything we need. Think of it as a day shopping at the markets.%SPEECH_OFF%The commander grins wryly.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "战团将在一小时内出发。",
					function getResult()
					{
						this.Contract.setState("Running_Requisition");
						return 0;
					}

				}
			],
			function start()
			{
				local settlements = this.World.EntityManager.getSettlements();
				local lowest_distance = 99999;
				local best_location;
				local myTile = this.Contract.m.Warcamp.getTile();

				foreach( s in settlements )
				{
					foreach( l in s.getAttachedLocations() )
					{
						if (l.getTypeID() == "attached_location.wheat_fields" || l.getTypeID() == "attached_location.pig_farm")
						{
							local d = myTile.getDistanceTo(l.getTile());

							if (d < lowest_distance)
							{
								lowest_distance = d;
								best_location = l;
							}
						}
					}
				}

				best_location.setActive(true);
				this.Contract.m.Destination = this.WeakTableRef(best_location);
			}

		});
		this.m.Screens.push({
			ID = "RequisitionSupplies2",
			Title = "农场……",
			Text = "[img]gfx/ui/events/event_72.png[/img]{农舍越来越近了。一片农作物的海洋在你面前展开，风吹打着麦浪。%randombrother%用手拂过一片麦地。%randombrother%拍了拍他的肩膀。%SPEECH_ON%你想把锯蝇带到营地去吗？别碰那些东西。%SPEECH_OFF%雇佣兵把手缩回来前挠了挠肩膀。%SPEECH_ON%草泥马。老子的手爱放哪放哪，不信回去问你娘。%SPEECH_OFF%很快一来二去的对话升级成推搡，田园风光的画面也荡然无存。 |  农舍就在远处。农田伴随清爽的威风晃荡，仿佛一片平静的海浪。农场工人用大镰刀在田里收割，后面一群人用甘草叉叉起佶秆。毛驴走在最后，在坑洼的地形上拖着推车。 |  农场绵延山丘，土壤太过肥沃以至于浪费每寸土地都显得可惜。每块地都种满作物，穿过它们看到了那些农场工人、大镰刀和甘草叉，在其中上上下下。远处，你看到农场主们站在一处。他们看起来相当生气，但在%companyname%跟前却丝毫不敢表现。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们来办正事吧。",
					function getResult()
					{
						if (this.Flags.get("IsAmbush"))
						{
							return "Ambush";
						}
						else if (this.Flags.get("IsUnrulyFarmers"))
						{
							return "UnrulyFarmers";
						}
						else
						{
							return "CooperativeFarmers";
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Ambush",
			Title = "农场……",
			Text = "[img]gfx/ui/events/event_10.png[/img]{当你靠近农民时，你的一边发出一声呼喊然后窜出来一群全副武装之人。一场埋伏！ |  靠近农舍时，装满食物的推车开始向后移动。当他们散开时，后面出现了一群全副武装的人。农民很快避开。%randombrother%抽出武器。%SPEECH_ON%有埋伏！%SPEECH_OFF%  |  你靠近了食物推车。农民们在%randombrother%上前时走到旁边抽掉了马车上的油布。里面什么也没有。突然间，箭羽朝马车袭来。伴随一群全副武装的人从两边涌入，农民们急忙弯下身跑开。一场埋伏！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Ambush";
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Center;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
						local n = 0;

						do
						{
							n = this.Math.rand(1, this.Const.PlayerBanners.len());
						}
						while (n == this.World.Assets.getBannerID());

						p.Entities = [];
						p.EnemyBanners = [
							this.Const.PlayerBanners[n - 1],
							"banner_noble_11"
						];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Mercenaries, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Const.Faction.Enemy);
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.PeasantsArmed, 40 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Const.Faction.Enemy);
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "UnrulyFarmers",
			Title = "农场……",
			Text = "[img]gfx/ui/events/event_43.png[/img]你追上这群农民却只得到他们的反抗。他们的领头者交叉手臂摇了摇头。%SPEECH_ON% { 看。我的人已经装满了推车。我本乐意在来这的半路与你们会面，你知道吗？因为我跟所有其他人一样也有家人要养活，有债要偿还。你何不付我们%cost%克朗然后我们就把这些都交给%commander%。 |  你是雇佣兵，对吗？那你应该能理解人们对金钱的需要甚于其他任何。我们不过是农民，又不是印钞机。我们只想要获得自己所付出的汗水的报酬。你给我们%cost%克朗，我们会给你食物。虽然这笔买卖上我们还是亏的，但我们还能接受。 |  你光鲜亮丽地站在这里理所当然地认为我们会随意屈服。%commander%已经白拿的够多了，是时候让他为我们每个人所付出的食物偿还代价了。所以就这么着吧。我以%cost%克朗把这些食物卖给你们。我觉得那是最合理的了。} %SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "你忘了自己的身份了，农民。你想让我们动手吗？",
					function getResult()
					{
						return "TakeItByForce";
					}

				},
				{
					Text = "我理解。你应该就给我们这些补给获得%cost%克朗。",
					function getResult()
					{
						return "PayCompensation";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BeatenByFarmers",
			Title = "农场……",
			Text = "[img]gfx/ui/events/event_22.png[/img]埋伏太强了！你带着还活着的人暂时撤退。%commander%的士兵现在将需要更多口粮而%companyname%在这里被击败的消息也无疑将传播开来。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "该死的！",
					function getResult()
					{
						this.Flags.set("IsRequisitionFailure", true);
						this.Contract.setState("Running_ReturnAfterRequisition");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "PoorFarmers",
			Title = "农场……",
			Text = "[img]gfx/ui/events/event_60.png[/img]{农民们喝他们的雇佣兵被镇压了。其中一位农场工人，肠子外露地向你求饶。你摇摇头道。%SPEECH_ON%这就是人次。%SPEECH_OFF%剑轻易地刺透他的喉咙。他漱漱口，但很快就没动静了。你下令手下收集食物并准备返回到%commander%。 |  农民们和他们雇佣的埋伏被杀光只剩一个。你下令手下手机食物。%commander%和他的属下应该会很高兴看到你的回归。 |  一些事物上还沾有血迹，但用水应该就能清洗掉。 |  %commander%的士兵们将会很感激你在这完成的任务。 |  %randombrother%发现一个装死的农民并砍断了他的脖子。农民脱离雇佣兵的抓握然后蠕动着离开。他挪动到一辆马车处，将血喷得所有事物上都是。你大叫出来。%SPEECH_ON%该死，把他从那拖走！%SPEECH_OFF%农民很快被处理，但那车货显然就遭殃了。你摇摇头。%SPEECH_ON%用毯子盖上了那些食物。或许没人会注意到的。%SPEECH_OFF%  |  获取食物比你想象的要更麻烦些，但现在都得手了。你把农田所有权交给了一个可怜的农场工人。%SPEECH_ON%别忘了你主人的遭遇，因为那同样也可能发生在你身上，明白了吗？%SPEECH_OFF%孩子飞快地点着头。你下令%companyname%准备返回%commander%。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Fools.",
					function getResult()
					{
						this.Flags.set("RequisitionSuccess", true);
						this.Contract.setState("Running_ReturnAfterRequisition");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CooperativeFarmers",
			Title = "农场……",
			Text = "[img]gfx/ui/events/event_55.png[/img]{农民们热情欢迎你们。%SPEECH_ON%我猜猜， %commander% 派你们来的？%SPEECH_OFF%你点点头。农民吐了口口水点头回应。%SPEECH_ON%那好吧。不会有任何麻烦。同志们，帮他们推上路。%SPEECH_OFF%农场工人出来帮着搬运食物并准备回%commander%。 |  你见到了农民中的领袖。他和你握了握手。%SPEECH_ON%%commander%已经放消息告诉我他派了雇佣兵过来，但你的着装显然比我看过的任何战团都要光线亮丽得多。我的人会帮助你装车那样你就能早点上路了。%SPEECH_OFF%  |  等你们靠近了农民们开始装车。他们的领袖走上一步前。%SPEECH_ON% 我虽然不甘愿把食物白白送给你们，但我更不想上战场为了我毫不关心的战争白白送死。我的人会帮助你装车那样你就能早点上路了。看到%commander%，替我问声好，可以吗？我希望能继续安稳做农活。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我敢肯定 %noblehouse% 会很感激的。",
					function getResult()
					{
						this.Flags.set("RequisitionSuccess", true);
						this.Contract.setState("Running_ReturnAfterRequisition");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TakeItByForce",
			Title = "农场……",
			Text = "[img]gfx/ui/events/event_43.png[/img]{你抽出剑。农民退到后面然后后面出现一阵草叉声。他们的领袖吐了口口水然后卷起袖子。%SPEECH_ON% 该死，是想来硬的吗？那就随你。%SPEECH_OFF%  |  你摇摇头。%SPEECH_ON%休想。放弃粮食或者面对我们的愤怒。%SPEECH_OFF%农民将甘草叉在两手间手递手。他的人慢慢拾起武器。他点点头。%SPEECH_ON%我们是农民，混蛋。很早以前我们就很愤怒了。%SPEECH_OFF%  |  你不是来这里达成协议的。%SPEECH_ON%不会有补偿的。%commander%拍我们来这……%SPEECH_OFF%农民笑着打断道。%SPEECH_ON%指挥官派了些宠物狗。好吧我这么跟你说吧乖狗狗，让我们看看你是不是只会叫还是也会咬呢。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们得赶紧。",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "TakeItByForce";
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.Entities = [];
						p.EnemyBanners = [
							"banner_noble_11"
						];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Peasants, 80 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Const.Faction.Enemy);
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "PayCompensation",
			Title = "农场……",
			Text = "[img]gfx/ui/events/event_55.png[/img]{你无意让一些不过是为了自己生计忙活的农民流血负伤。递过钱后，你警告农民想这样交易得小心点。%SPEECH_ON%不是所有人都这么善良着乐意更你谈判。%SPEECH_OFF%农民转过头，露出肩膀上一条长伤疤。%SPEECH_ON%我非常清楚。感谢你的关心，佣兵。%SPEECH_OFF%  |  如果是有人付钱让你做这些的话你可不单是卷进了杀农民的祸端。%commander%没有那么做。你同意了农民的条件。他们的领头者跟你握了握手。%SPEECH_ON%谢谢你，佣兵。很少见有人能愿意妥协。我原以为你是个暴君，但显然你是更聪明的人。%SPEECH_OFF%  |  你并不是大老远跑到这里来屠杀一些可怜的农民的。你同意了那人的条件。他感谢你没有大老远跑到这里来屠杀一些可怜的农民。然而%randombrother%轻声说他不是大老远跑到这来……你高声呵斥让他闭嘴然后开始装车。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们赶快回军营去。",
					function getResult()
					{
						this.Flags.set("RequisitionSuccess", true);
						this.Contract.setState("Running_ReturnAfterRequisition");
						return 0;
					}

				}
			],
			function start()
			{
				this.World.Assets.addMoney(-this.Flags.get("RequisitionCost"));
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]" + this.Flags.get("RequisitionCost") + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "WarcampDay2",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_96.png[/img]{早晨的太阳撒进你的营帐，光线透过你的手掌，你摩挲着眼睛开始忍受新的一天。 |  你起床穿上靴子，把其中误以为那是它们过夜之地的蜘蛛倾倒出来。 |  营帐外，公鸡嘹亮的打鸣声告知所有人它是有多烦人。你小气地起床。 |  醒来又是新的一天。好极了。 |  你睡得跟个死人一样，醒得也是。溜进营帐的阳光是如此耀眼以至于让你无法继续入睡而帐篷布则太远了拉不上。管他呢，你会起床的。 |  早晨。新一天无数个后悔伴随着阳光到来。\n\n 一个年轻人拿着一幅卷轴站在你的营帐外。他将其打开然后艰难地阅读着。%SPEECH_ON%{长……长长官已经……呃，你最好亲自去见见他。 |  %commander%希望见你，他……他说，等等，没马？什么？听着我不识字。去见指挥官吧。 |  长官，这里有张纸让我跟你说，那个……你，呃，你应该……呃，去见指挥官。还有更多，但我要读完得花上一整天。 |  所以说是的，我其实不认字，但我觉得指挥官希望见你。 |  我们来看看，这封信……我认得这字母……那是字母“我”，剩下的句子里似乎有一大堆我不认得的词。听着，去见指挥官吧。好像他是这意思。}%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "该去拜访一下指挥官了……",
					function getResult()
					{
						if (this.Flags.get("IsInterceptSupplies"))
						{
							return "InterceptSupplies";
						}
						else
						{
							return "Deserters1";
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "InterceptSupplies",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_96.png[/img]你在%commander%的营帐中见他。他看起来相当激动。一个遮挡着自己的机灵小人站在他身侧。指挥官语速很快。%SPEECH_ON%{我有线报称一批装备正被运往%feudfamily%军营。如果我们能拦截并摧毁它，它们未来就无力一战了！ |  你好，雇佣兵。我的间谍们告诉我%feudfamily%正有一大批急需的装备在运往营地。我需要你去毁掉它。 |  间谍是不是很棒？看这个小家伙。他告诉我，长官，%feudfamily%有一大批货物在运输回营地。武器、装备、食物，等等。我得说，我有个正好能利用这点优势的人选：那就是你！去找到这批货物然后毁掉它。 |  战争的胜负总是在开始之前就决定了，你知道的，对吧？我这的小间谍告诉我%feudfamily%有一批武器和护甲运进来。如果你能解决掉这批货，那他们的军队就会更手足无措。 |  你知道我曾经连剑斗没怎么举就赢得战争胜利的事迹吗？我成功拦截拦截了地方的一批物资导致敌人完全无法作战，所以他们就投降了。我的小间谍告诉我%feudfamily%也有一批相似的货正在运进来。虽然肯定不足以立即终结战斗，但如果你能去清除掉它那将会是一个大优势。 |  你可知道没有装备的军队犹如无米巧妇？%feudfamily%的军队补己不足。事实上，他们还没攻击的原因就是因为他们在等待更多武器装备运达！你猜怎么着，我这的小间谍发现了那批货。而我要你去毁掉它。 |  我收到了最棒的消息，佣兵。%feudfamily%正等待着武器和装甲——我们则知道那批货正在何处。我需要你去做些显而易见的事：销毁这批货然后让敌人有知觉前削弱他们。}%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "战团将立即出发。",
					function getResult()
					{
						this.Contract.setState("Running_InterceptSupplies");
						return 0;
					}

				}
			],
			function start()
			{
				local startTile = this.World.getEntityByID(this.Flags.get("InterceptSuppliesStart")).getTile();
				local destTile = this.World.getEntityByID(this.Flags.get("InterceptSuppliesDest")).getTile();
				local enemyFaction = this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse"));
				local party = enemyFaction.spawnEntity(startTile, "Supply Caravan", false, this.Const.World.Spawn.NobleCaravan, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.getSprite("base").Visible = false;
				party.getSprite("banner").setBrush(this.World.FactionManager.getFaction(this.Flags.get("EnemyNobleHouse")).getBannerSmall());
				party.setMirrored(true);
				party.setVisibleInFogOfWar(true);
				party.setImportant(true);
				party.setDiscovered(true);
				party.setDescription("A caravan with armed escorts transporting provisions, supplies and equipment between settlements.");
				party.setAttackableByAI(false);
				party.getTags().add("ContractSupplies");
				this.Contract.m.Destination = this.WeakTableRef(party);
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

				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local move = this.new("scripts/ai/world/orders/move_order");
				move.setDestination(destTile);
				move.setRoadsOnly(true);
				local despawn = this.new("scripts/ai/world/orders/despawn_order");
				c.addOrder(move);
				c.addOrder(despawn);
			}

		});
		this.m.Screens.push({
			ID = "SuppliesReachedEnemy",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_55.png[/img]{你未能消灭运输队。显然，其所有货物都运达了%feudfamily%的军营使得接下来的战斗变得更加困难。 |  运输队未被消灭。你几乎可以确信%feudfamily%的军队将会在之后的大战中严阵以待。 |  好吧，该死。运输队未被消灭。现在，%feudfamily%的军队将会全副武装地迎接接下来的战斗了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们该返回营地了……",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SuppliesIntercepted",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_60.png[/img]{你原打算或许能从运输队那把能打劫的全都打劫了，但守卫在你能这样做之前放火烧了所有东西。不幸的是，最重要的就是%feudfamily%的军队是得不到这批补给了。 | 　你毁掉了大多数运输队，其余的也由敌方守卫毁掉以防落入你手。%commander%会对这样的结果很满意。\\　是场硬仗，但你成功击杀了运输队守卫。不幸的是，部队似乎预先部署了焦土政策，他们在被捕之前就销毁了所有马车。不幸的是，他们很清楚不要让这批货落入敌人手中。不过%commander%会对此结果很满意的。\\　运输队守卫英勇反抗，即便如此，%companyname%还是把他们一一屠尽。或者这只是你个人的想法：战斗中，其中一名守卫成功逃脱并用了一些焦土。所有马车都被点燃了。很显然，如果%feudfamily%得不到这批装备，他也不会让任何人得到。虽让人不悦但显然机智。不过，%commander%和他的部下得知此消息会很开心的。\\　运输队被浪费掉了。你源希望夺取马车并自己占有这批装备，但其中一名守卫烧光了它们，以防落入他人之手。不管怎样，%feudfamily%的军队都被大大削弱了。｝",
			Image = "",
			List = [],
			Options = [
				{
					Text = "这应该会对接下来的战斗有益。",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Deserters1",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_96.png[/img]{你进入%commander%的营帐及时发现面前飞舞的蜡烛。你看到随着一张桌子倾覆灯芯也在泥土中熄灭，桌面上的地图全都纷飞在空中。一位面红耳赤的%commander%站在凶杀案前，手捂嘴唇，沉重呼吸着让自己回神一些。他解释到。%SPEECH_ON%逃兵！他们逃了！在我这辈子最重要的战斗前夜，我连自己的士兵都留不住。看啊，我都不能让这支军队上下一心。我要你去找出那些逃兵并把他们带来见我。如果他们补回来，就杀光他们。其中一个哨兵说他看到他们往%direction%去了。现在赶快！%SPEECH_OFF%  |  正当你要进入%commander%营帐时，一个人飞到你面前。%commander%从营帐中径直走出将他一掌拍在泥中。指挥官抓像抓娃娃一样提起他的衣领。%SPEECH_ON%他们去哪了？我以旧神致命起誓如果你敢对我撒谎我会让你苦着求我杀死你！%SPEECH_OFF%这个士兵苦着指向一遍。%SPEECH_ON%%direction%！他们往那边去了，我发誓！%SPEECH_OFF%%commander%扔下士兵，后者迅速被一对守卫拖走。指挥官昂首而立，抬起一只手拂过发梢。%SPEECH_ON%佣兵，我的一些士兵竟认为做逃兵是现在最好的选择。找到他们。把他们带回来。明白了吗？%SPEECH_OFF%你点点头，询问了如果那些人拒绝回来怎么处置。指挥官耸耸肩。%SPEECH_ON%当然是杀了他们。%SPEECH_OFF%  |  你进入%commander%营帐却发现他走离一个坐着的男人。指挥官手握钳子，尖头中有颗白牙夹在其中。你注意到坐着的男人已经混过去了，头斜靠着，血从口中流出。%commander%把钳子扔到桌上，涨红的手拂过发梢开口道。%SPEECH_ON%我的一些士兵叛逃了。我不能冒险让这只军队现在崩溃，尤其是在这个大战将即的节点。我这的小朋友，刚还能说话这会儿，告诉我他的同胞跑到%direction%去了。去，佣兵，把那些逃兵给我带回来见我。%SPEECH_OFF%在你动身之前，你询问了如果逃兵们拒绝返回怎么处置。指挥官盯着你。%SPEECH_ON%你说呢？当然是杀光了！%SPEECH_OFF%  |  你发现%commander%在地图前沉思。他的指关节作桌子，晃动着腿呻吟着。他抬头看向你。他眼神闪烁，闪过一阵难以置信的愤怒。%SPEECH_ON%我的一些士兵竟然选择了叛逃。哨兵告诉我他们看到逃兵往%direction%去了。去把他们带回来。%SPEECH_OFF%你询问是否需要活捉。他点点头。%SPEECH_ON%我要你健健康康把他们带回来那样我就更更好地让他们知道在我的军队里叛逃会有怎样的下场。当然了，如果他们坚决不返回那就杀了他们。那也是对没叛逃的人的提醒，你同意吗？%SPEECH_OFF%  |  %commander%的一位中尉被绑在其中一根营柱上。%commander%手持长棍并用它来猛击中尉的胸膛和腿。男人喊叫着，转过身去却只让自己的背部也遭受同样毒打。当中尉转过来，他发紫的脸上近乎失去意识。\n\n %commander%丢下他的棍子开始把碎片拉出指甲。%SPEECH_ON%很高兴你来了，佣兵。我的一些士兵叛逃了，我需要你去找到他们。把他们活着带来，如果他们拒绝就地格杀。这里的这位朋友告诉我他们往%direction%跑了。我希望他是在说实话。%SPEECH_OFF%你也希望他说的是实话。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "战团将在一小时内出发。",
					function getResult()
					{
						this.Contract.setState("Running_Deserters");
						return 0;
					}

				}
			],
			function start()
			{
				local playerTile = this.World.State.getPlayer().getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 5, 10, [
					this.Const.World.TerrainType.Shore,
					this.Const.World.TerrainType.Mountains
				]);
				local party = this.World.FactionManager.getFaction(this.Contract.getFaction()).spawnEntity(tile, "Deserters", false, this.Const.World.Spawn.Noble, 80 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.getSprite("banner").setBrush("banner_deserters");
				party.setAttackableByAI(false);
				party.getController().getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				party.setFootprintSizeOverride(0.75);
				this.Contract.addFootPrintsFromTo(playerTile, party.getTile(), this.Const.GenericFootprints, 0.75);
				this.Contract.m.Destination = this.WeakTableRef(party);
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

				local c = party.getController();
				local wait = this.new("scripts/ai/world/orders/wait_order");
				wait.setTime(9000.0);
				c.addOrder(wait);
			}

		});
		this.m.Screens.push({
			ID = "Deserters2",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_88.png[/img]{你遇见了那些逃兵，他们围坐在闷烧的营火前，其中一个正绝望地踢着煤灰。看到你时他停了下来。其余逃兵随着他的视线注意到你，然后跳了起来。%SPEECH_ON%我们是不会回去的。你可以让%commander%去死了。%SPEECH_OFF%  |  逃兵们在你闯入他们的逃亡派对之前正在相互争论。其中一个人跳起来。%SPEECH_ON%%commander%派你来的，是吗？那么，你可以让他去死了。%SPEECH_OFF%另一个人挥舞拳头道。%SPEECH_ON%是啊，我们是不会回去的！%SPEECH_OFF%他们显然是群不守规矩的人。 |  %randombrother%指着站在路标旁的一群人。他们正在大声争吵着什么，然后听到了你靠近。你发出一阵刺耳的口哨，让那些人安静然后转过身来。。后面一个人暴跳道。%SPEECH_ON%那个该死的指挥官派雇佣兵来抓我们了？%SPEECH_OFF%你点点头并表示他们应该跟你回去。另一个逃兵摇摇头。%SPEECH_ON%回去？你怎么不回去，赶紧从这滚回去？我们是不会回去的，所以你回去告诉指挥官。%SPEECH_OFF%  |  逃兵被发现在分一个羊毛袋中的食物。他们看到你之后停了下来，其中一个选择把食物整个吞下。他噎着了。剩下的人都没动。噎着的那个人滚成一团求救，他的脸色开始发紫。他的脚夹住羊毛袋，把食物踢得到处都是。你点点头。%SPEECH_ON%帮帮你的人。%SPEECH_OFF%逃兵们很快跑向那个噎着的人把他喉咙里的食物弄了出来。他大喘着气。你开始解释%commander%让你做的事，但被其中一个逃兵打断。%SPEECH_ON%不。我们是不会回去的。这场战争就是送死，我们可不想参与。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "你就想成为这样的人吗？连自己的土地都不守护的懦夫？",
					function getResult()
					{
						return this.Math.rand(1, 100) <= 50 ? "DesertersAcceptMotivation" : "DesertersRefuseMotivation";
					}

				},
				{
					Text = "你们的选择很简单。为自己的主将作战，要么死在这里。",
					function getResult()
					{
						return this.Math.rand(1, 100) <= 50 ? "DesertersAcceptThreats" : "DesertersRefuseThreats";
					}

				},
				{
					Text = "我们就挑明了吧。如果你们回去这里有%bribe%克朗给你们。",
					function getResult()
					{
						return "DesertersAcceptBribe";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "DesertersAcceptBribe",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_88.png[/img]{你拿出一个袋子并放了%bribe%克朗进去。%SPEECH_ON%我将个人支付你们这些钱，知道你们跟我回到军营。%commander%对你暴跳如雷，让你别再犯错了，但他需要每个能上战场的人。如果你们在接下来的战斗中为他效力，我敢确信他会赦免你们所犯下的这次错误。%SPEECH_OFF%  |  你给予逃兵%bribe%克朗。逃兵们互相望着彼此，然后对你说道。%SPEECH_ON%等指挥官把我们都绞死了钱又有什么用呢？%SPEECH_OFF%你点点头回答道。%SPEECH_OFF%这个问题提的好，但%commander%不是傻子。接下来这场战斗他需要所有能够集结的力量。在战斗中证明你自己，这点小钱你们很快就会遗忘了。%SPEECH_OFF%} {逃兵们考虑着自己的选择并最终同意跟你回去。 |  逃兵挤作一团并出现了意见分歧。他们中的领袖挤出人群走向前。%SPEECH_ON%虽然有一些反对意见，我们最终还是同意跟你回军营。希望我不要为此后悔。%SPEECH_OFF%  |  短暂争论了一小会儿时间后，逃兵们决定投票表决。虽然并不是全体一致，但他们还是达成统一：他们会跟你回%commander%那。 |  逃兵们争论接下来怎么做。最终还是决定投票表决。可以预见，投票将会是平局。士兵们然后统一掷硬币：头朝上他们就回军营，字朝上就走。他们的领袖弹了硬币然后士兵们看着它旋转、闪耀。头朝上。他们中每个人看到之后都一阵叹气，仿佛机会和财富让他们如释重负。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "这应该会对接下来的战斗有益。",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				}
			],
			function start()
			{
				this.World.Assets.addMoney(-this.Flags.get("Bribe"));
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]" + this.Flags.get("Bribe") + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "DesertersAcceptThreats",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_88.png[/img]{%bigdog% 向前走了一步, 在肩周轻松地挥舞着手中的武器。他点了点头。%SPEECH_ON%你们害怕%commander%。我懂得。你懂他的为人，你懂他的脾气，你懂他能干出点什么来。问题是……%SPEECH_OFF%佣兵狞笑气力啊，恶毒的微笑反射在了寒光刀刃之上。%SPEECH_ON%你们懂我妈？%SPEECH_OFF%  |  逃兵正准备离开时%bigdog%响亮地吹了一声口哨。%SPEECH_ON%嘿，狗屎东西们，我的指挥官给了你们一个命令。%SPEECH_OFF%一个逃兵嗤之以鼻。%SPEECH_ON%是嘛？他不是我们的指挥官所以你可以直接拿了那条命令滚了。%SPEECH_OFF%%bigdog%拔出了一柄巨剑掷在了地上。他把手放在了剑柄上面。%SPEECH_ON%你害怕%commander%，人之长情。但是你继续这要瞎搞的话，朋友，我们就要来看看你们到底该害怕哪个指挥官了。%SPEECH_OFF%  |  逃兵们转身离开。%bigdog%拿出了一柄巨剑，敲击着自己的盔甲。慢慢的，逃兵们转过了身。%bigdog%微笑气力啊。%SPEECH_ON%你们有人吓尿过裤子吗？%SPEECH_OFF%其中一个逃兵摇了摇头。%SPEECH_ON%嘿、老兄，别瞎逼逼了。%SPEECH_OFF%%bigdog%抓起了宝剑剑尖直指逃兵。%SPEECH_ON%哦，你是想要我闭嘴吗？继续那么跟我说话，很快这里就没有能够说话的人了。%SPEECH_OFF%}{逃兵们思索着自己的选择并最终决定跟你回去。 |  逃兵挤作一团并出现了意见分歧。他们中的领袖挤出人群走向前。%SPEECH_ON%虽然有一些反对意见，我们最终还是同意跟你回军营。希望我不要为此后悔。%SPEECH_OFF%  |  短暂争论了一小会儿时间后，逃兵们决定投票表决。虽然并不是全体一致，但他们还是达成统一：他们会跟你回%commander%那。 |  逃兵们争论接下来怎么做。最终还是决定投票表决。可以预见，投票将会是平局。士兵们然后统一掷硬币：头朝上他们就回军营，字朝上就走。他们的领袖弹了硬币然后士兵们看着它旋转、闪耀。头朝上。他们中每个人看到之后都一阵叹气，仿佛机会和财富让他们如释重负。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你们做出了正确的决定。",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						this.Contract.m.Dude = null;
						this.Contract.setState("Running_ReturnAfterIntercept");
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
					if (bro.getSkills().hasSkill("trait.bloodthirsty") || bro.getSkills().hasSkill("trait.brute") || bro.getBackground().getID() == "background.raider" || bro.getBackground().getID() == "background.sellsword" || bro.getBackground().getID() == "background.hedge_knight" || bro.getBackground().getID() == "background.brawler")
					{
						candidates.push(bro);
					}
				}

				if (candidates.len() == 0)
				{
					candidates = brothers;
				}

				this.Contract.m.Dude = candidates[this.Math.rand(0, candidates.len() - 1)];
				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "DesertersAcceptMotivation",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_88.png[/img]{当逃兵们开始转身离开时, %motivator% 向前走了一步，清了清嗓子.%SPEECH_ON%所以事情就要这样子了吗？你们要像一群软斜支撑一样甩开你们的责任吗？我知道你们是怎么想的。我知道你们觉得没有理由要为了一些狗眼看人低的贵族在这场战争中去冒生命危险。那很正常。但是多年以后的某一天，你们将孙子抱在膝盖上玩耍的时候，他会问你你参加过的战争的故事的。然后你就只能对那个小男孩撒谎。%SPEECH_OFF%  |  %motivator%将手指放在嘴唇上然后吹起了一声尖锐的口哨。他开始说话的时候逃兵们转向了他。%SPEECH_ON%所以就这样那个了吗？你要故意让自己背负这些东西？等你的孩子们长大了之后你要怎么跟他们说？你是一个让你的战友们为你而死的垃圾逃兵吗？不要搞错了，你们的失踪绝对会让本不该死的人命丧战场的。你们的离开会造成超乎你们想象的影响！%SPEECH_OFF%  |  %motivator%叫喊着逃兵们。%SPEECH_ON%好吧，你们现在离开了。扔下你的战旗，说战争对于你来说已经结束了。那么等%feudfamily%赢了的时候会发生什么？%SPEECH_OFF%其中一个逃兵耸了耸肩。%SPEECH_ON%他们又不认识我。我要回家去种田。%SPEECH_OFF%%motivator%笑着摇了摇头。%SPEECH_ON%是那样吗？那么等这些歪果仁到你的农田时你会做什么？等他们看见你的妻子时？等他们看见你的孩子时？你觉得这场战争是为了什么？你们不会有可以回的家了，蠢货！%SPEECH_OFF%}{逃兵们仔细思考了自己的选择然后决定和你回去。 |  逃兵挤作一团并出现了意见分歧。他们中的领袖挤出人群走向前。%SPEECH_ON%虽然有一些反对意见，我们最终还是同意跟你回军营。希望我不要为此后悔。%SPEECH_OFF%  |  短暂争论了一小会儿时间后，逃兵们决定投票表决。虽然并不是全体一致，但他们还是达成统一：他们会跟你回%commander%那。 |  逃兵们争论接下来怎么做。最终还是决定投票表决。可以预见，投票将会是平局。士兵们然后统一掷硬币：头朝上他们就回军营，字朝上就走。他们的领袖弹了硬币然后士兵们看着它旋转、闪耀。头朝上。他们中每个人看到之后都一阵叹气，仿佛机会和财富让他们如释重负。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你们做出了正确的决定。",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						this.Contract.m.Dude = null;
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				}
			],
			function start()
			{
				local brothers = this.World.getPlayerRoster().getAll();
				local highest_bravery = 0;
				local best;

				foreach( bro in brothers )
				{
					if (bro.getCurrentProperties().getBravery() > highest_bravery)
					{
						best = bro;
					}
				}

				this.Contract.m.Dude = best;
				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "DesertersRefuseThreats",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_88.png[/img]{%bigdog% 向前走了一步, 在肩周轻松地挥舞着手中的武器。他点了点头。%SPEECH_ON%你们害怕%commander%。我懂得。你懂他的为人，你懂他的脾气，你懂他能干出点什么来。问题是……%SPEECH_OFF%佣兵狞笑气力啊，恶毒的微笑反射在了寒光刀刃之上。%SPEECH_ON%你们懂我妈？%SPEECH_OFF%  |  逃兵正准备离开时%bigdog%响亮地吹了一声口哨。%SPEECH_ON%嘿，狗屎东西们，我的指挥官给了你们一个命令。%SPEECH_OFF%一个逃兵嗤之以鼻。%SPEECH_ON%是嘛？他不是我们的指挥官所以你可以直接拿了那条命令滚了。%SPEECH_OFF%%bigdog%拔出了一柄巨剑掷在了地上。他把手放在了剑柄上面。%SPEECH_ON%你害怕%commander%，人之长情。但是你继续这要瞎搞的话，朋友，我们就要来看看你们到底该害怕哪个指挥官了。%SPEECH_OFF%  |  逃兵们转身离开。%bigdog%拿出了一柄巨剑，敲击着自己的盔甲。慢慢的，逃兵们转过了身。%bigdog%微笑气力啊。%SPEECH_ON%你们有人吓尿过裤子吗？%SPEECH_OFF%其中一个逃兵摇了摇头。%SPEECH_ON%嘿、老兄，别瞎逼逼了。%SPEECH_OFF%%bigdog%抓起了宝剑剑尖直指逃兵。%SPEECH_ON%哦，你是想要我闭嘴吗？继续那么跟我说话，很快这里就没有能够说话的人了。%SPEECH_OFF%}{逃兵们没办法达成一致意见于是决定投票。继续逃跑的意见占了大多数。他们的首领通知了你这个明主决定，向你道了别。%commander%不会开心的，但是你拔出了你的剑，告诉了大伙这些人只有另外一条路可以走了。头领转过了身，拔出了剑然后点了点头。%SPEECH_ON%好吧，我就在想你不是跑这么多路来跟我们说再见的。拿起武器，兄弟们。%SPEECH_OFF%  | %commander%肯定会讨厌这结果，但是逃兵们拒绝回去。他们看不到有任何让他们重回地狱的理由。你祝福了他们的头领。他感谢了你，但是在你拔出自己的武器时很快沉默了起来，%companyname%其他人也这样做了。头领叹了一口气。%SPEECH_ON%好吧，我就觉得会是这样的。%SPEECH_OFF%你点了点头。%SPEECH_ON%公事公办。我不关心你做了什么，但是这是公事，而且我们要完成自己的工作。%SPEECH_OFF%  |  逃兵们没办法自己决定于是转而去相信命运了：他们的头领拿出了一枚硬币，抛向半空。正面朝上回营地，正面朝下继续走。背面朝上。逃兵们不约而同地叹了一口气。他们的头领拍了拍你的肩膀。%SPEECH_ON%命运女神已经下了判决。%SPEECH_OFF%你点了点头，抽出了剑，战团其他人照做了。%SPEECH_ON%当我们在杀你的时候记住。%SPEECH_OFF%头领拔剑的时候微微笑了一下。%SPEECH_ON%没事的。我们宁愿死在自由的门槛上也不要再回那绞肉机去。%SPEECH_OFF%  |  头领礼貌拒绝了返回的提议。%SPEECH_ON%我们不是随便选择了这条道路，佣兵。我们不会回去的。%SPEECH_OFF%你命令%companyname%拔出武器。逃兵的头领叹了一口气，但是理解地点了点头。%SPEECH_ON%我猜应该就这样了。我们已经讨论过这事情，我们已经准备好死在这里了，死在自己的手上也比因为某个畜生的命令而死要好的多。现在我们想的就是这个。%SPEECH_OFF%耸了耸肩，你回答了。%SPEECH_ON%只是公事公办而已。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "来解决这事情吧……",
					function getResult()
					{
						this.Contract.m.Dude = null;
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "Deserters";
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.TemporaryEnemies = [
							this.Contract.getFaction()
						];
						p.AllyBanners = [
							this.World.Assets.getBanner()
						];
						p.EnemyBanners = [
							"banner_deserters"
						];
						this.World.Contracts.startScriptedCombat(p, false, true, true);
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
					if (bro.getSkills().hasSkill("trait.bloodthirsty") || bro.getSkills().hasSkill("trait.brute") || bro.getBackground().getID() == "background.raider" || bro.getBackground().getID() == "background.sellsword" || bro.getBackground().getID() == "background.hedge_knight" || bro.getBackground().getID() == "background.brawler")
					{
						candidates.push(bro);
					}
				}

				if (candidates.len() == 0)
				{
					candidates = brothers;
				}

				this.Contract.m.Dude = candidates[this.Math.rand(0, candidates.len() - 1)];
				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "DesertersRefuseMotivation",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_88.png[/img]{当逃兵们开始转身离开时, %motivator% 向前走了一步，清了清嗓子.%SPEECH_ON%所以事情就要这样子了吗？你们要像一群软斜支撑一样甩开你们的责任吗？我知道你们是怎么想的。我知道你们觉得没有理由要为了一些狗眼看人低的贵族在这场战争中去冒生命危险。那很正常。但是多年以后的某一天，你们将孙子抱在膝盖上玩耍的时候，他会问你你参加过的战争的故事的。然后你就只能对那个小男孩撒谎。%SPEECH_OFF%  |  %motivator%将手指放在嘴唇上然后吹起了一声尖锐的口哨。他开始说话的时候逃兵们转向了他。%SPEECH_ON%所以就这样那个了吗？你要故意让自己背负这些东西？等你的孩子们长大了之后你要怎么跟他们说？你是一个让你的战友们为你而死的垃圾逃兵吗？不要搞错了，你们的失踪绝对会让本不该死的人命丧战场的。你们的离开会造成超乎你们想象的影响！%SPEECH_OFF%  |  %motivator%叫喊着逃兵们。%SPEECH_ON%好吧，你们现在离开了。扔下你的战旗，说战争对于你来说已经结束了。那么等%feudfamily%赢了的时候会发生什么？%SPEECH_OFF%其中一个逃兵耸了耸肩。%SPEECH_ON%他们又不认识我。我要回家去种田。%SPEECH_OFF%%motivator%笑着摇了摇头。%SPEECH_ON%是那样吗？那么等这些歪果仁到你的农田时你会做什么？等他们看见你的妻子时？等他们看见你的孩子时？你觉得这场战争是为了什么？你们不会有可以回的家了，蠢货！%SPEECH_OFF%}{逃兵们没办法达成一致意见，于是决定投票。继续逃跑的意见占了大多数。他们的首领通知了你这个明主决定，向你道了别。%commander%不会开心的，但是你拔出了你的剑，告诉了大伙这些人只有另外一条路可以走了。头领转过了身，拔出了剑然后点了点头。%SPEECH_ON%好吧，我就在想你不是跑这么多路来跟我们说再见的。拿起武器，兄弟们。%SPEECH_OFF%  | %commander%肯定会讨厌这结果，但是逃兵们拒绝回去。他们看不到有任何让他们重回地狱的理由。你祝福了他们的头领。他感谢了你，但是在你拔出自己的武器时很快沉默了起来，%companyname%其他人也这样做了。头领叹了一口气。%SPEECH_ON%好吧，我就觉得会是这样的。%SPEECH_OFF%你点了点头。%SPEECH_ON%公事公办。我不关心你做了什么，但是这是公事，而且我们要完成自己的工作。%SPEECH_OFF%  |  逃兵们没办法自己决定于是转而去相信命运了：他们的头领拿出了一枚硬币，抛向半空。正面朝上回营地，正面朝下继续走。背面朝上。逃兵们不约而同地叹了一口气。他们的头领拍了拍你的肩膀。%SPEECH_ON%命运女神已经下了判决。%SPEECH_OFF%你点了点头，抽出了剑，战团其他人照做了。%SPEECH_ON%当我们在杀你的时候记住。%SPEECH_OFF%头领拔剑的时候微微笑了一下。%SPEECH_ON%没事的。我们宁愿死在自由的门槛上也不要再回那绞肉机去。%SPEECH_OFF%  |  头领礼貌拒绝了返回的提议。%SPEECH_ON%我们不是随便选择了这条道路，佣兵。我们不会回去的。%SPEECH_OFF%你命令%companyname%拔出武器。逃兵的头领叹了一口气，但是理解地点了点头。%SPEECH_ON%我猜应该就这样了。我们已经讨论过这事情，我们已经准备好死在这里了，死在自己的手上也比因为某个畜生的命令而死要好的多。现在我们想的就是这个。%SPEECH_OFF%耸了耸肩，你回答了。%SPEECH_ON%只是公事公办而已。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "来解决这事情吧……",
					function getResult()
					{
						this.Contract.m.Dude = null;
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "Deserters";
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.TemporaryEnemies = [
							this.Contract.getFaction()
						];
						p.AllyBanners = [
							this.World.Assets.getBanner()
						];
						p.EnemyBanners = [
							"banner_deserters"
						];
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
				local brothers = this.World.getPlayerRoster().getAll();
				local highest_bravery = 0;
				local best;

				foreach( bro in brothers )
				{
					if (bro.getCurrentProperties().getBravery() > highest_bravery)
					{
						best = bro;
					}
				}

				this.Contract.m.Dude = best;
				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "DesertersAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{%randombrother% 用一具尸体上的帆布清洗着他的刀刃。%SPEECH_ON%真可惜他们那样就死了。他们本来可以好好活着的。他们有过选择的。%SPEECH_OFF%你耸了耸肩然后回答了。%SPEECH_ON%他们不管怎么样都是要死的。他们只是选择了我们做处刑者而已。%SPEECH_OFF%  |  你身边都是死去的逃兵。其中一个在地上爬着，想要远离%commander%的军队。你在他身旁蹲了下来，手里拿着匕首准备了结他。他朝你笑着。%SPEECH_ON%没必要弄脏匕首了，佣兵。给我点时间。只要一点时间就好了，呃。%SPEECH_OFF%血流下了他的脸颊。他的眼睛眯了起来，盯视着虚空，慢慢地堕入了地下。你站了起来，告诉战团准备离开。 |  最后的逃兵被发现依靠着一块岩石，他的手无力地垂在身侧，像是一个乞求着的乞丐一样。血流下了他的胸膛，他的腿，在地上汇成了一个血池。他盯着它。%SPEECH_ON%我没事，谢谢你来了啊，佣兵。%SPEECH_OFF%你告诉他说他什么都没说。他盯着你，困惑着。%SPEECH_ON%你没有吗？那好吧。%SPEECH_OFF%片刻之后，他倒下了侧面，面孔僵硬在死时的面孔之上。 |  有些人垂青注定毁灭的生命的讽刺性。所有的选择与自由都已不复存在，除了对此种残忍的命运大笑之外还有什么好做？每一个逃兵死时脸上都有着绝对的沉静。 |  最后一名活着的逃兵在盯视着天空。他的一只手朝着天空伸着手。%SPEECH_ON%该死的，我就想看一个而已。%SPEECH_OFF%你问他想要看什么。他大笑着，一阵由心自发出的笑声被一阵剧痛打断了。%SPEECH_ON%鸟。哦，有一只。好大啊，好美丽。%SPEECH_OFF%他指了指，你朝天上看着。一只秃鹫在头顶盘旋着。当你低下头来时，男人已经死了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "很不幸，但是这是公事。",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WarcampDay2End",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_96.png[/img]{%commander%通知你说明天是大日子。你回到了你的帐篷，好好地休憩了一番。 | 你回去找%commander%并且告知了他这个消息。他非常温和，脑子只在思考着明天的事情：一场决定性的大战。日子过去了，你决定前去汇报，等待黎明。 | 你向%commander%汇报了，但是他几乎没有反应。他基本上是活在他的战场地图上了。%SPEECH_ON%明天见，佣兵。好好睡一觉吧。%SPEECH_OFF%  |  %commander%迎接你进了帐篷，但是看上去无视了你的报告。他全神贯注地盯着地图，正在与他的副官们讨论明天的战斗计划。你觉得好好睡一觉。 |  %commander%点了点头，接受了你的报告，但是除此以外不再关注你。一堆作战地图摊在了桌子上，他的视线都集中在了那些上面。你明白：明天是大战的日子，他有更加需要思考的事情。你决定回去睡觉。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "今晚好好休息，明天开战！",
					function getResult()
					{
						this.Flags.set("LastDay", this.World.getTime().Days);
						this.Flags.set("NextDay", 3);
						this.Contract.setState("Running_WaitForNextDay");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WarcampDay3",
			Title = "在军营……",
			Text = "[img]gfx/ui/events/event_78.png[/img]{%commander% 走在他的士兵面前。一些人脸上带着疲乏的表情，明显是晚上没有睡好。其他人还在紧张地颤抖着。他们的指挥官呼唤着他们。%SPEECH_ON%你们害怕了吗？你们忧心了吗？没关系。如果你们不这样做对的话我就要担心了。%SPEECH_OFF%零散的笑声鼓舞了气氛。他继续道。%SPEECH_ON%但是现在我要要求你们不会为了自己害怕，而是要为了你的同胞们，为了你的家庭们害怕！那些我们今天为之而战的人！让我们明天再担心自己，今天我们是男人！%SPEECH_OFF%笑成变成了如雷般的欢呼声。 |  %commander%集结起了他的人马。步兵，弓手，预备队，都纹丝不动地站着。指挥官上下打量着他们。%SPEECH_ON%我知道你们在想些什么“我为什么要为了这蠢货战斗呢。如果他这么高贵的话，他的高头大马去哪里了？”%SPEECH_OFF%士兵们笑了起来，打消了一点紧张情绪。%commander%继续说道。%SPEECH_ON%好吧，不管长得丑不丑，我最喜欢的就是一场好战斗了。那就是我将去的地方，伙计们。我会跟你们一起去，战斗到我不能再战为之，战斗到最后一口气，因为那就是一个战士该做的事情！%SPEECH_OFF%士兵们举起了他们的武器，欢呼起来。他们的指挥官转过了身，手里高举着宝剑。%SPEECH_ON%现在跟我来，我们会给%feudfamily%看看什么才是真正的男人！%SPEECH_OFF%  |  %commander%鱼龙混杂的部队集结在了一起准备大战。在战线前走来走去，指挥官开始了演说。%SPEECH_ON%有些人看上去没睡好觉。怎么回事，紧张了吗？我也是！一点点都没有睡。%SPEECH_OFF%这段话让一些人放松了点。知道自己不是一个人总归是好的，不管是血肉还是灵魂。他继续道。%SPEECH_ON%但是我为了今天，为了这场战斗醒着。我绝对不要错过这事情。所以把睡衣都擦擦掉，伙计们，今天我们要让那些%feudfamily%混蛋们知道他们应该待在床上的！%SPEECH_OFF%  |  %commander%向他准备待续的手下们致意。你一个词都没有听。你让你的人为接下来的战斗做好准别。 | 你看着%commander%去他的手下那里用鼓舞人心的话语给他们打气。许多都是你以前听过的。话说，这些台词是不是哪本旧书上的？一个世世代代都被人饮用的鼓舞人心的演讲？%randombrother%笑着过来。%SPEECH_ON%我知道那个指挥官说的都是些废话，但是我还是有种想要做一两个俯卧撑的感觉。%SPEECH_OFF%大笑着，你告诉这家伙跟其他战团一起站好。他吼了回去。%SPEECH_ON%有演讲吗？%SPEECH_OFF%他大笑了起来，你把他推了进去。 |  %commander%在战线前走来走去。他走到了一个害怕到盔甲都在颤抖的男孩子面前。%SPEECH_ON%你知道吗，孩子，你让我想到我自己了。你觉得我没有跟你一样过吗？嘻，放轻松，因为有一天你有可能变得跟我一样。%SPEECH_OFF%孩子抬起了头，眼中有了一种新的闪光。他镇定了下来，鉴定地点了点头。指挥官拉高了嗓音，朝他的手下们叫喊着，指挥者他们为生死之战做好准备。 |  %commander%在他的手下中走来走去，喊叫着说这场战斗将是他们一辈子从来没有见过的大战。你并不是很同意他的观点，但是能肯定的是这会是很多人最后见到的东西。但是，战争的残酷并不是最好的激励，所以你就闭上了自己的嘴。 | 当%commander%用激动人心的演讲向他的手下宣传贵族之间战争的重要意义时你拉紧了你的靴子。真是巧了。肯定是这样的，如果人们从战斗中什么也得不到的话还不如去死了好。 | %commander%站在了他的手下面前。他穿着华丽的战甲，站在他的手下旁边就像是砂砾中的珍珠一样。他解释说他们必须赢得这场战斗，因为输了这一场的话有可能整个战争都会输。你猜只要是能让手下投入的话他什么都能说。你自己是绝对不会因为哪个寻找着荣耀的指挥官美化了这里面的政治恶臭就为那些傻逼贵族们去死的。但话又说回来，你就是因为那个态度才开始当起佣兵来的。 |  战争非常可怕。一个人怎么把这东西推销给其他人？%commander%尽力了，在向手下演讲时讲了无数个重点。首先，他声称这是一件光荣之事。然后他声称他们有很多士兵，毫无疑问这能够提高其他蠢货而不是你死的几率。数量大就是正义！然后他声称输掉这场战斗有可能意味着失去他们的妻子，他们的孩子，他们的国家。最后几点好像最有用处，人们带着愤怒与力量怒吼着。在现在沸腾起来的士兵中间，你轻易地就发现了愤世嫉俗之人还有斜支撑。 |  %commander%用一种深沉，有力的语调向他的手下致意。%SPEECH_ON%啊，你们有些人看上去很不得了嘛、等不及去杀%feudfamily%的人了，是不是？我知道那种感觉。%SPEECH_OFF%一阵零散的紧张笑声。指挥官继续着。%SPEECH_ON%脑子里面想着你的家庭，伙计们，因为他们的一切都靠今天了！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "前进，兄弟们，我们要赢得这场战斗！",
					function getResult()
					{
						this.Contract.setState("Running_FinalBattle");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BattleLost",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_86.png[/img]{到处都是尸体。尸山上面%commander%的轮廓，盔甲闪烁着，是满地尸骸中耀眼的存在。%employer%无疑会因为战斗失利而悲伤，但也别无他法。 |  战斗失败！%commander%手下的幸存者四散分离，指挥官本人也被打倒了。秃鹫一直在上空盘旋，%feudfamily%的人平稳地穿行在尸海中，杀死每一个假死之人。你迅速召集了剩下的%companyname%撤离。%employer%无疑会被这里的结果惊吓，但现在已经没有挽救之法。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "不是每场战斗都是能取胜的……",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Lost an important battle");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BattleWon",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_87.png[/img]{你们胜利了！你和%commander%的人都是。战斗已经取胜，那才是现在最重要的事情。你踏着遍地尸骸准备返回你%employer%身边。 |  尸体堆积成山。秃鹫从尸堆里觅食。受伤的人乞求帮助。当然，在旁观者眼里，这里根本没有赢家。然而，%commander%，大笑着走来。%SPEECH_ON%{做得好，佣兵！你应该回到你的雇主身边，告诉他这里的情况。 |  好吧，如果没有佣兵。都不知道你们能不能成功。你应该回到你的雇主身边，告诉他这里的情况。}%SPEECH_OFF%  |  受伤的人在你脚边乞求。你看不出他是%commander%的人还是敌人。突然，一个矛头投射过来，穿透了男人的脑袋，让他永远停留在了斜着眼的样子。你看过去，只看到了杀手把手放在矛上，露出得意洋洋的神情。他竖起一根手指。%SPEECH_ON%你就是那个佣兵，对吗？%commander%告诉我你应该回雇主那里。是这样吗？%SPEECH_OFF%你点头。尸体堆里冒出一声呻吟。男人从背上抽出长矛，握在另一只手中。%SPEECH_ON%小崽子，滚回去！%SPEECH_OFF%  |  战斗结束，你发现战士咆哮着，剥着自己的盔甲和贴身衣物。他炫耀着自己的伤口，扭曲着它们，它们像新切的水果外壳一样张着口。他要求自己的人也这么做，转过身去让他看到后背。%SPEECH_ON%你们看，像我们这样的好战士浑身是伤，这里，这里，还有这里……%SPEECH_OFF%他指着自己正面的所有伤口，然后指着自己的背。%SPEECH_ON%但这里，没人会伤到这里。因为我们会死在冲锋的路上，而不是退缩的时刻！难道不是吗？%SPEECH_OFF%他们欢呼着，尽管有些人很虚弱，鲜血从伤口往下滑落着。你无视了这种表演，召集了%companyname%的人。你的雇主听到这里的结果肯定会很高兴，你真正在乎的就是这些。 |  战斗之后%commander%向你问好。他浸透了血液，就好像他砍掉了谁的脑袋然后在喷涌而出的血液下淋了一遍一样。他笑的时候露出一排雪白的牙齿。%SPEECH_ON%这才是我说的战斗啊。%SPEECH_OFF%你问他如果输了还会说这种话吗。他笑了。%SPEECH_ON%哦，我们都愤世嫉俗吗？不，我不打算在这里失败，如果我输了，也不打算活着见证自己的失败。%SPEECH_OFF%你点头做出了回应。%SPEECH_ON%见证自己最大的失败是很少见。和你战斗很不错，指挥官，但我现在必须要回到你雇主身边了。%SPEECH_OFF%指挥官点点头，然后转身，喊着叫人给他拿毛巾来。 |  你发现%commander%蹲坐在一个受伤的敌军士兵身上。他把匕首刺进这个可怜人的胸膛，反反复复，刮擦着盔甲。指挥官看着你。%SPEECH_ON%你怎么看，佣兵？我应该留他一命吗？%SPEECH_OFF%囚犯盯着你，他用力伸出脑袋，拼命眨眼。你感觉是“是”。你耸耸肩。%SPEECH_ON%这不是我能决定的。你看，跟你战斗很不错，但我现在必须要去你雇主那边了。%SPEECH_OFF%%commander%点点头。%SPEECH_ON%那就再见。%SPEECH_OFF%你走的时候，指挥官仍在折磨囚犯，匕首随着他反复，反复，反复的动作闪烁着。 |  你发现%commander%把匕首捅进了受伤之人的胸膛。被击倒的敌人极为痛苦，但他很快就倒下了，转瞬就瘫软在地。鲜血因为指挥官抽出匕首喷涌而出，他在裤腿上擦拭了匕首。%SPEECH_ON%对准心脏，一击毙命。谁还能有更高的要求呢？%SPEECH_OFF%你点点头，告诉指挥官你要回去找雇主拿报酬。 |  你看着%commander%和士兵们在战场上打来打去，杀死每一个被发现的受伤敌人。%randombrother%询问我们是否应该对指挥官报告。你摇摇头。%SPEECH_ON%不。我们对你的雇主报告。让这地方见鬼去吧，我们去拿报酬。%SPEECH_OFF%  |  战场上到处都是死人和找死的人。%commander%的人四处找受伤之人，看见敌人就会杀死。指挥官拍拍你的肩，血花溅到了你脸上。%SPEECH_ON%干得漂亮，佣兵。我不确定你的人能不能坚守承诺，但你确实做得很好。我想，你的雇主看见你应该很高兴。%SPEECH_OFF%  |  你四处召集%companyname%的人。%commander%走到你身边，拿着块布在擦剑，血液大块大块掉落下来。%SPEECH_ON%这么快就要走？%SPEECH_OFF%你点头。%SPEECH_ON%你的雇主才是给我们钱的人，所以我们要去找他。%SPEECH_OFF%指挥官把剑归鞘，点头回应。%SPEECH_ON%有道理。和你并肩作战很不错，佣兵。真可惜不能把你收在我麾下。我看你们这些小子们都是追着钱跑的，对吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "胜利！",
					function getResult()
					{
						local faction = this.World.FactionManager.getFaction(this.Contract.getFaction());
						local settlements = faction.getSettlements();
						local origin = settlements[this.Math.rand(0, settlements.len() - 1)];
						local party = faction.spawnEntity(this.World.State.getPlayer().getTile(), origin.getName() + " Company", true, this.Const.World.Spawn.Noble, 150);
						party.getSprite("body").setBrush(party.getSprite("body").getBrush().Name + "_" + faction.getBannerString());
						party.setDescription("Professional soldiers in service to local lords.");
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你发现%employer%烂醉如泥。他从杯沿上方盯着你看，喝酒前拿着它说话。%SPEECH_ON%啊见鬼，你回来了。%SPEECH_OFF%他吞咽时杯子掉了下来。你迅速报告了自己的成功。虽然他喝的烂醉，几近混乱，还是笑了。%SPEECH_ON%那么事情办完了。胜利属于我。这就是我想要的。我希望完成我心愿的过程中没有死太多人。%SPEECH_ON%他发出一阵大笑。他的守卫交给你一个包，引导你离开房间。 |  %employer%用一袋克朗欢迎了你。%SPEECH_ON%{胜利属于我们。谢谢你，佣兵。 |  干得真漂亮，佣兵。胜利属于我们，而我们，在某种程度上，应该感谢你。你的%reward_completion%克朗就在这里。 |  这是什么，%reward_completion%克朗？击败那支军队，让我们离结束战争更近一步的小小谢意。 |  我的小鸟告诉我你在外面做得很好，佣兵。当然，他们还告诉我%feudfamily%的军队正在撤退。我还能要求什么呢？你的%reward_completion%克朗，按照约定。}%SPEECH_OFF%  |  你发现%employer%对他的指挥官下命令。看到你之后，他立刻指着你的方向。%SPEECH_ON%看见这个人了吗？他才是办成事的人。卫兵！把%reward_completion%克朗给他。要是我能出钱让你们这些落水狗做得有他一半好就好了！%SPEECH_OFF%  |  %employer%在花园里被找到了，他正对一群女人讲笑话。你闯进了他们的小团体，浑身是血，沾满泥土。女人们喘着气走开了。%employer%大笑。%SPEECH_ON%啊，佣兵回来了！你真是个讨女人喜欢的男子啊，佣兵。我真想把哪个漂亮女人送给你，但恐怕你碰她们一下，她们的父亲就不会放过你。%SPEECH_OFF%有位女士抚着胸。%SPEECH_ON%只要他愿意，就可以碰我。%SPEECH_OFF%%employer%再次笑了。%SPEECH_ON%哦亲爱的，为你陷入麻烦的男子还不够吗？走吧，女士们，告诉我哪个卫兵，拿袋%reward_completion%克朗过来。%SPEECH_OFF%  |  你发现%employer%想要训练自己的猫摇摆。%SPEECH_ON%看看这小家伙。他都不敢看我！每次我喂他的时候，他都表现得好像渴望我一样。要是我想，就能把这小东西踢出窗外。%SPEECH_OFF%你回应了。%SPEECH_ON%它会用脚着陆。%SPEECH_OFF%贵族点点头。%SPEECH_ON%那是最讨厌的部分。%SPEECH_OFF%你的雇主拎起小猫扔出窗外。他拍拍手，然后丢给你一袋%reward_completion%克朗。%SPEECH_ON%抱歉，如果我看起来心事重重的话。你做得很好。%feudfamily%军队撤退了，现在这种日子，我也没更高的要求了。%SPEECH_OFF%  |  你发现%employer%对他某位指挥官有即兴审判。你不确定这是为什么，但指挥官的下巴抬得很高，目中无人。结束之后，他被粗暴地拉了出去。%employer%召唤你到他身边。%SPEECH_ON%{谢谢你，佣兵。胜利属于我们，我都不知道没有你帮忙的话情况会变成什么样。当然，这是%reward_completion%克朗，按照约定。 |  那人拒绝了我的命令，就是这样。而你，表现得堪为典范！你的%reward_completion%克朗，按照约定。 |  那人不愿为我而战。他说他不会对为敌方而战的异母兄弟挥剑。真蠢。你做得很好，佣兵。你的%reward_completion%克朗，按照约定。}%SPEECH_OFF%  |  你回到了%employer%那里，他在指挥官队伍的中间。%SPEECH_ON%{谢谢你，佣兵。胜利属于我们了。你的%reward_completion%克朗，按照约定。 |  战争还在继续，但因为你，结束也许不远了。敌军全部撤退，我们离永远结束这该死的战争更近一步。你的%reward_completion%是辛苦赚来的，佣兵。}%SPEECH_OFF%  |  %employer%的卫兵阻止你继续靠近。他拿着一袋%reward_completion%克朗，很快交给了你。%SPEECH_ON%我的君主告诉我你在战场上表现得很好。%SPEECH_OFF%卫兵尴尬地乱瞟。%SPEECH_ON%我、我要说的就是这些。%SPEECH_OFF%  |  %employer%欢迎你进入他没有了指挥官的战争室。%SPEECH_ON%看见你真好，佣兵。你肯定知道，%feudfamily%的军队已经在撤退了。如果没有你，谁知道我们能不能成功呢。按照约定，%reward_completion%克朗给你。%SPEECH_OFF%  |  %employer%正在喂一只高高的，模样愚蠢的鸟。你从来没见过那种比例的鸟，所以保持距离。高兴的贵族说着话，让它从手中取食。%SPEECH_ON%没什么好怕的，佣兵。你知道的，我已经听说了你的作为。%feudfamily%的军队正在撤退，所以我们离结束战争更近一步了。那边的卫兵，拿着袋子的那个，手上有你的%reward_completion%克朗。%SPEECH_OFF%你离开的时候鸟拍着翅膀发出了抗议。 |  你发现%employer%在人工池塘里闲逛。他温柔地往外舀青蛙。这种滑溜溜的小生物扭动着跳开了。%SPEECH_ON%胜利属于我们。我得说你做得很好，佣兵。我给了你一个好机会，而你确实……抓住了。%SPEECH_OFF%贵族很快站了起来，在裤子上擦擦手，你不得不鞠躬。%SPEECH_ON%那也不错，对吗？好吧，那边的卫兵拿着你的%reward_completion%克朗。%SPEECH_OFF%}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Won an important battle");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isCivilWar())
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

	function onCommanderPlaced( _entity, _tag )
	{
		_entity.setName(this.m.Flags.get("CommanderName"));
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"noblehouse",
			this.World.FactionManager.getFaction(this.getFaction()).getName()
		]);
		_vars.push([
			"feudfamily",
			this.World.FactionManager.getFaction(this.m.Flags.get("EnemyNobleHouse")).getName()
		]);
		_vars.push([
			"commander",
			this.m.Flags.get("CommanderName")
		]);
		_vars.push([
			"objective",
			this.m.Destination == null || this.m.Destination.isNull() ? "" : this.m.Destination.getName()
		]);
		_vars.push([
			"cost",
			this.m.Flags.get("RequisitionCost")
		]);
		_vars.push([
			"bribe",
			this.m.Flags.get("Bribe")
		]);

		if (this.m.Flags.get("IsInterceptSupplies"))
		{
			_vars.push([
				"supply_start",
				this.World.getEntityByID(this.m.Flags.get("InterceptSuppliesStart")).getName()
			]);
			_vars.push([
				"supply_dest",
				this.World.getEntityByID(this.m.Flags.get("InterceptSuppliesDest")).getName()
			]);
		}

		if (this.m.Dude != null)
		{
			_vars.push([
				"bigdog",
				this.m.Dude.getName()
			]);
			_vars.push([
				"motivator",
				this.m.Dude.getName()
			]);
		}

		if (this.m.Destination == null)
		{
			_vars.push([
				"direction",
				this.m.WarcampTile == null ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.WarcampTile)]
			]);
		}
		else
		{
			_vars.push([
				"direction",
				this.m.Destination == null || this.m.Destination.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Destination.getTile())]
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

			if (this.m.Warcamp != null && !this.m.Warcamp.isNull())
			{
				this.m.Warcamp.die();
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isCivilWar())
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

		if (this.m.Warcamp != null && !this.m.Warcamp.isNull())
		{
			_out.writeU32(this.m.Warcamp.getID());
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

		local warcamp = _in.readU32();

		if (warcamp != 0)
		{
			this.m.Warcamp = this.WeakTableRef(this.World.getEntityByID(warcamp));
		}

		this.contract.onDeserialize(_in);
	}

});

