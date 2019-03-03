this.minstrel_regals_refugee_event <- this.inherit("scripts/events/event", {
	m = {
		Minstrel = null,
		Refugee = null
	},
	function create()
	{
		this.m.ID = "event.minstrel_regals_refugee";
		this.m.Title = "营地…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]战团成员围着营火而坐，吟游诗人%minstrel%注意到流亡者%refugee%却独自一人坐着。不消一刻，吟游诗人就起身站到一根木桩上，挥舞着自己的双臂。%SPEECH_ON%噢，%refugee%待的地方真小，环境又奇怪，还没好吃的。不过！那里的人可真大！我们团里就有来自那里的人，世界都在围绕着他旋转，他战无不胜，我们只能用言语来感谢他！用克朗来感谢他！这就是他的战团，这就是我们愿意支付的报酬。.%SPEECH_OFF%吟游诗人朝流亡者鞠了一躬，然后坐回原处。所有的%companyname%成员都起立欢呼，%refugee%的脸上也出现了少有的笑容。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Bravo!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Minstrel.getImagePath());
				this.Characters.push(_event.m.Refugee.getImagePath());
				_event.m.Refugee.improveMood(1.0, "Was regaled by " + _event.m.Minstrel.getName());

				if (_event.m.Refugee.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Refugee.getMoodState()],
						text = _event.m.Refugee.getName() + this.Const.MoodStateEvent[_event.m.Refugee.getMoodState()]
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

		local candidates_refugee = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.refugee")
			{
				candidates_refugee.push(bro);
			}
		}

		if (candidates_refugee.len() == 0)
		{
			return;
		}

		this.m.Minstrel = candidates_minstrel[this.Math.rand(0, candidates_minstrel.len() - 1)];
		this.m.Refugee = candidates_refugee[this.Math.rand(0, candidates_refugee.len() - 1)];
		this.m.Score = (candidates_minstrel.len() + candidates_refugee.len()) * 5;
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
			"refugee",
			this.m.Refugee.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Minstrel = null;
		this.m.Refugee = null;
	}

});

