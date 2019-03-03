this.houndmaster_tames_wolf_event <- this.inherit("scripts/events/event", {
	m = {
		Houndmaster = null
	},
	function create()
	{
		this.m.ID = "event.houndmaster_tames_wolf";
		this.m.Title = "路上…";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_08.png[/img]当穿越领土北方的积雪荒原时，驯兽师%houndmaster%驯化了一头一直跟随战团周围的狼。驯兽师不断地逗留到队尾，蹲下身子，双手放在身体两侧，注视着那只在队尾的孤狼。但是今天，他用一点剩下的肉，把那只野兽带到了战团中间。而现在，他蹲在它的身边，与它的显眼，肌肉发达的肌肉，尖尖的角，专注的耳朵以及长着杀人犬齿的嘴相比十分矮小。\n\n 其余的人站在自己的武器后面。其中一个人朝驯兽师大喊，让他停止正在做的事情。另一个人说狼能嗅到，恐惧的味道。还有一个人朝它扔石头。那只狼退缩了一下，但是没有作出任何反应。驯兽师笑着发出“呲！”的声音，一边指着它。那只狼往前走了一步，捡起那块石头，并把它交换到那个人的手里。他揉了揉那只野兽德鬓毛。%SPEECH_ON%你瞧，十分容易被驯服，它只是只狗而已。只不过跟狗相比更大，更快也更强壮。当然也更聪明。%SPEECH_OFF%它的眼神撞上了你的眼神。那只狼放低身子，就像一个人在鞠躬。%houndmaster%又笑了起来。%SPEECH_ON%瞧？它都已经知道谁是这个群落的老大了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真是只高贵的野兽。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Houndmaster.getImagePath());
				local item = this.new("scripts/items/accessory/wolf_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				_event.m.Houndmaster.improveMood(2.0, "Managed to tame a wolf");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Houndmaster.getMoodState()],
					text = _event.m.Houndmaster.getName() + this.Const.MoodStateEvent[_event.m.Houndmaster.getMoodState()]
				});
			}

		});
	}

	function onUpdateScore()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Snow)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 5 && bro.getBackground().getID() == "background.houndmaster")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Houndmaster = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 6;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"houndmaster",
			this.m.Houndmaster.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Houndmaster = null;
	}

});

