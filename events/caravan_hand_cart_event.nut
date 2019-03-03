this.caravan_hand_cart_event <- this.inherit("scripts/events/event", {
	m = {
		CaravanHand = null
	},
	function create()
	{
		this.m.ID = "event.caravan_hand_cart";
		this.m.Title = "营地…";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_55.png[/img]你碰上了曾经的商队管理员，%caravanhand%，他正在完善战团的马车。他把木板钉合到车底，用钉子把它固定到滚轴上。稍微推拉一下，木板就能掉到马车内部去。真是心灵手巧。这样你就能装更多东西到马车上了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "漂亮。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.CaravanHand.getImagePath());
				this.World.Assets.getStash().resize(this.World.Assets.getStash().getCapacity() + 9);
				this.List.push({
					id = 10,
					icon = "ui/icons/special.png",
					text = "你获得物品栏空间"
				});
				_event.m.CaravanHand.improveMood(1.0, "Improved the company\'s cart");

				if (_event.m.CaravanHand.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.CaravanHand.getMoodState()],
						text = _event.m.CaravanHand.getName() + this.Const.MoodStateEvent[_event.m.CaravanHand.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.Ambitions.getAmbition("ambition.cart").isDone())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 6 && bro.getBackground().getID() == "background.caravan_hand")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.CaravanHand = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"caravanhand",
			this.m.CaravanHand.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.CaravanHand = null;
	}

});

