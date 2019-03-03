this.mountain_running_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.mountain_running";
		this.m.Title = "在山脉中……";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_42.png[/img]翻山越岭，无论对敌对友，都是一项严酷的考验。虽然战团在经历这这一切之后显得有些疲惫，但他们已经战胜了自然环境所设下的种种挑战。%dude%尤其如此。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这一切都是值得的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local bro = _event.m.Dude;
				this.Characters.push(bro.getImagePath());
				local stamina = this.Math.rand(1, 3);
				bro.getBaseProperties().Stamina += stamina;
				bro.getSkills().update();
				this.List.push({
					id = 17,
					icon = "ui/icons/fatigue.png",
					text = bro.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + stamina + "[/color] 最大疲劳"
				});
			}

		});
	}

	function onUpdateScore()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Mountains)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		this.m.Dude = brothers[this.Math.rand(0, brothers.len() - 1)];
		this.m.Score = 20;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"dude",
			this.m.Dude.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

