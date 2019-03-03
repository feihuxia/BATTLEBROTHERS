this.miner_atop_world_event <- this.inherit("scripts/events/event", {
	m = {
		Miner = null
	},
	function create()
	{
		this.m.ID = "event.miner_atop_world";
		this.m.Title = "路上…";
		this.m.Cooldown = 80.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_42.png[/img]战团挺近了山峦之中，那里被%randombrother%称作是“国之双峰’。云雾就在人们的眼前穿行着，空气也十分稀薄，让人感觉是在用草管呼吸一样。脚下的积雪在吱咯作响，冷冽的寒风似乎能将人的眼球冻成冰块。除了要穿越一些陡峭的悬崖和危险的裂口，矿工%miner%似乎对现在的状况感到很乐观。%SPEECH_ON%这就像是我们来到了世界之巅一样！这景象真是太壮丽了！%SPEECH_OFF%他显得十分兴奋，以至于没有意识到他的呼吸已经跟不上了。多年来不见天日的矿工生涯，让他对眼前的景象感到无比赞叹。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "呃，在这种情况下，有人能保持乐观也是不错。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Miner.getImagePath());
				_event.m.Miner.improveMood(2.0, "Enjoyed the view from atop a mountain");

				if (_event.m.Miner.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Miner.getMoodState()],
						text = _event.m.Miner.getName() + this.Const.MoodStateEvent[_event.m.Miner.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Mountains)
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
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
			if (bro.getLevel() <= 3 && bro.getBackground().getID() == "background.miner")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Miner = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 25;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"miner",
			this.m.Miner.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Miner = null;
	}

});

