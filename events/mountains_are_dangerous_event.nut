this.mountains_are_dangerous_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.mountains_are_dangerous";
		this.m.Title = "在山脉中……";
		this.m.Cooldown = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_42.png[/img]尽管身处山脉之中，你依然能看到不断向四方蔓延的山峰，山峰之间则有谷地相连。这篇景象真是壮丽，但同时也带来了许多麻烦。翻山越岭，或者是寻找山路，都是非常累人的。对于那些需要湿滑的斜坡和松动的沙砾地，你们只能通过手脚并用的方式来通过。这些险要的地形无不在考验着人们克服困难的决心。\n\n 在你周围，四处都是闲逛的山羊。它们四处轻松地跳跃着觅食，似乎在嘲笑着你们的无能。石桥以及各种古怪的岩石之间，常有好奇的山狮子活动。你感觉到它们似乎对人并不陌生。它们并不会主动攻击，但也会一直跟着你们。如果你们其中有人因坠落而受伤，那最好还是丢下他。因为在这种环境下背着一个受伤的人，无异于让两个人都去送死。\n\n在检查一下队伍的状况后，你发现许多人都负了伤。一些人是腿伤。一些人四肢酸痛。还有人膝部抽筋。有些人可能断了几根骨头，但这些都不是致命伤。只有那些敏捷而强壮的人才能在这里穿梭自如，而且他们一般会是第一个登上山顶的人。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这地方真可恶！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.List = _event.giveEffect();
			}

		});
	}

	function giveEffect()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local result = [];
		local lowestChance = 9000;
		local lowestBro;
		local applied = false;

		foreach( bro in brothers )
		{
			local chance = bro.getHitpoints() + 20;

			if (bro.getSkills().hasSkill("trait.dexterous"))
			{
				chance = chance + 20;
			}

			if (bro.getSkills().hasSkill("trait.sure_footing"))
			{
				chance = chance + 20;
			}

			if (bro.getSkills().hasSkill("trait.strong"))
			{
				chance = chance + 20;
			}

			for( ; this.Math.rand(1, 100) < chance;  )
			{
				if (chance < lowestChance)
				{
					lowestChance = chance;
					lowestBro = bro;
				}
			}

			applied = true;
			local injury = bro.addInjury(this.Const.Injury.Mountains);
			result.push({
				id = 10,
				icon = injury.getIcon(),
				text = bro.getName() + " suffers " + injury.getNameOnly()
			});
		}

		if (!applied && lowestBro != null)
		{
			local injury = lowestBro.addInjury(this.Const.Injury.Mountains);
			result.push({
				id = 10,
				icon = injury.getIcon(),
				text = lowestBro.getName() + " suffers " + injury.getNameOnly()
			});
		}

		return result;
	}

	function onUpdateScore()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Mountains)
		{
			return;
		}

		this.m.Score = 25;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

