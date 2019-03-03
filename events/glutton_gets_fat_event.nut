this.glutton_gets_fat_event <- this.inherit("scripts/events/event", {
	m = {
		Glutton = null
	},
	function create()
	{
		this.m.ID = "event.glutton_gets_fat";
		this.m.Title = "营地…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_14.png[/img]你发现%glutton%第三次去拿东西吃。那太多了，所以你要求那是最后一次。又一个兄弟加入进来，嘲笑着他的习惯。贪吃者生气了，放下了食物然后站了起来。但是他的肚子却出卖了他，这个胖家伙四肢一软倒了下去。尽管战团其他的人大笑了起来，你还是不禁怀疑是不是这个佣兵太胖了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "放下叉子。现在。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Glutton.getImagePath());
				local trait = this.new("scripts/skills/traits/fat_trait");
				_event.m.Glutton.getSkills().add(trait);
				this.List.push({
					id = 10,
					icon = trait.getIcon(),
					text = _event.m.Glutton.getName() + " gets fat"
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getFood() < 100)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 3 && bro.getSkills().hasSkill("trait.gluttonous") && !bro.getSkills().hasSkill("trait.fat"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Glutton = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"glutton",
			this.m.Glutton.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Glutton = null;
	}

});

