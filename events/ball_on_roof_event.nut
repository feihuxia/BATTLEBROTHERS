this.ball_on_roof_event <- this.inherit("scripts/events/event", {
	m = {
		Surefooted = null,
		Other = null,
		OtherOther = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.ball_on_roof";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 140.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_97.png[/img]战团遇到了一个小孩子，他趴在树上，站在树枝边缘。他想把卡在屋顶上的球拿下来。并没有人来帮他。他看到你的时候，问你是否能帮他把球拿下来。似乎很简单。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们可以帮他。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 70)
						{
							return "Good";
						}
						else
						{
							return "Bad";
						}
					}

				}
			],
			function start( _event )
			{
				if (_event.m.Surefooted != null)
				{
					this.Options.push({
						Text = "%surefooted%，你真稳。帮他一下。",
						function getResult( _event )
						{
							return "Surefooted";
						}

					});
				}

				this.Options.push({
					Text = "我们没这个时间。",
					function getResult( _event )
					{
						return 0;
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "Good",
			Text = "[img]gfx/ui/events/event_97.png[/img]你让%otherbrother%把球拿下来。他把%otherother%当做凳子，然后够着屋顶，把玩具拿了下来。那个男孩十分高兴，脸上露出温暖的笑容，感染了雇佣兵。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "卖给撒马利亚人的是一把多好的剑啊。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Other.getImagePath());
				_event.m.Other.improveMood(1.0, "Helped a little boy");

				if (_event.m.Other.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Other.getMoodState()],
						text = _event.m.Other.getName() + this.Const.MoodStateEvent[_event.m.Other.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Bad",
			Text = "[img]gfx/ui/events/event_97.png[/img]你让%otherbrother%把球拿下来。他爬上树，通过树枝跳上屋顶。任务完成，他把球踢过去给那个男孩。糟糕的是，那孩子放开抓着树枝的双手去接球。他从树上滑下，从15英寸的高处掉下来。战团里的所有人都为他的掉落感到惋惜。你过去看的时候，他并没有任何动静，背已经摔断了。%otherother%朝着屋顶上的那个白痴大喊，%SPEECH_ON%你他妈在想什么？妈的！%SPEECH_OFF%雇佣兵从屋顶上下来。他看着那个孩子，然后紧张地看着地面。%SPEECH_ON%他，呃，他拿到球了不是么。我们出去吧。我们赶紧离开吧。我们的……我们的任务完成了。%SPEECH_OFF%这种情况真他妈烦人。你和战团赶紧趁父母还没回来离开了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "没人看见。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Other.getImagePath());
				this.Characters.push(_event.m.OtherOther.getImagePath());
				_event.m.Other.worsenMood(1.5, "Accidentally crippled a little boy");

				if (_event.m.Other.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Other.getMoodState()],
						text = _event.m.Other.getName() + this.Const.MoodStateEvent[_event.m.Other.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Surefooted",
			Text = "[img]gfx/ui/events/event_97.png[/img]%surefooted%清了清嗓子，走上前。%SPEECH_ON%我来当你的英雄，孩子。%SPEECH_OFF%他张开双手，那孩子跳下来。那孩子走到一边，佣兵指着地面，%SPEECH_ON%就待在这里。%SPEECH_OFF%雇佣兵爬上树，然后跳到屋顶。他拿起球，用一根手指旋转着，就像一阵小型龙卷风，然后优雅地落到狡辩。那个男孩兴奋地拍着手，拿着玩具，战团所有人几乎都被他的开心感染了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "炫耀。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Surefooted.getImagePath());
				_event.m.Surefooted.improveMood(1.5, "Impressed everyone with his talents");

				if (_event.m.Surefooted.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Surefooted.getMoodState()],
						text = _event.m.Surefooted.getName() + this.Const.MoodStateEvent[_event.m.Surefooted.getMoodState()]
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

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 4 && t.isAlliedWithPlayer())
			{
				nearTown = true;
				town = t;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates_surefooted = [];
		local candidates_other = [];

		foreach( b in brothers )
		{
			if (b.getSkills().hasSkill("trait.sure_footing"))
			{
				candidates_surefooted.push(b);
			}
			else
			{
				candidates_other.push(b);
			}
		}

		this.m.Other = candidates_other[this.Math.rand(0, candidates_other.len() - 1)];

		if (candidates_surefooted.len() != 0)
		{
			this.m.Surefooted = candidates_surefooted[this.Math.rand(0, candidates_surefooted.len() - 1)];
		}

		do
		{
			this.m.OtherOther = brothers[this.Math.rand(0, brothers.len() - 1)];
		}
		while (this.m.OtherOther == null || this.m.OtherOther.getID() == this.m.Other.getID());

		this.m.Town = town;
		this.m.Score = 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"otherbrother",
			this.m.Other.getName()
		]);
		_vars.push([
			"otherother",
			this.m.OtherOther.getName()
		]);
		_vars.push([
			"surefooted",
			this.m.Surefooted != null ? this.m.Surefooted.getName() : ""
		]);
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.Other = null;
		this.m.OtherOther = null;
		this.m.Surefooted = null;
		this.m.Town = null;
	}

});

