this.alp_nightmare2_event <- this.inherit("scripts/events/event", {
	m = {
		Addict = null,
		Other = null,
		Item = null
	},
	function create()
	{
		this.m.ID = "event.alp_nightmare2";
		this.m.Title = "During camp...";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]{你去查看库存，却发现 %addict% 瘫在那，半屁股坐在桶里，四肢都悬在桶上方。 他肚子上放着许多小瓶子。 他昏昏的盯着你，眼睛发红，眼眶发紫，好像所有的血都涌到了那里。 他妈的发生了什么事，你问。但 %addict% 只是微笑。%SPEECH_ON%做，嗝，做你该做的事。 呃，队长，因为我已经赢了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我只希望你能及时恢复正常。",
					function getResult( _event )
					{
						return "E";
					}

				},
				{
					Text = "马上给我停下，%addict%。",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "够了。 我要把这该死的恶魔从你身体里抽出来！",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Addict.getImagePath());
				this.List.push({
					id = 10,
					icon = "ui/items/" + _event.m.Item.getIcon(),
					text = "You lose " + _event.getArticle(_event.m.Item.getName()) + _event.m.Item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_38.png[/img]{你把 %addict% 带到一个专门的鞭打位。 他软趴趴的瘫在木头上， 手指张开，不时捏紧。 他看起来像在追蝴蝶， 当 %otherbrother% 用鞭子猛抽他的时候，他却一脸心不在焉的神情。\n\n 一开始，鞭打好像没有任何作用，甚至当它在男人的背上猛抽时，也不会留下深红色的新月疤痕。 但打了几鞭后，他醒了过来，并开始尖叫。 你转过身来问他，问他是否会戒瘾。他连忙点头。 你让他再挨鞭子，再问，他又点头。 又一个鞭打，又一个问题，又一个答案。最后 %otherbrother% 把鞭子收了起来。%SPEECH_ON%他死了，先生。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "什么？！给我看看！",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Addict.getImagePath());
				this.Characters.push(_event.m.Other.getImagePath());
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Addict.getName() + " 死了"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Addict.getID() || bro.getID() == _event.m.Other.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 50)
					{
						continue;
					}

					local mood = this.Math.rand(0, 1);
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[mood],
						text = bro.getName() + this.Const.MoodStateEvent[mood]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_39.png[/img]{你冲上前去把那个人的头抬起来，结果却发现那只是一个绑在长矛上的水壶。后退一步，你碰到了 %addict% ，他正在整理库存。%SPEECH_ON%你还好吧，队长？%SPEECH_OFF%你点了点头，问他药物储存如何。他咧嘴一笑。%SPEECH_ON%都数清了。我还要再数一遍吗%SPEECH_OFF%你告诉他去数点别的东西，然后去你的帐篷喝一杯。 转过身，一个苍白身影从一个板条箱旁移开。 你拔出剑去追赶，却发现只是一张被单在风中翻腾。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "也许我只是需要休闲。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Other.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_39.png[/img]{你把 %addict% 从桶里拉出来，并把他推到地上。 他迅速地转过身，大叫起来。%SPEECH_ON%咋回事啊，队长？！%SPEECH_OFF%这根本不是 %addict% 而是 %otherbrother%。你四处张望，看到 %addict% 在挥剑。远处有个苍白的身影在移动，但你一眨眼它就消失了。你把 %otherbrother% 拉起来，叫他当心强盗。他尽职尽责地点了点头，也许是感觉到你有什么不对劲，也许是不想因为一个错误而责备你。你回到帐篷里去喝一杯。}"
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "或许我需要马上睡一觉。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Other.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_05.png[/img]{你不去管他，但当你转过身去的那一刹那，你就听到了打碎玻璃的声音和打碎玻璃的人的漱口声。 转过身来，你发现 %addict% 弯着腰，脖子上挂着几条烂肉，他正在从裸露的喉咙里挑碎玻璃。你冲过去帮助他，用手捂住流血的伤口，你能感觉到他的喉咙在你的手指上抽搐，就像一条搁浅的鱼的嘴巴。那个人瘫倒在地，他的全身，他的死尸。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我应该采取一些行动……",
					function getResult( _event )
					{
						return "F";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Addict.getImagePath());
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Addict.getName() + " 死了"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Addict.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 66)
					{
						continue;
					}

					local mood = this.Math.rand(0, 1);
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[mood],
						text = bro.getName() + this.Const.MoodStateEvent[mood]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_39.png[/img]{你俯伏在地，心中蒙羞，以致于你追念从前亵渎旧神的日子。当你回头看的时候，你发现你的手指伸进了一个装满谷物的袋子里，里面的东西撒得到处都是。%SPEECH_ON%噢队长，这些东西我们还有用呢。%SPEECH_OFF%回头一看，你看到 %addict% 和一个站在他身后白色的影子。你匆忙地站起来，但是阴影却消失了。你找不到它，也找不到任何足迹。为了不让 %addict% 害怕，你让佣兵在附近留神戒备。你自己去帐篷里喝一杯。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "或许我需要喝两到三杯。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Addict.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		if (this.World.getTime().Days < 20)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates_addict = [];
		local candidates_other = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.addict"))
			{
				candidates_addict.push(bro);
			}
			else
			{
				candidates_other.push(bro);
			}
		}

		if (candidates_addict.len() == 0 || candidates_other.len() == 0)
		{
			return;
		}

		local items = this.World.Assets.getStash().getItems();
		local candidates_items = [];

		foreach( item in items )
		{
			if (item == null)
			{
				continue;
			}

			if (item.getID() == "misc.potion_of_knowledge" || item.getID() == "misc.antidote" || item.getID() == "misc.snake_oil" || item.getID() == "accessory.recovery_potion" || item.getID() == "accessory.iron_will_potion" || item.getID() == "accessory.berserker_mushrooms" || item.getID() == "accessory.cat_potion" || item.getID() == "accessory.lionheart_potion" || item.getID() == "accessory.night_vision_elixir")
			{
				candidates_items.push(item);
			}
		}

		if (candidates_items.len() == 0)
		{
			return;
		}

		this.m.Addict = candidates_addict[this.Math.rand(0, candidates_addict.len() - 1)];
		this.m.Other = candidates_other[this.Math.rand(0, candidates_other.len() - 1)];
		this.m.Item = candidates_items[this.Math.rand(0, candidates_items.len() - 1)];
		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"addict",
			this.m.Addict.getName()
		]);
		_vars.push([
			"otherbrother",
			this.m.Other.getName()
		]);
		_vars.push([
			"item",
			this.getArticle(this.m.Item.getName()) + this.m.Item.getName()
		]);
	}

	function onClear()
	{
		this.m.Addict = null;
		this.m.Other = null;
		this.m.Item = null;
	}

});

