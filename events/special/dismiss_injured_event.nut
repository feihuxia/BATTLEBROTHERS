this.dismiss_injured_event <- this.inherit("scripts/events/event", {
	m = {
		Fired = null
	},
	function setFired( _f )
	{
		this.m.Fired = _f;
	}

	function create()
	{
		this.m.ID = "event.dismiss_injured";
		this.m.Title = "路上…";
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_64.png[/img]%dismissed%\'s 伤口证明很多事情: 那个男人没有死， 但是在你的心中他可能不再适合战斗了。你放过他吧。虽然饶恕那个雇佣兵的生命是一个无私的举动，战团其他的人不是这么想的。他们看到的是一个你因为一个伤口放弃一个人。现在他们担心是否你会对他们做同样的事情伤害他们，就像是与一个自私的人骑着一匹瘸腿的马。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "他们会走过去的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getSkills().hasSkillOfType(this.Const.SkillType.PermanentInjury))
					{
						bro.worsenMood(1.5, "Afraid to be dismissed on account of his injury");

						if (bro.getMoodState() < this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}
					else if (this.Math.rand(1, 100) <= 33)
					{
						bro.worsenMood(this.Const.MoodChange.BrotherDismissed, "Lost confidence in the company\'s solidarity");

						if (bro.getMoodState() < this.Const.MoodState.Neutral)
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
		if (this.World.Statistics.hasNews("dismiss_injured"))
		{
			this.m.Score = 2000;
		}

		return;
	}

	function onPrepare()
	{
		local news = this.World.Statistics.popNews("dismiss_injured");
		this.m.Fired = news.get("Name");
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"dismissed",
			this.m.Fired
		]);
	}

	function onClear()
	{
		this.m.Fired = null;
	}

});

