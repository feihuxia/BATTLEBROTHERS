this.all_naked_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.all_naked";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 9999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_16.png[/img]向前进军的时候，你发现一个旅行者前后转个不停，他的手不知道是否在遮太阳，保护自己的眼睛。他摇了摇头，吐了口口水，%SPEECH_ON%我听说过你们的事情，一群光屁股的家伙来到恶魔之地，就像魔鬼的玩笑复活了似的。你们到底是什么？%SPEECH_OFF%你耸耸肩，告诉那个人，你们目前并没有船上衣服的打算。旅行者又摇了摇头，吐口水，%SPEECH_ON%见鬼，赤身裸体的人进入战场，跟他出生那天一样一丝不挂！讽刺的是，如果我们有人发现你们死在战场上，下葬的时候肯定会给你们穿上像样的衣服。这一点都不难，因为你们当前什么都没穿。%SPEECH_OFF%你对这位旅行者表示感谢，然后继续前进。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "多美的一天啊！",
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
		if (this.World.getTime().Days < 14)
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		foreach( bro in brothers )
		{
			if (bro.getItems().getItemAtSlot(this.Const.ItemSlot.Body) != null)
			{
				return;
			}
		}

		this.m.Score = 25;
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

