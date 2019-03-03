this.giant_tree_in_forest_event <- this.inherit("scripts/events/event", {
	m = {
		Monk = null
	},
	function create()
	{
		this.m.ID = "event.giant_tree_in_forest";
		this.m.Title = "路上…";
		this.m.Cooldown = 200.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img]你穿过一道灌木丛组成的墙发现你自己停留在一道景观前面。把它称之为树似乎是侮辱。它周围的树那么的矮小他们就像是弯下身去，像是对宗主国宣誓效忠， 就像是人类那么粗的根须在下面， 上面的阴影似乎遮蔽了天地分不出白天黑夜感觉不到时间。\n\n 你走到巨大的基座下面并且用手在它的树皮上划过， 但是之后你停下来， 害怕你的肉体会侵犯神圣的地方就像一个顽皮的小孩踏入到一个神圣的教堂。%monk% 孙女走到你身边点头他的手牢牢的放在他的背上。%SPEECH_ON%这是一棵神树。树根深入大地直到神灵的国度。据说他们曾经在倾听， 但是现在... 我们不是很确定。%SPEECH_OFF%你看着那个男人，他摆出一个要后退的姿势，问他是否怕这棵树。他对你笑了笑然后摆着头。%SPEECH_ON%我尊敬他就像一个男人尊敬大海， 大海里面有很多让人害怕的东西， 但是， 水手还是会起航。如果说大海是一个温顺的野兽， 是不是人类让他这么可爱？%SPEECH_OFF%",
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
				_event.m.Monk.improveMood(2.0, "Saw a godtree with his own eyes");

				if (_event.m.Monk.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Monk.getMoodState()],
						text = _event.m.Monk.getName() + this.Const.MoodStateEvent[_event.m.Monk.getMoodState()]
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

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 6)
			{
				return false;
			}
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local monk_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.monk" || bro.getBackground().getID() == "background.monk_turned_flagellant")
			{
				monk_candidates.push(bro);
			}
		}

		if (monk_candidates.len() == 0)
		{
			return;
		}

		this.m.Monk = monk_candidates[this.Math.rand(0, monk_candidates.len() - 1)];
		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"monk",
			this.m.Monk.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Monk = null;
	}

});

