this.hunt_food_event <- this.inherit("scripts/events/event", {
	m = {
		Hunter = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.hunt_food";
		this.m.Title = "路上…";
		this.m.Cooldown = 7.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_10.png[/img]{就在你帮%otherguy%把靴子拔出淤泥的时候，%hunter%从一个树丛中钻出，身上挂着差不多一打活兔子。他将这些兔子放在地上，然后逐一解开绑在它们身上的绳子。这些小兔子，虽然看上去很可怜，但却是不可多得的美味。猎人其中一只兔子拎起，扭断它的脖子，然后迅速掏空它的内脏。他不断重复这一动作，直至将所有兔子都处理完毕。然后，他在%otherguy%的披风上擦了擦手，然后指了指脚下已经被剖空的兔子。%SPEECH_ON%那堆是可以吃的。%SPEECH_OFF%然后他又指了指被丢弃在一旁的兔子内脏。%SPEECH_ON%那堆是不能吃的。明白吗？很好。%SPEECH_OFF%  | %hunter%在几个小时前就离开队伍走在前面，而你们现在才赶上他。他的脚下踩着一头死鹿，鹿的胸前插着一支箭。在你走近之后，他笑着走了下来。他说，如果有其他弟兄能帮忙抬一抬，他就可以剥鹿皮、准备鹿肉。| 森林中的鸟儿在战团行进途中叽叽喳喳地唱个不停。阳光透过树叶形成的缝隙投射在地面上，形成了一片片光斑。你看到一只松鼠正沐浴在阳光下，享用着一颗美味的松果。突然，它停了下来，似乎意识到了你正在看着他。它的身体开始颤抖，紧接着一团血从它身内溅到你的脸上。待你抹掉脸上的血之后，你才发现那只松鼠已经被一支箭牢牢钉在树上。它的身体依旧在抽搐着，似乎在进行最后的挣扎。%hunter%突然从树丛中钻出，脸上带着笑容，手上还拿着一把弓。猎人取回自己的猎物，然后把它与其他猎物放在一起。猎人的身上挂满了各种各样战利品，一些来自于他的朋友，一些来自于他的敌人。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "都是美味啊。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Hunter.getImagePath());
				local food = this.new("scripts/items/supplies/cured_venison_item");
				this.World.Assets.getStash().add(food);
				this.List = [
					{
						id = 10,
						icon = "ui/items/" + food.getIcon(),
						text = "你获得了鹿肉"
					}
				];
				_event.m.Hunter.improveMood(0.5, "Has hunted successfully");

				if (_event.m.Hunter.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Hunter.getMoodState()],
						text = _event.m.Hunter.getName() + this.Const.MoodStateEvent[_event.m.Hunter.getMoodState()]
					});
				}
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

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.hunter" || bro.getBackground().getID() == "background.poacher")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Hunter = candidates[this.Math.rand(0, candidates.len() - 1)];

		foreach( bro in brothers )
		{
			if (bro.getID() != this.m.Hunter.getID())
			{
				this.m.OtherGuy = bro;
				this.m.Score = candidates.len() * 10;
				break;
			}
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"hunter",
			this.m.Hunter.getName()
		]);
		_vars.push([
			"otherguy",
			this.m.OtherGuy.getName()
		]);
	}

	function onClear()
	{
		this.m.Hunter = null;
		this.m.OtherGuy = null;
	}

});

