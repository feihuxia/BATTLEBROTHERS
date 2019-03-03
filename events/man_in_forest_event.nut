this.man_in_forest_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.man_in_forest";
		this.m.Title = "路上…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_76.png[/img]当你在树林间闲逛的时候，突然有一个人从树丛中蹿出。他那已被汗水浸透的头发上挂满了枝丫。在看到你之后，他连连后退几步。%SPEECH_ON%求你了，不要啊。%SPEECH_OFF%你举起手让他冷静下来，并询问到底发生了什么。这位陌生人后退了一步。%SPEECH_ON%求你了，不要啊！%SPEECH_OFF%他转身跑开，沿原路折了回去。%randombrother%赶到了你的身边。%SPEECH_ON%我们要不要去追踪他？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "跟着他，快点！",
					function getResult( _event )
					{
						local r = this.Math.rand(1, 100);

						if (r <= 45)
						{
							return "B";
						}
						else if (r <= 90)
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
					Text = "他跟我们没有关联。让他走吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_50.png[/img]你跟着那个人进入了丛林。他那占满泥泞的脚印并不难辨认，到处都是他逃跑时留下的痕迹。突然之间，这些痕迹中断了。这个人逃进了一处开阔地，然后他的足迹一下子就消失了。你听到上方传来一阵口哨声。抬头望去，你看到一个人正坐在树枝上。他挥了挥手。%SPEECH_ON%你好啊，陌生人。%SPEECH_OFF%他朝空地扫了一眼。那里出现了一群人，他们都全副武装。树上的那个人哼了一声。%SPEECH_ON%再见，陌生人。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult( _event )
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.BanditTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.BanditDefenders, this.Math.rand(90, 110) * _event.getReputationToDifficultyLightMult(), this.Const.Faction.Enemy);
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
			Text = "[img]gfx/ui/events/event_25.png[/img]那个人逃跑时显得十分惊慌，到处都留下了他的足迹。像他这样惊恐的人并不难追踪，可惜的是，他已经不再会感到害怕了，因为你已经找到了他内脏被掏空的尸体。\n\n附近的树丛中传来微弱的吼声。你朝声音的位置看去，隐约看到一只黑色、毛茸茸的生物从树后走出。你立即高呼，让大家准备战斗。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult( _event )
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.BeastsTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Direwolves, this.Math.rand(90, 110) * _event.getReputationToDifficultyLightMult(), this.Const.Faction.Enemy);
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
			ID = "D",
			Text = "[img]gfx/ui/events/event_25.png[/img]没花多少力气，你就找到了这个惊恐的男人。你看到他正蜷缩在一棵树下。他将什么东西紧紧抱在胸前，就好像在冰冷的夜晚怀抱暖炉取暖一般。然而，那个人已经死了。你掰开他的手，并取得了那个东西。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这是什么？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/weapons/named/named_dagger");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.SnowyForest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		this.m.Score = 7;
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

