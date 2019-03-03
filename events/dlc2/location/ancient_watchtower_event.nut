this.ancient_watchtower_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.location.ancient_watchtower";
		this.m.Title = "随着你的接近...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_108.png[/img]{那座尖塔比你见过的任何城堡都要高出两倍，又比你见过的任何高塔都要细长。看起来好像是谁有足以建造一座堡垒的材料，但却没有建造要塞而是盖了一座塔。 %randombrother%眯着眼睛看向塔顶。%SPEECH_ON%欲与天公试比高啊这是。这玩意他娘的都快窜到云里头去了，头儿。%SPEECH_OFF%你带着一份地图和几个手下进入了高塔。在里面，你发现一个玻璃球放在一个中空的讲台上。球里有一些粉末状的残留物。也许是最近一次使用魔法的痕迹，也许。你的直觉告诉你，住在这个狭小的避难所里的人可能并不总是靠走楼梯上下楼层。但是你只能老老实实爬上去。攀登的过程漫长到残酷，在塔顶是另一个玻璃球，这个球破成了碎片，在一堆玻璃下是具骷髅。附近有一根折断的法杖。你摇摇头朝着窗口走去。从这里望去，世界本身似乎在地平线的边缘弯曲，这无疑是一种奇怪又壮观的景象。你在地图上标记出看到的地理位置，休息五分钟，然后向下折返。\n\n当你回到塔底时，那骷髅跟他的法杖也跑到了那里，而那个碎掉的玻璃球就放在讲台上。所有的人赶紧跑出门外，你紧随其后。回头望去，尖塔的大门正在一阵巨大的金属声中缓缓落下。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧，至少我们得到了这片地方的地图。",
					function getResult( _event )
					{
						this.World.uncoverFogOfWar(this.World.State.getPlayer().getPos(), 1900.0);
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
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
	}

});

