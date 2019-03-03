this.fainthearted_is_shellshocked_event <- this.inherit("scripts/events/event", {
	m = {
		Rookie = null
	},
	function create()
	{
		this.m.ID = "event.fainthearted_is_shellshocked";
		this.m.Title = "营地…";
		this.m.Cooldown = 40.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_12.png[/img]你发现 %fainthearted% 在篝火前来来回回。他的脸上有干涸的血液他的手在发抖。有几个兄弟想要和他说话，但是没有人能够走进。看来这个懦弱的男人已经被最近的残酷战斗给吓傻了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "就让它那样吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Rookie.getImagePath());
				_event.m.Rookie.worsenMood(1.5, "Shocked by the horrors of battle");

				if (_event.m.Rookie.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Rookie.getMoodState()],
						text = _event.m.Rookie.getName() + this.Const.MoodStateEvent[_event.m.Rookie.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		local fallen = this.World.Statistics.getFallen();

		if (fallen.len() < 2)
		{
			return;
		}

		if (this.World.getTime().Days - fallen[0].Time > 1 || this.World.getTime().Days - fallen[1].Time > 1)
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
			if (bro.getLevel() <= 4 && bro.getSkills().hasSkill("trait.fainthearted") && bro.getPlaceInFormation() <= 17 && bro.getLifetimeStats().Battles >= 1)
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() < 1)
		{
			return;
		}

		this.m.Rookie = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"fainthearted",
			this.m.Rookie.getName()
		]);
	}

	function onClear()
	{
		this.m.Rookie = null;
	}

});

