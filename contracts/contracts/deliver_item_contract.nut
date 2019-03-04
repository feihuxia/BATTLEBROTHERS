this.deliver_item_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Location = null,
		RecipientID = 0
	},
	function create()
	{
		this.contract.create();
		this.m.DifficultyMult = this.Math.rand(70, 105) * 0.01;
		this.m.Type = "contract.deliver_item";
		this.m.Name = "武装信使";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		if (this.m.Home == null)
		{
			this.setHome(this.World.State.getCurrentTown());
		}

		local recipient = this.World.FactionManager.getFaction(this.m.Destination.getFactions()[0]).getRandomCharacter();
		this.m.RecipientID = recipient.getID();
		this.m.Flags.set("RecipientName", recipient.getName());
		this.contract.start();
	}

	function setup()
	{
		local settlements = this.World.EntityManager.getSettlements();
		local candidates = [];

		foreach( s in settlements )
		{
			if (s.getID() == this.m.Home.getID())
			{
				continue;
			}

			if (!s.isDiscovered()  ||  s.isMilitary())
			{
				continue;
			}

			if (!s.isAlliedWithPlayer())
			{
				continue;
			}

			if (this.m.Home.isIsolated()  ||  s.isIsolated()  ||  !this.m.Home.isConnectedToByRoads(s)  ||  this.m.Home.isCoastal() && s.isCoastal())
			{
				continue;
			}

			local d = this.m.Home.getTile().getDistanceTo(s.getTile());

			if (d < 15  ||  d > 100)
			{
				continue;
			}

			if (this.World.getTime().Days <= 10)
			{
				local distance = this.getDistanceOnRoads(this.m.Home.getTile(), s.getTile());
				local days = this.getDaysRequiredToTravel(distance, this.Const.World.MovementSettings.Speed, false);

				if (this.World.getTime().Days <= 5 && days >= 2)
				{
					continue;
				}

				if (this.World.getTime().Days <= 10 && days >= 3)
				{
					continue;
				}
			}

			candidates.push(s);
		}

		if (candidates.len() == 0)
		{
			this.m.IsValid = false;
			return;
		}

		this.m.Destination = this.WeakTableRef(candidates[this.Math.rand(0, candidates.len() - 1)]);
		local distance = this.getDistanceOnRoads(this.m.Home.getTile(), this.m.Destination.getTile());
		local days = this.getDaysRequiredToTravel(distance, this.Const.World.MovementSettings.Speed, false);

		if (days >= 2  ||  distance >= 40)
		{
			this.m.DifficultyMult = this.Math.rand(95, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(70, 85) * 0.01;
		}

		this.m.Payment.Pool = this.Math.max(125, distance * 4.5 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentLightMult());

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		this.m.Flags.set("Distance", distance);
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"在%days%内把货物交给%direction%方向%objective%里的%recipient%"
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
				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
				local r = this.Math.rand(1, 100);

				if (r <= 10)
				{
					if (this.Contract.getDifficultyMult() >= 0.95 && this.World.Assets.getBusinessReputation() > 750 && (!this.World.Ambitions.hasActiveAmbition()  ||  this.World.Ambitions.getActiveAmbition().getID() != "ambition.defeat_mercenaries"))
					{
						this.Flags.set("IsMercenaries", true);
					}
				}
				else if (r <= 15)
				{
					if (this.World.Assets.getBusinessReputation() > 700)
					{
						this.Flags.set("IsEvilArtifact", true);

						if (!this.World.Tags.get("IsCursedCrystalSkull") && this.Math.rand(1, 100) <= 50)
						{
							this.Flags.set("IsCursedCrystalSkull", true);
						}
					}
				}
				else if (r <= 20)
				{
					if (this.World.Assets.getBusinessReputation() > 500)
					{
						this.Flags.set("IsThieves", true);
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
				this.Contract.m.BulletpointsObjectives = [
					"在%days%内把货物交给%direction%方向%objective%里的%recipient%"
				];

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Destination) && !this.Flags.get("IsStolenByThieves"))
				{
					if (this.Flags.get("IsEnragingMessage"))
					{
						this.Contract.setScreen("EnragingMessage1");
					}
					else
					{
						this.Contract.setScreen("Success1");
					}

					this.World.Contracts.showActiveContract();
				}
				else
				{
					local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);

					foreach( party in parties )
					{
						if (!party.isAlliedWithPlayer)
						{
							return;
						}
					}

					if (this.Flags.get("IsMercenaries") && this.World.State.getPlayer().getTile().HasRoad)
					{
						if (!this.TempFlags.get("IsMercenariesDialogTriggered") && this.Contract.getDistanceToNearestSettlement() >= 6 && this.Math.rand(1, 1000) <= 1)
						{
							this.Contract.setScreen("Mercenaries1");
							this.World.Contracts.showActiveContract();
							this.TempFlags.set("IsMercenariesDialogTriggered", true);
						}
					}
					else if (this.Flags.get("IsEvilArtifact") && !this.Flags.get("IsEvilArtifactDone"))
					{
						if (!this.TempFlags.get("IsEvilArtifactDialogTriggered") && this.Contract.getDistanceToNearestSettlement() >= 6 && this.Math.rand(1, 1000) <= 1)
						{
							this.Contract.setScreen("EvilArtifact1");
							this.World.Contracts.showActiveContract();
							this.TempFlags.set("IsEvilArtifactDialogTriggered", true);
						}
					}
					else if (this.Flags.get("IsEvilArtifact") && this.Flags.get("IsEvilArtifactDone"))
					{
						this.Contract.setScreen("EvilArtifact3");
						this.World.Contracts.showActiveContract();
						this.Flags.set("IsEvilArtifact", false);
					}
					else if (this.Flags.get("IsThieves") && !this.Flags.get("IsStolenByThieves") && (this.World.Assets.isCamping()  ||  !this.World.getTime().IsDaytime) && this.Math.rand(1, 100) <= 3)
					{
						local tile = this.Contract.getTileToSpawnLocation(this.World.State.getPlayer().getTile(), 5, 10, [
							this.Const.World.TerrainType.Shore,
							this.Const.World.TerrainType.Ocean,
							this.Const.World.TerrainType.Mountains
						], false);
						tile.clear();
						this.Contract.m.Location = this.WeakTableRef(this.World.spawnLocation("scripts/entity/world/locations/bandit_hideout_location", tile.Coords));
						this.Contract.m.Location.setResources(0);
						this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).addSettlement(this.Contract.m.Location.get(), false);
						this.Contract.m.Location.onSpawned();
						this.Contract.addUnitsToEntity(this.Contract.m.Location, this.Const.World.Spawn.BanditDefenders, 80 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
						this.Contract.addFootPrintsFromTo(this.World.State.getPlayer().getTile(), tile, this.Const.GenericFootprints, 0.75);
						this.Flags.set("IsStolenByThieves", true);
						this.Contract.setScreen("Thieves1");
						this.World.Contracts.showActiveContract();
					}
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "EvilArtifact")
				{
					this.Flags.set("IsEvilArtifactDone", true);
				}
				else if (_combatID == "Mercs")
				{
					this.Flags.set("IsMercenaries", false);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "EvilArtifact")
				{
					this.World.FactionManager.getFaction(this.Contract.m.Destination.getFactions()[0]).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to deliver cargo");
					this.World.Contracts.removeContract(this.Contract);
				}
				else if (_combatID == "Mercs")
				{
					this.World.FactionManager.getFaction(this.Contract.m.Destination.getFactions()[0]).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to deliver cargo");
					this.World.Contracts.removeContract(this.Contract);
				}
			}

		});
		this.m.States.push({
			ID = "Running_Thieves",
			function start()
			{
				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Location != null && !this.Contract.m.Location.isNull())
				{
					this.Contract.m.Location.getSprite("selection").Visible = true;
				}

				this.Contract.m.BulletpointsObjectives = [
					"跟踪小偷的踪迹并归还你的货物",
					"在%days%内把货物交给%direction%方向%objective%里的%recipient%"
				];
			}

			function update()
			{
				if (this.Contract.m.Location == null  ||  this.Contract.m.Location.isNull())
				{
					this.Contract.setScreen("Thieves2");
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
			Text = "[img]gfx/ui/events/event_112.png[/img] {%employer%将一个大箱子推进你手中，你和他甚至都没来得及说一个字。%SPEECH_ON%瞧啊，需要运送的货物已经找到快递员了！真棒！%SPEECH_OFF%他停下夸张的动作。%SPEECH_ON%你得将这玩意送到%objective%，一个叫%recipient%的正等着呢。虽然看起来没什么，但是只要能安全送到，我不会吝啬酬金的。有兴趣吗？还是你个弱鸡连这都搬不动了？%SPEECH_OFF%  |  你发现%employer%正关上一个盒子。他抬头迅速瞄了一眼，似乎被人抓了个现行。%SPEECH_ON%雇佣兵！多谢前来！%SPEECH_OFF%啪嗒几声，他迅速锁上门闩。然后轻怕了箱子数次，甚至靠在上面，就像还需要一个厚实的栓门一样。%SPEECH_ON%需要将这货物安全送到%objective%。一个叫%recipient%的人正等着呢。任务绝非易事，因为货物相当宝贵，有些人为了得到它肯定会不择手段，所以我才求助于你这样的…老手。有兴趣接下这活儿吗？%SPEECH_OFF%  |  当你走进%employer%房间时，他和一名仆人正钉上箱子。%SPEECH_ON%雇佣兵，很高兴见到你。稍等片刻。不，蠢货，握紧好钉子！我知道之前敲中你的手指了，但是我不会重蹈覆辙的。%SPEECH_OFF%仆人迟疑地握着钉子，雇主好锤在箱子上。完事后，他擦了擦额头的汗水，然后看向你。%SPEECH_ON%我需要将这玩意送到%objective%。接货人是%recipient%，你懂的。就是他。好吧，或许你不认识他。虽然我知道通常来说这并非你的行当，但是只要能完成，我绝不会吝啬酬金。那就是你的需求，对吧？想赚钱？%SPEECH_OFF%  |  %employer%看到你时交叉着双手。%SPEECH_ON%问题或许有点儿奇怪，但是愿意给我送个货吗？%SPEECH_OFF%你解释道，只要价格满意，离别寻常刀尖上舔血的生活也挺不错的。雇主鼓掌说道。%SPEECH_ON%很好！不幸的是，我感觉不会那样。这趟运货很重要，会招引各种苍蝇，所以我才首先找上了雇佣兵。东西得送往%objective%，收货人是%recipient%。所以，如你所闻，并非是你所期待的“离别”，但是酬金不菲。%SPEECH_OFF%  |  %employer%的手下站在货物旁。当雇主看到你时，他示意手下离开。%SPEECH_ON%欢迎，欢迎。很高兴见到你。我需要武装卫兵将这货物送往%objective%的%recipient%。有兴趣替我做这事吗？%SPEECH_OFF%  |  当你进入时，%employer%翘起双脚放在桌子上。手放在头后面，在你看来有点略过于轻松惬意。%SPEECH_ON%好消息，队长。远离杀戮生活，你觉得意下如何。%SPEECH_OFF%你的回应让他轻挑眉毛，准确来说没什么。%SPEECH_ON%哈，我就知道你会抓住机会的。无论如何，是这样的：我需要你将包裹送给居住在%objective%的伙计，名叫%recipient%。货物绝对会引来一些意图不轨的鼠辈，所以我需要你的帮忙。如果你感兴趣，你也应该感兴趣才对，那咱们就来谈谈价格吧。%SPEECH_OFF%  |  %employer%欢迎你，招手示意你进去。%SPEECH_ON% 很好，既然来了，劳烦关上门好吗？%SPEECH_OFF%他的一名卫兵从角落处探出头。你微笑着将他关在外面。你转身发现%employer%正走向一扇窗户。边盯着外面边说。%SPEECH_ON%我有需要…呃，其实吧，你不需要知道具体情况。我需要将这个“东西”送给一个叫%recipient%的伙计。他正在%objective%等着呢。这活儿相当重要，务必要送到目的地，并且必须要有武装护送，所以我才请求你和你的战团帮忙。雇佣兵，意下如何？%SPEECH_OFF%  |  房间里烛光黯淡，你勉强能看到东西，%employer%坐在桌子后，影子随着摇曳烛光在墙上舞动着。%SPEECH_ON%如果我报价不菲，你愿意为我效力吗？我需要将{一个小箱子  |  对我来说很重要  |  很有价值}安全送给%objective%的%recipient%，就在%direction%。这东西引起了杀戮，所以你必须做好拿命守好它的准备。%SPEECH_OFF%他停了下来，权衡着你的反应。%SPEECH_ON%我会写封密信，其中叮嘱了交给你报酬，只要你将它送给%objective%的联系人。如何？%SPEECH_OFF%  |  一名仆人示意你等待%employer%，他说马上就接待你了。于是你等着，等着，等着。终于，当你准备第二次离开时，%employer%%employer%打开门，冲向你。%SPEECH_ON%这是谁来着？雇佣兵？%SPEECH_OFF%他的助手点点头，%employer%便露出了笑容。%SPEECH_ON%队长，你在%townname%里真是三生有幸啊！\n\n我有些宝贵货物得尽快且安全地送往%objective%。我正需要你这样的人，寻常毛贼绝没有那个胆子招惹你和你的手下。\n\n没错，我想雇佣你执行护送任务。确保货物一定要送给%recipient%，当然不用绕弯路。你觉得如何？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{咱们谈谈价格吧。 |  多少克朗？}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{没兴趣。 |  我们的旅途暂时不会前往那里。 |  我们不接这样的活儿。}",
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
			ID = "Mercenaries1",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_07.png[/img]{路程中，一群装备精良的人挡住你的去路。 |  在前往%objective%时，一群人打断的安静的旅途，他们的武器和盔甲叮当作响，并结成阵型。 |  很不幸，你的旅途并不是那么简单。一群人出现在你面前，挡住了去路。 |  一些装备精良的人出现了，似乎陷入了僵局。他们似乎是想拦住你的去路。 |  部分人停了下来。你走上前查明情况，却只看到一排装备精良的人挡住了%companyname%的去路。这下有意思了。}敌人中尉向前一步，紧握拳头锤击胸口。%SPEECH_ON%{%mercband%，站在你面前的是我们。凶兽屠夫，空前绝后，神弃之地的最后希望！ |  行不改名坐不改姓，我们是大名鼎鼎的%mercband%，抛头颅啥热血，大口喝酒大口吃肉，美女们尽皆投怀送抱！ |  在你面前的是传说中的%mercband%。我们乃是%randomtown%的救世主，伪王刽子手！ |  见识下大名鼎鼎的%mercband%！我们击败了上百兽人，拯救城市于水火之中。你又是什么来头？ |  和你说话的是%mercband%。任何寻常毛贼，肮脏绿皮，钱财或妹纸能逃出我们的手掌心！}%%SPEECH_OFF%等这人故作姿态，发表完壮志豪言后，他指了指你带着的货物。%SPEECH_ON%{现在你该明白趟进了什么样的浑水了吧，不如乖乖把货物交出来吧！ |  可悲的雇佣兵，希望你意识到遇到了什么样的对手，不然你的手下今晚可就要长眠于此了。只要你乖乖交出货物，那你的名字就不会荣登咱们%mercband%的光辉史了。 |  啊，我打赌你肯定想登上咱们的光辉史，对吧？哟，好消息，不交货物就可以见识下咱们用剑练就的草书了。当然了，只要你交出货物，那咱们就放你一马。 |  好了，只有%companyname%才会这样。虽然很想让你成为我的手下败将，但是雇佣兵一家亲，我就破例一次好了。你只需要交出货物，那咱们就大路朝天各走一边。意下如何？}%SPEECH_OFF%{嗯，如果别无其他，那真是言过其实了。 |  呃，舞台效果还是相当逗趣的。 |  你不明白表演的必要性，但是新局势的严重性是毫无疑问的。  |  虽然你很欣赏空前绝后的夸张，但是简明扼要的事实仍没有改变，那就是这些人不是开玩笑的。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "如果想要，那就亲手来取吧！",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Mercs";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Mercenaries, 120 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				},
				{
					Text = "没必要丢掉性命。拿走该死的箱子，然后滚吧。",
					function getResult()
					{
						return "Mercenaries2";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Mercenaries2",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_07.png[/img]{不欲战斗，你交出了货物。他们大笑着接过。%SPEECH_ON%明智的选择，雇佣兵。或许有一天你也会像今天的我们。%SPEECH_OFF%  |  无论货物是什么，都不值得自己的手下搭上性命。你交出箱子，然后雇佣兵拿走了。当你离开时，他们大笑着。%SPEECH_ON%真他娘的带劲！%SPEECH_OFF%  |  时间地点都不是自己手下献出性命的时候，而且还是为%employer%运送货物。你交出货物。雇佣兵拿到手后便离开了，他们的副官抛出一枚克朗，旋转着落入尘土之中。%SPEECH_ON%孩子，给自己买点好的吧，这行当不适合你。%SPEECH_OFF%  |  雇佣兵装备精良，如果手下因为什么愚蠢的箱子而丢掉性命，你觉得自己晚上会良心不安，睡不着觉。你点头将货物交了出去。雇佣兵高兴地接过去，他们的副官尊敬地点点头。%SPEECH_ON%明智的选择。Don\'t think I didn\'t make many like it when I was coming up.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Hrm...",
					function getResult()
					{
						this.Flags.set("IsMercenaries", false);
						this.Flags.set("IsMercenariesDialogTriggered", true);
						this.World.FactionManager.getFaction(this.Contract.m.Destination.getFactions()[0]).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to deliver cargo");
						local recipientFaction = this.Contract.m.Destination.getFactionOfType(this.Const.FactionType.Settlement);

						if (recipientFaction != null)
						{
							recipientFaction.addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail * 0.5);
						}

						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BountyHunters1",
			Title = "沿路行走…",
			Text = "[img]gfx/ui/events/event_07.png[/img]{行程中你遇到了一帮赏金猎人。他们的囚犯向你大声呼喊，渴求着救命。他称自己是无辜的。赏金猎人让你滚犊子玩蛋去。 |  在路上你遇到了一群装备精良的赏金猎人。他们推搡着一个头和脚都有镣铐的人。%SPEECH_ON%你可不想成为阶下囚。%SPEECH_OFF%一人说道，踹了下囚犯的腿。那人痛苦地大喊，用染血的手和膝盖向你爬来。%SPEECH_ON%他们都是骗子！我是无辜的，他们却想杀了我！救救我，求求你们了！%SPEECH_OFF%  |  你遇到一大群赏金猎人，虽然俩群人惊人的相似，但明显各自目的迥然不同。他们在运输一名囚犯，那人铐上枷锁，嘴中还塞着破布。他渴求般地向你大喊，直到窒息到满脸通红。一名赏金猎人吐了口唾沫。%SPEECH_ON%陌生人，不关你的事，走你的路。最好还是不要招惹麻烦的好。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "这跟我们没关系。",
					function getResult()
					{
						return 0;
					}

				},
				{
					Text = "或许我们能买下囚犯？",
					function getResult()
					{
						return this.Math.rand(1, 100) <= 50 ? "BountyHunters1" : "BountyHunters1";
					}

				},
				{
					Text = "如果想要，那就亲手来取吧！",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Mercs";
						p.Music = this.Const.Music.NobleTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Mercenaries, 140 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Thieves1",
			Title = "营地…",
			Text = "[img]gfx/ui/events/event_05.png[/img]{你小睡醒来，翻身寻找包裹，就像寻找爱人一般。但是爱人不在，货物也无影无踪。你麻溜的起身，命令手下打起精神。%randombrother%跑上前说他找到了些许足迹。 |  休息时，你听到营地某处发生了骚乱。你快步冲过去，发现%randombrother%躺在地上，手挠着后脑窝。%SPEECH_ON%抱歉，长官，我正在小便，他们报复了我。而且，他们偷走了包裹。%SPEECH_OFF%你让他重复下最后一部分。%SPEECH_ON%该死的毛贼偷走了货物！%SPEECH_OFF%该找到那些狗崽子，夺回货物了。 |  很明显，这趟旅途并非普通。这个狗屎世界怎么会有普通的事情。似乎窃贼带着货物跑了。幸运的是，他们留下了许多证据，足迹，携带包裹留下的拖痕。应该很容易就能找到… |  你就想在两个镇子间享受下旅途，哪怕一次也好。但事与愿违，与%employer%的协议再次引来了麻烦。窃贼想法设法溜进了营地，而且带走了货物。好消息是他们没能逃太远：你发现了足迹，应该不难追踪。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们追踪他们的痕迹！",
					function getResult()
					{
						this.Contract.setState("Running_Thieves");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Thieves2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_22.png[/img]{窃贼的血液变得浓稠。你成功找到雇主的货物，仍在营地里，而且完好无损。这小小的意外就不用让他知道了。 |  好了，一切正常。%employer%的货物就在窃贼扭动的身体下。你一脚踢开他，然后再一剑刺下。毕竟你可不想包裹上沾染了血迹。 |  你和手下杀光所有盗贼后，便分头在强盗营地里寻找包裹。%randombrother%很快发现了，东西被一个死掉的蠢货抓着。雇佣兵笨拙地想松开尸体的手，但沮丧地发现，只能一刀砍下那王八羔子的手臂。你取回了包裹，在前行路上，你握得更紧了。 |  你盯着窃贼尸体，沉思着是否将这状况告诉%employer%。包裹似乎完好无损。虽然有些血渍和骨头，但是擦擦就行了。 |  虽然包裹有些磨损了，但小事一桩而已。好吧，上面满是血，而且还有一根粉碎的窃贼手指。除了这些，其他一切都很完美无缺。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "放回原处。",
					function getResult()
					{
						this.Flags.set("IsThieves", false);
						this.Flags.set("IsStolenByThieves", false);
						this.Contract.setState("Running");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "EnragingMessage1",
			Title = "在%objective%",
			Text = "{墓地模糊不清，不知是迷雾还是尸体散发的瘴气。等等…亡灵！准备迎战！ |  你发现一座墓碑下有个土堆。泥土如面包屑一般指向远方。没有铲子…空无一人…你一路追踪，遇到了一帮哀嚎的亡灵…饥肠辘辘地盯着你… |  一个人徘徊在墓碑深处。身影摇曳，似乎要倒下了。%randombrother%来到你身边，摇摇头。%SPEECH_ON%长官，那并非活人。那是行进中的亡灵。%SPEECH_OFF%他话刚说完，远方的陌生人就出现了，光照下，你发现他一半脸都没了。 |  你发现众多坟墓都是空的。不仅如此，而且还是从下方挖空的。这可不像是盗墓贼的杰作…}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "EvilArtifact1",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_55.png[/img]{行进路上，你发现还有东西也有动静：货物。盖子跳动着，而且周围散发着奇怪的光芒。%randombrother%走上前来，看了看货物，又看了看你。%SPEECH_ON%长官，咱们要打开看看吗？或许交给我，我扔进附近的水塘里，看起来很不对劲啊。%SPEECH_OFF%你捅了那人一下，问他是否害怕。 |  沿路前进，你听到%employer%交给你的包裹中传来了低沉的嗡嗡声。%randombrother%站在旁边，用一根棍子戳了戳它。你一个耳光抽开他。他解释道。%SPEECH_ON%长官，咱们运送的货物有点儿不对劲…%SPEECH_OFF%你仔细观察了下。盖子边缘溢出了浅淡的颜色。就你所知，火焰是不可能的，而且黑暗中能发光的只有月亮和星星。你担心好奇心逐渐会占了上风… |  货物就在你身旁，晃动着就要倾斜了。突然之间，它发出嗡嗡声，而且你对天发誓，刹那之间绝对看到了盖子向上漂浮了。%randombrother%瞧了一眼。%SPEECH_ON%长官，你没事吧？%SPEECH_OFF%他话刚说完，盖子就爆炸般地飞出，纷乱的颜色，迷雾，灰烬尽皆而出，炽烈的热和刺骨的冷。你拔出武器防御，当你透过肘部缝隙看向包裹时，它仍完好无损，而且盖子又合上了。你与雇佣兵交换了下眼神，然后两人都盯着货物。这送货任务非比寻常… |  附近传来低沉的嗡嗡声。你以为附近出现了蜜蜂，于是本能地闪避，却发现声音是从%employer%的货物传来的。容器上的盖子左右晃动，插销和钉子动荡不安。%randombrother%似乎有点吓到了。%SPEECH_ON%咱们把这玩意就扔这儿吧。这玩意有点邪门。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我不想知道发生了什么",
					function getResult()
					{
						return "EvilArtifact2";
					}

				},
				{
					Text = "扔下那玩意。",
					function getResult()
					{
						this.Flags.set("IsEvilArtifact", false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "EvilArtifact2",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_73.png[/img]{你终究没克制好奇心。你慢慢撬着盖子。%randombrother%后退抗议道。%SPEECH_ON%长官，我觉得不该去碰那玩意。说真的，你倒是看看啊。%SPEECH_OFF%你无视他的话，并告诉他没事的，然后你揭开盖子。\n\n 并不安全。爆炸轰得你四肢朝天。你周身尽是可怕的形状和尖叫声。随着幽影冲入地面，人们本能地拿出武器。地面出现土堆，并且伴随着哀嚎声。你看到一双双手如出芽般，将衰败的尸体从土中拉了出来。亡者再生，并且数量还不少！ |  你无视所有人的判断，撬开了货物。起初，一切正常。只是个空盒子。%randombrother%紧张地大小。%SPEECH_ON%好吧…看来就这样了。%SPEECH_OFF%但是不可能就这样吧？为什么%employer%会让你护送个空盒子，除非— \n\n 你意识到铃声慢慢从你耳边消散。你转身看到盒子完全蒸发了，空留下一堆雪花般的木屑。%randombrother%冲过来，拖着你来到战团其他人身边他们手挥舞着，嘴巴动着，大喊道…\n\n 一群装备精良的人…挡住了去路？当你看清楚后，你意识到他们举着破旧的木盾，上面涂着奇怪的灵魂仪式，而且盔甲的形状和尺寸你见所未见，就像是青涩的铁匠打造的。他们就像古人…先民。 |  当你打开盖子时，%randombrother%摇着头。你费了些力气撬开了，然后快速后退以应对最糟糕的情况。但是什么都没发生。连一丝儿声音都没有。你拿起剑，敲了敲空盒子周围，寻找秘密隔间什么的。%randombrother%大笑。%SPEECH_ON%嘿，我们护送的是一盒空气。之前我还觉得这傻逼玩意太重了！%SPEECH_OFF%就在那时，盒子略微升入空中，旋转着，然后自己砸向地面。轻松且没有一丝噪音地就碎了，每片木头躺在草地上，就像古代的石雕工艺。一个灵魂体飘出，诡异地笑着。%SPEECH_ON%噢，人类，见到你实在太高兴了。%SPEECH_OFF%声音如刺骨冰锥，让你脊背发凉。你看着幽灵冲向天空，然后如长矛般刺入地面。不消一会儿，地面碎裂，尸体从中爬出。 |  盒子似乎有魔力一般。你果决地打开货物，然后瞧了瞧。未见其物，先闻其味—一股恶臭几乎让人要失去了感官能力。一人呕吐了。其他人开始作呕。当你再次看向盒子时，散发着丝丝黑烟，如触须般伸向远方，似乎摸索着地面。当似乎找到需要的东西时，便一股脑儿潜入地下，接着亡灵便像看到饵的鱼一般出现了。 |  你无视了数人的担忧，打开了包裹。其中有一堆人头，眼睛睁着，散发着光芒。他们下颌裂开，上下合动，发出咯咯的笑声。你快速关上盒子，但是一股力量意欲冲开。你奋力关上，%randombrother%和其它数人也来帮忙，但是那感觉就像与风暴无声的飓风对抗着。\n\n过了一会儿，你们所有人都开始往后退去。那群黑色的灵魂挂起一阵阴风将箱子的盖子吹向了天空。他们地面上快速的移动着，然后突然停了下来，面对着%companyname%。之后你就看到了恐怖的一幕：那群幽灵般的存在逐渐化为实体，雾状的灵魂凝结成了结实的骨头。而且，当然了，他们身上全副武装，你甚至可以听见他们的下颚咯咯作响，似乎在嘲笑你们。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "EvilArtifact";
						p.Music = this.Const.Music.UndeadTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Center;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;

						if (this.Flags.get("IsCursedCrystalSkull"))
						{
							this.World.Tags.set("IsCursedCrystalSkull", true);
							p.Loot = [
								"scripts/items/accessory/legendary/cursed_crystal_skull"
							];
						}

						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.UndeadArmy, 120 * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getID());
						this.World.Contracts.startScriptedCombat(p, false, false, false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "EvilArtifact3",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_55.png[/img]{战斗结束后，你立刻冲向了那件器具，发现它正漂浮在空中。%randombrother%跑到你的身边。%SPEECH_ON%快毁了它，大人，趁它还没造成更多的麻烦前！%SPEECH_OFF%  |  战斗后，除了你的部下，还有一个东西存活了下来 - 那件器具，还有它里面残存的力量，无意识地漂浮在它原来的位置上。那个器具化作球体旋转着，周边环绕着某种能量，偶尔会咯咯作响，有时还会发出一阵你从未听见过的笑声。%randombrother%朝那东西点了点头。%SPEECH_ON%快毁了它，大人。快点结束这场灾难吧。%SPEECH_OFF%  |  这个世界不应存在这样的力量！那件器具化作了球体形状，跟你的拳头差不多大小。它飘离了地面，嗡嗡作响，仿佛低唱着另一个世界的歌谣。那东西似乎在等你，像条正在等待主人的小狗似的。%SPEECH_ON%大人。%SPEECH_OFF%%randombrother%拉住了你的肩膀。%SPEECH_ON%大人，拜托，快毁了它。别再带着它了！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们必须毁了它。",
					function getResult()
					{
						return "EvilArtifact4";
					}

				},
				{
					Text = "我们已经收了钱，所以必须完成这趟护送。",
					function getResult()
					{
						this.Flags.set("IsEvilArtifact", false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "EvilArtifact4",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_55.png[/img]{你拔出了剑，站在了那件器具前面，然后慢慢举了武器。%SPEECH_ON%住手！%SPEECH_OFF%你转过头去，看见%randombrother%和其他人怒视着你。黑暗包围了他们，整个世界似乎都离你远去。他们的眼睛变得血红，口中清晰地怒吼着。%SPEECH_ON%下地狱吧！下地狱吧！一旦毁了它你就得下地狱！万劫不复！万劫不复！%SPEECH_OFF%尖叫声中，你转身用剑劈开了那件器具。它瞬间化作两半，同时斑斓的色彩重新回到了你的世界当中。这时你才发现自己的前额布满了汗水，依靠武器才勉强地站着。你回头看向战团的兄弟们，他们也正看着你。%SPEECH_ON%大人，你没事吧？%SPEECH_OFF%你收起剑点了点头，但你清楚，你一生中从未经历过如此另人心悸的事情。%employer%不会高兴的，而且会极度地愤怒！ |  就在摧毁这个器具的念头闪过你的脑海时，你听到了一阵恐怖的尖叫声。那是女人和孩童尖锐的哭喊声，他们撕心裂肺的恐怖叫声仿佛是从地狱中传来的。他们用各种语言向你大叫着，但你明白那些话语只代表一个意思：住手。\n\n 你拔出了武器，回头顺势一劈。那件器具发出了嗡嗡声，颤抖了起来。里面散发出阵阵烟雾，忽然一阵炽烈的热浪向你席卷而来。住手。\n\n 你抓紧了剑柄。\n\n Davkul。Yekh\'la。Imshudda。Pezrant。住手。\n\n你咽了口气，仔细地瞄准着。\n\n 住手。RAVWEET。URRLA。OSHARO。EBBURRO。MEHT\'JAKA。--住手。住手。住手。住--\n\n 你将手中的剑劈下，话语声瞬间消失了，那件器具掉落在了地面上。你也无力地跪倒在地上，身后的战团弟兄们立刻上来扶起了你。%employer%不会高兴的，但你明白自己让整个世界避免了一场恐怖的灾难。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "结束了。",
					function getResult()
					{
						this.Flags.set("IsEvilArtifact", false);
						this.World.FactionManager.getFaction(this.Contract.m.Destination.getFactions()[0]).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to deliver cargo");
						local recipientFaction = this.Contract.m.Destination.getFactionOfType(this.Const.FactionType.Settlement);

						if (recipientFaction != null)
						{
							recipientFaction.addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail * 0.5);
						}

						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "EvilArtifact5",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_55.png[/img]{你摇了摇头，拿出了另一只箱子，小心翼翼地将那漂浮着的器具放了进去，然后盖上了盖子。%employer%付给了你很大一笔钱，你也很想要这笔钱。但不知怎的，你不确定这样的选择是出自于自己的内心，还是被那件遗物奇怪的低语声影响的结果。 |  你取来了一只木箱，抬起来把那件器具装了进去，然后立刻封上了箱子。有些雇佣兵摇了摇头。这样做或许不是最好的选择，但不知怎的，你感觉自己必须去完成这项任务。 |  你的直觉告诉你应该去摧毁那件遗物，但你并没有那么做。你拿来了一只木箱，将那件器具装了进去，然后把箱子封了起来。你完全不知道自己为什么要这么做，但你感觉自己的体内重新充满了力量，能够再次踏上旅途。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们得继续上路了。",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在%objective%",
			Text = "[img]gfx/ui/events/event_20.png[/img]{你进入城中时%recipient%正在等着你。他急忙把货物从你手中接了过去。%SPEECH_ON%哦，啊，我真没想到你能安全到达这里。%SPEECH_OFF%他那肮脏的手指愉悦地敲打着装着货物的箱子。他转过身去跟他的手下说了些什么。然后他们走向前来并交给你一大袋克朗。 |  终于，你成功了。%recipient%正站在道路中间，双手紧捂真自己的腹部，脸上浮现出一抹假笑。%SPEECH_ON%佣兵，我本来还不相信你能做得到呢。%SPEECH_OFF%你搬出货物交给了他。%SPEECH_ON%哦是吗，你为什么要那么说？%SPEECH_OFF%那个男人那走了箱子，将其交给了一位穿着长袍的家伙，然后那个长袍男就抱着箱子匆匆离开了。%recipient%大笑着交给你一袋克朗。%SPEECH_ON%最近这路可不好走呐，不是吗？%SPEECH_OFF%你知道他只是在瞎扯，好把你的注意力从货物上转移开。管他呢，你拿到了报酬，这就足够了。 |  %recipient%对你的到来表示了欢迎，而他的手下很快就将货物拿了过去。他拍了拍你的肩。%SPEECH_ON%我想你路上还算是顺利的吧？%SPEECH_OFF%你跟他大致说了下路上的情况，然后问起了你的报酬。%SPEECH_ON%哎呀，佣兵到底是佣兵啊。%randomname%！把他的报酬拿来！%SPEECH_OFF%%recipient%的一位手下走了过来，交给你一只装满克朗的小箱子。 |  你四处寻找了一会儿后，一个男人走来过来，问你在找谁。当你说出%recipient%的名字后，他指了指不远处的马场，那里有个男人正牵着一匹看起来很昂贵的马。\n\n 你走向了那个正在喂马的男人，那人看见了你，并问那件货物是否是%employer%送来的。你点了点头。%SPEECH_ON%你把它放在脚边就行。我会去拿的。%SPEECH_OFF%你并没那样做，而是问起你的报酬。那人叹了口气，很快招来了一位手下。%SPEECH_ON%把这位佣兵的报酬拿来。%SPEECH_OFF%最后，你拿到了报酬，然后留下箱子离开了。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "一笔数量可观的克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Delivered some cargo");
						local recipientFaction = this.Contract.m.Destination.getFactionOfType(this.Const.FactionType.Settlement);

						if (recipientFaction != null)
						{
							recipientFaction.addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess * 0.5, "Delivered some cargo");
						}

						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Tactical.getEntityByID(this.Contract.m.RecipientID).getImagePath());
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
				});
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		local days = this.getDaysRequiredToTravel(this.m.Flags.get("Distance"), this.Const.World.MovementSettings.Speed, true);
		_vars.push([
			"objective",
			this.m.Destination == null  ||  this.m.Destination.isNull() ? "" : this.m.Destination.getName()
		]);
		_vars.push([
			"recipient",
			this.m.Flags.get("RecipientName")
		]);
		_vars.push([
			"mercband",
			this.Const.Strings.MercenaryCompanyNames[this.Math.rand(0, this.Const.Strings.MercenaryCompanyNames.len() - 1)]
		]);
		_vars.push([
			"direction",
			this.m.Destination == null  ||  this.m.Destination.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Destination.getTile())]
		]);
		_vars.push([
			"days",
			days <= 1 ? "1 天" : days + " 天"
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Destination != null && !this.m.Destination.isNull())
			{
				this.m.Destination.getSprite("selection").Visible = false;
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (this.m.Destination == null  ||  this.m.Destination.isNull()  ||  !this.m.Destination.isAlive()  ||  !this.m.Destination.isAlliedWithPlayer())
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

		if (this.m.Location != null && !this.m.Location.isNull())
		{
			_out.writeU32(this.m.Location.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		_out.writeU32(this.m.RecipientID);
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local destination = _in.readU32();

		if (destination != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}

		local location = _in.readU32();

		if (location != 0)
		{
			this.m.Location = this.WeakTableRef(this.World.getEntityByID(location));
		}

		this.m.RecipientID = _in.readU32();

		if (!this.m.Flags.has("Distance"))
		{
			this.m.Flags.set("Distance", 0);
		}

		this.contract.onDeserialize(_in);
	}

});

