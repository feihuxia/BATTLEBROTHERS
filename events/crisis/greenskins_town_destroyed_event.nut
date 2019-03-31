this.greenskins_town_destroyed_event <- this.inherit("scripts/events/event", {
	m = {
		News = null
	},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_town_destroyed";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 7.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_94.png[/img]{收到了个不好的消息。据避难者和商人们所说，%city%已经被绿皮怪物们摧毁了！如果再这样下去，这片土地就再也不会有能被称为家园的地方了。 |  你看到一位贵族信使正在路边给他的马喂水。他说绿皮怪物们已经消灭了%city%的人类军队，毁掉了整座城市！ |  你遇到了坐着一辆空荡荡的货车的制图师和商人。他们正在重新绘制地图，而有一点显得非常奇怪：图上%city%的标志被抹去了。当你询问他们这点时，他们回应道。%SPEECH_ON%哦，你还没听说吗？%city%已经被摧毁了。那些绿皮怪物们击破了防线，杀死了所有人。%SPEECH_OFF%  |  你在路上遇到了一名商人。他的货车空荡荡的，牲口似乎也少了几头。他的脸和衣服上都沾满了鲜血。你问他发生了什么事。他挺了挺身子。%SPEECH_ON%事情？哦不，我并没有什么事情。我只不过在前往%city%的时候发现，那地方已经被绿皮怪物们摧毁了。我勉强跑了出来。那个地方已经完蛋了。如果你想去那里的话，不用白费力气了。它已经消失了。完全不存在了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这场战争我们失败了吗？",
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
		if (!this.World.State.getPlayer().getTile().HasRoad)
		{
			return;
		}

		if (this.World.Statistics.hasNews("crisis_greenskins_town_destroyed"))
		{
			this.m.Score = 2000;
		}
	}

	function onPrepare()
	{
		this.m.News = this.World.Statistics.popNews("crisis_greenskins_town_destroyed");
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"city",
			this.m.News.get("City")
		]);
	}

	function onClear()
	{
		this.m.News = null;
	}

});

