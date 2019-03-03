this.come_across_burial_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.come_across_burial";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 130.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_28.png[/img]在路上的时候，你看到一群人挤在一堆泥土面前。靠近后你发现他们正在举行葬礼。其中一个人看着你。%SPEECH_ON%你认识他吗？你和他一起战斗过吗？%SPEECH_OFF%你摇摇头，穿过人群去看那个人。你发现那个人很老。他胸膛上放着一把非常锋利，闪闪发光的长剑，那个人的双手握着剑柄。%randombrother%站在你身边，小声说道。%SPEECH_ON%那把武器真好看啊，我就说说的。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们把它拿过来吧。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 35 ? "B" : "C";
					}

				},
				{
					Text = "别管他们了。",
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
			Text = "[img]gfx/ui/events/event_36.png[/img]你拔出自己的剑，其他人也一样。雇佣兵把人群挤到后面，没遇到什么反抗。其中一个人走上前来。%SPEECH_ON%你想要那把剑，是吧？拿走吧。他有提到过像你这样的人。他说你会更需要这把剑。%SPEECH_OFF%你把剑收回，问他这是否就是他们聚集在一起的原因。那个人笑了笑。%SPEECH_ON%不，他还说过他拥有不会死呢，所以我们想知道，不知道他说的话哪些是真的。%SPEECH_OFF%你慢慢把剑拿起来，不知道是否会像传说中那样，碰到这把剑的人都会死掉。还好，这家伙没说过这样的话。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "他也用不着这把剑了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/weapons/longsword");
				item.setCondition(27.0);
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_28.png[/img]你穿过人群，拿起那个死人的剑。其中一个人尖叫着。%randombrother%一拳就把那家伙打倒了。战团其他人拔出武器，防止还有人反抗。一位老妇人刺穿长剑，不停地颤抖。%SPEECH_ON%先生，那不是你的东西，把它放回去。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "它现在是我的了。",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "那个老太婆说得对，我们不该打扰葬礼。",
					function getResult( _event )
					{
						return "E";
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(-1);
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_36.png[/img]你让那个老太婆闭嘴，赶紧去死。死人的剑已经放入你的物品栏，%companyname%重新上路。\n\n那些农民很伤心，大声哭喊着，并说你们的所作所为马上就会传开。你只是笑了笑，并表示很欣赏他们的想象力。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "世界就是这样。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(-3);
				local item = this.new("scripts/items/weapons/longsword");
				item.setCondition(27.0);
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_28.png[/img]你重新把剑放回死者的手中。老妇人点点头。%SPEECH_ON%看来这个世界上还是有好人，愿意听从智者的教诲。%SPEECH_OFF%其中一个农民向你致敬，其他人也跟着他这样做。似乎在外行人看来，把武器拿起来，然后又放回去，是一种表达敬意的方式。或许你应该经常假装盗窃。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "反正我们也用不着。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(5);
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		if (this.World.getTime().Days <= 15)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		if (currentTile.Type == this.Const.World.TerrainType.Snow || currentTile.Type == this.Const.World.TerrainType.Forest || currentTile.Type == this.Const.World.TerrainType.LeaveForest || currentTile.Type == this.Const.World.TerrainType.SnowyForest)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		this.m.Score = 2;
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

