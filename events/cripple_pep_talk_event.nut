this.cripple_pep_talk_event <- this.inherit("scripts/events/event", {
	m = {
		Cripple = null,
		Veteran = null
	},
	function create()
	{
		this.m.ID = "event.cripple_pep_talk";
		this.m.Title = "营地…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_06.png[/img]跛子%cripple%问%veteran%是怎么做到的。老兵抬抬眼。%SPEECH_ON%做什么？%SPEECH_OFF%跛子象征性地对着灌木敲敲，同时摇摇头。%SPEECH_ON%你懂的。战斗。每次我到这里，都觉得自己不行，就好像我在拖你们后退。%SPEECH_OFF%%veteran%大笑。%SPEECH_ON%啊，我明白你的意思了。跛子不适合干佣兵这一行。但你是吗？你只是跛子吗？还是男人？你可以选择让你的摇晃和丑陋来决定自己的身份，或者也可以走自己的路，虽然它可能弯弯曲曲，难以前行。%SPEECH_OFF%%cripple%点着头，脸颊开始发光。%SPEECH_ON%你说的对。我能做的还有很多，虽然我有具垂死的身体，但没人比我更努力！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "说得好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cripple.getImagePath());
				this.Characters.push(_event.m.Veteran.getImagePath());
				local resolve = this.Math.rand(1, 3);
				local fatigue = this.Math.rand(1, 3);
				local initiative = this.Math.rand(1, 3);
				_event.m.Cripple.getBaseProperties().Bravery += resolve;
				_event.m.Cripple.getBaseProperties().Stamina += fatigue;
				_event.m.Cripple.getBaseProperties().Initiative += initiative;
				_event.m.Cripple.getSkills().update();
				this.List = [
					{
						id = 16,
						icon = "ui/icons/bravery.png",
						text = _event.m.Cripple.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + resolve + "[/color] 决心"
					},
					{
						id = 17,
						icon = "ui/icons/fatigue.png",
						text = _event.m.Cripple.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + fatigue + "[/color] 最大疲劳"
					},
					{
						id = 17,
						icon = "ui/icons/initiative.png",
						text = _event.m.Cripple.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + initiative + "[/color] 主动性"
					}
				];
				_event.m.Cripple.improveMood(2.0, "Was motivated by " + _event.m.Veteran.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Cripple.getMoodState()],
					text = _event.m.Cripple.getName() + this.Const.MoodStateEvent[_event.m.Cripple.getMoodState()]
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

		foreach( bro in brothers )
		{
			if (bro.getLevel() <= 3 && bro.getBackground().getID() == "background.cripple")
			{
				cripple_candidates.push(bro);
			}
		}

		if (cripple_candidates.len() == 0)
		{
			return;
		}

		local veteran_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 5)
			{
				veteran_candidates.push(bro);
			}
		}

		if (veteran_candidates.len() == 0)
		{
			return;
		}

		this.m.Cripple = cripple_candidates[this.Math.rand(0, cripple_candidates.len() - 1)];
		this.m.Veteran = veteran_candidates[this.Math.rand(0, veteran_candidates.len() - 1)];
		this.m.Score = cripple_candidates.len() * 5;
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
			"veteran",
			this.m.Veteran.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Cripple = null;
		this.m.Veteran = null;
	}

});

