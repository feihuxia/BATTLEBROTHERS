this.ambition_fulfilled_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.ambition_fulfilled";
		this.m.Title = "一个远大目标被实现了";
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [],
			function start( _event )
			{
				this.Music.setTrackList(this.Const.Music.VictoryTracks, this.Const.Music.CrossFadeTime);
				local active = this.World.Ambitions.getActiveAmbition();

				if (!active.isDone())
				{
					active.succeed();
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 75)
					{
						bro.improveMood(this.Const.MoodChange.AmbitionFulfilled, "Gained confidence in your leadership");
					}
				}

				this.Banner = "ui/banners/" + this.World.Assets.getBanner() + "s.png";
				this.Text = active.getSuccessText();
				this.Options = [
					{
						Text = active.getSuccessButtonText(),
						function getResult( _event )
						{
							this.Music.setTrackList(this.Const.Music.WorldmapTracks, this.Const.Music.CrossFadeTime, true);
							return 0;
						}

					}
				];
				this.List = active.getSuccessList();

				if (active.isGrantingRenown())
				{
					this.List.insert(0, {
						id = 10,
						icon = "ui/icons/special.png",
						text = "战团获得声望"
					});
				}

				if (active.isShowingMood())
				{
					foreach( bro in brothers )
					{
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

		});
	}

	function onUpdateScore()
	{
		return;
	}

	function onPrepareVariables( _vars )
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local lowest_hiretime = 100000000.0;
		local lowest_hiretime_bro;
		local highest_hiretime = -9000.0;
		local highest_hiretime_bro;
		local highest_bravery = 0;
		local highest_bravery_bro;
		local lowest_hitpoints = 9999;
		local lowest_hitpoints_bro;

		foreach( bro in brothers )
		{
			if (bro.getHireTime() < lowest_hiretime)
			{
				lowest_hiretime = bro.getHireTime();
				lowest_hiretime_bro = bro;
			}

			if (bro.getHireTime() > highest_hiretime)
			{
				highest_hiretime = bro.getHireTime();
				highest_hiretime_bro = bro;
			}

			if (bro.getCurrentProperties().getBravery() > highest_bravery)
			{
				highest_bravery = bro.getCurrentProperties().getBravery();
				highest_bravery_bro = bro;
			}

			if (bro.getHitpoints() < lowest_hitpoints)
			{
				lowest_hitpoints = bro.getHireTime();
				lowest_hitpoints_bro = bro;
			}
		}

		_vars.push([
			"highestexperience_brother",
			lowest_hiretime_bro.getName()
		]);
		_vars.push([
			"strongest_brother",
			lowest_hiretime_bro.getName()
		]);
		_vars.push([
			"lowestexperience_brother",
			highest_hiretime_bro.getName()
		]);
		_vars.push([
			"bravest_brother",
			highest_bravery_bro.getName()
		]);
		_vars.push([
			"lowesthp_brother",
			lowest_hitpoints_bro.getName()
		]);
		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();
		local nearest_town_distance = 999999;
		local nearest_town;

		foreach( t in towns )
		{
			local d = t.getTile().getDistanceTo(playerTile);

			if (d < nearest_town_distance)
			{
				nearest_town_distance = d;
				nearest_town = t;
			}
		}

		_vars.push([
			"currenttown",
			nearest_town.getName()
		]);
		_vars.push([
			"nearesttown",
			nearest_town.getName()
		]);
		this.World.Ambitions.getActiveAmbition().onPrepareVariables(_vars);
	}

	function onClear()
	{
	}

});

