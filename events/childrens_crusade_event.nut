this.childrens_crusade_event <- this.inherit("scripts/events/event", {
	m = {
		Monk = null,
		Traveller = null
	},
	function create()
	{
		this.m.ID = "event.childrens_crusade";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 300.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_97.png[/img]你在路上遇到了一支小鬼头队伍。其中最大最壮实的一个大概15岁最多了，长着一头杂乱的橙色头发，手里拿着长矛做武器。他领导着队伍——比城镇更大的战斗力。他们和你在路上碰到，小领袖对你点点头。%SPEECH_ON%让让！我们走在正义的道路上，不应受到阻拦！%SPEECH_OFF%你感到好奇，询问他们目的地是哪里。孩子回答时一副怀疑你认不认识的模样。%SPEECH_ON%好吧，让我来告诉你，佣兵。我们要往北穿过冰冻荒原。未教化的部落需要了解古神，无论是以文明还是暴力地方式。%SPEECH_OFF%他举起了长矛。队伍中传出了相当活跃的‘战嚎’。似乎有某种宗教热情主宰了这支游荡的，无害的，因此无异于自杀的队伍。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "你们应该回家找父母，孩子。",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
				if (_event.m.Monk != null)
				{
					this.Options.push({
						Text = "%monk%，你代表古神。对吗？",
						function getResult( _event )
						{
							return "Monk";
						}

					});
				}

				if (_event.m.Traveller != null)
				{
					this.Options.push({
						Text = "%walker%，你一路走到此地。说点什么吧。",
						function getResult( _event )
						{
							return "Traveller";
						}

					});
				}

				this.Options.push({
					Text = "我会让你免去漫长的步行，帮你摆脱任何有价值的权利。",
					function getResult( _event )
					{
						return "C";
					}

				});
				this.Options.push({
					Text = "祝好运。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-1);
						return 0;
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_97.png[/img]你叫孩子们回家去找父母。首领笑了，其他人有样学样，就像小孩子被兄长影响一样。他摇摇头。%SPEECH_ON%你觉得我们为什么要跑这么大老远？我们的父母知道我们在哪里，也知道我们对在哪里。古神应该被正片大地知晓！快点让开！%SPEECH_OFF%孩子们逼上前来。一条小标语从你身边飞过，他们的迷你武器发出一阵叮叮当当，大部分都是瓶子，弹弓，还有餐具。\n\n 他们绝对是在送死。掠夺者和流浪汉肯定会折磨他们，就像老鹰捕食旅鼠，而奴隶不会介意让看起来是孤儿的孩子‘消失’。如果他们能拜托这些威胁，北方的荒原也会成为他们提供冰封的棺木。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "祝成功。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(1);
			}

		});
		this.m.Screens.push({
			ID = "Monk",
			Text = "[img]gfx/ui/events/event_97.png[/img]%monk%僧侣上前来，把孩子们挤在一起。他们立刻崇拜起了他，因为他在某种程度上代表了他们急于宣扬的事业。他弯下膝盖。%SPEECH_ON%是古神让你们来到这里做这些事情吗？%SPEECH_OFF%小首领点点头。%SPEECH_ON%他们在我梦中与我交谈。%SPEECH_OFF%僧侣摩挲着下巴点头回应。他拍拍男孩的头。%SPEECH_ON%古神会和我交流，我代表着他们。解读他们的信息需要多年研究，但是，让我告诉你吧！你确实是你吗，小家伙，是你要肩负这种负担吗？也许你是信使，不是吗？看看我们，我们是战士。能够杀死轻视古神之人的合适战士。你跟我们还不一样，但你有强有力的声音，和真正领导者的控制。我相信古神是因为你的魅力，而非力量才选择你。%SPEECH_OFF%僧侣玩笑地推推男孩。他微笑了，明白了修士想说的真相。僧侣确实是对的，小首领要他的队伍回家去。有人跟感激这些孩子被劝服了，不会去送死。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "愚蠢的孩子们。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk.getImagePath());
				this.World.Assets.addMoralReputation(2);
				local resolve = this.Math.rand(1, 2);
				_event.m.Monk.getBaseProperties().Bravery += resolve;
				_event.m.Monk.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Monk.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + resolve + "[/color] 决心"
				});
				_event.m.Monk.improveMood(1.0, "Saved some children from certain doom");

				if (_event.m.Monk.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Monk.getMoodState()],
						text = _event.m.Monk.getName() + this.Const.MoodStateEvent[_event.m.Monk.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() != _event.m.Monk.getID() && this.Math.rand(1, 100) <= 25)
					{
						bro.improveMood(0.5, "Glad that " + _event.m.Monk.getName() + " saved children from certain doom");

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
		this.m.Screens.push({
			ID = "Traveller",
			Text = "[img]gfx/ui/events/event_97.png[/img]%walker%脱下了靴子，把脚底给孩子们看。他们退缩了，捂着嘴恶心作呕。一个小女孩发出了长长的‘噫’声把问题讲清楚。男人摇着脚，炫耀着恶心僵硬的皮肤。%SPEECH_ON%我在路上走了很多年，大部分时间都没有鞋子穿。我知道那里什么样。我见过危险。人们在睡梦中夺取他人性命。为了一点点点心互相残杀。陌生人和你当朋友，然后好背叛你。而这些都是情况好的时候！等到情况不好的时候……好吧，会非常糟糕。小孩子在外面毫无生计。你们会被强暴，杀害，变成奴隶，遭受折磨，成为野狗、野猪、黑熊、狼群的食物，不管什么东西看你都是看着午餐的模样。回家去吧。你们。%SPEECH_OFF%孩子们窃窃私语。有人说要回家找妈妈。一个小女孩说她根本就不想来这里，而且也从来没获得说好的待遇。小首领察觉到了士气衰弱，想要抓住这些孩子，但是没什么用。队伍分散开来，谢天谢地，他们开始回家了。不少人如释重负，因为他们不想看到这些小家伙继续这场送命的旅途。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你也许该看看那些脚。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Traveller.getImagePath());
				this.World.Assets.addMoralReputation(2);
				local resolve = this.Math.rand(1, 2);
				_event.m.Traveller.getBaseProperties().Bravery += resolve;
				_event.m.Traveller.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Traveller.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + resolve + "[/color] 决心"
				});
				_event.m.Traveller.improveMood(1.0, "Saved some children from certain doom");

				if (_event.m.Traveller.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Traveller.getMoodState()],
						text = _event.m.Traveller.getName() + this.Const.MoodStateEvent[_event.m.Traveller.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() != _event.m.Traveller.getID() && this.Math.rand(1, 100) <= 25)
					{
						bro.improveMood(0.5, "Glad that " + _event.m.Traveller.getName() + " saved children from certain doom");

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
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_97.png[/img]你不知道自己能不能让这些孩子清醒过来，但如果你的教导有用的话你应该能对他们当头棒喝。在迅速的命令下，你的战团朝孩子们扑过去，击倒他们，抢夺他们的物资。小首领想要用矛刺穿某个佣兵，给他点教训。\n\n 这可不是什么每秒的活计，如果有人看到战团在殴打孩子的话就很糟糕了，但这样‘结束’他们的改革运动比其他等待他们的可怕结局好多了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "吃土去吧，小畜生。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(-4);
				local item = this.new("scripts/items/loot/silverware_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				item = this.new("scripts/items/weapons/militia_spear");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 11,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().isOffendedByViolence() && this.Math.rand(1, 100) <= 75)
					{
						bro.worsenMood(1.0, "Was appalled by your order to rob children");

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
	}

	function onUpdateScore()
	{
		if (this.World.FactionManager.isGreaterEvil())
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates_monk = [];
		local candidates_traveller = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.monk")
			{
				candidates_monk.push(bro);
			}
			else if (bro.getBackground().getID() == "background.messenger" || bro.getBackground().getID() == "background.vagabond" || bro.getBackground().getID() == "background.refugee")
			{
				candidates_traveller.push(bro);
			}
		}

		if (candidates_monk.len() != 0)
		{
			this.m.Monk = candidates_monk[this.Math.rand(0, candidates_monk.len() - 1)];
		}

		if (candidates_traveller.len() != 0)
		{
			this.m.Traveller = candidates_traveller[this.Math.rand(0, candidates_traveller.len() - 1)];
		}

		this.m.Score = 5;
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"monk",
			this.m.Monk != null ? this.m.Monk.getName() : ""
		]);
		_vars.push([
			"walker",
			this.m.Traveller != null ? this.m.Traveller.getName() : ""
		]);
	}

	function onClear()
	{
		this.m.Monk = null;
		this.m.Traveller = null;
	}

});

