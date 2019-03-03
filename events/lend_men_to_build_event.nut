this.lend_men_to_build_event <- this.inherit("scripts/events/event", {
	m = {
		Town = null
	},
	function create()
	{
		this.m.ID = "event.lend_men_to_build";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 45.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_79.png[/img]当你正在接近%townname%时，一个本地人朝你招手，让你停下。他站在一间似乎是磨坊的房架子边上。他似乎很愤怒，解释说他的工人今天没有出现，他必须在本地的男爵到来之前完成工作。如果他没有完成这座磨坊，男爵或许再也不会给他合同了。你的战团里确实有人以前是工人。或许他们能够帮上他？",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你的工作是建造，而我们负责杀戮。去找别人吧。",
					function getResult( _event )
					{
						return 0;
					}

				},
				{
					Text = "好吧，我能给你些人。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 50 ? "B" : "C";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_79.png[/img]你同意把%companyname%里最好的人借给他完成这项工程。那些人又回到了自己的老岗位，带上手套，来回收集资源，四处锤，四处砌砖，四处装门？不管装一扇门需要什么，他们都非常迅速地就能完成。当一切都尘埃落定之后，那个本地人满脸笑容地朝你走来。他递给你一个小挎包。%SPEECH_ON%这是你应得的，善良的先生！不止如此，你也赢得了我的说辞 — 我会随时颂扬你的仁慈的！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "大家不要过于习惯这种工作。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.FactionManager.getFaction(_event.m.Town.getFactions()[0]).addPlayerRelation(this.Const.World.Assets.RelationFavor, "You lend some men to help build a mill");
				this.World.Assets.addMoney(150);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]150[/color]克朗"
					}
				];
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					local id = bro.getBackground().getID();

					if (id == "background.daytaler" || id == "background.mason" || id == "background.lumberjack" || id == "background.miller" || id == "background.farmhand" || id == "background.gravedigger")
					{
						if (this.Math.rand(1, 100) <= 33)
						{
							local effect = this.new("scripts/skills/effects_world/exhausted_effect");
							bro.getSkills().add(effect);
							this.List.push({
								id = 10,
								icon = effect.getIcon(),
								text = bro.getName() + " is exhausted"
							});
						}

						if (this.Math.rand(1, 100) <= 50)
						{
							bro.improveMood(0.5, "Helped build a mill");

							if (bro.getMoodState() >= this.Const.MoodState.Neutral)
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
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_79.png[/img]你同意帮助这个人。不幸的是，他的计划并不怎么靠谱。在你的一位“劳工”踩上屋顶的同时，屋顶就塌了。残垣断壁瞬间将他吞没。而另一个正在钉钉子的人，脚下的木头支架裂成了两半，尖锐的木刺扎在了他的脸上。松动的砖瓦纷纷坠落，人们滑倒在湿滑的泥地上，整个工程项目陷入了一片混乱。\n\n 那个当地人一个劲地道歉，还时不时地咬着自己的指甲，思索着该如何应付男爵。突然，他打了一个响指，恍然大悟地说道他只要用克朗来补偿男爵就好。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那些克朗是属于我们的！",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "但愿你能妥善应付男爵。",
					function getResult( _event )
					{
						return "E";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_79.png[/img]就在那个男人似乎为自己的问题找到一个比较满意的解决方案时，你的一句话将他拉回了残酷的现实。%SPEECH_ON%那些克朗是属于我们的，农夫。这是我们当初说好的。%SPEECH_OFF%那个男人张了张嘴，然后摇了摇头。%SPEECH_ON%可是磨坊……还没有建完啊！%SPEECH_OFF%你耸了耸肩。%SPEECH_ON%那不是我们的问题。把钱交出来，不然我就会让你成为我们的问题。%SPEECH_OFF%在严肃地点了点头之后，那个男人服从了你的命令，并把那袋克朗交给了你。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "愿你下次能交上好运。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.FactionManager.getFaction(_event.m.Town.getFactions()[0]).addPlayerRelation(-this.Const.World.Assets.RelationFavor, "You pressed hard an important citizen to get paid for helping build a mill");
				this.World.Assets.addMoney(200);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]200[/color] 克朗"
					}
				];
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					local id = bro.getBackground().getID();

					if (id == "background.daytaler" || id == "background.mason" || id == "background.lumberjack" || id == "background.miller" || id == "background.farmhand" || id == "background.gravedigger")
					{
						if (this.Math.rand(1, 100) <= 33)
						{
							local effect = this.new("scripts/skills/effects_world/exhausted_effect");
							bro.getSkills().add(effect);
							this.List.push({
								id = 10,
								icon = effect.getIcon(),
								text = bro.getName() + " is exhausted"
							});
						}

						if (this.Math.rand(1, 100) <= 50)
						{
							bro.improveMood(0.5, "Helped build a mill");

							if (bro.getMoodState() >= this.Const.MoodState.Neutral)
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
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_79.png[/img]有那么一瞬间，你眼前浮现出了你持剑追逐着一个斜眼男人的场面。尽管那样会让他认识到世界的残酷，但这次你决定放他一马。不过那些被卷入这场灾难的劳工们并不怎么开心。但愿这次的教训能让他们学到点东西。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "祝成功。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.FactionManager.getFaction(_event.m.Town.getFactions()[0]).addPlayerRelation(this.Const.World.Assets.RelationFavor, "You lend some men to help build a mill");
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					local id = bro.getBackground().getID();

					if (id == "background.daytaler" || id == "background.mason" || id == "background.lumberjack" || id == "background.miller" || id == "background.farmhand" || id == "background.gravedigger")
					{
						if (this.Math.rand(1, 100) <= 33)
						{
							local effect = this.new("scripts/skills/effects_world/exhausted_effect");
							bro.getSkills().add(effect);
							this.List.push({
								id = 10,
								icon = effect.getIcon(),
								text = bro.getName() + " is exhausted"
							});
						}

						if (this.Math.rand(1, 100) <= 33)
						{
							bro.worsenMood(1.0, "Helped build a mill without getting paid");

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
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		if (this.World.Assets.getMoney() > 3000)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.isMilitary() || t.getSize() > 2)
			{
				continue;
			}

			if (t.getTile().getDistanceTo(playerTile) <= 3 && t.isAlliedWithPlayer())
			{
				nearTown = true;
				town = t;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			local id = bro.getBackground().getID();

			if (id == "background.daytaler" || id == "background.mason" || id == "background.lumberjack" || id == "background.miller" || id == "background.farmhand" || id == "background.gravedigger")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() < 2)
		{
			return;
		}

		this.m.Town = town;
		this.m.Score = 25;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.Town = null;
	}

});

