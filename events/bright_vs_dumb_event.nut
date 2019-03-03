this.bright_vs_dumb_event <- this.inherit("scripts/events/event", {
	m = {
		Dumb = null,
		Bright = null
	},
	function create()
	{
		this.m.ID = "event.bright_vs_dumb";
		this.m.Title = "路上…";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_15.png[/img]%dumb%可能是你遇到过最蠢的人了，不过%bright%似乎有那么一刻突然明白过来，教了他一些批判性思维和暗记的技巧。你看着他们两一起坐下，看着卷轴。你不知道这些文件是从哪儿来的，但那个讨厌学习的呆子注意力确实非常集中。\n\n你听到%dumb%问了些非常深奥的问题。关于土地和人们的关系，还有天空以及鸟儿的关系。很快你便发现，那个白痴只不过看了看四周，然后把%bright%教给他的东西描述一遍而已，每一句后面都附上了恭维的问题。他们两结束后，%bright%笑着走到你身边。%SPEECH_ON%他已经在进步了，一直在学习，你知道吗？对待这样的学生，一定要耐心，慢慢来。%SPEECH_OFF%%dumb%正在远处用石头砸蚂蚁。你点了点头，让%bright%继续完成每个教师最大的梦想。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你终于找到他了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bright.getImagePath());
				this.Characters.push(_event.m.Dumb.getImagePath());
				_event.m.Bright.improveMood(1.0, "Taught " + _event.m.Dumb.getName() + " something");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Bright.getMoodState()],
					text = _event.m.Bright.getName() + this.Const.MoodStateEvent[_event.m.Bright.getMoodState()]
				});
				_event.m.Dumb.improveMood(1.0, "Bonded with " + _event.m.Bright.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Dumb.getMoodState()],
					text = _event.m.Dumb.getName() + this.Const.MoodStateEvent[_event.m.Dumb.getMoodState()]
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

		local dumb_candidates = [];
		local bright_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.dumb"))
			{
				dumb_candidates.push(bro);
			}
			else if (bro.getSkills().hasSkill("trait.bright"))
			{
				bright_candidates.push(bro);
			}
		}

		if (dumb_candidates.len() == 0 || bright_candidates.len() == 0)
		{
			return;
		}

		this.m.Dumb = dumb_candidates[this.Math.rand(0, dumb_candidates.len() - 1)];
		this.m.Bright = bright_candidates[this.Math.rand(0, bright_candidates.len() - 1)];
		this.m.Score = (dumb_candidates.len() + bright_candidates.len()) * 2;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"dumb",
			this.m.Dumb.getName()
		]);
		_vars.push([
			"dumb_short",
			this.m.Dumb.getNameOnly()
		]);
		_vars.push([
			"bright",
			this.m.Bright.getName()
		]);
		_vars.push([
			"bright_short",
			this.m.Bright.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Dumb = null;
		this.m.Bright = null;
	}

});

