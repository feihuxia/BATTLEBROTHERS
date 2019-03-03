this.cripple_vs_injury_event <- this.inherit("scripts/events/event", {
	m = {
		Cripple = null,
		Injured = null
	},
	function create()
	{
		this.m.ID = "event.cripple_vs_injury";
		this.m.Title = "营地…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]最近的战斗给%injured%留下了可怕的永久性损伤。他闷闷不乐地坐在篝火旁，跛子%cripple%坐到了他身边。%SPEECH_ON%所以你就坐在这里，因为一些无关紧要的事情垂头丧气。看着我。看着我！看看我在哪儿！我已经失去了能归还的事物，但我有一直想着它吗？不。我往前走了。我加入了%companyname%。因此，伤害不存在了，变成了过去。这里……%SPEECH_OFF%跛子指指脑袋一侧。%SPEECH_ON%这里的东西能够更新。这里能让你思考，对，它发生过了，但我还是我，我还在这里。如果世界想要我死，就要拿走我的一切，因为我是不到最后不放弃的人！%SPEECH_OFF%%injured%点点头，心情好像好了很多。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那家伙精神真好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cripple.getImagePath());
				this.Characters.push(_event.m.Injured.getImagePath());
				_event.m.Injured.improveMood(1.0, "Spirits lifted by " + _event.m.Cripple.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Injured.getMoodState()],
					text = _event.m.Injured.getName() + this.Const.MoodStateEvent[_event.m.Injured.getMoodState()]
				});
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

		local cripple_candidates = [];
		local injured_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.cripple")
			{
				cripple_candidates.push(bro);
			}
			else if (bro.getSkills().hasSkillOfType(this.Const.SkillType.PermanentInjury))
			{
				foreach( n in bro.getMoodChanges() )
				{
					if (n.Text == "Suffered a permanent injury")
					{
						injured_candidates.push(bro);
						break;
					}
				}
			}
		}

		if (cripple_candidates.len() == 0 || injured_candidates.len() == 0)
		{
			return;
		}

		this.m.Cripple = cripple_candidates[this.Math.rand(0, cripple_candidates.len() - 1)];
		this.m.Injured = injured_candidates[this.Math.rand(0, injured_candidates.len() - 1)];
		this.m.Score = (cripple_candidates.len() + injured_candidates.len()) * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"cripple",
			this.m.Cripple.getNameOnly()
		]);
		_vars.push([
			"injured",
			this.m.Injured.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Cripple = null;
		this.m.Injured = null;
	}

});

