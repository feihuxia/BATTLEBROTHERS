this.disowned_noble_reminisces_event <- this.inherit("scripts/events/event", {
	m = {
		Disowned = null
	},
	function create()
	{
		this.m.ID = "event.disowned_noble_reminisces";
		this.m.Title = "营地…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]你发现 %disowned%独自坐在营帐外面你身后充满了欢乐的声音还有篝火燃烧的声音，你走近那个人问他怎么了。他送了耸肩。%SPEECH_ON%没什么事情， 先生， 只是在思考而已。尽管我觉得有时候会轻易误会他人的意思。%SPEECH_OFF%轻笑着，他分给你一点酒你喝了一点。坐在他旁边，你问他他正在\'思考\' 什么事情。这个贵族又在吃耸了耸肩。%SPEECH_ON%啊，真的没什么事。只是想家了。我现在离家很远，我对于家最后的记忆不是很好，但是我发现我自己还是想再次回到那里。想家对我来说简直是一种贵族病， 猜猜看。%SPEECH_OFF%你把酒还给他他可能比你更需要它。趁你头脑还清醒， 你想要说出你的真心话...",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让你的老家见鬼去，你现在和我们在一起了。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "想一想老家没有什么不对。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Disowned.getImagePath());
				_event.m.Disowned.getTags().set("disowned_noble_reminisces", true);
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_26.png[/img]你说的。%SPEECH_ON%那个地方只是一个房子不是家。你在不同的时候渴望一个不同的地方， 当你在这个地方的时候，就在这里， 就在当下。那个%companyname%照顾你， 而你也组成他，只有在一起我们才能够生存。%SPEECH_OFF%那个男人就那么看着他的酒看了一会儿。他笑了， 好下去， 然后就过去了。%SPEECH_ON%那就对了，我觉得就应该是那个样子。谢谢你， 队长。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "不客气。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Disowned.getImagePath());
				local resolve = this.Math.rand(1, 3);
				_event.m.Disowned.getBaseProperties().Bravery += resolve;
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Disowned.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + resolve + "[/color] 决心"
				});
				_event.m.Disowned.improveMood(1.0, "Had a good talk with you");

				if (_event.m.Disowned.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Disowned.getMoodState()],
						text = _event.m.Disowned.getName() + this.Const.MoodStateEvent[_event.m.Disowned.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_26.png[/img]你趴在那个人的肩膀然后说。%SPEECH_ON%嘿嘿， 想一想老家对灵魂是有益的，即使那样屁用也没有并且残忍和邪恶让你在晚上难以入睡。但是那只是暂时的。你回顾过去， 你感觉那一切，然后你就翻过那一页。你只能是稍稍回顾一下而不能是沉溺在过去。每一个这里的人都有过去， %disowned%， 那样想的话你就不孤单了。%SPEECH_OFF%这个贵族盯着地面一会儿。他缓缓的点头。%SPEECH_ON%是的是的就是那样子。我想我的潜意识里也担心我想要回到那里。我在想着坐在火堆边， 烟从烟囱里散出去， 柔和的烛光从窗口射出去，而我的家人在那里等我。我忘记了锁门，看家犬冲了出去， 而那些我爱的人告诉我绝对不要回去除非我被放在一个骨灰盒里。我太沉溺于我的过去了老是去幻想它，而我想你帮助我意识到了那一点。谢谢你。我知道， 有一天， 我不应该再继续梦想 %companyname%，反而时而带着我应该牢牢的记住它。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "战团很明白。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Disowned.getImagePath());
				local resolve = this.Math.rand(1, 3);
				_event.m.Disowned.getBaseProperties().Bravery += resolve;
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Disowned.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + resolve + "[/color] 决心"
				});
				_event.m.Disowned.improveMood(1.0, "Had a good talk with you");

				if (_event.m.Disowned.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Disowned.getMoodState()],
						text = _event.m.Disowned.getName() + this.Const.MoodStateEvent[_event.m.Disowned.getMoodState()]
					});
				}
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
			if (bro.getLevel() >= 5 && bro.getBackground().getID() == "background.disowned_noble" && !bro.getTags().get("disowned_noble_reminisces"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Disowned = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"disowned",
			this.m.Disowned.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Disowned = null;
	}

});

