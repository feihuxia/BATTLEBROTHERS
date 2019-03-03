this.monk_vs_monk_event <- this.inherit("scripts/events/event", {
	m = {
		Monk1 = null,
		Monk2 = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.monk_vs_monk";
		this.m.Title = "营地…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]啊，篝火周围最适合聊天了。人们都在享用着啤酒和食物。突然之间，两个人的谈话打破了这融洽的气氛。这并不是因为他们的声音比别人大，而是因为他们两人的身份：僧侣%monk1%和%monk2%正在对神学理论进行深入探讨。\n\n虽然你所受的教育不足以让你明白他们所讨论的高深理论，但你明白愤怒地指着另一个人的脸或是圣经肯定是一个非常不礼貌的行为，这样做必定会挑起事端。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这与我无关。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 50 ? "B" : "C";
					}

				},
				{
					Text = "佣兵战团没有资格讨论宗教！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk1.getImagePath());
				this.Characters.push(_event.m.Monk2.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]一开始，你试图阻止这场争论演变成一场斗殴，但你突然想到这已经不是你第一次看到两位针锋相对的神学家了。因此，这种情况是很正常的。于是你决定放任他们继续争论。没过多久，他们的音调逐渐增高，他们的脸也离书本越来越近。他们开始相互推搡，不停地争夺书本的使用权。终于，%monk1%站了起来，指着一些句子说道。%SPEECH_ON%看那里！就是那里！‘人来自于泥土’，不是‘人来自于血液’。人不可能从血液中产生，人本身就是血！人怎么可能自己产生自己呢？明白吗？%SPEECH_OFF%%monk2%挠了挠自己的下巴，点了点头，但又踢出了新的问题。%SPEECH_ON%如果……%SPEECH_OFF%在他还没说完时，%monk1%猛力合上书然后将双手举起。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这位神学家避免了另一场危机。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk1.getImagePath());
				this.Characters.push(_event.m.Monk2.getImagePath());
				_event.m.Monk1.improveMood(1.0, "Had a stimulating discourse on religious matters");

				if (_event.m.Monk1.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Monk1.getMoodState()],
						text = _event.m.Monk1.getName() + this.Const.MoodStateEvent[_event.m.Monk1.getMoodState()]
					});
				}

				_event.m.Monk2.improveMood(1, "Had a stimulating discourse on religious matters");

				if (_event.m.Monk2.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Monk2.getMoodState()],
						text = _event.m.Monk2.getName() + this.Const.MoodStateEvent[_event.m.Monk2.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_06.png[/img]这已经不是你第一次看到两个僧侣在争论了。上一次争吵中，一位辩论者迅速解决了事端。所以这次你觉得会发生同样的事情。只不过，这次的情况有所不同了。他们的声音开始越变越大。你真没想到僧侣的言语也能变得如此刻薄。粗鲁和下流已经不足以用来形容他们两个相互之间的侮辱言语了。几秒钟之后，他们两人已经扭打在地上，你不得不命令%otherguy%将他们拉开。\n\n看来，战团中的生活经历已经对这两个人造成了一些影响。他们已经不再是当初慈眉善目的僧侣了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我想这就是所谓的信仰危机。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk1.getImagePath());
				this.Characters.push(_event.m.Monk2.getImagePath());
				_event.m.Monk1.getBaseProperties().Bravery += 1;
				_event.m.Monk1.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Monk1.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] 决心"
				});
				_event.m.Monk2.getBaseProperties().Bravery += 1;
				_event.m.Monk2.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Monk2.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] 决心"
				});
				_event.m.Monk1.worsenMood(1.0, "Lost his composure and resorted to violence");

				if (_event.m.Monk1.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Monk1.getMoodState()],
						text = _event.m.Monk1.getName() + this.Const.MoodStateEvent[_event.m.Monk1.getMoodState()]
					});
				}

				_event.m.Monk2.worsenMood(1.0, "Lost his composure and resorted to violence");

				if (_event.m.Monk2.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Monk2.getMoodState()],
						text = _event.m.Monk2.getName() + this.Const.MoodStateEvent[_event.m.Monk2.getMoodState()]
					});
				}

				if (this.Math.rand(1, 100) <= 50)
				{
					_event.m.Monk1.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Monk1.getName() + " suffers light wounds"
					});
				}
				else
				{
					local injury = _event.m.Monk1.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Monk1.getName() + " suffers " + injury.getNameOnly()
					});
				}

				if (this.Math.rand(1, 100) <= 50)
				{
					_event.m.Monk2.addLightInjury();
					this.List.push({
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Monk2.getName() + " suffers light wounds"
					});
				}
				else
				{
					local injury = _event.m.Monk2.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Monk2.getName() + " suffers " + injury.getNameOnly()
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local monk_candidates = [];
		local other_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() < 3)
			{
				continue;
			}

			if (bro.getBackground().getID() == "background.monk")
			{
				monk_candidates.push(bro);
			}
			else
			{
				other_candidates.push(bro);
			}
		}

		if (monk_candidates.len() < 2)
		{
			return;
		}

		if (other_candidates.len() == 0)
		{
			return;
		}

		this.m.Monk1 = monk_candidates[this.Math.rand(0, monk_candidates.len() - 1)];
		this.m.Monk2 = null;
		this.m.OtherGuy = other_candidates[this.Math.rand(0, other_candidates.len() - 1)];

		do
		{
			this.m.Monk2 = monk_candidates[this.Math.rand(0, monk_candidates.len() - 1)];
		}
		while (this.m.Monk2 == null || this.m.Monk2.getID() == this.m.Monk1.getID());

		this.m.Score = monk_candidates.len() * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"monk1",
			this.m.Monk1.getNameOnly()
		]);
		_vars.push([
			"monk2",
			this.m.Monk2.getNameOnly()
		]);
		_vars.push([
			"otherguy",
			this.m.OtherGuy.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Monk1 = null;
		this.m.Monk2 = null;
		this.m.OtherGuy = null;
	}

});

