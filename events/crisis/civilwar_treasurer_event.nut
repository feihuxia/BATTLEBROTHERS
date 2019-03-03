this.civilwar_treasurer_event <- this.inherit("scripts/events/event", {
	m = {
		NobleHouse = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_treasurer";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 40.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_72.png[/img]行军路上，你碰到了一个被穿着得体的男人囚禁在了对话之中的一个农民。看见你之后，农民就喊了出来。%SPEECH_ON%先生，请帮帮我！这个司库想要拿走我的庄稼！%SPEECH_OFF%司库点了点头，看上去这里没有发生什么罪行啊。%SPEECH_ON%对的。我是从%noblehouse%来的，我来这是为了收集军队补给。这是我们的土地，所以这也是我们的庄稼。%SPEECH_OFF%战争的绞肉机越来越糟了……%randombrother%问你想要怎么做。",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "放开那可怜的农民！",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "关你屁事。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "你们两个都给我滚开。食物现在是我们的了！",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_72.png[/img]尽管到的在这个战争游戏中并没有什么大戏份，你还是不禁在想这个可怜的农民什么也没有做错啊。你抓住了司库的衣服，把他摁在了农舍的一堵墙上。他的眼睛都放大了，就像是你刚刚穿透了某种无敌的面纱一样。%SPEECH_ON%你以为你在做什么？%SPEECH_OFF%你松开了手，因为虽然这个男人有可能不是无敌的，但是他的名字背后还是有一个无敌的靠山的。%SPEECH_ON%告诉你的人这个农民没有什么好提供的。这个季节的庄稼长的很不好，懂了吗？%SPEECH_OFF%你把一只手放在了剑柄上。男人瞟了一眼你手里的剑，然后快速地点了点头。%SPEECH_ON%好吧，我懂了。%SPEECH_OFF%农民由心地感谢了你，顺便也给了你他的食物储配里的几代谷物。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "我们今天做了点好事。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "You threatened one of their treasurers");
				this.World.Assets.addMoralReputation(1);
				local food = this.new("scripts/items/supplies/ground_grains_item");
				this.World.Assets.getStash().add(food);
				this.World.Assets.updateFood();
				this.List.push({
					id = 10,
					icon = "ui/items/" + food.getIcon(),
					text = "你获得了" + food.getName()
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().getID() == "background.farmhand" && this.Math.rand(1, 100) <= 50)
					{
						bro.improveMood(0.25, "You helped a farmer in peril");

						if (bro.getMoodState() >= this.Const.MoodState.Neutral)
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
			Text = "[img]gfx/ui/events/event_72.png[/img]虽然你为农民感到难过，但是感情在贵族家族之间的战争期间并没有什么意义。你决定不牵涉进去。当司库的手下们将成袋的谷物搬上马车的时候，他过来找你聊天。%SPEECH_ON%我会向贵族们诉说你在这里的，高贵的选择的。你本来可以捣乱的，但是你没有。谢谢你，佣兵。我们的军队里的人们需要这些粮食救命。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "好吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "You respected the authority of one of their treasurers");
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_72.png[/img]乍一看，似乎只有两个选项，但是当一名佣兵不受道德感，责任感，以及任何种类的社会枷锁束缚之后，你选择了第三条路：为你和你的手下夺取食物。司库和农民们都表达了自己的抗议，但是你的手下们拔出了剑，这真是迅速结束任何种类争论的好方法。\n\n 但是，其实本来就没有多少东西好拿，而且平民们和贵族们都会来找你麻烦了。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "我们得先照顾好自己。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "You threatened one of their treasurers");
				this.World.Assets.addMoralReputation(-2);
				local maxfood = this.Math.rand(2, 3);

				for( local i = 0; i < maxfood; i = ++i )
				{
					local food = this.new("scripts/items/supplies/ground_grains_item");
					this.World.Assets.getStash().add(food);
					this.World.Assets.updateFood();
					this.List.push({
						id = 10,
						icon = "ui/items/" + food.getIcon(),
						text = "你获得了" + food.getName()
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isCivilWar())
		{
			return;
		}

		if (!this.World.State.getPlayer().getTile().HasRoad)
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();
		local towns = this.World.EntityManager.getSettlements();
		local bestDistance = 9000;
		local bestTown;

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d <= bestDistance)
			{
				bestDistance = d;
				bestTown = t;
				break;
			}
		}

		if (bestTown == null)
		{
			return;
		}

		this.m.NobleHouse = bestTown.getOwner();
		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"noblehouse",
			this.m.NobleHouse.getName()
		]);
	}

	function onClear()
	{
		this.m.NobleHouse = null;
	}

});

