this.ailing_recovers_event <- this.inherit("scripts/events/event", {
	m = {
		Ailing = null,
		Healer = null
	},
	function create()
	{
		this.m.ID = "event.miner_fresh_air";
		this.m.Title = "During camp...";
		this.m.Cooldown = 75.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]{%ailing% 在营地里走来走去，伸出双手，伸出手指，好像在一根绳子上保持平衡（脑补走钢丝姿势）。 他向自己点点头，然后转身，一只脚放在另一只脚的前面，一路走回去。%SPEECH_ON%这么长时间了，我第一次感觉这么好。 谢谢你， %healer%!%SPEECH_OFF% %healer% 似乎知道两种方法可以帮助 %ailing% 摆脱病痛。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "很高兴听到这个消息",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Ailing.getImagePath());
				this.Characters.push(_event.m.Healer.getImagePath());
				_event.m.Ailing.improveMood(1.5, "Feels the best he did in a long time");

				if (_event.m.Ailing.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Ailing.getMoodState()],
						text = _event.m.Ailing.getName() + this.Const.MoodStateEvent[_event.m.Ailing.getMoodState()]
					});
				}

				_event.m.Ailing.getSkills().removeByID("trait.ailing");
				this.List.push({
					id = 10,
					icon = "ui/traits/trait_icon_59.png",
					text = _event.m.Ailing.getName() + " 不再生病了"
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates_ailing = [];
		local candidates_healer = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() < 4)
			{
				continue;
			}

			if (bro.getSkills().hasSkill("trait.ailing"))
			{
				candidates_ailing.push(bro);
			}
			else if (bro.getBackground().getID() == "background.monk" || bro.getBackground().getID() == "background.beast_hunter")
			{
				candidates_healer.push(bro);
			}
		}

		if (candidates_ailing.len() == 0 || candidates_healer.len() == 0)
		{
			return;
		}

		this.m.Ailing = candidates_ailing[this.Math.rand(0, candidates_ailing.len() - 1)];
		this.m.Healer = candidates_healer[this.Math.rand(0, candidates_healer.len() - 1)];
		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"ailing",
			this.m.Ailing.getName()
		]);
		_vars.push([
			"healer",
			this.m.Healer.getName()
		]);
	}

	function onClear()
	{
		this.m.Ailing = null;
		this.m.Healer = null;
	}

});

