this.hedge_knight_vs_raider_event <- this.inherit("scripts/events/event", {
	m = {
		HedgeKnight = null,
		Raider = null
	},
	function create()
	{
		this.m.ID = "event.hedge_knight_vs_raider";
		this.m.Title = "营地…";
		this.m.Cooldown = 70.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]%raider%坐在篝火旁，，他的眼睛，痴痴的看着火焰。你回来之前， ，有几个人，在那里朝他大叫。过去作为，掠夺者，他没有太多的朋友。雇佣骑士， %hedgeknight%， ，走过去，站在他旁边。当他们交换目光的时候，你正在担心，会突然爆发一场你无法阻止的战斗。反而雇佣骑士，坐了下来。他沉静地说，尽管他深沉的声音，仍然听起来非常可怕。%SPEECH_ON%你袭击了海边，是吗？杀死了女人和孩子？从教堂那里偷东西？%SPEECH_OFF%掠夺者点头。%SPEECH_ON%是的，还有更坏的。%SPEECH_OFF%%hedgeknight% 从湖里面，拿起一块燃烧的木头。他用手把它挤碎，火焰嘶哑的变成灰烬和烟雾。他用充满老茧的手把它弄得粉碎。%SPEECH_ON%你不应该理会其他人的话，掠夺者。真的很讨厌，饥饿的世界，而你也要注意他的牙齿。让弱者哭泣并且死去。我们只能武装我们自己，弥漫死亡的妒忌，会高兴地把一个婴儿的头颅砸碎，只是因为想要从我们的肺脏中吸一口。%SPEECH_OFF%掠夺者，抓起一块柴火，磨起来。他们握了一下手什么都没说。",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这个世界钟爱强者。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight.getImagePath());
				this.Characters.push(_event.m.Raider.getImagePath());
				_event.m.HedgeKnight.improveMood(1.0, "Bonded with " + _event.m.Raider.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.HedgeKnight.getMoodState()],
					text = _event.m.HedgeKnight.getName() + this.Const.MoodStateEvent[_event.m.HedgeKnight.getMoodState()]
				});
				_event.m.Raider.improveMood(1.0, "Bonded with " + _event.m.HedgeKnight.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Raider.getMoodState()],
					text = _event.m.Raider.getName() + this.Const.MoodStateEvent[_event.m.Raider.getMoodState()]
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

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local hedge_knight_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.hedge_knight")
			{
				hedge_knight_candidates.push(bro);
			}
		}

		if (hedge_knight_candidates.len() == 0)
		{
			return;
		}

		local raider_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.raider")
			{
				raider_candidates.push(bro);
			}
		}

		if (raider_candidates.len() == 0)
		{
			return;
		}

		this.m.HedgeKnight = hedge_knight_candidates[this.Math.rand(0, hedge_knight_candidates.len() - 1)];
		this.m.Raider = raider_candidates[this.Math.rand(0, raider_candidates.len() - 1)];
		this.m.Score = (hedge_knight_candidates.len() + raider_candidates.len()) * 3;
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
			"raider",
			this.m.Raider.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.HedgeKnight = null;
		this.m.Raider = null;
	}

});

