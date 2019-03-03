this.drive_away_bandits_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Dude = null,
		Reward = 0,
		OriginalReward = 0
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.drive_away_bandits";
		this.m.Name = "赶走强盗";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function generateName()
	{
		local vars = [
			[
				"randomname",
				this.Const.Strings.CharacterNames[this.Math.rand(0, this.Const.Strings.CharacterNames.len() - 1)]
			],
			[
				"randomtown",
				this.Const.World.LocationNames.VillageWestern[this.Math.rand(0, this.Const.World.LocationNames.VillageWestern.len() - 1)]
			]
		];
		return this.buildTextFromTemplate(this.Const.Strings.BanditLeaderNames[this.Math.rand(0, this.Const.Strings.BanditLeaderNames.len() - 1)], vars);
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		local banditcamp = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getNearestSettlement(this.m.Home.getTile());
		this.m.Destination = this.WeakTableRef(banditcamp);
		this.m.Flags.set("DestinationName", banditcamp.getName());
		this.m.Flags.set("RobberBaronName", this.generateName());
		this.m.Payment.Pool = 550 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

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
					"驱赶位于 %origin% 的 %direction%方向的" + this.Flags.get("DestinationName") + "里的强盗"
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

				if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Destination.getTags().get("IsEventLocation"))
				{
					this.Contract.m.Destination.getLoot().clear();
				}

				this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.BanditDefenders, 110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.setLootScaleBasedOnResources(110 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 70 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult()));
				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);

				if (this.World.Assets.getBusinessReputation() >= 500 && this.Contract.getDifficultyMult() >= 0.95 && this.Math.rand(1, 100) <= 20)
				{
					this.Flags.set("IsRobberBaronPresent", true);

					if (this.World.Assets.getBusinessReputation() > 600 && this.Math.rand(1, 100) <= 50)
					{
						this.Flags.set("IsBountyHunterPresent", true);
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
					if (this.Flags.get("IsRobberBaronDead"))
					{
						this.Contract.setScreen("RobberBaronDead");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Math.rand(1, 100) <= 10)
					{
						this.Contract.setScreen("Survivors1");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Math.rand(1, 100) <= 10 && this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
					{
						this.Contract.setScreen("Volunteer1");
						this.World.Contracts.showActiveContract();
					}

					this.Contract.setState("Return");
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				if (this.Flags.get("IsRobberBaronPresent"))
				{
					if (!this.Flags.get("IsAttackDialogTriggered"))
					{
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.setScreen("AttackRobberBaron");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.Music = this.Const.Music.BanditTracks;
						properties.Entities.push({
							ID = this.Const.EntityType.BanditLeader,
							Variant = 0,
							Row = 2,
							Script = "scripts/entity/tactical/enemies/bandit_leader",
							Faction = _dest.getFaction(),
							Callback = this.onRobberBaronPlaced.bindenv(this)
						});
						properties.EnemyBanners.push(this.Contract.m.Destination.getBanner());
						this.World.Contracts.startScriptedCombat(properties, true, true, true);
					}
				}
				else
				{
					this.World.Contracts.showCombatDialog();
				}
			}

			function onRobberBaronPlaced( _entity, _tag )
			{
				_entity.getTags().set("IsRobberBaron", true);
				_entity.setName(this.Flags.get("RobberBaronName"));
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getTags().get("IsRobberBaron") == true)
				{
					this.Flags.set("IsRobberBaronDead", true);
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
					if (this.Flags.get("IsRobberBaronDead"))
					{
						this.Contract.setScreen("Success2");
					}
					else
					{
						this.Contract.setScreen("Success1");
					}

					this.World.Contracts.showActiveContract();
				}

				if (this.Flags.get("IsRobberBaronDead") && this.Flags.get("IsBountyHunterPresent") && !this.TempFlags.get("IsBountyHunterTriggered") && this.World.Events.getLastBattleTime() + 7.0 < this.Time.getVirtualTimeF() && this.Math.rand(1, 1000) <= 2)
				{
					this.Contract.setScreen("BountyHunters1");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "BountyHunters")
				{
					this.Flags.set("IsBountyHunterPresent", false);
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
			Text = "[img]gfx/ui/events/event_20.png[/img]{%employer%愤怒地摇了摇他的头。%SPEECH_ON%强盗们已经在这里肆虐了太久了!我派了一个小伙子去找他们，%randomname%的儿子。你猜怎么着？只有头回来了。当然了，那愚蠢的强盗派了自己人去送。我们捕获了他然后审问了一番……所以现在我们知道他们在哪了。%SPEECH_OFF%男人往后靠了靠，诺有所思的动着拇指。%SPEECH_ON%我没有人手，但是我有克朗 -我给你点，然后你给他们身上捅几把剑怎么样？%SPEECH_OFF%  |  %employer%给自己倒了杯酒，盯着杯子，然后倒了更多酒。他在说话之前一口闷掉了一整杯酒。%SPEECH_ON%强盗杀掉了%randomname%全家。你敢信？我知道你不知道他们是谁，但是他们是所有人都喜欢的一家。我保证你已经明白了，我想要弄死这些强盗。为了找到他们的营地我已经浪费了一半的人手，现在我已经准备花费半……我的一些克朗雇用你去杀了他们。你感兴趣吗？%SPEECH_OFF%  |  %employer%朝窗外看去，沉思着，手指在酒杯边缘动着。%SPEECH_ON%强盗们抢走了重要的牲口。强盗们是晚上来的，他们切断了铃铛所以什么声音都没有。我肯定牲口对你来说不是什么重要东西，但是一头公牛，一头母牛，一头小牛呢？那对于这地方的某些人来说可是一大笔钱啊。\n\n有天我让一个小伙子跟着动物的痕迹出城去探路，然后他告诉我了强盗的具体位置。我肯定你猜得到，我没有足够的人手去解决这些恶棍，但是克朗……我不缺克朗。如果我给你手里塞点铜，你愿意给那些强盗们肚子里塞点铁吗？%SPEECH_OFF%  |  %employer%叹了一口气，就像是厌倦了这些问题一样，尽管他马上就要开始说以前说过很多次的话。%SPEECH_ON%%randomname%，一个这里有点地位的人，说强盗轮了一遍她的女儿。现在他很担心他们下次也会这么做。幸运的是，那人有点钱，而且可以轻松追踪到强盗的所在地。如果我给你一笔可观数目的钱，你有多愿意捅死几个强盗？%SPEECH_OFF%  |  %employer%坐进了一张大到两个人都能坐进去的椅子里面。他玩弄着一个酒杯。%SPEECH_ON%强盗们已经骚扰了我们好几周了，就在昨天，他们还想要烧掉酒馆。你敢信？谁会烧这种东西？幸运的是我们及时扑灭了大伙，但是这里每况愈下。如果他们都已经开始威胁我们珍贵的饮品了，他们接下来还会做什么？幸运的是，我们成功找到了这些恶棍的藏身之地。所以……对的，你懂了。这是个简单的要求，佣兵：我们想要你杀掉那里的每一个强盗。你愿意帮我们工作吗？%SPEECH_OFF%  |  当你进入房间时，%employer%正好喝掉了一杯蛇酒，他将杯子扔了出去。杯子碰撞的铿锵声传的很远，很远。他转向了你。%SPEECH_ON%在路上时，强盗冲上了我的马车，抢走了所有东西！他们留了我条命，虽然说还不错，但是他们做的事情让我夜里辗转反侧。我看见了他们嘲笑的面孔……听见了他们的笑声……我相信那是给我带的信，因为我拒绝支付他们的“过路费”。好了，现在我准备好付钱了 -给你的，佣兵。如果你去杀了那些恶棍，我就给你封个大大的红包。怎么说？%SPEECH_OFF%  |  当你坐下之后，%employer%朝你扔了一份卷轴。当你接住时卷轴打开了。你看了起来，但是%employer%自己开始说了起来。%SPEECH_ON%%randomtown%的商人们约定除非我们的强盗问题解决，不然再也不来%townname%了。这个过程很简单，我肯定已经明白了强盗的手法，但是这些该死的恶棍一直在阻碍道路，劫掠车队，屠杀商人。\n\n我知道他们在哪，我只需要有胆量、需要黄金的人！去杀了他们。你怎么说，佣兵？说个价钱，然后我们就可以谈了。%SPEECH_OFF%  |  当你见到他的时候%employer%浑身打颤。他因为愤怒都要口吐白沫了 -或者也有可能他是喝醉了。%SPEECH_ON%这个村庄的人们在挨饿。为什么？因为强盗们不停在晚上过来劫掠粮仓！如果我们看见他们了，他们就把建筑烧了。现在我们不能坐等了……现在……我想要通过杀光他们来保护自己。%SPEECH_OFF%男人摇晃了一会，差点就要躺倒在桌子上了。他镇定了一下然后继续。%SPEECH_ON%我想要你杀掉那些恶棍。你要做的就是……打嗝……开个价出来。%SPEECH_OFF%  |  %employer%严肃地看着地面。他打开了一份卷轴，给你看了一张脸。%SPEECH_ON%这是%randomname%,之前被我们抓住，但是现在逃跑了的一个强盗。他曾经是一队不分日夜骚扰劫掠我们城镇的恶棍。问题是，他不是真正的毒蛇头领，而只是九头蛇的一个头而已。杀掉一个头，其他几个就会接替他的位置。所以你的答案是什么？当然是杀光他们啦。我想要你做那事情，佣兵.你感兴趣吗？%SPEECH_OFF%  |  当你想找个位子坐下来的时候%employer%转向了你。%SPEECH_ON%你好啊，佣兵，自从你的利剑最后一次品尝邪恶，冷酷之人的鲜血已经过了多久了？%SPEECH_OFF%他不再讽刺，你觉得现在应该说话了勒。%SPEECH_ON%我们%townname%的人与一些当地强盗起了点矛盾。我们那边的当地强盗啦，他们那鼠洞离这里不远。很明显，我觉得这问题的答案就是雇一群像你的战团这样强汉的小伙去解决他们。那么，感兴趣了吗，佣兵，还是说我需要找更强壮的人去完成这任务？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{多少克朗？ |  %townname%准备为他们的安全付出多少？ | 来讲正事。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{没兴趣。 | 你还有更重要的事情要处理。 | 祝你好运，但跟我们无关。}",
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
			ID = "AttackRobberBaron",
			Title = "攻击前……",
			Text = "[img]gfx/ui/events/event_54.png[/img]{在侦查强盗营地时，你注意到了一个符合当地人疯狂谈论对象特征的男人：是%robberbaron%，一个肆虐此地臭名昭著的强盗。不管他去哪里都有一群恶棍跟着他。\n\n你猜他的脑袋肯定值点克朗。 | 你不是为了找他才来，但是毫无疑问是他本人：%robberbaron%在强盗营地里面。臭名昭著的杀手似乎正在拜访他的一个犯罪分部，一本正经在盗贼中间走着，手指江山，评头道足。\n\n有几个保镖跟着他。你估计了一下他和剩下来的强盗人数，大概是有%totalenemy%人。 | 合约是只要杀光强盗，但是似乎又来了一个大得多的奖品：%robberbaron%，臭名昭著的杀手和掠夺者，就在营地里面。一个保镖跟着他，强盗男爵看上去在评估他的罪犯队伍。\n\n你好奇%robberbaron%的脑袋能值多重的克朗…… | %robberbaron%。你知道就是他。通过一个望远镜，你可以轻松看见臭名昭著的强盗男爵在强盗营地里面大摇大摆的身影。你本来没有计划有他，合约里面也没提到他，但是毫无疑问如果你把他的脑袋带回城镇能让你弄到额外一笔钱。 | 在观察强盗时，你发现大概有%totalenemy%人在营地里，而且你发现了一个异意外的身影：%robberbaron%，臭名昭著的强盗男爵。男人和他的保镖肯定是在视察营地。\n\n真是太幸运了！如果你可以把他的头带给你的雇主，说不定能拿份额外奖金。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备攻击！",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "RobberBaronDead",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{战斗结束了，你走向%robberbaron%被击杀的尸首，利剑连挥两下将他身首分离，一刀斩肉，二刀断骨。你将一根钩子穿过脖颈，连上一根绳索把那东西挂在了腰上。 | 当战斗结束之后，你快速打扫着战场，并且在死尸中发现了%robberbaron%。虽然你全无血色，他看上去还是相当强大。虽然你将他身首分离，但是他的表情还是难以忍受，于是你将他的头扔进了行囊中。 | %robberbaron%死在了你的脚下。你将身体翻了个身，然后把脖子撸直了，准备挥剑。你花了两下才将他的头砍了下来，你把那脑袋放进了一个袋子中。 |  现在他已经死了，%robberbaron%瞬间让你想起来了你过去认识的好多人。你没有沉迷于那既视感很久：快速挥砍了几下后，你将那男人的头颅卸了下来，扔进了一个背囊中。 | %robberbaron%挣扎的很厉害，他的脖子也是，筋肉和骨骼阻扰着你，不想让你轻松收集你的奖赏。 |  你收下了%robberbaron%的脑袋。%randombrother%当你走过的时候指着你。%SPEECH_ON%那是什么？那是%robberbaron%的…………？%SPEECH_OFF%你摇了摇头。%SPEECH_ON%不，那个人已经死了。这东西现在就只是一大笔赏金而已。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "走了！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BountyHunters1",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_07.png[/img]{回去收集赏金的路上，几个男人挡住了你的去路。其中一个人指着%robberbaron%的脑袋。%SPEECH_ON%我们这一块最棒的赏金猎人，我相信你们挡了我们的财路。把脑袋给我们，双方今晚都可以上床日斜支撑。%SPEECH_OFF%你笑了起来。%SPEECH_ON%你得再试试。%robberbaron%的脑袋值很多钱，我的朋友。%SPEECH_OFF%这些赏金猎人的头领也笑了起来。他举起了一个球形袋子。%SPEECH_ON%这里的是%randomname%，这地方另一个悬赏目标。然后这……%SPEECH_OFF%他拿出了另一个袋子。%SPEECH_ON%是那个杀了他的男人的脑袋。明白了吗？快点把脑袋交过来，我们早点各回各家。%SPEECH_OFF%  |  一个男人站在路上，背挺的笔直，朝你做了个手势。%SPEECH_ON%好心的先生们。我相信你们手上有%robberbaron%的脑袋。%SPEECH_OFF%你点了点头。男人微笑起来。%SPEECH_ON%你愿意把那东西交给我吗。%SPEECH_OFF%你们大笑起来，摇了摇头。男人没有微笑，他反而举起了一只手，然后打了一个响指。一队装备精良的人从附近的树丛中跑了出来，冲到了路上，沉重的金属碰撞着，铿锵声此起彼伏。他们看上去去就像是临死之人梦到的东西一样。他们的头领咧出了一个金闪闪的笑容。%SPEECH_ON%我不会问第二遍。%SPEECH_OFF% |  在与%randombrother%讲话时，一声大叫吸引了你的注意力。你看向路面，一群人堵在了你的路上。他们手上拿着各式武器。他们的领袖往前站了出来，宣称他们是有名的赏金猎人。%SPEECH_ON%我们只想要%robberbaron%的脑袋。%SPEECH_OFF%你耸了耸肩。%SPEECH_ON%是我们杀的人，我们的赏金。现在给我滚开。%SPEECH_OFF%当你往前站了一步之后，赏金猎人们举起了他们的武器。他们的领袖朝你走进了一步。%SPEECH_ON%现在你可以做一个选择，里面牵扯到了许多人的性命。我知道这不容易，但是我建议你好好仔细想一下。%SPEECH_OFF%  | 一声尖锐的口哨声吸引了你和手下的注意。你转向路面，看见一队人从树丛中蹿了出来。所有人都拔出了武器，但是陌生人们没有动。他们的领袖站了出来。他胸口挂了一串耳朵项链，炫耀用的战利品。%SPEECH_ON% 大嘎吼啊。我们是赏金猎人，如果你看不出来的话。我相信你有我们的东西。%SPEECH_OFF%你举起了%robberbaron%的脑袋。%SPEECH_ON%你说这个吗？%SPEECH_OFF%领袖热情地微笑着。%SPEECH_ON%对的。如果能麻烦您把那东西交出来，我和我的朋友们就会非常开心了。%SPEECH_OFF%男人敲打着他的剑柄，微笑着。%SPEECH_ON%公事公办。我相信你能理解。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿走那个该死的头，离开这里。",
					function getResult()
					{
						this.Flags.set("IsRobberBaronDead", false);
						this.Flags.set("IsBountyHunterPresent", false);
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractPoor);
						return "BountyHunters2";
					}

				},
				{
					Text = "如果你这么想要的话，就付出血的代价吧。",
					function getResult()
					{
						this.TempFlags.set("IsBountyHunterTriggered", true);
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						local tile = this.World.State.getPlayer().getTile();
						local p = this.Const.Tactical.CombatInfo.getClone();
						p.Music = this.Const.Music.BanditTracks;
						p.TerrainTemplate = this.Const.World.TerrainTacticalTemplate[tile.TacticalType];
						p.Tile = tile;
						p.CombatID = "BountyHunters";
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.BountyHunters, 130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BountyHunters2",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_07.png[/img]你今天已经见到的杀戮已经够多了，你交出了头颅。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们走。还有一份赏金要收集。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Survivors1",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{战斗临近结束，几个敌人跪在了地上求饶。%randombrother%看着你，想要知道你想怎么解决这事情。 |  在战斗后，你的人把剩下来的强盗聚在了一起。幸存者们祈求着他们的性命。一个看上去与其说是男人还不如说是个孩子，但是他是里面最安静的那个。 |  意识到被打败之后，几个剩下来的强盗放下来武器，开始求饶。你现在好奇如果角色交换，他们会做什么。 | 战斗已经结束，但是还有选择要做：有几个强盗在战斗中活了下来。%randombrother%站在一个面前，他的利剑垂在一个囚犯的脖子旁，他向你请示下一步要做什么。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "割喉。",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-1);
						return "Survivors2";
					}

				},
				{
					Text = "拿走他们的武器，赶走他们。",
					function getResult()
					{
						this.World.Assets.addMoralReputation(2);
						return "Survivors3";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Survivors2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{只有天真者才会相信利他主义。你屠杀了囚犯们。 | 你回想起多少次强盗们屠杀手无寸铁的商人。当你下令处决犯人的时候那年头还在你的脑海里挥之不去。他们想要反抗，但是很快就被长剑和长矛砍倒了。 | 你转身离开。%SPEECH_ON%穿过喉咙。记得利落点。%SPEECH_OFF%佣兵们跟随指令，你听见了垂死之人的哽咽声。那样子一点也不会利落啊。 |  你摇了摇头“不”。囚犯们哭号了起来，但是佣兵们已经开始挥砍，戳削。幸运的囚犯在他们意识到终焉以至之前就被斩首了。那些想反抗则痛苦地死去了。 |  慈悲需要时间。是时候回顾过去。是时候思考有没有做正确的选择了。你没有时间。你没有怜悯。囚犯们被处决了，那一点也不费时。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们有重要的事情要处理。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Survivors3",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{今天的杀戮已经够多了。你放走了囚犯，在赶走他们之前没收了他们的武器和盔甲。 | 对于强盗和盗贼们的怜悯不常有，所以当你放走囚犯们的时候，他们几乎是像对神一样在亲吻的脚背。 | 你想了想，然后点了点头。%SPEECH_ON%怜悯好了。拿走他们的装备，然后放了他们。%SPEECH_OFF%犯人们被放走了，留下了之前的武器和盔甲。 | 你将强盗们拨的一干二净，然后放走了他们。%randombrother%拾掇着留下来的装备，你看着一群半裸男人向着远方逃跑。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "杀了他们又没有钱拿。",
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
			Text = "[img]gfx/ui/events/event_22.png[/img]{当战斗结束，事情归于平静之后，你听见了一个男人的吼声。你朝响声走去，发现了一个强盗的囚犯。他的手脚还有嘴都被封住了，你迅速解开了他。他喘了一会气，问能不能加入你们。 | 你在强盗营地发现了一个被绑了起来的囚犯。释放他之后，他解释说自己来自%randomtown%，是被恶棍们几天前绑架到这里的。他问自己能不能加入你的佣兵团。 | 捡拾了强盗营地的废墟之后，你发现了他们的一个囚犯。释放他之后，男人坐了起来，解释说当他去%randomtown%找工作的路上被强盗们绑架了。你好奇他能不能为你工作…… | 战斗后剩下了一个男人。他不是强盗，原来是他们的囚犯。当你问到他的身份时，他说自己来自%randomtown%正在找工作。你问他会不会用剑。他点了点头。}",
			Image = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "你可以加入我们。",
					function getResult()
					{
						return "Volunteer2";
					}

				},
				{
					Text = "回家去吧。",
					function getResult()
					{
						return "Volunteer3";
					}

				}
			],
			function start()
			{
				local roster = this.World.getTemporaryRoster();
				this.Contract.m.Dude = roster.create("scripts/entity/tactical/player");
				this.Contract.m.Dude.setStartValuesEx(this.Const.CharacterLaborerBackgrounds);

				if (this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
				{
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand).removeSelf();
				}

				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Volunteer2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{男人加入了你的队伍，沉浸在被一群当作兄弟的雇佣杀手们的热情欢迎中。新人说他善用所有武器，但是你寻思着你自己来决定他最擅长什么。 | 当你接受他的时候囚犯咧开了一个大大的笑容。几个人问了他要什么武器，但是你耸了耸肩，心想自己来决定给这人什么武器。}",
			Image = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "给你来找把武器。",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Contract.m.Dude.getImagePath());
				this.World.getPlayerRoster().add(this.Contract.m.Dude);
				this.World.getTemporaryRoster().clear();
				this.Contract.m.Dude.onHired();
				this.Contract.m.Dude = null;
			}

		});
		this.m.Screens.push({
			ID = "Volunteer3",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{你摇摇头，那人皱眉。%SPEECH_ON%你确定？我很擅长…%SPEECH_OFF%你打断他的话。%SPEECH_ON%我很确定。陌生人，现在享受新得到的自由吧。%SPEECH_OFF%  |  你打量着那人，觉得他不太适合雇佣兵。%SPEECH_ON%陌生人，虽然很感谢邀请，但是雇佣兵可是刀上舔血的行当。回家去吧，回到家人同事的身边。%SPEECH_OFF%  |  你有足够的人手能帮你度过难关，但是你觉得自己很想换掉%randombrother%，就为了看看他对降职的反应。然而你与囚犯握了握手，然后让他离开了。虽然他很失望，但仍然感谢你还她自由。}",
			Image = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "你走了。",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Contract.m.Dude.getImagePath());
				this.World.getTemporaryRoster().clear();
				this.Contract.m.Dude = null;
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你返回%townname%与%employer%攀谈。旅途的细节简单明了：你杀了强盗。他点点头，微笑着交出%reward%克朗。%SPEECH_ON%伙计，干得漂亮。这些强盗给我们带来了不少麻烦。%SPEECH_OFF%  |  %employer%为你打开门。他手中拿着个小包。%SPEECH_ON%既然你回来了，看来强盗已经死了？%SPEECH_OFF%你点点头。他将小包扔向你。你告诉他自己有可能在撒谎。%employer%耸耸肩。%SPEECH_ON%有可能，但是对于那些忘恩负义之徒，消息传得很快。雇佣兵，干得不错。但是如果你撒谎的话，那么我肯定不会放过你的。%SPEECH_OFF%  |  你走进%employer%的房间，然后将一麻袋脑袋放在他桌子上。%SPEECH_ON%佣兵，证明自己完成了任务无需弄脏了我的好东西。我已经听说过你成功的消息了—这片大陆的小小鸟传消息可快了，不是么？正如协定的%reward%克朗。%SPEECH_OFF%  |  等你完成报告后，%employer%用手帕擦了擦额头。%SPEECH_ON%那么说他们真的都死了？天啊…佣兵，这真是让如释重负。你真是完全不知道！这是之前协定的克朗。%SPEECH_OFF%他将一个小袋子放在桌子上，然后你快速地取过。所有都在这里了，就跟约定的一样。 |  %employer%抿了口酒，然后点点头。%SPEECH_ON%要知道，虽然我并不看得起你这种人，但是你的表现很不错。在你来之前，%randomname%就已经将所有强盗被屠杀的消息告诉我了。照他描述的样子，肯定耗费了不少力气。那好吧…%SPEECH_OFF%他将一个小袋子放在桌子上。%SPEECH_ON%这是之前协定的酬金。%SPEECH_OFF%  |  %employer% 靠在椅子上，插着双手放在膝盖上。%SPEECH_ON%由于你们雇佣兵心血来潮就屠戮摧毁村庄，于是很多人看不惯你们，但是这次你做的很出色。%SPEECH_OFF%他点点头，示意房间角落一个打开的木箱子。%SPEECH_ON%都在那儿了，但是你要清点的话，自便吧。%SPEECH_OFF%你的确清点了下： |  %employer%桌子上布满了肮脏展开的卷轴。他满脸微笑着，似乎在对一堆财宝轻声歌唱。%SPEECH_ON%贸易协议！到处都是！愉悦的农民！愉悦的家庭！大伙儿都高兴！啊，真是太好了。噢，当然了，佣兵，你也不赖嘛，钱包有鼓起来了！%SPEECH_OFF%那人向你扔来一个又一个小钱包。%SPEECH_ON%大点的钱袋子当然也有，但我就喜欢扔钱的这种感觉。%SPEECH_OFF%他嬉笑着扔给你钱袋，你就像剑上仍沾着鲜血的人沉着地随意接过。}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Destroyed a brigand encampment");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] 克朗"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你将罪犯的脑袋仍在%employer%的桌子上。你笑着指了指它。%SPEECH_ON%那是%robberbaron%。%SPEECH_OFF%站起来，然后揭开掩盖着战利品的麻袋。他点点头。%SPEECH_ON%没错，的确是他。看来得给你点额外奖赏。%SPEECH_OFF%不仅干掉了强盗，还摧毁了附近的领导阶层，你的酬金是%reward%克朗。 |  当你提着一颗脑袋走进房间时，%employer%后退几步。幸运的是，没有掉落。%SPEECH_ON%这就是%robberbaron%。或者该说曾经是？%SPEECH_OFF%%employer%粗略地扫了一眼。%SPEECH_ON%‘曾经’更恰当点…那么你不仅剿灭了强盗的老巢，还带来了歹徒领袖的项上头颅。佣兵，真是干得漂亮，该给你额外奖赏。%SPEECH_OFF%那人交出一袋%reward%克朗，然后又从自己身上拿出一个钱袋交给你。 |  你提起%robberbaron%的脑袋，斜视的眼神看着沾满鲜血的头发。%employer%脸上露出微笑。%SPEECH_ON%佣兵，你明白自己做了什么吗？让这个人掉脑袋，你知道自己给这些地方卸掉了多重的包袱吗？你应该得到额外嘉奖！本来任务应得的%reward%克朗…%SPEECH_OFF%他将一个敦实的钱包滑向你。%SPEECH_ON%给你的一点…额外奖励。%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一笔数量可观的克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() * 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Destroyed a brigand encampment");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion() * 2;
				this.Contract.m.OriginalReward = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] 克朗"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"reward",
			this.m.Reward
		]);
		_vars.push([
			"original_reward",
			this.m.OriginalReward
		]);
		_vars.push([
			"robberbaron",
			this.m.Flags.get("RobberBaronName")
		]);
		_vars.push([
			"totalenemy",
			this.m.Destination != null && !this.m.Destination.isNull() ? this.beautifyNumber(this.m.Destination.getTroops().len()) : 0
		]);
		_vars.push([
			"direction",
			this.m.Destination == null || this.m.Destination.isNull() || !this.m.Destination.isAlive() ? "" : this.Const.Strings.Direction8[this.m.Home.getTile().getDirection8To(this.m.Destination.getTile())]
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
			if (this.m.Destination != null && !this.m.Destination.isNull())
			{
				this.m.Destination.getSprite("selection").Visible = false;
				this.m.Destination.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}

		if (this.m.Home != null && !this.m.Home.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Home.getSituationByInstance(this.m.SituationID);

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

			return true;
		}
		else
		{
			return true;
		}
	}

	function onSerialize( _out )
	{
		_out.writeI32(0);

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
		_in.readI32();
		local destination = _in.readU32();

		if (destination != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}

		this.contract.onDeserialize(_in);
	}

});

