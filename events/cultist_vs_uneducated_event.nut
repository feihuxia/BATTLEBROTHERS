this.cultist_vs_uneducated_event <- this.inherit("scripts/events/event", {
	m = {
		Cultist = null,
		Uneducated = null
	},
	function create()
	{
		this.m.ID = "event.cultist_vs_uneducated";
		this.m.Title = "营地…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]有几个人到你这里来看起来非常担心。他们说 %cultist% 已经和 %uneducated% 坐下来有几个小时。当你问担心什么事情的时候，他们让你想起了异教徒那伤痕累累的前额还说到一些奇怪的事情。啊， 是的。\n\n你去看看那两个人。%uneducated% 抬头看你， 到时候笑着， 还说异教徒教了他们很多。扮个鬼脸，你想知道你是否应该停止.. 他们的授课。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你想怎么做都可以，不过别忘了我雇佣你的目的。",
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
				this.Characters.push(_event.m.Cultist.getImagePath());
				this.Characters.push(_event.m.Uneducated.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]你点头然后转身离开剩下的兄弟们摇着头。第二天早上， %uneducated% 被发现在额头上有新鲜的伤口，改变信仰的血。你问他情况的时候，他只说了几个字。%SPEECH_ON%Davkul 来了。%SPEECH_OFF%好吧，非常好。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "随便吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cultist.getImagePath());
				this.Characters.push(_event.m.Uneducated.getImagePath());
				local background = this.new("scripts/skills/backgrounds/converted_cultist_background");
				_event.m.Uneducated.getSkills().removeByID(_event.m.Uneducated.getBackground().getID());
				_event.m.Uneducated.getSkills().add(background);
				background.buildDescription();
				background.onSetAppearance();
				this.List = [
					{
						id = 13,
						icon = background.getIcon(),
						text = _event.m.Uneducated.getName() + " has been converted to a Cultist"
					}
				];
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
			Text = "[img]gfx/ui/events/event_05.png[/img]你分开了那两个人， 告诉 %uneducated% 去计算一下物品。等他离开的时候， 异教徒对你冷笑。%SPEECH_ON% Davkul 在等待。你在你的睡梦中看到过他。你在夜晚看到他。他的黑暗来了。永远不再有光。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "嗯，好吧，在这之前你还是要替我干活。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cultist.getImagePath());
				this.Characters.push(_event.m.Uneducated.getImagePath());
				_event.m.Cultist.worsenMood(2.0, "Was denied the chance to convert " + _event.m.Uneducated.getName());

				if (_event.m.Cultist.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Cultist.getMoodState()],
						text = _event.m.Cultist.getName() + this.Const.MoodStateEvent[_event.m.Cultist.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 4)
		{
			return;
		}

		local cultist_candidates = [];
		local uneducated_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
			{
				cultist_candidates.push(bro);
			}
			else if (bro.getBackground().isLowborn() && !bro.getSkills().hasSkill("trait.bright") || !bro.getBackground().isNoble() && bro.getSkills().hasSkill("trait.dumb"))
			{
				uneducated_candidates.push(bro);
			}
		}

		if (cultist_candidates.len() == 0 || uneducated_candidates.len() == 0)
		{
			return;
		}

		this.m.Cultist = cultist_candidates[this.Math.rand(0, cultist_candidates.len() - 1)];
		this.m.Uneducated = uneducated_candidates[this.Math.rand(0, uneducated_candidates.len() - 1)];
		this.m.Score = cultist_candidates.len() * 5;
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
			"uneducated",
			this.m.Uneducated.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Cultist = null;
		this.m.Uneducated = null;
	}

});

