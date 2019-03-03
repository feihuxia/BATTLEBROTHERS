this.greenskins_intro_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_intro";
		this.m.Title = "营地…";
		this.m.Cooldown = 1.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_59.png[/img]%randombrother%来到你的帐篷。%SPEECH_ON%首领，我们抓到了一群难民，他们现在就在外面，想跟你谈谈。%SPEECH_OFF%你将羽毛笔放在一边，走出去见他们。他们乱成一堆，与其说是一群人，不如说是扔入泥地中的抹布。一个手被瘤给取代了的人走上前说道。%SPEECH_ON%你是这里管事的？%SPEECH_OFF%你点了点头，问他们发生了什么，为什么来找我们？他用另一只正常的手。%SPEECH_ON%绿皮怪物攻击了我。%SPEECH_OFF%好吧，没什么新奇的。你问他们现在在哪里，是不是小妖精或兽人。那人摇了摇头。%SPEECH_ON%我知道，是那个东西。两者都是。他们在一起合作。他们如我们脚底下的草那般多。从某种程度上来讲，我说错了。他们不仅仅是攻击我们，更在入侵我们的领地。“所有！”一起的。这是一种超越了能力及方式的侵略，你懂么？%SPEECH_OFF%你看着这群难民。孩子们挤在母亲的裙边，男人们看上去如迷失一般。那人继续说道。%SPEECH_ON%我的父亲在众名之战中奋战。他经常向我保证：他会回来的。现在看来，他说的没错。我们听说贵族已经恐慌了，可能会参与战斗，防止全部都被侵占。如果你愿意听我的意见的话，我建议你们远离那个东西。他们那么多……，没有东西能阻止他们。而且他们做的事……%SPEECH_OFF%你一把抓住那人的上衣%SPEECH_ON%他们所为跟我无关。你们这些农民，离开这个地方，那些打战的去打就好了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "战争来了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Statistics.hasNews("crisis_greenskins_start"))
		{
			this.m.Score = 6000;
		}
	}

	function onPrepare()
	{
		this.World.Statistics.popNews("crisis_greenskins_start");
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

