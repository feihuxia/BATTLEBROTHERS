this.ambition_failed_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.ambition_failed";
		this.m.Title = "营地…";
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_64.png[/img]{%randombrother%抱怨道。%SPEECH_ON%放弃可不是这个战团的风格，至少我不这么认为。%SPEECH_OFF%佣兵们都在抱怨。他们对战团没能取得预期的成果感到不满。%SPEECH_ON%我们当然可以为了这个目标而满世界跑，就像是我们整天追逐那虚无缥缈的东西一样。但如果这个目标是无法实现的，我们必须放下它，然后回到我们最擅长的事情上去：战斗，喝酒，然后我们辛苦挣来的钱全花掉！%SPEECH_OFF%%highestexperience_brother%鼓舞着身边的战友。这些话语鼓舞着战团中的其他人，而你则为避免了一场叛乱而松了一口气。  | 当你在营地附近走动时，%randombrother%走上前来向你抱怨。%SPEECH_ON%我记得我刚来的时候，战团是由一群勇猛且无情的战士组成的。没有什么能挡住我们的去路。而现在，%companyname%更像是一帮疲乏的孩子。%SPEECH_OFF%他停顿了一下，咬了咬自己的嘴唇。%SPEECH_ON%队长，呃，我是说，长官。%SPEECH_OFF%你点了点头，然后继续向前走。显然，这个人对战团没能达成你不久前订下的目标而感到不满。  | 尽管以你已经经历了，但战团依然没能取得预期的成果。更糟糕的是，佣兵们都清楚地意识到了这个问题，并且他们似乎比你更受打击。人人都是一副垂头丧气的样子，不满和抱怨的声音明显要多于平时。\n\n然而，太阳依旧照常升起，与其纠结于过往的失败，不如将精力放在寻找新契机上。你心里知道，%companyname%的成员们能够走出这次失利的阴影，并迈向更大的成功。如若不然，这支队伍将在这个过程中灭亡。  | 在经历了一系列思想斗争后，你终于迫使自己放弃了当初为%companyname%制定的目标。佣兵战团在成长的过程中必然会经历一些挫折，但最近的这次失败所带来的影响，完全超出了你的想象。现在最好去接一个报酬丰厚或是比较危险的任务，来转移大家的注意力。  | 当你将战团无法达到预期目标的情况告知所有人的时候，大家都变得有些垂头丧气。他们如同生闷气的小孩子一样刻意避开你，并在你背后低声抱怨。%SPEECH_ON%如果我们连自己制定的目标都无法实现，那还怎么去闯出名气？我想让我们成为世人皆知的战团，无论我们走到哪里，都会有人给我们准备酒水。%SPEECH_OFF%}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "{并非事事都能如愿。 | 好吧。 | 大家会理解的。 | 这阻止不了%companyname%。 | 重要的是，我们仍在不断进步。 | 新的挑战在等待着我们。}",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = "ui/banners/" + this.World.Assets.getBanner() + "s.png";
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 50)
					{
						bro.worsenMood(this.Const.MoodChange.AmbitionFailed, "Lost confidence in your leadership");

						if (bro.getMoodState() < this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}
				}
			}

		});
	}

	function onUpdateScore()
	{
		return;
	}

	function onPrepareVariables( _vars )
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local lowest_hiretime = 100000000.0;
		local lowest_hiretime_bro;
		local highest_hiretime = -9999.0;
		local highest_hiretime_bro;
		local highest_bravery = 0;
		local highest_bravery_bro;
		local lowest_hitpoints = 9999;
		local lowest_hitpoints_bro;

		foreach( bro in brothers )
		{
			if (bro.getHireTime() < lowest_hiretime)
			{
				lowest_hiretime = bro.getHireTime();
				lowest_hiretime_bro = bro;
			}

			if (bro.getHireTime() > highest_hiretime)
			{
				highest_hiretime = bro.getHireTime();
				highest_hiretime_bro = bro;
			}

			if (bro.getCurrentProperties().getBravery() > highest_bravery)
			{
				highest_bravery = bro.getCurrentProperties().getBravery();
				highest_bravery_bro = bro;
			}

			if (bro.getHitpoints() < lowest_hitpoints)
			{
				lowest_hitpoints = bro.getHireTime();
				lowest_hitpoints_bro = bro;
			}
		}

		_vars.push([
			"highestexperience_brother",
			lowest_hiretime_bro.getName()
		]);
		_vars.push([
			"strongest_brother",
			lowest_hiretime_bro.getName()
		]);
		_vars.push([
			"lowestexperience_brother",
			highest_hiretime_bro.getName()
		]);
		_vars.push([
			"bravest_brother",
			highest_bravery_bro.getName()
		]);
		_vars.push([
			"lowesthp_brother",
			lowest_hitpoints_bro.getName()
		]);
		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();
		local nearest_town_distance = 999999;
		local nearest_town;

		foreach( t in towns )
		{
			local d = t.getTile().getDistanceTo(playerTile);

			if (d < nearest_town_distance)
			{
				nearest_town_distance = d;
				nearest_town = t;
			}
		}

		_vars.push([
			"currenttown",
			nearest_town.getName()
		]);
		_vars.push([
			"nearesttown",
			nearest_town.getName()
		]);
	}

	function onClear()
	{
	}

});

