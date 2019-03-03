this.minstrel_teases_deserter_event <- this.inherit("scripts/events/event", {
	m = {
		Minstrel = null,
		Deserter = null
	},
	function create()
	{
		this.m.ID = "event.minstrel_teases_deserter";
		this.m.Title = "营地…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]在劈啪作响的营火旁，吟游诗人%minstrel%站在一根树桩上。他拍了拍自己的胸脯然后指向%deserter%。%SPEECH_ON%喂，你的腿脚真是快，还没战败你就跑！逃兵啊！噢，逃兵啊！逃到荒漠中去吧！他没有勇气，也没有荣誉，更别提男子气概了！逃兵啊！%SPEECH_OFF%吟游诗人以极快的速度拍了拍手，然后坐回原处。不到一会儿，%deserter%就上来勒住了他的脖子。战团一下子乱成一团，一些人在劝架，而另一些人则笑得前俯后仰。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真是太有趣了！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Minstrel.getImagePath());
				this.Characters.push(_event.m.Deserter.getImagePath());
				_event.m.Deserter.worsenMood(2.0, "Felt humiliated in front of the company");

				if (_event.m.Deserter.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Deserter.getMoodState()],
						text = _event.m.Deserter.getName() + this.Const.MoodStateEvent[_event.m.Deserter.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates_minstrel = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.minstrel")
			{
				candidates_minstrel.push(bro);
			}
		}

		if (candidates_minstrel.len() == 0)
		{
			return;
		}

		local candidates_deserter = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.deserter")
			{
				candidates_deserter.push(bro);
			}
		}

		if (candidates_deserter.len() == 0)
		{
			return;
		}

		this.m.Minstrel = candidates_minstrel[this.Math.rand(0, candidates_minstrel.len() - 1)];
		this.m.Deserter = candidates_deserter[this.Math.rand(0, candidates_deserter.len() - 1)];
		this.m.Score = (candidates_minstrel.len() + candidates_deserter.len()) * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"minstrel",
			this.m.Minstrel.getNameOnly()
		]);
		_vars.push([
			"deserter",
			this.m.Deserter.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Minstrel = null;
		this.m.Deserter = null;
	}

});

