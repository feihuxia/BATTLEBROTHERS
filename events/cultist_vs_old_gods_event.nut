this.cultist_vs_old_gods_event <- this.inherit("scripts/events/event", {
	m = {
		Cultist = null,
		OldGods = null
	},
	function create()
	{
		this.m.ID = "event.cultist_vs_old_gods";
		this.m.Title = "营地…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_06.png[/img]在享受培根切片的同时， 你听到了一阵争吵。你曾经忽视了他，但是他变得越来越丑，让你不能好好享受你的大餐。被激怒了，你站起来去那里看看。你发现 %cultist% 还有%oldgods% 彼此对视，异教徒和神的跟随者显然有一些分歧。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让我们使用暴力吧！",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "阻止这种场面。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OldGods.getImagePath());
				this.Characters.push(_event.m.Cultist.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_06.png[/img] 你走到旁边，让人们消除分歧而他们当前有巨大的分歧。以武力解决争端，神的信徒，一次又一次地打击异教徒。但是受伤的人只会报以冷笑。他的眼睛肿了， 他的眼皮变成紫色模糊了他的视力。但是， 仍然，他冷笑着， 在他红色的嘴唇里面发出的笑容喷出血液。%SPEECH_ON%如此黑暗!Davkul 最为快乐!%SPEECH_OFF%一副好奇的表情， %oldgods% 走开 %cultist% 又回来。摩擦着带血的指关节， 意识到他可能在一边倒的混战当中打到了几个人。但是是异教徒的话伤他伤的最深。%SPEECH_ON%人不是被黑暗所吸引， 那是他自己的决定!快点滚吧!他返回的时候的快乐!%SPEECH_OFF%几乎不敢回头， %oldgods% 留下异教徒匆匆逃走， 狂笑并且在草地上狰狞， 没有人敢于接近他。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我不知道 %oldgods% 如此有勇气。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OldGods.getImagePath());
				this.Characters.push(_event.m.Cultist.getImagePath());
				_event.m.OldGods.worsenMood(1.0, "Lost composure and resorted to violence");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.OldGods.getMoodState()],
					text = _event.m.OldGods.getName() + this.Const.MoodStateEvent[_event.m.OldGods.getMoodState()]
				});
				_event.m.OldGods.getBaseProperties().Bravery += -1;
				_event.m.OldGods.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.OldGods.getName() + " loses [color=" + this.Const.UI.Color.NegativeEventValue + "]-1[/color] 决心"
				});
				local injury = _event.m.Cultist.addInjury(this.Const.Injury.Brawl);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.Cultist.getName() + " suffers " + injury.getNameOnly()
				});
				_event.m.Cultist.getBaseProperties().Bravery += 2;
				_event.m.Cultist.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Cultist.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+2[/color] 决心"
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_03.png[/img] 你做的那些事，简直不是人。趁他们还没有拳脚相向，你赶紧走到那两个人中间，分开他们。你告诉 %oldgods% 说，他有更高的本事，你什么也没对%cultist%说，因为异教徒正在大笑。他咯咯笑着。%SPEECH_ON%虽然现在一片光明，但黑暗非常有耐心。Davkul在等待你们所有人。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "工作也在等你，赶紧滚。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OldGods.getImagePath());
				this.Characters.push(_event.m.Cultist.getImagePath());
				_event.m.OldGods.worsenMood(1.0, "Was denied the chance to enlighten a cultist");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.OldGods.getMoodState()],
					text = _event.m.OldGods.getName() + this.Const.MoodStateEvent[_event.m.OldGods.getMoodState()]
				});
				_event.m.Cultist.worsenMood(1.0, "Was denied the chance to break a follower of the old gods");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Cultist.getMoodState()],
					text = _event.m.Cultist.getName() + this.Const.MoodStateEvent[_event.m.Cultist.getMoodState()]
				});
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

		local cultist_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
			{
				cultist_candidates.push(bro);
			}
		}

		if (cultist_candidates.len() == 0)
		{
			return;
		}

		local oldgods_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.monk" || bro.getBackground().getID() == "background.flagellant" || bro.getBackground().getID() == "background.pacified_flagellant" || bro.getBackground().getID() == "background.monk_turned_flagellant")
			{
				oldgods_candidates.push(bro);
			}
		}

		if (oldgods_candidates.len() == 0)
		{
			return;
		}

		this.m.Cultist = cultist_candidates[this.Math.rand(0, cultist_candidates.len() - 1)];
		this.m.OldGods = oldgods_candidates[this.Math.rand(0, oldgods_candidates.len() - 1)];
		this.m.Score = (cultist_candidates.len() + oldgods_candidates.len()) * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"cultist",
			this.m.Cultist.getName()
		]);
		_vars.push([
			"oldgods",
			this.m.OldGods.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Cultist = null;
		this.m.OldGods = null;
	}

});

