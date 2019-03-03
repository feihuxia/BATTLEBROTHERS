this.player_plays_dice_event <- this.inherit("scripts/events/event", {
	m = {
		Gambler = null,
		PlayerDice = 0,
		GamblerDice = 0
	},
	function create()
	{
		this.m.ID = "event.player_plays_dice";
		this.m.Title = "营地…";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_62.png[/img]在经历了一天的行军后，%gambler%在休息时间拿着两个骰子和一个杯子朝你走来。他问你想不想玩个小游戏。规则很简单：你来摇骰子，谁的点数高，就算谁赢。这完全是凭运气的游戏！每次的赌注为二十五克朗。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们玩！",
					function getResult( _event )
					{
						_event.m.Gambler.improveMood(1.0, "Has played a game of dice with you");
						_event.m.PlayerDice = this.Math.rand(3, 18);
						_event.m.GamblerDice = this.Math.rand(3, 18);

						if (_event.m.PlayerDice == _event.m.GamblerDice)
						{
							return "D";
						}
						else if (_event.m.PlayerDice > _event.m.GamblerDice)
						{
							return "C";
						}
						else
						{
							return "B";
						}
					}

				},
				{
					Text = "我没这个时间。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Gambler.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_62.png[/img]你摇了骰子，得到%playerdice%点。\n\n接下来轮到了%gambler%，他摇出了%gamblerdice%点。\n\n{嗯，你输了。赌徒取回了骰子，还有你那二十五克朗赌资，并询问你愿不愿意再来一把。| 看来骰子没站在你这边，赌徒拿走了所有的赌资。他抬头看着你，脸上带着笑容%SPEECH_ON%想再来一轮吗？%SPEECH_OFF% | 数字是加起来的，也就是说，你输了。赌徒问你愿不愿意再来一次。| 输了！或许下一次，你就能……| 你输了！摇骰子很简单，输掉也很简单。不过在这里输掉可比在战场上好很多。赌徒问你愿不愿意再来一次。| 神并没有眷顾你和你的骰子。输掉这场赌局只不过是小事，但你的自尊心受到的打击要比这二十五克朗高一些。你想再来一次吗？| 命运让你失去了二十五克朗。或许下一次你能吧它们赢回来？| 你注视着滚动的骰子。一个本来能赢的点数在你眼皮低下变成了让你输掉的点数。赌徒大笑着问你愿不愿意再来一次。| 你玩骰子的手法堪称完美！可是你为什么会输掉呢？就是因为那几点，他最后才赢的！你摇了摇头，犹豫着是不是要再来一把。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们再来一次！",
					function getResult( _event )
					{
						_event.m.PlayerDice = this.Math.rand(3, 18);
						_event.m.GamblerDice = this.Math.rand(3, 18);

						if (_event.m.PlayerDice == _event.m.GamblerDice)
						{
							return "D";
						}
						else if (_event.m.PlayerDice > _event.m.GamblerDice)
						{
							return "C";
						}
						else
						{
							return "B";
						}
					}

				},
				{
					Text = "我受够了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Gambler.getImagePath());
				this.World.Assets.addMoney(-25);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你失去了[color=" + this.Const.UI.Color.NegativeEventValue + "]25[/color]克朗"
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_62.png[/img]你摇了骰子，得到%playerdice%点。\n\n接下来轮到了%gambler%，他摇出了%gamblerdice%点。\n\n{你赢了！赌徒拍了拍手。%SPEECH_ON%看来是新手走了狗屎运！%SPEECH_OFF%你将双手叉在胸前。%SPEECH_ON%这难道不是一场仅仅依靠运气的游戏吗？%SPEECH_OFF%赌徒笑了笑，然后问你是否准备再来试一把。| 赌徒朝后靠去。%SPEECH_ON%唉，我真是倒霉。我们再来！%SPEECH_OFF% | 赌徒朝后靠去。%SPEECH_ON%{唉，我今天的手气就像屎一样臭 | 看来今天神明没有站在我这一边 | 我真是倒大霉了 | 我怎么这么不走运 | 真是不幸啊，至少对我来说是这样 | 噢，这把看来有戏 | 我要输成穷光蛋了 | 真他妈倒霉 | 手气烂到家了 | 我就像是干了修女一样倒霉 | 这可是大师级的一掷 | 你这运气简直是犯规 | 愿%randomtown%成为兽人 | 谁说瞎眼松鼠找不到坚果吃 | 我真是倒了八辈子霉}，你赢了！我们再来一把！%SPEECH_OFF% | 你赢了！你大笑着拿走赢下的钱并询问赌徒是否想再来一把。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们再来一次！",
					function getResult( _event )
					{
						_event.m.PlayerDice = this.Math.rand(3, 18);
						_event.m.GamblerDice = this.Math.rand(3, 18);

						if (_event.m.PlayerDice == _event.m.GamblerDice)
						{
							return "D";
						}
						else if (_event.m.PlayerDice > _event.m.GamblerDice)
						{
							return "C";
						}
						else
						{
							return "B";
						}
					}

				},
				{
					Text = "我受够了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Gambler.getImagePath());
				this.World.Assets.addMoney(25);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你赢得了[color=" + this.Const.UI.Color.PositiveEventValue + "]25[/color]克朗"
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_62.png[/img]你摇了骰子，得到%playerdice%点。\n\n接下来轮到了%gambler%，他摇出了%gamblerdice%点。\n\n一样的数字。是平局！再来一把吗？",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们再来一次！",
					function getResult( _event )
					{
						_event.m.PlayerDice = this.Math.rand(3, 18);
						_event.m.GamblerDice = this.Math.rand(3, 18);

						if (_event.m.PlayerDice == _event.m.GamblerDice)
						{
							return "D";
						}
						else if (_event.m.PlayerDice > _event.m.GamblerDice)
						{
							return "C";
						}
						else
						{
							return "B";
						}
					}

				},
				{
					Text = "我受够了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Gambler.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getMoney() <= 100)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.gambler" || bro.getBackground().getID() == "background.vagabond" || bro.getBackground().getID() == "background.thief" || bro.getBackground().getID() == "background.raider")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Gambler = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"gambler",
			this.m.Gambler.getName()
		]);
		_vars.push([
			"playerdice",
			this.m.PlayerDice
		]);
		_vars.push([
			"gamblerdice",
			this.m.GamblerDice
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Gambler = null;
		this.m.PlayerDice = 0;
		this.m.GamblerDice = 0;
	}

});

