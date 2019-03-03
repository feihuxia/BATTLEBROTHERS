this.optimist_lost_battle_event <- this.inherit("scripts/events/event", {
	m = {
		Optimist = null
	},
	function create()
	{
		this.m.ID = "event.optimist_lost_battle";
		this.m.Title = "路上…";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_88.png[/img]尽管最近吃了败仗，但%optimist%依然对%companyname%的未来十分乐观。%SPEECH_ON%朋友，时间并不总是在站着的时候流逝的。有的时候，我们爬起来也需要时间。不过，我坚信我们不会一直被人打趴在地上！这个战团还是有希望的。%SPEECH_OFF%这位乐观的佣兵不断地鼓舞着战友们，让他们打起精神迎接明天的到来。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "一个失去战意的人。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Optimist.getImagePath());
				_event.m.Optimist.improveMood(0.5, "Is optimistic despite a recent setback");

				if (_event.m.Optimist.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Optimist.getMoodState()],
						text = _event.m.Optimist.getName() + this.Const.MoodStateEvent[_event.m.Optimist.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Optimist.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 50 && !bro.getSkills().hasSkill("trait.pessimist"))
					{
						bro.improveMood(0.5, "Rallied by " + _event.m.Optimist.getName() + "\'s optimism");

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
		if (this.World.Statistics.get().LastCombatResult != 2)
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
			if (bro.getSkills().hasSkill("trait.optimist") && bro.getLifetimeStats().Battles >= 1)
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() < 1)
		{
			return;
		}

		this.m.Optimist = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 50;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"optimist",
			this.m.Optimist.getName()
		]);
	}

	function onClear()
	{
		this.m.Optimist = null;
	}

});

