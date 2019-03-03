this.dead_merchant_forest_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.dead_merchant_forest";
		this.m.Title = "路上…";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img]能通过森林的时候，你看到一个树枝上摇摆的尸体。他看起来在那里已经很久了苍蝇们似乎都已经吃饱了。%randombrother% 注意到有一些锋利的皮鞋在尸体的脚上。%SPEECH_ON%在我看来像是一个商人，先生。%SPEECH_OFF%你很同意并且把他放了下来。仔细检查之后，发现他的眼睛被挖了出来胸部有纹身。既然你发现在尸体上有一些克朗， 这像是那些野人被外面来的人吓到了所做出的事情。",
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
				local money = this.Math.rand(30, 150);
				this.World.Assets.addMoney(money);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] 克朗"
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

		if (!currentTile.HasRoad)
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();
		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d < 10)
			{
				nearTown = true;
				break;
			}
		}

		if (nearTown)
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

