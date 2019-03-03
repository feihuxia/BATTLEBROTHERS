this.bastard_assassin_event <- this.inherit("scripts/events/event", {
	m = {
		Bastard = null,
		Other = null,
		Assassin = null
	},
	function create()
	{
		this.m.ID = "event.bastard_assassin";
		this.m.Title = "营地…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "Intro",
			Text = "[img]gfx/ui/events/event_33.png[/img]在夜色的掩护下，有个人偷偷溜进你的帐篷。他穿着黑色的斗篷和贵族肩铠。你拿起武器，不过他伸出一只手，%SPEECH_ON%算了吧，佣兵，我不是来找你的。%SPEECH_OFF%你觉得这样很不好。那家伙采取行动的下一刻，你马上冲过去把他压在桌子上，另一只手拿出匕首对准他的脖子。他笑了起来，%SPEECH_ON%我已经说了，我不是来找你的，我是来找%bastard%的。%SPEECH_OFF%那个贵族私生子？你问他想干什么。%SPEECH_ON%那要视情况而定，你想谈谈吗？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好，说吧。",
					function getResult( _event )
					{
						return "A";
					}

				},
				{
					Text = "不谈。你死定了。",
					function getResult( _event )
					{
						local r = this.Math.rand(1, 100);

						if (r <= 33)
						{
							return "Decline1";
						}

						if (r <= 66)
						{
							return "Decline2";
						}
						else
						{
							return "Decline3";
						}
					}

				}
			],
			function start( _event )
			{
				local roster = this.World.getTemporaryRoster();
				_event.m.Assassin = roster.create("scripts/entity/tactical/player");
				_event.m.Assassin.setStartValuesEx([
					"assassin_background"
				]);
				this.Characters.push(_event.m.Assassin.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_33.png[/img]你把他脖子上的匕首拿开。他站起来盯着地图，%SPEECH_ON%我知道%companyname%的进军范围很广。%bastard%很聪明，加入了战团。%SPEECH_OFF%这时一滴血滴到地图上，他停下来摸了摸脖子上的一道小伤口，然后放在嘴里，似乎他早上刮了胡子。%SPEECH_ON%言归正传吧，我的资助者希望杀死%bastard%。他给了我一大笔钱，所以我有义务完成这项任务。或者……也可以不那样做。%SPEECH_OFF%他皱起眉头，你问他在想什么。他指着地图上教堂司事说，%SPEECH_ON%有一支军队在等%bastard%，所以贵族才想杀了他，因为他目前是个巨大的威胁，而他自己根本不知道。我觉得他也没必要知道，不过这样给他送行也不错，对吧？你应该知道，他在这个世界上处于正义的位置，不相信这个世界上会有讨厌他的人。但是我呢，我只不过是个非常有天赋的刺客而已。那我呢？我已经不想要他的命了。所以我建议：我代替他的位置，他回家，我跟你一起。他不停征战，我的资助者并不是很聪明，他们只知道我消失了。听起来不错吧？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "成交。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "你收了多少钱？",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "或者我杀了你算了。",
					function getResult( _event )
					{
						local r = this.Math.rand(1, 100);

						if (r <= 33)
						{
							return "Decline1";
						}

						if (r <= 66)
						{
							return "Decline2";
						}
						else
						{
							return "Decline3";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Assassin.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_33.png[/img]%bastard%应该得到更好的。%companyname%在他下面，但他一直都认为自己是个外人，觉得自己是家族的耻辱，是自己所爱之人的威胁，因为他们的血统都比自己要高贵。你同意刺客的请求，让私生子来到帐篷。他进来之后，你迅速解释了当前的情况。他问你们关于那支军队的证据，刺客马上照做了，拿出一张卷轴，上面有一个只有私生子认识的印章。%bastard%认真看了起来。他蹲下来看着你，%SPEECH_ON%你也同意吗？这是我的命运，我会一直效忠你。%SPEECH_OFF%你拍了拍他的肩膀，告诉他走自己的路。刺客告诉他说，如果要行动，那就抓紧。%bastard%有点伤心，他并没有打算隐藏，对你表示感谢，尽管他才加入%companyname%不久，但你依然选择相信他。然后他离开了。你转过身发现刺客向你鞠躬。%SPEECH_ON%队长，我发誓向您效忠。%SPEECH_OFF%这种情况要向其他人解释好久了，不过他们肯定会相信你的选择。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "照顾好私生子。",
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Assassin);
						this.World.getTemporaryRoster().clear();
						_event.m.Assassin.onHired();
						_event.m.Bastard.getItems().transferToStash(this.World.Assets.getStash());
						this.World.getPlayerRoster().remove(_event.m.Bastard);
						_event.m.Bastard = null;
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Assassin.getImagePath());
				this.Characters.push(_event.m.Bastard.getImagePath());
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Bastard.getName() + " leaves the " + this.World.Assets.getName()
				});
				this.List.push({
					id = 13,
					icon = "ui/icons/special.png",
					text = _event.m.Assassin.getName() + " joins the " + this.World.Assets.getName()
				});
				_event.m.Assassin.getBackground().m.RawDescription = "%name% joined the company in exchange for " + _event.m.Bastard.getName() + "\'s life. Little is known about the assassin and most remain wary of him. With a dagger in hand, the killer\'s sword-hand swerves and sways more akin to a snake than a man.";
				_event.m.Assassin.getBackground().buildDescription(true);
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_33.png[/img]你做决定之前，问刺客收了多少钱来杀私生子。他歪着头权衡着这个数量。%SPEECH_ON%呃，就是…扣除旅行时间，装备消耗，还有找他的时间，以及侦查营地，你是否会找我谈话的时间，应该是……5000克朗吧。如果你想超过这个数字，那得更多一些才行。差不多多1000克朗吧，也就是说总共6000克朗。还想继续讨论吗？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我同意你的条件。%bastard%离开，你来代替他的位置。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "我给你6000克朗，你和%bastard%都能活下来。",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "我还是杀了你算了。",
					function getResult( _event )
					{
						local r = this.Math.rand(1, 100);

						if (r <= 33)
						{
							return "Decline1";
						}

						if (r <= 66)
						{
							return "Decline2";
						}
						else
						{
							return "Decline3";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Assassin.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_33.png[/img]%companyname%一切顺利，可能是目前最顺利的，6000克朗有点多了。不过……你同意了。刺客听了你的话，坐了一会儿，%SPEECH_ON%你同意？你愿意支付6000克朗？%SPEECH_OFF%你点了点头。他仔细思考了一会儿，似乎没之前那般坚定了。%SPEECH_ON%老实说，没想到你会答应。不过既然已经说好了，我也就不费话了。%SPEECH_OFF%他坚定地和你握了握手，似乎想确定这是否是个诡计。他鞠了一躬，他因为听从了贵族的话，所以才到这里来，%SPEECH_ON%%companyname%队长，我愿意为您效劳！%SPEECH_OFF%虽然要花很大的力气解释为什么有人半夜溜进战团，不过大家都非常相信你的领导，对你招募的人都非常有信心。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "欢迎加入我们，刺客。",
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Assassin);
						this.World.getTemporaryRoster().clear();
						_event.m.Assassin.onHired();
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Assassin.getImagePath());
				_event.m.Assassin.getBackground().m.RawDescription = "An assassin tired of the killing life, %name% offered to join your company at a large price which you were quick to match. He is extremely skilled with a short-blade, twirling daggers around with more dexterity and control than some men have over their own fingers.";
				_event.m.Assassin.getBackground().buildDescription(true);
				this.World.Assets.addMoney(-6000);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]6,000[/color]克朗"
				});
				this.List.push({
					id = 13,
					icon = "ui/icons/special.png",
					text = _event.m.Assassin.getName() + " joins the " + this.World.Assets.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Decline1",
			Text = "[img]gfx/ui/events/event_33.png[/img]你拒绝了刺客的提议。他点点头，%SPEECH_ON%好吧。%SPEECH_OFF%匕首的速度比你想象中更快，你用手去格挡，但还是慢了一步。你的脸被匕首划伤，开始流血。等你拔剑，刺客已经离开了帐篷。你听到外面传来一阵骚动的声音。%bastard%躺在地上，身边围着几个人。%otherbrother%走过来询问你的情况。他说有个黑衣人想杀死私生子。%SPEECH_ON%我们应该把他给打伤了，可不知道他去哪儿了。那混蛋打伤了我们不少人。先生，你在流血。%SPEECH_OFF%你告诉他你知道，现在的主要任务，就是照顾好私生子和其他人。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "嗯，至少没人死亡。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bastard.getImagePath());
				local injury = _event.m.Bastard.addInjury(this.Const.Injury.PiercingBody);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.Bastard.getName() + " suffers " + injury.getNameOnly()
				});
				injury = _event.m.Bastard.addInjury(this.Const.Injury.PiercingBody);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.Bastard.getName() + " suffers " + injury.getNameOnly()
				});
			}

		});
		this.m.Screens.push({
			ID = "Decline2",
			Text = "[img]gfx/ui/events/event_33.png[/img]你把手放在刀柄上，拒绝了刺客的提议。他拍了拍手，%SPEECH_ON%好吧，佣兵。很好。不劳烦你拔剑了。%SPEECH_OFF%他对你那只拿着剑的手点点头。%SPEECH_ON%如果我真的想杀死私生子，你觉得我还会站在这儿吗？我是来交谈的。很明显，杀戮的生活已经不适合我，还有我这张扑克脸。你说我在虚张声势，大概吧。晚安，雇佣兵。%SPEECH_OFF%你还来不及说什么，刺客就从帐篷跳了出去。你赶紧追出去看他去哪儿了，不过只看到外面漆黑一片。%bastard%看到你了，问你要去干什么。你笑着让他去休息。他疑惑地耸耸肩，%SPEECH_ON%呃，或许吧。谢谢你，队长。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "就那样了。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bastard.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Decline3",
			Text = "[img]gfx/ui/events/event_33.png[/img]你拒绝了刺客的提议。他点点头，把手放在蜡烛上。%SPEECH_ON%好吧，我们的谈话到此为止，该做其他事了。%SPEECH_OFF%他转过来看着你，眨了下眼。\n\n 匕首速度很快，直接飞到你面前。你想拔剑，但他一脚把你的手踢开，剑又重新回到剑鞘。第二支匕首飞出去了，这支是你甩出去的，明显带着杀意。刺客的匕首弹开分叉，正好抓住你的剑。他用手瞬间解除你的武装，然后又用手拿住匕首，压制另一把剑。混蛋……\n\n 那家伙想用匕首刺伤你，不过你抓住他的手臂。他让你安静下来，然后取回了另一把剑。他冷静地说道，%SPEECH_ON%受死吧，队长。%SPEECH_OFF%他的手向后伸过去，突然一阵光闪过，手不见了。剩下的只有一片红色。刺客看着自己被砍断的手，大叫起来。%bastard%站在那儿，拿着武器。又一阵光闪过，刺客的脑袋滚到地面上。鲜血哦恩撒出来，他的身体倒在桌子上，然后又倒在地上。私生子赶紧问道，%SPEECH_ON%你没事吧？这人到底是谁？%SPEECH_OFF%更多的佣兵进来，看看到底发生了什么事。你告诉他们，有个刺客来杀私生子了，但你不想把他交出去。大家都很欣赏你的防御。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你欠我一次，私生子。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bastard.getImagePath());

				if (!_event.m.Bastard.getSkills().hasSkill("trait.loyal") && !_event.m.Bastard.getSkills().hasSkill("trait.disloyal"))
				{
					local loyal = this.new("scripts/skills/traits/loyal_trait");
					_event.m.Bastard.getSkills().add(loyal);
					this.List.push({
						id = 10,
						icon = loyal.getIcon(),
						text = _event.m.Bastard.getName() + " is now loyal"
					});
				}

				_event.m.Bastard.improveMood(2.0, "You risked your life for him");

				if (_event.m.Bastard.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Bastard.getMoodState()],
						text = _event.m.Bastard.getName() + this.Const.MoodStateEvent[_event.m.Bastard.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Bastard.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 50)
					{
						bro.improveMood(0.5, "You risked your life for the men");

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
		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (this.World.getPlayerRoster().getSize() >= this.World.Assets.getBrothersMax())
		{
			return;
		}

		local candidates = [];
		local candidates_other = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 6 && bro.getBackground().getID() == "background.bastard")
			{
				candidates.push(bro);
			}
			else
			{
				candidates_other.push(bro);
			}
		}

		if (candidates.len() == 0 || candidates_other.len() == 0)
		{
			return;
		}

		this.m.Bastard = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Other = candidates_other[this.Math.rand(0, candidates_other.len() - 1)];
		this.m.Score = candidates.len() * 2;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"bastard",
			this.m.Bastard.getNameOnly()
		]);
		_vars.push([
			"otherbrother",
			this.m.Other.getNameOnly()
		]);
	}

	function onDetermineStartScreen()
	{
		return "Intro";
	}

	function onClear()
	{
		this.m.Bastard = null;
		this.m.Other = null;
		this.m.Assassin = null;
	}

});

