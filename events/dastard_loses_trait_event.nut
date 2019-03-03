this.dastard_loses_trait_event <- this.inherit("scripts/events/event", {
	m = {
		Dastard = null,
		Braveman1 = null,
		Braveman2 = null
	},
	function create()
	{
		this.m.ID = "event.dastard_loses_trait";
		this.m.Title = "营地…";
		this.m.Cooldown = 45.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_58.png[/img]你看到%braveman1%与%braveman2%，他们和%dastard%坐在一起。那两个人让他变得十分激动，告诉他在战场上没什么好害怕的。%dastard%解释说，他非常害怕死亡的痛苦。%braveman1%说他看到过很多人死亡，而死在剑下是最快的办法。%braveman2%举起手。%SPEECH_ON%除非直接刺中你的肚子。%SPEECH_OFF%%braveman1%点点头。%SPEECH_ON%没错。除此之外，你没什么好害怕的！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "长大变成一个真正的佣兵， 是吗？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dastard.getImagePath());
				this.Characters.push(_event.m.Braveman1.getImagePath());
				_event.m.Dastard.getSkills().removeByID("trait.dastard");
				this.List = [
					{
						id = 10,
						icon = "ui/traits/trait_icon_38.png",
						text = _event.m.Dastard.getName() + " is no longer a dastard"
					}
				];
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates_dastard = [];
		local candidates_brave = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 3 && bro.getSkills().hasSkill("trait.dastard"))
			{
				candidates_dastard.push(bro);
			}
			else if (bro.getSkills().hasSkill("trait.brave") || bro.getSkills().hasSkill("trait.fearless"))
			{
				candidates_brave.push(bro);
			}
		}

		if (candidates_dastard.len() == 0 || candidates_brave.len() < 2)
		{
			return;
		}

		this.m.Dastard = candidates_dastard[this.Math.rand(0, candidates_dastard.len() - 1)];
		this.m.Braveman1 = candidates_brave[0];
		this.m.Braveman2 = candidates_brave[1];
		this.m.Score = candidates_dastard.len() * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"dastard",
			this.m.Dastard.getName()
		]);
		_vars.push([
			"braveman1",
			this.m.Braveman1.getName()
		]);
		_vars.push([
			"braveman2",
			this.m.Braveman2.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Dastard = null;
		this.m.Braveman1 = null;
		this.m.Braveman2 = null;
	}

});

