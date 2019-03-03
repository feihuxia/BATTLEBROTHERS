this.more_action_event <- this.inherit("scripts/events/event", {
	m = {
		Bro1 = null,
		Bro2 = null
	},
	function create()
	{
		this.m.ID = "event.more_action";
		this.m.Title = "营地…";
		this.m.Cooldown = 40.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_64.png[/img]你坐在自己的帐篷里，享受着和谐与宁静。这种机会虽然不多，不过最近似乎出现得越来越频繁了。突然，%combatbro1%和%combatbro2%走了进来。他们想要和你谈谈。你答应了他们，然后请他们坐下。很快，他们说明了自己的忧虑：战团已经有一段时间没有参加过战斗了。你向后靠在了椅子上%SPEECH_ON%这难道不好吗？%SPEECH_OFF%%combatbro1%摇了摇头然后摆出了一个坚决的手势。%SPEECH_ON%不好。我们是受雇参加战斗的，而战斗正是我们想要的东西。我们想要战斗，想要厮杀，以及通过它们而得到的荣耀。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们很快就能战斗了 - 我向你保证！",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "不管有没有战斗，你拿到的钱都一样多 - 而且现在你有更多的机会去花钱了。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 50 ? "B" : "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bro1.getImagePath());
				this.Characters.push(_event.m.Bro2.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_64.png[/img]You nod.%SPEECH_ON%我明白。你们两个是渴望战斗的人。你们甚至让我想起了自己。凭你们的本事，我相信你们日后肯定能超越我。你们都是优秀的战士，但不管有没有战斗，你们拿的钱不是一样多吗？那你们为什么还这么担心没有战斗？战斗会来的。我们养你们不是让你们歇着。而是让你们做好准备。%SPEECH_OFF%两人相互看了一眼，然后耸了耸肩并点点头。他们一起站了起来。%SPEECH_ON%你说得对，长官。当时机成熟的时候，我们会为你奋战！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "有这样的战士真是不错。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bro1.getImagePath());
				this.Characters.push(_event.m.Bro2.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_64.png[/img]你试图向这些人解释，无论他们战斗与否，都能拿到全额佣金。但钱并不是他们最关心的问题。他们真正的想要的是战斗，所以你的话对他们没什么作用。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "But...",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bro1.getImagePath());
				this.Characters.push(_event.m.Bro2.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().isCombatBackground() && this.Math.rand(1, 100) <= 50)
					{
						bro.worsenMood(1.0, "Lost confidence in your leadership");

						if (bro.getMoodState() < this.Const.MoodState.Neutral)
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
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_64.png[/img]你站起身来，用手撑住桌面。%SPEECH_ON%你们想要战斗吗？%SPEECH_OFF%两人相互看了一眼，并朝你点了点头。%SPEECH_ON%那就准备好去作战吧！不要担心尚在鞘中的宝剑，佣兵们。我很快就会给你们带来一场实实在在的战斗！%SPEECH_OFF%两人站起身来，握了握你的手。在离开帐篷的时候，他们向你表示感谢。等他们走了之后，你立即打开地图，开始寻找离你最近的作战目标。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "有这样的战士真是不错。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bro1.getImagePath());
				this.Characters.push(_event.m.Bro2.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().isCombatBackground() && this.Math.rand(1, 100) <= 25)
					{
						bro.improveMood(1.0, "Was promised a battle soon");

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
		if (this.Time.getVirtualTimeF() - this.World.Events.getLastBattleTime() < this.World.getTime().SecondsPerDay * 10)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().isCombatBackground() && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() < 2)
		{
			return;
		}

		this.m.Bro1 = candidates[0];
		this.m.Bro2 = candidates[1];
		this.m.Score = candidates.len() * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"combatbro1",
			this.m.Bro1.getName()
		]);
		_vars.push([
			"combatbro2",
			this.m.Bro2.getName()
		]);
	}

	function onClear()
	{
		this.m.Bro1 = null;
		this.m.Bro2 = null;
	}

});

