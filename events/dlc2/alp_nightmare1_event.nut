this.alp_nightmare1_event <- this.inherit("scripts/events/event", {
	m = {
		Victim = null,
		Other = null
	},
	function create()
	{
		this.m.ID = "event.alp_nightmare1";
		this.m.Title = "During camp...";
		this.m.Cooldown = 300.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]{男人正在营火旁谈话，突然 %spiderbro% 尖叫着跳了起来。 他向后一跳，在营火的照耀下，你看到一只头盔大小的蜘蛛落在了他的靴子上!}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "来个人把它砍了！",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "把它给我烧了！",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Victim.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_26.png[/img]{你拔出你的剑，但是 %otherbro% 已经抢先一步。 他勉强地向 %spiderbro% 大喊让他站着别动。但是这个全副武装的佣兵把他的剑举得太高了，直接砍向了这个男子的脖子。无头尸体弯曲着倒下，小队的其他成员在恐惧和愤怒中尖叫。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "What the fuck!",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Victim.getImagePath());
				this.Characters.push(_event.m.Other.getImagePath());
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Victim.getName() + " 死了"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Victim.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 50)
					{
						continue;
					}

					local mood = this.Math.rand(0, 1);
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[mood],
						text = bro.getName() + this.Const.MoodStateEvent[mood]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_39.png[/img]{你跑向 %otherbro% 想把他掐死, 结果你的手好像什么都没抓住，眼前不过是一团黑雾。你的没刹住车，冲向地面。%SPEECH_ON%呃，队长你没事吧？%SPEECH_OFF%你回头看,一个非常健康的 %spiderbro% 就坐在营火边。远处，一个苍白而光滑的东西从树干上滑了下来。 你一眨眼睛，它就不见了。 你让其他人注意周围的情况，然后回到你的帐篷里，摇着头，捏着眼睛。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真是个噩梦。",
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
			ID = "D",
			Text = "[img]gfx/ui/events/event_26.png[/img]{%spiderbro% 点点头，僵硬地走向营火，小蜘蛛抬头用奇怪的信任眼神看着他。 他把那活物放在坑里，立刻把它点着了起初，你认为他做到了, 他干得很漂亮，但这只燃烧的的小蜘蛛飞快地爬上了男人的裤腿,把他的衣服点着，并且闪到了他的头上。着火后，那个男人伸出双手，开始四处求救。野兽用毒牙咬进它的头骨，尖叫声戛然而止，佣兵像木头一样掉进了篝火里。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "把他的尸体弄出来！",
					function getResult( _event )
					{
						return "E";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Victim.getImagePath());
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Victim.getName() + " 死了"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Victim.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 50)
					{
						continue;
					}

					local mood = this.Math.rand(0, 1);
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[mood],
						text = bro.getName() + this.Const.MoodStateEvent[mood]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_39.png[/img]{你对雇佣兵大喊，让他们做自己该做的事， 但当你跳向营火和 %spiderbro% 时，那里有余烬和火花，当它们熄灭时，你发现佣兵静静地坐在火焰旁边。%SPEECH_ON%呃，队长，你说什么了吗%SPEECH_OFF%环顾四周，你发现队伍里其他人都在闲聊。 而当你回头看向 %spiderbro% 时，你似乎看到一个白色的影子从他身后经过，但再一看，它就不见了。 你吩咐弟兄们要警惕入侵者，然后回到你的帐篷。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我需要多休息。",
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
	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		if (this.World.getTime().Days < 20)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		this.m.Victim = brothers[this.Math.rand(0, brothers.len() - 1)];
		local other_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getID() != this.m.Victim.getID())
			{
				other_candidates.push(bro);
			}
		}

		this.m.Other = other_candidates[this.Math.rand(0, other_candidates.len() - 1)];
		this.m.Score = 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"spiderbro",
			this.m.Victim.getName()
		]);
		_vars.push([
			"otherbro",
			this.m.Other.getName()
		]);
	}

	function onClear()
	{
		this.m.Victim = null;
		this.m.Other = null;
	}

});

