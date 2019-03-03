this.brawler_vs_brawler_event <- this.inherit("scripts/events/event", {
	m = {
		Brawler1 = null,
		Brawler2 = null
	},
	function create()
	{
		this.m.ID = "event.brawler_vs_brawler";
		this.m.Title = "营地…";
		this.m.Cooldown = 45.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]你和大家坐在火堆边，大家开始大声讨论起来。%brawler%站起来指着自己的胸膛，大声笑道，%SPEECH_ON%你？你以为自己能打倒我？%SPEECH_OFF%另一名格斗家，%brawler2%跳过来，%SPEECH_ON%打倒你？我完全可以把你揍趴下，白痴！%SPEECH_OFF%因为大家说%brawler%的拳头不足以打碎别人的下巴，这才引起一场搏斗。两个格斗家一只手抓住对方，另一只手放在对方的腰上。疯狂地用拳头出击。没有人承受如此伤害之后还能站起来，但这两个人似乎没有伤到丝毫。你命令战团阻止他们两打斗。\n\n%brawler%捏住另一个人的鼻孔，后者马上流血了。他耸耸肩。%SPEECH_ON%一点点冲突而已，先生。%SPEECH_OFF%%brawler2%点点头，%SPEECH_ON%是啊，没有伤害彼此。%SPEECH_OFF%你看着他们两握了握手，拍了拍彼此的肩膀，向对方表示祝贺。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这是一种和好的办法。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Brawler1.getImagePath());
				this.Characters.push(_event.m.Brawler2.getImagePath());

				if (this.Math.rand(1, 100) <= 50)
				{
					local injury1 = _event.m.Brawler1.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury1.getIcon(),
						text = _event.m.Brawler1.getName() + " suffers " + injury1.getNameOnly()
					});
				}
				else
				{
					_event.m.Brawler1.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Brawler1.getName() + " suffers light wounds"
					});
				}

				_event.m.Brawler1.improveMood(2.0, "Bonded with " + _event.m.Brawler2.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Brawler1.getMoodState()],
					text = _event.m.Brawler1.getName() + this.Const.MoodStateEvent[_event.m.Brawler1.getMoodState()]
				});

				if (this.Math.rand(1, 100) <= 50)
				{
					local injury2 = _event.m.Brawler2.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury2.getIcon(),
						text = _event.m.Brawler2.getName() + " suffers " + injury2.getNameOnly()
					});
				}
				else
				{
					_event.m.Brawler2.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Brawler2.getName() + " suffers light wounds"
					});
				}

				_event.m.Brawler2.improveMood(2.0, "Bonded with " + _event.m.Brawler1.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Brawler2.getMoodState()],
					text = _event.m.Brawler2.getName() + this.Const.MoodStateEvent[_event.m.Brawler2.getMoodState()]
				});
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.brawler")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() < 2)
		{
			return;
		}

		local idx = this.Math.rand(0, candidates.len() - 1);
		this.m.Brawler1 = candidates[idx];
		candidates.remove(idx);
		idx = this.Math.rand(0, candidates.len() - 1);
		this.m.Brawler2 = candidates[idx];
		this.m.Score = candidates.len() * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"brawler",
			this.m.Brawler1.getNameOnly()
		]);
		_vars.push([
			"brawler2",
			this.m.Brawler2.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Brawler1 = null;
		this.m.Brawler2 = null;
	}

});

