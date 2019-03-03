this.greenskins_slayer_leaves_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_slayer_leaves";
		this.m.Title = "路上…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_35.png[/img]%orcslayer%兽人杀手向你走来。%SPEECH_ON%那么，看来事情就到此为止了。附近已经没有什么兽人和哥布林可供我杀戮了。再见了，佣兵。%SPEECH_OFF%你问他接下来准备去做什么。他脱下了他的盔甲，放在了你面前的地面上。%SPEECH_ON%我已经为我的家人复仇了。%SPEECH_OFF%你点了点头，祝福了他，希望他的心魔现在已经消散了。他笑了起来。%SPEECH_ON%开个玩笑。我没有家人。我之所以要去杀那些混蛋，因为我很享受那个过程，但现在，我对那已经没什么兴趣了。帮我向其他人道别吧。%SPEECH_OFF%说完，这位兽人杀手，或是说前兽人杀手，离开了战团。",
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
					text = _event.m.Dude.getName() + " leaves the " + this.World.Assets.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.FactionManager.isGreenskinInvasion())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() == 1)
		{
			return;
		}

		local slayer;

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.orc_slayer")
			{
				slayer = bro;
				break;
			}
		}

		if (slayer == null)
		{
			return;
		}

		this.m.Dude = slayer;
		this.m.Score = 100;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"orcslayer",
			this.m.Dude.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

