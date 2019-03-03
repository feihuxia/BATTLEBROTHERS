this.fat_guy_gets_fit_event <- this.inherit("scripts/events/event", {
	m = {
		FatGuy = null
	},
	function create()
	{
		this.m.ID = "event.fat_guy_gets_fit";
		this.m.Title = "路上…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_75.png[/img]%fatguy%，顶着一个大肚子， 自从他加入到战团里来他已经对他的体重没有概念了。现在打架不会让他无法呼吸。实际上，他现在弹跳有力显示出了某种敏捷之前你从来没在他身上发现过。看来这些行走在他的身上发生了奇迹。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "他还真有可能成为一个好佣兵。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.FatGuy.getImagePath());
				_event.m.FatGuy.getSkills().removeByID("trait.fat");
				this.List = [
					{
						id = 10,
						icon = "ui/traits/trait_icon_10.png",
						text = _event.m.FatGuy.getName() + " is no longer fat"
					}
				];
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 5 && bro.getSkills().hasSkill("trait.fat"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() > 0)
		{
			this.m.FatGuy = candidates[this.Math.rand(0, candidates.len() - 1)];
			this.m.Score = candidates.len() * 5;
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"fatguy",
			this.m.FatGuy.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.FatGuy = null;
	}

});

