this.broken_wagon_in_swamp_event <- this.inherit("scripts/events/event", {
	m = {
		Butcher = null
	},
	function create()
	{
		this.m.ID = "event.broken_wagon_in_swamp";
		this.m.Title = "路上…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_09.png[/img]旅行中碰到沼泽可不是什么好事。从烟雾和倒下的树判断，这里显然居住着许多有魔力的东西。至少那些德鲁伊会这么说。你在这里发现了几匹被淹死的马，还有一辆坠毁的马车。%randombrother%穿过这些废弃物，成功找到了一些东西。%SPEECH_ON%嗯，还不错。应该是不久前留下的。可能是被这里的某个东西给吓坏了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "还有用。",
					function getResult( _event )
					{
						if (_event.m.Butcher != null)
						{
							return "Butcher";
						}
						else
						{
							return 0;
						}
					}

				}
			],
			function start( _event )
			{
				local amount = this.Math.rand(5, 15);
				this.World.Assets.addArmorParts(amount);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_supplies.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + amount + "[/color] 工具和补给。"
				});
			}

		});
		this.m.Screens.push({
			ID = "Butcher",
			Text = "[img]gfx/ui/events/event_14.png[/img]%SPEECH_ON%先生，等等。%SPEECH_OFF%前屠夫%butcher%说。他走上前，开始砍其中一匹马的尸体。他砍下几块肉，用树叶包好，然后用灰尘和盐把它们弄干，之后交给你。%SPEECH_ON%别把这些给浪费了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你确定这东西能吃？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Butcher.getImagePath());
				local item = this.new("scripts/items/supplies/strange_meat_item");
				this.World.Assets.getStash().add(item);
				item = this.new("scripts/items/supplies/strange_meat_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		if (currentTile.Type != this.Const.World.TerrainType.Swamp)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.butcher")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() != 0)
		{
			this.m.Butcher = candidates[this.Math.rand(0, candidates.len() - 1)];
		}

		this.m.Score = 9;
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"butcher",
			this.m.Butcher != null ? this.m.Butcher.getName() : ""
		]);
	}

	function onClear()
	{
		this.m.Butcher = null;
	}

});

