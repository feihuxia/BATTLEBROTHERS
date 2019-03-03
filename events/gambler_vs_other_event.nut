this.gambler_vs_other_event <- this.inherit("scripts/events/event", {
	m = {
		DumbGuy = null,
		Gambler = null
	},
	function create()
	{
		this.m.ID = "event.gambler_vs_other";
		this.m.Title = "营地…";
		this.m.Cooldown = 25.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_06.png[/img]{%gambler%和%nongambler%争斗了起来。好像他们之间有一点矛盾。看到两个人都没死，你并不是很在意是因为什么，但是他们还是告诉了你。\n\n原来赌徒靠出老千赢了一点钱。你问他们其中是不是有战团的钱。他们说没有。你又问那他们找你干什么。| 一场纸牌游戏最终以不快告终，%nongambler%跳了起来开始对%gambler%长篇大论。这个专业赌徒羞怯地环顾四周。这样的人是怎么通过打牌得到这么多钱的，他问道，但是当他举起手想要制造混乱的时候，几张‘额外的’牌从他的袖子里掉了出来。接下来的事情很有意思，但是你在有人受伤之前制止了这场闹剧。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "把这力气留到战斗的时候用。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Gambler.getImagePath());
				this.Characters.push(_event.m.DumbGuy.getImagePath());

				if (this.Math.rand(1, 100) <= 50)
				{
					_event.m.Gambler.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Gambler.getName() + " suffers light wounds"
					});
				}
				else
				{
					local injury = _event.m.Gambler.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Gambler.getName() + " suffers " + injury.getNameOnly()
					});
				}

				if (this.Math.rand(1, 100) <= 50)
				{
					_event.m.DumbGuy.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.DumbGuy.getName() + " suffers light wounds"
					});
				}
				else
				{
					local injury = _event.m.DumbGuy.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.DumbGuy.getName() + " suffers " + injury.getNameOnly()
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

		local gambler_candidates = [];
		local dumb_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.gambler")
			{
				gambler_candidates.push(bro);
			}
			else if (!bro.getSkills().hasSkill("trait.bright"))
			{
				dumb_candidates.push(bro);
			}
		}

		if (gambler_candidates.len() == 0 || dumb_candidates.len() == 0)
		{
			return;
		}

		this.m.DumbGuy = dumb_candidates[this.Math.rand(0, dumb_candidates.len() - 1)];
		this.m.Gambler = gambler_candidates[this.Math.rand(0, gambler_candidates.len() - 1)];
		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"nongambler",
			this.m.DumbGuy.getName()
		]);
		_vars.push([
			"gambler",
			this.m.Gambler.getName()
		]);
	}

	function onClear()
	{
		this.m.DumbGuy = null;
		this.m.Gambler = null;
	}

});

