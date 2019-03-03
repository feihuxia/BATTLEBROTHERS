this.juggler_entertains_townsfolk_event <- this.inherit("scripts/events/event", {
	m = {
		Juggler = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.juggler_entertains_townsfolk";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_92.png[/img]当手下的人在%townname% 闲逛着找事做的时候，杂耍者%juggler%开始自娱自乐起来。他拿走了信息使者的卷轴，把它折成了带角的纸帽子。然后把它戴在了头上，溜进到一群农民之中， 让他们给点东西来杂耍。他们把各种各样的东西朝他扔去，从胡萝卜到刀子，一个人甚至在一个母亲扇死他之前想把新生的婴儿给杂耍者。不管杂耍者接到的是什么，他都能轻而易举地将其抛到空中，他的身体扭曲变形，脚与手并用将东西重新踢回空中。这简直就是一首行动的诗 — 也是给这被蹂躏的小镇一次恩赐。你有感觉，这个杂耍者今天完美代表了%companyname%。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干得好，非常棒。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				_event.m.Town.getFactionOfType(this.Const.FactionType.Settlement).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "One of your men entertained the townsfolk");
				_event.m.Juggler.improveMood(2.0, "Entertained townsfolk with his juggling");

				if (_event.m.Juggler.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Juggler.getMoodState()],
						text = _event.m.Juggler.getName() + this.Const.MoodStateEvent[_event.m.Juggler.getMoodState()]
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

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.juggler")
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

		this.m.Juggler = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Town = town;
		this.m.Score = candidates.len() * 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"juggler",
			this.m.Juggler.getNameOnly()
		]);
		_vars.push([
			"town",
			this.m.Town.getNameOnly()
		]);
		_vars.push([
			"townname",
			this.m.Town.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Juggler = null;
		this.m.Town = null;
	}

});

