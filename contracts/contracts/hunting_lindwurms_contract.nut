this.hunting_lindwurms_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		Dude = null,
		IsPlayerAttacking = true
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.hunting_unholds";
		this.m.Name = "狩猎巨蛇";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		this.m.DifficultyMult = this.Math.rand(95, 135) * 0.01;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 800 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		this.m.Flags.set("Bribe", this.Math.rand(300, 600));
		this.m.Flags.set("MerchantsDead", 0);
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"狩猎 " + this.Contract.m.Home.getName()+"附近的巨蛇"
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

				if (r <= 10)
				{
					this.Flags.set("IsAnimalActivist", true);
				}
				else if (r <= 25)
				{
					this.Flags.set("IsBeastFight", true);
				}
				else if (r <= 35)
				{
					this.Flags.set("IsMerchantInDistress", true);
				}

				this.Flags.set("StartTime", this.Time.getVirtualTimeF());
				local playerTile = this.World.State.getPlayer().getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 6, 12, [
					this.Const.World.TerrainType.Mountains
				]);
				local nearTile = this.Contract.getTileToSpawnLocation(playerTile, 4, 7);
				local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).spawnEntity(tile, "Lindwurm", false, this.Const.World.Spawn.Lindwurm, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.getSprite("banner").setBrush("banner_beasts_01");
				party.setDescription("A Lindwurm - a wingless bipedal dragon resembling a giant snake.");
				party.setAttackableByAI(false);
				party.setFootprintSizeOverride(0.75);
				this.Contract.addFootPrintsFromTo(nearTile, party.getTile(), this.Const.BeastFootprints, 0.75);
				this.Contract.m.Target = this.WeakTableRef(party);
				party.getSprite("banner").setBrush("banner_beasts_01");
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				local roam = this.new("scripts/ai/world/orders/roam_order");
				roam.setPivot(this.Contract.m.Home);
				roam.setMinRange(2);
				roam.setMaxRange(8);
				roam.setAllTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
				roam.setTerrain(this.Const.World.TerrainType.Shore, false);
				roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
				c.addOrder(roam);
				this.Contract.m.Home.setLastSpawnTimeToNow();
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Target != null && !this.Contract.m.Target.isNull())
				{
					this.Contract.m.Target.getSprite("selection").Visible = true;
					this.Contract.m.Target.setOnCombatWithPlayerCallback(this.onTargetAttacked.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Target == null || this.Contract.m.Target.isNull() || !this.Contract.m.Target.isAlive())
				{
					if (this.Flags.get("IsMerchantInDistress"))
					{
						if (this.Flags.get("MerchantsDead") < 5)
						{
							this.Contract.setScreen("MerchantDistressSuccess");
						}
						else
						{
							this.Contract.setScreen("MerchantDistressFailure");
						}
					}
					else
					{
						this.Contract.setScreen("Victory");
					}

					this.World.Contracts.showActiveContract();
					this.Contract.setState("Return");
				}
				else if (!this.Flags.get("IsBanterShown") && this.Contract.m.Target.isHiddenToPlayer() && this.Math.rand(1, 1000) <= 1 && this.Flags.get("StartTime") + 15.0 <= this.Time.getVirtualTimeF())
				{
					this.Flags.set("IsBanterShown", true);
					this.Contract.setScreen("Banter");
					this.World.Contracts.showActiveContract();
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (this.Flags.get("IsBeastFight"))
				{
					this.Contract.setScreen("BeastFight");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsMerchantInDistress"))
				{
					this.Contract.setScreen("MerchantDistress");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsAnimalActivist"))
				{
					this.Contract.setScreen("AnimalActivist");
					this.World.Contracts.showActiveContract();
				}
				else if (!this.Flags.get("IsEncounterShown"))
				{
					this.Flags.set("IsEncounterShown", true);
					this.Contract.setScreen("Encounter");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					this.World.Contracts.showCombatDialog(_isPlayerAttacking);
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_combatID != "Lindwurms")
				{
					return;
				}

				if (_actor.getType() == this.Const.EntityType.CaravanDonkey || _actor.getType() == this.Const.EntityType.CaravanHand)
				{
					this.Flags.increment("MerchantsDead");
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
					if (this.Flags.get("BribeAccepted") && this.Math.rand(1, 100) <= 40)
					{
						this.Contract.setScreen("Failure");
					}
					else
					{
						this.Contract.setScreen("Success");
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
			//Text = "[img]gfx/ui/events/event_77.png[/img]{%employer% is staring into a basket when you find him. A few peasants are off in the corner scratching themselves and looking rather tense. You ask what is going on. Your potential employer brings you over to the basket and inside you find a snake slithering about. It\'s a docile one, and the colors aren\'t arranged in a manner to suggest it carries poison in its belly. You tell him as much. He shrugs and closes the lid.%SPEECH_ON%Gonna kill it and eat it anyhow, take its skin for a dagger sheath. What I need you to do is go find a much larger snake than this. I\'m talking lindwurms, sellsword. Bigguns. Roaming about, eating folks in the hinterland. You the kind to see this situation sorted?%SPEECH_OFF% | You find %employer% mucking about his personal library that\'s more cobweb than knowledge. He seems to sense your entrance and asks if you know about lindwurms. Before you can answer he wheels around, scroll in hand.%SPEECH_ON%I need you to go out to the hinterland. We got a couple of them monsters on our hands. They\'re killing farmers, peddlers. Hell, some of those folks were even well liked. I figure you\'d be just the man we\'d need to get these beasts off our backs. Are you interested?%SPEECH_OFF%You see his scroll unfurl a bit to reveal a crudely drawn woman and her exposed breast. The man hurriedly rolls it back up and stows it behind his back. He smiles.%SPEECH_ON%Well are ya?%SPEECH_OFF% | A line of peasants stand outside %employer%\'s door. You cut by them all and when a few protest you grab the handle on your sword. %employer% jumps out of his door and intervenes.%SPEECH_ON%Ease up, ease up everyone. This is the mercenary I wanted to hire. Sir, please, let me explain the short tempers. Lindwurms are ravaging the countryside and we need a strapping sellsword such as yourself to slay them all. Are you interested?%SPEECH_OFF%The once angry peons now stare at you as though you were a savior.}",
		Text = "[img]gfx/ui/events/event_77.png[/img]{你的雇主把你带到篮子旁边，里面有一条蛇在游动。它是一种温顺的动物，颜色的排列方式并不表明它肚子里有毒药。你告诉他这些。他耸了耸肩，关上了盖子。%SPEECH_ON%无论如何，我要杀了它，吃掉它，把它的皮当匕首鞘。然后我要你去找一条比这大得多的蛇。我在说巨蛇，佣兵。它们到处游荡，吃内陆的人。你能帮我解决这个问题吗?%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{你要求我们做的是一项艰巨的任务. | 与这样的敌人作战，我期望得到丰厚的报酬. | 我希望你能让我成为一个富翁.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{听起来你更需要的是英雄和傻瓜. | 不值得冒这个险. | 我不这么认为.}",
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
			ID = "Banter",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_66.png[/img]{%randombrother% holds a sleeve of scaly skin at the length of his weapon. He wiggles it around, the shedding scratching itself in dry rasps. You tell him to put it down and to be on guard. The lindwurms are no doubt close. | %randombrother% states that he once heard the story of a lindwurm that killed someone without eating them.%SPEECH_ON%That\'s right. They said it spewed green water and the man just melted into his own boots. Said it looked like soup with his shins for stirring.%SPEECH_OFF%A disgusting tale, but one that hopefully keeps the men rightfully on their toes. Those lindwurms can\'t be far. | The tracks have the grass flattened in a snaking pattern with holes set to the sides. %randombrother% crouches beside the patterns.%SPEECH_ON%Either a plough with no dig or this be the critters we\'re lookin\' for.%SPEECH_OFF%You nod. The lindwurms can\'t be far.}",
			Text = "[img]gfx/ui/events/event_66.png[/img]{%randombrother%说他曾经听过一个故事，一条巨蛇在没有东西可吃的情况下杀死了一个人。他们说它喷出了绿色的水，那个人的靴子都融化了。这看起来荒谬，但他的小腿在颤抖。这是一个令人作呕的故事，但希望能让男人们保持警觉。那些巨蛇们可能离着不远}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "注意...!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Encounter",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_129.png[/img]{当你在查看地图时，%randombrother%突然叫了起来。抬头一看，巨蛇一家从地上的一个洞里冒了出来，一片片的尘土从他们的身上流了下来。当他们朝着 %companyname%疾驰而来时，它们的身体低低地摇晃着。你拔出剑来，命令士兵们排成队形}",
			//You\'re checking the map when %randombrother% calls out. Looking up, you see the lindwurms emerging from a hole in the ground, great sheets of dust streaming off their sides. Their bodies sway low to the ground as they whip their way toward the %companyname%. You draw out your sword and order the men into formation. | The company comes upon a cave lined with boulders at its front. But as you draw near, the rocks uncoil and flip mid-air and legs shoot out their bellies to plant the landings of what are clearly lindwurms. You step back as the beasts wriggle the dust off their backs and snap their maws with guttural croaking. They turn to you, eyes blinking, and begin to lazily come forward as though your mercenaries were but a minor inconvenience to dispatch. You order the company into formation. The monsters, perhaps sensing you\'re more of a threat, suddenly surge forward, powerfully hissing as their bodies sidewinder over the ground with surprising speed. | The %companyname% steps toward a hill with bones crunching under every step. %randombrother% shushes the company and points to the hilltop. Lindwurms are curved about its crest as though to embroider the very earth. Seemingly sensing your stare, the beasts unfurl and slumber down the slope, some half twisting like children rolling down a hill. Their maws clap and snap, tongues licking the dust out of their eyes, altogether looking like sleepwalking critters more than murderous monsters. But the second their feet step upon the flat earth they seize up and bolt forward, their snaky shapes streaking across the boneyard, powdered bonemeal rooster tailing up in their wake. Drawing your sword, you urgently order the men to formation.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "冲锋!",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "AnimalActivist",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_17.png[/img]{在你开始战斗之前，一个男人的大喊声打断了你的指挥。他看起来几天没刮胡子了，肩膀上挎着一个大背包，头上缠着一条大手帕，头发像盆栽的山艾树一样。除了他憔悴的样子外，身上没有武器。你问他想要什么。他说话急促，声音低沉。%SPEECH_ON%你是来杀巨蛇一家的吗?%SPEECH_OFF%令人讨厌的蛇形怪物在远处扭动着，似乎在像小狗小猫一样互相玩耍.你点点头，告诉他你是被雇来杀死它们的。男人噘起嘴唇。%SPEECH_ON%看见它们皮肤上的闪光了吗?这对它们来说是独一无二的，他们是同类中最后的一群。这些都是稀有的巨蛇，先生，如果把它们完全消灭掉，那对世界本身就是一种可怕的毁灭。 不如我给你%bribe%克朗，然后，呃，你被人雇佣了，对吧?所以你拿这个，%SPEECH_OFF%他从背包里拿出一件又大又粗糙的巨蛇皮衣，递了过来。%SPEECH_ON%告诉你的雇主你找到并杀死了巨蛇一家，并给他们看这个。他们不会知道其中的区别。我看起来有点疯狂，但实际上我很疯狂。像我这样的疯子，如果连一两件事都不懂，就不会跟在这些高大、非常漂亮、非常漂亮的巨蛇后面活下来，明白吗? %SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让开，笨蛋。我们要杀野兽.",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				},
				{
					Text = "很好。我接受你的提议.",
					function getResult()
					{
						return "AnimalActivistAccept";
					}

				}
			],
			function start()
			{
				this.Flags.set("IsAnimalActivist", false);
			}

		});
		this.m.Screens.push({
			ID = "AnimalActivistAccept",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_17.png[/img]{在你看来，巨蛇一家并不是你真正的问题，你只是被雇来杀死它们的。如果疯狂的巨蛇保护者的皮衣愚弄了雇主，你可能会得到双倍的报酬。你接受这笔交易。傻瓜出乎意料地感谢你，拥抱你。他闻起来很难闻，他的头发变得又密又乱，虫子都钻出了洞，你都能看到它们在盯着你看。你把他扔回去，不管他在做什么，祝他好运 %SPEECH_ON%先生，你是正义的.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "但愿我的决定是正确的.",
					function getResult()
					{
						local bribe = this.Flags.get("Bribe");
						this.World.Assets.addMoney(bribe);

						if (this.Contract.m.Target != null && !this.Contract.m.Target.isNull())
						{
							this.Contract.m.Target.getSprite("selection").Visible = false;
							this.Contract.m.Target.setOnCombatWithPlayerCallback(null);
							this.Contract.m.Target.die();
							this.Contract.m.Target = null;
						}

						this.Flags.set("BribeAccepted", true);
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				local bribe = this.Flags.get("Bribe");
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + bribe + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "BeastFight",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_129.png[/img]{尘云从一个遥远的洞口喷出来。当你走近时，你能听到巨蛇的嘶嘶声和其他东西断断续续的咆哮声.%SPEECH_ON%看, 阁下!%SPEECH_OFF%%randombrother% 指着其中一个洞口. 这里有两只吸血鬼在对付一只巨蛇，一只在抓尾巴的时候被甩来甩去，另一只则在用手抓着它的嘴不让它被咬. 怪物们在互相战斗!\n\n你摇摇头，拔出剑来，命令士兵们排成队形。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我不知道这样做是好是坏.",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Lindwurms";
						p.Music = this.Const.Music.BeastsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Edge;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Random;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Ghouls, 100 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getID());
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
			ID = "MerchantDistress",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_41.png[/img]{你看到一个商人和他的马车在路上缓慢地行进。大篷车的后部向上抬起，大篷车后部像布娃娃一样被抛起。一缕绿色从车队后面滑过，另一缕滑到一边。当巨蛇开始进攻时，商人转身跳上了马车。毫无疑问，这些就是你一直在寻找的生物. 在您的命令下,  %companyname% 在车队被摧毁之前冲过去.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "攻击!",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Lindwurms";
						p.Music = this.Const.Music.BeastsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Edge;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Random;
						p.Entities.push({
							ID = this.Const.EntityType.CaravanDonkey,
							Variant = 0,
							Row = -1,
							Script = "scripts/entity/tactical/objective/donkey",
							Faction = this.Const.Faction.PlayerAnimals,
							Callback = null
						});
						p.Entities.push({
							ID = this.Const.EntityType.CaravanDonkey,
							Variant = 0,
							Row = -1,
							Script = "scripts/entity/tactical/objective/donkey",
							Faction = this.Const.Faction.PlayerAnimals,
							Callback = null
						});
						p.Entities.push({
							ID = this.Const.EntityType.CaravanHand,
							Variant = 0,
							Row = -1,
							Script = "scripts/entity/tactical/humans/caravan_hand",
							Faction = this.Const.Faction.PlayerAnimals,
							Callback = null
						});
						p.Entities.push({
							ID = this.Const.EntityType.CaravanHand,
							Variant = 0,
							Row = -1,
							Script = "scripts/entity/tactical/humans/caravan_hand",
							Faction = this.Const.Faction.PlayerAnimals,
							Callback = null
						});
						p.Entities.push({
							ID = this.Const.EntityType.CaravanHand,
							Variant = 0,
							Row = -1,
							Script = "scripts/entity/tactical/humans/caravan_hand",
							Faction = this.Const.Faction.PlayerAnimals,
							Callback = null
						});
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				},
				{
					Text = "后退!",
					function getResult()
					{
						this.Flags.set("IsMerchantInDistress", false);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "MerchantDistressSuccess",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_41.png[/img]{战斗结束了。当你去和商人谈话时，你让佣兵们剥了几块巨蛇的皮。他向你鞠躬表示感谢，亲吻你没有戒指的手指。%SPEECH_ON%谢谢您，先生，谢谢您!呵呵,我的车!我的货物!%SPEECH_OFF%他的目光转向他那辆大篷车的残骸。他瘫倒在地，膝盖埋在废墟里，摇了摇头。%SPEECH_ON%陌生人，我真希望我有什么东西可以报答你，可是它全不见了%SPEECH_OFF%然后他询问道你有没有地图。你拿出你的地图，他拿出一支羽毛笔。%SPEECH_ON%我知道有一个地方据说藏有珍宝。我不知道那是真的还是假的，如果真是这样的话，这谣言就和黄金一样！%SPEECH_OFF%无论如何，你要感谢商人的慷慨，并祝他在未来的旅途中好运。对于%companyname%，需要返回%employer%才能获得报酬.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "有时间的话我们应该去探索那个地方.",
					function getResult()
					{
						this.Contract.setState("Return");
						local bases = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getSettlements();
						local candidates_location = [];

						foreach( b in bases )
						{
							if (!b.getLoot().isEmpty() && !b.isLocationType(this.Const.World.LocationType.Unique) && !b.getTags().get("IsEventLocation"))
							{
								candidates_location.push(b);
							}
						}

						if (candidates_location.len() == 0)
						{
							return 0;
						}

						local location = candidates_location[this.Math.rand(0, candidates_location.len() - 1)];
						this.World.uncoverFogOfWar(location.getTile().Pos, 700.0);
						location.getTags().set("IsEventLocation", true);
						location.setDiscovered(true);
						this.World.getCamera().moveTo(location);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "MerchantDistressFailure",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_60.png[/img]{战斗结束了。你让一半的人去剥巨蛇的皮，当你回去的时候，让雇主看看你的成果。另一半人在商队的残骸中筛选。没有什么值得注意的东西可找，连金子也没有。任何有价值的东西在战斗中都被打得粉碎。商人本人也被撕成两半，两条腿挂在远处，口袋都翻了出来，里面空空如也。嗯，这是一个令人遗憾的方式。破产了，甚至更多。你点点头，然后对着男人们大喊，让他们收拾东西.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "至少我们消灭了那些野兽.",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "Victory",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_130.png[/img]{巨蛇一家已经名正言顺地倾家荡产了。你的战队在远处戳着尸体，确保那些混蛋真的死了。你让一些人去剥皮。雇主终究会期待证据 ｜ 战斗结束了，你收刮着巨蛇一家任何有价值的东西，如剥皮制成衣服。过不了多久，这片土地就会散发出臭味，这种体型过大的蜥蜴被剥去了曾经保护它们的鳞片。向所有人展示着他们那病态的、闪闪发光的肌肉组织。}",
				//Fighting the lindwurms was like taking a butterknife and jabbing it into a basket of vipers. They fought like something from another world, hissing and spewing and biting, but they were no match for the %companyname%\'s resolve and skill. You have the men scalp and skin the creatures and ready them for a return to %employer% for a well earned payday. | The lindwurms lay in well earned ruin. Your company goes about poking the corpses at a distance, making sure the bastards are truly dead. A few gargle and flip over, but that\'s about the last of their living issuances. You order the overgrown lizards scalped and skinned. %employer% will be expecting proof, after all. | You crouch beside a lindwurm and take your hand over its skin. The way you figure, the scales are long and sharp enough to cut your fingers off if jammed in between the wedges. You then stand akimbo over the head and stare into its maw, getting a measure of its teeth with your hands and its gullet with the steel of your sword. %randombrother% comes to your side and asks what they\'re to do next. You unsheathe your sword from the lindwurm\'s throat, wipe it clean, and sheathe it proper. You order the men to skin a few of the beasts and ready a return to %employer%. | The battle over, you have the lindwurms skinned and dressed for anything of value. It isn\'t long for the field to stink of the skinks, the overly large lizards being shorn of the scales that once protected them. Their sickly, glistening musculature bared for all to see, a nakedness and vulnerability is wrought upon the once and always monsters. %randombrother% snorts and runs a sleeve beneath his nose. He nods at his handiwork.%SPEECH_ON%Nothing more than a common creature, just a shade larger than it ought to be.%SPEECH_OFF%Damn right. You order the men to collect what they\'ve got and ready a return to %employer%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们成功了.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_77.png[/img]{你拖着一些巨蛇的皮肉进入%employer%的房间。%SPEECH_ON%做的好，佣兵。关于那些混蛋的报道已经全部绝迹了，所以我敢打赌我们在这里的钱已经花得很值了。用这些皮，我有一个人能用它来修几双破靴子。%SPEECH_OFF%我们只是为了得到这双愚蠢的新靴子吗?你摇摇头，%SPEECH_ON% 啊。好吧，你的工资就在那边的角落里，就像我们商定的那样%SPEECH_OFF%}",
			//| %employer% welcomes you and your booty, a long, scratchy, scaly, scraping piece of lindwurm skin. You heave it across the floor where it skitters like a stiff leather jacket. The mayor nods.%SPEECH_ON%Very, very well done, good sir! Most excellent. Your pay, as promised.%SPEECH_OFF%The man hands you a satchel heavy with well earned crowns. | %employer% is found warming himself beside a fire. He turns around in the seat to see the lindwurm flesh you have brought in with you. The mayor nods.%SPEECH_ON%Quite alright work, sellsword. I\'m curious, do the lizard bastards grow their limbs back? I\'ve heard tales of the reptilian sort carrying such tricks.%SPEECH_OFF%You shrug and state each creature was slain with as much scientific curiosity a good sword can muster. %employer% purses his lips.%SPEECH_ON%Ah. Right. Well your pay is in the corner there, as much as agreed upon.%SPEECH_OFF%He returns to the fire, cozying himself up in a blanket and sipping at the lip of a steamy mug. | %employer% found outside and surrounded by raucous peasants. You yell over the crowd and display the lindwurm skin which you\'ve brought. The crowd quiets for a moment, whispers amongst its numbers, then returns to shouting. You purse your lips and elbow your way into the mob and demand the pay which you are owed. %employer% yells at the peons to spread out and let him breathe. While two guards stand close, he you a leather satchel.%SPEECH_ON%Good work, sellsword. If it ain\'t all there feel free to come back and kill me. I won\'t mind, not on this damned day.%SPEECH_OFF%As you take the satchel and leave, a peasant jabs his finger at the mayor.%SPEECH_ON%Tellin\' ya, that damned bastard, my supposed \'neighborly neighbor\', stole my birds and if he don\'t return them I\'mma burn his whole farm to the farkin\' ground!%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一次成功的狩猎.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Rid the town of lindwurms");
						this.World.Contracts.finishActiveContract();
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
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Failure",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_43.png[/img]{你发现%employer%在他的房间里，里面全是警卫。。不知道发生了什么事，你向市长展示了巨蛇的皮革，并要求支付报酬. %SPEECH_ON%我不认为会发生这种事，佣兵。我不知道你从哪儿弄来的该死的小蜥蜴，相信我，我可以告诉你它是旧的，像石头一样，不是新的。而且我仍然收到蜥蜴袭击领地的报告，所以如果你不介意的话，请在我叫警卫之前离开这个城镇。%SPEECH_OFF%很好。事情就是这样，不管怎样，你只能怪你自己。你关上门就走了.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "完全在意料之内.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail * 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail * 2, "Tried to swindle the town out of money");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function onPrepareVariables( _vars )
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates_helpful = [];
		local candidates_bro1 = [];
		local candidates_bro2 = [];
		local helpful;
		local bro1;
		local bro2;

		foreach( bro in brothers )
		{
			if (bro.getBackground().isLowborn() && !bro.getBackground().isOffendedByViolence() && !bro.getSkills().hasSkill("trait.bright") && bro.getBackground().getID() != "background.hunter")
			{
				candidates_helpful.push(bro);
			}

			candidates_bro1.push(bro);

			if (!bro.getBackground().isOffendedByViolence() && bro.getBackground().isCombatBackground())
			{
				candidates_bro2.push(bro);
			}
		}

		if (candidates_helpful.len() != 0)
		{
			helpful = candidates_helpful[this.Math.rand(0, candidates_helpful.len() - 1)];
		}
		else
		{
			helpful = brothers[this.Math.rand(0, brothers.len() - 1)];
		}

		bro1 = candidates_bro1[this.Math.rand(0, candidates_bro1.len() - 1)];

		if (candidates_bro2.len() > 1)
		{
			do
			{
				bro2 = candidates_bro2[this.Math.rand(0, candidates_bro2.len() - 1)];
			}
			while (bro2.getID() == bro1.getID());
		}
		else if (brothers.len() > 1)
		{
			do
			{
				bro2 = brothers[this.Math.rand(0, brothers.len() - 1)];
			}
			while (bro2.getID() == bro1.getID());
		}
		else
		{
			bro2 = bro1;
		}

		_vars.push([
			"helpfulbrother",
			helpful.getName()
		]);
		_vars.push([
			"bro1",
			bro1.getName()
		]);
		_vars.push([
			"bro2",
			bro2.getName()
		]);
		_vars.push([
			"bribe",
			this.m.Flags.get("Bribe")
		]);
		_vars.push([
			"direction",
			this.m.Target == null || this.m.Target.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Target.getTile())]
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/ambushed_trade_routes_situation"));
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Target != null && !this.m.Target.isNull())
			{
				this.m.Target.getSprite("selection").Visible = false;
				this.m.Target.setOnCombatWithPlayerCallback(null);
				this.m.Target.getController().getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(true);
				this.m.Target.getController().getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(true);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}

		if (this.m.Home != null && !this.m.Home.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Home.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(3);
			}
		}
	}

	function onIsValid()
	{
		return true;
	}

	function onSerialize( _out )
	{
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
		local target = _in.readU32();

		if (target != 0)
		{
			this.m.Target = this.WeakTableRef(this.World.getEntityByID(target));
		}

		this.contract.onDeserialize(_in);
	}

});

