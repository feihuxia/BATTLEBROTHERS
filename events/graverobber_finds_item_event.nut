this.graverobber_finds_item_event <- this.inherit("scripts/events/event", {
	m = {
		Graverobber = null,
		Historian = null,
		UniqueItemName = null,
		NobleName = null
	},
	function create()
	{
		this.m.ID = "event.graverobber_finds_item";
		this.m.Title = "路上…";
		this.m.Cooldown = 9999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_33.png[/img]气候不错。一个美好的夜晚，如果要说有问题的话，那就是月亮的位置：橘色的圆圈在云中时隐时现 - 云层被微风吹拂着形成人畜无害的形状。月亮的边缘是那么的明亮，让你不禁怀疑是不是有花要开了，差点就把这月光当成日光了。你在想飞蛾、苍蝇和甲壳虫看到这个月亮之后会不会向奔向蜡烛和火把一样奔向月亮。他们会那么绝望吗？发觉之后是多么的残忍，当你所有的和大自然比起来，你就什么也没有什么也不是……那样发觉之后会带来如此的仇恨，如此的嫉妒……\n\n 突然，%graverobber%盗墓者出现在你身边，他身上的气味马上充斥着你的思维。他几乎就不能算是个人，几乎就是个魔像，浑身泥浆，布满青草，两只白色的眼睛伸了出来。你叹了口气，问他想干什么。他一手举得高高的，另一只手拿着一把铁锹。%SPEECH_ON%继续挖几个坟墓。找到了点东西，而且我说的不是一般出现在坟墓里的东西。想看看吗？%SPEECH_OFF%你当然想了……",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们看看……",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Graverobber.getImagePath());

				if (_event.m.Historian != null)
				{
					this.Options.push({
						Text = "咱们去把%historian%历史学家叫来吧，他肯定了解这些被埋葬的宝物。",
						function getResult( _event )
						{
							return "C";
						}

					});
				}
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_33.png[/img]%graverobber%带你来到地面上的一个大洞。骷髅的上半身在地步，手臂放松地搭在土上，就好像是在那睡了一夜一样。空洞的眼窝看着你。盗墓者蹲下去抓住了某样东西。他擦掉了上面的泥巴和虫子，然后交给了你。%SPEECH_ON%我觉得我们可以用上它。%SPEECH_OFF%你点点头，但是让他赶紧在别人看见之后把坟墓填上。",
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
				this.Characters.push(_event.m.Graverobber.getImagePath());
				local r = this.Math.rand(1, 8);
				local item;

				if (r == 1)
				{
					item = this.new("scripts/items/weapons/bludgeon");
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/weapons/falchion");
				}
				else if (r == 3)
				{
					item = this.new("scripts/items/weapons/knife");
				}
				else if (r == 4)
				{
					item = this.new("scripts/items/weapons/dagger");
				}
				else if (r == 5)
				{
					item = this.new("scripts/items/weapons/shortsword");
				}
				else if (r == 6)
				{
					item = this.new("scripts/items/weapons/woodcutters_axe");
				}
				else if (r == 7)
				{
					item = this.new("scripts/items/weapons/scramasax");
				}
				else if (r == 8)
				{
					item = this.new("scripts/items/weapons/hand_axe");
				}

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
			Text = "[img]gfx/ui/events/event_33.png[/img]一边看着东西，%historian%精明的学者和历史学家一边挤在你身边。他摸了摸下巴，然后发出微弱的嗡嗡声。%SPEECH_ON%是的，是的……%SPEECH_OFF%你转向他然后问是怎么回事。他打了个响指然后指向盗墓者发现的东西。他解释道，那并不是普通的胸甲和武器，而是著名的战士、贵族、好色之徒%noblename%的装备。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真有趣。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Historian.getImagePath());
				local item;
				local i = this.Math.rand(1, 8);

				if (i == 1)
				{
					item = this.new("scripts/items/shields/named/named_bandit_kite_shield");
				}
				else if (i == 2)
				{
					item = this.new("scripts/items/shields/named/named_bandit_heater_shield");
				}
				else if (i == 3)
				{
					item = this.new("scripts/items/shields/named/named_dragon_shield");
				}
				else if (i == 4)
				{
					item = this.new("scripts/items/shields/named/named_full_metal_heater_shield");
				}
				else if (i == 5)
				{
					item = this.new("scripts/items/shields/named/named_golden_round_shield");
				}
				else if (i == 6)
				{
					item = this.new("scripts/items/shields/named/named_red_white_shield");
				}
				else if (i == 7)
				{
					item = this.new("scripts/items/shields/named/named_rider_on_horse_shield");
				}
				else if (i == 8)
				{
					item = this.new("scripts/items/shields/named/named_wing_shield");
				}

				item.m.Name = _event.m.UniqueItemName;
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
		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates_graverobber = [];
		local candidates_historian = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.graverobber")
			{
				candidates_graverobber.push(bro);
			}
			else if (bro.getBackground().getID() == "background.historian")
			{
				candidates_historian.push(bro);
			}
		}

		if (candidates_graverobber.len() == 0)
		{
			return;
		}

		this.m.Graverobber = candidates_graverobber[this.Math.rand(0, candidates_graverobber.len() - 1)];

		if (candidates_historian.len() != 0)
		{
			this.m.Historian = candidates_historian[this.Math.rand(0, candidates_historian.len() - 1)];
		}

		this.m.Score = 5;
	}

	function onPrepare()
	{
		this.m.NobleName = this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)];
		this.m.UniqueItemName = this.m.NobleName + "\'s Shield";
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"graverobber",
			this.m.Graverobber.getName()
		]);
		_vars.push([
			"historian",
			this.m.Historian != null ? this.m.Historian.getNameOnly() : ""
		]);
		_vars.push([
			"noblename",
			this.m.NobleName
		]);
		_vars.push([
			"uniqueitem",
			this.m.UniqueItemName
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Graverobber = null;
		this.m.Historian = null;
		this.m.UniqueItemName = null;
		this.m.NobleName = null;
	}

});

