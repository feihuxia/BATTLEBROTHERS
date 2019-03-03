this.civilwar_town_conquered_event <- this.inherit("scripts/events/event", {
	m = {
		News = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_town_conquered";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 1.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_45.png[/img]{有消息称%conqueror%已经从%defeated%手中夺取了%city%！|信使们说%conqueror%已经是%city%的新统治者了，在经历了一场大战之后从%defeated%手中夺回来的。|重新规划地图！难民，信使，商人们都在说%city%已经属于%conqueror%了！}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "边境线已经改变。",
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
	}

	function onUpdateScore()
	{
		if (!this.World.State.getPlayer().getTile().HasRoad)
		{
			return;
		}

		if (this.World.Statistics.hasNews("crisis_civilwar_town_conquered"))
		{
			this.m.Score = 2000;
		}
	}

	function onPrepare()
	{
		this.m.News = this.World.Statistics.popNews("crisis_civilwar_town_conquered");
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"conqueror",
			this.m.News.get("Conqueror")
		]);
		_vars.push([
			"defeated",
			this.m.News.get("Defeated")
		]);
		_vars.push([
			"city",
			this.m.News.get("City")
		]);
	}

	function onClear()
	{
		this.m.News = null;
	}

});

