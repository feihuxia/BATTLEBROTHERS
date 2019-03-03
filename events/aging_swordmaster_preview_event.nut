this.aging_swordmaster_preview_event <- this.inherit("scripts/events/event", {
	m = {
		Swordmaster = null
	},
	function create()
	{
		this.m.ID = "event.aging_swordmaster_preview";
		this.m.Title = "路上…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_17.png[/img]你发现%swordmaster%坐在树桩上。他看着地面，%SPEECH_ON%知道么，我意识到自己已经老了，杀戮太多。这些天我聪明多了，知道了许多事情，很多以前不了解的事情。我回顾过去，开始思考，年轻的时候自己是多么愚蠢。然后我又想，那些被我杀死的人，年纪轻轻就结束了凡人的生命，这样可以重生吗？%SPEECH_OFF%你坐下来耸耸肩。他继续说道，%SPEECH_ON%我发现自己是一名具有智慧的杀手。接着我便杀了很多老人，学到了很多知识。我破坏了许多世界，人们生活的世界，他们甚至不知道这个世界发生了什么事情。如果有人把我打倒，会拯救多少生命呢？会多出多少智慧呢？抱歉，我不是故意唠叨的。%SPEECH_OFF%他站起来，拍了拍双腿。你抓住他的手，%SPEECH_ON%你有想过，自己可能拯救了世界吗？你杀死的那些人，可能会变成可怕的怪物呢？%SPEECH_OFF%他露出微笑，你知道他早就想通这一点了，并不想回答这个问题。他点了点头，然后加入了战团的其他人。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我希望他能开心起来。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Swordmaster.getImagePath());
				_event.m.Swordmaster.worsenMood(1.0, "Realized he\'s getting old");

				if (_event.m.Swordmaster.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Swordmaster.getMoodState()],
						text = _event.m.Swordmaster.getName() + this.Const.MoodStateEvent[_event.m.Swordmaster.getMoodState()]
					});
				}

				_event.m.Swordmaster.getTags().add("aging_preview");
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 6 && bro.getBackground().getID() == "background.swordmaster" && !bro.getTags().has("aging_preview") && !bro.getSkills().hasSkill("trait.old"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() > 0)
		{
			this.m.Swordmaster = candidates[this.Math.rand(0, candidates.len() - 1)];
			this.m.Score = this.m.Swordmaster.getLevel();
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"swordmaster",
			this.m.Swordmaster.getName()
		]);
	}

	function onClear()
	{
		this.m.Swordmaster = null;
	}

});

