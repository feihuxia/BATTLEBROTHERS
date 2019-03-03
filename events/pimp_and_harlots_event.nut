this.pimp_and_harlots_event <- this.inherit("scripts/events/event", {
	m = {
		Payment = 0
	},
	function create()
	{
		this.m.ID = "event.pimp_and_harlots";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_85.png[/img]在行军途中，你看到一个女人站在路旁边。她的背后有一个被驴子拖动的货车。在看到你之后，她拍了拍手，似乎是在下什么命令。不消一刻，车后面走出一些女孩，并你面前站成一排。她们衣衫褴褛，似乎也没有受过什么训练。你可以看出，她们根本不想待在这里。这点在乡下姑娘身上很是普遍。你向这群人的“领导者”询问她们在做什么。她的脸上堆满了笑容。%SPEECH_ON%我是一个经营皮肉生意的商人，客人的愉悦就是我的经济来源。而这些，就是我的商品。%SPEECH_OFF%她朝那些妓女们挥了挥手。那些妓女们便开始对你和你的手下们搔首弄姿。老鸨点了点头。%SPEECH_ON%所以，让我们来帮你们放松一下如何？你们长途跋涉相比相当辛苦吧？看在你们有这么多人的份上，我可以给你打个折，只要%cost%克朗。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "成交！",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 60)
						{
							return "C";
						}
						else
						{
							return "D";
						}
					}

				},
				{
					Text = "不如你们把身上值钱的东西都交出来吧？",
					function getResult( _event )
					{
						return "G";
					}

				},
				{
					Text = "不，谢谢。",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_64.png[/img]不顾一些手下的反对，你决绝了那位老鸨的提议。她耸了耸肩。%SPEECH_ON%可恶，早知如此，我就该花钱弄几个小男孩来。那就这样吧。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们可以去下一个城镇上找乐子。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 25)
					{
						bro.worsenMood(0.75, "You refused to pay for harlots");

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
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_85.png[/img]那些女人们朝前靠了过来，她们的脸上充满了倦容。虽然这些女人可能经历过不幸的遭遇，但你的部下也需要放松放松。你接受了老鸨的提议，随后你的部下们便各自找好地方和那些妓女们翻云覆雨去了。在他们正快活的时候，那位老鸨走到你身旁。%SPEECH_ON%感谢你没有打劫我们。%SPEECH_OFF%你耸了耸肩，然后说现在下定论还太早。她也耸了耸肩。%SPEECH_ON%我知道，不过我觉得你不是那样的人。我和你有很多相似之处。你为了填饱肚子而战斗，我们则为了填饱肚子和客人睡觉。%SPEECH_OFF%出于好奇，你问她现在是否还会为了赚钱而‘亲自上阵’。她笑了笑。%SPEECH_ON%只有在必要的时候。毕竟这个‘领导者’头衔是个非常不错的幌子。那你呢？你现在还会‘亲自上阵’吗？%SPEECH_OFF%你跟她说了实话。%SPEECH_ON%我杀过许多许多人。%SPEECH_OFF%她慢慢走近你，将一只手伸到你身下。%SPEECH_ON%那好吧。%SPEECH_OFF%确实不错。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "值了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoney(-_event.m.Payment);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]" + _event.m.Payment + "[/color] 克朗"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					bro.improveMood(1.0, "Enjoyed himself with harlots");

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

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_07.png[/img]你同意了。老鸨和她的妓女们向前走来，如同一团色欲之蛇涌入了你的队伍。不消片刻，你的手下已被脱得一丝不挂，这时，一群强盗从旁边的树丛中走了出来。你顾不得穿上衣服，赶忙拿起了你的剑——那柄真正的剑，然后一剑砍下了一个强盗的头并刺穿了另一个强盗的胸膛。又有一群抢劫者冲了出来，他们手中紧握着武器，就在这时，那位老鸨却突然跳了出来。%SPEECH_ON%喂！我们没有必要在这里大开杀戒啊！%SPEECH_OFF%你的一些手下依然没有意识到这到底是怎么回事，所以，这个女人行为对你来说无异于一件好事。就算是光着屁股，%companyname%的战斗力依然不容小觑，那个老鸨应该是意识到了这一点。她开始则被那些和她一伙的强盗。%SPEECH_ON%我记得我跟你们这帮蠢货说过吧？只有在对方看起来很危险的时候，你们再冲出来。这帮人看起来很危险吗？你们真是能把我气死。听我说，佣兵。只要你肯出双倍的钱，我们马上就离开。只要双倍就行。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "好吧，成交。",
					function getResult( _event )
					{
						return "E";
					}

				},
				{
					Text = "没门儿。",
					function getResult( _event )
					{
						return "F";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_07.png[/img]你不想让你的手下再有任何生命危险，于是你同意了老鸨的条件。在她接过钱的时候，她点了点头。%SPEECH_ON%许多人在这种情况下都放不下自己的尊严，但你是一个关心手下安危的人。现在像你这样的聪明的佣兵已经不多了。能有你这样的领导者，你的部下也会感到高兴吧。%SPEECH_OFF%在抢劫者和那些妓女们离开后，%randombrother%一边叹气，一边向你走来。%SPEECH_ON%真扫兴。我本来都准备好把那些臭婊子劈成两半了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "这我真是没想到。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoney(-_event.m.Payment * 2);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]" + _event.m.Payment * 2 + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_06.png[/img]你虽然嘴上没说拒绝，但你的行动证明了你的意图。你紧握手中的剑，朝那个老鸨的脸上挥去。就在她用怀疑的表情看着你的时候，你反手一挥将她的头颅砍下。你的部下们，虽然一丝不挂，但也立刻找到了一件武器准备开始战斗。一些妓女掏出了匕首开始挥舞，但她们很快就被杀掉了。大多数的妓女并没有什么战斗经验，她们还没有搞清楚情况，就在混战中被杀死了。\n\n那些强盗们并没有预料到会遇上一场真正的战斗，因此很快就被你的队伍干掉了。当战斗结束后，场上差不多有二十多具死尸，多数佣兵的身上也挂了彩。你则开始搜刮那些尸体。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "看来以后要避免光着屁股战斗。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/loot/signet_ring_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				item = this.new("scripts/items/weapons/dagger");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/weapons/bludgeon");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.Math.rand(100, 300);
				this.World.Assets.addMoney(item);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + item + "[/color] 克朗"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 33)
					{
						local injury = bro.addInjury(this.Const.Injury.Brawl);
						this.List.push({
							id = 10,
							icon = injury.getIcon(),
							text = bro.getName() + " suffers " + injury.getNameOnly()
						});
					}
					else
					{
						local injury = bro.addInjury(this.Const.Injury.PiercingBody);
						this.List.push({
							id = 10,
							icon = injury.getIcon(),
							text = bro.getName() + " suffers " + injury.getNameOnly()
						});
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_07.png[/img]你仔细考虑了一下老鸨的提议，随后意识到她们只不过是一群身处荒郊的女人罢了。于是，你一挥手将那老鸨打翻在地。她揉了揉自己的下巴，然后说如果你们想玩强硬式的要额外加钱。你点了点头。%SPEECH_ON%没错，你要为此交出所有的东西。大家给我上，把所有的东西都拿走。%SPEECH_OFF%那老鸨问你是不是要抢劫她们，你点了点头。就在你清楚地表明了意图后，一群全副武装的男人从旁边的树丛里钻了出来。老鸨从地上爬起身来，揉了揉自己的下巴。%SPEECH_ON%现在后悔还来得及，佣兵，我还可以和你谈条件。做我们这行的，挨一两个巴掌是很常见的事。我早就准备好应付这种情况了，当然，我也做好了应付强盗、杀人犯和强奸犯的准备。现在，如果你还不改主意的话，我只能让这些人来保护我和我的女孩们了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "好吧，我们走便是了。",
					function getResult( _event )
					{
						return "H";
					}

				},
				{
					Text = "你的那些护卫不值一提。大家上啊！",
					function getResult( _event )
					{
						return "I";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "H",
			Text = "[img]gfx/ui/events/event_64.png[/img]你看了看那些护卫，又看了看你的部下，觉得没必要在这种事情上制造伤亡。于是，你点了点头。%SPEECH_ON%你是个聪明女人。好。我们没必要为此大开杀戒。%SPEECH_OFF%老鸨松了一口气。%SPEECH_ON%你们能同意那是再好不过了。不过我最初的提议也就此作废。我想你应该能理解吧。%SPEECH_OFF%你收起了剑，并说你可以理解。战团中的一些弟兄们则摇了摇头。在他们看来，你的过激举动使得他们错失了一次放纵的机会。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "你们难道就看不出来他们一开始就准备打劫我们吗？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 33)
					{
						bro.worsenMood(1.0, "Missed out on a good lay because of you");

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
			}

		});
		this.m.Screens.push({
			ID = "I",
			Text = "[img]gfx/ui/events/event_60.png[/img]这些“护卫”都是渣渣。你下令让队伍展开攻击。这场战斗很快就结束了。那些被妓女们雇来的帮手根本没有什么战斗经验。\n\n 当战斗结束后，你看到那辆货车还在原处，只是老鸨和她的妓女们都已经不见了。她们肯定是趁我们在战斗时溜走了。她们甚至还把驴都牵走了。\n\n 你的手下洗劫了那辆货车。就在他们抢走一切能拿走的东西时，%randombrother%听到了一声响动。他在货车底部搜索了一圈，然后找到了一段绳子。就在他拉动绳子后，车上掉下一堆木板，里面出现了一个全身被黑色皮革裹住的人。你撤下了盖在他脸上的面罩。他深吸了一口气。%SPEECH_ON%谢、谢谢你！旧神在上！我还以为她们会一直把我关在这里！%SPEECH_OFF%你询问这个人的身份。他吐出了嘴中的碎皮革。%SPEECH_ON%瘸子。%SPEECH_OFF%你就叫‘瘸子’吗？他点了点头。%SPEECH_ON%是的，先生。嘿，你的武器真不错啊。护甲也很好。嗯。我的主人已经不在了，所以……%SPEECH_OFF%你摇了摇头。%SPEECH_ON%去离这里最近的镇上好好洗漱一下吧，陌生人。%SPEECH_OFF%她点了点头。%SPEECH_ON%如您所愿，主人。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "是，是。去吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/loot/signet_ring_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				item = this.new("scripts/items/weapons/dagger");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/weapons/bludgeon");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.Math.rand(100, 300);
				this.World.Assets.addMoney(item);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + item + "[/color] 克朗"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 25)
					{
						if (this.Math.rand(1, 100) <= 66)
						{
							local injury = bro.addInjury(this.Const.Injury.Brawl);
							this.List.push({
								id = 10,
								icon = injury.getIcon(),
								text = bro.getName() + " suffers " + injury.getNameOnly()
							});
						}
						else
						{
							bro.addLightInjury();
							this.List.push({
								id = 10,
								icon = "ui/icons/days_wounded.png",
								text = bro.getName() + " suffers light wounds"
							});
						}
					}
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().Days <= 10)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() <= 3)
		{
			return;
		}

		if (this.World.Assets.getMoney() < 50 * brothers.len() * 2 + 500)
		{
			return;
		}

		this.m.Payment = 50 * brothers.len();
		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"cost",
			this.m.Payment
		]);
	}

	function onClear()
	{
		this.m.Payment = 0;
	}

});

