this.siege_fortification_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Allies = []
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

		this.m.Type = "contract.siege_fortification";
		this.m.Name = "围攻 %objective%";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		this.m.MakeAllSpawnsResetOrdersOnContractEnd = false;
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

		this.m.Flags.set("ObjectiveName", this.m.Origin.getName());
		this.m.Flags.set("RivalHouseID", this.m.Origin.getOwner().getID());
		this.m.Flags.set("RivalHouse", this.m.Origin.getOwner().getName());
		this.m.Flags.set("WaitUntil", 0.0);
		this.m.Flags.set("CommanderName", this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)]);
		this.m.Payment.Pool = 1550 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

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
					"向%direction%的%objective% 行军 ",
					"帮助围攻"
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
				this.Contract.m.Origin.getOwner().addPlayerRelation(-99.0, "Took sides in the war");
				local r = this.Math.rand(1, 100);

				if (r <= 50)
				{
					this.Flags.set("IsTakingAction", true);
					local r = this.Math.rand(1, 100);

					if (r <= 50)
					{
						this.Flags.set("IsAssaultTheGate", true);
					}
					else if (r <= 80)
					{
						this.Flags.set("IsBurnTheCastle", true);
					}
					else
					{
						this.Flags.set("IsPlayerDecision", true);
					}
				}
				else
				{
					this.Flags.set("IsMaintainingSiege", true);
					r = this.Math.rand(1, 100);

					if (r <= 25)
					{
						this.Flags.set("IsNighttimeEncounter", true);
					}
					else
					{
						this.Flags.set("IsReliefAttack", true);
						r = this.Math.rand(1, 100);

						if (r <= 40)
						{
							this.Flags.set("IsSurrender", true);
						}
						else
						{
							this.Flags.set("IsDefendersSallyForth", true);
						}
					}
				}

				local r = this.Math.rand(1, 100);

				if (r <= 10)
				{
					if (!this.Flags.get("IsSecretPassage") && !this.Flags.get("IsSurrender"))
					{
						this.Flags.set("IsPrisoners", true);
					}
				}

				this.Contract.spawnSiege();
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
					this.Contract.m.Origin.setLastSpawnTimeToNow();
				}
			}

			function update()
			{
				if (this.Contract.isPlayerNear(this.Contract.m.Origin, 300))
				{
					this.Contract.setScreen("TheSiege");
					this.World.Contracts.showActiveContract();

					foreach( a in this.Contract.m.Allies )
					{
						local ally = this.World.getEntityByID(a);

						if (ally != null)
						{
							ally.setAttackableByAI(true);
						}
					}
				}
			}

		});
		this.m.States.push({
			ID = "Running_Wait",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"保持包围 %objective%",
					"拦截任何试图突破的人"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.m.Origin.getDistanceTo(this.World.State.getPlayer()) >= 800)
				{
					this.Contract.setScreen("TooFarAway");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Time.getVirtualTimeF() < this.Flags.get("WaitUntil"))
				{
					return;
				}

				this.Contract.m.Origin.getOwner().addPlayerRelation(-99.0, "Took sides in the war");

				foreach( i, a in this.Contract.m.Allies )
				{
					local ally = this.World.getEntityByID(a);

					if (ally == null  ||  !ally.isAlive())
					{
						this.Contract.m.Allies.remove(i);
					}
				}

				if (this.Contract.isPlayerNear(this.Contract.m.Origin, 300))
				{
					if (this.Flags.get("IsReliefAttackForced"))
					{
						if (this.World.getTime().IsDaytime)
						{
							this.Contract.setScreen("ReliefAttack");
							this.World.Contracts.showActiveContract();
						}
					}
					else if (this.Flags.get("IsSurrenderForced"))
					{
						this.Contract.setScreen("Surrender");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsDefendersSallyForthForced"))
					{
						this.Contract.setScreen("DefendersSallyForth");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsTakingAction"))
					{
						if (this.World.getTime().IsDaytime)
						{
							if (this.Flags.get("IsPlayerDecision"))
							{
								this.Contract.setScreen("TakingAction");
								this.World.Contracts.showActiveContract();
							}
							else
							{
								this.Contract.setState("Running_TakingAction");
							}
						}
					}
					else if (this.Flags.get("IsMaintainingSiege"))
					{
						this.Contract.setScreen("MaintainSiege");
						this.World.Contracts.showActiveContract();
					}
				}
			}

		});
		this.m.States.push({
			ID = "Running_TakingAction",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"参与攻击 %objective%"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.m.Origin.getDistanceTo(this.World.State.getPlayer()) >= 800)
				{
					this.Contract.setScreen("TooFarAway");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Time.getVirtualTimeF() < this.Flags.get("WaitUntil"))
				{
					return;
				}

				if (this.Flags.get("IsLost"))
				{
					this.Contract.setScreen("Failure");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsAssaultTheGate") && !this.TempFlags.get("AssaultTheGateShown"))
				{
					this.TempFlags.set("AssaultTheGateShown", true);
					this.Contract.setScreen("AssaultTheGate");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsAssaultAftermath"))
				{
					this.Contract.setScreen("AssaultAftermath");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsAssaultTheCourtyard") && !this.TempFlags.get("AssaultTheCourtyardShown"))
				{
					this.TempFlags.set("AssaultTheCourtyardShown", true);
					this.Contract.setScreen("AssaultTheCourtyard");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsBurnTheCastleAftermath"))
				{
					this.Contract.setScreen("BurnTheCastleAftermath");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsBurnTheCastle") && !this.TempFlags.get("BurnTheCastleShown"))
				{
					this.TempFlags.set("BurnTheCastleShown", true);
					this.Contract.setScreen("BurnTheCastle");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					foreach( i, a in this.Contract.m.Allies )
					{
						local ally = this.World.getEntityByID(a);

						if (ally == null  ||  !ally.isAlive())
						{
							this.Contract.m.Allies.remove(i);
						}
					}

					if (this.Contract.m.Allies.len() == 0)
					{
						this.Contract.setScreen("Failure");
						this.World.Contracts.showActiveContract();
						return;
					}
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "AssaultTheGate")
				{
					this.Flags.set("IsAssaultTheGate", false);
					this.Flags.set("IsAssaultTheCourtyard", true);
				}
				else if (_combatID == "AssaultTheCourtyard")
				{
					this.Flags.set("IsAssaultTheCourtyard", false);
					this.Flags.set("IsAssaultAftermath", true);
				}
				else if (_combatID == "BurnTheCastle")
				{
					this.Flags.set("IsBurnTheCastle", false);
					this.Flags.set("IsBurnTheCastleAftermath", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "AssaultTheGates"  ||  _combatID == "AssaultTheCourtyard"  ||  _combatID == "BurnTheCastle")
				{
					this.Flags.set("IsLost", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_NighttimeEncounter",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"保持包围 %objective%",
					"拦截任何试图突破的人"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.m.Origin.getDistanceTo(this.World.State.getPlayer()) >= 800)
				{
					this.Contract.setScreen("TooFarAway");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Time.getVirtualTimeF() < this.Flags.get("WaitUntil")  ||  this.World.getTime().IsDaytime)
				{
					return;
				}

				if (this.Flags.get("IsNighttimeEncounterLost"))
				{
					this.Contract.setScreen("Failure");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsNighttimeEncounterAfermath"))
				{
					this.Contract.setScreen("NighttimeEncounterAftermath");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsNighttimeEncounter") && !this.TempFlags.get("NighttimeEncounterShown"))
				{
					if (!this.World.getTime().IsDaytime)
					{
						this.TempFlags.set("NighttimeEncounterShown", true);
						this.Contract.setScreen("NighttimeEncounter");
						this.World.Contracts.showActiveContract();
					}
				}
				else
				{
					foreach( i, a in this.Contract.m.Allies )
					{
						local ally = this.World.getEntityByID(a);

						if (ally == null  ||  !ally.isAlive())
						{
							this.Contract.m.Allies.remove(i);
						}
					}

					if (this.Contract.m.Allies.len() == 0)
					{
						this.Contract.setScreen("Failure");
						this.World.Contracts.showActiveContract();
						return;
					}
				}
			}

			function onActorRetreated( _actor, _combatID )
			{
				if (!_actor.isPlayerControlled())
				{
					this.Flags.set("IsNighttimeEncounterLost", true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "NighttimeEncounter")
				{
					this.Flags.set("IsNighttimeEncounter", false);
					this.Flags.set("IsNighttimeEncounterAfermath", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "NighttimeEncounter")
				{
					this.Flags.set("IsNighttimeEncounterLost", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_SecretPassage",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"在夜晚结束之前潜入 %objective% ",
					"刺杀敌人的指挥官"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
					this.Contract.m.Origin.setOnCombatWithPlayerCallback(this.onSneakIn.bindenv(this));
					this.Contract.m.Origin.setAttackable(true);
				}
			}

			function end()
			{
				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.setOnCombatWithPlayerCallback(null);
					this.Contract.m.Origin.setAttackable(false);
				}
			}

			function update()
			{
				if (this.Flags.get("IsSecretPassageWin"))
				{
					this.Contract.setScreen("SecretPassageAftermath");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsSecretPassageLost"))
				{
					this.Contract.setScreen("SecretPassageFail");
					this.World.Contracts.showActiveContract();
				}
				else if (this.World.getTime().IsDaytime)
				{
					this.Contract.setScreen("FailedToReturn");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					foreach( i, a in this.Contract.m.Allies )
					{
						local ally = this.World.getEntityByID(a);

						if (ally == null  ||  !ally.isAlive())
						{
							this.Contract.m.Allies.remove(i);
						}
					}

					if (this.Contract.m.Allies.len() == 0)
					{
						this.Contract.setScreen("Failure");
						this.World.Contracts.showActiveContract();
						return;
					}
				}
			}

			function onSneakIn( _dest, _isPlayerAttacking = true )
			{
				if (!this.TempFlags.get("IsSecretPassageShown"))
				{
					this.TempFlags.set("IsSecretPassageShown", true);
					this.Contract.setScreen("SecretPassage");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					p.CombatID = "SecretPassage";
					p.Music = this.Const.Music.NobleTracks;
					p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
					p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
					this.Contract.flattenTerrain(p);
					p.Entities = [];
					p.EnemyBanners = [
						this.Contract.m.Origin.getOwner().getBannerSmall()
					];
					this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.m.Origin.getOwner().getID());
					p.Entities.push({
						ID = this.Const.EntityType.Knight,
						Variant = 0,
						Row = 2,
						Script = "scripts/entity/tactical/humans/knight",
						Faction = this.Contract.m.Origin.getOwner().getID(),
						Callback = this.onEnemyCommanderPlaced
					});
					this.World.Contracts.startScriptedCombat(p, false, true, true);
				}
			}

			function onEnemyCommanderPlaced( _entity, _tag )
			{
				_entity.getTags().set("IsFinalBoss", true);
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getTags().get("IsFinalBoss") == true)
				{
					this.Flags.set("IsSecretPassageWin", true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "SecretPassage")
				{
					this.Flags.set("IsSecretPassageWin", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "SecretPassage" && !this.Flags.get("IsSecretPassageWin"))
				{
					this.Flags.set("IsSecretPassageFail", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_ReliefAttack",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"保持包围 %objective%",
					"拦截任何试图突破的人"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.m.Origin.getDistanceTo(this.World.State.getPlayer()) >= 800)
				{
					this.Contract.setScreen("TooFarAway");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Flags.get("IsReliefAttackLost"))
				{
					this.Contract.setScreen("Failure");
					this.World.Contracts.showActiveContract();
					return;
				}

				local isAlive = false;

				foreach( id in this.Contract.m.UnitsSpawned )
				{
					local e = this.World.getEntityByID(id);

					if (e != null && e.isAlive() && e.getFaction() == this.Contract.m.Origin.getOwner().getID())
					{
						isAlive = true;

						if (e.getDistanceTo(this.Contract.m.Origin) <= 250)
						{
							this.onCombatWithPlayer(e, false);
							return;
						}
					}
				}

				if (this.Flags.get("IsReliefAttackWon")  ||  !isAlive)
				{
					this.Contract.setScreen("ReliefAttackAftermath");
					this.World.Contracts.showActiveContract();
					return;
				}

				foreach( i, a in this.Contract.m.Allies )
				{
					local ally = this.World.getEntityByID(a);

					if (ally == null  ||  !ally.isAlive())
					{
						this.Contract.m.Allies.remove(i);
					}
				}

				if (this.Contract.m.Allies.len() == 0)
				{
					this.Contract.setScreen("Failure");
					this.World.Contracts.showActiveContract();
					return;
				}
			}

			function onCombatWithPlayer( _dest, _isPlayerAttacking = true )
			{
				_dest.setPos(this.World.State.getPlayer().getPos());
				local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
				p.CombatID = "ReliefAttack";
				p.Music = this.Const.Music.NobleTracks;
				p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
				p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
				p.AllyBanners.push(this.World.FactionManager.getFaction(this.Contract.getFaction()).getBannerSmall());
				p.EnemyBanners.push(_dest.getBanner());
				this.Contract.flattenTerrain(p);

				if (_dest.getDistanceTo(this.Contract.m.Origin) <= 400)
				{
					this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.getFaction());

					foreach( id in this.Contract.m.UnitsSpawned )
					{
						local e = this.World.getEntityByID(id);

						if (e.isAlliedWithPlayer())
						{
							e.die();
							break;
						}
					}
				}

				this.World.Contracts.startScriptedCombat(p, false, true, true);
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "ReliefAttack")
				{
					this.Flags.set("IsReliefAttackWon", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "ReliefAttack")
				{
					this.Flags.set("IsReliefAttackLost", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_DefendersSallyForth",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"保持包围 %objective%",
					"拦截任何试图突破的人"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.m.Origin.getDistanceTo(this.World.State.getPlayer()) >= 800)
				{
					this.Contract.setScreen("TooFarAway");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Flags.get("IsDefendersSallyForthLost"))
				{
					this.Contract.setScreen("DefendersPrevail");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsDefendersSallyForthWon"))
				{
					this.Contract.setScreen("DefendersAftermath");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					this.Contract.m.Origin.getOwner().addPlayerRelation(-99.0, "Took sides in the war");
					this.Contract.setScreen("DefendersSallyForth");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "DefendersSallyForth")
				{
					this.Flags.set("IsDefendersSallyForthWon", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "DefendersSallyForth")
				{
					this.Flags.set("IsDefendersSallyForthLost", true);
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

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = false;
				}

				this.Contract.m.Home.getSprite("selection").Visible = true;
				this.Flags.set("WaitUntil", this.Time.getVirtualTimeF() + 5.0);
			}

			function update()
			{
				if (this.Flags.get("IsPrisoners") && this.Time.getVirtualTimeF() <= this.Flags.get("WaitUntil"))
				{
					this.Contract.setScreen("Prisoners");
					this.World.Contracts.showActiveContract();
				}

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
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer%迎接你进入他的房间。他的桌上放着一张地图。地图上有各种用来表示军队的饰品和徽章。这位贵族指着其中一个部队说道。%SPEECH_ON%我需要你到这里去和%commander%汇合。他正在对一座堡垒展开围攻，并需要你的协助展开最终突袭。完成了这个任务，你就可以领到%reward%克朗的报酬，这个数量应该不少吧？%SPEECH_OFF%  |  你进入了%employer%的战争会议室，房间里的指挥官和将军们突然各个都默不作声了。%employer%招呼你来到他的身旁。在对你打量了一番之后，那些军官这才恢复啦刚才中断的战术讨论。%employer%向你解释他目前的处境。%SPEECH_ON%我让%commander%指挥官围攻一座位于%objective%的堡垒。他需要一些人手才能展开最终的突袭，因此这里就需要你出马了。如果你可以到那里去协助他，我可以出%reward%克朗作为报酬，这个开价不错吧？%SPEECH_OFF%  |  在你进入%employer%的房间前，他突然从里面冲出来，一把抓住了你的肩膀。他拉着你走过房间，来到窗户前，一边看着庭院一边向你说话。%SPEECH_ON%我不能让我的将军们看见你。他们认为你是一个没有荣誉感的人。有的时候，只有借助一些政治手腕才能动用雇佣军。%SPEECH_OFF%你摇了摇头，然后简单地回答了一句。%SPEECH_ON%我们能和正规军一样消灭敌人。%SPEECH_OFF%贵族点了点头。%SPEECH_ON%当然了，佣兵。只是在未来，或许别人会雇用你来对付我们。这会让我的将军们夜不能寐，有些人甚至还会为此忧虑、暴怒。而我很明白这个世界的运行法则，所以我一直睡得很安稳。接下来，让我们说正事吧。我想让你到%objective%去协助%commander%指挥官对那里的堡垒发动突袭。事成之后，你会得到%reward%克朗的报酬。%SPEECH_OFF%  |  %employer%会见了你并带你去他的花园。虽然现在他的处境并不乐观，但他似乎显得很平静。他一边看着一串番茄，一边向你说道。%SPEECH_ON%战争就像是地狱。许多人会因为我说的几句话而死去。因此，我不想滥用我的权力。%SPEECH_OFF%你将手指叉在腰带上，然后回答说。%SPEECH_ON%为了我的手下们着想，我也不希望你那样做。%SPEECH_OFF%%employer%点了点头，然后抓住了其中一个番茄。在一阵用力之后，连接番茄的藤崩断了。他咬了一口番茄，似乎是在向往一个园丁的生活。%SPEECH_ON%我有一位名叫%commander%的指挥官目前正在围攻%objective%。他即将对目标展开最终突袭。这项突袭计划他已经酝酿很久了，所以这方面你不必担心。他只是需要一些增援来确保突袭万无一失。如果你能去帮助他，我可以支付你%reward%克朗的酬劳。%SPEECH_OFF%  |  %employer%迎接了你并将你带到他其中一张战略地图旁。他指着%objective%。%SPEECH_ON%%commander%指挥官目前正在对那里的堡垒展开围攻。我需要一些精锐前去支援他发动最终突袭。如果你能去协助他，我可以付你%reward%作为报酬。这个提议不错吧？%SPEECH_OFF%  |  当你进入%employer%的房间时，你看到一群指挥官围在一张地图旁。地图上放置着各种指示用的印记。其中一个人正在用木棍将一只木马推过潦草画出的平原上。%employer%欢迎了你的到来，但其中一位将军将你拉到一边，并解释了他们的需求： \n\n 指挥官%commander%目前正在%objective%指挥一次围攻。那些防守部队就快崩溃了，但他同时也担心敌方会前来增援。所以，他想在敌方增援出现前发动一次最终突袭。如果你能到那里去协助这位指挥官，我们可以付你%reward%作为报酬。 |  你站在%employer%的门外，为自己是否该去趟这道浑水而感到犹豫不决。突然，一位仆人装上了你，他的胸前抱着一大堆克朗。他问你%employer%是否在房间内，因为这%reward%克朗是要作为报酬支付给佣兵的。于是你二话不说就在赶在这位仆人之前走进了房间。%employer%热情地欢迎了你。他向你解释说，指挥官%commander%目前正在围攻%objective%，并且即将突破敌人的防御。他只需要一些人去帮他完成最终的突袭。%employer%装模作样地思考了一下，然后补充道。%SPEECH_ON%事成之后，你会得到%reward%克朗作为报酬。%SPEECH_OFF%你假装这个数量感到非常震惊。 |  你不清楚目前的战局对%employer%来说是否有利，但他手下的将军们一个个都显得很紧张。看他们的样子，似乎已经忍不住要自己拔剑上战场去了。%employer%就坐在房间中的火堆旁，他的身旁还站着一个端着葡萄酒的侍从。这位贵族朝招呼你过去，并和你说道。%SPEECH_ON%别在意这些脾气暴躁的家伙们。这场战争局势良好。一切都很正常。为了向你证明这一点，我需要你去和位于%objective%的指挥官%commander%汇合，因为他所发起的围攻即将结束。胜利已经在我们手中，我需要你去帮我完成这最后的一战！为此我可以付你%reward%克朗，如何？%SPEECH_OFF%  |  你走进了%employer%的房间，发现这位贵族正坐在一张舒适的椅子上。他的脚下睡着两只狗，而他的手下面还有只猫。他已经彻底陷入了熟睡，不仅鼾声如雷，而且另一只手上还抓着一只酒杯。一个看起来像是将军的人招呼你穿过房间。%SPEECH_ON%不必去在意领主。他为这场战争操劳得太多了。现在，给我听好了。我肩上背负着使命，而你则要听我的指挥。我想让你到%objective%去协助%commander%指挥官对那里的堡垒进行围攻。就是这些。%SPEECH_OFF%你询问你能从中得到多少报酬。将军的脸色一下子变得有些难看。%SPEECH_ON%是啊。还有报酬。我准备为此支付你%reward%克朗。希望这能换来你的……效忠。%SPEECH_OFF%他在说出最后一个词的时候似乎非常不舒服。显然，他的外交式口吻都是装出来的。 |  %employer%的其中一位将军在走廊里迎接了你。%SPEECH_ON%领主大人很忙。%SPEECH_OFF%他将一个卷轴递给了你。你打开它，并开始阅读其中的内容。其中的大意为，指挥官%commander%正在围攻%commander%，并且需要支援。毫无疑问，这些人需要%companyname%为此出力。你抬头看着那位将军。他很不情愿地说道。%SPEECH_ON%身为我们光荣的佣兵，你将会得到%reward%克朗作为报酬。%SPEECH_OFF%在说“光荣”两字的时候，他显然极不情愿。 |  在你找到了%employer%后，他将你带进了他的私人狗舍中。他一边把食物扔给了狗，一边开始说话。%SPEECH_ON%战争的形势对我们来说非常好。这是我有史以来遇上的最佳时机。%SPEECH_OFF%他给狗递了一块食物。%SPEECH_ON%但我们还可以做得更好。我想让你到%objective%去协助%commander%指挥官对那里的堡垒发动突袭。为你你可以得到%reward%克朗的报酬。%SPEECH_OFF%一位侍从带着一直活鸡从旁边经过。那位贵族拎着鸡腿将鸡丢入狗舍中。随着一阵骚动，那只鸡瞬间被狗撕成了碎片。%employer%转过身来，掸掉了身上的鸡毛。%SPEECH_ON%那，我们就这么说定了？%SPEECH_OFF%  |  %employer%迎接你进入了他的房间，这里明显已经被改造成了战争会议室。指挥官们在一张战略图上忙碌着，来回推动着各种模型。%employer%将你领到一边。他一边转动着手上的戒指，一边对你说。%SPEECH_ON%指挥官%commander%在围攻%objective%的过程中需要支援。根据情报，他就快突破敌人的防守了。而你，能助他这最后一臂之力。只要你能完成这项任务，就能领到%reward%克朗作为奖励。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "你刚才说多少克朗来着?",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。 |  我们还有其他事情要做。 |  我不会用围攻的方式把战团碾碎。}",
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
			ID = "TheSiege",
			Title = "包围圈中……",
			Text = "[img]gfx/ui/events/event_31.png[/img]{你来到了%commander%\'s 帐篷看见士兵们貌似都很轻松。他们在铺在泥地上的木板上一边玩着骰子，一边讲着笑话，唱着歌。四周飘扬着旗帜，其中的大多数早已褪去了色。有几个人正在把棍子——弹弩的组成成分栓成一捆。%commander%亲自领着你来到他的指挥篷。他给了你一杯酒，尝起来就像是老鼠的洗澡水。他分析着当下的形势。%SPEECH_ON%你肯定知道，我们在这有一会儿了，正打算突围。我需要你留在附近，并时刻准备着。进攻的时机只要一到,我就会发起进攻的号角%SPEECH_OFF%  |  %commander%\'s营地已摧毁了%objective%附近的一切。驻军每日的走动已将平地踏成了泥地。其中的一小部分人批量生产着低劣，下等的弹弩的辐条。他们把一头得了蠕虫的牛的头嗯进木桶中，在战争利器开始发威前，放松绳索的弹簧，同时开始纺织，拼命地筑建着防御工事。在用糟糕的颜料把这些墙毁容之前，对墙进行了一次射击，飞出的子弹碰到齿装堡垒后被弹飞。一个堡垒士兵喊道。%SPEECH_ON%打的不错，你这个讨厌鬼！%SPEECH_OFF%%commander%轻轻地拍了拍你的肩膀。他脸上露着微笑。%SPEECH_ON%欢迎来到前线，佣兵。我很感激你们能来。%objective%中断了，尽管饥饿难耐，他们却拒绝投降，仍奋力地拼命着。但不自已地在饥饿中逐渐失去生气。等时机来临，我会发动进攻，我希望你为那一刻准备着。%SPEECH_OFF%  |  %commander%欢迎来到前线。他传讯给你%objective%守军已经陷入疲势,供给即将耗竭，马上就要溃败了。鉴于这些迹象，他正准备着最后的总攻，需要%companyname%的你们在时机来临时做好准备。 | %objective%的包围圈更像是大型戏剧里的摆设，而非严肃的战事安排。两边都处于严重供给不足的境地，隔着墙有来有往地骂着对方，被困于这个糟糕境地的不幸在其间悄悄地发酵着。但是，%commander%面露喜色地走到你身边%SPEECH_ON%啊，我亲爱的雇佣兵。我来告诉你现在正在发生什么。我们已经切断了运至%objective%的供给并在几天前的一个晚上我们的一个分部成功地焚烧了敌人的粮仓。他们现在饿得发慌，死期就在眼前了。因为我们现在时间不多了。我正在组织一次全员总攻，尽早冲出这个包围圈。在进攻来临时一定要准备好哦。%SPEECH_OFF%  | 你来到%objective%看到地平线上伫立在地平线上的堡垒，%commander%透着一副皮革物在看——透镜，他面露怒色地瞧着镜前的东西。他递给你那副透镜，你凑上去看了一下。\n\n 首入眼帘的是一个男人一边用手拍着屁股，屁股上下晃动着。他旁边的士兵闭着眼，笑着扯拉着他的生殖器。你放下了透镜，不浪费力气去看别的东西。%commander%摇了摇头。%SPEECH_ON%我们切断了他们的食物供给，他们现在已经发傻了。他们自以为这样很好玩，但很快我们就能看到谁才能笑到最后。我正在策划一次进攻。我需要你及%companyname%在命令下达前准备好%SPEECH_OFF%  |  %commander%欢迎来到%objective%的郊区，他们的营地就建在这里。面露疲色，眼透怨念的士兵挤满了行行列列的帐篷。他们用从没洗过的锅炖着东西，讲着不堪入耳的玩笑。在远处，%objective%中不知疲倦的守兵在堡垒中饿着肚子。首领将你领到他的帐篷解释着刚才的情景。%SPEECH_ON%%objective%已经把食物吃光了，一直在饿着肚子。不幸的是，我已经没时间了。我们需要马上把那个死妈的地方攻下来，刻不容缓。等要打时，我会让佣兵来通知你，你一定要准备好。%SPEECH_OFF%  |  %objective%的郊区遍满了帐篷。%commander%\'s一个警卫领着我穿过包围区。怨形于色的职业士兵怀疑地看着你。但是，%commander%微笑地欢迎你来到他的帐篷。进门时，你看到一个双手被悬挂起的人，两只脚在空中来回地晃动。另一个人在一桶发红的水中洗着小刀。%commander%挥手打了那个囚犯。%SPEECH_ON%啊，我的佣兵。你刚好错过了刚才那段。%SPEECH_OFF%你自己问问他刚刚做了什么。首领走到囚犯跟前，托起他的下巴，一张疲倦的脸庞映入眼帘%SPEECH_ON%刚刚你做了什么？%objective%将落之时，我没时间干坐着等着它发生。我马上就要攻打堡垒，在那时，我要你和你的手下准备好。%SPEECH_OFF%  | 你来到 %commander%\'s包围圈营地发现士兵正在拿着一网袋的头往弹弩里装然后在%objective%\'s堡垒上把他发射出去。首领来到你的身边，面露喜色，沉浸在眼前的景象之中。%SPEECH_ON%你是清楚的，有些头是来自我们这边的，但我觉得城墙上的那些饭桶发现不了这点。这不关乎谁的脑袋，有多少，你知道么？跟我来，佣兵。%SPEECH_OFF%他领着我去他的指挥篷，那里铺着一张地图。%SPEECH_ON%这些守军都累透了，最新的一个消息说他们差不多已经把食物给吃完了，开始争残羹冷炙了。但我已经没那时间让他们去自己幡悟了。我只能采取这一策略了。我们马上要开展进攻了。在命令下达时，你得在这里。%SPEECH_OFF%  |  当进入%commander%\'s帐篷时,一些属于他的人朝你的人身上吐唾沫，一场争斗随即就爆发了。幸亏，首领亲自过来把争斗镇压下来。他快速地将你带到他的帐篷，与你进行交谈，与此同时，你的士兵守在外面。%SPEECH_ON%我对刚刚我手下的举动向你表示歉意。当你们整日在泥地中站睡，而你的敌人安逸地在床上休息，并侮辱你们，日复一日，脾气变得越来越差。\n\n幸运的是，我的一个分部焚烧了%objective%\'s粮仓及库存，敌人堡垒已断了供给。守军们已空腹很久，我真的怕我的手下已经坚持不了多久了。我还担心援军会过来帮忙突破包围。眼下的这些都意味着一件事情……我要下达攻击命令了。攻打的计划现在正在制定当中，我需要你在命令下达时准备好。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "%companyname%马上就位。",
					function getResult()
					{
						this.Flags.set("WaitUntil", this.Time.getVirtualTimeF() + this.Math.rand(15, 30));
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TakingAction",
			Title = "包围圈中……",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%commander%在他包围圈的外面欢迎你。他手上有一队骑兵。他的脸上溢满嫉妒之情。他赶忙解释道。%SPEECH_ON%佣兵，你手握最好的时机。我的侦察兵刚刚报道援军正在赶来解除对%objective%的包围。我们可以对他们发起进攻，也可以直接烧了这个狗地方从而把他们驱赶出去。那样做的话，应该不会太困难。%SPEECH_OFF%奇怪的是，首领看着我仿佛在寻求我的意见。 |  %objective%已被%commander%\'s人所包围，但围攻者看起来比守军更紧张不安。%commander%把你拉近他的帐篷。他一边说着现在的情况一边用指关节敲着桌子。%SPEECH_ON%我的侦察兵发现了一股军队来解除包围。我们没有足够的人能把他们击退，更别提我们精力了。我们可以现在发起进攻，也可以用炮火填满我们的弹弩，把那狗地方夷为平地。守军是肯定能冲出来的，也不会残留下很多需要去援救出来。%SPEECH_OFF%然后，突然，首领抬起头问道。%SPEECH_ON%佣兵，你认为我们应该怎么做？%SPEECH_OFF%  | 当你来到%commander%\'s帐篷时, 他和他的陆军中尉正站着一副地图旁，你的出现很快让他们很快停止了争论。首领手指着你。%SPEECH_ON%佣兵！我们已经得到消息援军正赶来解除包围，而且我们没有人能去击退他们。我们要么攻打%objective%要么烧了这个地方从而把他们驱赶出去，然后拿走剩下的全部东西。我的中尉对这件事看法不同。你怎么看？你来做最后的决定。%SPEECH_OFF%中尉在旁发着牢骚，但却奇怪地任由这个决定权落入一个佣兵手中。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我认为我们应该对堡垒发起全面的进攻。",
					function getResult()
					{
						this.Flags.set("IsAssaultTheGate", true);
						this.Contract.setState("Running_TakingAction");
						return "AssaultTheGate";
					}

				},
				{
					Text = "我认为我们大火烧了堡垒从而把他们驱赶出去。",
					function getResult()
					{
						this.Flags.set("IsBurnTheCastle", true);
						this.Contract.setState("Running_TakingAction");
						return "BurnTheCastle";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "AssaultTheGate",
			Title = "包围圈中……",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%commander%已经做出了进攻的命令。\n\n {%companyname%和一队贵族手下的士兵前去攻打前大门。你们戴着攻城槌的兜帽排着长队，与其说是扣人心弦的战争机器，不如说是破轮胎。大家齐力推着攻城槌前进。随着弓箭一支一支地射在攻城槌上，顶部传来砰-砰-砰的声音。你抬起头看到有些箭头已刺穿攻城槌顶部。当来到大门前，你命令手下去把攻城槌的尾部抬起来，然后在听到命令时把它放下。\n\n发出沉重的橡木声状的呻吟，攻城槌向前驶进，啪的一声撞在大门上。攻城槌中间位置断裂开来，通过缝隙你可以看到 %objective%\'s 守军正在另一边等着你。又一道命令，新的一辆攻城槌。这一次攻城槌连续猛击，直至击穿大门，打断了铰链，伴随着飞舞的碎片和散落的金属，两扇大门被击开。大家都已准备好，你及手下冲进大门之中。 | 在一名commander\'s随行人员的陪同下,%companyname%推着一个带着兜帽的攻城槌驶向%objective%的大门。一些守军面露嘲笑及不屑，向我们吼叫着。%SPEECH_ON%{你不先带我们去吃个晚餐么？ | 真是个绝佳的攻城槌。想要弥补是么？ | 过来拿这个，龟孙子。 | 但愿你的祈祷能得到回应。}%SPEECH_OFF%他们的箭没有发出一丝声响，当你颠簸地向大门行进时，只用了一次进攻，大门就被攻开了。你的手下快速地通过入口。 | 带着一些commander\'s手下,%companyname%推着一个带着兜帽的攻城槌驶向%objective%的大门。顶部发出格格，嗡嗡的声音，出现了更多简陋之处。你祈祷着这能坚持住。上方传来无数箭矢的声响，箭头尖锐的部分插入木顶篷中。当越来越靠近%objective%\'s大门时，箭换成了石头，沉重地击在兜帽上。%randombrother%抬头看攻城槌的顶部，大笑起来。%SPEECH_ON%来源于地狱，朋友。%SPEECH_OFF%突然大家被一种惹人厌的嘶嘶声所包围，就像是跌入了毒蛇的巢穴一般。瞬间陷入阴影当滚烫的油从顶部溢进来。其中的一细流倾倒在那个贵族的背上，他撕心地喊着，倒在了地上，变成了一团嘶喊的岩浆。你惊忙地叫那些手下开始攻城。幸亏，只用了一击就把%objective%的大门打开。你的手下快速地冲进进口与遇到的一小些守军打斗起来。 | 攻打%objective%的命令传达下来。你准备好了么？%companyname%。你的手下和%commander%\'s推着攻城槌驶向堡垒的前大门。箭矢划过天空，射入如潮的进攻者中。士兵们无声息地倒下，其他人上前摁住他们的伤口。\n\n 前大门被攻开，你的手下纷纷涌进庭院，那里等候着%objective%\'s 守军。 |  %commander%下达了进攻的命令。你的战团和他的军队在堡垒里厮杀，一兵营围攻士兵射出了箭，箭多得挡住了阳光，犹如雹暴一般。城墙不停地受到猛击守军们在as %commander%\'s弓箭手的施压下，不停在躲避。你成功地将攻城槌推至大门前，快速地把他撞开。当%companyname%冲进来时， %objective%的守军自发组织起来在庭院里等候你们。 | 攻打%objective%的命令传达下来。进攻引来了预示着灾难的景象——天空布满了箭矢。消防管布满了%objective%的城墙，你看到%commander%\'s手下往堡垒上架梯子，并奋力向上爬。与此同时，你及你的手下躲在攻城槌的兜帽下缓缓前进，将之推至大门前，并快速地将大门撞开。当往进冲时，发现庭院里全是守军，正准备着与你决战。 |  %commander%给你下达了攻打%objective%\'s堡垒的命令。这次进攻的情形大概这样：天空因双方的远攻（使用箭矢）彻底暗了下来，砰砰的碰击声如雨般充斥在耳边，空中遍布着各个方向的箭。箭矢像彗星般划过天空，插入城墙和防御塔中。守军们奋力把梯子从堡垒上推开。进攻者涌上梯子，最高处的那人用盾牌抵挡着来自于堡垒上的进攻，他下面的人用长矛一面往上刺着，一面缓慢向上爬去。你和%companyname%推着一辆快要散架的攻城槌向大门前进，根本不忌惮于外面的激烈斗争。\n\n 撞开了大门，你及你的手下急忙冲进去，与早已在里集合的守军奋战。四处可见%commander%\'s手下为了夺取控制权而奋战。 | 不幸的是，%commander%看到%objective%被撞开，突然癫痫发作。你和%companyname%负责将攻城槌推至大门前。当在泥地中推着这辆突围机器时，你看到一个背着冒着热气的大锅在大门处等着你。你四处瞧了瞧看到士兵们正扛着梯子准备冲上城墙。他们飞快地爬上城墙开始战斗。回头看时，背着盛着热油的士兵已经不见了，仅留一副腿孤零零地露在大锅之外。\n\n 大门已被撞开，士兵们冲了进去。你很快就遇上了一小队守军，与此同时，%commander%\'s手下仍在墙体周围奋战。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "冲啊！",
					function getResult()
					{
						local tile = this.Contract.m.Origin.getTile();
						this.World.State.getPlayer().setPos(tile.Pos);
						this.World.getCamera().moveToPos(this.World.State.getPlayer().getPos());
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "AssaultTheGate";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.flattenTerrain(p);
						p.Entities = [];
						p.AllyBanners = [];
						p.EnemyBanners = [
							this.Contract.m.Origin.getOwner().getBannerSmall()
						];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.m.Origin.getOwner().getID());
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
			ID = "BurnTheCastle",
			Title = "包围圈中……",
			Text = "[img]gfx/ui/events/event_68.png[/img]{一排弓箭手们将他们的箭头捆上了帆布，并在柏油里浸了浸。当他们准备好箭矢后，一位年轻的男孩拿着火炬跑了过来，照亮了他们。指挥官举起了他的手，同时弓箭手们搭箭上弦。他挥下了手，箭矢如雨点般射了出去。被点燃的箭矢冲入了天空，发出噼噼啪啪的嘈杂声。它们争先恐后地落在了要塞上。一名士兵指着一个冒烟的地方大喊起来。很快，火焰升腾而起。几分钟后，前门就被大火烧穿了，那群烟熏火燎地冲出来的人，就像刚从地狱走了一圈似的。\n\n %commander%再次举起了他的手臂，但这次他的手中拿着剑。%SPEECH_ON%冲啊！%SPEECH_OFF%  |  弹弩，投石器以及弓箭手们都在不停地向%objective%城墙发射火焰。到处都充斥着弹矢的破空声。\n\n 要塞很快就着起了大火。漆黑的烟雾升腾而起。身后的火焰也在慢慢扩散开来。前门不停地被火焰舔舐着，最终还是被烧穿了。被火焰与浓烟环绕的人们为了呼吸新鲜的空气争先恐后地推挤着彼此。%commander%拔出了他的剑，指向了敌人。%SPEECH_ON%一个不留！%SPEECH_OFF%%objective%的守军似乎也听到了这句话，立刻组成了阵型。有那么一会儿，你很好奇这群被熏得漆黑的敌人如何才能举起白旗。 |  接到上面的命令，说要对%objective%施行火攻。你亲眼看着%commander%的营地不停地发射着燃烧的弹矢，照亮了天空。很快，要塞的城墙着起火来，被困在其中的人们焦急地来回奔跑着。当火焰侵蚀进%objective%内部后，要塞的大门打开了，一群被黑烟熏得漆黑的人冲了出来。看到他们后，%commander%立刻对手下们下达了冲锋的命令。 |  %commander%下令对%objective%施行火攻。于是无数浸过柏油点燃的弹矢射向了要塞。它们的轨迹划亮了天空。无数的燃烧弹矢射入了%objective%内部，很快，你看到那里面冒起了烟。要塞中的火焰升腾而其，不一会儿前门就打开了，里面冲出了一群被烟熏火燎的人。%commander%拔出了他的剑。%SPEECH_ON%他们出来了，伙计们。去解决他们吧！%SPEECH_OFF%  |  弓箭手们开始给箭头包上帆布，然后浸了浸柏油。孩子们拿着油桶在场地里跑动着，不停地给弹弩的弹矢涂抹着。准备好后，%commander%下令开始射击。人类或许曾崇拜火焰，然而现在，火焰的颜色却撕裂了天空，让%objective%变成了恐怖的地狱。燃烧的弹矢粉碎了高塔与屋顶，照亮了整片区域。防守者们不停地四处逃窜着，而燃烧的箭矢不断地降落在他们身边。随着火势越来越大，要塞的前门猛然打开了，里面冲出了一群被烟熏火燎的人，仿佛刚从地狱中跑出来一般。\n\n 看到这个情况后，%commander%拔出了他的武器。%SPEECH_ON%解决他们，兄弟们，不留活口！%SPEECH_OFF%  |  %commander%下令对%objective%发动火攻。于是你看到弹弩，投石机和弓箭手们同时开始发射燃烧的弹矢，火光照亮了天空。很快要塞就着起了大火。奔溃的人们打开了大门冲了出来，剧烈地咳嗽着，渴望着新鲜的空气。%commander%拔出了他的武器，微笑着看着这样的情况。%SPEECH_ON%时机已到，消灭他们！冲啊！%SPEECH_OFF%  |  你看到攻城技师们给弹弩和投石机填装着牛的尸体，同时涂抹着各种动物的脂肪。小孩们在阵线中来回奔波着，给弹矢涂抹油脂。之后，工程师们讲尸体投掷了出去。密集的破空声撕裂了天空。你看到其中一发命中了塔楼，炸开了它的外部，同时点燃了要塞的中庭。在这样的攻击下，很快，%objective%陷入了一片火海当中。\n\n 大门突然被打开了，里面冲出了一群人。他们推挤着彼此，而身后的火焰就像有生命般追逐着他们。%commander%拔出了他的武器。%SPEECH_ON%我们等待的就是这一刻，兄弟们。就是现在！冲啊！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "冲啊！",
					function getResult()
					{
						local tile = this.Contract.m.Origin.getTile();
						this.World.State.getPlayer().setPos(tile.Pos);
						this.World.getCamera().moveToPos(this.World.State.getPlayer().getPos());
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "BurnTheCastle";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.flattenTerrain(p);
						p.Entities = [];
						p.AllyBanners = [
							this.World.Assets.getBanner(),
							this.World.FactionManager.getFaction(this.Contract.getFaction()).getBannerSmall()
						];
						p.EnemyBanners = [
							this.Contract.m.Origin.getOwner().getBannerSmall()
						];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.getFaction());
						p.Entities.push({
							ID = this.Const.EntityType.Knight,
							Variant = 0,
							Row = 2,
							Script = "scripts/entity/tactical/humans/knight",
							Faction = this.Contract.getFaction(),
							Callback = this.Contract.onCommanderPlaced.bindenv(this.Contract),
							Tag = this.Contract
						});
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 200 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.m.Origin.getOwner().getID());
						p.Entities.push({
							ID = this.Const.EntityType.Knight,
							Variant = 0,
							Row = 2,
							Script = "scripts/entity/tactical/humans/knight",
							Faction = this.Contract.m.Origin.getOwner().getID(),
							Callback = null
						});
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
				foreach( id in this.Contract.m.UnitsSpawned )
				{
					local e = this.World.getEntityByID(id);

					if (e != null && e.isAlive())
					{
						e.die();
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "AssaultTheCourtyard",
			Title = "在 %objective%...",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%objective%的大门已被夺下，但现在还有更多的事情要做。这种势头需要保持住：于是你很快就开始下令让你的手下开始对中庭发动攻击。 |  大门被夺下了，但%objective%的中庭还没有沦陷。你对%companyname%下令，继续向里推进。 |  %companyname%已占领了大门，%commander%的手下正在清理周围的塔楼。你不想失去这股冲劲，于是很快下令，让手下继续向中庭发动进攻。 |  当你冲入中庭时，看到%commander%的手下正在为争夺城墙的控制权而战斗着。 |  你和%companyname%冲进了%objective%的中庭。上方传来了一阵阵刀剑相交的声音，%commander%的手下正在为争夺城墙的控制权而战。 |  必须夺下中庭！你和%companyname%冲进了要塞内部。同时你发现，%commander%的手下正在为争夺城墙的控制权而战。 |  当你冲进%objective%的中庭时，一名被杀死的敌人正好从上方坠落而下，你发现%commander%的手下正在为争夺城墙的控制权而拼死厮杀着。 |  %commander%的人正在对城墙发动攻击。现在你必须履行自己的职责，清扫整片中庭！ |  %commander%的人在争夺城墙，你也得去肃清要塞的中庭。不许失败！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "冲啊！",
					function getResult()
					{
						local tile = this.Contract.m.Origin.getTile();
						this.World.State.getPlayer().setPos(tile.Pos);
						this.World.getCamera().moveToPos(this.World.State.getPlayer().getPos());
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "AssaultTheCourtyard";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.flattenTerrain(p);
						p.Entities = [];
						p.AllyBanners = [];
						p.EnemyBanners = [
							this.Contract.m.Origin.getOwner().getBannerSmall()
						];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.m.Origin.getOwner().getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
				foreach( id in this.Contract.m.UnitsSpawned )
				{
					local e = this.World.getEntityByID(id);

					if (e != null && e.isAlive())
					{
						e.die();
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "AssaultAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%objective%的堡垒已经沦陷。你看到%commander%的手下正在四处搜索着，把那些因绝望而倒在阴暗缝隙处的人的尸体拉扯出来。尸体被点燃了，无头的，缺少肢体的，内脏外流的以及极少数保持完整，就像睡着了一样的尸体。一名专业士兵从塔楼的垛口探出身子，撕下了堡垒原来的旗帜，并升起了%noblefamily%的徽章，大声欢呼着。 |  中庭到处都是尸体，堆叠在城墙边，角落里的一些人甚至还保持着死前的惊恐表情。尸堆中不仅有人的尸体，还有马，猪，狗以及鸟。他们都被这场无情的地狱大火给吞噬了。\n\n %commander%正在向他那些幸存下来的手下们道贺，称赞着他们的功绩。其中一名士兵将%noblefamily%的旗帜挂在了一座塔楼上。这个可怜的地方有了一个新主人。 |  战斗结束了，%objective%的守军都被肃清了。如果还有谁活着的，那一定已经弃城而去了。%commander%下令让他的一名手下在一座塔楼上升起了%noblefamily%的徽章，就这样，%objective%的拥有者变成了另一个人，而那面带有徽章的旗帜也缓缓地随风飘扬起来。 |  虽然代价高昂，但这场战斗总归还是结束了。%commander%踏过了几具尸体，下令让他的手下立即开始清理区域。其中一名手下升起了%noblefamily%的旗帜，证明了这场战斗谁才是最后的胜利者。 |  你身边都是些%objective%驻军的尸体。虽然他们也奋力战斗了，但历史是不会记住失败者的。他们的名字将被遗忘，他们的存在也将被消亡。你看到%commander%的一名士兵将他们的旗帜升到了一座塔楼上，总之，结果还是不错的。 |  战斗就快结束了。你看到%commander%的手下将那些守军从附近的塔楼中扔了出来，让那些可怜的人尖叫着死去。当一切结束后，其中一名士兵升起了%noblefamily%旗帜。它在空中飘荡着，猎猎作响。 |  治疗师们冲进了要塞，开始治疗%commander%的手下。一些要塞的守军们也受伤了，但没有人去照顾他们。求救的哭喊声都被冰冷的剑刃终结了。那样的喊叫声很快就消失了。\n\n %noblefamily%的旗帜在要塞中随风飘扬。 |  %commander%的手下在%objective%的中庭里四处搜索着。他们发现了一个女人，然后将她带入了塔楼中。孩子们哭喊着冲向了她，然而并没有理会他们。%commander%向你打了个招呼，祝贺你的工作顺利完成。他指着那名正在前门升起%noblefamily%旗帜的士兵。%SPEECH_ON%看到那个徽章了吗？它代表着胜利。%SPEECH_OFF%你以为只有敌人成堆的尸体才能见证胜利，然而看来一块破布也足以证明这场胜利了。 |  中庭堆满了尸体，鲜血环绕着城墙。%commander%的手下正在四处收集武器，同时消灭着那些还未彻底死去的受伤的敌人。而他们自己的伤口早就被那些老治疗师们处理过了。%noblefamily%的旗帜在城墙上随风飘扬，作为一种确实的见证：%objective%有了新的主人。 |  %objective%的居民们被迫在要塞中进行游行，看着那些死去的守军，见证了这场彻底的失败。%commander%傲然站在他们面前，手指插在腰带间，脸上还带着得意的笑容。当一名士兵升起%noblefamily%的旗帜后，他指向了他。%SPEECH_ON%看到那个了吗？现在你们要臣服于此。明白了吗？%SPEECH_OFF%  |  你看到居民们被迫在%objective%中游行。%commander%似乎很喜欢宣扬这场绝对的胜利，并让所有人明白，已经没有反抗的余地了。你不能责怪他这点：被征服者通常会产生反抗的情绪，这种隐藏的情绪比那些已然亮剑的敌人更加危险，也更加致命，因此需要尽快开始根除这种情绪。 |  %commander%将%objective%的居民们集合起来，在要塞中开始游行。他们被迫去看些已经死去的守军，上面的鲜血还未干涸。一名美丽的女性也在队列中，而指挥官将她拉了出来。他问她，其中是否有她认识的人。她指向了一个男人，那人的脸已经凹陷了下去。她认出了他胸口间别着的那已经干瘪的玫瑰—她在早上将它送给了她的丈夫。%commander%向她表达了自己的歉意，然后轻轻地将她送回了队列中。他面向人群，用慈父般的声音说道。%SPEECH_ON%你们会得到良好的照顾的。我们会重建此地，不用担心。不过，也请你们不要搞错了，从现在起，%objective%属于%noblefamily%。只要我们在这点上达成共识，那一切都没有问题。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "胜利！",
					function getResult()
					{
						this.Contract.changeObjectiveOwner();
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BurnTheCastleAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_68.png[/img]{肃清%objective%守军的行动进行得很顺利。你和%commander%走过了现在无人驻守的大门，去看看这地方还有什么剩余的东西。很不幸，大火彻底地烧毁了这个地方。同时，其中一名专业士兵将%noblefamily%的旗帜挂在了一座塔楼上。不过，在如此浓重的烟熏下，你几乎看不清上面的徽章了。 |  战场横尸遍野。%commander%的手下在成堆的尸体中穿梭着，用长矛终结那些还在呻吟的声音。\n\n 你和指挥官前往了%objective%的大门。大火烧毁了这里的一切。中庭散布着各种家畜被烧焦的尸体。%commander%耸了耸肩，下令让一名手下在塔楼上升起了%noblefamily%的旗帜，证明了谁才是这场战斗的胜利者。 |  战斗结束了。用火攻对付%objective%的守军或许减少了牺牲，但大门处的一切都被焚烧殆尽了。重建此地得花上些时间。%commander%看起来很高兴，下令让一名手下升起了%noblefamily%的旗帜。然而在如此烟熏火燎下，那块布的样子也变得不咋地了。 |  %commander%在%objective%焚烧的废墟中行走着。%SPEECH_ON%总之，我们还是成功了。虽然最终的情形不怎么雅观。不过我也不想抱怨什么。干得好，佣兵。%SPEECH_OFF%  |  %objective%的居民们走了出来，看着那些守军们的尸体。妇女们在被烧焦的尸体中翻找着，寻找着她们的所爱之人。然而，找到的只有被烧焦的脸庞以及扭曲的骨头，那些脸上还带着死前恐惧的表情。%commander%的一名手下在前门升起了%noblefamily%的旗帜，他指向了那面旗帜。%SPEECH_ON%都给我听好了！看到那个了吗？那代表着我们的势力。现在，你们要做的，就是尊重这面旗帜，臣服于我们，然后一切都将恢复正常！如果不愿意这样做，那我会让你们明白一些新道理的，明白了吗？%SPEECH_OFF%人们静静地点了点头。%commander%笑了起来，那笑容让人胆寒。%SPEECH_ON%很好！那么现在我想问问，有人会炒蛋吗？%SPEECH_OFF%  |  你和%commander%进入了%objective%要塞，去检视战后的情况。无论是人还是动物，都被烧焦了，各种尸体交织在一起。有个人正在处理那些尸体，拉动着手中的绳子，上面捆着一堆被烧焦的肉体。你捂住了嘴尽量让自己不要吐出来。%commander%下令让他的手下在前门升起了%noblefamily%的旗帜。他拍了拍你的肩。%SPEECH_ON%嘿，干得不错，佣兵。不过你还得多闻闻这股恶臭。这样你就能更快习惯这种味道了。%SPEECH_OFF%  |  你穿过了%objective%的城墙，用一片布捂住了鼻子。%commander%走在你的身边，高高地抬起头，似乎是想摆脱里面的恶臭。%objective%中，你看到那些尸体已扭曲在一起，家畜和人混杂在一起，脸上都带着忍受焚烧的痛苦神情。%commander%拍了拍你的肩。%SPEECH_ON%这真是场伟大的胜利，你知道吗？你得快点回去向%employer%报告，除非你想留在这里进行清理工作。%SPEECH_OFF%  |  你和%employer%举着剑进入了%objective%，但其实根本不用这么做：那场地狱般的火焰已经焚烧了一切。里面的人就算没被烧死，也被烟灰给呛死了。%commander%踢了踢脚边的碎石，同时一具烧焦的尸体从废墟中滚落而出。%SPEECH_ON%操了，这里除了城墙，什么都没剩下。%SPEECH_OFF%他严肃地看向了你。%SPEECH_ON%但城墙就是一切。%SPEECH_OFF%你蹲下看着那具尸体。%SPEECH_ON%你觉得这人也是这么想的吗？%SPEECH_OFF%指挥官耸了耸肩。很快，他下令让手下在前门升起了%noblefamily%的旗帜。 |  你走进了%objective%，不过很快就后悔了。里面到处都是被烧得面目全非的尸体。火焰把一切都烧成了漆黑的颜色，就连地面也一样。%commander%想用脚翻过了一具尸体。然而在触碰的时候，尸体却像冰层那样裂开了。他死命地捏着自己的鼻子。%SPEECH_ON%真没想到会这样，你呢？%SPEECH_OFF%他转身吹了个口哨，指着手下的一名士兵。%SPEECH_ON%你！去把%noblefamily%的旗帜挂到大门和塔楼上！%SPEECH_OFF%那名士兵敬了个礼，然后立刻去办事了。%commander%拍了下你的肩膀，说%employer%会对这个消息感到很高兴的。 |  %objective%要塞里已经没有剩下什么东西了：大火烧尽了一切。那些留在其中的人，都已被烧得面目全非。而那些跑进塔楼躲避者，都窒息而死。死者痛苦的面部表情已清楚地说明了一切—那并不是什么舒服的死法。%commander%看起来很高兴，下令让他的手下去清理战场，并挂起%nobefamily%的旗帜。 |  你在%objective%的废墟中仔细搜索着。成片的死尸吸引了你的注意，因为你从未见过如此众多被烧焦的尸体堆积在一处。其中一人似乎还抓着一个小小的东西，你走近一看，发现那个东西原来是个婴儿。%commander%走了过来，拍了拍你的肩。%SPEECH_ON%啊，这可真惨。嘿，但是你干得很不错，佣兵。别想太多了，明白吗？%SPEECH_OFF%你点了点头。指挥官短短地笑了一下，然后下令让他的手下开始在四处挂起%nobefamily%的旗帜。得让其他陌生人们明白，这座被烧毁的要塞，有了新的主人。 |  在%objective%中，你发现里面已被烧得面目全非了。狗的尸体都已被烧得通红，在被火焰吞噬前，锁链就已经闷死了它们。马匹被困死在了马厩中，漆黑的腿部已经变得僵硬无比。猪冲破了围栏，四处乱跑，当然，身上还燃烧着。淡淡的熏猪肉气味稍稍减缓了这地狱般景象的恐怖感。这些生物毫无退路可走。\n\n 你打开了储物室的门，发现里面还有一群被闷死的守军。%commander%走到了你身边，朝里面看去。%SPEECH_ON%真是可怜的家伙。他们看起来还很年轻。可能只是些养马人，侍从什么的。真惨。%SPEECH_OFF%指挥官把身子探进房间里，拿起了一条面包，拍了拍上面的稻草。他掰掉了外面烧焦的部分，里面的部分还很干净。%SPEECH_ON%嘿，你饿吗？%SPEECH_OFF%你礼貌地拒绝了他的提议。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "胜利！",
					function getResult()
					{
						this.Contract.changeObjectiveOwner();
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Origin.spawnFireAndSmoke();

				foreach( a in this.Contract.m.Origin.getActiveAttachedLocations() )
				{
					a.spawnFireAndSmoke();
					a.setActive(false);
				}
			}

		});
		this.m.Screens.push({
			ID = "MaintainSiege",
			Title = "包围圈中……",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%commander%带来消息说，守军的力量似乎已被削弱。他希望避免正面激烈的战斗，只想等待他们自己出来。你被指示暂留在前线营地，等待进一步的通知。 |  %commander%的一名副官通知你，指挥官已决定再等一段时间，希望守军能够投降，已避免不必要的伤亡。%companyname%被指示暂且待命，等待进一步通知。 |  你得到了新消息，围城还要再持续一段时间。你被指示暂且待命，等待进一步通知。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "%companyname%马上就位。",
					function getResult()
					{
						if (this.Flags.get("IsNighttimeEncounter"))
						{
							this.Contract.setState("Running_NighttimeEncounter");
						}
						else if (this.Flags.get("IsReliefAttack"))
						{
							this.Flags.set("IsReliefAttackForced", true);
							this.Flags.set("WaitUntil", this.Time.getVirtualTimeF() + this.Math.rand(15, 30));
							this.Contract.setState("Running_Wait");
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "NighttimeEncounter",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_33.png[/img]{%commander%命令你和你的人前去巡逻。期间，你发现%objective%的一些守军正悄悄地从要塞的一面城墙边溜出来。他们似乎正在穿过某种秘密通道。你思索片刻，立刻命令你的手下冲了过去，希望在被发现前能占据那条通道。别让那些混蛋溜回去！ |  当你在查看围城状况时，%commander%命令你和%companyname%前去%objective%的外部工事进行巡逻。\n\n 就在巡逻期间，你发现一群%objective%的守军正悄悄地从某个口子中溜出来。你蹲下身子，慢慢的靠近他们，仔细观察着。当那个口子关上后，你能到上面盖上了苔藓和青草，标记出了它的位置。如果你现在离开去把这事告诉%commander%，那些人很可能就会发现你，然后毁掉这条通道。于是你决定抓住机会，发动了攻击。%companyname%绝不能让任何一个人逃跑！ |  当围城情况稳定下来后，你决定去外面主动调查一番，于是向上级询问你和%companyname%是否可以出去巡逻一下。外出散散步能帮助你的手下保持良好的状态。否则他们留在营地里，很可能会跟职业士兵们产生争执。%commander%同意了。\n\n 巡逻还没过几秒，你就发现了一些%objective%的守军正从护城河堤岸处溜出来。他们是从要塞城墙处的一道口子中游出来的。%randombrother%摇了摇头。%SPEECH_ON%我了个大操。%SPEECH_OFF%你让他保持安静。如果那些人发现他们的秘密通道被发现了，他们一定会立刻关上它的。你等到那些人全都游出来，然后发起了攻击。不能让任何人逃离！ |  你接到了巡逻的命令，决定和%companyname%一起执行这个任务。你的手下不停地抱怨着，但这样的任务能让他们保持着良好的状态。\n\n 同样，发现一群从密道中偷偷溜出来的%objective%守军也能让士兵们兴奋不已！就在巡逻开始没过几分钟后，你就发现这样的情况了。你看着那群守军集合，就在准备向内陆进发时，下令发动了攻击。不能让任何人逃离！ |  围城持续着，%commander%命令你和你的手下前往%objective%附近进行巡逻。期间，你的手下发现一些守军正从某个秘密通道溜出来。占领那个通道或许能让你们在未来的战斗中占据极大的优势地位。你很快下令让手下们开始发动攻击—不能让那些人跑掉！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "抓住他们！",
					function getResult()
					{
						local tile = this.Contract.m.Origin.getTile();
						this.World.State.getPlayer().setPos(tile.Pos);
						this.World.getCamera().moveToPos(this.World.State.getPlayer().getPos());
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "NighttimeEncounter";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.flattenTerrain(p);
						p.Entities = [];
						p.EnemyBanners = [
							this.Contract.m.Origin.getOwner().getBannerSmall()
						];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 80 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.m.Origin.getOwner().getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "NighttimeEncounterFail",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_33.png[/img]{真是去他娘的。一些守卫跑了回去，你甚至还听到了通道被封锁的声音。 |  你的动作还不够快，让一些守军溜了回去。他们退回了%objective%，并封锁了通道。 |  好吧，原本的计划是杀光那些溜出来的守军，占领通道。然而现在，有些人却跑回了%objective%，并封锁了通道。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "该死的！",
					function getResult()
					{
						this.Flags.set("IsNighttimeEncounter", false);
						this.Flags.set("IsReliefAttack", true);
						this.Flags.set("WaitUntil", this.Time.getVirtualTimeF() + this.Math.rand(15, 30));
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "NighttimeEncounterAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_33.png[/img]{你成功杀光了所有的守军，并占领了通道。当你把此事汇报给%commander%后，他下令让你溜进去，暗杀%objective%的指挥官。你有几小时的准备时间，记住，时间很宝贵，你必须在夜晚结束前完成任务。 |  你成功杀光了所有守军，占领了通道。你返回至%commander%处，把这一情况汇报给他。他点了点头，转向了你。%SPEECH_ON%我想让你通过那个密道溜进城中，暗杀他们的首领。%SPEECH_OFF%跟正面对敌比起来，这个夜间行动似乎会更轻松一些。 |  你成功占领了通道，并把这一情况汇报给了%commander%。他大笑起来，摇了摇头。%SPEECH_ON%这种机会我们已经寻找了很久了，而你则是第一个发现%objective%这种秘密的人。%SPEECH_OFF%他希望你和%companyname%能溜进城中暗杀守军的领袖。一旦成功，守军将会溃散，而%objective%就能被轻易拿下。要么这样做，要么就得正面进攻，而你对后者毫无兴趣。你有几小时的准备时间，但必须在夜晚结束前完成任务。 |  一名守军大声呼救。%SPEECH_ON%他们发现了，啊—%SPEECH_OFF%%randombrother%立刻隔断了他的喉咙。你安静地看着%objective%城墙上的活动，似乎没有人发现这个呼救声。\n\n 之后你们返回了围城营地，途中被%commander%拦住了。他似乎在等着好消息，于是你把情况说了一遍。首领顿了顿足。%SPEECH_ON%老天，这是我几周来听到的最好的消息了！这真是好极了，但我们得赶快开始行动。我希望你和你的手下能溜进城中暗杀%objective%的领导人。我们必须尽快完成此事，只有几小时的时间，明白了吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们做好了准备，然后溜进了城中。",
					function getResult()
					{
						this.Flags.set("IsSecretPassage", true);
						this.Contract.setState("Running_SecretPassage");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "FailedToReturn",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_33.png[/img]{你没能杀死守军的首领，因此%commander%不得不取消了围城。虽然围城的失利并不都是你的错，但%employer%可不会这么想。 |  密道被锁上了！因为守军的领导人仍存活着，对要塞发动正面进攻估计会造成极大的牺牲。%commander%取消了围城，而你也承担了很大一部分的责任。 |  你浪费的时间太多了，密道被堵上了。那些守军一定发现了事情有变，于是用石头封死了通道。由于守军的指挥官没有死，对要塞发起正面攻击将会给%commander%的军队带来极大的损失。他取消了围城。%employer%不会满意的。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Damnit!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Wandered off during the siege of " + this.Flags.get("ObjectiveName"));
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SecretPassage",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_33.png[/img]{你和%companyname%悄悄地溜进了密道。密道中沾满屎尿的墙壁和水可不是那么好受的。%randombrother%抱怨了几声，不过你立刻命令他闭上嘴巴。\n\n 出了密道后，你们来到了中庭，战团隐藏在一堆灌木中，而你观察着整片场地。\n\n 有几名守军在四处漫步着。他们有的在叹气，有的在打着哈欠。他们饥饿的肚子在咕咕作响，口中还咒骂着什么。很快，你发现了那名指挥官，身边陪伴着他最好的警卫队。他正在中庭进行检视。再也不会有比这更好的机会了，于是你下令发动攻击！ |  %companyname%和你打开了密道。你们刚好遇到一名看着一卷写满货物名称的卷轴正向外走去的马童。他祈求你饶恕他的性命，但这种关头你可不能冒险。%randombrother%割开了他的喉咙，把他的尸体扔进了肮脏的密道中。你们继续向中庭摸索去。你和手下隐藏在了一堆灌木中，静静着观察着。\n\n 忽然，你发现一名穿着指挥官服装的人在一群守卫的陪伴下走了过来。再也不会有比这更好的机会了，于是你下令发动攻击！ |  密道又暗又脏，里面的水沾满了屎尿。你卷起了裤子，慢慢向内走去。火炬可能会暴露你的存在，所以你们是摸着墙向里走去的。你手指碰到的东西让你感到恶心，你也不想知道那到底是什么。终于，你们走出了密道，来到了中庭。\n\n %objective%的指挥官正埋头工作着，听到响动后，他停下动作转过头来，正好看到你和%companyname%带着浑身恶臭出现在了他的面前。他猛然睁大双眼，立刻伸手去拿武器。%SPEECH_ON%有刺客！%SPEECH_OFF%同时，你下令让%companyname%发起攻击！ |  密道短得惊人，出口在%objective%城墙的另一边。出口处，一名守卫正站在那里。他看到你和你的手下的影子。他说道。%SPEECH_ON%希望你们弄到了我们想要的东西。记着，我要鸡蛋和……%SPEECH_OFF%忽然，他看到%randombrother%的脸从阴影中浮现出来，同时他意识到，面前的陌生人并不是他正在等待的人。守卫立刻往后退去，但在他开口呼救前，你的佣兵就已经刺穿了他的胸膛。没有了那人的阻拦，你们静静地溜进了%objective%，发现指挥官正在中庭进行训练。\n\n 不会有比这更好的机会了，于是你下令让%companyname%发起了攻击！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "冲啊！",
					function getResult()
					{
						this.Contract.getActiveState().onSneakIn(null, false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SecretPassageAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%objective%的指挥官倒下了，他的手下也很快放弃了抵抗。一位副官举起了他的双手，急切地说道。%SPEECH_ON%我们不想再继续这场没有意义的战斗了。唯一想坚持的人已经死在这里了。我们投降。%SPEECH_OFF%%employer%会感到很满意的。 |  战斗结束了，你找到了那位濒死的%objective%守军指挥官。你跨过他的时候，他朝你吐了口血。%SPEECH_ON%我们永不投降。随你怎么折磨我。%SPEECH_OFF%你把剑刺入了他的眼窝。他的一位副官扔掉了武器，举起了双手。%SPEECH_ON%嘿，他是唯一一个想要防守这个地方的人。现在，这地方是你的了。请放过我们！%SPEECH_OFF%你下令让%randombrother%发送信号，好让%commander%了解这里的情况。 |  %objective%的指挥官死了，他的手下很快就放弃了抵抗。他们说只有那位指挥官想防守这个地方。很显然他正在试图吸引贵族们的注意力，这样史诗般的守城战，一旦成功，他一定能获得不错的回报。不过现在，他已经死了。你让%randombrother%发送信号，好让%commander%了解%objective%已经投降的这一信号。一名守军乞求你的仁慈。%SPEECH_ON%你一定会饶恕我们的，对吗？%SPEECH_OFF%你擦了擦剑上的血，耸了耸肩。%SPEECH_ON%这可不是我说了算。我的赞助人和他的军队正朝这里来。他想怎么做，我可管不着。你想要仁慈，很好办，拿起你的武器，我的手下就会让你感受到什么是仁慈的。%SPEECH_OFF%守军皱着眉点了点头。%SPEECH_ON%我想我还是等着吧。%SPEECH_OFF%  |  %objective%的指挥官死了。剩下的守卫们立刻举起了双手。你下令让手下们把这些守卫绑了起来，同时发出了信号，在塔楼的一侧扬起了你的徽章。%commander%的围城营地立刻吹响了号角做出回应。战斗结束了。%employer%一定会很高兴的。 |  战斗结束了，%objective%的领导者也死了。剩下的守军们立刻投降了。你下令让%companyname%围住了他们，并将其一个个绑了起来。%randombrother%向%commander%发出了信号，通知其要塞已经拿下。%employer%一定会很期待与你的再次见面。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们成功了！",
					function getResult()
					{
						this.Contract.changeObjectiveOwner();
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SecretPassageFail",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_33.png[/img]{不幸的是，你没有就位以暗杀指挥官因而必须撤退。%objective%的守卫在你和你的部下溜回通道的时候对你各种嘲笑。当你回到外面时，你听到通道被封的声音。看来必须要采用更困难的办法来抓捕%objective%le . |  战斗没有如预期发展。你和%companyname%被迫撤退回通道并实行战略撤退。当你到外面时，你听到石头崩塌的声响，那是守卫将其封锁的声音。你尽力了，但看来要抓捕%objective%没有预期的简单。 |  值得称赞的是，守卫干的很不错。他们又累又饿，如困兽之斗。当你撤退出%objective%的围墙，你听到通道被封锁的声响。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "该死的！",
					function getResult()
					{
						this.Flags.set("IsSecretPassage", false);
						this.Flags.set("IsReliefAttackForced", true);
						this.Flags.set("WaitUntil", this.Time.getVirtualTimeF() + this.Math.rand(15, 30));
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ReliefAttack",
			Title = "包围圈中……",
			Text = "[img]gfx/ui/events/event_90.png[/img]{%commander%的侦察兵带消息返回，称一只救援部队正在赶来试图终结对%objective%的包围战。指挥官点点头并让大家准备战斗。你也这么做了。 |  等待的时候，一小队侦察兵返回并进入%commander%的营帐。你跟着进去却发现指挥官正点着头收拾东西。他看着你解释道。%SPEECH_ON%救援部队要来了。他们会试图终结围城战。让你的人准备战斗。%SPEECH_OFF%  |  {你看着%randombrother%和一位职业军人掰手腕。他们在以去了脑袋的鸡打赌。胜者能够饱餐一顿，败者只有手臂酸痛。 |  其中一位围城士兵和%randombrother%正准备开始对视比赛。先眨眼的就输了。胜的人能得到一只鸡。 |  你发现%randombrother%举起泥潭棍子旁边的大石头。一个围城士兵也做了同样的事。显然他们在为了一只鸡比赛，而最后的胜者能赢得所有。}他们还没开始，一个侦察兵冲进营帐并表示一支军队正赶来解救%objective%。%commander%下令让他的士兵做好战斗准备。你将其复述给%companyname%。 |  %commander%的侦察兵带消息返回称一只军队正试图营救%objective%。你命令%companyname%做好大规模交战的准备。 |  一场大战在即：%commander%的侦察兵带消息返回称一只军队正赶来尝试终结围城战。做好准备！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备战斗！",
					function getResult()
					{
						this.Contract.spawnReliefForces();
						this.Contract.setState("Running_ReliefAttack");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ReliefAttackAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_86.png[/img]{营救军被击败并逃离战场。%objective%的守卫无疑看到了整场战斗，士气大受打击。他们的投降看来只是时间问题了！ |  万岁！救援军被击溃。%commander%感谢你的帮助。他用皮质外皮的望远镜看着%objective%的围墙笑道。%SPEECH_ON%哦，他们被打得落花流水。他们看到了全程。我这辈子没见过这么多绝望无助的人。%SPEECH_OFF%他大笑着拍打你的肩膀。%SPEECH_ON%佣兵，我觉得围城战就要结束了！%SPEECH_OFF%  |  你成功击退了救援军！那可能是%objective%最后的希望因而他们的投降估计指日可待了。 |  %commander%感谢你帮忙击溃救援军。他相信%objective%现在随时可能投降了。 |  看着你在这世上唯一的希望破灭可能对士气来说是最大的打击了。%objective%的守卫看到了他们的救援军被屠杀，而那无疑使他们到了投降边缘。 |  好吧，%objective%最后的希望也彻底破灭了。你和%commander%召开会议并一直认为：守卫无疑要准备投降了。只是时间问题而已。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "他们撑不了多久了。",
					function getResult()
					{
						this.Flags.set("IsReliefAttackForced", false);

						if (this.Flags.get("IsSurrender"))
						{
							this.Flags.set("IsSurrenderForced", true);
						}
						else if (this.Flags.get("IsDefendersSallyForth"))
						{
							this.Flags.set("IsDefendersSallyForthForced", true);
						}

						this.Flags.set("WaitUntil", this.Time.getVirtualTimeF() + this.Math.rand(10, 20));
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Surrender",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_31.png[/img]%objective%投降！\n\n{你穿过打开的大门发现到处是守卫。饥饿的士兵痛苦倒地，其他人则倾靠在墙壁上，皲裂的嘴唇在祈求着水。动物全死光了。它们早就被屠宰光了。乌鸦从高墙上向下望，加入你的征服战并等待机会分一杯羹。%commander%拍拍你的肩膀表示感谢。 |  前门打开，你以胜利者的姿态从中穿过。然而，里面的景象却能消除任何荣耀感，因为你看到自己所击败的是这些可怜的家伙。死去的守卫被堆在角落。少数人因同类相食被钉死在十字架上，但即便是那些被处决的人也显露出被食用的迹象。庭院一边有一个烧焦的粮仓。一些人嘴唇发黑地坐着，显然试过狼吞虎咽遗留的焦黑谷物。每只动物都被屠宰并蚕食的只剩骨头。\n\n %commander%对着这场景发笑并下令让他的属下开始拷住这些人。他转向你说道。%SPEECH_ON%谢谢你，佣兵。你现在可以回到%employer%那了。%SPEECH_OFF%  |  城堡里你看到守卫站成排。两位%commander%的士兵开始着手行动，一个拖着链条，另一个则拉着链条把这些人拷在一起。你看到一具尸体刺在马棚上面，风向标穿过他的胸膛穿透胸膛然后刺着心脏像是某种仪式。%commander%笑着走过来。%SPEECH_ON%那是他们的中尉。{他们说他拒绝投降并自己跳下了高塔。 |  显然他拒绝投降于是他的手下将其丢下了防御塔。}%SPEECH_OFF%有意思。好吧，%employer%再见到你会很高兴的。 |  这些高墙后，%commander%的士兵正在收缴守卫的武器并堆成堆。守卫被赶在角落，每个人都手被拷在身后，他们低着头，眼睛盯着泥地。少数守卫看着他们，偶尔踢着他们，朝他们吐痰，甚至威胁杀掉他们。一切都很有趣的样子。\n\n %commander%走过来拍拍你的背。%SPEECH_ON%干得好，佣兵。非常感谢你的帮助。回%employer%那去吧。这里的活干完了。%SPEECH_OFF%  |  穿过大门，你看到卫士在祈求怜悯。他们的中尉死躺在泥地中，还因数个刺伤流血。一个人解释道。%SPEECH_ON%我们很久之前就想投降但他不同意！你必须要理解！我们并不想要战争。%SPEECH_OFF%%commander%走到你旁边点头道。%SPEECH_ON%这里的工作完成了，佣兵。回去见%employer%吧。%SPEECH_OFF%你询问他要怎么处置这些囚犯。他耸耸肩道。%SPEECH_ON%不知道。我会想先吃点东西。然后或许给我爱的人写封信。我试着更慎重些。%SPEECH_OFF%很好。 |  你和%commander%走过打开的大门。里面，一些幸存的守卫跪在地上，祈求食物。他们几乎弯不下腰，因为肠胃会疼。%SPEECH_ON%求求你们！救命……%SPEECH_OFF%%commander%用脚踹开他。%SPEECH_ON%我们看起来像是来帮你们的吗？%SPEECH_OFF%指挥官转向你。%SPEECH_ON%干得好，佣兵。回%employer%那吧。这里的工作完成了。%SPEECH_OFF%  |  通过大门你发现守卫被圈在一个角落。%commander%问谁是领袖。那群人一起将手指向了庭院。防御塔下吊着一个死人，脸色死白，鼻子和手都发紫了。其中一位囚犯解释道。%SPEECH_ON%如果我们不这么做，你还会站在外面，而我们依然在这里忍饥挨饿。%SPEECH_OFF%%commander点点头。%SPEECH_ON%好吧。这我就不惩罚你们了。佣兵！你回%employer%那吧。这里的工作完成了。%SPEECH_OFF%  |  穿过大门，你发现堡垒的指挥官挥舞着长剑被逼至角落，他周围则是几个手持长矛的%commander%士兵。一次统一的冲击，士兵们把他刺成了刺猬。被刺枪固定后，他放弃了向前跪倒，像慵懒依靠在篱笆桩似的挂下手臂。%SPEECH_ON%好吧，你们抓到我了。%SPEECH_OFF%他转向自己的属下，看来他们真是来开门的。%SPEECH_ON%死了之后我会缠着你的。%SPEECH_OFF%血从他的口中喷出，他的身体最后一次晃了一下。士兵们收回长矛，于是这位领袖笔直落到了泥地中。%commander%站在他旁边然后跟你说道。%SPEECH_ON%好了，佣兵。回%employer%那吧。%SPEECH_OFF%  |  堡垒内是人间炼狱。人们捂着肚子散在各处，有一些已经死了，有些则希望如此。堡垒的指挥官被吊死在防御塔，一面家族旗帜缠在他的脖子上仿佛那给他的死带去了一些尊严。动物骨架散落在庭院，到处都是屎尿屁呕吐物。%commander%走了过来点头道。%SPEECH_ON%看来不错。他们没早点投降真是太可惜了。%SPEECH_OFF%你暗示可能是被吊死的中尉坚决主张反对投降才至此。%commander%又点了点头。%SPEECH_ON是啊。他认为那才是光荣的选择。过去我可能也会做同样的事，但看过这些后，我不确定他做的到底是对是错了。%SPEECH_OFF%  |  穿过大门，你发现守卫们被集中到一个朝拜地。剩下的人不多并且没有人在祈祷。死者在角落堆积而且有同类相食的迹象。看不见任何动物。马棚中满是苍蝇，嗡嗡声震天响。猪舍被彻底践踏。其中一个囚犯看向你说道。%SPEECH_ON%我们吃掉了所有能吃的。你明白吗？我们。吃掉了。所有。能。吃。的。%SPEECH_OFF%%commander%来到你身边。%SPEECH_ON%别让他们烦你了，佣兵。回%employer%那吧。他肯定在等着你了。%SPEECH_OFF%  |  你和%commander%走过大门。里面的守卫都只剩皮包骨了因而摇晃不稳。一个人抓住你的肩膀。%SPEECH_ON%食物！食物！%SPEECH_OFF%他的呼吸中带有因饥饿而散发的可怕恶臭。你将他推倒在地，他大声呼喊着然后开始用泥土填嘴巴。%commander%嚼食一片黄油面包来到你旁边。%SPEECH_ON%这些混蛋真是让人不忍直视啊，不是吗？%SPEECH_OFF%他嘴里喷出面包屑，像盯着金子一样两眼发亮。指挥官拍着你的肩膀。%SPEECH_ON%回%employer%那吧，他会非常开心得知这消息的。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "%objective%沦陷了！",
					function getResult()
					{
						this.Contract.changeObjectiveOwner();
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				foreach( id in this.Contract.m.UnitsSpawned )
				{
					local e = this.World.getEntityByID(id);

					if (e != null && e.isAlive())
					{
						e.die();
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "DefendersSallyForth",
			Title = "包围圈中……",
			Text = "[img]gfx/ui/events/event_78.png[/img]{围城营地传来一阵响亮的尖叫声。你探出头看到%objective%的大门打开然后跑出来一群人。%commander%冲出营帐，看了一眼，然后开始朝他的士兵大喊。%SPEECH_ON%出击！出击！他们来了，士兵们，他们来了！做好战斗准备！杀光那些混蛋，听到了吗？%SPEECH_OFF%围城营地发出吼叫声。你很快集结了%companyname%并准备加入战斗。 |  %objective%的守卫向前出击！你下令士兵做好战斗准备加入%commander%的战斗。 |  不会有投降一说！%objective%的守卫向前出击。他们都是一群可怜饥饿的模样，但似乎他们宁死不屈。%commander%让他的士兵准备应战，你也同样告知了%companyname%。 |  %objective%的大门打开了！起初就是如此，然后一小群守卫咆哮着开始向外出击。他们提起手臂欢呼，高唱着家族的战吼。他们只是用吼叫攻击，而你将用暴力反制。准备作战！ |  锈迹斑驳的铰链环声响响彻围攻营地。你看向%objective%发现大门缓慢打开。一群人走出来，携带旗帜和武器。他们看着像是已经战败的军队，饥肠辘辘地蹒跚前行。%commander%摇摇头。%SPEECH_ON%那些白痴。他们怎么救不直接投降呢？%SPEECH_OFF%你耸耸肩然后转向%companyname%。%SPEECH_ON%既然你们求死，那就成全你们。做好战斗准备，士兵！%SPEECH_OFF%  |  %randombrother%走到你跟前指向%objective%的大门。%SPEECH_ON%看，长官。%SPEECH_OFF%你看到大门缓缓打开。一群人蹒跚而出。他们没有举任何白旗，而是举着家族的图章。你跑向%commander%并告知了守卫正在进击的消息。他点点头道。%SPEECH_ON%我知道他们很顽固，但这不过是可悲罢了。谁都不该如此毫无意义地死去。%SPEECH_OFF%你差点开口说那样最初就不会有人参战。然而你没有，你去让%companyname%的士兵们准备作战。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "做个了结吧！",
					function getResult()
					{
						local tile = this.Contract.m.Origin.getTile();
						this.World.State.getPlayer().setPos(tile.Pos);
						this.World.getCamera().moveToPos(this.World.State.getPlayer().getPos());
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "DefendersSallyForth";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.flattenTerrain(p);
						p.Entities = [];
						p.AllyBanners = [
							this.World.Assets.getBanner(),
							this.World.FactionManager.getFaction(this.Contract.getFaction()).getBannerSmall()
						];
						p.EnemyBanners = [
							this.Contract.m.Origin.getOwner().getBannerSmall()
						];
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.getFaction());
						p.Entities.push({
							ID = this.Const.EntityType.Knight,
							Variant = 0,
							Row = 2,
							Script = "scripts/entity/tactical/humans/knight",
							Faction = this.Contract.getFaction(),
							Callback = this.Contract.onCommanderPlaced.bindenv(this.Contract)
						});
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Noble, 200 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.Contract.m.Origin.getOwner().getID());
						p.Entities.push({
							ID = this.Const.EntityType.Knight,
							Variant = 0,
							Row = 2,
							Script = "scripts/entity/tactical/humans/knight",
							Faction = this.Contract.m.Origin.getOwner().getID(),
							Callback = null
						});
						this.Contract.setState("Running_DefendersSallyForth");
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
				foreach( id in this.Contract.m.UnitsSpawned )
				{
					local e = this.World.getEntityByID(id);

					if (e != null && e.isAlive())
					{
						e.die();
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "DefendersPrevail",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]难以置信，疲惫的%objective%守卫获胜了！你在围城战溃败后撤退。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "围城战失败了。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed in the siege of " + this.Flags.get("ObjectiveName"));
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "DefendersAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%objective%的守卫被消灭而防御工事则留出完全空当。你和%commander%走过大门发现尸体、垃圾和屠宰的动物到处都是，一副绝望的迹象。指挥官点点头拍了拍你的肩膀。%SPEECH_ON%干得好，佣兵。你现在该回到%employer%那然后告诉他这个喜讯了。%SPEECH_OFF%  |  战斗结束了，%objective%守卫溃败而他们的堡垒则完全放空等待被夺取。%commander%在解除%companyname%战场上的服务前向你表示感谢。你现在该去看看开心的%employer%了。 |  %objective%的守卫很英勇，但如果他们像这样玩的话他们该在几周前这样做，那时候他们的体力补给还能与他们激昂的斗志相符。现在都无所谓了。饿死鬼跟饱死鬼看起来差不多，再花点时间，他们就完全一样了。\n\n %commander%过来告诉你不再需要%companyname%效力了。你同意了并回去找%employer%要报酬。 |  饿着肚皮进军和糟糕领导下导致陷入困境显然都不是什么好情况。你无从得知要是%objective%的守卫投降%commander%是否会放过他们。至于现在，他们都死在泥地中了，而他们的时代也早已过去。你召集%companyname%的士兵并下令他们准备返回%employer%。领报酬的日子会很开心的。 |  %objective%的守卫被清除掉后你和%commander%走向堡垒。这些士兵这么绝望是有原因的：条件太凄惨了。尸体被扒去衣服堆在角落。一口原本应该是煮过猪的锅，但很难辨别因为他们似乎把那动物吃的一点不剩。防御塔下吊着一具尸体。他们在他的胸膛上钉了一块“食人者”的牌子，可能是用他自己的血书写的。\n\n %commander%笑了。%SPEECH_ON%看来这里才是真正的派对啊，不是吗？记得这个场景，下次碰到好战的中尉坚持要你坚守时。%SPEECH_OFF%  |  %companyname%和%commander%的军队已经击败了大部分进击的%objective%守卫。堡垒无人驻守后，%commander%的士兵很快将其夺取。指挥官亲自告诉你可以去找%employer%要报酬了。 |  %objective%的守卫战死沙场，但那也算是战场的仁慈了。这些高墙后几乎没剩下任何有价值的东西，尤其是粮食近乎绝迹。仿佛墙壁后的人甚至不知道食物是什么，守卫不得不清理这个地方。你很确信光是提到食物这个字眼对于这些人来说都是煎熬了。%commander%来到你身边笑着说。%SPEECH_ON%我原以为自己知道什么叫饥饿，然而我一直是知道答案的，你知道吗？我从未饥饿到绝望。真是太可怕了。但话说回来，他们最终还是找到解决办法了，不是吗？%SPEECH_OFF%他对自己的黑色幽默发笑时你点点头。%SPEECH_ON%你完成的很棒，佣兵。去找%employer%要报酬吧。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "%objective%沦陷了！",
					function getResult()
					{
						this.Contract.changeObjectiveOwner();
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Prisoners",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_53.png[/img]{你的几个部下成功抓捕了几个%objective%守卫。他们站在一起，被佣兵的武器拦着。一些人在靴子里瑟瑟发抖。有一个甚至连靴子都没穿。另一个已经吓得尿裤子了。%randombrother%询问该如何处置他们。 |  %randombrother%报告一些%objective%的守卫被捕。你看到一组人挤在一起，围成一个圈，但他们都低着头。一个人大喊道。%SPEECH_ON%求求你，不要杀我们！我们不过是遵照指令，跟你们一样！%SPEECH_OFF%  |  你的人成功抓捕了几个%objective%守卫。他们被堆在一起，脱去裤子，然后还硬逼他们脸扎进泥土。%randombrother%询问该如何处置他们。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "放他们走。%rivalhouse%可以将此作为示好的表示。",
					function getResult()
					{
						return "PrisonersLetGo";
					}

				},
				{
					Text = "他们或许会有些价值。把他们作为囚犯带给%commander%。",
					function getResult()
					{
						return "PrisonersSold";
					}

				},
				{
					Text = "最好现在就杀了他们，免得在几天后的战场上见到他们。",
					function getResult()
					{
						return "PrisonersKilled";
					}

				}
			],
			function start()
			{
				this.Flags.set("IsPrisoners", false);
			}

		});
		this.m.Screens.push({
			ID = "PrisonersLetGo",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_53.png[/img]{囚犯对你和任何人都没有价值。你放了他们，希望你不会后悔这个决定。 |  你放了这些囚犯。他们哭着向你表示感谢，但你只希望这不是犯错。 |  你放走了囚犯。他们在离开前私下感谢你，希望永远不用再见。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "死的够多了。",
					function getResult()
					{
						this.World.Assets.addMoralReputation(2);
						this.World.FactionManager.getFaction(this.Flags.get("RivalHouseID")).addPlayerRelation(5.0, "Let some of their men go free after battle");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "PrisonersKilled",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_53.png[/img]{你朝%randombrother%点点头。%SPEECH_ON%杀光他们。%SPEECH_OFF%囚犯企图逃跑，但那显然不可能。他们被砍成碎片。 |  他们带着手铐没有任何价值，但很显然若是逃脱了有一天他们会回来攻击你。你下令处决他们，怒气下的命令。 |  像这样的战斗中，没那么多食物来供养囚犯的，而在你还深陷敌人据点时他们对你也毫无用处。但如果让他们走，他们某天或许会反过来再攻击你。\n\n 想到这里，你下令处决他们。抗议声很快变成了被抹脖子的声音。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "着手更重要的事情……",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-2);

						if (this.World.FactionManager.isCivilWar())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnPartyDestroyed);
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "PrisonersSold",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_53.png[/img]{你将囚犯带到指挥官面前。这些人站成排然后指挥官一个个打量着。%SPEECH_ON%这个。这个。他。还有他。其他的杀掉。%SPEECH_OFF%几个幸运儿，碰巧也是队伍中最大块头，看起来最实用的，被拉到前面。剩下的大多数被长矛刺透胸膛杀死。%commander%给了你一些钱。%SPEECH_ON%感谢你抓到他们。他们会被好好利用的。%SPEECH_OFF%  |  囚犯们被带到%commander%那。他命令被拷住的人去做苦力活。指挥官付给你一笔可观的钱感谢你。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "着手更重要的事情……",
					function getResult()
					{
						this.World.Assets.addMoney(250);
						this.World.Assets.addMoralReputation(-1);
						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]250[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你向%employer%报告 %objective%已被夺取控制。男人手后藏着假笑，让他保持一些风度仿佛贵族不应该自降身价到表现这种门外汉似非专业的激动。他只是点点头仿佛这消息是理所当然。%SPEECH_ON%很好。很好。当然了。%SPEECH_OFF%这个男人打了个响指然后一个仆人递给你一袋%reward_completion%钱。 |  进入%employer%的房间让一群指挥官、中尉和贵族本人都安静了一阵。他站起身。%SPEECH_ON%我的线报已经告知了我%objective%的夺取消息。你的酬劳在外面。%SPEECH_OFF%领袖连感谢都没说，虽然%reward_completion%钱在你看来足够表达感谢。 |  %employer%欢迎你到他的作战指挥室。一群指挥官围在桌子上的地图四周。你看着他们将自己的印记推到%objective%。%employer%笑了。%SPEECH_ON%那些人可能没说，但我们对你所完成的功绩非常满意。我的探子带回来的消息使我确信我对你的投资没有错。%SPEECH_OFF%贵族亲自给了你一袋%reward_completion%钱。 |  %employer%的房间业务繁忙。%commander%来来回回，彼此争论着自己的观点，而仆人则躲闪迂回以确保他们用膳妥当。战争可没工夫浪费在收拾衣服和做饭这种小事上。你甚至惊讶没有仆人在他们争论当中给他们喂食。\n\n 然而，%employer%在一旁却显得很奇怪。他正犹如坐在叽喳鸟叫的花园中翻看着一本书。他抬头看向你。看了眼他的将军们，然后看向你。%SPEECH_ON%干得好。这是你的报酬。%SPEECH_OFF%一个箱子被推到你面前。其中有%reward_completion%克朗。 |  一个仆人拦着没让你进%employer%的房间。他解释道。%SPEECH_ON%我被要求在这见你然后给你这袋%reward_completion%钱。%SPEECH_OFF%你收下钱点点头。 |  你想进%employer%的房间，但一个守卫拦住了你。%SPEECH_ON%你推开拦在面前的戟，声称自己与%employer%有业务关系。守卫放低了戟。%SPEECH_ON%仅限贵族。%SPEECH_OFF%当你要开口骂人时，一个仆人拿着一个大袋子从房间走出。他看到了%companyname%的标记然后递给你一个袋子。%SPEECH_ON%这是你的%reward_completion%钱。抱歉我的主人和他的指挥官很忙。%SPEECH_OFF%就那样仆人走了。守卫看向你。%SPEECH_ON%仅限贵族。%SPEECH_OFF%  |  帮助攻克%objective%的奖励是%reward_completion%克朗以及一碗闭门羹。%objective%太忙于跟他的指挥官争论了以致于没有那么多功夫祝贺你。 |  其中一个%employer%的指挥官在一个休息室里接见了你。他随行还带了一个带着一个大袋子的仆人。指挥官开口了。%SPEECH_ON%啊，%companyname%。你的旅途中没多少荣耀，佣兵。你应该像个男人一样跟贵族们并肩作战。我们所做有着巨大的荣耀。你何不加入我们呢？%SPEECH_OFF%大袋%reward_completion%克朗放在你的手上。你笑着回应指挥官，你的金牙闪闪发光。%SPEECH_ON%是，怎么了？%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "%objective%沦陷了。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Took part in the siege of " + this.Flags.get("ObjectiveName"));
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
		this.m.Screens.push({
			ID = "Failure",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]真是场灾难。战斗输了，你也退回到余下的人那。%objective%不会很快陷落的。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "这地方真可恶！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed in the siege of " + this.Flags.get("ObjectiveName"));
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TooFarAway",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_36.png[/img]{时间流逝的概念似乎在逃避你。尽管你不在，围城战突然尝试继续，但最终由于没有%companyname%的帮助而失利。别急着返回%employer%。 |  你受雇来协助攻城的，而不是弃城。没有%companyname%指挥作战，士兵们不得不从战场撤退。 |  你闲逛的离攻城营地太远了！没有你的帮助，进攻者不得不撤退，而%objective%也摆脱了%employer%的进攻。考虑到那是你受雇所要完成的，你或许还是最好先别回到贵族那。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "对的，就是这战场……",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail);
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function spawnReliefForces()
	{
		local tile;
		local originTile = this.m.Origin.getTile();

		while (true)
		{
			local x = this.Math.rand(originTile.SquareCoords.X - 8, originTile.SquareCoords.X + 8);
			local y = this.Math.rand(originTile.SquareCoords.Y - 8, originTile.SquareCoords.Y + 8);

			if (!this.World.isValidTileSquare(x, y))
			{
				continue;
			}

			tile = this.World.getTileSquare(x, y);

			if (tile.getDistanceTo(originTile) <= 4)
			{
				continue;
			}

			if (tile.Type == this.Const.World.TerrainType.Ocean  ||  tile.Type == this.Const.World.TerrainType.Mountains)
			{
				continue;
			}

			break;
		}

		local enemyFaction = this.m.Origin.getOwner();
		local party = enemyFaction.spawnEntity(tile, this.m.Origin.getOwner().getName() + " Army", true, this.Const.World.Spawn.Noble, 200 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
		party.getSprite("body").setBrush(party.getSprite("body").getBrush().Name + "_" + enemyFaction.getBannerString());
		party.getSprite("banner").setBrush(enemyFaction.getBannerSmall());
		party.setDescription("Professional soldiers in service to local lords.");
		party.getLoot().Money = this.Math.rand(50, 200);
		party.getLoot().ArmorParts = this.Math.rand(0, 25);
		party.getLoot().Medicine = this.Math.rand(0, 5);
		party.getLoot().Ammo = this.Math.rand(0, 30);
		local r = this.Math.rand(1, 4);

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

		party.setAttackableByAI(false);
		this.m.UnitsSpawned.push(party.getID());
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(originTile);
		c.addOrder(move);
		local wait = this.new("scripts/ai/world/orders/wait_order");
		wait.setTime(10.0);
		c.addOrder(wait);
	}

	function spawnSupplyCaravan()
	{
		local tile;
		local originTile = this.m.Origin.getTile();

		while (true)
		{
			local x = this.Math.rand(originTile.SquareCoords.X - 7, originTile.SquareCoords.X + 7);
			local y = this.Math.rand(originTile.SquareCoords.Y - 7, originTile.SquareCoords.Y + 7);

			if (!this.World.isValidTileSquare(x, y))
			{
				continue;
			}

			tile = this.World.getTileSquare(x, y);

			if (tile.getDistanceTo(originTile) <= 4)
			{
				continue;
			}

			if (!tile.HasRoad)
			{
				continue;
			}

			break;
		}

		local enemyFaction = this.m.Origin.getOwner();
		local party = enemyFaction.spawnEntity(tile, "Supply Caravan", false, this.Const.World.Spawn.NobleCaravan, this.Math.rand(100, 150));
		party.getSprite("base").Visible = false;
		party.setMirrored(true);
		party.setDescription("A caravan with armed escorts transporting provisions, supplies and equipment between settlements.");
		party.addToInventory("supplies/ground_grains_item");
		party.addToInventory("supplies/ground_grains_item");
		party.addToInventory("supplies/ground_grains_item");
		party.addToInventory("supplies/ground_grains_item");
		party.getLoot().Money = this.Math.rand(0, 100);
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(originTile);
		move.setRoadsOnly(true);
		c.addOrder(move);
		local despawn = this.new("scripts/ai/world/orders/despawn_order");
		c.addOrder(despawn);
	}

	function spawnSiege()
	{
		this.m.SituationID = this.m.Origin.addSituation(this.new("scripts/entity/world/settlements/situations/besieged_situation"));

		foreach( a in this.m.Origin.getActiveAttachedLocations() )
		{
			if (this.Math.rand(1, 100) <= 50)
			{
				a.spawnFireAndSmoke();
				a.setActive(false);
			}
		}

		local f = this.World.FactionManager.getFaction(this.getFaction());
		local castles = [];

		foreach( s in f.getSettlements() )
		{
			if (s.isMilitary())
			{
				castles.push(s);
			}
		}

		if (castles.len() == 0)
		{
			castles = clone f.getSettlements();
		}

		local originTile = this.m.Origin.getTile();
		local lastTile;

		for( local i = 0; i < 2; i = i )
		{
			local tile;

			while (true)
			{
				local x = this.Math.rand(originTile.SquareCoords.X - 1, originTile.SquareCoords.X + 1);
				local y = this.Math.rand(originTile.SquareCoords.Y - 1, originTile.SquareCoords.Y + 1);

				if (!this.World.isValidTileSquare(x, y))
				{
					continue;
				}

				tile = this.World.getTileSquare(x, y);

				if (tile.getDistanceTo(originTile) == 0)
				{
					continue;
				}

				if (tile.Type == this.Const.World.TerrainType.Ocean)
				{
					continue;
				}

				if (i == 0 && !tile.HasRoad && !this.m.Origin.isIsolatedFromRoads())
				{
					continue;
				}

				if (lastTile != null && tile.ID == lastTile.ID)
				{
					continue;
				}

				break;
			}

			lastTile = tile;
			local party = f.spawnEntity(tile, castles[this.Math.rand(0, castles.len() - 1)].getName() + " Company", true, this.Const.World.Spawn.Noble, castles[this.Math.rand(0, castles.len() - 1)].getResources());
			party.setDescription("Professional soldiers in service to local lords.");
			party.setVisibilityMult(2.5);

			if (i == 0)
			{
				party.getSprite("body").setBrush("figure_siege_01");
				party.getSprite("base").Visible = false;
			}
			else
			{
				party.getSprite("body").setBrush(party.getSprite("body").getBrush().Name + "_" + f.getBannerString());
			}

			party.setAttackableByAI(false);
			this.m.UnitsSpawned.push(party.getID());
			this.m.Allies.push(party.getID());
			party.getLoot().Money = this.Math.rand(50, 200);
			party.getLoot().ArmorParts = this.Math.rand(0, 25);
			party.getLoot().Medicine = this.Math.rand(0, 5);
			party.getLoot().Ammo = this.Math.rand(0, 30);
			local r = this.Math.rand(1, 4);

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

			local c = party.getController();
			c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
			c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
			local wait = this.new("scripts/ai/world/orders/wait_order");
			wait.setTime(9000.0);
			c.addOrder(wait);
			i = ++i;
		}
	}

	function changeObjectiveOwner()
	{
		if (this.m.Origin.getFactionOfType(this.Const.FactionType.Settlement) != null)
		{
			this.m.Origin.getOwner().removeAlly(this.m.Origin.getFactionOfType(this.Const.FactionType.Settlement).getID());
		}

		this.m.Origin.removeFaction(this.m.Origin.getOwner().getID());
		this.World.FactionManager.getFaction(this.getFaction()).addSettlement(this.m.Origin.get());

		if (this.m.Origin.getFactionOfType(this.Const.FactionType.Settlement) != null)
		{
			this.World.FactionManager.getFaction(this.getFaction()).addAlly(this.m.Origin.getFactionOfType(this.Const.FactionType.Settlement).getID());
		}

		if (this.m.SituationID != 0)
		{
			this.m.Origin.removeSituationByInstance(this.m.SituationID);
			this.m.SituationID = 0;
		}

		this.m.Origin.addSituation(this.new("scripts/entity/world/settlements/situations/conquered_situation"), 3);
	}

	function flattenTerrain( _p )
	{
		if (_p.TerrainTemplate == "tactical.hills_steppe")
		{
			_p.TerrainTemplate = "tactical.steppe";
		}
		else if (_p.TerrainTemplate == "tactical.hills_tundra")
		{
			_p.TerrainTemplate = "tactical.tundra";
		}
		else if (_p.TerrainTemplate == "tactical.hills_snow"  ||  _p.TerrainTemplate == "forest_snow")
		{
			_p.TerrainTemplate = "tactical.snow";
		}
		else if (_p.TerrainTemplate == "tactical.hills"  ||  _p.TerrainTemplate == "tactical.mountain")
		{
			_p.TerrainTemplate = "tactical.plains";
		}
		else if (_p.TerrainTemplate == "tactical.hills"  ||  _p.TerrainTemplate == "tactical.mountain")
		{
			_p.TerrainTemplate = "tactical.plains";
		}
		else if (_p.TerrainTemplate == "tactical.forest_leaves"  ||  _p.TerrainTemplate == "tactical.forest"  ||  _p.TerrainTemplate == "tactical.autumn")
		{
			_p.TerrainTemplate = "tactical.plains";
		}
		else if (_p.TerrainTemplate == "tactical.swamp")
		{
			_p.TerrainTemplate = "tactical.plains";
		}
	}

	function onCommanderPlaced( _entity, _tag )
	{
		_entity.setName(this.m.Flags.get("CommanderName"));
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"objective",
			this.m.Flags.get("ObjectiveName")
		]);
		_vars.push([
			"noblefamily",
			this.World.FactionManager.getFaction(this.getFaction()).getName()
		]);
		_vars.push([
			"rivalhouse",
			this.m.Flags.get("RivalHouse")
		]);
		_vars.push([
			"commander",
			this.m.Flags.get("CommanderName")
		]);
		_vars.push([
			"direction",
			this.m.Origin == null  ||  this.m.Origin.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Origin.getTile())]
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			foreach( id in this.m.UnitsSpawned )
			{
				local e = this.World.getEntityByID(id);

				if (e != null && e.isAlive())
				{
					local c = e.getController();
					c.clearOrders();

					if (e.isAlliedWithPlayer())
					{
						local wait = this.new("scripts/ai/world/orders/wait_order");
						wait.setTime(60.0);
						c.addOrder(wait);
					}
				}
			}

			if (this.m.Origin != null && !this.m.Origin.isNull())
			{
				this.m.Origin.getSprite("selection").Visible = false;
				this.m.Origin.setOnCombatWithPlayerCallback(null);
				this.m.Origin.setAttackable(false);
			}

			if (this.m.Home != null && !this.m.Home.isNull())
			{
				this.m.Home.getSprite("selection").Visible = false;
			}
		}

		if (this.m.Origin != null && !this.m.Origin.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Origin.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(2);
			}
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isCivilWar())
		{
			return false;
		}

		if (this.m.Origin == null  ||  this.m.Origin.isNull()  ||  this.m.Origin.getFaction() == this.getFaction())
		{
			return false;
		}

		return true;
	}

	function onSerialize( _out )
	{
		this.contract.onSerialize(_out);
		_out.writeU8(this.m.Allies.len());

		foreach( ally in this.m.Allies )
		{
			_out.writeU32(ally);
		}
	}

	function onDeserialize( _in )
	{
		this.contract.onDeserialize(_in);

		if (_in.getMetaData().getVersion() >= 22)
		{
			local numAllies = _in.readU8();

			for( local i = 0; i < numAllies; i = i )
			{
				this.m.Allies.push(_in.readU32());
				i = ++i;
			}
		}
	}

});

