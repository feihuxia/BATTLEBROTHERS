this.undead_zombie_in_granary_event <- this.inherit("scripts/events/event", {
	m = {
		Town = null,
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.undead_zombie_in_granary";
		this.m.Title = "在 %town%...";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_79.png[/img]你遇到一个呼救的男子，如此歇斯底里以至于他都不管所招来的是不是无法无天的佣兵们。%SPEECH_ON%拜托了！救救我！有一具……一具尸体！在粮仓里！%SPEECH_OFF%他指着一个大型木制建筑。其前门恰好在这个时候咯吱作响。那个男人疯了。%SPEECH_ON%就是它！就是这怪物！拜托了，进去杀了它！我们不能失去那的全部粮食！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "最好烧掉粮仓。",
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
					Text = "我们中会有人进去处理的。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "D";
						}
						else
						{
							return "E";
						}
					}

				},
				{
					Text = "我们没时间。",
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
			Text = "[img]gfx/ui/events/event_30.png[/img]你抓着男人的肩膀盯着他开口道。%SPEECH_ON%我们要去烧掉粮仓。里面有粮食，你在听吗？仔细听我接下来要说的话。里面的粮食被感染了不能吃。没有要救的东西。%SPEECH_OFF%农民仿佛感冒似地发抖，走开了。他双手扶脸，几乎看不到你的两个佣兵走向前，手持火炬，点燃了粮仓。\n\n门突然停止声响，然后又开始，几乎打破了铰链。底部冒出一阵烟，有人开始呼喊。%SPEECH_ON%是场恶作剧！恶作剧！请让我出去！啊啊啊，啊啊啊！%SPEECH_OFF%%dude%冲向门然后将其拆掉。一个小男孩跑出来，身上都是火焰。他坐在地上，雇佣兵们想要盖住他，但太迟了。火焰被扑灭时他已经是一个阴燃的废墟了。农民看起来绝对是吓坏了。%SPEECH_ON%我……我不知道，我原以为……他不断发出咆哮的声音。%SPEECH_OFF%你摇摇头告诉战团赶快返回上路。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧，该死。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().isOffendedByViolence() && this.Math.rand(1, 100) <= 50)
					{
						bro.worsenMood(0.5, "You had a boy burned by accident");

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
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_30.png[/img]粮食到现在无疑是被感染了，整座建筑或许会被人类无法估量的邪恶物感染了。你慢慢地向男人解释你将烧掉他的粮仓。他没有就拒绝，只是飞快地点头。%SPEECH_ON%我知道。我猜我是不想亲自动手罢了，或许还幻想着有人能来告诉我一切还有救，而不是必须要被烧毁。%SPEECH_OFF%一些佣兵将火炬丢到粮仓角落，不久就火光冲天。但一分钟后整座建筑就开始燃烧了。当前门被破开时，一个亡灵冲出缝隙，它整个身体都被火焰包围。现在只剩下发黑的骨头了，皮肤上滴着粘液。%dude%快速砍下它的脑袋。农民看着建筑的其他部分崩塌，火焰照耀着他脸颊上的眼泪。%SPEECH_ON%好吧，看来就这样了。谢谢你，佣兵。%SPEECH_OFF%他给了你一些钱，而你则很乐意收下。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Gross.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
				this.World.Assets.addMoney(50);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]50[/color]克朗"
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_79.png[/img]你决定解决这个亡灵麻烦，就像是自己在野外碰到它一样。%dude%踢开了前门并刺杀了第一眼所看到的东西。不死者的尸体倾斜，那势头弯曲了剑上的尸体。然后你看到：血在剑身上缓缓流下。当佣兵回来时，光线显示那不是亡灵，而是一个小男孩的尸体。他睁大眼睛，手颤抖地抚着伤口。我只是在玩……%SPEECH_OFF%佣兵抽回武器。男孩倒下来。你转向那个农民。他绝望地紧握着双手。%SPEECH_ON%我……我不知道！他在发出响声！他不停地，我听到……咆哮声！他不停咆哮着，我不……%SPEECH_OFF%男人跪在地上。你看着这个死绝的男孩，当深红色的绳子困出伤口时肤色变得更白了。你摇着头告诉部下该在污秽的东西出现前继续上路。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "该死。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
				_event.m.Dude.worsenMood(2.0, "Killed a little boy by accident");

				if (_event.m.Dude.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Dude.getMoodState()],
						text = _event.m.Dude.getName() + this.Const.MoodStateEvent[_event.m.Dude.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_79.png[/img]你派%dude%进粮仓来对付它。他拍着自己的肩膀来放松。%SPEECH_ON%现在就杀一个亡灵。%SPEECH_OFF%佣兵踢开门冲了进去。一阵战斗的声响，刀光剑影中是他在与黑暗和邪恶交战。过了一会儿，他走出来，擦拭前额的汗水。%SPEECH_ON%搞定了。粮食上沾染了一些血迹，但剩下的还可以吃。%SPEECH_OFF%你转向农民然后伸出手。他吝啬地递给你一小袋钱。%SPEECH_ON%谢谢你……佣兵。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干得好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
				this.World.Assets.addMoney(50);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]50[/color]克朗"
					}
				];
				_event.m.Dude.improveMood(0.25, "Saved a peasant");

				if (_event.m.Dude.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Dude.getMoodState()],
						text = _event.m.Dude.getName() + this.Const.MoodStateEvent[_event.m.Dude.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local playerTile = this.World.State.getPlayer().getTile();
		local towns = this.World.EntityManager.getSettlements();
		local bestDistance = 9000;
		local bestTown;

		foreach( t in towns )
		{
			if (t.isMilitary() || t.getSize() > 2)
			{
				continue;
			}

			local d = playerTile.getDistanceTo(t.getTile());

			if (d < bestDistance)
			{
				bestDistance = d;
				bestTown = t;
			}
		}

		if (bestTown == null || bestDistance > 3)
		{
			return;
		}

		this.m.Town = bestTown;
		this.m.Dude = brothers[this.Math.rand(0, brothers.len() - 1)];
		this.m.Score = 25;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"town",
			this.m.Town.getName()
		]);
		_vars.push([
			"dude",
			this.m.Dude.getName()
		]);
	}

	function onClear()
	{
		this.m.Town = null;
		this.m.Dude = null;
	}

});

