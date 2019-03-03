this.dogs_dig_up_loot_event <- this.inherit("scripts/events/event", {
	m = {
		FoundItem = null
	},
	function create()
	{
		this.m.ID = "event.dogs_dig_up_loot";
		this.m.Title = "路上…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_27.png[/img]在路上，你的战犬突然开始奔逃然后开始挖地。你不确定是为什么，因为你不记得给过它们骨头。过了一会，它们开始争抢所为的%finding%。你打断了这个拔河比赛，拿走了物品。猎犬们发出呜呜的怨声，但是几个乖一点的安静了下来。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好孩子。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.getStash().add(_event.m.FoundItem);
				this.List.push({
					id = 10,
					icon = "ui/items/" + _event.m.FoundItem.getIcon(),
					text = "你获得了" + _event.getArticle(_event.m.FoundItem.getName()) + _event.m.FoundItem.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		local numWardogs = 0;
		local brothers = this.World.getPlayerRoster().getAll();

		foreach( bro in brothers )
		{
			local item = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory);

			if (item != null && (item.getID() == "accessory.wardog" || item.getID() == "accessory.armored_wardog"))
			{
				numWardogs = ++numWardogs;
			}
		}

		if (numWardogs < 2)
		{
			local stash = this.World.Assets.getStash().getItems();

			foreach( item in stash )
			{
				if (item != null && (item.getID() == "accessory.wardog" || item.getID() == "accessory.armored_wardog"))
				{
					numWardogs = ++numWardogs;

					if (numWardogs >= 2)
					{
						break;
					}
				}
			}
		}

		if (numWardogs < 2)
		{
			return;
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
		local item;
		local r = this.Math.rand(1, 10);

		if (r == 1)
		{
			item = this.new("scripts/items/weapons/wooden_stick");
		}
		else if (r == 2)
		{
			item = this.new("scripts/items/armor/tattered_sackcloth");
		}
		else if (r == 3)
		{
			item = this.new("scripts/items/helmets/aketon_cap");
		}
		else if (r == 4)
		{
			item = this.new("scripts/items/helmets/hood");
		}
		else if (r == 5)
		{
			item = this.new("scripts/items/helmets/cultist_hood");
		}
		else if (r == 6)
		{
			item = this.new("scripts/items/helmets/full_leather_cap");
		}
		else if (r == 7)
		{
			item = this.new("scripts/items/armor/ragged_surcoat");
		}
		else if (r == 8)
		{
			item = this.new("scripts/items/armor/noble_tunic");
		}
		else if (r == 9)
		{
			item = this.new("scripts/items/armor/thick_tunic");
		}
		else if (r == 10)
		{
			item = this.new("scripts/items/armor/wizard_robe");
		}

		item.setCondition(this.Math.max(1, item.getConditionMax() * this.Math.rand(10, 40) * 0.01));
		this.m.FoundItem = item;
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"finding",
			this.getArticle(this.m.FoundItem.getName()) + this.m.FoundItem.getName()
		]);
	}

	function onClear()
	{
		this.m.FoundItem = null;
	}

});

