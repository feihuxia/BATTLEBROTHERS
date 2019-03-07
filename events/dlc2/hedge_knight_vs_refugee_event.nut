this.hedge_knight_vs_refugee_event <- this.inherit("scripts/events/event", {
	m = {
		HedgeKnight = null,
		Refugee = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.hedge_knight_vs_refugee";
		this.m.Title = "宿营间...";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_52.png[/img]%hedgeknight%雇佣骑士走向一个正在吃东西的难民。这位难民看到眼前的阴影，缓缓转过身来。%SPEECH_ON% 怎么了，伙计? %SPEECH_OFF% 雇佣骑士哼了一声，吐出一口浓痰。%SPEECH_ON%你逃离你燃烧的家，看着他们在你家里破坏而不是去反抗。现在佣兵队是你的家了，这次你还打算继续逃跑吗？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "喂, %hedgeknight%. 住手!",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "你可以自己处理这事儿！",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight.getImagePath());
				this.Characters.push(_event.m.Refugee.getImagePath());

				if (_event.m.OtherGuy != null)
				{
					this.Options.push({
						Text = "等下. %streetrat%, 你看起来有话要说？",
						function getResult( _event )
						{
							return "D";
						}

					});
				}
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_52.png[/img]你走上前去告诉雇佣骑士收敛些。佣兵队不是来打击他的自尊心的。 虎背熊腰的男人大笑着走开了。%SPEECH_ON%如您所说，先生，我也不想和废物在一起！%SPEECH_OFF%队伍里的人都大笑起来，只有难民继续盯着他的碗发呆，就像有人吐在里面一样。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧，我想这事儿已经解决了！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight.getImagePath());
				this.Characters.push(_event.m.Refugee.getImagePath());
				local bravery = this.Math.rand(1, 3);
				_event.m.Refugee.getBaseProperties().Bravery -= bravery;
				_event.m.Refugee.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Refugee.getName() + " 失去了 [color=" + this.Const.UI.Color.NegativeEventValue + "]-" + bravery + "[/color] 决心"
				});
				_event.m.Refugee.worsenMood(1.0, "Got humiliated in front of the company");

				if (_event.m.Refugee.getMoodState() <= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Refugee.getMoodState()],
						text = _event.m.Refugee.getName() + this.Const.MoodStateEvent[_event.m.Refugee.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_06.png[/img]你没有干预。雇佣骑士继续挖苦说道。%SPEECH_ON%我才不会在意你的痛苦，明白吗懦夫！%SPEECH_OFF% 难民抬起头来.%SPEECH_ON% 很好，懦夫你一点也不可怜！%SPEECH_OFF%难民扔掉盘子，拿起餐叉迅猛的扎向 %hedgeknight%的大腿，但是难民的叉子像被卡在树枝上一样无法抽出. 雇佣骑士把难民粗暴的摔在了地上，巨大的双手讲他的头颅压入泥土，肮脏的泥水涌入了这个可怜的人的口腔和鼻腔.休息中的佣兵都被吓得后退了一步。你走上前来，但是%hedgeknight%站起来并拉起了难民。%SPEECH_ON% 很好，爱逃跑的小家伙,你已经和你自己较量过了！%SPEECH_OFF% 他捡起自己的叉子，吐出口中的碎牙和血沫。%SPEECH_ON% 继续吃吗？很好，我用我的部分给你加倍，快来坐吧！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "很好！问题解决了！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight.getImagePath());
				this.Characters.push(_event.m.Refugee.getImagePath());
				local bravery = this.Math.rand(1, 3);
				_event.m.Refugee.getBaseProperties().Bravery += bravery;
				_event.m.Refugee.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Refugee.getName() + " 获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + bravery + "[/color] 决心"
				});
				_event.m.Refugee.improveMood(1.0, "Got some recognition from " + _event.m.HedgeKnight.getName());

				if (_event.m.Refugee.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Refugee.getMoodState()],
						text = _event.m.Refugee.getName() + this.Const.MoodStateEvent[_event.m.Refugee.getMoodState()]
					});
				}

				_event.m.HedgeKnight.improveMood(0.5, "Grew to like " + _event.m.Refugee.getName() + " some");

				if (_event.m.HedgeKnight.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.HedgeKnight.getMoodState()],
						text = _event.m.HedgeKnight.getName() + this.Const.MoodStateEvent[_event.m.HedgeKnight.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_80.png[/img]%streetrat% 走到前面，用手指着雇佣骑士。%SPEECH_ON%你觉得你是篝火的哪一部分，火焰还是火苗？。%SPEECH_OFF%哈哈哈哈。 %hedgeknight% 转过身，捏响自己的指关节。%SPEECH_ON%我当然知道。我是火焰！%SPEECH_OFF%他轻蔑的抱着双臂。%SPEECH_ON%对，你是火焰，但是我们也不是灰烬，我们是木柴！他已经为懦弱复出了高额的代价，你却用你的力量残忍揭露他的痛苦，这就像..就像一个肮脏妓女！%SPEECH_OFF%另一个佣兵也举起了手指。%SPEECH_ON%我认为我们都一样，我们都是佣兵。%SPEECH_OFF%另一个补充道%SPEECH_ON%你刚刚把你自己比喻成火焰？%SPEECH_OFF%%streetrat% 挠了挠他的脑袋。%SPEECH_ON%很好！刚刚雇佣骑士确实吓到我了，现在我没什么想说的了。%SPEECH_OFF%大家相视一笑，矛盾烟消云散。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "现在还要打架吗?",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight.getImagePath());
				this.Characters.push(_event.m.OtherGuy.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.OtherGuy.getID() || bro.getID() == _event.m.HedgeKnight.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 25)
					{
						bro.improveMood(1.0, "Felt entertained");

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

		local hedge_knight_candidates = [];
		local refugee_candidates = [];
		local other_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.hedge_knight")
			{
				hedge_knight_candidates.push(bro);
			}
			else if (bro.getBackground().getID() == "background.refugee")
			{
				refugee_candidates.push(bro);
			}
			else if (bro.getBackground().getID() == "background.vagabond" || bro.getBackground().getID() == "background.beggar" || bro.getBackground().getID() == "background.cripple" || bro.getBackground().getID() == "background.servant" || bro.getBackground().getID() == "background.ratcatcher")
			{
				other_candidates.push(bro);
			}
		}

		if (hedge_knight_candidates.len() == 0 || refugee_candidates.len() == 0)
		{
			return;
		}

		this.m.HedgeKnight = hedge_knight_candidates[this.Math.rand(0, hedge_knight_candidates.len() - 1)];
		this.m.Refugee = refugee_candidates[this.Math.rand(0, refugee_candidates.len() - 1)];
		this.m.Score = (hedge_knight_candidates.len() + refugee_candidates.len()) * 5;

		if (other_candidates.len() != 0)
		{
			this.m.OtherGuy = other_candidates[this.Math.rand(0, other_candidates.len() - 1)];
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"hedgeknight",
			this.m.HedgeKnight.getNameOnly()
		]);
		_vars.push([
			"refugee",
			this.m.Refugee.getName()
		]);
		_vars.push([
			"streetrat",
			this.m.OtherGuy != null ? this.m.OtherGuy.getName() : ""
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.HedgeKnight = null;
		this.m.Refugee = null;
		this.m.OtherGuy = null;
	}

});

