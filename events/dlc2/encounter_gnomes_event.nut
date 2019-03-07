this.encounter_gnomes_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.encounter_gnomes";
		this.m.Title = "旅途中..";
		this.m.Cooldown = 200.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img]你让大家休息一下自己独自探访前方的森林。不到五分钟你就听到持续的吟唱的声音。 你抽出佩剑， 来到了一片倒下的树林边，看着树林的另一边 。 在哪里你看到有一群小矮人在绕着圈跳舞。他们一边吹口哨一边说着一些你听不懂的话语，讨论的中心是一个蘑菇和一些非常无聊的蟾蜍，偶尔，也会有小矮人欢笑着在圈子里调皮的跑进跑出,\n\n 喔！小矮人数量太多了，你向前爬为了看的更清楚，不小心弄翻了隐蔽的树枝，小矮人们都停止了歌舞，想看着猎物一样看着你， 突然他们大叫起来，奔跑跳跃着离去，有些躲入树洞有些藏进灌木丛中。你跑到他们跳舞的木桩边，但是什么也没找到，只有一个蘑菇和一只被匕首刺穿的蟾蜍。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真奇怪.",
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
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 25)
			{
				return false;
			}
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

