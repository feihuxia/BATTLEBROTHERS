this.forestlover_event <- this.inherit("scripts/events/event", {
	m = {
		Forestlover = null
	},
	function create()
	{
		this.m.ID = "event.forestlover";
		this.m.Title = "路上…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img] {%forestlover%看着森林林冠，手漫不经心地在光束中穿梭。他看向你。%SPEECH_ON%我小时候经常在这些森林里玩。%SPEECH_OFF%你点点头，然后问道。%SPEECH_ON%我还以为你是在%randomtown%外面生的呢？%SPEECH_OFF%%forestlover%放下手，眼睛盯着地面。%SPEECH_ON%是的，没错。那么，我们该走了，对吗？%SPEECH_OFF%在你开口之前，这个红脸男继续行进了。| 你发现%forestlover%最近的气色好多了。原来，这些森林对他来说很熟悉，这些绿色让他因为温暖的怀旧之情而容光焕发。| 尽管你经历过很多森林，这个森林的绿色还是让你感到印象深刻。难怪%forestlover%很高兴来到这个地方。| 枝叶繁茂，躯干庞大的树木高高地挺立在你面前。%forestlover%好像对此非常着迷。你发现他最近一直都在微笑，好像回到森林就是回到过去的美好时光里一样。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真为他高兴。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Forestlover.getImagePath());
				_event.m.Forestlover.improveMood(1.0, "Enjoyed being in a forest");

				if (_event.m.Forestlover.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Forestlover.getMoodState()],
						text = _event.m.Forestlover.getName() + this.Const.MoodStateEvent[_event.m.Forestlover.getMoodState()]
					});
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

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.hunter" || bro.getBackground().getID() == "background.poacher" || bro.getBackground().getID() == "background.lumberjack")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() > 0)
		{
			this.m.Forestlover = candidates[this.Math.rand(0, candidates.len() - 1)];
			this.m.Score = candidates.len() * 10;
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"forestlover",
			this.m.Forestlover.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Forestlover = null;
	}

});

