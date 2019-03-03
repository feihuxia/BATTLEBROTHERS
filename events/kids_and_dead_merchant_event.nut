this.kids_and_dead_merchant_event <- this.inherit("scripts/events/event", {
	m = {
		HedgeKnight = null
	},
	function create()
	{
		this.m.ID = "event.kids_and_dead_merchant";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_97.png[/img]你发现一个小孩，他的脖子上带着一根异常华丽的项链。那条链子太重了，以至于他的头向前弯曲，但是这一点点小挣扎也没能抹去他脸上大大的微笑。%randombrother%把那个小孩推倒，拿走了项链。%SPEECH_ON%你是从哪里得到这个的？%SPEECH_OFF%那个小孩大哭了起来，想要拿回自己的宝贝，但是他大约才三英尺高，长得太矮了。%SPEECH_ON%嘿，那是我的！还给我！%SPEECH_OFF%另一个小孩走了过来，手上戴着一枚硕大的戒指，那枚戒指太大了以至于他能一次塞进两根手指。好吧。够了。整个战团呈扇形散开，最终在森林线的一棵高树上找到了一个死去的商人。他的脸已经泛紫，浑身都是骨折。看上去他已经死透了。\n\n 一帮四五十岁的年轻人从树林里出现，每个人手里都捏着一块石头。他们的领导者，一个一头红发，手臂上纹身的小个子问你想干什么。你告诉他说你要拿走这个商人的货物。那个领导者笑了起来。%SPEECH_ON%哦，是吗？我再给你几秒钟时间重新想想，没错，先生！%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们要拿走这些货物。",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
				if (_event.m.HedgeKnight != null)
				{
					this.Options.push({
						Text = "你有什么要说的吗，%hedgeknight%？",
						function getResult( _event )
						{
							return "HedgeKnight";
						}

					});
				}

				this.Options.push({
					Text = "后退，老兄。",
					function getResult( _event )
					{
						return 0;
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_97.png[/img]尽管在你眼前的是一支小型的军队，但是这些货物已经被下令收回。那个指挥这次行动的小孩子尖叫着发出战吼，那声音与其说是像正在死亡的猫，倒不如说是潜水的鹰发出的声音。%SPEECH_ON%拿下他们！扔！扔！扔起来！%SPEECH_OFF%在他的指挥之下，那群小孩开始从树林线扔起了石头。剑士们联合了起来，用盾牌形成了乌龟一样的阵型，慢慢向前移动。这是种奇怪的尝试，就像是骗局游戏的大师把自己的杯子罩在球上，但是战团成功地获取了商人的货物，慢慢退出了战场，从始至终都在受到各个方向的投掷袭击。那个领头的小孩朝你挥了挥自己的拳头。你朝他竖了竖手指，开始回到看到商人货物的那条路上。%randombrother%盯着奖励的同时，擦了擦额头上的伤痕。%SPEECH_ON%该死的，老兄。我从没有见过如此激烈的军队。我为未来那些和这些小姑娘小伙子决斗的人感到悲伤。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那些小混蛋着实让我们吃了点苦头。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/loot/signet_ring_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.Math.rand(50, 200);
				this.World.Assets.addMoney(item);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + item + "[/color] 克朗"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 25)
					{
						if (this.Math.rand(1, 100) <= 66)
						{
							local injury = bro.addInjury(this.Const.Injury.Brawl);
							this.List.push({
								id = 10,
								icon = injury.getIcon(),
								text = bro.getName() + " suffers " + injury.getNameOnly()
							});
						}
						else
						{
							bro.addLightInjury();
							this.List.push({
								id = 10,
								icon = "ui/icons/days_wounded.png",
								text = bro.getName() + " suffers light wounds"
							});
						}
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "HedgeKnight",
			Text = "[img]gfx/ui/events/event_35.png[/img]%hedgeknight%向前走了一步，朝前挥了挥武器。他朝那些孩子挥舞着手中的武器。%SPEECH_ON%啊，所以你们想当小强盗或者英雄之类的狗屁？很好。很不错。但是我会看着谁第一个扔石头。他，还是她，谁这么干的会感受一下我生气的时候会发生些什么。然后在你们其他人看到之后，我会把你们杀掉。我还会跟着你们的脚印回家，找到你们的家人，砍下他们的脑袋。%SPEECH_OFF%鬼鬼祟祟的骑士停了下来，怒目圆睁。%SPEECH_ON%那么，你们谁会扔第一块石头呢？%SPEECH_OFF%那个领头冲锋的小孩举起了手，说道。%SPEECH_ON%让他们走吧。比起跟这些旅行者争吵，我们还有更重要的事情要做。%SPEECH_OFF%嘿，那可真是明智之举。有这样忍气吞声的机智，那个红头发的小混蛋或许会在将来领导起一支真正的战团。但是如今是你的时代。你拿走了商人的货物，离开了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "小混蛋。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight.getImagePath());
				local item = this.new("scripts/items/loot/signet_ring_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.Math.rand(50, 200);
				this.World.Assets.addMoney(item);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + item + "[/color] 克朗"
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

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates_hedgeknight = [];

		foreach( b in brothers )
		{
			if (b.getBackground().getID() == "background.hedge_knight")
			{
				candidates_hedgeknight.push(b);
			}
		}

		if (candidates_hedgeknight.len() != 0)
		{
			this.m.HedgeKnight = candidates_hedgeknight[this.Math.rand(0, candidates_hedgeknight.len() - 1)];
		}

		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"hedgeknight",
			this.m.HedgeKnight != null ? this.m.HedgeKnight.getNameOnly() : ""
		]);
		_vars.push([
			"hedgeknighfull",
			this.m.HedgeKnight != null ? this.m.HedgeKnight.getName() : ""
		]);
	}

	function onClear()
	{
		this.m.HedgeKnight = null;
	}

});

