this.fish_caught_event <- this.inherit("scripts/events/event", {
	m = {
		Fisherman = null
	},
	function create()
	{
		this.m.ID = "event.hunt_food";
		this.m.Title = "路上…";
		this.m.Cooldown = 7.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_52.png[/img]{当在一条河流面前停下的时候，看起来%fisherman% 去做他的老买卖捕一些鱼!| 你来到一个水体上面停了下来和当地人谈到周围的陆地。%fisherman% 曾经的渔民抓住机会去抓一些三文鱼和其他的水生生物。|刚走到河边的时候， %fisherman%曾经的渔民沿着河堤跑搜集了一些小虾!他们在桶里面煮这是美味。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "今晚吃鱼啦！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Fisherman.getImagePath());
				local food = this.new("scripts/items/supplies/dried_fish_item");
				this.World.Assets.getStash().add(food);
				this.List = [
					{
						id = 10,
						icon = "ui/items/" + food.getIcon(),
						text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + food.getAmount() + "[/color] 鱼"
					}
				];
				_event.m.Fisherman.improveMood(0.5, "Has caught some fish");

				if (_event.m.Fisherman.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Fisherman.getMoodState()],
						text = _event.m.Fisherman.getName() + this.Const.MoodStateEvent[_event.m.Fisherman.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Shore)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
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

		if (candidates.len() > 0)
		{
			this.m.Fisherman = candidates[this.Math.rand(0, candidates.len() - 1)];
			this.m.Score = candidates.len() * 15;
		}
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

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Fisherman = null;
	}

});

