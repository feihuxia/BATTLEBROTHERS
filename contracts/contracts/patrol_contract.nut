this.patrol_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Location1 = null,
		Location2 = null,
		NextObjective = null,
		Dude = null
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.patrol";
		this.m.Name = "巡逻";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 5.0;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
		this.m.MakeAllSpawnsResetOrdersOnceDiscovered = true;
		this.m.DifficultyMult = 1.0;
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

		local settlements = clone this.World.FactionManager.getFaction(this.m.Faction).getSettlements();
		local i = 0;

		while (i < settlements.len())
		{
			local s = settlements[i];

			if (s.isIsolatedFromRoads() || !s.isDiscovered() || s.getID() == this.m.Home.getID())
			{
				settlements.remove(i);
				continue;
			}

			i = ++i;
			i = i;
		}

		this.m.Location1 = this.WeakTableRef(this.getNearestLocationTo(this.m.Home, settlements, true));
		this.m.Location2 = this.WeakTableRef(this.getNearestLocationTo(this.m.Location1, settlements, true));
		this.m.Payment.Pool = 800 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		local r = this.Math.rand(1, 3);

		if (r == 1)
		{
			this.m.Payment.Count = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else if (r == 2)
		{
			this.m.Payment.Count = 0.75;
			this.m.Payment.Completion = 0.25;
		}
		else
		{
			this.m.Payment.Count = 1.0;
		}

		local maximumHeads = [
			20,
			25,
			30,
			35
		];
		this.m.Payment.MaxCount = maximumHeads[this.Math.rand(0, maximumHeads.len() - 1)];
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
				this.Contract.m.BulletpointsObjectives = [
					"巡逻" + this.Contract.m.Location1.getName()+"的道路 ",
					"巡逻" + this.Contract.m.Location2.getName()+"的道路 ",
					"巡逻" + this.Contract.m.Home.getName()+"的道路 "
				];
				this.Contract.m.BulletpointsObjectives.push("%days%内返回");

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
				this.Flags.set("EnemiesAtWaypoint1", this.Math.rand(1, 100) <= 25 * this.Math.pow(this.Contract.getDifficultyMult(), 2));
				this.Flags.set("EnemiesAtWaypoint2", this.Math.rand(1, 100) <= 25 * this.Math.pow(this.Contract.getDifficultyMult(), 2) + (this.Flags.get("EnemiesAtWaypoint1") ? 0 : 50));
				this.Flags.set("EnemiesAtLocation3", this.Math.rand(1, 100) <= 25 * this.Math.pow(this.Contract.getDifficultyMult(), 2) + (this.Flags.get("EnemiesAtWaypoint2") ? 0 : 100));
				this.Flags.set("StartDay", this.World.getTime().Days);

				if (this.World.FactionManager.getFaction(this.Contract.getFaction()).getFlags().get("Betrayed"))
				{
					this.Flags.set("IsBetrayal", this.Math.rand(1, 100) <= 75);
				}
				else
				{
					local r = this.Math.rand(1, 100);

					if (r <= 10)
					{
						if (this.World.FactionManager.isGreenskinInvasion())
						{
							this.Flags.set("IsCrucifiedMan", true);
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
				this.Contract.m.Location1.getSprite("selection").Visible = true;
				this.Contract.m.Location2.getSprite("selection").Visible = false;
				this.Contract.m.Home.getSprite("selection").Visible = false;
				this.Contract.m.NextObjective = this.Contract.m.Location1;
				this.Contract.m.BulletpointsObjectives = [
					"巡逻 " + this.Contract.m.Location1.getName()+"的道路"
				];

				if (this.Contract.m.Payment.Count != 0)
				{
					this.Contract.m.BulletpointsObjectives.push("你在路上收集的每个头颅都有报酬(%killcount%/%maxcount%)");
				}

				this.Contract.m.BulletpointsObjectives.push("%days%天内返回");
			}

			function update()
			{
				if (this.Flags.get("LastUpdateDay") != this.World.getTime().Days)
				{
					if (this.World.getTime().Days - this.Flags.get("StartDay") >= 7)
					{
						this.Contract.setScreen("Failure1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Flags.set("LastUpdateDay", this.World.getTime().Days);
						this.start();
						this.World.State.getWorldScreen().updateContract(this.Contract);
					}
				}

				if (this.Contract.isPlayerAt(this.Contract.m.Location1))
				{
					this.Contract.setScreen("Success1");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("EnemiesAtWaypoint1"))
				{
					if (this.Contract.spawnEnemies())
					{
						this.Flags.set("EnemiesAtWaypoint1", false);
					}
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				this.Contract.addKillCount(_actor, _killer);
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
		this.m.States.push({
			ID = "Location2",
			function start()
			{
				this.Contract.m.Location1.getSprite("selection").Visible = false;
				this.Contract.m.Location2.getSprite("selection").Visible = true;
				this.Contract.m.Home.getSprite("selection").Visible = false;
				this.Contract.m.NextObjective = this.Contract.m.Location2;
				this.Contract.m.BulletpointsObjectives = [
					"巡逻 " + this.Contract.m.Location2.getName()+"的道路"
				];

				if (this.Contract.m.Payment.Count != 0)
				{
					this.Contract.m.BulletpointsObjectives.push("你在路上收集的每个头颅都有报酬(%killcount%/%maxcount%)");
				}

				this.Contract.m.BulletpointsObjectives.push("%days%天内返回");
			}

			function update()
			{
				if (this.Flags.get("LastUpdateDay") != this.World.getTime().Days)
				{
					if (this.World.getTime().Days - this.Flags.get("StartDay") >= 7)
					{
						this.Contract.setScreen("Failure1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Flags.set("LastUpdateDay", this.World.getTime().Days);
						this.start();
						this.World.State.getWorldScreen().updateContract(this.Contract);
					}
				}

				if (this.Contract.isPlayerAt(this.Contract.m.Location2))
				{
					this.Contract.setScreen("Success2");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("EnemiesAtWaypoint2"))
				{
					if (this.Contract.spawnEnemies())
					{
						this.Flags.set("EnemiesAtWaypoint2", false);
					}
				}

				if (this.Flags.get("IsCrucifiedMan") && !this.TempFlags.get("IsCrucifiedManShown") && this.World.State.getPlayer().getTile().HasRoad && this.Contract.getDistanceToNearestSettlement() >= 6 && this.Math.rand(1, 1000) <= 1)
				{
					this.TempFlags.set("IsCrucifiedManShown", true);
					this.Contract.setScreen("CrucifiedA");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsCrucifiedManWon"))
				{
					this.Flags.set("IsCrucifiedManWon", false);

					if (this.Math.rand(1, 100) <= 50)
					{
						this.Contract.setScreen("CrucifiedE_AftermathGood");
					}
					else
					{
						this.Contract.setScreen("CrucifiedE_AftermathBad");
					}

					this.World.Contracts.showActiveContract();
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				this.Contract.addKillCount(_actor, _killer);
			}

			function onCombatVictory( _combatID )
			{
				this.start();
				this.World.State.getWorldScreen().updateContract(this.Contract);

				if (_combatID == "CrucifiedMan")
				{
					this.Flags.set("IsCrucifiedManWon", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.start();
				this.World.State.getWorldScreen().updateContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.Location1.getSprite("selection").Visible = false;
				this.Contract.m.Location2.getSprite("selection").Visible = false;
				this.Contract.m.Home.getSprite("selection").Visible = true;
				this.Contract.m.NextObjective = this.Contract.m.Home;
				this.Contract.m.BulletpointsObjectives = [
					"巡逻 " + this.Contract.m.Home.getName()+"的道路"
				];

				if (this.Contract.m.Payment.Count != 0)
				{
					this.Contract.m.BulletpointsObjectives.push("你在路上收集的每个头颅都有报酬(%killcount%/%maxcount%)");
				}

				this.Contract.m.BulletpointsObjectives.push("%days%天内返回");
			}

			function update()
			{
				if (this.Flags.get("LastUpdateDay") != this.World.getTime().Days)
				{
					if (this.World.getTime().Days - this.Flags.get("StartDay") >= 7)
					{
						this.Contract.setScreen("Failure1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Flags.set("LastUpdateDay", this.World.getTime().Days);
						this.start();
						this.World.State.getWorldScreen().updateContract(this.Contract);
					}
				}

				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					if (this.Flags.get("HeadsCollected") != 0)
					{
						this.Contract.setScreen("Success3");
					}
					else
					{
						this.Contract.setScreen("Success4");
					}

					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("EnemiesAtWaypoint3"))
				{
					if (this.Contract.spawnEnemies())
					{
						this.Flags.set("EnemiesAtWaypoint3", false);
					}
				}

				if (this.Flags.get("IsCrucifiedMan") && !this.TempFlags.get("IsCrucifiedManShown") && this.World.State.getPlayer().getTile().HasRoad && this.Contract.getDistanceToNearestSettlement() >= 6 && this.Math.rand(1, 1000) <= 1)
				{
					this.TempFlags.set("IsCrucifiedManShown", true);
					this.Contract.setScreen("CrucifiedA");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsCrucifiedManWon"))
				{
					this.Flags.set("IsCrucifiedManWon", false);

					if (this.Math.rand(1, 100) <= 50)
					{
						this.Contract.setScreen("CrucifiedE_AftermathGood");
					}
					else
					{
						this.Contract.setScreen("CrucifiedE_AftermathBad");
					}

					this.World.Contracts.showActiveContract();
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				this.Contract.addKillCount(_actor, _killer);
			}

			function onCombatVictory( _combatID )
			{
				this.start();
				this.World.State.getWorldScreen().updateContract(this.Contract);

				if (_combatID == "CrucifiedMan")
				{
					this.Flags.set("IsCrucifiedManWon", true);
				}
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
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer% 牢牢握住他的一把椅子。你请坐。%SPEECH_ON%这区域不太安全。商人在抱怨沿路的强盗和其他危险。%SPEECH_OFF%他低下头，按摩太阳穴。%SPEECH_ON%因为现在我所有人都出动了，我需要你在这块区域巡逻。前往%location1%，再到%location2%，然后在%days%天内回到这里。如果发现任何威胁，确保处理好它们。在树林里闲逛我是不会付给你任何钱的，雇佣兵。你每取回一个首级我就会付给你报酬。%SPEECH_OFF%  |  %employer%正对着一张地图低吟，眼神仿佛猎鹰盘旋着扫略疾走的老鼠。他似乎无法集中眼神。%SPEECH_OFF%整个地方，都是我的人。这里。那里。还有那里。地图这边？甚至连名字都没有，但他们也在那里。稍有没有他们踪迹的是这里，和这里。所以就需要你出马了，雇佣兵。%SPEECH_OFF%他停下来看向你。%SPEECH_ON%我需要你巡逻从%location1%到%location2%的领地。清除任何据山占道的人或兽。你肯定知道会是哪些人。但你要只是走走过场的话我是不会付你任何钱的，佣兵。在%days%天之内尽可能多地携人头过来，每个我都会酬劳你的。%SPEECH_OFF%  |  %employer%猛灌一口酒然后打了个嗝。他似乎很生气。%SPEECH_ON%我通常不叫雇佣兵为我巡逻，但我大多数人都被派去其他地方了。这任务很简单：只要去到%location1%再到%location2%，然后在%days%天之内回到这儿。路上，杀死任何可能威胁到当地人民的人或野兽。不过一定要确保取得他们的首级。我会好好酬劳你，那取决于你的战利品，而不是你走过的路程数。%SPEECH_OFF%  |  %employer%奸诈地咧着嘴笑。%SPEECH_ON% 如果说我给你的任务酬劳不在于你怎么做的，而取决于你得取的人头数？这提议你有兴趣么？因为现在我需要巡逻%location1%和%location2%。你散散步，到处杀杀人和兽，然后%days%天之内带着收集的各种首级给我。\n\n我会为你杀的那些支付你酬劳的。让我听听你的想法。%SPEECH_OFF%  |  %employer%手指地图。%SPEECH_ON%我需要你前往这里。%SPEECH_OFF%他用手指指了另一个地点。%SPEECH_ON%然后这里。是一段长远的巡逻。你要杀死任何非以%noblehousename%之名据山占道的人或兽。不过一定要确保取得他们的首级。我可不是付你钱去度假的。我会就你在%days%天内返回后带来的每个战利品来酬劳你。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "你说的酬劳是指？",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "那可是要走一大段路。",
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
			ID = "CrucifiedA",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_02.png[/img]%randombrother%拿着一份侦查报告回到你身边。%SPEECH_ON%有些人一把火烧了村落。惨遭腰斩的死人。腿都没了。他的狗就躺在那里。不愿意离开。都没有办法把它骗走。有些树上找到了一头死驴。而且还有只长矛。%SPEECH_OFF%他顿了顿，仿佛想起了什么，打了个响指。%SPEECH_ON%对了！差点忘了。那边的山上有个人被钉在十字架上。还活着。扯着嗓子大喊大叫，但是我没靠近。陌生人的痛苦可是件麻烦事。%SPEECH_OFF%",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "好吧。咱们去看看这个被钉在十字架上的人吧。",
					function getResult()
					{
						return "CrucifiedB";
					}

				},
				{
					Text = "没什么可行动的。报告不错。",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Flags.set("IsCrucifiedMan", false);
			}

		});
		this.m.Screens.push({
			ID = "CrucifiedB",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_02.png[/img]你决定冒险去看看那个被钉在十字架上的伙计。\n\n 你爬上附近的山，向斜坡看去。基本和佣兵说的差不多。山的另一边有个被钉在十字架上的人。即使从这也能听到他时不时的叫喊声。%randombrother%问该怎么做。",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "干掉他吧。",
					function getResult()
					{
						if (this.Math.rand(1, 100) <= 50 && this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
						{
							return "CrucifiedC";
						}
						else
						{
							return "CrucifiedD";
						}
					}

				},
				{
					Text = "这明显是陷阱。等等看。",
					function getResult()
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "CrucifiedE";
						}
						else
						{
							return "CrucifiedF";
						}
					}

				},
				{
					Text = "我们走吧。此时有点蹊跷。",
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
			ID = "CrucifiedC",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_02.png[/img]要是放任这可怜人不管，或许你晚上会良心不安地睡不着觉。你和战团的人看向山坡。你仍然担心会有埋伏，所以援救并非很快，但是什么都没发生。当你靠近时，那人咧开了笑容。%SPEECH_ON%快放我下来，我会为你效力，我保证！%SPEECH_OFF%佣兵放那人下来了。他从木十字架上滑落至佣兵的怀中，然后佣兵将他轻轻放在地上。在喝水的时候，他说道。%SPEECH_ON%绿皮怪物这么对我的。我是咱们村子最后的幸存者，看来他们觉得比起一斧子砍死我，这样戏弄我会更有乐子。在你们没来之前，我还真希望一死了之。先生，虽然我现在状态不佳，但是我会康复的，我向天发誓，我将为你作战，至死方休！%SPEECH_OFF%",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "如此惨剧，很少有人能活下来。欢迎加入战团。",
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
					Text = "战团已经容纳不下其他人了。",
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
				this.Contract.m.Dude.setStartValuesEx(this.Const.CharacterVillageBackgrounds);
				this.Contract.m.Dude.getBackground().m.RawDescription = "You pulled the crucified %name% down off the means to his execution just in time. He has pledged allegiance to your side until the end of his days or the last of your victories.";
				this.Contract.m.Dude.getBackground().buildDescription(true);
				this.Contract.m.Dude.getSkills().removeByID("trait.disloyal");
				this.Contract.m.Dude.getSkills().add(this.new("scripts/skills/traits/loyal_trait"));
				this.Contract.m.Dude.setHitpoints(1);

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

				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "CrucifiedD",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_67.png[/img]如果放任这可怜人不管，那晚上说不定就睡不安稳了。你率领战团来到山坡拯救他，也是为了拯救自己的健全心智。当你们靠近时，那人露出了笑容。%SPEECH_ON%陌生人，谢谢！谢谢，太感谢了—%SPEECH_OFF%话还没说完，一支长矛就刺进他的胸膛，死死地钉在十字架上。你转身发现绿皮怪物从附近的灌木丛中冲了出来。该死，陷阱！准备迎战！",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.GoblinsTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						properties.EnemyBanners = [
							"banner_goblins_03"
						];
						properties.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Center;
						properties.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
						this.Contract.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.GreenskinHorde, this.Math.rand(90, 110), this.Const.Faction.Enemy);
						this.World.Contracts.startScriptedCombat(properties, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "CrucifiedE",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_07.png[/img]你决定等等再说。你坐下，倾听着濒死之人的哀嚎声，然后慢慢消失了。%randombrother%抓着你的肩膀，指了指稍远处的地方。有些强盗正在向钉在十字架上的人走去。他们抵达后说了一会儿。其中一人掏出一把匕首开始朝那人的脚趾刺去。他的哀嚎声再次响起。其中一名强盗转身大笑。随后停了下来。他说了些什么。他伸手指了指。你们被发现了！趁这些王八蛋还没能集结队形，你下令%companyname%冲锋！",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "CrucifiedMan";
						properties.Music = this.Const.Music.GoblinsTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						properties.EnemyBanners = [
							"banner_bandits_03"
						];
						this.Contract.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.BanditRaiders, this.Math.rand(90, 110), this.Const.Faction.Enemy);
						this.World.Contracts.startScriptedCombat(properties, false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "CrucifiedE_AftermathGood",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]震惊的是，那个被钉在十字架上的人仍活着。他沙哑的声音中只能听到‘请求求我’。你让佣兵放他下来。当落在地上时短暂昏迷了，然后颠簸让他醒了过来，然后一把抓住你的手。%SPEECH_ON%感谢你，陌生人。太感谢你了。兽人…来了…然后强盗从死人身上抢东西…但是你，你们不一样。谢谢你！与那些夺走我一切的人战斗是我活在这个世界上的唯一希望。我是%crucifiedman%，最后的幸存者，如果你不嫌弃，我愿意宣誓为你效力，至死方休。%SPEECH_OFF%",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "如此惨剧，很少有人能活下来。欢迎加入战团。",
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
					Text = "战团已经容纳不下其他人了。",
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
				this.Contract.m.Dude.setStartValuesEx(this.Const.CharacterVillageBackgrounds);
				this.Contract.m.Dude.getBackground().m.RawDescription = "You pulled the crucified %name% down off the means to his execution just in time. He has pledged allegiance to your side until the end of his days or the last of your victories.";
				this.Contract.m.Dude.getBackground().buildDescription(true);
				this.Contract.m.Dude.getSkills().removeByID("trait.disloyal");
				this.Contract.m.Dude.getSkills().add(this.new("scripts/skills/traits/loyal_trait"));
				this.Contract.m.Dude.setHitpoints(1);

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

				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "CrucifiedE_AftermathBad",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]解决掉强盗后，你前去查看那个可怜人是否还活着。他死了。他身上什么都没有，于是你夺走了强盗了东西，而后与%companyname%重新踏上路途。",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "安息吧。",
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
			ID = "CrucifiedF",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_02.png[/img]你决定等等再说。濒死之人仍然是那样。他的叫喊声小了点，虽然耳朵清静了点，但是人们的灵魂就受折磨了。不一会儿后，%randombrother%起身建议战团都下去。现在看来有人埋伏的几率应该不太大。你和战团一路小跑，来到那可怜人的身边。他垂着头，眼睛半开半闭，嘴边有着唾液，混杂着血液。他身上也没什么东西，于是你下令%companyname%继续上路。",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "安息吧。",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-1);
						return 0;
					}

				}
			],
			function start()
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().isOffendedByViolence() && !bro.getBackground().isCombatBackground())
					{
						bro.worsenMood(0.5, "You let a crucified man die a slow death");

						if (bro.getMoodState() < this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在%location1%……",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你到达%location1%然后让你的人休息一下。在他们休息时，你要清点物资以确保一切井然有序。很快，你就要携战团继续行军。 |  在%location1%停下，那是ini巡逻的第一站，让你的人休息一下。你前面还有更长的路要走所以你现在就要想好时机来补给物资。 |  巡逻第一站结束了。现在你要前往下一个地点。在你的人抱怨时你告知他们。你同样告知他们你不是付钱给他们发牢骚的，然后他们就会对那点继续发牢骚。 |  你到达巡逻第一站然后清点下物资，这时可以命令士兵休息。巡逻只完成了1/3。你在想是不是应该在继续行军前备货更多装备。 |  你安全抵达%location1%，大部分还算无恙。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "我们继续。",
					function getResult()
					{
						this.Contract.setState("Location2");
						return 0;
					}

				}
			],
			function start()
			{
				if (this.Math.rand(1, 100) <= 33)
				{
					this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/safe_roads_situation"), 2, this.Contract.m.Location1, this.List);
				}
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "在%location2%……",
			Text = "[img]gfx/ui/events/event_45.png[/img]{%location2%就在传说的位置。你让属下休息一会儿回复一下，然后自己计划下最后一站巡逻点。 |  巡逻将你带去%location2%，那和你在任何地方见到的一样都是废话和猜疑。你还有一站要去，所以收集物资会是很棒的主意。 |  属下散进%location2%的酒吧。你只是盘点了下物资然后看是否需要重新补给。你扫视了下酒吧的昏暗灯光，然后想着小酌一杯似乎也无伤大雅。 |  到达%location2%后，%randombrother%建议战团应该为返回%employer%的旅途收集些物资。你已经想到了这一点，但你还是让那个佣兵心满意足地觉得那是他想到的主意。",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "我们继续。",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				if (this.Math.rand(1, 100) <= 33)
				{
					this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/safe_roads_situation"), 2, this.Contract.m.Location2, this.List);
				}
			}

		});
		this.m.Screens.push({
			ID = "Success3",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你的返回让%employer%有些好奇。他在点着克朗，但在给你之前，他询问你这趟旅途中收集了多少“首级”。在回禀了%killcount%的击杀数后，他咬着嘴唇点头道。%SPEECH_ON%很好。%SPEECH_OFF%他将克朗塞进背包然后递过来。 |  回到%employer%后，你发现他深深陷进巨型座椅，仿佛他需要那么大空间来支撑他的高贵、奢华和骄傲。\n\n你谈论着巡逻，以及沿途如何击杀的%killcount%。你的强调点在于技术，因为那是你得到酬劳的原因。%employer%点点头兵让他的人将克朗塞进背包然后递过来。 |  %employer%倚着窗台，喝着酒似乎在对下面花园的女人们抛媚眼。他询问你沿途击杀了多少人，甚至连头都没转。%SPEECH_ON%%killcount%。%SPEECH_OFF% 他咯咯笑了。%SPEECH_ON%你似乎完成的很轻松。%SPEECH_OFF%同样的，还是扣着手指没有看你。旁边出来一位带着背包的男子。收下吧，然后可以退下了。 |  %employer%欢迎你入内时正在读着卷纸。他很好奇你在巡逻途中杀死了多少人。你回禀到%killcount%，他嗯了一声然后在一张纸上记录了一下。他点点头，打开身旁的箱子然后往背包中塞克朗。他递给你然后甚至没有抬头地，让你退下。 |  %employer%的住所正在举行宴会。你穿过醉醺醺的人群来到他面前。他在音乐与嘈杂声中呼喊，询问你的巡逻途中杀死了多少人。这有些奇怪，但叫喊着你击杀了%killcount%似乎对聚会的成员没有任何影响。%employer%耸耸肩然后转身离开，滑进与会的人群中。你试图追赶，但一个人拦住了你，将一个背包丢到你怀中。%SPEECH_ON%这是你的报酬，雇佣兵。现在，请离开。人们开始注意到你而他们不是来这感到不适的。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "今天行军路程够了。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.Assets.addMoney(this.Contract.m.Payment.getPerCount() * this.Flags.get("HeadsCollected"));
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Patrolled the realm");
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
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] 克朗"
				});

				if (this.Math.rand(1, 100) <= 33)
				{
					this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/safe_roads_situation"), 2, this.Contract.m.Home, this.List);
				}
			}

		});
		this.m.Screens.push({
			ID = "Success4",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你空手回到%employer%那。他估量着你，显然注意到你没有任何战利品。%SPEECH_ON%真的吗？一点也不麻烦？%SPEECH_OFF%别动。他咬着嘴唇耸耸肩道。%SPEECH_ON%啊该死，好吧……%SPEECH_OFF%他看向你几乎笑出声。%SPEECH_ON%有意思。%SPEECH_OFF%  |  %employer%上下打量着你。%SPEECH_ON% 说好的手机呢，佣兵？你该不会是忘了收集吧……？%SPEECH_OFF%你解释道在巡逻途中没有发现任何情况。他眉毛上扬。%SPEECH_ON%什么都没撞见？该死……好吧……再见。%SPEECH_OFF%  |  你空手回到%employer%那。他看着你，不带任何……货物。%SPEECH_ON%这是什么情况？说好的脑袋呢？%SPEECH_OFF%你耸耸肩，解释道巡逻途中没有遇到任何情况。%employer%喝了口酒对你的回复差点被刚喝的酒呛到。%SPEECH_ON%等等，真的吗？我是说，那应该算是好事，不过该死的……真没料到。我，呃，估计你也没料到。%SPEECH_OFF%你俩大眼瞪小眼。一声鸟叫打破寂静。他喝了口酒然后望向窗外。%SPEECH_ON%那么……今天天气不错啊，是吗？%SPEECH_OFF%你眼珠转动。}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "今天行军路程够了。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnVictory);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractPoor, "Patrolled the realm");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				if (this.Contract.m.Payment.getOnCompletion() > 0)
				{
					this.List.push({
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你的巡逻花了太长时间。所以合约失效了。 |  %employer%的属下带着布告靠近。上面写着你的巡逻应该要迅速，而不是悠闲的散步。所以合约失效了。 |  你打算怎么做，尽可能多地收集人头吗？你的雇主，%employer%，会相信这样的诡计就怪了。他给你这么少时间完成任务是有原因的。所以它失效了。}",
			Image = "",
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "去他妈的合同！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Wandered off while tasked to patrol");
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

		if (!_actor.isAlliedWithPlayer() && !_actor.isAlliedWith(this.m.Faction) && !_actor.isResurrected())
		{
			this.m.Flags.set("HeadsCollected", this.m.Flags.get("HeadsCollected") + 1);
		}
	}

	function spawnEnemies()
	{
		if (this.m.Flags.get("HeadsCollected") >= this.m.Payment.MaxCount)
		{
			return false;
		}

		local tries = 0;
		local myTile = this.m.NextObjective.getTile();
		local tile;

		while (tries++ < 10)
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

			local bandits_dist = nearest_bandits != null ? nearest_bandits.getTile().getDistanceTo(tile) + this.Math.rand(0, 10) : 9000;
			local goblins_dist = nearest_goblins != null ? nearest_goblins.getTile().getDistanceTo(tile) + this.Math.rand(0, 10) : 9000;
			local orcs_dist = nearest_orcs != null ? nearest_orcs.getTile().getDistanceTo(tile) + this.Math.rand(0, 10) : 9000;
			local party;
			local origin;

			if (bandits_dist <= goblins_dist && bandits_dist <= orcs_dist)
			{
				if (this.Math.rand(1, 100) <= 50)
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).spawnEntity(tile, "Brigands", false, this.Const.World.Spawn.BanditRaiders, 110 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				}
				else
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).spawnEntity(tile, "Brigand Hunters", false, this.Const.World.Spawn.BanditRoamers, 80 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				}

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
				if (this.Math.rand(1, 100) <= 50)
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).spawnEntity(tile, "Goblin Raiders", false, this.Const.World.Spawn.GoblinRaiders, 110 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				}
				else
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).spawnEntity(tile, "Goblin Scouts", false, this.Const.World.Spawn.GoblinScouts, 80 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				}

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
				if (this.Math.rand(1, 100) <= 50)
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).spawnEntity(tile, "Orc Marauders", false, this.Const.World.Spawn.OrcRaiders, 110 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				}
				else
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).spawnEntity(tile, "Orc Scouts", false, this.Const.World.Spawn.OrcScouts, 80 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
				}

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
		_vars.push([
			"location1",
			this.m.Location1.getName()
		]);
		_vars.push([
			"location2",
			this.m.Location2.getName()
		]);
		_vars.push([
			"killcount",
			this.m.Flags.get("HeadsCollected")
		]);
		_vars.push([
			"noblehousename",
			this.World.FactionManager.getFaction(this.m.Faction).getNameOnly()
		]);
		_vars.push([
			"days",
			7 - (this.World.getTime().Days - this.m.Flags.get("StartDay"))
		]);
		_vars.push([
			"crucifiedman",
			this.m.Dude != null ? this.m.Dude.getNameOnly() : ""
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Location1 != null)
			{
				this.m.Location1.getSprite("selection").Visible = false;
			}

			if (this.m.Location2 != null)
			{
				this.m.Location2.getSprite("selection").Visible = false;
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (this.m.IsStarted)
		{
			if (this.m.Location1 == null || this.m.Location1.isNull() || !this.m.Location1.isAlive())
			{
				return false;
			}

			if (this.m.Location2 == null || this.m.Location2.isNull() || !this.m.Location2.isAlive())
			{
				return false;
			}

			return true;
		}
		else
		{
			if (this.World.FactionManager.getFaction(this.m.Faction).getSettlements().len() < 3)
			{
				return false;
			}

			return true;
		}
	}

	function onIsTileUsed( _tile )
	{
		if (this.m.Location1 != null && !this.m.Location1.isNull() && _tile.ID == this.m.Location1.getTile().ID)
		{
			return true;
		}

		if (this.m.Location2 != null && !this.m.Location2.isNull() && _tile.ID == this.m.Location2.getTile().ID)
		{
			return true;
		}

		return false;
	}

	function onSerialize( _out )
	{
		if (this.m.Location1 != null)
		{
			_out.writeU32(this.m.Location1.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		if (this.m.Location2 != null)
		{
			_out.writeU32(this.m.Location2.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local location1 = _in.readU32();

		if (location1 != 0)
		{
			this.m.Location1 = this.WeakTableRef(this.World.getEntityByID(location1));
		}

		local location2 = _in.readU32();

		if (location2 != 0)
		{
			this.m.Location2 = this.WeakTableRef(this.World.getEntityByID(location2));
		}

		this.contract.onDeserialize(_in);
	}

});

