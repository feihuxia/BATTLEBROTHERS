this.fisherman_tells_story_event <- this.inherit("scripts/events/event", {
	m = {
		Fisherman = null
	},
	function create()
	{
		this.m.ID = "event.fisherman_tells_story";
		this.m.Title = "营地…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]%fisherman%，这个老渔民，跟战团的人说着他曾经捕鱼的日子。%SPEECH_ON%{真是大。我以我母亲的名义发誓!这么大的雨当我把他拉出水面的时候河水都下降了一码!| 大海是一个野兽， 是的是的， 上面的天空是主人， 风是纽带，我们人类是跳蚤。| 我又神游了!一个夏日的漂流， 船随着水流行进， 每一次波浪都会带着一个水手直到只剩下我一个人， 是的， 是的!这是实话!到秋天， 我看到了大地， 我是如此高兴我看到了树木高山头上的鸟玩儿我把船在岩石上砸碎亲吻沙子船的碎片在我周围浮动。那是我生命当中最高兴的日子。| 之前从来没有看到过白色的鲸鱼， 但是绿色的？是的。穿着一件苔藓外套， 一件偷来的土地皮毛如果没有什么其他的东西。我们用长矛还有老水手的精神把他干倒。哈，他意识到我们跟上他了 %randomname% - 一个男人带着精良的鱼叉 - 插到它的气孔里面。我当时不知道一头鲸能够这么快地转身， 但是他转身了，他就那么一下撞上了我们的船把几个水手拖下海作为报复。| 我曾经捕捉过一个很大的鲈鱼， 很大。你相信吗？好吧， 有这么大。好了，或许这么大 。好吧我从来没有捉到过鲈鱼。好吧!我从来没有看到过鲈鱼!我只是知道他们就在那里!别管我你们这些只会呆在土地上的人!我在大海里面捕鱼， 该死!我对你们愚蠢的鱼塘什么都不懂。除了鲈鱼， 当然， 我了解他们。}%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我听起来挺可疑。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Fisherman.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 25)
					{
						bro.improveMood(1.0, "Felt entertained");

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
		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.fisherman")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Fisherman = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"fisherman",
			this.m.Fisherman.getName()
		]);
	}

	function onClear()
	{
		this.m.Fisherman = null;
	}

});

