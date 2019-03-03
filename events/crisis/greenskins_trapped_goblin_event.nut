this.greenskins_trapped_goblin_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_trapped_goblin";
		this.m.Title = "路上…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img]战团穿过了一些灌木丛，来到了一处林中空地，发现一只哥布林正蹲坐在地上。它转身看向了战团，呼吸很粗中，眼神也很昏暗。你看到它的小腿被一只巨大的捕熊夹夹住了。哥布林试图朝你们咆哮几声，然而只咳出了一些血。\n\n 在那只濒死的哥布林身边，是一位脸朝下倒在草地上的男子。他的臀部似乎有什么闪闪发光的东西，但你不确定那是什么。%randombrother%走到你身边。.%SPEECH_ON%可能是个陷阱。连环计之类的。这家伙的同类可能就在附近。如果我们就这样离开，或许他就会脱开这个夹子，然后告诉其他的怪物我们在这里。我们怎么办？%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "杀了它。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "B";
						}
						else
						{
							return "C";
						}
					}

				},
				{
					Text = "不管它。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 70)
						{
							return "D";
						}
						else
						{
							return "E";
						}
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_25.png[/img]无论如何，都不能让这只哥布林活下去。你准备走上前利落的终结了它的生命，然后再去看看旁边的那具尸体，想知道那闪光的东西到底是什么。那只绿皮怪物退缩了几步，咆哮着，而陷阱却让它动弹不得。%randombrother%拿着武器，小心地靠近它，仅靠一击就利落地消灭了那只怪物。\n\n 威胁被清除后，你翻过了那具尸体，带走了所有有价值的东西。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "又少了只需要处理的哥布林。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item;
				local r = this.Math.rand(1, 6);

				if (r == 1)
				{
					item = this.new("scripts/items/weapons/named/named_dagger");
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/weapons/rondel_dagger");
				}
				else if (r == 3)
				{
					item = this.new("scripts/items/weapons/dagger");
				}
				else if (r == 4)
				{
					item = this.new("scripts/items/weapons/knife");
				}
				else if (r == 5)
				{
					item = this.new("scripts/items/loot/golden_chalice_item");
				}
				else if (r == 6)
				{
					item = this.new("scripts/items/loot/silver_bowl_item");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_69.png[/img]这是场歼灭之战，不能让任何哥布林存活。你走入场地中，杀死了那个肮脏的家伙。威胁被清除后，你翻过了那具尸体，带走了所有有价值的东西。正当你准备离开时，树林边传来一阵咆哮声。%randombrother%拿着武器向前指去。%SPEECH_ON%食尸鬼！%SPEECH_OFF%该死！它们一定是闻到了哥布林尸体的气味，前来觅食的。其中有些家伙甚至还在用兽人的骨头剔牙……",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "这情况比预期得更混乱啊……",
					function getResult( _event )
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.BeastsTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Ghouls, this.Math.rand(70, 90), this.Const.Faction.Enemy);
						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item;
				local r = this.Math.rand(1, 6);

				if (r == 1)
				{
					item = this.new("scripts/items/weapons/named/named_dagger");
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/weapons/rondel_dagger");
				}
				else if (r == 3)
				{
					item = this.new("scripts/items/weapons/dagger");
				}
				else if (r == 4)
				{
					item = this.new("scripts/items/weapons/knife");
				}
				else if (r == 5)
				{
					item = this.new("scripts/items/loot/golden_chalice_item");
				}
				else if (r == 6)
				{
					item = this.new("scripts/items/loot/silver_bowl_item");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_25.png[/img]你可不想拿战团兄弟们的命去冒险，更别提那具尸体很可能并没有什么有价值的东西。保持着安全的距离，战团继续在森林中穿行着。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "得让战团保持良好状态，以应对更大的麻烦。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_48.png[/img]你可不想拿战团兄弟们的命去冒险，更别提那具尸体很可能并没有什么有价值的东西。保持着安全的距离，战团继续在森林中穿行着。\n\n 沿着路走还没到5分钟，你突然听见身后传来雷鸣般的脚步声。很显然，发出这震撼脚步声的家伙根本不介意被别人听到。你们弯腰躲藏了起来，毫不惊讶地，你们发现了一群兽人和哥布林穿过树林，出现在了眼前。其中一只哥布林，就是刚才你们弃置不管的那个家伙，它的腿上还捆着亚麻和树叶。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "该死的，那个小矮子发现我们了！",
					function getResult( _event )
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.GoblinsTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						properties.EnemyBanners = [
							"banner_goblins_03"
						];
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.GreenskinHorde, this.Math.rand(70, 90), this.Const.Faction.Enemy);
						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isGreenskinInvasion())
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d <= 5)
			{
				return;
			}
		}

		this.m.Score = 10;
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

