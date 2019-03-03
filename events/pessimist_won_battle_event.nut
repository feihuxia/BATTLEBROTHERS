this.pessimist_won_battle_event <- this.inherit("scripts/events/event", {
	m = {
		Pessimist = null
	},
	function create()
	{
		this.m.ID = "event.pessimist_won_battle";
		this.m.Title = "路上…";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_64.png[/img]即便在心情沮丧的时候，%pessimist%也会四处闲逛，用他那悲观的言论，将胜利说得一文不值。他摆出一个轻蔑的手势。%SPEECH_ON%我们尝到了胜利的滋味，那又如何？我们的胜利，就意味着别人的战败。所以，日后别人的胜利很有可能意味着我们的战败，你们明白吗？我们可不能被胜利的光辉冲昏了头脑，不然以后遭人暗算，连哭都来不及。%SPEECH_OFF%一些佣兵让他不要再说这么刻薄的话了，可是为时已晚，他的话已经让一些人陷入低落之中。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "悲观主义者的糟糕之处在于，他们说的话在大多情况下都是正确的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Pessimist.getImagePath());
				_event.m.Pessimist.worsenMood(0.5, "Is pessimistic despite a recent victory");

				if (_event.m.Pessimist.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Pessimist.getMoodState()],
						text = _event.m.Pessimist.getName() + this.Const.MoodStateEvent[_event.m.Pessimist.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Pessimist.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 50 && !bro.getSkills().hasSkill("trait.optimist"))
					{
						bro.worsenMood(0.4, "Tempered by " + _event.m.Pessimist.getName() + "\'s pessimism");

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
		if (this.World.Statistics.get().LastCombatResult != 1)
		{
			return;
		}

		if (this.Time.getVirtualTimeF() - this.World.Events.getLastBattleTime() > 20.0)
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
			if (bro.getSkills().hasSkill("trait.pessimist") && !bro.getSkills().hasSkill("trait.dumb") && bro.getLifetimeStats().Battles >= 1)
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() < 1)
		{
			return;
		}

		this.m.Pessimist = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 50;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"pessimist",
			this.m.Pessimist.getName()
		]);
	}

	function onClear()
	{
		this.m.Pessimist = null;
	}

});

