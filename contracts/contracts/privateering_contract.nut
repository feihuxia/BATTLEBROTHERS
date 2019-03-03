this.privateering_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Item = null,
		CurrentObjective = null,
		Objectives = [],
		LastOrderUpdateTime = 0.0
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

		this.m.Type = "contract.privateering";
		this.m.Name = "私掠";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		local nobleHouses = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);

		foreach( i, h in nobleHouses )
		{
			if (h.getID() == this.getFaction())
			{
				nobleHouses.remove(i);
				break;
			}
		}

		nobleHouses.sort(this.onSortBySettlements);
		this.m.Flags.set("FeudingHouseID", nobleHouses[0].getID());
		this.m.Flags.set("FeudingHouseName", nobleHouses[0].getName());
		this.m.Flags.set("RivalHouseID", nobleHouses[1].getID());
		this.m.Flags.set("RivalHouseName", nobleHouses[1].getName());
		this.m.Payment.Pool = 1300 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
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
		this.m.Flags.set("StartDay", 0);
		this.m.Flags.set("LastUpdateDay", 0);
		this.m.Flags.set("SearchPartyLastNotificationTime", 0);
		this.contract.start();
	}

	function onSortBySettlements( _a, _b )
	{
		if (_a.getSettlements().len() > _b.getSettlements().len())
		{
			return -1;
		}
		else if (_a.getSettlements().len() < _b.getSettlements().len())
		{
			return 1;
		}

		return 0;
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Flags.set("StartDay", this.World.getTime().Days);
				this.Contract.m.BulletpointsObjectives = [
					"前往%feudfamily%的领地",
					"烧杀抢夺",
					"剿灭任何车队或巡逻队",
					"5天后返回"
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
				local f = this.World.FactionManager.getFaction(this.Flags.get("FeudingHouseID"));
				f.addPlayerRelation(-99.0, "Took sides in the war");
				this.Flags.set("StartDay", this.World.getTime().Days);
				local nonIsolatedSettlements = [];

				foreach( s in f.getSettlements() )
				{
					if (s.isIsolated())
					{
						continue;
					}

					nonIsolatedSettlements.push(s);
					local a = s.getActiveAttachedLocations();

					if (a.len() == 0)
					{
						continue;
					}

					local obj = a[this.Math.rand(0, a.len() - 1)];
					this.Contract.m.Objectives.push(this.WeakTableRef(obj));
					obj.clearTroops();

					if (s.isMilitary())
					{
						if (obj.isMilitary())
						{
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Noble, this.Math.rand(90, 120) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						}
						else
						{
							local r = this.Math.rand(1, 100);

							if (r <= 10)
							{
								this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Mercenaries, this.Math.rand(90, 110) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
							}
							else
							{
								this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Noble, this.Math.rand(70, 100) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
							}
						}
					}
					else if (obj.isMilitary())
					{
						this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Militia, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
					}
					else
					{
						local r = this.Math.rand(1, 100);

						if (r <= 15)
						{
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Mercenaries, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						}
						else if (r <= 30)
						{
							obj.getTags().set("HasNobleProtection", true);
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Noble, this.Math.rand(80, 100) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						}
						else if (r <= 70)
						{
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Militia, this.Math.rand(70, 110) * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						}
						else
						{
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Peasants, this.Math.rand(70, 100));
						}
					}

					if (this.Contract.m.Objectives.len() >= 3)
					{
						break;
					}
				}

				local origin = nonIsolatedSettlements[this.Math.rand(0, nonIsolatedSettlements.len() - 1)];
				local party = f.spawnEntity(origin.getTile(), origin.getName() + " Company", true, this.Const.World.Spawn.Noble, 190 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.getSprite("body").setBrush(party.getSprite("body").getBrush().Name + "_" + f.getBannerString());
				party.setDescription("Professional soldiers in service to local lords.");
				this.Contract.m.UnitsSpawned.push(party.getID());
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
				local wait = this.new("scripts/ai/world/orders/wait_order");
				wait.setTime(9000.0);
				c.addOrder(wait);
				local r = this.Math.rand(1, 100);

				if (r <= 15)
				{
					local rival = this.World.FactionManager.getFaction(this.Flags.get("RivalHouseID"));

					if (!f.getFlags().get("Betrayed"))
					{
						this.Flags.set("IsChangingSides", true);
						local i = this.Math.rand(1, 18);
						local item;

						if (i == 1)
						{
							item = this.new("scripts/items/weapons/named/named_axe");
						}
						else if (i == 2)
						{
							item = this.new("scripts/items/weapons/named/named_billhook");
						}
						else if (i == 3)
						{
							item = this.new("scripts/items/weapons/named/named_cleaver");
						}
						else if (i == 4)
						{
							item = this.new("scripts/items/weapons/named/named_crossbow");
						}
						else if (i == 5)
						{
							item = this.new("scripts/items/weapons/named/named_dagger");
						}
						else if (i == 6)
						{
							item = this.new("scripts/items/weapons/named/named_flail");
						}
						else if (i == 7)
						{
							item = this.new("scripts/items/weapons/named/named_greataxe");
						}
						else if (i == 8)
						{
							item = this.new("scripts/items/weapons/named/named_greatsword");
						}
						else if (i == 9)
						{
							item = this.new("scripts/items/weapons/named/named_javelin");
						}
						else if (i == 10)
						{
							item = this.new("scripts/items/weapons/named/named_longaxe");
						}
						else if (i == 11)
						{
							item = this.new("scripts/items/weapons/named/named_mace");
						}
						else if (i == 12)
						{
							item = this.new("scripts/items/weapons/named/named_spear");
						}
						else if (i == 13)
						{
							item = this.new("scripts/items/weapons/named/named_sword");
						}
						else if (i == 14)
						{
							item = this.new("scripts/items/weapons/named/named_throwing_axe");
						}
						else if (i == 15)
						{
							item = this.new("scripts/items/weapons/named/named_two_handed_hammer");
						}
						else if (i == 16)
						{
							item = this.new("scripts/items/weapons/named/named_warbow");
						}
						else if (i == 17)
						{
							item = this.new("scripts/items/weapons/named/named_warbrand");
						}
						else if (i == 18)
						{
							item = this.new("scripts/items/weapons/named/named_warhammer");
						}

						item.onAddedToStash("");
						this.Contract.m.Item = item;
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
				this.Contract.m.BulletpointsObjectives = [];

				foreach( obj in this.Contract.m.Objectives )
				{
					if (obj != null && !obj.isNull() && obj.isActive())
					{
						this.Contract.m.BulletpointsObjectives.push("摧毁 " + obj.getSettlement().getName() + " 附近的 " + obj.getName());
						obj.getSprite("selection").Visible = true;
						obj.setAttackable(true);
						obj.setOnCombatWithPlayerCallback(this.onCombatWithLocation.bindenv(this));
					}
				}

				this.Contract.m.BulletpointsObjectives.push("摧毁任何%feudfamily%的商队或巡逻队 ");
				this.Contract.m.BulletpointsObjectives.push("在 %days% 返回");
				this.Contract.m.CurrentObjective = null;
			}

			function update()
			{
				if (this.Flags.get("LastUpdateDay") != this.World.getTime().Days)
				{
					if (this.World.getTime().Days - this.Flags.get("StartDay") >= 5)
					{
						this.Contract.setScreen("TimeIsUp");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Flags.set("LastUpdateDay", this.World.getTime().Days);
						this.start();
						this.World.State.getWorldScreen().updateContract(this.Contract);
					}
				}

				if (this.Contract.m.UnitsSpawned.len() != 0 && this.Time.getVirtualTimeF() - this.Contract.m.LastOrderUpdateTime > 2.0)
				{
					this.Contract.m.LastOrderUpdateTime = this.Time.getVirtualTimeF();
					local party = this.World.getEntityByID(this.Contract.m.UnitsSpawned[0]);
					local playerTile = this.World.State.getPlayer().getTile();

					if (party != null && party.getTile().getDistanceTo(playerTile) > 3)
					{
						local f = this.World.FactionManager.getFaction(this.Flags.get("FeudingHouseID"));
						local nearEnemySettlement = false;

						foreach( s in f.getSettlements() )
						{
							if (s.getTile().getDistanceTo(playerTile) <= 6)
							{
								nearEnemySettlement = true;
								break;
							}
						}

						if (nearEnemySettlement)
						{
							local c = party.getController();
							c.clearOrders();
							local move = this.new("scripts/ai/world/orders/move_order");
							move.setDestination(this.World.State.getPlayer().getTile());
							c.addOrder(move);
							local wait = this.new("scripts/ai/world/orders/wait_order");
							wait.setTime(this.World.getTime().SecondsPerDay * 1);
							c.addOrder(wait);

							if (party.getTile().getDistanceTo(playerTile) <= 8 && this.Time.getVirtualTimeF() - this.Flags.get("SearchPartyLastNotificationTime") >= 300.0)
							{
								this.Flags.set("SearchPartyLastNotificationTime", this.Time.getVirtualTimeF());
								this.Contract.setScreen("SearchParty");
								this.World.Contracts.showActiveContract();
							}
						}
					}
				}

				if (this.Flags.get("IsChangingSides") && this.Contract.getDistanceToNearestSettlement() >= 5 && this.World.State.getPlayer().getTile().HasRoad && this.Math.rand(1, 1000) <= 1)
				{
					this.Flags.set("IsChangingSides", false);
					this.Contract.setScreen("ChangingSides");
					this.World.Contracts.showActiveContract();
				}

				foreach( i, obj in this.Contract.m.Objectives )
				{
					if (obj != null && !obj.isNull() && !obj.isActive() || obj.getSettlement().getOwner().isAlliedWithPlayer() || obj.isAlliedWithPlayer())
					{
						obj.getSprite("selection").Visible = false;
						obj.setAttackable(false);
						obj.getTags().set("HasNobleProtection", false);
						obj.setOnCombatWithPlayerCallback(null);
					}

					if (obj == null || obj.isNull() || !obj.isActive() || obj.getSettlement().getOwner().isAlliedWithPlayer() || obj.isAlliedWithPlayer())
					{
						this.Contract.m.Objectives.remove(i);
						this.Flags.set("LastUpdateDay", 0);
						break;
					}
				}
			}

			function onCombatWithLocation( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.CurrentObjective = _dest;

				if (_dest.getTroops().len() == 0)
				{
					this.onCombatVictory("RazeLocation");
					return;
				}
				else
				{
					local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					p.CombatID = "RazeLocation";

					if (_dest.isMilitary())
					{
						p.Music = this.Const.Music.NobleTracks;
					}
					else
					{
						p.Music = this.Const.Music.CivilianTracks;
					}

					p.EnemyBanners = [];

					if (_dest.getSettlement().isMilitary() || _dest.getTags().get("HasNobleProtection"))
					{
						p.EnemyBanners.push(_dest.getSettlement().getBanner());
					}
					else
					{
						p.EnemyBanners.push("banner_noble_11");
					}

					if (_dest.getTags().get("HasNobleProtection"))
					{
						local f = this.Flags.get("FeudingHouseID");

						foreach( e in p.Entities )
						{
							if (e.Faction == _dest.getFaction())
							{
								e.Faction = f;
							}
						}
					}

					this.World.Contracts.startScriptedCombat(p, _isPlayerAttacking, true, true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "RazeLocation")
				{
					this.Contract.m.CurrentObjective.setActive(false);
					this.Contract.m.CurrentObjective.spawnFireAndSmoke();
					this.Contract.m.CurrentObjective.clearTroops();
					this.Contract.m.CurrentObjective.getSprite("selection").Visible = false;
					this.Contract.m.CurrentObjective.setOnCombatWithPlayerCallback(null);
					this.Contract.m.CurrentObjective.setAttackable(false);
					this.Contract.m.CurrentObjective.getTags().set("HasNobleProtection", false);
					this.Flags.set("Score", this.Flags.get("Score") + 5);

					foreach( i, obj in this.Contract.m.Objectives )
					{
						if (obj.getID() == this.Contract.m.CurrentObjective.getID())
						{
							this.Contract.m.Objectives.remove(i);
							break;
						}
					}

					this.Flags.set("LastUpdateDay", 0);
				}
			}

			function onPartyDestroyed( _party )
			{
				if (_party.getFaction() == this.Flags.get("FeudingHouseID") || this.World.FactionManager.isAllied(_party.getFaction(), this.Flags.get("FeudingHouseID")))
				{
					this.Flags.set("Score", this.Flags.get("Score") + 2);
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

				foreach( obj in this.Contract.m.Objectives )
				{
					if (obj != null && !obj.isNull() && obj.isActive())
					{
						obj.getSprite("selection").Visible = false;
						obj.setOnCombatWithPlayerCallback(null);
					}
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					if (this.Flags.get("Score") <= 9)
					{
						this.Contract.setScreen("Failure1");
					}
					else if (this.Flags.get("Score") <= 15)
					{
						this.Contract.setScreen("Success1");
					}
					else
					{
						this.Contract.setScreen("Success2");
					}

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
			Text = "[img]gfx/ui/events/event_45.png[/img]{你前脚刚走进%employer%的房间，他立马就说道。%SPEECH_ON%{佣兵，晚上好。我需要一队人马去找%feudfamily%的茬，你应该懂吧。嗯？这么说吧，基本上我需要你进入他们的领地，然后尽全力烧掉一切。这样做%days%天应该就能让他们伤筋动骨了。而且一定要十分，十分小心敌军的巡逻队。 |  啊，佣兵。听着，我需要些狠角色进入%feudfamily%的领地，然后烧掉所有的车队和粮食。虽然这任务不算很光荣，但的确有助于战争的结束。%days%天应该就差不多可以了。 |  我需要掠夺者深入%feudfamily%的领地%days%天，尽可能摧毁他们的资源。他们会憎恨你，而且会迅速采取狠辣的行动，但只要能避开他们的巡逻队，这任务应该耗时不多，而且也挺简单的。你意下如何？ |  我们与%feudfamily%开战了，但是军队之间的较量还不够。阴谋诡计还是需要的。佣兵，我的要求是你们去执行为期%days%天的掠夺。摧毁车队，一把火烧了农场，任何有助于战争的事情。当然了，你得小心他们的巡逻队。如果你盯上了我的土地和人民，那我会双倍奉还。那么，你意下如何？ |  我简要的说下。我需要人手对%feudfamily%执行为期%days%的掠夺行动。当然了，他们会预料到这样一手，所以当你外出执行任务的时候，我会尽力避开巡逻队。觉得如何？ |  佣兵，我这有项任务非常适合你。掠夺%feudfamily%的领地，在%days%天内竭尽全力摧毁一切东西。这样的行动有助于结束战争。当然了，他们也明白这点，而且会尽全力阻止你。}%SPEECH_OFF%  |  %employer%欢迎你的到来，他指向桌子上摊开的地图。%SPEECH_ON%战斗的最佳策略就是让敌人没有作战能力，你明白这点吗？我从一本古籍上学到的。%SPEECH_OFF%虽然比较艺术性，但话的确在理。你点点头。他继续说道。%SPEECH_ON%我希望你能侵入%feudfamily%的领土，竭尽全力地搞破坏行动。摧毁车队，烧农场，想怎么搞事就怎么搞事。%days%天内尽全力吧，然后就撤回来。噢，对了。小心他们的巡逻队。他们不会轻易饶恕你的…“远足”。%SPEECH_OFF%  |  你发现%employer%正在聚精会神地读书。并且还用羽毛笔做着笔记。%SPEECH_ON%我的祖父曾经击败了十倍于自己的军队。他是怎么做到的？我的家族供养着历史学家和文士，让其叙述战场上的光荣故事。但事实并非如此。你知道真相吗？%SPEECH_OFF%你耸耸肩，猜测他的祖父使用了某种计谋。贵族合上书，指出一根手指。%SPEECH_ON%没错！他率领了小批人马烧毁了对手的农场，粮仓和食物储备。如果没有粮草，军队规模再大又有何用？佣兵，我需要你来这么一出。前往%feudfamily%的领地，%days%天内尽可能地破坏。当然得避开巡逻队。要是被抓到了，你可就会人头落地了。%SPEECH_OFF%  |  你走进%employer%的房间，发现他在与一名老将军争论着。指挥官昂首挺胸。%SPEECH_ON%我绝不容忍家族之名蒙受如此下作行径的玷污。如果你执意如此，那就去找些下等人吧！%SPEECH_OFF%指挥官拿着东西悻悻而去，出去的路上鼻孔朝天地看着你。%employer%笑着看着你走进。他张开双臂说道。%SPEECH_ON%正好，说曹操曹操就到。佣兵，我需要人手对%feudfamily%执行为期%days%的掠夺行动。高贵的指挥官认为这太下作了，但是我觉得很适合你。当然了，敌人也会认为这是种下作的行为，因此如果他们发现你了，你可得做好准备了，因为他们会怎么狠怎么来。%SPEECH_OFF%  |  %employer%盯着桌上倒翻的牛奶。%SPEECH_ON%就这么简单就毁了，有这样的经历吗？%SPEECH_OFF%你点点头。谁没有呢？他继续说道。%SPEECH_ON%我本来想制作奶酪，但是由于材料毁了，于是计划也玩完了。佣兵，这种想法和突如其来的格言同样适用于战争。我希望你能掠夺%feudfamily%的领地，就像上面说的，弄翻他们的牛奶：摧毁车队，烧了农场，捣毁矿藏，想怎么搞事就怎么搞事。像这样弄个%days%天应该就行了。当然了，你可得小心他们的巡逻队。如果要是我的领地遇到这样的事情，我肯定是想把肇事者的头挂上城墙示众的！%SPEECH_OFF%  |  卫兵带着你找到%employer%，他正在料理一些作物。作物都弯了腰，害虫将叶子啃成了锯齿状，而且颜色斑驳不一。%employer%捡起死去的作物说道。%SPEECH_ON%这本来是这些作物长势最好的季节。但如今却成了这个样子，都是因为渺小害虫在这为虎作伥。处理这些小混蛋还有大把的时间。%SPEECH_OFF%他扔下作物，拍了拍你的肩。%SPEECH_ON%佣兵，我需要人手化身为敌人花园里的邪恶害虫。我需要人手对%feudfamily%执行为期至少%days%天的掠夺行动。当然了，要是被发现了，他们也会视你为害虫一脚踩扁了。所以可别让他们发现你的行踪。你懂的，就像虫子一样。%SPEECH_OFF%  |  当你走进%employer%的房间时，他正在与一名妇女谈笑风生。她迅速收拾好东西匆忙离开了，眼睛从你身上挪开了。自以为是的贵族给自己倒了杯酒。%SPEECH_ON%别管她。那是我妻子的朋友。仅此而已。%SPEECH_OFF%他将酒杯又放回在桌子上。%SPEECH_ON%说到朋友，不如你仗义一把，替我掠夺%feudfamily%的领地？%SPEECH_OFF%他颤颤巍巍地挪步坐在桌子的角落上。他嗅嗅手指，耸耸肩，然后喝了口酒。%SPEECH_ON%深入敌军领地，%days%内尽可能地搞破坏。然后回来就行了。当然，你要想在外面也可以，但是我强烈建议你回来，因为他们的军队可不会忍受你造成的破坏太久。贵族不太喜欢掠夺者。你肯定明白那儿的政治。%SPEECH_OFF%  |  指挥官围着%employer%。他示意你上前，然后伸出手指，仿佛控诉某种你甚至都不知道犯过的罪名。%SPEECH_ON%这就是我们的人选！他非常合适！佣兵！我需要厉害的战士对%feudfamily%执行为期%days%的掠夺行动。随便怎么搞破坏，只要能危及到他们的战斗能力。当然了，你得小心行事。要是被发现了，你可就惨了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{外出5天需要不少费用。 |  %companyname%能处理好这种事情。 |  报酬？}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。 |  别的地方需要我们。 |  这对战团来说时间太久了。}",
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
			ID = "SearchParty",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_90.png[/img]{你正站在农场附近，突然一扇窗户打开了。一位老妇人举着白旗大声尖叫着。%randombrother%过去看看发生了什么事，听她说了一会儿之后迅速返回。%SPEECH_ON%先生，他说%feudfamily%知道我们在哪儿，一支分遣队已经向我们出发了。没错，分遣队是她说的。%SPEECH_OFF%  |  你经过的时候，一个小男孩出现了。%SPEECH_ON%哦，你们是来杀死掠夺者的吗？%SPEECH_OFF%你问这是谁告诉他的。小男孩耸耸肩。%SPEECH_ON%我在酒馆附近闲逛的时候，听人说%feudfamily%知道掠夺者在哪儿，而且听说已经派人过来对付他们拉！%SPEECH_OFF%小男孩拍了拍手。你摸了摸那孩子的头，%SPEECH_ON%没错，正是我们。回家去吧。%SPEECH_OFF%你迅速把消息通知给%companyname%。 |  %randombrother%来到一个山坡下。他站在你身边，大口喘着气。%SPEECH_ON%先生，我…他们…%SPEECH_OFF%他站直身子，%SPEECH_ON%我需要锻炼，不过我不是来告诉你这个的！有一大群敌人正向我们赶来。他们知道我们在哪儿，先生。%SPEECH_OFF%你点点头，告诉他们准备好。 |  侦察兵报告说，一大群敌人正在向这边赶过来，他们似乎知道你们的位置。%companyname%应该做好准备，要么准备逃跑，要么准备战斗。 |  你发现一大群%feudfamily%正在靠近！让大家准备好，据侦查发现，敌人已全副武装。 |  %randombrother%报告说，他从当地人那儿听说了一些消息。他们说一大群战士正在向你们这边赶过来，他们还携带者旗帜。你让雇佣兵描述下旗帜的样子，他说完后，你知道了这些事%feudfamily%的人。他们肯定知道你的消息了。%companyname%得开始为这场硬仗好好准备一番了！ |  一群女人正在溪边洗衣服，问你怎么还在这儿。你问她们这是什么意思。其中一个人笑了起来，显得十分野蛮，%SPEECH_ON%又来？我们问你在这儿干什么。你知道%feudfamily%很不喜欢你这类的人吧。我听说他们很快就来抓你了。%SPEECH_OFF%你问她们是怎么知道的。另外一个女人边洗衬衫边说，%SPEECH_ON%先生，你真是太愚蠢了。传言的速度可比马快多了。别问了，反正就是这样。%SPEECH_OFF%如果这些女人说的没错，看来%companyname%有一场硬仗要打了！ |  你站在山坡上，看着周围的环境。一群看着%feudfamily%旗帜的人正在向你这边走过来。这种景象确实壮观，很快你就能近距离观察了。\n\n 敌人已经赶上%companyname%！你应该做好打一场硬仗的准备。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "时刻警惕！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TimeIsUp",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_36.png[/img]{已经差不多%maxdays%天了。战团可以回去找%employer%领取报酬了。 |  战团在战场已经待了%maxdays%天。%employer%肯定正在等你们回去。 |  已经过了%maxdays%天，你该回去找%employer%领取报酬了。没必要再做那些得不到报酬的事情。 |  %employer%雇了你%maxdays%天。战团没必要再战场多待一分钟。回去找那个人领取报酬吧。 |  %companyname%已经花了%maxdays%天替%employer%完成任务。他只会愿意付这些天的钱，你最好赶紧回去找他。 |  %employer%付了%maxdays%天的报酬，%companyname%应该赶紧回去找他。 |  虽然破坏土地已变得越来越熟练，但%employer%只给了你%maxdays%天的钱。你最好赶紧回去找他。 |  你干的很好，但该回去找%employer%了，因为他只给了你们%maxdays%天的钱。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "该回%townname%去了。",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ChangingSides",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_51.png[/img]{路程中，一个穿着黑色斗篷的人慢慢靠近。他的脸隐藏在黑色兜帽中。他在你面前停下，把手伸出来，%SPEECH_ON%你好，我是%rivalhouse%的信使。我们有个提议。不要再为%noblehouse%服务了，加入我们吧。和我们在一起，永远不会有空闲的时候，你的战团一定能第一时间获得合同。为了表达诚意，我会献上名为%nameditem%的武器。%SPEECH_OFF%你思考着这一提议。转换阵营是雇佣兵职业生涯中的必要部分。哪个贵族会给战团更好的待遇呢？哪边能获胜呢？ |  你走到路边去小便。突然树丛里走出一个人，还好没尿他身上。你往后跳一步，拿出匕首，不过那个人伸出一只手。%SPEECH_ON%你好，佣兵，我是%rivalhouse%的信使。我是来替建议的。加入我们吧。只要我们有需要，第一考虑的绝对是你们，因此你们能获得最好的契约和报酬，而且我们一直都有各种需求。为了表达诚意，我给你这个。%SPEECH_OFF%他拿出一件精良的武器。你告诉他给你等一下，然后继续尿尿。你在脑海里迅速思量着。 |  躺在地上的时候，一个穿着黑色斗篷的人靠过来。%randombrother%抓住他的兜帽，用匕首抵住他的脖子。那个人举起双手说，他是来替%rivalhouse%送信的。你点点头让他继续说下去，%SPEECH_ON%希望你们能加入我们。别再为当前的贵族服务了，加入我们吧。你们可以获得报酬丰厚的契约，可以获得不少好处！为了表示诚意，我把这件名为%nameditem%的武器送给你。当然，前提是你要加入我们。%SPEECH_OFF%你仔细思考着这一提议，转换阵营可不是那么简单的事情。 |  一个穿着黑色衣服的人慢慢靠近，手上拿着卷轴。%SPEECH_ON%晚上好，%companyname%。我代表%rivalhouse%向你们提出建议。放弃现有的资助人，加入我们吧。你们能获得更好的契约，而且能在这场战斗中获得胜利！如果你同意，为表诚意，我将把这件名为%nameditem%的武器送给你。%SPEECH_OFF%%randombrother%看着你耸耸肩。%SPEECH_ON%我并不想越级，但这个提议确实值得考虑。%SPEECH_OFF%没错，确实如此。 |  你离开战团其他人，躺在地上好好休息会儿。一个穿着斗篷的人突然出现在眼前，手里还拿着什么东西。%randombrother%把他按到在地上，拿着刀指着他的脸。陌生人举起双手，拿出一副卷轴。你让他站起来，说明自己的身份。他说他是从%rivalhouse%来的，准备给%companyname%提出一个建议。%SPEECH_ON%换边吧，作为雇佣兵，这样做根本没什么坏处，并且这是大家都期待的。追求克朗，对吧？我们拥有报酬丰厚的契约。这也是你们需要的，不是吗？%SPEECH_OFF%信使整理下自己的衣服，站直身子，%SPEECH_ON%如果你接受我们的提议，我将把这件名为%nameditem%的武器送给你。怎么样？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "非常有趣的提议。我接受。",
					function getResult()
					{
						return "AcceptChangingSides";
					}

				},
				{
					Text = "你这是在浪费时间。走吧，不然把你吊死在树上。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "AcceptChangingSides",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_51.png[/img]{你接受了提议。神秘的信使把你带到一具尸体旁，从树林后面挖出武器，然后递给你。%SPEECH_ON%希望我们合作愉快，佣兵。%SPEECH_OFF%现在%employer%肯定非常讨厌你了。 |  你接受提议后，信使带你来到路边，从树林后面拿出武器。他把武器递过来的时候，和你握了握手，%SPEECH_ON%你的选择十分明智，佣兵。%SPEECH_OFF%%employer%现在很定非常恨你，没必要回去找他了，除非你的新雇主有这样的要求。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "%companyname%从此以后替%rivalhouse%效劳！",
					function getResult()
					{
						this.Contract.m.Item = null;
						local f = this.World.FactionManager.getFaction(this.Contract.getFaction());
						f.addPlayerRelation(-f.getPlayerRelation(), "Changed sides in the war");
						f.getFlags().set("Betrayed", true);
						local a = this.World.FactionManager.getFaction(this.Flags.get("RivalHouseID"));
						a.addPlayerRelationEx(50.0 - a.getPlayerRelation(), "Changed sides in the war");
						a.makeSettlementsFriendlyToPlayer();
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.updateAchievement("NeverTrustAMercenary", 1, 1);
				this.World.Assets.getStash().add(this.Contract.m.Item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + this.Contract.m.Item.getIcon(),
					text = "你获得了" + this.Contract.m.Item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer%欢迎你的到来。他给了你%reward_completion%克朗，%SPEECH_ON%干得好，佣兵。你完成了我们的所有要求。%SPEECH_OFF%  |  %employer%正在喂鸡。你穿过这群鸡来到他身边，告诉他消息。他礼貌的回应，%SPEECH_ON%是吗？很好，你想要鸡食还是克朗啊？%SPEECH_OFF%他严肃地盯着你，之后露出笑容。%SPEECH_ON%去找那边的守卫拿%reward_completion%克朗，他会给你的。%SPEECH_OFF%  |  %employer%太忙了，没时间见你，不过他的一名守卫递给你%reward_completion%克朗，这就证明他对你的行动十分满意。 |  %employer%用手指搅动着酒杯，%SPEECH_ON%袭击的工作很不好做，不过你们做的很好。我真希望你给敌人带去灾难，不过你那样做也很好。%SPEECH_OFF%他舔了舔手指，然后给你%reward_completion%克朗。 |  %employer%坐在椅子上，手扶着扶手，脚放在桌子上。%SPEECH_ON%你的%reward_completion%克朗在那边。%SPEECH_OFF%他向房间的一个角落点点头，那边有个袋子。你过去拿包裹，他继续说道，%SPEECH_ON%你做得非常不错，那一袋克朗中还包含着我的喜悦之情。%SPEECH_OFF%  |  你发现%employer%正在喂狗，%SPEECH_ON%干得好啊，佣兵。如果我的士兵们都有你这样的热情，这场战争早就结束了。真遗憾啊，对吧？%SPEECH_OFF%他突然转身盯着你。你觉得他想让你加入他的军队，真狡猾。你礼貌性地表示拒绝，然后询问自己的报酬。他手里拿着一块培根指着那边的一个人说，%SPEECH_ON%在那个守卫手里，一共%reward_completion%克朗。%SPEECH_OFF%  |  %employer%向你表示感谢。然后给了你%reward_completion%克朗。 |  你发现%employer%被一群人围着。他们正在根据你的行动调整战略地图。贵族挺直身子看着结果，%SPEECH_ON%虽然跟我要求的不一样，但也很好，非常好。那边的守卫手里有%reward_completion%克朗，都是给你的。%SPEECH_OFF%  |  %employer%站在一副挂在墙上的地图前。他正在用羽毛笔最笔记，你发现他把%companyname%通过%feudfamily%领土的路线都标出来了。贵族不时自言自语，并且对自己点点头。他没有看你，%SPEECH_ON%虽然不是最好的，但也很不错。角落里有%reward_completion%克朗。%SPEECH_OFF%  |  %employer%的一个指挥官阻止你进入。他递给你一个装着%reward_completion%克朗的带子。%SPEECH_ON%大人很忙，这是你的报酬，请离开吧。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "报酬十分公平。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Raided the enemy lands");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isCivilWar())
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
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你走进房间的时候发现，%employer%和他的指挥官都喝醉了。一个人拍着你的肩膀，似乎想说点什么，可是接着就开始呕吐了。你赶紧走开，找到了%employer%。%SPEECH_ON%啊，佣兵！我 -嗝- 这儿。%reward_completion%克朗。%SPEECH_OFF%他拿着一个袋子，你赶紧接过来，生怕他会吐在袋子上。%employer%向后退了几步，然后靠在桌子上。%SPEECH_ON%你们给%feudfamily%带来了沉重的打击，真他妈 -嗝- 干得太好了！你们的行为空前绝后，绝无 -嗝- 仅有。%SPEECH_OFF%你离开房间，在这个欢庆的城市里游荡着。 |  %employer%猛地放下酒杯，身上洒得到处都是，%SPEECH_ON%太棒了！太了不起了！太完美了！佣兵，这便是我对你的评价。我们抓住了几个%feudfamily%逃兵，他们担心自己已经输了。给，这是%reward_completion%克朗。算我的。%SPEECH_OFF%他爆发出一阵笑声，接着继续喝酒。 |  你走进%employer%的房间，发现他正在研究地图。他用一支羽毛笔抵住下巴，喃喃自语地说些什么。%SPEECH_ON%我刚刚正在画你穿过%feudfamily%领土的路线，不过没墨水了。你做得真是太棒了，佣兵。角落里有%reward_completion%克朗。%SPEECH_OFF%  |  一个人在%employer%房间外面向你打了打招呼，他手里拿着一个包裹。%SPEECH_ON%给你的%reward_completion%克朗。大人很忙，不过他很高兴。希望这袋克朗能表达他对你的感激之情。%SPEECH_OFF%这确实是个好迹象。 |  守卫带你来到%employer%身边，他在一间上锁的屋子里面。里面还有个女人，他似乎……心情十分愉快。守卫准备敲门，但考虑之后又停下了。%SPEECH_ON%我很想通知他你来了，不过他不喜欢被人打扰。特别是这种时候。你懂的。这样的时候。%SPEECH_OFF%你点点头，问报酬在哪儿。守卫带你去金库。你发现一个人坐在一堆文件和硬币后面。他拿出一袋%reward_completion%克朗，然后记录在卷轴上。 |  %employer%在花园见你。他正在监督仆人们种树，%SPEECH_ON%你的花园里都有些什么呢，佣兵？%SPEECH_OFF%你告诉他，你并没有花园。他点点头，似乎觉得很有意思，%SPEECH_ON%我正在考虑种些红萝卜。好了，不说了。看到那边正在干活的那个仆人了吗？他拿着一个袋子，很重，因为里面装着%reward_completion%克朗。那是你的奖励，佣兵。或许你可以用这些钱来买个花园！%SPEECH_OFF%  |  %employer%和他的指挥官们正在一张战略地图前窃窃私语。其中一个人把印记放在你的战团上，他用印记绕着地图，偶尔还留下了少量的墨水印。你抱着双手大声说着，%SPEECH_ON%我们做得不错吧？%SPEECH_OFF%跪着和他的指挥官看着你。%employer%露出笑容，走到你身边，%SPEECH_ON%就是说啊！你做的很不错，雇佣兵，真的。那边的守卫手里拿着一个装着%reward_completion%克朗的袋子，是你的报酬。%SPEECH_OFF%  |  %employer%站在指挥官中间。你走进来的时候，他哎呀地叫了一声，%SPEECH_ON%天呐，孩子！你差点把他们一半的基业给毁掉！还会有谁跟我一样，请求这样的打击呢？你会获得%reward_completion%克朗，我觉得你们的价值远比这个高！%SPEECH_OFF%  |  你发现%employer%坐在自己的房间里。他看到你非常高兴。%SPEECH_ON%{这不是我们的大明星嘛。我的鸟儿们整天飞到窗户前，跟我说你的功绩。关于你的所作所为，消息传播得很快！%feudfamily%受到了重创，战争很快就要结束了！我给你准备了%reward_completion%克朗，就在角落里。 |  你应该多点爱好，佣兵。你对%feudfamily%的所作所为，超过了我的期望。我很惊讶你没有继续采取行动，明明有机会把他们全都给杀死。啊，一切刚刚好。%reward_completion%克朗正在角落等着你呢。}%SPEECH_OFF%  |  你发现%employer%蹲在桌子边，上面放着一张地图。他盯着边缘，正在看各种印记。%SPEECH_ON%你好，佣兵。%SPEECH_OFF%他站了起来。他一只手指着代表%feudfamily%的印记，然后翻过来，%SPEECH_ON%正在享受你的作品，佣兵。你给敌人带来了沉重的打击！你的所作所为比任何人做的都要好！角落里放着给你的%reward_completion%克朗。希望这些报酬足够了，因为你做得确实很好。%SPEECH_OFF%  |  你发现%employer%和他的指挥官还有一群女人在一起，显得很不协调。%SPEECH_ON%佣兵！过来，%SPEECH_OFF%%employer%转过身来，搂着两个女人。你跟着他。一个女人想拉你加入聚会，不过一个将军把她拉走了。%employer%坐下来，那两个女人坐在他腿上。%SPEECH_ON%我们都在为你庆祝，雇佣兵。你入侵了%feudfamily%的领土，因此我们离这场伟大的战争结束又近了一步！欢呼吧！%SPEECH_OFF%你看了看四周。%SPEECH_ON%到处都在庆祝，不过我不想为了女人和酒战斗，你还欠我钱呢。%SPEECH_OFF%雇主点点头。%SPEECH_ON%当然，当然！去找财务，把你的印章给他。他会给你%reward_completion%克朗。%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "报酬十分公平。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess * 2);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess * 2, "Raided the enemy lands");
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
			ID = "Failure1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你走进%employer%的房间，他似乎非常生气，然后对你发了脾气，%SPEECH_ON%我就直说了，佣兵。我给你报酬，让你袭击%feudfamily%。你也同意了，我觉得这是个非常不错的提议，双方都能获得好处。可现在你站在我面前，说并没有按照我们的安排行事。那为什么还要过来找我呢，你这个狗东西？不，你连狗都比不上，最多只是一条想偷我们东西的虫子。赶紧给我滚蛋。%SPEECH_OFF%尽管%employer%虚张声势，但陷入危险的那个人还是他。你赶紧趁自己还没发火杀了他之前离开。 |  你回去找%employer%，但一名守卫把你拦在门外，%SPEECH_ON%他已经知道你做了什么，或者说什么都没做。你最好别进去。%SPEECH_OFF%你听到桌子被掀翻的声音。还有尖叫声。你接受了守卫了建议，然后离开。 |  %employer%的一只手指沿着杯子转圈，发出很大的嘈杂声。%SPEECH_ON%多么美妙的音乐啊，怎么会连一个杯子都比你要好呢，雇佣兵？我觉得这个世界大概就是这样吧。我让别人做一些事情，可是他们却没做。还有什么可说的呢？出去吧。%SPEECH_OFF%  |  你发现%employer%正在喂狗。仆人们在附近看着，似乎非常羡慕狗的待遇，甚至希望自己变成一条狗。%employer%转身对着你，一条狗从他手里叼走一块培根。%SPEECH_ON%狗都喜欢吃肉。我把残留的猪肉都给他们。那头猪很不错，过着快乐的一生，只有最后一刻有些糟糕而已。如今已经进狗的肚子了。你，佣兵，给我带来了十分糟糕的消息。我要拿你来喂狗吗？不行？那跟进给我滚。%SPEECH_OFF%  |  %employer%拒绝见你。守卫解释说，因为你没能给%feudfamily%带来损失，所以他非常生气。这也说得通。你感谢守卫，让你躲过了那位贵族的侮辱。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "去死吧你！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to raid the enemy lands");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"noblehouse",
			this.World.FactionManager.getFaction(this.m.Faction).getName()
		]);
		_vars.push([
			"rivalhouse",
			this.m.Flags.get("RivalHouseName")
		]);
		_vars.push([
			"feudfamily",
			this.m.Flags.get("FeudingHouseName")
		]);
		_vars.push([
			"maxdays",
			"five days"
		]);
		local days = 5 - (this.World.getTime().Days - this.m.Flags.get("StartDay"));
		_vars.push([
			"days",
			days > 1 ? "" + days + " days" : "1 day"
		]);

		if (this.m.Item != null)
		{
			_vars.push([
				"nameditem",
				this.m.Item.getName()
			]);
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			foreach( obj in this.m.Objectives )
			{
				if (obj != null && !obj.isNull() && obj.isActive())
				{
					obj.clearTroops();
					obj.setAttackable(false);
					obj.getSprite("selection").Visible = false;
					obj.getTags().set("HasNobleProtection", false);
					obj.setOnCombatWithPlayerCallback(null);
				}
			}

			this.m.Item = null;
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
		_out.writeU8(this.m.Objectives.len());

		foreach( o in this.m.Objectives )
		{
			if (o != null && !o.isNull())
			{
				_out.writeU32(o.getID());
			}
			else
			{
				_out.writeU32(0);
			}
		}

		if (this.m.Item != null)
		{
			_out.writeBool(true);
			_out.writeI32(this.m.Item.ClassNameHash);
			this.m.Item.onSerialize(_out);
		}
		else
		{
			_out.writeBool(false);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local numObjectives = _in.readU8();

		for( local i = 0; i != numObjectives; i = i )
		{
			local o = _in.readU32();

			if (o != 0)
			{
				this.m.Objectives.push(this.WeakTableRef(this.World.getEntityByID(o)));
				local obj = this.m.Objectives[this.m.Objectives.len() - 1];

				if (!obj.isMilitary() && !obj.getSettlement().isMilitary() && !obj.getTags().get("HasNobleProtection"))
				{
					local garbage = [];

					foreach( i, e in obj.getTroops() )
					{
						if (e.ID == this.Const.EntityType.Footman || e.ID == this.Const.EntityType.Greatsword || e.ID == this.Const.EntityType.Billman || e.ID == this.Const.EntityType.Arbalester || e.ID == this.Const.EntityType.StandardBearer || e.ID == this.Const.EntityType.Sergeant || e.ID == this.Const.EntityType.Knight)
						{
							garbage.push(i);
						}
					}

					garbage.reverse();

					foreach( g in garbage )
					{
						obj.getTroops().remove(g);
					}
				}
			}

			i = ++i;
		}

		local hasItem = _in.readBool();

		if (hasItem)
		{
			this.m.Item = this.new(this.IO.scriptFilenameByHash(_in.readI32()));
			this.m.Item.onDeserialize(_in);
		}

		this.contract.onDeserialize(_in);
	}

});

