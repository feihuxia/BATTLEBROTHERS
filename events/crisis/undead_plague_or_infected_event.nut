this.undead_plague_or_infected_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.crisis.undead_plague_or_infected";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 40.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_59.png[/img]你遇到一群农民坐在路边。男人，女人，孩子。肮脏的衣服，泥泞的靴子，皮肤上的血迹。几个形状像咬伤的伤口。队伍中最年老的人说话。%SPEECH_ON%求你了，长官，你有食物或水给我们吗？%SPEECH_OFF%他似乎看见你盯着脓包和咬痕。他摇摇头。%SPEECH_ON%哦，别介意这些。简单的狐狸狩猎发生了意外。我们只要一点点帮助就可以继续上路了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们可以分一点食物。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "C";
						}
						else
						{
							return "D";
						}
					}

				},
				{
					Text = "这不是我们的问题。",
					function getResult( _event )
					{
						return 0;
					}

				},
				{
					Text = "你只会让亡灵队伍壮大。我们最好现在就干掉你。",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_59.png[/img]你很好地控制着这些生病的人 - 指挥你的人把他们都杀了。当人们起来抵抗的时候，长者带着女人孩子逃跑。一个人迈着绿色蜕皮的腿走向你。%SPEECH_ON%你这混蛋真是个圣徒啊。希望我能死而复生。希望我的尸体杀了你们这群野蛮人。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那我会期待杀你第二次。",
					function getResult( _event )
					{
						if (this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnPartyDestroyed);
						}

						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.CivilianTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.PeasantsArmed, this.Math.rand(50, 100), this.Const.Faction.Enemy);
						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_59.png[/img]你告诉%randombrother% 拿出一些食物和补给。老人感谢你，说无论到哪里都会赞扬%companyname%。有几个男人似乎松了一口气，因为你没问他们可怕的事。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们做力所能及的事。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(3);
				local food = this.World.Assets.getFoodItems();

				for( local i = 0; i < 2; i = ++i )
				{
					local idx = this.Math.rand(0, food.len() - 1);
					local item = food[idx];
					this.List.push({
						id = 10,
						icon = "ui/items/" + item.getIcon(),
						text = "你输了" + item.getName()
					});
					this.World.Assets.getStash().remove(item);
					food.remove(idx);
				}
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_29.png[/img]你告诉%randombrother% 拿出一些食物和补给。老人感谢你，说无论到哪里都会赞扬%companyname%。你拿了一块面包，蹲在一个体弱多病的孩子旁边，他的父亲抱着他。但是当你拿出面包，孩子抬起头咬了他的父亲。健康的农民都站起来跑了。剩下的……好吧，剩下的摇摇晃晃站起来，脸色苍白，下巴松弛，眼里发着疯狂饥饿的红光。你快速命令雇佣兵摆出阵型。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好心没好报。",
					function getResult( _event )
					{
						if (this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnPartyDestroyed);
						}

						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.CivilianTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						properties.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Center;
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Peasants, this.Math.rand(10, 30), this.Const.Faction.PlayerAnimals);
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.ZombiesLight, this.Math.rand(60, 90), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getID());
						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();

		if (!playerTile.HasRoad)
		{
			return;
		}

		local food = this.World.Assets.getFoodItems();

		if (food.len() < 3)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d <= 4)
			{
				return;
			}
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

