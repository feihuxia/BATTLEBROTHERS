this.caravan_guard_vs_raider_event <- this.inherit("scripts/events/event", {
	m = {
		CaravanHand = null,
		Raider = null
	},
	function create()
	{
		this.m.ID = "event.caravan_guard_vs_raider";
		this.m.Title = "营地…";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_06.png[/img] 你希望受你雇佣的人能忘掉他们以前的生活，但情况并不如意。%caravanhand%和%raider%彼此非常熟悉：商人以前在战斗中对付过掠夺者，最后没能获胜。如今，他们希望解决很久以前就结下的仇恨，他们两扭打在一起，拳打脚踢，甚至互相吐口水。你把他们俩分开，让他们平静下来，告诉他们说，如今他们已经是佣兵了，不是敌人。你强迫他们俩握了握手。商人点点头。%SPEECH_ON%好了，%raider%。%SPEECH_OFF%掠夺者点点头，擦了擦自己鼻子上的血。%SPEECH_ON%你似乎比以前变强了。%SPEECH_OFF%他们一起离开了，重修旧好，把之前的麻烦都抛在了一边。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "世界真小啊…",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.CaravanHand.getImagePath());
				this.Characters.push(_event.m.Raider.getImagePath());

				if (this.Math.rand(1, 100) <= 50)
				{
					_event.m.CaravanHand.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.CaravanHand.getName() + " suffers light wounds"
					});
				}
				else
				{
					local injury = _event.m.CaravanHand.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.CaravanHand.getName() + " suffers " + injury.getNameOnly()
					});
				}

				if (this.Math.rand(1, 100) <= 50)
				{
					_event.m.Raider.addLightInjury();
					this.List.push({
						id = 11,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Raider.getName() + " suffers light wounds"
					});
				}
				else
				{
					local injury = _event.m.Raider.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Raider.getName() + " suffers " + injury.getNameOnly()
					});
				}
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

		local candidates_caravan = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() <= 7 && bro.getBackground().getID() == "background.caravan_guard" && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				candidates_caravan.push(bro);
			}
		}

		if (candidates_caravan.len() == 0)
		{
			return;
		}

		local candidates_raider = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() <= 7 && bro.getBackground().getID() == "background.raider" && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				candidates_raider.push(bro);
			}
		}

		if (candidates_raider.len() == 0)
		{
			return;
		}

		this.m.CaravanHand = candidates_caravan[this.Math.rand(0, candidates_caravan.len() - 1)];
		this.m.Raider = candidates_raider[this.Math.rand(0, candidates_raider.len() - 1)];
		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"caravanhand",
			this.m.CaravanHand.getName()
		]);
		_vars.push([
			"raider",
			this.m.Raider.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.CaravanHand = null;
		this.m.Raider = null;
	}

});

