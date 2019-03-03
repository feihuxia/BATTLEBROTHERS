this.cocky_challenges_player_event <- this.inherit("scripts/events/event", {
	m = {
		Cocky = null
	},
	function create()
	{
		this.m.ID = "event.cocky_challenges_player";
		this.m.Title = "营地…";
		this.m.Cooldown = 45.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]%cocky%来到战团篝火边，说话的时候脸变得红红的。%SPEECH_ON%我不太了解你们，不过我一定能比其他人更好地带领战团！特别是他！%SPEECH_OFF%他指着你。\n\n你坐了下来。他盯着你，等待回应。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你说得对。应该交给你负责。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "该削弱你的权利了。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "现在开始由我负责！这是我的战团！",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cocky.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_26.png[/img]你双腿交叉伸出去，把手放在膝盖上。你点点头，对那个人说。%SPEECH_ON%好了，%cocky%，现在你是负责人了。你每天早晚都要清点物品。我知道你不会数数，但你要学。我可不希望那些人缺少武器就加入战斗。%SPEECH_OFF%你指着其他几个帐篷。%SPEECH_ON%你还要保证不要少人。他们不是很好控制，可能会有人讽刺你，也可能不会。%SPEECH_OFF%你看着自己充满淤青的双手，继续说。%SPEECH_ON%你不仅要下达让他们听从的命令，还要保证他们的人生安全。包括你自己，还有坐在你身边的人。嗯，那么就交给你负责了，%cocky%。一切都是你的责任了。%SPEECH_OFF%你说完后，一群人马上站起来，希望你继续负责。%cocky%看到后，打起了退堂鼓，大声说着“还是你负责吧！”然后跑了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你说的太对了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cocky.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getMoodState() < this.Const.MoodState.Neutral && this.Math.rand(1, 100) <= 33)
					{
						bro.improveMood(1.0, "Gained confidence in your leadership");

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
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_26.png[/img]篝火把你的脸照的通红。你站起来点点头，走向%cocky%。他后退一步，但你伸出手，一把抓住他的肩膀。你迅速走上前去，一条腿抵住他的膝盖后面，抓住他，一下把他扔出去。你跟着他倒在地上，一只手抓住他的后空，另一只手伸出一根手指。%SPEECH_ON%你是个好人，%cocky%，就是太蠢了。我知道你们有些人对目前的情况不太满意，不过我提醒你一句，至少你们还活着！如果有人希望%cocky%掌权，那你们早就死了！%SPEECH_OFF%你站起来，并拉了%cocky%一把。他嘲笑了你一声，然后走开了，顺便踢翻了附近的木桶。你身上被箭射中的地方传来一阵疼痛，但你咬紧牙关，不想有所暴露，然后又坐了下来。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "宝刀未老！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cocky.getImagePath());
				_event.m.Cocky.worsenMood(3.0, "Felt humiliated in front of the company");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Cocky.getMoodState()],
					text = _event.m.Cocky.getName() + this.Const.MoodStateEvent[_event.m.Cocky.getMoodState()]
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_26.png[/img]你马上跳起来大叫着。%SPEECH_ON%我才是负责人！我！有钱的是谁？是我！如果不是我，你们根本不会在这儿！你们还在最艰苦的地方，过着以前的生活！你们应该趴在我面前，乞求我给你们机会！%cocky%，如果你再敢和我争论，我发誓我会吊死你，知道了吗？%SPEECH_OFF%营地突然安静下来。%cocky%点点头，退后了。你重新坐下来的时候，有几个人在下面窃窃私语。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "事情进展非常顺利，不是吗？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cocky.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 33)
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
	}

	function onUpdateScore()
	{
		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates = [];
		local grumpy = 0;

		foreach( bro in brothers )
		{
			if (bro.getMoodState() < this.Const.MoodState.Neutral)
			{
				grumpy = ++grumpy;

				if (bro.getSkills().hasSkill("trait.cocky"))
				{
					candidates.push(bro);
				}
			}
		}

		if (candidates.len() == 0 || grumpy < 3)
		{
			return;
		}

		this.m.Cocky = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 3 + grumpy * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"cocky",
			this.m.Cocky.getName()
		]);
	}

	function onClear()
	{
		this.m.Cocky = null;
	}

});

