this.undead_crusader_leaves_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.undead_crusader_leaves";
		this.m.Title = "路上…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_35.png[/img]%crusader%脱下盔甲的十字军战士向你走来，头盔还夹在他的手臂下。%SPEECH_ON%好了长官，是时候跟战团道别了。不死者已经被打败了，我的任务也完成了。%SPEECH_OFF%你想跟他握握手，但他却递上了他的头盔和武器。%SPEECH_ON%这些东西对你来说更有用，我已经用不着它们了。佩戴它们与你并肩作战是我一辈子的荣幸。替我向其他人道别。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "再见！",
					function getResult( _event )
					{
						_event.m.Dude.getItems().transferToStash(this.World.Assets.getStash());
						this.World.getPlayerRoster().remove(_event.m.Dude);
						_event.m.Dude = null;
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Dude.getName() + " 离开了 " + this.World.Assets.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.FactionManager.isUndeadScourge())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() == 1)
		{
			return;
		}

		local crusader;

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.crusader")
			{
				crusader = bro;
				break;
			}
		}

		if (crusader == null)
		{
			return;
		}

		this.m.Dude = crusader;
		this.m.Score = 100;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"crusader",
			this.m.Dude.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

