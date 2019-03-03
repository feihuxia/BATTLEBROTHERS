this.eunuch_ladies_event <- this.inherit("scripts/events/event", {
	m = {
		Eunuch = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.eunuch_ladies";
		this.m.Title = "在 %town%";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_85.png[/img]有传言提到 %eunuch% 太监。很明显， 他和他的兄弟们去了妓院。妓女和兄弟们戏弄了太监， 但是他要求和最有经验的妓女共度五分钟。在两分钟之后他就出来了然后有传言 %eunuch% 的卧室里面有力量在爆发。\n\n现在，小镇的一半人，确切的说是女人，对于 %companyname% 评价很高并且希望战团再次到访。%eunuch% 自己给了你一个眨眼并且笑了一下。你注意到他的嘴唇上面长了点蘑菇。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "一个隐藏的才能。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Eunuch.getImagePath());
				_event.m.Town.getFactionOfType(this.Const.FactionType.Settlement).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "One of your men got a reputation with the ladies");
				_event.m.Eunuch.improveMood(1.5, "Got friendly with some ladies in " + _event.m.Town.getName());

				if (_event.m.Eunuch.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Eunuch.getMoodState()],
						text = _event.m.Eunuch.getName() + this.Const.MoodStateEvent[_event.m.Eunuch.getMoodState()]
					});
				}
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

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 3 && bro.getBackground().getID() == "background.eunuch")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.isMilitary())
			{
				continue;
			}

			if (t.getTile().getDistanceTo(playerTile) <= 3 && t.isAlliedWithPlayer())
			{
				nearTown = true;
				town = t;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		this.m.Eunuch = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Town = town;
		this.m.Score = candidates.len() * 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"eunuch",
			this.m.Eunuch.getNameOnly()
		]);
		_vars.push([
			"town",
			this.m.Town.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Eunuch = null;
		this.m.Town = null;
	}

});

