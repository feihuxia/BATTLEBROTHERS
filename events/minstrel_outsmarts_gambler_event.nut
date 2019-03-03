this.minstrel_outsmarts_gambler_event <- this.inherit("scripts/events/event", {
	m = {
		Minstrel = null,
		Gambler = null
	},
	function create()
	{
		this.m.ID = "event.minstrel_outsmarts_gambler";
		this.m.Title = "营地…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]%gambler%这个人喜欢赌博。他在营地中寻找愿意和他玩掷马蹄铁游戏的人，当然，这是要下注的。看来我们狡猾的吟游诗人，%minstrel%，愿意和他玩上一局。他自称是这个游戏的高手，而我们的赌徒认为自己才是最棒的。 \n\n 这两个人比拼掷马蹄铁直到手臂酸麻、太阳落山。但双方都没能获胜，因为他们一直处于平局状态。在经历了又一轮无果的比赛后，%minstrel%提出要来一轮双倍决胜局，而且两人都必须用左手。%gambler%同意了。他先手丢出了三个马蹄铁。前两个都丢空了，但第三个在圆环附近停留。这个结果让他感到胜券在握，他不禁咧嘴而笑并祝吟游诗人好运。%minstrel%点了点头然后卷起了自己的袖子。他摆好架势，并瞄准了目标。在投掷之前，他小跳了几下，然后回头说道，%SPEECH_ON%我应该提前告诉你，我*其实*是个左撇子。%SPEECH_OFF%然后他头也不回地就丢出了他的马蹄铁。那是一次完美的投掷，直接命中了正中心。而接下来的两次投掷也是天衣无缝，引得围观的人哄堂大笑。而那位赌徒则吃惊得合不拢嘴。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真是个无耻的小骗子。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Minstrel.getImagePath());
				this.Characters.push(_event.m.Gambler.getImagePath());
				_event.m.Minstrel.improveMood(1.0, "Has outsmarted " + _event.m.Gambler.getName());

				if (_event.m.Minstrel.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Minstrel.getMoodState()],
						text = _event.m.Minstrel.getName() + this.Const.MoodStateEvent[_event.m.Minstrel.getMoodState()]
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

		local candidates_gambler = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.gambler")
			{
				candidates_gambler.push(bro);
			}
		}

		if (candidates_gambler.len() == 0)
		{
			return;
		}

		this.m.Minstrel = candidates_minstrel[this.Math.rand(0, candidates_minstrel.len() - 1)];
		this.m.Gambler = candidates_gambler[this.Math.rand(0, candidates_gambler.len() - 1)];
		this.m.Score = (candidates_minstrel.len() + candidates_gambler.len()) * 5;
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
			"gambler",
			this.m.Gambler.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Minstrel = null;
		this.m.Gambler = null;
	}

});

