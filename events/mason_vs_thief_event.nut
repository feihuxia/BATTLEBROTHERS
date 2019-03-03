this.mason_vs_thief_event <- this.inherit("scripts/events/event", {
	m = {
		Mason = null,
		Thief = null
	},
	function create()
	{
		this.m.ID = "event.mason_vs_thief";
		this.m.Title = "营地…";
		this.m.Cooldown = 120.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]泥瓦匠%mason%正在拨弄着营火，%thief%就站一旁。那位盗贼正在思索着一个问题。%SPEECH_ON%在什么地方偷东西最难得手？嗯，金库是最好偷的，所以我们可以先把它排除掉。我曾经从一个金库中偷了好多东西，以至于那里的人都想把给那金库制锁的锁匠给绞死。当然，他们最后并没有找到那位锁匠，因为我就是那个锁匠。哈哈！现在回到你之前的问题上：偷高塔里的东西是最难得手的，特别是那种孤立的高塔。%SPEECH_OFF%说完后，他骄傲地坐回了原处。泥瓦匠点了点头。%SPEECH_ON%是啊，我就料到你会这么说。高塔是为了囚禁重要犯人或保护特殊的物品而建造的。对没有翅膀的生物来说，它们就像是悬挂在空中的笼子。不过有一次，一位恶名昭彰的盗贼，成功从一座高塔上逃脱了。他花了数年的时间用自己的毛发制作了一根足以让他从塔上爬下的‘绳子’。可惜的是，他后来还是被抓住了。几年之后，他故技重施，不过这次他只编了一半长度的绳子，因为他只是用它来上吊。%SPEECH_OFF%%thief%哈哈大笑。%SPEECH_ON%这故事确实非常有趣，不过我可是一名真正的窃贼啊，泥瓦匠，那些小偷根本无法和我相提并论。在我看来，问题的关键在于如何‘进入’高塔。%SPEECH_OFF%泥瓦匠点了点头。%SPEECH_ON%这很简单。只要去犯一个……重罪就行了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好一番高谈阔论啊。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Mason.getImagePath());
				this.Characters.push(_event.m.Thief.getImagePath());
				_event.m.Mason.improveMood(1.0, "Bonded with " + _event.m.Thief.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Mason.getMoodState()],
					text = _event.m.Mason.getName() + this.Const.MoodStateEvent[_event.m.Mason.getMoodState()]
				});
				_event.m.Thief.improveMood(1.0, "Bonded with " + _event.m.Mason.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Thief.getMoodState()],
					text = _event.m.Thief.getName() + this.Const.MoodStateEvent[_event.m.Thief.getMoodState()]
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

		local mason_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.mason")
			{
				mason_candidates.push(bro);
				break;
			}
		}

		if (mason_candidates.len() == 0)
		{
			return;
		}

		local thief_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.thief")
			{
				thief_candidates.push(bro);
			}
		}

		if (thief_candidates.len() == 0)
		{
			return;
		}

		this.m.Mason = mason_candidates[this.Math.rand(0, mason_candidates.len() - 1)];
		this.m.Thief = thief_candidates[this.Math.rand(0, thief_candidates.len() - 1)];
		this.m.Score = (mason_candidates.len() + thief_candidates.len()) * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"mason",
			this.m.Mason.getNameOnly()
		]);
		_vars.push([
			"thief",
			this.m.Thief.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Mason = null;
		this.m.Thief = null;
	}

});

