this.addict_steals_potion_event <- this.inherit("scripts/events/event", {
	m = {
		Addict = null,
		Other = null,
		Item = null
	},
	function create()
	{
		this.m.ID = "event.addict_steals_potion";
		this.m.Title = "在扎营时...";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]{你去战团的仓库里检查库存，结果发现 %addict% 四肢朝天，屁股朝下陷在桶里。有好多瓶药水进了丫的肚子。他转过头望向你，双眼黯淡无神，充满血丝，眼窝因为过度充血而发紫。你质问他在这搞什么飞机，而 %addict% 的回复只有傻笑。%SPEECH_ON%您，呃，您爱咋咋地，队长，嗝——反正我已经喝了个爽了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "但愿时间能让你康复过来。",
					function getResult( _event )
					{
						return 0;
					}

				},
				{
					Text = "你现在就给我停下， %addict%.",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 33 ? "C" : "D";
					}

				},
				{
					Text = "够了，老子要用鞭子把这瘾头从你脑子里抽出去！",
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
					text = "你失去了 " + _event.getArticle(_event.m.Item.getName()) + _event.m.Item.getName()
				});
				local items = this.World.Assets.getStash().getItems();

				foreach( i, item in items )
				{
					if (item == null)
					{
						continue;
					}

					if (item.getID() == _event.m.Item.getID())
					{
						items[i] = null;
						break;
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_38.png[/img]{你把 %addict% 带到专门负责鞭刑的地方。他软趴趴的躺倒在木板上，手指不断地松开又握紧。他看起来好像在追蝴蝶玩，而且他这神志不清的状态在 %otherbrother% 一鞭子狠抽在他身上时也没有改变。\n\n 起初，鞭刑看起来没有起到任何作用，即使它将那瘾君子的后背抽得鲜血淋漓。但在几次鞭笞之后，他清醒了过来，并且开始惨叫。你走过去面对他，询问他会不会戒掉自己的药瘾，他慌忙点头。你又抽了他一鞭子，又一次询问，他又一次点头，再然后是再一次鞭笞，再一次询问，再一次回答。如此循环往复，直到他再也承受不住，以及你可以肯定他的毛病已经彻底消失为止。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让他滚出我的视线。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Addict.getImagePath());
				_event.m.Addict.addLightInjury();
				this.List = [
					{
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Addict.getName() + " 受伤了"
					}
				];
				_event.m.Addict.getSkills().removeByID("trait.addict");
				this.List.push({
					id = 10,
					icon = "ui/traits/trait_icon_29.png",
					text = _event.m.Addict.getName() + " 不再上瘾"
				});
				_event.m.Addict.worsenMood(2.5, "在你的命令下受了鞭刑");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Addict.getMoodState()],
					text = _event.m.Addict.getName() + this.Const.MoodStateEvent[_event.m.Addict.getMoodState()]
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Addict.getID())
					{
						continue;
					}

					if (!bro.getBackground().isOffendedByViolence() || bro.getLevel() >= 7)
					{
						continue;
					}

					bro.worsenMood(1.0, "对你用鞭刑处罚 " + _event.m.Addict.getName() + " 的决定感到震惊");

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

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]{你把 %addict% 从桶里拽出来砸到地上。他摇摇晃晃的，好像他正躺在楼梯的最高阶往下看一样。%SPEECH_ON%喔，小心点，队长，这地方晃晃悠悠的！%SPEECH_OFF%起初你想狠踹这饭桶一脚，但最后决定宽容一些。你在他旁边蹲下，他翻过身来看着云彩。时间流逝，过了一会儿， %addict% 撅起嘴唇，你看见清澈重新回到了他的双眼中。%SPEECH_ON%我有点……心事，队长。%SPEECH_OFF%你点点头，告诉他别再一直嗑药了，不然你没法信任这种状态下的他。如果他对自己身为一个雇佣兵有什么想法，如果那就是他为什么这么干的话，那可以理解，但这种行为对战团来说是个问题。他再次撅起嘴唇，然后点点头。%SPEECH_ON%谢谢你，队长。我会尽我所能把事情干好，不让那些吊事继续影响我的。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "说得好",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Addict.getImagePath());
				_event.m.Addict.getSkills().removeByID("trait.addict");
				this.List.push({
					id = 10,
					icon = "ui/traits/trait_icon_62.png",
					text = _event.m.Addict.getName() + " 不再上瘾"
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_05.png[/img]{你把 %addict% 从桶里拽出来砸到地上。他摇摇晃晃的，好像他正躺在楼梯的最高阶往下看一样。%SPEECH_ON%喔，小心点，队长，这地方晃晃悠悠的！%SPEECH_OFF%起初你想狠踹这饭桶一脚，但最后决定宽容一些。你在他旁边蹲下，他翻过身来看着云彩。时间流逝，过了一会儿，他转过头来。%SPEECH_ON%你是想帮我吗？%SPEECH_OFF%你点头给出肯定的回复，但 %addict% 傻笑起来摇了摇头。%SPEECH_ON%我没跟你说话，我是在跟它说话！%SPEECH_OFF%他指向你身后的桶。而当你回头看的时候，那家伙已经站起来冲过去了。%SPEECH_ON%你个狗养的死肥婆臭婊子，少跟老子来这出！%SPEECH_OFF%那家伙冲过去把桶砸得稀烂，桶里的东西被弄坏，乱七八糟的洒了一地。几个雇佣兵在你检查损失的时候冲过来架走了那家伙。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真该死。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Addict.getImagePath());
				local items = this.World.Assets.getStash().getItems();
				local candidates = [];

				foreach( i, item in items )
				{
					if (item == null || item.isItemType(this.Const.Items.ItemType.Legendary) || item.isItemType(this.Const.Items.ItemType.Named))
					{
						continue;
					}

					if (item.isItemType(this.Const.Items.ItemType.Misc))
					{
						candidates.push(i);
					}
				}

				if (candidates.len() != 0)
				{
					local i = candidates[this.Math.rand(0, candidates.len() - 1)];
					this.List.push({
						id = 10,
						icon = "ui/items/" + items[i].getIcon(),
						text = "你失去了 " + items[i].getName()
					});
					items[i] = null;
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Unhold)
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
		this.m.Score = candidates_addict.len() * 10;
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

