this.tutorial_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Location = null,
		BigCity = null
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.tutorial";
		this.m.Name = "%companyname% 战团 ";
		this.m.TimeOut = this.Time.getVirtualTimeF() + 9000.0;
	}

	function start()
	{
		local settlements = this.World.EntityManager.getSettlements();
		local best_dist = 9000;
		local best_start;
		local best_big;

		foreach( s in settlements )
		{
			if (s.isMilitary() || !s.isDiscovered() || s.getSize() > 1 || s.isIsolatedFromRoads())
			{
				continue;
			}

			local bestDist = 9000;
			local best;

			foreach( b in settlements )
			{
				if (s.getID() == b.getID())
				{
					continue;
				}

				if (!b.isDiscovered() || b.getSize() <= 1 || b.isIsolatedFromRoads())
				{
					continue;
				}

				local d = s.getTile().getDistanceTo(b.getTile());

				if (d < bestDist)
				{
					bestDist = d;
					best = b;
				}
			}

			if (best != null && bestDist < best_dist)
			{
				best_dist = bestDist;
				best_start = s;
				best_big = best;
			}
		}

		this.setHome(best_start);
		this.setOrigin(best_start);
		this.m.Home.setVisited(true);
		this.m.Faction = best_start.getFactions()[0];
		this.m.EmployerID = this.World.FactionManager.getFaction(this.m.Faction).getRandomCharacter().getID();
		this.m.BigCity = this.WeakTableRef(best_big);
		local tile = this.getTileToSpawnLocation(this.m.Home.getTile(), 5, 8, [
			this.Const.World.TerrainType.Swamp,
			this.Const.World.TerrainType.Forest,
			this.Const.World.TerrainType.LeaveForest,
			this.Const.World.TerrainType.SnowyForest,
			this.Const.World.TerrainType.Shore,
			this.Const.World.TerrainType.Ocean,
			this.Const.World.TerrainType.Mountains
		]);
		this.World.State.getPlayer().setPos(tile.Pos);
		this.World.getCamera().jumpTo(this.World.State.getPlayer());
		this.m.Flags.set("BossName", "Hoggart the Weasel");
		this.m.Flags.set("LocationName", "霍加特的避难处");
		this.setState("StartingBattle");
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "StartingBattle",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"杀死 %boss%"
				];
				this.World.State.m.IsAutosaving = false;
			}

			function update()
			{
				if (!this.Flags.get("IsTutorialBattleDone"))
				{
					if (!this.Flags.get("IsIntroShown"))
					{
						this.Flags.set("IsIntroShown", true);
						this.Sound.play("sounds/intro_battle.wav");
						this.Contract.setScreen("Intro");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						local tile = this.World.State.getPlayer().getTile();
						local p = this.Const.Tactical.CombatInfo.getClone();
						p.Music = this.Const.Music.CivilianTracks;
						p.TerrainTemplate = this.Const.World.TerrainTacticalTemplate[tile.TacticalType];
						p.Tile = tile;
						p.CombatID = "Tutorial1";
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Custom;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Custom;
						p.PlayerDeploymentCallback = this.onPlayerDeployment.bindenv(this);
						p.EnemyDeploymentCallback = this.onAIDeployment.bindenv(this);
						p.IsFleeingProhibited = true;
						p.IsAutoAssigningBases = false;
						this.World.Contracts.startScriptedCombat(p, false, false, false);
					}
				}
				else
				{
					this.Contract.setScreen("IntroAftermath");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Tutorial1")
				{
					this.Flags.set("IsTutorialBattleDone", true);
					local brothers = this.World.getPlayerRoster().getAll();
					brothers[0].setIsAbleToDie(true);
					brothers[1].setIsAbleToDie(true);
					brothers[2].setIsAbleToDie(true);
					this.World.State.m.IsAutosaving = true;
				}
			}

			function onPlayerDeployment()
			{
				for( local x = 0; x != 32; x = x )
				{
					for( local y = 0; y != 32; y = y )
					{
						local tile = this.Tactical.getTileSquare(x, y);
						tile.Level = 0;

						if (x > 11 && x < 22 && y > 12 && y < 21)
						{
							tile.removeObject();

							if (tile.IsHidingEntity)
							{
								tile.clear();
								tile.IsHidingEntity = false;
							}
						}

						y = ++y;
						y = y;
					}

					x = ++x;
					x = x;
				}

				this.Tactical.fillVisibility(this.Const.Faction.Player, true);
				local brothers = this.World.getPlayerRoster().getAll();
				this.Tactical.addEntityToMap(brothers[0], 13, 15 - 13 / 2);
				brothers[0].setIsAbleToDie(false);
				this.Tactical.addEntityToMap(brothers[1], 13, 16 - 13 / 2);
				brothers[1].setIsAbleToDie(false);
				this.Tactical.addEntityToMap(brothers[2], 12, 18 - 12 / 2);
				brothers[2].setIsAbleToDie(false);
				this.Tactical.CameraDirector.addJumpToTileEvent(0, this.Tactical.getTile(6, 17 - 6 / 2), 0, null, null, 0, 0);
				this.Tactical.CameraDirector.addMoveSlowlyToTileEvent(0, this.Tactical.getTile(18, 17 - 18 / 2), 0, null, null, 0, 1000);
				this.Contract.spawnBlood(11, 12);
				this.Contract.spawnBlood(13, 15);
				this.Contract.spawnBlood(14, 17);
				this.Contract.spawnBlood(15, 16);
				this.Contract.spawnBlood(17, 14);
				this.Contract.spawnBlood(15, 15);
				this.Contract.spawnBlood(18, 16);
				this.Contract.spawnBlood(12, 14);
				this.Contract.spawnBlood(13, 16);
				this.Contract.spawnBlood(12, 15);
				this.Contract.spawnBlood(16, 18);
				this.Contract.spawnBlood(15, 17);
				this.Contract.spawnArrow(13, 13);
				this.Contract.spawnArrow(14, 17);
				this.Contract.spawnArrow(17, 15);
				this.Contract.spawnCorpse(12, 13);
				this.Contract.spawnCorpse(16, 14);
				this.Contract.spawnCorpse(17, 16);
				this.Contract.spawnCorpse(15, 14);
				this.Contract.spawnCorpse(14, 18);
			}

			function onAIDeployment()
			{
				local e;
				this.Const.Movement.AnnounceDiscoveredEntities = false;
				e = this.Tactical.spawnEntity("scripts/entity/tactical/humans/bounty_hunter", 16, 16 - 16 / 2);
				e.setFaction(this.Const.Faction.PlayerAnimals);
				e.setName("One-Eye");
				e.getSprite("socket").setBrush("bust_base_player");
				e.assignRandomEquipment();
				e.getSkills().removeByID("perk.overwhelm");
				e.getSkills().removeByID("perk.nimble");
				e.getItems().getItemAtSlot(this.Const.ItemSlot.Body).setArmor(0);

				if (e.getItems().getItemAtSlot(this.Const.ItemSlot.Head) != null)
				{
					e.getItems().getItemAtSlot(this.Const.ItemSlot.Head).removeSelf();
				}

				if (e.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
				{
					e.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand).removeSelf();
				}

				e.getBaseProperties().Hitpoints = 5;
				e.getBaseProperties().MeleeSkill = -200;
				e.getBaseProperties().RangedSkill = 0;
				e.getBaseProperties().MeleeDefense = -200;
				e.getBaseProperties().Initiative = 200;
				e.getSkills().update();
				e.setHitpoints(5);
				e = this.Tactical.spawnEntity("scripts/entity/tactical/humans/bounty_hunter", 15, 18 - 15 / 2);
				e.setFaction(this.Const.Faction.PlayerAnimals);
				e.setName("Captain Bernhard");
				e.getSprite("socket").setBrush("bust_base_player");
				e.getSkills().removeByID("perk.overwhelm");
				e.getSkills().removeByID("perk.nimble");
				local armor = this.new("scripts/items/armor/mail_hauberk");
				armor.setVariant(32);
				armor.setArmor(0);
				e.getItems().equip(armor);
				e.getItems().equip(this.new("scripts/items/weapons/arming_sword"));
				e.getBaseProperties().Hitpoints = 9;
				e.getBaseProperties().MeleeSkill = -200;
				e.getBaseProperties().RangedSkill = 0;
				e.getBaseProperties().MeleeDefense = -200;
				e.getBaseProperties().DamageTotalMult = 0.1;
				e.getBaseProperties().Initiative = 250;
				e.getSkills().update();
				e.setHitpoints(5);
				e = this.Tactical.spawnEntity("scripts/entity/tactical/enemies/bandit_thug", 18, 17 - 18 / 2);
				e.setFaction(this.Const.Faction.Enemy);
				e.getAIAgent().getProperties().OverallDefensivenessMult = 0.0;
				e.getAIAgent().getProperties().BehaviorMult[this.Const.AI.Behavior.ID.Retreat] = 0.0;
				e.assignRandomEquipment();
				e.getBaseProperties().Initiative = 300;
				e.getSkills().update();
				e = this.Tactical.spawnEntity("scripts/entity/tactical/enemies/bandit_thug", 17, 18 - 17 / 2);
				e.setFaction(this.Const.Faction.Enemy);
				e.getAIAgent().getProperties().OverallDefensivenessMult = 0.0;
				e.getAIAgent().getProperties().BehaviorMult[this.Const.AI.Behavior.ID.Retreat] = 0.0;
				e.assignRandomEquipment();
				e.getBaseProperties().Initiative = 200;
				e.getSkills().update();
				e = this.Tactical.spawnEntity("scripts/entity/tactical/enemies/bandit_raider_low", 19, 17 - 19 / 2);
				e.setFaction(this.Const.Faction.Enemy);
				e.setName(this.Flags.get("BossName"));
				e.getAIAgent().getProperties().OverallDefensivenessMult = 0.0;
				e.getAIAgent().addBehavior(this.new("scripts/ai/tactical/behaviors/ai_retreat_always"));
				local items = e.getItems();
				items.equip(this.new("scripts/items/armor/patched_mail_shirt"));
				items.equip(this.new("scripts/items/weapons/hunting_bow"));
				this.Flags.set("BossHead", e.getSprite("head").getBrush().Name);
				this.Flags.set("BossBeard", e.getSprite("beard").HasBrush ? e.getSprite("beard").getBrush().Name : "");
				this.Flags.set("BossBeardTop", e.getSprite("beard_top").HasBrush ? e.getSprite("beard_top").getBrush().Name : "");
				this.Flags.set("BossHair", e.getSprite("hair").HasBrush ? e.getSprite("hair").getBrush().Name : "");
				e.getBaseProperties().Hitpoints = 300;
				e.getSkills().update();
				e.setHitpoints(180);
				e.setMoraleState(this.Const.MoraleState.Wavering);
				this.Const.Movement.AnnounceDiscoveredEntities = true;
			}

		});
		this.m.States.push({
			ID = "ReturnAfterIntro",
			function start()
			{
				this.Contract.m.Home.getSprite("selection").Visible = true;
				this.Contract.m.BulletpointsObjectives = [
					"Return to " + this.Contract.m.Home.getName() + " to get paid"
				];
				this.World.State.getPlayer().setAttackable(false);
				this.World.State.m.IsAutosaving = true;
			}

			function update()
			{
				if (this.World.getTime().Days > 2)
				{
					this.World.State.getPlayer().setAttackable(true);
				}

				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					this.Contract.setScreen("PaymentAfterIntro1", false);
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Recruit",
			function start()
			{
				this.Contract.m.Home.getSprite("selection").Visible = false;
				this.Contract.m.BigCity.getSprite("selection").Visible = true;
				this.Contract.m.BulletpointsObjectives = [
					"拜访%townname%%citydirection%的%bigcity%"
				];

				if (this.World.getPlayerRoster().getSize() < 6)
				{
					if (this.Math.max(1, 6 - this.World.getPlayerRoster().getSize()) > 1)
					{
						this.Contract.m.BulletpointsObjectives.push("Recruit at least " + this.Math.max(1, 6 - this.World.getPlayerRoster().getSize()) + " more men");
					}
					else
					{
						this.Contract.m.BulletpointsObjectives.push("Recruit at least one more man");
					}
				}

				this.Contract.m.BulletpointsObjectives.push("Buy weapons and armor for your men");
				this.World.State.getPlayer().setAttackable(false);
			}

			function update()
			{
				if (this.World.getTime().Days > 4)
				{
					this.World.State.getPlayer().setAttackable(true);
				}

				if (this.World.getPlayerRoster().getSize() >= 6 && this.Flags.get("IsMarketplaceTipShown"))
				{
					this.Contract.setState("ReturnAfterRecruiting");
				}
				else if (this.World.getPlayerRoster().getSize() >= 6 && this.Contract.m.BulletpointsObjectives.len() == 3)
				{
					this.start();
					this.World.Contracts.updateActiveContract();
				}
				else if (!this.Flags.get("IsMarketplaceTipShown") && this.World.State.getPlayer().getDistanceTo(this.Contract.m.BigCity.get()) <= 600)
				{
					this.Flags.set("IsMarketplaceTipShown", true);
					this.Contract.setScreen("MarketplaceTip");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "ReturnAfterRecruiting",
			function start()
			{
				this.Contract.m.Home.getSprite("selection").Visible = true;
				this.Contract.m.BigCity.getSprite("selection").Visible = false;
				this.Contract.m.BulletpointsObjectives = [
					"Return to %employer% in %townname%"
				];
				this.World.State.getPlayer().setAttackable(false);
			}

			function update()
			{
				if (this.World.getTime().Days > 6)
				{
					this.World.State.getPlayer().setAttackable(true);
				}

				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					local tile = this.Contract.getTileToSpawnLocation(this.World.State.getPlayer().getTile(), 6, 10, [
						this.Const.World.TerrainType.Swamp,
						this.Const.World.TerrainType.Forest,
						this.Const.World.TerrainType.LeaveForest,
						this.Const.World.TerrainType.SnowyForest,
						this.Const.World.TerrainType.Shore,
						this.Const.World.TerrainType.Ocean,
						this.Const.World.TerrainType.Mountains
					], false);
					tile.clear();
					this.Contract.m.Location = this.WeakTableRef(this.World.spawnLocation("scripts/entity/world/locations/bandit_hideout_location", tile.Coords));
					this.Contract.m.Location.setResources(0);
					this.Contract.m.Location.setBanner("banner_deserters");
					this.Contract.m.Location.getSprite("location_banner").Visible = false;
					this.Contract.m.Location.setName(this.Flags.get("LocationName"));
					this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).addSettlement(this.Contract.m.Location.get(), false);
					this.Contract.m.Location.setDiscovered(true);
					this.World.uncoverFogOfWar(this.Contract.m.Location.getTile().Pos, 400.0);
					this.Contract.m.Location.clearTroops();
					this.Const.World.Common.addTroop(this.Contract.m.Location, {
						Type = this.Const.World.Spawn.Troops.BanditMarksmanLOW
					}, false);
					this.Const.World.Common.addTroop(this.Contract.m.Location, {
						Type = this.Const.World.Spawn.Troops.BanditThug
					}, false);
					this.Const.World.Common.addTroop(this.Contract.m.Location, {
						Type = this.Const.World.Spawn.Troops.BanditThug
					}, false);

					if (this.World.Assets.getCombatDifficulty() >= this.Const.Difficulty.Normal)
					{
						this.Const.World.Common.addTroop(this.Contract.m.Location, {
							Type = this.Const.World.Spawn.Troops.BanditThug
						}, false);
					}

					if (this.World.Assets.getCombatDifficulty() >= this.Const.Difficulty.Hard)
					{
						this.Const.World.Common.addTroop(this.Contract.m.Location, {
							Type = this.Const.World.Spawn.Troops.BanditThug
						}, false);
					}

					this.Contract.m.Location.updateStrength();
					this.Contract.setScreen("Briefing");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Finale",
			function start()
			{
				this.Contract.m.Home.getSprite("selection").Visible = false;

				if (this.Contract.m.Location != null && !this.Contract.m.Location.isNull())
				{
					this.Contract.m.Location.getSprite("selection").Visible = true;
				}

				if (this.Contract.m.BigCity != null && !this.Contract.m.BigCity.isNull())
				{
					this.Contract.m.BigCity.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Location != null && !this.Contract.m.Location.isNull())
				{
					this.Contract.m.Location.setOnCombatWithPlayerCallback(this.onLocationAttacked.bindenv(this));
				}

				this.Contract.m.BulletpointsObjectives = [
					"Travel to %location% %direction% of %townname%",
					"Kill %boss%"
				];
				this.Contract.m.BulletpointsPayment = [
					"Get 400 crowns on completion"
				];
				this.World.State.getPlayer().setAttackable(false);
			}

			function update()
			{
				if (this.World.getTime().Days > 8)
				{
					this.World.State.getPlayer().setAttackable(true);
				}

				if (this.Flags.has("IsHoggartDead") || this.Contract.m.Location == null || this.Contract.m.Location.isNull() || !this.Contract.m.Location.isAlive())
				{
					if (this.Contract.m.Location != null && !this.Contract.m.Location.isNull())
					{
						this.Contract.m.Location.die();
						this.Contract.m.Location = null;
					}

					this.Contract.setScreen("AfterFinale");
					this.World.Contracts.showActiveContract();
				}
			}

			function onLocationAttacked( _dest, _isPlayerAttacking = true )
			{
				local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
				properties.Music = this.Const.Music.BanditTracks;
				properties.BeforeDeploymentCallback = this.onDeployment.bindenv(this);
				this.World.Contracts.startScriptedCombat(properties, true, true, true);
			}

			function onDeployment()
			{
				this.Tactical.getTileSquare(21, 17).removeObject();
				local e = this.Tactical.spawnEntity("scripts/entity/tactical/enemies/bandit_raider_low", 21, 17 - 21 / 2);
				e.setFaction(this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getID());
				e.setName(this.Flags.get("BossName"));
				e.m.IsGeneratingKillName = false;
				e.getAIAgent().getProperties().BehaviorMult[this.Const.AI.Behavior.ID.Retreat] = 0.0;
				e.getTags().add("IsFinalBoss", true);
				local items = e.getItems();
				items.equip(this.new("scripts/items/armor/patched_mail_shirt"));
				items.equip(this.new("scripts/items/weapons/falchion"));
				local shield = this.new("scripts/items/shields/wooden_shield");
				shield.setVariant(4);
				items.equip(shield);
				e.getSprite("head").setBrush(this.Flags.get("BossHead"));
				e.getSprite("beard").setBrush(this.Flags.get("BossBeard"));
				e.getSprite("beard_top").setBrush(this.Flags.get("BossBeardTop"));
				e.getSprite("hair").setBrush(this.Flags.get("BossHair"));
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getTags().get("IsFinalBoss") == true)
				{
					this.Flags.set("IsHoggartDead", true);
					this.updateAchievement("TrialByFire", 1, 1);
				}
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.Home.getSprite("selection").Visible = true;
				this.Contract.m.BigCity.getSprite("selection").Visible = false;
				this.Contract.m.BulletpointsObjectives = [
					"Return to %employer% in %townname% to get paid"
				];
				this.World.State.getPlayer().setAttackable(false);
			}

			function update()
			{
				if (this.World.getTime().Days > 10)
				{
					this.World.State.getPlayer().setAttackable(true);
				}

				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					this.Contract.setScreen("Success");
					this.World.Contracts.showActiveContract();
				}
				else if (!this.Flags.get("IsCampingTipShown") && this.Time.getVirtualTimeF() - this.World.Events.getLastBattleTime() >= 10.0)
				{
					this.Flags.set("IsCampingTipShown", true);
					this.Contract.setScreen("CampingTip");
					this.World.Contracts.showActiveContract();
				}
			}

		});
	}

	function createScreens()
	{
		this.m.Screens.push({
			ID = "Intro",
			Title = "最后一战",
			Text = "[img]gfx/ui/events/event_21.png[/img]情形大糟。两天前战团受雇去追踪%boss%和他的突击兵，但你却被敌人先发现了。一场埋伏。有些人调笑马匹时被一箭刺穿喉咙。箭羽从四面八方袭来。士兵们呼喊尖叫着，死前高声哀嚎。\n\n 箭羽平息后你和其他士兵抽出武器，也只沦落到要跪。你的身侧中了一箭。疼痛呼喊。瞥到冲锋的士兵们英勇战到最后一刻，如钢铁互相撞击。\n\n在看到队长然后跟他最后一次点头示意后，敌人砍下了他的头颅。你手下现在只剩下几个人了。你忍着剧痛颤抖着靠在剑上，并用尽全部意志力缓缓起身…… ",
			Image = "",
			List = [],
			Options = [
				{
					Text = "战斗到底！",
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
			ID = "IntroAftermath",
			Title = "结果",
			Text = "[img]gfx/ui/events/event_22.png[/img]你还活着。你们获胜了。\n\n强撑的精气神褪去，你再无法支撑，倒在地上。你咬紧牙关。折断箭杆。你的胸腔肿起，每次呼吸都带来巨大的疼痛感，一切都变得模糊。\n\n战团满目疮痍，只剩下不过几个人。而那个私生子霍加特人如其名，像一只黄鼠狼一样仓皇逃窜。%SPEECH_ON% 现在怎么做，队长？ %SPEECH_OFF%后面传来一阵声音。是坐在你旁边的斧手，他将浸染血迹的斧头枕在腿上。你转头想回复他，但还没开口他就继续说道。%SPEECH_ON%伯恩哈德死了，他们抹了他的脖子。他是个好人也是位很出色的领袖，但一次犯错就葬送了这一切。现在是由你来带队了，不是吗？%SPEECH_OFF% 矛兵依旧呼吸沉重地加入到你们当中来。 然后是弓弩手。%SPEECH_ON% 改天再举行庆祝仪式吧。我们先好好安葬了他然后回到任务点去把报酬收回来。 毕竟，那个鼹鼠家伙是逃掉了。 还有，队长，我们还应该先好好看看你的伤口。 我们可不想再换成别人管事，对吧？%SPEECH_OFF%",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那就这样吧。",
					function getResult()
					{
						this.Contract.setState("ReturnAfterIntro");
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.World.getPlayerRoster().getAll()[1].getImagePath());
				this.Characters.push(this.World.getPlayerRoster().getAll()[0].getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "PaymentAfterIntro1",
			Title = "返回 %townname%",
			Text = "[img]gfx/ui/events/event_79.png[/img]当你来到这里时旁观者一定会想你又有好故事可讲了。 4位浸染鲜血伤痕累累的雇佣兵倒霉运了。 几天前雇佣战团的那个人，无疑期待着你以更荣耀的情景归来。\n\n不过，雇主依然在家中迎接了你们并奉上面包美酒，仆人还叫来一位医师。老人手臂颤抖着医治你们的伤口，期间除了间歇性的咕哝和喘息声外少有闲语。一根钉刺过你的皮肤，还有数针要缝。你咬紧牙关直到仿佛听到破碎的声响。 雇主坐在你的旁边询问你是否干掉了霍加特。你摇了摇头道。 %SPEECH_ON%我们杀光了他的部下，但黄鼠狼最终逃脱了.%SPEECH_OFF% 医师挥舞着灼热的火戳，示意他要把它放到伤口。你点点头然后他那样做了。不过一瞬间，肉体在火光中遭受剧痛。 雇主递给你一杯酒。 %SPEECH_ON%辛苦了，佣兵。 强盗被解决了，虽然霍加特还活着是挺遗憾的。%SPEECH_OFF% ",
			Characters = [],
			ShowEmployer = true,
			List = [],
			Options = [
				{
					Text = "我们希望拿到我们的酬金。",
					function getResult()
					{
						return "PaymentAfterIntro2";
					}

				}
			],
			function start()
			{
				this.World.Assets.addMoney(400);
				this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Killed Hoggart\'s men");
			}

		});
		this.m.Screens.push({
			ID = "PaymentAfterIntro2",
			Title = "返回 %townname%",
			Text = "[img]gfx/ui/events/event_79.png[/img]%employer% 气喘吁吁地说道.%SPEECH_ON%好吧，当然了！按照约定的400克朗。%SPEECH_OFF%他向一位带着报酬冲到你身边的仆人打招呼.%SPEECH_ON%我在想……我能再雇佣你一次吗？我很想一次彻底解决霍加特的麻烦。当然了，我也会支付报酬。再400克朗，如何？%SPEECH_OFF% %bro1%站起来开口道.%SPEECH_ON%是的，%companyname%战团现在是破碎不堪，但我们会重建它的！没了%companyname%，%bro2%会把钱全花在喝酒上最终流落街头乞讨 , 并且 %bro3% 以我们所有知道的神明打赌他会去追妇女到南墙。我们需要 %companyname%, 这是我们的全部了！你怎么说，队长？?%SPEECH_OFF%%bro2% 打了个嗝朝你举杯. %bro3% 玩味地用拇指拨了拨鼻子点头道.%SPEECH_ON%杀不杀那个叫霍加特的混蛋，随你，队长.%SPEECH_OFF%",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "是的，我们跟霍加特的事还没完。",
					function getResult()
					{
						return "PaymentAfterIntro3";
					}

				},
				{
					Text = "不，我们希望去别处赚钱.",
					function getResult()
					{
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Tactical.getEntityByID(this.Contract.m.EmployerID).getImagePath());
				this.Characters.push(this.World.getPlayerRoster().getAll()[0].getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "PaymentAfterIntro3",
			Title = "返回 %townname%",
			Text = "[img]gfx/ui/events/event_79.png[/img]雇主满意地拍拍手。%SPEECH_ON%棒极了！我的线人需要时间找到霍加特现在藏匿在哪。与此同时，我建议你囤积些补给那样就能在需要的时候做好准备做了结。我应该在至少几天后见你！%SPEECH_OFF%当你离开雇主家然后站在郊区时，弓弩手想跟你聊聊。%SPEECH_ON%我们需要更多士兵，队长。我知道我在那说了大话，但虚张声势什么用也没有。我们需要更多的士兵。我们要找到3个以上的佣兵，给他们买些趁手的武器，给他们穿上我们能提供的最精良的护甲。%SPEECH_OFF%男人停顿下来看了看四周。%SPEECH_ON%我打赌这镇上会有一两个想换种新生活的农民，或者我们可以去别的城镇。这些城镇居民不像乡村土包子一样强硬，但我们更倾向于找到有作战经验的人。%SPEECH_OFF%",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那就是我们要做的.",
					function getResult()
					{
						this.Contract.setState("Recruit");
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Tactical.getEntityByID(this.Contract.m.EmployerID).getImagePath());
				this.Characters.push(this.World.getPlayerRoster().getAll()[0].getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "MarketplaceTip",
			Title = "路上...",
			Text = "[img]gfx/ui/events/event_77.png[/img]当%bigcity%城镇的天际线出现在视线中时，%bro3%找你谈话。%SPEECH_ON%我从来没来过这里，但我去过一个很像这里的地方。像这样的城市很适合销售这样的小东西，自大的混蛋们喜欢这样移送货物。有这么多商人，你也能找到近乎自己需要的任何东西。关注特价品，别被那些宰人不眨眼的奸商阴了。%SPEECH_OFF% %bro2%建议你该如何做是合适的。%SPEECH_ON%如果有个好酒馆，我觉得我们应该先去那。没什么能比酒更能帮助一个不走运的人了。神知道这一切是我们赢得的！%SPEECH_OFF% %bro3%摇摇头。%SPEECH_ON%每次我们进城你都这么说！甚至在已经醉了的时候你还这么说过！%SPEECH_OFF%",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我会记住的。",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				if (this.World.getPlayerRoster().getSize() >= 3)
				{
					this.Characters.push(this.World.getPlayerRoster().getAll()[2].getImagePath());
					this.Characters.push(this.World.getPlayerRoster().getAll()[1].getImagePath());
				}
			}

		});
		this.m.Screens.push({
			ID = "Briefing",
			Title = "未完成的任务",
			Text = "[img]gfx/ui/events/event_79.png[/img]你见到雇主正在来回踱步。差点用火戳痛死你的医生站在旁边。他扣着自己指甲缝里干掉的血块。雇主拍了拍手。%SPEECH_ON%你终于来了。我有好消息！我们抓到了一个之前效力于霍加特的人！我跟他聊过之后发现了霍加特正在一处隐蔽的地点疗养。%SPEECH_OFF%医生清了清嗓子，像一个想要油漆的少女一样把他的手指伸了出来。他说话的声音好像在辨认他将要切除的一种疾病。%SPEECH_ON%叫霍加特强盗正躲在一处小屋中。基于我和他部下最有礼貌的交谈后，霍加特知道了你们正在追赶他且从上次你见到他后就在召集更多人马。%SPEECH_OFF%雇主点点头，挥手示意你离开。%SPEECH_ON%祝你好运，佣兵。%SPEECH_OFF%",
			ShowEmployer = true,
			List = [],
			Options = [
				{
					Text = "我们会提着他的头回来见你！",
					function getResult()
					{
						this.Contract.setState("Finale");
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "AfterFinale",
			Title = "战斗之后",
			Text = "[img]gfx/ui/events/event_87.png[/img]霍加特死在了血泊中，被扭曲成一种怪诞而又惊慌失措的姿势。他这次没能逃跑。你在他的尸体上放了一只靴子，看看你的兄弟。%SPEECH_ON%为了战团，为了所有倒下的人。%SPEECH_OFF%有人向死去的霍加特吐了口口水。%SPEECH_ON%让我们拿这个混蛋的头，回到雇主那儿。%SPEECH_OFF%",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "获得报酬的时间到了",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				if (this.World.getPlayerRoster().getSize() >= 3)
				{
					this.Characters.push(this.World.getPlayerRoster().getAll()[2].getImagePath());
				}
			}

		});
		this.m.Screens.push({
			ID = "CampingTip",
			Title = "路上...",
			Text = "[img]gfx/ui/events/event_75.png[/img]%bro3% 来到你身边。%SPEECH_ON%有时间吗，队长?%SPEECH_OFF%你向他点头示意。%SPEECH_ON%这场战斗让一些装备变得更糟，一些人也得到了不错的装备。我们可以在行军的时候把人和设备都修补好，但是扎营修理会更快。当然，如果我们扎营，我们就应该提防伏击。这地方的营火可以从各个方向看到.%SPEECH_OFF%",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我会记住的。",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				if (this.World.getPlayerRoster().getSize() >= 3)
				{
					this.Characters.push(this.World.getPlayerRoster().getAll()[2].getImagePath());
				}
			}

		});
		this.m.Screens.push({
			ID = "Success",
			Title = "返回 %townname%",
			Text = "[img]gfx/ui/events/event_24.png[/img]战队以胜利者的身份返回%townname%, 这一次他们抬头挺胸. 战队不再是从前的大小,但他们仍然是一个不容小觑的力量。\n\n 你把他的头放在一个袋子里，			扔到了雇主的脚下。他吓了一跳，但医生迅速地把头捡起，盯着它，然后点了点头。雇主走近仔细地看了强盗的脸和眼睛。%SPEECH_ON%是的，是的... 那是他的丑陋的脸。仆人!把他的钱给他！%SPEECH_OFF%钱到手了，你大声对兄弟说。%SPEECH_ON%只要我们的血管里有血，只要我们能拿着剑和盾，就会有我们的战队。整个世界的人们都会知道!%SPEECH_OFF%大家欢呼。某人把他的手放在你的肩膀上。%SPEECH_ON%你做得很好,队长。无论你在哪里领导我们，我们都将在战斗中跟随你！%SPEECH_OFF%",
			ShowEmployer = true,
			Image = "",
			List = [],
			Options = [
				{
					Text = "为了兄弟!",
					function getResult()
					{
						this.World.Tags.set("IsHoggartDead", true);
						this.Music.setTrackList(this.Const.Music.WorldmapTracks, this.Const.Music.CrossFadeTime, true);
						this.World.Assets.addMoney(400);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Killed Hoggart for good");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.Music.setTrackList(this.Const.Music.VictoryTracks, this.Const.Music.CrossFadeTime);
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().getID() == "background.companion")
					{
						bro.improveMood(1.0, "Avenged the company");
					}
					else
					{
						bro.improveMood(0.25, "Gained confidence in your leadership");
					}
				}

				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]400[/color] Crowns"
				});
			}

		});
	}

	function spawnCorpse( _x, _y )
	{
		local tile = this.Tactical.getTileSquare(_x, _y);
		local armors = [
			"bust_body_10_dead",
			"bust_body_13_dead",
			"bust_body_14_dead",
			"bust_body_15_dead",
			"bust_body_19_dead",
			"bust_body_20_dead",
			"bust_body_22_dead",
			"bust_body_23_dead",
			"bust_body_24_dead",
			"bust_body_26_dead"
		];
		local armorSprite = armors[this.Math.rand(0, armors.len() - 1)];
		local flip = this.Math.rand(0, 1) == 1;
		local decal = tile.spawnDetail(armorSprite, this.Const.Tactical.DetailFlag.Corpse, flip, false, this.Const.Combat.HumanCorpseOffset);
		decal.Scale = 0.9;
		decal.setBrightness(0.9);
		decal = tile.spawnDetail("bust_naked_body_01_dead", this.Const.Tactical.DetailFlag.Corpse, flip, false, this.Const.Combat.HumanCorpseOffset);
		decal.Scale = 0.9;
		decal.setBrightness(0.9);

		if (this.Math.rand(1, 100) <= 25)
		{
			decal = tile.spawnDetail("bust_body_guts_0" + this.Math.rand(1, 3), this.Const.Tactical.DetailFlag.Corpse, flip, false, this.Const.Combat.HumanCorpseOffset);
			decal.Scale = 0.9;
		}
		else if (this.Math.rand(1, 100) <= 25)
		{
			decal = tile.spawnDetail("bust_head_smashed_01", this.Const.Tactical.DetailFlag.Corpse, flip, false, this.Const.Combat.HumanCorpseOffset);
			decal.Scale = 0.9;
		}
		else
		{
			decal = tile.spawnDetail(armorSprite + "_arrows", this.Const.Tactical.DetailFlag.Corpse, flip, false, this.Const.Combat.HumanCorpseOffset);
			decal.Scale = 0.9;
		}

		local color = this.Const.HairColors.All[this.Math.rand(0, this.Const.HairColors.All.len() - 1)];
		local hairSprite = "hair_" + color + "_" + this.Const.Hair.AllMale[this.Math.rand(0, this.Const.Hair.AllMale.len() - 1)];
		local beardSprite = "beard_" + color + "_" + this.Const.Beards.All[this.Math.rand(0, this.Const.Beards.All.len() - 1)];
		local headSprite = this.Const.Faces.AllMale[this.Math.rand(0, this.Const.Faces.AllMale.len() - 1)];
		local decal = tile.spawnDetail(headSprite + "_dead", this.Const.Tactical.DetailFlag.Corpse, flip, false, this.Const.Combat.HumanCorpseOffset);
		decal.Scale = 0.9;
		decal.setBrightness(0.9);

		if (this.Math.rand(1, 100) <= 50)
		{
			local decal = tile.spawnDetail(beardSprite + "_dead", this.Const.Tactical.DetailFlag.Corpse, flip, false, this.Const.Combat.HumanCorpseOffset);
			decal.Scale = 0.9;
			decal.setBrightness(0.9);
		}

		if (this.Math.rand(1, 100) <= 90)
		{
			local decal = tile.spawnDetail(hairSprite + "_dead", this.Const.Tactical.DetailFlag.Corpse, flip, false, this.Const.Combat.HumanCorpseOffset);
			decal.Scale = 0.9;
			decal.setBrightness(0.9);
		}

		local pools = this.Math.rand(this.Const.Combat.BloodPoolsAtDeathMin, this.Const.Combat.BloodPoolsAtDeathMax);

		for( local i = 0; i < pools; i = i )
		{
			this.Tactical.spawnPoolEffect(this.Const.BloodPoolDecals[this.Const.BloodType.Red][this.Math.rand(0, this.Const.BloodPoolDecals[this.Const.BloodType.Red].len() - 1)], tile, this.Const.BloodPoolTerrainAlpha[tile.Type], 1.0, this.Const.Tactical.DetailFlag.Corpse);
			i = ++i;
			i = i;
		}

		local corpse = clone this.Const.Corpse;
		corpse.CorpseName = "Someone";
		tile.Properties.set("Corpse", corpse);
	}

	function spawnBlood( _x, _y )
	{
		local tile = this.Tactical.getTileSquare(_x, _y);
		tile.spawnDetail(this.Const.BloodDecals[this.Const.BloodType.Red][this.Math.rand(0, this.Const.BloodDecals[this.Const.BloodType.Red].len() - 1)]);
	}

	function spawnArrow( _x, _y )
	{
		local tile = this.Tactical.getTileSquare(_x, _y);
		tile.spawnDetail(this.Const.ProjectileDecals[this.Const.ProjectileType.Arrow][this.Math.rand(0, this.Const.ProjectileDecals[this.Const.ProjectileType.Arrow].len() - 1)], 0, true);
	}

	function onPrepareVariables( _vars )
	{
		local bros = this.World.getPlayerRoster().getAll();
		_vars.push([
			"location",
			this.m.Flags.get("LocationName")
		]);
		_vars.push([
			"bigcity",
			this.m.BigCity.getName()
		]);
		_vars.push([
			"boss",
			this.m.Flags.get("BossName")
		]);
		_vars.push([
			"direction",
			this.m.Location != null && !this.m.Location.isNull() ? this.Const.Strings.Direction8[this.m.Home.getTile().getDirection8To(this.m.Location.getTile())] : ""
		]);
		_vars.push([
			"citydirection",
			this.m.BigCity != null && !this.m.BigCity.isNull() ? this.Const.Strings.Direction8[this.m.Home.getTile().getDirection8To(this.m.BigCity.getTile())] : ""
		]);
		_vars.push([
			"terrain",
			this.m.Location != null && !this.m.Location.isNull() ? this.Const.Strings.Terrain[this.m.Location.getTile().Type] : ""
		]);
		_vars.push([
			"bro1",
			bros[0].getName()
		]);
		_vars.push([
			"bro2",
			bros.len() >= 2 ? bros[1].getName() : bros[0].getName()
		]);
		_vars.push([
			"bro3",
			bros.len() >= 3 ? bros[2].getName() : bros[0].getName()
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Location != null && !this.m.Location.isNull())
			{
				this.m.Location.getSprite("selection").Visible = false;
			}

			if (this.m.BigCity != null && !this.m.BigCity.isNull())
			{
				this.m.BigCity.getSprite("selection").Visible = false;
			}

			this.m.Home.getSprite("selection").Visible = false;
			this.World.Ambitions.setDelay(12);
		}

		this.World.State.getPlayer().setAttackable(true);
		this.World.State.m.IsAutosaving = true;
	}

	function onIsValid()
	{
		return true;
	}

	function onSerialize( _out )
	{
		if (this.m.Location != null && !this.m.Location.isNull())
		{
			_out.writeU32(this.m.Location.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		if (this.m.BigCity != null && !this.m.BigCity.isNull())
		{
			_out.writeU32(this.m.BigCity.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local location = _in.readU32();

		if (location != 0)
		{
			this.m.Location = this.WeakTableRef(this.World.getEntityByID(location));
		}

		local bigCity = _in.readU32();

		if (bigCity != 0)
		{
			this.m.BigCity = this.WeakTableRef(this.World.getEntityByID(bigCity));
		}

		this.contract.onDeserialize(_in);
	}

});

