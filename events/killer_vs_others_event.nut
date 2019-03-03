this.killer_vs_others_event <- this.inherit("scripts/events/event", {
	m = {
		Killer = null,
		OtherGuy1 = null,
		OtherGuy2 = null
	},
	function create()
	{
		this.m.ID = "event.killer_vs_others";
		this.m.Title = "营地…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_06.png[/img]就在你准备开始研究一些潦草的地图时，你听到了刺耳的金属碰撞声。你将地图收好，开始寻找这声音的源头。\n\n%killerontherun%正被一位弟兄按在膝下，而%otherguy1%和%otherguy2%正准备对他进行斩首。在看到你走过来之后，这些人停止了手中的动作。他们向你解释说这位杀人犯试图杀死一位弟兄。确实，这位弟兄的脖子上有一道伤痕。要是再砍得深一些，估计他现在就说不出话来了。这些人要%killerontherun%为自己蓄意谋杀的罪行而被绞死。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "对他施以鞭刑。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "对他施以绞刑。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "这里已经是你们的家了。不准再做这样的事了！",
					function getResult( _event )
					{
						local r = this.Math.rand(1, 3);

						if (r == 1)
						{
							return "D";
						}
						else if (r == 2)
						{
							return "E";
						}
						else
						{
							return "F";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OtherGuy1.getImagePath());
				this.Characters.push(_event.m.Killer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_38.png[/img]是你下令让他们进行鞭打的。当你的手下把%killerontherun%绑在树上的时候，他唾弃着你的名号。你要是再敢这么说一句，就再让你多吃一鞭。他们用鞭子鞭下了他的上衣，而你站在他的身边，数着。第一鞭下去之后，他的背上出现了一条笔直的鞭痕。那个男人缩了一下身子，你听到由于他握起了拳头绳子被拉紧发出的声音。当抽到第5鞭的时候，他已经站不起来了。当抽到第10鞭的时候，他昏了过去。再又抽了5鞭之后，你下令停手，让手下把他放下来，对其伤口进行治疗。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "但愿这会让他接受教训。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OtherGuy1.getImagePath());
				this.Characters.push(_event.m.Killer.getImagePath());
				_event.m.Killer.addLightInjury();
				_event.m.Killer.worsenMood(3.0, "Was flogged on your orders");
				this.List = [
					{
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Killer.getName() + " suffers light wounds"
					}
				];

				if (_event.m.Killer.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Killer.getMoodState()],
						text = _event.m.Killer.getName() + this.Const.MoodStateEvent[_event.m.Killer.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_02.png[/img]你下令绞死这个人。战团大半的人都发出了叫好声，%killerontherun%发现自己已经命不久矣，发出了尖叫声。他们把那个人拖到树下。绳子被甩上树枝，一次又一次的，打圈拉紧。一个人打起了绳套，而剩下的其他人则在拍手叫好，喝着啤酒。下面放了一把凳子，那个被定罪的男人被迫站在了上面。当%killerontherun%的头被套进绳套时，他说自己有话对你们所有人说，但是不管他要说什么，当%otherguy1%踢掉他脚下的凳子时，他也没法说出来了。\n\n这样的死法可不太好。那是通过刽子手或者手段。通常来说，当有人从平台上掉下来会摔断脖子，或者直接掉脑袋。这个人的绞刑充满了哽塞与乱踢。你听到他肺部传来了某种尖叫声，但是那些声音想要奋力从他喉咙里冲出。几分钟过去了，他依然在挣扎。%otherguy2%走向那个将死之人，抓住他一条猛烈抽搐的腿来让他保持不动，然后用空的那只手猛戳%killerontherun%的心脏部位。就是这样。\n\n{令人吃惊的是，弟兄们都同意将那个人放下，然后埋了他。| 那个人就被那样吊着，战团也重新开始上路。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们继续前行。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OtherGuy1.getImagePath());
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Killer.getName() + " has died"
				});
				_event.m.Killer.getItems().transferToStash(this.World.Assets.getStash());
				this.World.getPlayerRoster().remove(_event.m.Killer);
				_event.m.OtherGuy1.improveMood(2.0, "Got satisfaction with " + _event.m.Killer.getNameOnly() + "\'s hanging");

				if (_event.m.OtherGuy1.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.OtherGuy1.getMoodState()],
						text = _event.m.OtherGuy1.getName() + this.Const.MoodStateEvent[_event.m.OtherGuy1.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_64.png[/img]当你试图给一个不合群的党派带来和平时，你想要尝试保持中立，却只是惹怒了其中的一些人。特别的是，那个脖子上有伤痕的男人怒气腾腾，一边咒骂一边踢翻东西。不少人大声说担心缺乏纪律。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们继续前行。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OtherGuy1.getImagePath());
				this.Characters.push(_event.m.Killer.getImagePath());
				_event.m.OtherGuy1.worsenMood(4.0, "Angry about lack of justice under your command");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.OtherGuy1.getMoodState()],
					text = _event.m.OtherGuy1.getName() + this.Const.MoodStateEvent[_event.m.OtherGuy1.getMoodState()]
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Killer.getID() || bro.getID() == _event.m.OtherGuy1.getID())
					{
						continue;
					}

					bro.worsenMood(1.0, "Concerned about lack of discipline");

					if (bro.getMoodState() < this.Const.MoodState.Neutral)
					{
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[bro.getMoodState()],
							text = bro.getNameOnly() + this.Const.MoodStateEvent[bro.getMoodState()]
						});
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_64.png[/img]在%killerontherun%的尸体被发现的时候，似乎让他冷静下来的要求失败了。{似乎有人在背后捅了他。| 有人用一条结实的麻绳勒死了他。| 他差不多被砍成了两半，这应该出自于一个非常愤怒的人之手。| 当它被发现时，他的头躺在他的胸口上，他的手被如此放着，就好像在拿着他的头一样。| 注意“身体”这个词，因为根本找不到他的头在哪里。| 有人在夜里抹了她的脖子。| 他身上的青肿与手上的割伤意味着发生了一场搏斗，但是不管是谁，他都成功地把这个人开肠破肚了。你仔细猜了一下凶手会是谁，但是看上去似乎没人为他的死感到悲伤，某些证据会对任何的调查造成迷惑。尽管那一切可能会是真的，你依然下令可疑的手下帮忙埋了尸体。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "现在也只能这样处理了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OtherGuy1.getImagePath());
				local dead = _event.m.Killer;
				local fallen = {
					Name = dead.getName(),
					Time = this.World.getTime().Days,
					TimeWithCompany = this.Math.max(1, dead.getDaysWithCompany()),
					Kills = dead.getLifetimeStats().Kills,
					Battles = dead.getLifetimeStats().Battles,
					KilledBy = "Murdered by his fellow brothers"
				};
				this.World.Statistics.addFallen(fallen);
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Killer.getName() + " has died"
				});
				_event.m.Killer.getItems().transferToStash(this.World.Assets.getStash());
				this.World.getPlayerRoster().remove(_event.m.Killer);
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.OtherGuy1.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 33)
					{
						continue;
					}

					bro.worsenMood(1.0, "Concerned about lack of discipline");

					if (bro.getMoodState() < this.Const.MoodState.Neutral)
					{
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[bro.getMoodState()],
							text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
						});
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "%killerontherun%还没死，不过他已经被打得遍体鳞伤。看来正义的复仇最终还是找上他了。他要求你去处罚那些违背你命令的弟兄们。你想了一想，然后问他如果这样继续下去最终会导致什么样的后果。虽然你很难从一个被打得鼻青脸肿的人看到他真实的反应，但他最后还是慎重地点了点头。你说得对，他答道。这件事最好还是就这么让它过去吧。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们继续前行。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.OtherGuy1.getImagePath());
				this.Characters.push(_event.m.Killer.getImagePath());
				local injury = _event.m.Killer.addInjury(this.Const.Injury.Brawl);
				this.List.push({
					id = 13,
					icon = injury.getIcon(),
					text = _event.m.Killer.getName() + " suffers " + injury.getNameOnly()
				});
				injury = _event.m.Killer.addInjury(this.Const.Injury.Brawl);
				this.List.push({
					id = 13,
					icon = injury.getIcon(),
					text = _event.m.Killer.getName() + " suffers " + injury.getNameOnly()
				});
				_event.m.Killer.worsenMood(2.0, "Was beaten up by men of the company");

				if (_event.m.Killer.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Killer.getMoodState()],
						text = _event.m.Killer.getName() + this.Const.MoodStateEvent[_event.m.Killer.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Killer.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 50 && bro.getID() != _event.m.OtherGuy1.getID())
					{
						continue;
					}

					bro.worsenMood(1.0, "Concerned about lack of discipline");

					if (bro.getMoodState() < this.Const.MoodState.Neutral)
					{
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[bro.getMoodState()],
							text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
						});
					}
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().Days < 10)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local killer_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getHireTime() + this.World.getTime().SecondsPerDay * 60 >= this.World.getTime().Time && bro.getBackground().getID() == "background.killer_on_the_run" && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				killer_candidates.push(bro);
			}
		}

		if (killer_candidates.len() == 0)
		{
			return;
		}

		this.m.Killer = killer_candidates[this.Math.rand(0, killer_candidates.len() - 1)];
		local other_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getID() != this.m.Killer.getID())
			{
				other_candidates.push(bro);
			}
		}

		if (other_candidates.len() == 0)
		{
			return;
		}

		this.m.OtherGuy1 = other_candidates[this.Math.rand(0, other_candidates.len() - 1)];
		other_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getID() != this.m.Killer.getID() && bro.getID() != this.m.OtherGuy1.getID())
			{
				other_candidates.push(bro);
			}
		}

		if (other_candidates.len() == 0)
		{
			return;
		}

		this.m.OtherGuy2 = other_candidates[this.Math.rand(0, other_candidates.len() - 1)];
		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"killerontherun",
			this.m.Killer.getName()
		]);
		_vars.push([
			"otherguy1",
			this.m.OtherGuy1.getName()
		]);
		_vars.push([
			"otherguy2",
			this.m.OtherGuy2.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Killer = null;
		this.m.OtherGuy1 = null;
		this.m.OtherGuy2 = null;
	}

});

