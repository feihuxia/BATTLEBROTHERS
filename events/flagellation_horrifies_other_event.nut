this.flagellation_horrifies_other_event <- this.inherit("scripts/events/event", {
	m = {
		Flagellant = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.flagellation_horrifies_other";
		this.m.Title = "营地…";
		this.m.Cooldown = 45.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_38.png[/img]肉被分离。身体的一部分都认不出是他了。空气中弥漫着血液的铜味。当你被一个兄弟呼唤的时候你就发现到了这些事情。\n\n %flagellant%苦修者弯腰待在一个树桩上，他的整个身体都一动不动，只有手臂不断地用带有玻璃和倒刺的皮鞭鞭笞着自己的后背。一个响声让你注意到%weakbro%，他正蹲在高高的草丛中大便。%flagellant%感觉到自己打扰到了其他人，笑了一下，丝毫没有因为自己恐怖的鞭打而受到影响。%SPEECH_ON%不要害怕死神，%weakbro%，我会为拯救你的灵魂而留更多的血的。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "{一个奇怪的习俗。 | 这肯定不健康。}",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Flagellant.getImagePath());
				this.Characters.push(_event.m.OtherGuy.getImagePath());
				_event.m.OtherGuy.worsenMood(1.0, "Horrified by " + _event.m.Flagellant.getName() + "\'s flagellation");

				if (_event.m.OtherGuy.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.OtherGuy.getMoodState()],
						text = _event.m.OtherGuy.getName() + this.Const.MoodStateEvent[_event.m.OtherGuy.getMoodState()]
					});
				}

				_event.m.Flagellant.improveMood(1.0, "Satisfied with his flagellation");

				if (_event.m.Flagellant.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Flagellant.getMoodState()],
						text = _event.m.Flagellant.getName() + this.Const.MoodStateEvent[_event.m.Flagellant.getMoodState()]
					});
				}

				if (this.Math.rand(1, 100) <= 50)
				{
					local injury = _event.m.Flagellant.addInjury(this.Const.Injury.Flagellation);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Flagellant.getName() + " suffers " + injury.getNameOnly()
					});
				}
				else
				{
					_event.m.Flagellant.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Flagellant.getName() + " suffers light wounds"
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidate_flagellant = [];

		foreach( bro in brothers )
		{
			if ((bro.getBackground().getID() == "background.flagellant" || bro.getBackground().getID() == "background.monk_turned_flagellant") && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				candidate_flagellant.push(bro);
			}
		}

		if (candidate_flagellant.len() == 0)
		{
			return;
		}

		local candidate_other = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() != "background.flagellant" && bro.getBackground().getID() != "background.monk_turned_flagellant" && (bro.getBackground().isOffendedByViolence() || bro.getSkills().hasSkill("trait.fainthearted")))
			{
				candidate_other.push(bro);
			}
		}

		if (candidate_other.len() == 0)
		{
			return;
		}

		this.m.Flagellant = candidate_flagellant[this.Math.rand(0, candidate_flagellant.len() - 1)];
		this.m.OtherGuy = candidate_other[this.Math.rand(0, candidate_other.len() - 1)];
		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"flagellant",
			this.m.Flagellant.getNameOnly()
		]);
		_vars.push([
			"weakbro",
			this.m.OtherGuy.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Flagellant = null;
		this.m.OtherGuy = null;
	}

});

