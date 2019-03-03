this.determined_delivers_peptalk_event <- this.inherit("scripts/events/event", {
	m = {
		Determined = null
	},
	function create()
	{
		this.m.ID = "event.determined_delivers_peptalk";
		this.m.Title = "营地…";
		this.m.Cooldown = 40.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_58.png[/img]你开始担心手下人们开始有些心神不安了。他们围坐在营火旁边，盲目地往火堆里丢柴火。每个人脸上都展现出一种失去控制的感觉，失去了对自己命运的掌控。如果一个人不能确定明天会比今天更好，那他怎么会有动力继续前进？正当你要说这一点的时候，%determined%站了起来，情绪沮丧到就连他的动作也引起了战团的注意。%SPEECH_ON%看看你们这些可怜虫。你们觉得你们很特殊吗？你们觉得你们是第一个有这种感觉的人吗？不是，当然不是。而且你们也不是第一个放弃的。躺下，永远不再起来。那倒是容易。那是世界想要你做的事情。这世上婊子养的已经够多了，如果你们不想在继续自己的人生的话，那就不需要像你们这些可怜虫来收拾残局。%SPEECH_OFF%战团受到了激励，大家重拾了一点希望。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "他说的对！",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Determined.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_58.png[/img]%determined% 继续说着，几乎要把拇指戳进胸口了。%SPEECH_ON%我才不要忍受这个世界的狗屁事情。我要让这个世界为我的处境付出代价。我可没要请帖，所以我也不会在这个该死的派对上老实下去。我们下辈子见，伙计们，但是在那之前，咱们现在这一世中好好折腾一把！%SPEECH_OFF%人们起身欢呼了起来，大家突然变得兴高采烈起来，就好像地面把他们束缚太久了一样。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "同意！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Determined.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getMoodState() <= this.Const.MoodState.Neutral && this.Math.rand(1, 100) <= 33)
					{
						bro.improveMood(1.0, "Inspired by " + _event.m.Determined.getNameOnly() + "\'s speech");

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
		if (this.World.Assets.getAverageMoodState() >= this.Const.MoodState.Concerned)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 3 && bro.getSkills().hasSkill("trait.determined"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Determined = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 6;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"determined",
			this.m.Determined.getName()
		]);
	}

	function onClear()
	{
		this.m.Determined = null;
	}

});

