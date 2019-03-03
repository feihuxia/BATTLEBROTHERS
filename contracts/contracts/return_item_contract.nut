this.return_item_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		IsPlayerAttacking = true
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.return_item";
		this.m.Name = "归还物品";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 400 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		local items = [
			"Rare Coin Collection",
			"Ceremonial Staff",
			"Idol of Fertility",
			"Golden Talisman",
			"Tome of Arcane Knowledge",
			"Lockbox",
			"Demonic Statuette",
			"Crystal Skull"
		];
		local r = this.Math.rand(0, items.len() - 1);
		this.m.Flags.set("Item", items[r]);
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"沿着%townname%附近的踪迹",
					"将%item%还给%townname%"
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

				if (r <= 15)
				{
					if (this.Contract.getDifficultyMult() >= 0.95)
					{
						this.Flags.set("IsNecromancer", true);
					}
				}
				else if (r <= 30)
				{
					this.Flags.set("IsCounterOffer", true);
					this.Flags.set("Bribe", this.Contract.beautifyNumber(this.Contract.m.Payment.getOnCompletion() * this.Math.rand(100, 300) * 0.01));
				}
				else
				{
					this.Flags.set("IsBandits", true);
				}

				this.Flags.set("StartDay", this.World.getTime().Days);
				local playerTile = this.World.State.getPlayer().getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 5, 10, [
					this.Const.World.TerrainType.Mountains
				]);
				local party;
				party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).spawnEntity(tile, "Thieves", false, this.Const.World.Spawn.BanditRaiders, 80 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.setDescription("A group of thieves and bandits.");
				party.setAttackableByAI(false);
				party.getController().getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				party.setFootprintSizeOverride(0.75);
				this.Contract.addFootPrintsFromTo(this.Contract.m.Home.getTile(), party.getTile(), this.Const.GenericFootprints, 0.75);
				this.Contract.m.Target = this.WeakTableRef(party);
				party.getSprite("banner").setBrush("banner_bandits_0" + this.Math.rand(1, 6));
				local c = party.getController();
				local wait = this.new("scripts/ai/world/orders/wait_order");
				wait.setTime(9000.0);
				c.addOrder(wait);
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"沿着%townname%的%direction%的踪迹",
					"将%item%还给%townname%"
				];

				if (this.Contract.m.Target != null && !this.Contract.m.Target.isNull())
				{
					this.Contract.m.Target.getSprite("selection").Visible = true;
					this.Contract.m.Target.setOnCombatWithPlayerCallback(this.onTargetAttacked.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Target == null || this.Contract.m.Target.isNull())
				{
					if (this.Flags.get("IsCounterOffer"))
					{
						this.Contract.setScreen("CounterOffer1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("BattleDone");
						this.World.Contracts.showActiveContract();
						this.Contract.setState("Return");
					}
				}
				else if (this.World.getTime().Days - this.Flags.get("StartDay") >= 3 && this.Contract.m.Target.isHiddenToPlayer())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (!this.Flags.get("IsAttackDialogTriggered"))
				{
					if (this.Flags.get("IsNecromancer"))
					{
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
						this.Contract.setScreen("Necromancer");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
						this.Contract.setScreen("Bandits");
						this.World.Contracts.showActiveContract();
					}
				}
				else
				{
					this.World.Contracts.showCombatDialog(_isPlayerAttacking);
				}
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"将%item%还给%townname%"
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
			Text = "[img]gfx/ui/events/event_20.png[/img]{%employer% 不安地来回走动，解释是什么在困扰着他。%SPEECH_ON%发生一次大胆的偷窃行为！卑鄙的强盗偷了我的%itemLower%，它对我来说具有无法估量的价值。我恳求你去追捕那些贼，并且归还我的物品。%SPEECH_OFF%他放低声音，语气坚持。%SPEECH_ON%你不仅会得到丰厚报酬，也能让担忧的%townname%的好人们放下心来！%SPEECH_OFF%  }",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{这对你有什么价值？ |  我们来谈谈报酬。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这听起来可不像是我们的活。 |  我不这么认为。}",
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
			ID = "Bandits",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_80.png[/img]{强盗！就像你的%employer%认为的一样。他们看起来很害怕，可能知道%employer%的愤怒将要落在他们身上。 |  啊，小偷非常人性——流浪汉和强盗的简单成员。当你下令攻击他们的时候，他们武装自己。 |  你抓住一群拿着你的雇主的财产的强盗。他们似乎很震惊你在这里找到他们，没有浪费一点时间武装自己，而你命令%companyname%冲锋。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备迎战！",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Necromancer",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_76.png[/img]{这里有强盗，和预想的一样，但是他们把%itemLower%交给一个穿着黑色破衣服的人。你的出现不出意外地阻止了事务，暴徒和这些鬼怪一样的人都想拿起武器。 |  你抓到强盗把 %employer%的财产交易给一个死灵法师！也许他想用它对房子施放某种邪恶的法术。某种程度上这些看法也不算坏……但是那人钱财替人消灾。冲啊！ |  %employer%的财产被强盗卖给了一位黑衣人！他比别人先盯上你，他锐利的黑眼睛瞬间对你的战团缩小。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "准备迎战！",
					function getResult()
					{
						local unit = clone this.Const.World.Spawn.Troops.Necromancer;
						unit.Faction <- this.Contract.m.Target.getFaction();
						this.Contract.m.Target.getTroops().push(unit);
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CounterOffer1",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_76.png[/img]{你擦去剑上的血迹,去拿回物品。当你弯腰去捡的时候，你发现一个人在远处看着你。他走上前，两只手上有长袖图腾。%SPEECH_ON%我看到你杀了我恩人的人。%SPEECH_OFF%保健入鞘，你对他点点头。他继续说。%SPEECH_ON%我的恩人为了那件神器花了不少钱。似乎他支付的那些已经不欠了，也许我能直接跟你说了。我会给你%bribe%克朗换取那个物品。%SPEECH_OFF%那是……相当多的钱。不过，如果你决定接受，%employer%会不高兴的。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "当我看到一个好交易的时候我会知道。递过克朗。",
					function getResult()
					{
						this.updateAchievement("NeverTrustAMercenary", 1, 1);
						return "CounterOffer2";
					}

				},
				{
					Text = "我们收钱来归还它，而那是我们将要做的事。",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CounterOffer2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_76.png[/img]你交出 %itemLower%，陌生人给你一个重重的袋子。交易完成。你的雇主%employer%会不高兴的。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "好报酬。",
					function getResult()
					{
						this.World.Assets.addMoney(this.Flags.get("Bribe"));
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to return stolen " + this.Flags.get("Item"));
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
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Flags.get("Bribe") + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "BattleDone",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{战斗结束，你从敌人的破包里拿回%itemLower%，准备返回%employer%。他一定很高兴看到你成功！ |  偷%itemLower%的人已经死了，谢天谢地你能找到这物品。%employer%会对你在这里的工作很满意。 |  你找到了偷取%itemLower%的人，并杀死了他们。现在你只需要吧%itemLower%还到%employer%手里，拿到你的奖励！ |  战斗结束，很容易就在敌人的尸体中找到了%itemLower%。你应该把它还给%employer% }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "让我们取得我们的酬劳。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer% 拿走%itemLower%，紧紧地抱住它，仿佛找到了丢失的孩子。他看着神器眼睛都有点湿润了。%SPEECH_ON%T谢谢你，佣兵。这对我而言意义重大……我是说，对这镇子而言。很感激你！%SPEECH_OFF%你盯着他，他停顿了一下。他的目光跳到房间的一角。%SPEECH_ON%我们的……感激，佣兵……%SPEECH_OFF%守卫打开一个巨大的木箱子。你数了数钱离开了。 }",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Returned stolen " + this.Flags.get("Item"));
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
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_75.png[/img]{你蹲到地上，让一些灰尘渗过你的手指。但这只是灰尘——没有脚印穿过道路。事实上，你很久没见过脚印了。%randombrother%加入你，蹲低耸肩。%SPEECH_ON%长官，我想我们跟丢了。%SPEECH_OFF%你点点头。%employer%对此不会高兴的，但事实就是这样。 |  你追踪%itemLower%窃贼的踪迹有段时间了，但线索已经枯竭。你遇到的平民什么都不知道，地上也没有脚印可以追踪。从所有的这些看，%itemLower%已经逃脱了}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "去他妈的合同！",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to return stolen " + this.Flags.get("Item"));
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
			"direction",
			this.m.Target == null || this.m.Target.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Target.getTile())]
		]);
		_vars.push([
			"item",
			this.m.Flags.get("Item")
		]);
		_vars.push([
			"itemLower",
			this.m.Flags.get("Item").tolower()
		]);
		_vars.push([
			"bribe",
			this.m.Flags.get("Bribe")
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Target != null && !this.m.Target.isNull())
			{
				this.m.Target.getSprite("selection").Visible = false;
				this.m.Target.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
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

