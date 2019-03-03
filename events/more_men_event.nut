this.more_men_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.more_men";
		this.m.Title = "营地…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]整个战团 - 在你看来这是一个鱼龙混杂的小团队 - 一起走进了你的帐篷。以这种样子出现的佣兵通常来说都不是好事，于是你立刻将手伸向了自己的武器。但你随后注意到了他们身上都没有携带武器，而且脸上也没有杀意。尽管他们看起来并不像要发动叛变的样子，但你不由得还是提高了警惕。\n\n 他们一言不发，似乎在等待着你来发话，这让你送了一口气。因为这是一种表示尊敬的举动，所以你进一步打消了拔剑的想法。你将双手支撑在桌子上，询问着他们的来意。\n\n 他们解释说，他们觉得战团目前的规模太小了。每当他们四处征战的时候，他们都在担心自己会一去不返。最终，他们提出了自己的想法：如果要提高存活机率，就必须召集更多的弟兄。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "如果我们的资金允许，我会去招募更多的人。",
					function getResult( _event )
					{
						if (this.World.Assets.getMoney() >= 3000)
						{
							return "D";
						}
						else
						{
							return this.Math.rand(1, 100) <= 50 ? "E" : "F";
						}

						return "E";
					}

				},
				{
					Text = "我们很快就会为战团雇佣更多的人手 - 我向你们保证。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "没必要雇佣更多的人，我们现在的情况不错。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]你立刻站了起来，并用手敲打着桌面。%SPEECH_ON%果然英雄所见略同啊，我已经准备好一些克朗来雇佣新的弟兄们！%SPEECH_OFF%人们脸上忧虑和悲伤的表情逐渐消失了。他们一边笑着一边点着头说‘好吧’以及‘很好。’当他们转身离开时，你注意到他们在身后都藏了匕首。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "该是雇佣些新兵的时候了。",
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
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]不幸的是，你并不同意。%SPEECH_ON%你们是我见过的最优秀的士兵。我不觉得你们有什么好怕的。反而是我们的敌人会在看到你们的时候害怕！%SPEECH_OFF%不过你的话似乎并没有什么效果。一个人身后背着一只手向前靠了过来，但另一个拍了拍他的肩膀然后摇了摇头。他看着你然后说道。%SPEECH_ON%这是我们目前最关心的问题，长官。但我们会继续效命于你。%SPEECH_OFF%当他们转身离开的时候，你注意到一个人身上装着匕首的刀鞘扣子已经被拉开了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这可是个大问题……",
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
					if (this.Math.rand(1, 100) <= 50)
					{
						bro.worsenMood(this.Math.rand(1, 3), "Lost confidence in your leadership");

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
			ID = "D",
			Text = "[img]gfx/ui/events/event_05.png[/img]你双手一摊，开始编造谎言。%SPEECH_ON%我们真的没有资金来雇佣更多的人手。%SPEECH_OFF%但这些人并不买账。其中一个立即回头走出了帐篷，嘴里还在不停地骂骂咧咧。另一个弟兄则立刻将手伸到了背后。你朝你的剑又瞄了一眼。他注意到了你的举动，随后把手放在了你视线所及的地方。最终，他点了点头。%SPEECH_ON%我们会听从你的吩咐，长官。至少现在是。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这可是个大问题……",
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
					bro.worsenMood(this.Math.rand(1, 6), "Was lied to and lost confidence in your leadership");
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[bro.getMoodState()],
						text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_05.png[/img]当你告诉这些人你没有足够的资金来雇佣其他佣兵的时候，他们点了点头%SPEECH_ON%我们已经想到你可能会这样说。所以，我们有个提议，当然这也不是我们随便做出的决定。我们每个人都会拿出我们积攒的一部分养老金，好让你能雇佣其他的士兵。而你则通过我们的薪水将这份钱慢慢翻给我们。%SPEECH_OFF%你抬头看了一眼，对他们提出的这个建议感到惊讶。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那就这么办吧 - 感谢你们的支持。",
					function getResult( _event )
					{
						return "G";
					}

				},
				{
					Text = "没这个必要。",
					function getResult( _event )
					{
						return "H";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_05.png[/img]你告诉这些人，你没有足够的资金来雇佣更多的佣兵。他们都叹了口气，然后点点头。%SPEECH_ON%好吧，长官。那只不过是我们的建议罢了。与往常一样，我们会按照你的吩咐行事。%SPEECH_OFF%这些人转身离开了，他们的表情似乎变得更加沮丧了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "战团的情况会好转的，我保证。",
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
					if (this.Math.rand(1, 100) <= 20)
					{
						bro.worsenMood(1, "Lost confidence in your leadership");

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
			ID = "G",
			Text = "[img]gfx/ui/events/event_05.png[/img]你站起身来，与每个人握了握手。尽管你嘴上说自己也不想这样，但想到自己一下子有了不少克朗收入，你还是觉得很高兴。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让我们为战团雇佣更多的人吧！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoney(1000);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + 1000 + "[/color] 克朗"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					bro.getBaseProperties().DailyWage += 3;
					bro.getSkills().update();
					this.List.push({
						id = 10,
						icon = "ui/icons/asset_daily_money.png",
						text = bro.getName() + " is now paid " + bro.getDailyCost() + " crowns a day"
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "H",
			Text = "[img]gfx/ui/events/event_05.png[/img]你看了看这些人。他们的表情十分庄重，丝毫不像是你在上次胜利过后看到的一派狂欢的景象。尽管你现在没有钱雇佣更多的人，但现在没有必要削减他们的佣金。%SPEECH_ON%我很感谢你们的无私和勇敢。我知道你们能做出这样的决定并不简单，但我也不能厚颜无耻地接受你们的建议。你们的积蓄还是由你们好好保管吧。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "但我还是很感谢你们的提议。",
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
					if (this.Math.rand(1, 100) <= 20)
					{
						bro.improveMood(1.0, "Gained confidence in your leadership");

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
		if (this.World.getTime().Days <= 10)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() == 1 || brothers.len() > 5)
		{
			return;
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

