this.broken_cart_event <- this.inherit("scripts/events/event", {
	m = {
		Injured = null
	},
	function create()
	{
		this.m.ID = "event.broken_cart";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_55.png[/img]你前进的时候，看到路边站着一个人，他身边是一辆破旧的马车。马车旁边站着一头驴，显得十分颓废。商人的样子要好一些，你的出现似乎吓到他了。他跳起来，后退一步。%SPEECH_ON%你是来抢我东西的吗？如果是这样，请不要杀我。要什么就拿走吧。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "赶紧去那辆货车上拿一些我们需要的东西吧！",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "我们来帮你修理马车吧。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 70 ? "B" : "C";
					}

				},
				{
					Text = "我们没这个时间。",
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
			ID = "B",
			Text = "[img]gfx/ui/events/event_55.png[/img]你让他放心，并让%companyname%其他人帮忙把马车移到路上。他们动作十分迅速，商人似乎被他们的效率给震惊了。他的马车回到路上后，他从车上拿出一些补给表示感谢。这些补给品在接下来的路程中很有用。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "再见。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(2);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.List = _event.giveStuff(1);
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_55.png[/img]商人看到你之后吓坏了，不过你迅速打消了他的疑虑。你让几个人把他的马车移回路上。他们动作十分迅速，不过结束后，其中一个人突然大叫地弯下身子。\n\n商人的眼里重新出现恐惧的神情，马上给你一些补给表示感谢。难道他认为你会责怪他吗？不管怎样，补给还是很受欢迎的。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "希望一切值得。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(2);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Injured.getImagePath());
				local injury = _event.m.Injured.addInjury(this.Const.Injury.Helping);
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Injured.getName() + " suffers " + injury.getNameOnly()
					}
				];
				this.List.extend(_event.giveStuff(1));
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_55.png[/img]你让他们搜索马车，寻找有用的东西。%randombrother%拔出剑，似乎想杀死那头驴，这只愚蠢的动物直挺挺地看着刀。商人大声哭喊着，你了下来，%SPEECH_ON%别杀那头驴。%SPEECH_OFF%你的人站在商人身后，他向你表示感谢，货物都被你们拿走了。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿好东西，我们该走了。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-2);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.List = _event.giveStuff(3);
			}

		});
	}

	function giveStuff( _mult )
	{
		local result = [];
		local gaveSomething = false;

		if (this.Math.rand(1, 100) <= 50)
		{
			gaveSomething = true;
			local food = this.new("scripts/items/supplies/bread_item");
			this.World.Assets.getStash().add(food);
			result.push({
				id = 10,
				icon = "ui/items/" + food.getIcon(),
				text = "你获得了" + food.getName()
			});
		}

		if (this.Math.rand(1, 100) <= 50)
		{
			gaveSomething = true;
			local amount = this.Math.rand(1, 10) * _mult;
			this.World.Assets.addArmorParts(amount);
			result.push({
				id = 10,
				icon = "ui/icons/asset_supplies.png",
				text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + amount + "[/color] 工具和补给。"
			});
		}

		if (this.Math.rand(1, 100) <= 50)
		{
			gaveSomething = true;
			local amount = this.Math.rand(1, 5) * _mult;
			this.World.Assets.addMedicine(amount);
			result.push({
				id = 10,
				icon = "ui/icons/asset_medicine.png",
				text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + amount + "[/color] 医疗补给。"
			});
		}

		if (!gaveSomething)
		{
			local food = this.new("scripts/items/supplies/bread_item");
			this.World.Assets.getStash().add(food);
			result.push({
				id = 10,
				icon = "ui/items/" + food.getIcon(),
				text = "你获得了" + food.getName()
			});
		}

		return result;
	}

	function onUpdateScore()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( b in brothers )
		{
			if (!b.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				candidates.push(b);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Injured = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = 9;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
		this.m.Injured = null;
	}

});

