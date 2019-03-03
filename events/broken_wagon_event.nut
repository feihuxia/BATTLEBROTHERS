this.broken_wagon_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.broken_wagon";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "%image%你在芦苇丛中找到了一辆废弃的马车。%randombrother%过去看了看，大声说道，%SPEECH_ON%完全坏了，不过应该可以捞点东西上来。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "还不错。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local amount = this.Math.rand(5, 15);
				this.World.Assets.addArmorParts(amount);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_supplies.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + amount + "[/color] 工具和补给。"
				});
			}

		});
	}

	function onUpdateScore()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		this.m.Score = 9;
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

