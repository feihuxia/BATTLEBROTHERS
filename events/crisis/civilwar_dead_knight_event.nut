this.civilwar_dead_knight_event <- this.inherit("scripts/events/event", {
	m = {
		Thief = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_dead_knight";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_97.png[/img]你正好碰上一群孩子在抢夺草地上的什么东西，那架势就像苍蝇围着屎堆一样。%randombrother%开始踢他们，赶他们离开。%SPEECH_ON%快滚。走开！妈的。先生，来看看吧！%SPEECH_OFF%一个脸蛋胖乎乎的孩子对你喊。%SPEECH_ON%我先发现的！是我的！%SPEECH_OFF%你轻松推开他，看了一眼。草地上有个死去的骑士，毫无疑问，他在这里有一阵子了。蚂蚁在盔甲上乱爬，它发出了微弱的滴滴声。小女孩捏住鼻子。她护着鼻子，声音尖细，用了些机敏的外交手段。%SPEECH_ON%让他们拿走吧，罗比！这些人很危险！不是吗？你们是不是很危险？%SPEECH_OFF%%randombrother%拔出武器，夸张地挥舞着。%SPEECH_ON%小丫头说得没错！你们最好放弃，别等我们像对付这骑士一样让你们吃土！就是这样，我们就是杀人凶手，现在回来看看自己的杰作！%SPEECH_OFF%孩子们尖叫着哭喊着，像灌木丛里的小鸟一样分散开去。罗比落在了后面，对自己丢失的宝物恋恋不舍。你跟佣兵说没必要这样吓他们。他耸耸肩，开始收集骑士的装置。",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "还有用。",
					function getResult( _event )
					{
						if (_event.m.Thief != null)
						{
							return "Thief";
						}
						else
						{
							return 0;
						}
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/helmets/faction_helm");
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
			ID = "Thief",
			Text = "[img]gfx/ui/events/event_97.png[/img]%thief%看了看罗比，你注意到他已经开始出汗了。佣兵伸出一根手指。%SPEECH_ON%你不止是垃圾，孩子。你在衣服下面藏了什么？你不想骗一个小偷吧，来吧，拿出来！%SPEECH_OFF%罗比叹着气拎起衣服，一堆克朗掉到了草地上。男人点点头。%SPEECH_ON%我就知道是这样。你可以走了。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "眼神不错。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Thief.getImagePath());
				local money = this.Math.rand(30, 150);
				this.World.Assets.addMoney(money);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] 克朗"
				});
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

		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();
		local nearTown = false;

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 10 && t.getTile().getDistanceTo(playerTile) >= 4 && t.isAlliedWithPlayer())
			{
				nearTown = true;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.thief" || bro.getSkills().hasSkill("trait.eagle_eyes"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() != 0)
		{
			this.m.Thief = candidates[this.Math.rand(0, candidates.len() - 1)];
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"thief",
			this.m.Thief != null ? this.m.Thief.getName() : ""
		]);
	}

	function onClear()
	{
		this.m.Thief = null;
	}

});

