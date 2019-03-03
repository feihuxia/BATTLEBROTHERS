this.noble_vs_lowborn_event <- this.inherit("scripts/events/event", {
	m = {
		Noble = null,
		Lowborn = null
	},
	function create()
	{
		this.m.ID = "event.noble_vs_lowborn";
		this.m.Title = "营地…";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_64.png[/img] 你发现贵族%nobleman_short%正在和衣衫褴褛的%lowborn%争抢着最后一份食物。显然，是这位平民先叉到它的，但这位贵族却说因为自己血统高贵所以这肉应该归他。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你们自己解决吧。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "在佣兵战团里，没有出身贵贱之分。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "你知道这里的规矩，把那个贵族想要的东西给他。",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Noble.getImagePath());
				this.Characters.push(_event.m.Lowborn.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_06.png[/img]就在两人等待着你来定夺的时候，你选择了袖手旁观。他们随后转头看向对方。营地中的其他人则后退了几步，为他们的争斗让出了地方。那位平民先拔出了匕首。那只不过是一把非常简单的武器，一把带着木把手的刃具。贵族也拔出了自己的剑，那是铁匠精心打造的华丽武器。剑柄上还有两条蜿蜒的金蛇。持剑者一边笑一边说道，贱民就应该知道自己的身份。而那位贱民则只会尴尬地傻笑。\n\n突然，两个都把武器插入了刚才的座位之中，然后举起拳头开始了一场公平的对决。随后，一旁烤肉用的铁叉一下子就被扭打的两人所掀翻，顿时烟尘四散，旁边已被料理好的食物也粘上了的灰烬。\n\n看到他们的大餐被毁掉，剩余的战团终于结束战斗，拉开了二人。他们彼此威胁唾弃，但是几分钟后一切都静了下来。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "他们很快成为战场上的兄弟。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Noble.getImagePath());
				this.Characters.push(_event.m.Lowborn.getImagePath());
				local injury1 = _event.m.Noble.addInjury(this.Const.Injury.Brawl);
				local injury2 = _event.m.Lowborn.addInjury(this.Const.Injury.Brawl);
				this.List.push({
					id = 10,
					icon = injury1.getIcon(),
					text = _event.m.Noble.getName() + " suffers " + injury1.getNameOnly()
				});
				this.List.push({
					id = 10,
					icon = injury2.getIcon(),
					text = _event.m.Lowborn.getName() + " suffers " + injury2.getNameOnly()
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_64.png[/img]%nobleman%一脸惊愕。他略微抬起了自己的叉子，%lowborn%则借机将最后一块肉送入自己口中。贵族起身朝你走来。他在你面前直起身体，用胸脯顶着你，眼睛也死死盯着你不放。看到这架式，周围一些人把手放在了武器握柄上。%SPEECH_ON%{你和那个贱民是一伙的的吗？我想也是，毕竟你也出身下贱。别想着以后能成为我们的一员。你这辈子都只能当佣兵了。好好记住这一点。| 你觉得在这一切结束后，你能得到一片属于自己的领地吗？我衷心祝愿你的愿望能够实现，因为这样一来我可以到你的领地去给你展示一下贵族之间真正的交流方式。}%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "滚开。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Noble.getImagePath());
				this.Characters.push(_event.m.Lowborn.getImagePath());
				_event.m.Noble.worsenMood(2.0, "Was humiliated in front of the company");

				if (_event.m.Noble.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Noble.getMoodState()],
						text = _event.m.Noble.getName() + this.Const.MoodStateEvent[_event.m.Noble.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_64.png[/img]%nobleman%狞笑着将%lowborn%的叉子推到一边。随后这位贵族就开始大块朵颐，而那位出身贫贱的人则朝你冲了过来。在他靠近你的时候，旁边的一些人已经做好了拔剑的架式，但你举起一只手，示意他们不要动武。%SPEECH_ON%我曾以为你是我们的一员，看来我想错了。你是不是觉得自己有一天也能成为一名贵族？接着做你的美梦吧。那个人跟我说过的话，我原封不动地送给你，‘认清自己的身份吧’。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "滚开。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Noble.getImagePath());
				this.Characters.push(_event.m.Lowborn.getImagePath());
				_event.m.Lowborn.worsenMood(2.0, "Was humiliated in front of the company");

				if (_event.m.Lowborn.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Lowborn.getMoodState()],
						text = _event.m.Lowborn.getName() + this.Const.MoodStateEvent[_event.m.Lowborn.getMoodState()]
					});
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

		local noble_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() < 7 && bro.getBackground().isNoble())
			{
				noble_candidates.push(bro);
			}
		}

		if (noble_candidates.len() == 0)
		{
			return;
		}

		local lowborn_candidates = [];

		foreach( bro in brothers )
		{
			if (!bro.getSkills().hasSkill("trait.hesitant") && bro.getBackground().isLowborn())
			{
				lowborn_candidates.push(bro);
			}
		}

		if (lowborn_candidates.len() == 0)
		{
			return;
		}

		this.m.Noble = noble_candidates[this.Math.rand(0, noble_candidates.len() - 1)];
		this.m.Lowborn = lowborn_candidates[this.Math.rand(0, lowborn_candidates.len() - 1)];
		this.m.Score = noble_candidates.len() * 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"nobleman",
			this.m.Noble.getName()
		]);
		_vars.push([
			"nobleman_short",
			this.m.Noble.getNameOnly()
		]);
		_vars.push([
			"lowborn",
			this.m.Lowborn.getName()
		]);
		_vars.push([
			"lowborn_short",
			this.m.Lowborn.getNameOnly()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Noble = null;
		this.m.Lowborn = null;
	}

});

