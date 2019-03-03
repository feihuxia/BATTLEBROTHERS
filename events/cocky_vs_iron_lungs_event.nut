this.cocky_vs_iron_lungs_event <- this.inherit("scripts/events/event", {
	m = {
		Cocky = null,
		IronLungs = null
	},
	function create()
	{
		this.m.ID = "event.cocky_vs_iron_lungs";
		this.m.Title = "营地…";
		this.m.Cooldown = 150.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]在你卷起地图放回肩筐里时，骚乱声让你走出了帐篷。那人拖着%cocky%到处走。他的衣服湿透了，脸上一片阴影。那人给了他好几耳光。最终，他醒了过来，眼神疯狂，口水横流，好像坏掉的喷泉。他环顾四周，问出了你也想知道的事。%SPEECH_ON%怎么了？%SPEECH_OFF%%ironlungs%走过来，一副差不多的湿透的样子，但脸色复杂多了。%SPEECH_ON%自大的荡妇，敢看看我们谁更沉得住气吗。你输了，因为他们把这叫做铁肺是有原因的。%SPEECH_OFF%%ironlungs%炫耀地敲他胸膛时那人还在笑。还在摇摇晃晃的%cocky%站了起来。在完全失去意识后一会儿里，他已经恢复了骄傲的样子。在%SPEECH_ON%对对，今天你比我厉害，但我会成为最强的，你等着吧！%SPEECH_OFF%另一个佣兵古怪地指出那位自信过头的小伙子鼻子下面挂着一长条鼻涕。尽管战团哄堂大笑，但他自信地抹掉了鼻涕。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "啊，一如既往安全的男子气概测量方式。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cocky.getImagePath());
				this.Characters.push(_event.m.IronLungs.getImagePath());
				_event.m.Cocky.addLightInjury();
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.Cocky.getName() + " suffers light wounds"
				});
				_event.m.Cocky.worsenMood(1.0, "Was humiliated in front of the company");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Cocky.getMoodState()],
					text = _event.m.Cocky.getName() + this.Const.MoodStateEvent[_event.m.Cocky.getMoodState()]
				});
				_event.m.IronLungs.improveMood(1.0, "Beat " + _event.m.Cocky.getName() + " in a contest of strength");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.IronLungs.getMoodState()],
					text = _event.m.IronLungs.getName() + this.Const.MoodStateEvent[_event.m.IronLungs.getMoodState()]
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() != _event.m.Cocky.getID() && bro.getID() != _event.m.IronLungs.getID() && this.Math.rand(1, 100) <= 33)
					{
						bro.improveMood(0.5, "Felt entertained by " + _event.m.Cocky.getNameOnly());

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
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local cocky_candidates = [];
		local ironlungs_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.cocky"))
			{
				cocky_candidates.push(bro);
			}
			else if (bro.getSkills().hasSkill("trait.iron_lungs"))
			{
				ironlungs_candidates.push(bro);
			}
		}

		if (cocky_candidates.len() == 0 || ironlungs_candidates.len() == 0)
		{
			return;
		}

		this.m.Cocky = cocky_candidates[this.Math.rand(0, cocky_candidates.len() - 1)];
		this.m.IronLungs = ironlungs_candidates[this.Math.rand(0, ironlungs_candidates.len() - 1)];
		this.m.Score = (cocky_candidates.len() + ironlungs_candidates.len()) * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"cocky",
			this.m.Cocky.getNameOnly()
		]);
		_vars.push([
			"ironlungs",
			this.m.IronLungs.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Cocky = null;
		this.m.IronLungs = null;
	}

});

