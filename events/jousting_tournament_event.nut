this.jousting_tournament_event <- this.inherit("scripts/events/event", {
	m = {
		Jouster = null,
		Opponent = "",
		Bet = 0
	},
	function create()
	{
		this.m.ID = "event.jousting_tournament";
		this.m.Title = "路上…";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]%jouster%来到你面前，手上还拿着一张纸。他将纸甩在桌子上，然后说他想参加。你拿起那个卷轴，慢慢打开它，然后发现它是一张本地骑马比武比赛的招募状。那个人将双手插在胸前，等待着你的回答。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "很好，你可以去参加。",
					function getResult( _event )
					{
						return "E";
					}

				},
				{
					Text = "不行，我们还有更重要的事情要做。",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_96.png[/img]你同意让%jouster%参加锦标赛，并且你也想亲自见证，于是你也一同前去。\n\n当你靠近的时候，马术锦标赛伴随着能量发出了爆裂声。侍从迅速前去，带走一大堆盔甲和武器，一些由于肩膀上抗着的巨大长枪走得慢慢悠悠。其他人刷着犹如帝王般的马，那些马里有很多都穿戴着装饰着魔印的胸甲。在远处，你听到了短暂的飞驰声，沉重的铁蹄缓慢重踏的声音，接着爆发出突然的在金属上弹拨木头的声音以及干杯的声音。\n\n当你看着庆典的时候，一个贵族走了过来，拦下了你。一只手掂量着钱包的重量，嘴角吊着一根草杆，他问你想不想打个赌。你问赌什么。他点了点头，指着正在穿过集合点，报名参加马术锦标赛%jouster%。很明显他将面对这个贵族的骑手，一个叫做%opponent%的人。%SPEECH_ON%一点点战术策略总是好的，不是吗？%bet%克朗你觉得如何？当然所有都归赢家了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "正合我意！",
					function getResult( _event )
					{
						_event.m.Bet = 500;
						return "P";
					}

				},
				{
					Text = "我不赌博。",
					function getResult( _event )
					{
						return "P";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "P",
			Text = "[img]gfx/ui/events/event_96.png[/img]你在平明和貌似贵族的人之间坐了下来。只有本地的领主会和贱民区分开来，和像他儿子，女儿以及来自各地的王室成员的人坐在加高的位置上。\n\n接下来是%jouster%，一个侍从领着他的马来到其中一列骑士队列中。沿着战线下来，%opponent%骑行至场地上，他的马浑身漆黑，他的盔甲则是装饰着金色饰物的亮紫色，随处都能看见装饰的流苏。他和他的%jouster%都带着长枪，压着头盔上的护脸片。\n\n拉客者在主席台上大声喊出他们的名字，接着一个神职人员说了一些有关神是如此规定，如果今天有人在这死去，那么他们会在下一个国度时与那些最伟大的人平起平坐，同时在这个国度永远被世人所记住。等他说完这一切，两个骑士放低了自己的长枪，在神职人员以及那个拉客者都还没来得及坐下之前，就发起了冲锋。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真是太刺激了！",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 30 + 5 * _event.m.Jouster.getLevel())
						{
							return "Win";
						}
						else
						{
							return "Lose";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Win",
			Text = "[img]gfx/ui/events/event_96.png[/img]你从未参加过这样的盛事，当那两个骑手飞驰而下朝互相冲锋时，你忍不住屏住了呼吸。那些马看上去都很威严，它们的马蹄掀起土块，它们的盔甲在奔腾时反射着太阳的光点，这一切都给头昏眼花的旁观者们一丝清醒，让小孩发出大声的叫喊，让酒鬼的酒从杯中洒出，让年轻的公主们激动地挥动起裙子，让让王子们鼓起掌来，而不知怎的，也让你自己站起了身，在那里大声叫好。\n\n %opponent%努力让自己瞄准，他的长枪上下摆动，摇晃着寻找着真正的目标。\n\n他没有找到目标。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Ohh!",
					function getResult( _event )
					{
						if (_event.m.Bet > 0)
						{
							return "WinBet";
						}
						else
						{
							return "WinNobet";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "WinNobet",
			Text = "[img]gfx/ui/events/event_96.png[/img]%jouster%的长枪击穿了对手的胸膛，随着一阵碎屑飞溅，场上出现了一匹没有骑手的战马。那位骑手连同自己的马鞍一并被打下，他就这样面朝下摔在地上，不再移动，也没有了呼吸。人群中爆发出一阵咆哮声，你很快也卷入到这暴风雨中，你的耳边响起刺耳的嘈杂声，被扫进一个永远难忘的时间与地点之中。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Huzzah!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
				_event.m.Jouster.improveMood(2.0, "Won a jousting tournament");

				if (_event.m.Jouster.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Jouster.getMoodState()],
						text = _event.m.Jouster.getName() + this.Const.MoodStateEvent[_event.m.Jouster.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "WinBet",
			Text = "[img]gfx/ui/events/event_96.png[/img]%jouster%的长枪击穿了对手的胸膛，随着一阵碎屑飞溅，场上出现了一匹没有骑手的战马。那位骑手连同自己的马鞍一并被打下，他就这样面朝下摔在地上，不再移动，也没有了呼吸。人群中爆发出一阵咆哮声，你很快也卷入到这暴风雨中，你的耳边响起刺耳的嘈杂声，被扫进一个永远难忘的时间与地点之中。\n\n还在庆祝的时候，那个和你打赌的贵族走了过来，把一个钱包交到了你的手里。你想说些什么，但是在你还没来得及开口之前，他就生气地走开了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Huzzah!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
				this.World.Assets.addMoney(_event.m.Bet);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你赢得了[color=" + this.Const.UI.Color.PositiveEventValue + "]" + _event.m.Bet + "[/color] 克朗"
				});
				_event.m.Jouster.improveMood(2.0, "Won a jousting tournament");

				if (_event.m.Jouster.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Jouster.getMoodState()],
						text = _event.m.Jouster.getName() + this.Const.MoodStateEvent[_event.m.Jouster.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Lose",
			Text = "[img]gfx/ui/events/event_96.png[/img]你从未参加过这样的盛事，当那两个骑手飞驰而下朝互相冲锋时，你忍不住屏住了呼吸。那些马看上去都很威严，它们的马蹄掀起土块，它们的盔甲在奔腾时反射着太阳的光点，这一切都给头昏眼花的旁观者们一丝清醒，让小孩发出大声的叫喊，让酒鬼的酒从杯中洒出，让年轻的公主们激动地挥动起裙子，让让王子们鼓起掌来，而不知怎的，你也站起了身，在那里大声叫好。\n\n%opponent%努力让自己瞄准，他的长枪上下摆动，摇晃着寻找着真正的目标。\n\n他没有找到目标。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Ohh...",
					function getResult( _event )
					{
						if (_event.m.Bet > 0)
						{
							return "LoseBet";
						}
						else
						{
							return "LoseNobet";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "LoseNobet",
			Text = "[img]gfx/ui/events/event_96.png[/img]%opponent%的长枪在径直刺进%jouster%的胸甲时发出了一声巨响。那个男人把身子弯回到马鞍上，一阵旋转的木刺以及粉碎的木屑在他之后旋转纷飞。他试图去去拉缰绳。在他抓住缰绳后，你觉得他会缓过劲来，但战马的嚼子却在此时断裂，使得缰绳彻底脱开。 %jouster%向后倒去，从马鞍的后部越过，然后双脚着地。虽然他还站着，但他已经输掉了比赛。\n\n人群中爆发出一阵欢呼，他们在为胜者和败者的表现而喝彩。在动了动自己隐隐作痛的肩膀之后，%jouster%离开了竞技场。你在集合点后面找到了他。他说自己的长枪当时有些不对劲，你则提到他的战马的嚼子也有松动的迹象。就在此时，胜者从他身边经过，身边还跟随者一些女崇拜者以及牵着战马的侍从。让你感到惊讶的是，%opponent%和%jouster%居然握了握手并相互祝贺了对方的表现。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
				local injury = _event.m.Jouster.addInjury(this.Const.Injury.Jousting);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.Jouster.getName() + " suffers " + injury.getNameOnly()
				});
			}

		});
		this.m.Screens.push({
			ID = "LoseBet",
			Text = "[img]gfx/ui/events/event_96.png[/img]%opponent%的长枪在径直刺进%jouster%的胸甲时发出了一声巨响。那个男人把身子弯回到马鞍上，一阵旋转的木刺以及粉碎的木屑在他之后旋转纷飞。他试图去去拉缰绳。在他抓住缰绳后，你觉得他会缓过劲来，但战马的嚼子却在此时断裂，使得缰绳彻底脱开。%jouster%向后倒去，从马鞍的后部越过，然后双脚着地。虽然他还站着，但他已经输掉了比赛。\n\n 人群中爆发出一阵欢呼，他们在为胜者和败者的表现而喝彩。在动了动自己隐隐作痛的肩膀之后，%jouster%离开了竞技场。你在集合点后面找到了他。他说自己的长枪当时有些不对劲，你则提到他的战马的嚼子也有松动的迹象。就在此时，胜者从他身边经过，身边还跟随者一些女崇拜者以及牵着战马的侍从。让你感到惊讶的是，%opponent%和%jouster%居然握了握手并相互祝贺了对方的表现。 \n\n 那个和你打赌的贵族对公平可没那么感冒。他搓着手，脸上带着假笑朝你走来。你不情愿地支付了他应得的那份赌资。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
				this.World.Assets.addMoney(-_event.m.Bet);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你失去了[color=" + this.Const.UI.Color.NegativeEventValue + "]" + _event.m.Bet + "[/color] 克朗"
				});
				local injury = _event.m.Jouster.addInjury(this.Const.Injury.Jousting);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.Jouster.getName() + " suffers " + injury.getNameOnly()
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_64.png[/img]虽然你拒绝了%jouster%的要求，但事情没有就此结束。他认为自己能通过比赛赚取很多钱，而因为你的决定，他蒙受了相当的损失。虽然他的抱怨五花八门，但最终，他还是提出了要你给他%compensation%克朗作为补偿。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧，我会补偿你。",
					function getResult( _event )
					{
						return "H";
					}

				},
				{
					Text = "你现在是雇佣兵，不是骑手。你最好认清这一点。",
					function getResult( _event )
					{
						return "I";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "H",
			Text = "[img]gfx/ui/events/event_64.png[/img]你站起来拍了拍%jouster%的肩膀。%SPEECH_ON%我相信像你这样的人一定有实力横扫赛场。但我需要你留在这里服役。你不需要证明什么，我会给你相应的补偿。%SPEECH_OFF%这些充满外交口吻的话语让这个人平静了下来他点了点头，似乎在考虑自己拿补偿的行为是否妥当。为了不让这位佣兵过于纠结，你命令他必须收下这些钱。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你现在可以走了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
				this.World.Assets.addMoney(-500);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]500[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "I",
			Text = "[img]gfx/ui/events/event_64.png[/img]你拿起比赛海报并用蜡烛将其点燃。当火焰将那张纸燃烧殆尽之后，你给%jouster%立下了几条规定。%SPEECH_ON%我雇你做我的佣兵，而不是什么骑手。如果你想要去参加什么比赛的话，大可归还你的装备钱并与我们分道扬镳。否则，给我立刻滚出我的帐篷。%SPEECH_OFF%虽然这事情的结局并不完美，但至少这位佣兵仅仅是离开了你的帐篷而不是你的战团。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "回去干活！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Jouster.getImagePath());
				_event.m.Jouster.worsenMood(2.0, "Was denied participation in a jousting tournament");

				if (_event.m.Jouster.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Jouster.getMoodState()],
						text = _event.m.Jouster.getName() + this.Const.MoodStateEvent[_event.m.Jouster.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getMoney() < 500)
		{
			return;
		}

		if (this.World.FactionManager.isGreaterEvil())
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 4 && t.isAlliedWithPlayer())
			{
				nearTown = true;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 1)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() < 4)
			{
				continue;
			}

			if ((bro.getBackground().getID() == "background.adventurous_noble" || bro.getBackground().getID() == "background.disowned_noble" || bro.getBackground().getID() == "background.bastard" || bro.getBackground().getID() == "background.hedge_knight") && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Jouster = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 25;
	}

	function onPrepare()
	{
		this.m.Opponent = this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)];
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"jouster",
			this.m.Jouster.getName()
		]);
		_vars.push([
			"opponent",
			this.m.Opponent
		]);
		_vars.push([
			"bet",
			500
		]);
		_vars.push([
			"compensation",
			500
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Jouster = null;
		this.m.Opponent = "";
		this.m.Bet = 0;
	}

});

