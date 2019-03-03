this.inadvertently_save_merchant_event <- this.inherit("scripts/events/event", {
	m = {
		Town = null
	},
	function create()
	{
		this.m.ID = "event.inadvertently_save_merchant";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_20.png[/img]你和一些剑士正走向%townname%，当你转过一个转角时发现一个富人被一群贼和强盗团团围住。他们警惕着，一边大睁着眼睛。其中一个人在商人的脸上划了一道。%SPEECH_ON%好吧，我们下次走着瞧！%SPEECH_OFF%那群无赖很快跑掉了。过了一会儿，那个商人的重装护卫们出现了。他边护理着自己的伤口，边冲他们大喊。%SPEECH_ON%我到底付钱给你们这帮蠢货是干什么的？当我有麻烦的时候，你们人就都不见了？看看这个人，我该给他报酬才对！嘿，陌生人，把这个拿去当成给你造成困难的谢礼。%SPEECH_OFF%商人扔给你一袋钱以表谢意，尽管你所做的只是转了个弯，碰巧碰上这事。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "呃，好吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoney(25);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]25[/color]克朗"
				});
			}

		});
	}

	function onUpdateScore()
	{
		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getSize() <= 1 || t.isMilitary())
			{
				continue;
			}

			if (t.getTile().getDistanceTo(playerTile) <= 4 && t.isAlliedWithPlayer())
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

