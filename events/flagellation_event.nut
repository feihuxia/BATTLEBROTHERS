this.flagellation_event <- this.inherit("scripts/events/event", {
	m = {
		Flagellant = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.flagellation";
		this.m.Title = "营地…";
		this.m.Cooldown = 25.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]%otherguy%面带痛苦的表情向前走来。他手上拿着头盔，擦了擦眉毛。%SPEECH_ON%长官，呃，你应该来看看。%SPEECH_OFF%你询问他想让你看什么。%SPEECH_ON%我不知道该怎么形容。你最好来亲眼看看。%SPEECH_OFF%你低头看了看你的工作成功 - 为接下来几天的行进做的计划 - 但是，从这个兄弟的表情看来，应该能等等。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那就带我去看吧。",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OtherGuy.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_38.png[/img]你起身让他带你去看看这个神器的东西。你看到一群兄弟围着某个东西或者某个人。你穿过人群，战团安静了下来，你发现%flagellant_short%苦修者昏迷在地上。\n\n他的后背都被撕开，你感觉甚至可以看到一两根肋骨了。他暴力的鞭子上的倒刺都被损坏了，深深地扎入了他的肉体，他的皮肤挂在绳子上。幸好他昏迷了。不是因为他会非常痛苦，而是因为你觉得他可能不会停下。你命令手下帮他清洗干净，处理伤口，然后把他的工具藏起来。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "至少他没有杀死他自己。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OtherGuy.getImagePath());
				this.Characters.push(_event.m.Flagellant.getImagePath());

				if (this.Math.rand(1, 100) <= 50)
				{
					local injury = _event.m.Flagellant.addInjury(this.Const.Injury.Flagellation);
					this.List = [
						{
							id = 10,
							icon = injury.getIcon(),
							text = _event.m.Flagellant.getName() + " suffers " + injury.getNameOnly()
						}
					];
				}
				else
				{
					_event.m.Flagellant.addLightInjury();
					this.List = [
						{
							id = 10,
							icon = "ui/icons/days_wounded.png",
							text = _event.m.Flagellant.getName() + " suffers light wounds"
						}
					];
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

		local candidates = [];

		foreach( bro in brothers )
		{
			if ((bro.getBackground().getID() == "background.flagellant" || bro.getBackground().getID() == "background.monk_turned_flagellant") && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() > 0)
		{
			this.m.Flagellant = candidates[this.Math.rand(0, candidates.len() - 1)];
			this.m.Score = candidates.len() * 10;

			foreach( bro in brothers )
			{
				if (bro.getID() != this.m.Flagellant.getID())
				{
					this.m.OtherGuy = bro;
					break;
				}
			}
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"flagellant",
			this.m.Flagellant.getName()
		]);
		_vars.push([
			"flagellant_short",
			this.m.Flagellant.getNameOnly()
		]);
		_vars.push([
			"otherguy",
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

