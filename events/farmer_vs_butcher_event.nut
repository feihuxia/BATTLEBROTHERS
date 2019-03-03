this.farmer_vs_butcher_event <- this.inherit("scripts/events/event", {
	m = {
		Butcher = null,
		Farmer = null
	},
	function create()
	{
		this.m.ID = "event.farmer_vs_butcher";
		this.m.Title = "营地…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_06.png[/img]你发现 %farmhand% 和 %butcher% 为了一块肉吵了起来。农民提高了他的声音。%SPEECH_ON%肩上的肉是最好的。这就是为什么你先切下来!应该这样切， 不是像你这个傻瓜那样。%SPEECH_OFF%也提高了他的声音， 握着他的拳头屠夫摇头。%SPEECH_ON%为什么连你都要怀疑我？我是一个该死的屠夫，你这个可怜的农民!我这样做是为了生存， 你那么做是因为你抓牛的乳房抓得太紧了把他给弄死了，无疑是当成了你父亲的小鸡鸡!%SPEECH_OFF%互喷开始了。有人被削了， 还有一些人的鼻子被砸了个坑。人们被分开了，但是造成了伤害。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你们都是雇佣兵了!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Butcher.getImagePath());
				this.Characters.push(_event.m.Farmer.getImagePath());

				if (this.Math.rand(1, 100) <= 50)
				{
					local injury1 = _event.m.Butcher.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury1.getIcon(),
						text = _event.m.Butcher.getName() + " suffers " + injury1.getNameOnly()
					});
				}
				else
				{
					_event.m.Butcher.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Butcher.getName() + " suffers light wounds"
					});
				}

				_event.m.Butcher.worsenMood(0.5, "Got in a brawl with " + _event.m.Farmer.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Butcher.getMoodState()],
					text = _event.m.Butcher.getName() + this.Const.MoodStateEvent[_event.m.Butcher.getMoodState()]
				});

				if (this.Math.rand(1, 100) <= 50)
				{
					local injury2 = _event.m.Farmer.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury2.getIcon(),
						text = _event.m.Farmer.getName() + " suffers " + injury2.getNameOnly()
					});
				}
				else
				{
					_event.m.Farmer.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Farmer.getName() + " suffers light wounds"
					});
				}

				_event.m.Farmer.worsenMood(0.5, "Got in a brawl with " + _event.m.Butcher.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Farmer.getMoodState()],
					text = _event.m.Farmer.getName() + this.Const.MoodStateEvent[_event.m.Farmer.getMoodState()]
				});
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local butcher_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() <= 3 && bro.getBackground().getID() == "background.butcher")
			{
				butcher_candidates.push(bro);
				break;
			}
		}

		if (butcher_candidates.len() == 0)
		{
			return;
		}

		local farmer_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() <= 3 && bro.getBackground().getID() == "background.farmhand")
			{
				farmer_candidates.push(bro);
			}
		}

		if (farmer_candidates.len() == 0)
		{
			return;
		}

		this.m.Butcher = butcher_candidates[this.Math.rand(0, butcher_candidates.len() - 1)];
		this.m.Farmer = farmer_candidates[this.Math.rand(0, farmer_candidates.len() - 1)];
		this.m.Score = (butcher_candidates.len() + farmer_candidates.len()) * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"farmhand",
			this.m.Farmer.getNameOnly()
		]);
		_vars.push([
			"butcher",
			this.m.Butcher.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Farmer = null;
		this.m.Butcher = null;
	}

});

