this.dead_lumberjack_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.dead_lumberjack";
		this.m.Title = "路上…";
		this.m.Cooldown = 120.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img]森林真的是许多尸体和好奇者的家园， 即使不是最好奇的。所以当你发现一个死去的伐木工，唯一能引起你兴趣的事情是那旁边死去的惧狼。%randombrother% 看到战场上来去的脚印还有斧头嵌入到树干里面。他吐了口唾沫并且点头。%SPEECH_ON%可怜的家伙们。看来有一些惧狼偷袭了他们。%SPEECH_OFF%你让人们收集一下能够恢复的东西然后就走了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "安息吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item;

				if (this.Math.rand(1, 100) <= 50)
				{
					item = this.new("scripts/items/weapons/hand_axe");
				}
				else
				{
					item = this.new("scripts/items/weapons/woodcutters_axe");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/misc/werewolf_pelt_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();
		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d <= 7)
			{
				nearTown = true;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		this.m.Score = 5;
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

