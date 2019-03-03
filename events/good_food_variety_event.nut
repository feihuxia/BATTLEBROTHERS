this.good_food_variety_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.good_food_variety";
		this.m.Title = "营地…";
		this.m.Cooldown = 25.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_61.png[/img]{你看着这个男人吃着碟子上的东西就像是这个男人多彩的性格一样。这么多各种各样的食物库存唤起了他们的精神去赢得各种各样的胜利!| 大量的热食物是人们需要的， 但是热食物，几个配菜和主菜？好吧， 那就完全不同了!你给我买各种不同的食物人们都欢快地吃起来感觉到了生命的美好。| 食物的多样就像是贵族一样 - 或者是更近了吧。你把那些提供给战团人们非常感激地吃起来。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Enjoy.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getSkills().hasSkill("trait.spartan"))
					{
						continue;
					}
					else if (bro.getSkills().hasSkill("trait.gluttonous") || bro.getSkills().hasSkill("trait.fat"))
					{
						bro.improveMood(2.0, "Very much appreciated the food variety");
					}
					else
					{
						bro.improveMood(1.0, "Appreciated the food variety");
					}

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

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local hasBros = false;

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.spartan"))
			{
				continue;
			}

			hasBros = true;
			break;
		}

		if (!hasBros)
		{
			return;
		}

		local stash = this.World.Assets.getStash().getItems();
		local food = [];

		foreach( item in stash )
		{
			if (item != null && item.isItemType(this.Const.Items.ItemType.Food))
			{
				if (food.find(item.getID()) == null)
				{
					food.push(item.getID());
				}
			}
		}

		if (food.len() < 4)
		{
			return;
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

