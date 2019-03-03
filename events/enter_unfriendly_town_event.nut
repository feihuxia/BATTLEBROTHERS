this.enter_unfriendly_town_event <- this.inherit("scripts/events/event", {
	m = {
		Town = null
	},
	function create()
	{
		this.m.ID = "event.enter_unfriendly_town";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_43.png[/img]%townname%{The {居民| 市民| 农民| 三教九流 | 小资} 跟你你打招呼{他们向你扔来发臭的鸡蛋你认为他们对你的出现没什么好感。| 一个沾满油和羽毛的洋娃娃在附近的树上摇摆。他的脸和你的脸看起来非常相似， 但是你认为这是一个巧合而已。| 有几个小孩无疑是他们的父母让他们来作恶， 在这个成人的世界， 可能会引发暴力的回应。随后这些小东西引发了骚乱，你命令你的人用他们的靴子教育一下他们。教育一下他们可以把这些小杂种赶走，但是能维持多久呢？|你的雕像被焚烧。农民们把他侵泡在猪笼里。他们正在他的周围， 确保你无法看到有你形状的木头能剩下什么。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我受不了这个小镇了。",
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
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();
		local nearTown = false;
		local town;

		foreach( t in towns )
		{
			if (t.isMilitary())
			{
				continue;
			}

			if (t.getTile().getDistanceTo(playerTile) <= 3 && t.isAlliedWithPlayer() && t.getFactionOfType(this.Const.FactionType.Settlement).getPlayerRelation() <= 35)
			{
				nearTown = true;
				town = t;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		this.m.Town = town;
		this.m.Score = 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.Town = null;
	}

});

