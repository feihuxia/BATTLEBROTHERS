this.beggar_begs_event <- this.inherit("scripts/events/event", {
	m = {
		Beggar = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.beggar_begs";
		this.m.Title = "营地…";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]{你观察物品栏的时候，发现%beggar%在外围徘徊。你叹了口气，对着前一位乞丐，问他想要什么。他跟穷人一样伸出手，问你能不能给他几个克朗。| %beggar%明显技能十分线束，他靠近你，嘴里不停争吵，倒空了瓶子。前一位乞丐很倒霉，他只需要几个克朗就行了。| %otherguy%告诉你说，%beggar%会聚集在营地周围，讨要克朗。很明显，前面的乞丐需要更多，他喋喋不休地向所有愿意倾听的人说着悲惨的故事。听到这个消息后，你亲自过去看他，但你还没开口，那个人就自说自话起来了。他说完后看着你的眼睛，想知道你是否会给他点什么。| 很明显，%beggar%前面的乞丐需要一些帮助。他向你走过来，希望你能给他几个克朗。他看起来十分可怜，不过他训练过很多次，知道如何让自己看起来很贫穷，所以很难分辨真假。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "回去干活！",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "给你几个克朗。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Beggar.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]{你对乞丐说，如果他不回去工作，你就会那刀把他的手砍掉。那人耸耸肩，差不多按照说的做了。比预料中更简单。| 你让乞丐去工作的时候，他耸耸肩。你感觉有点难受，不过随即想到他们是如何缠着你的。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Ok.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Beggar.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]{乞丐收下克朗，带着笑容去工作了。| 你对他们的伎俩感到厌倦，给了乞丐几个克朗，并告诉他回去工作。他向你鞠了一躬表示感谢，而且让你惊讶的是，他竟然回去工作了。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Ok.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Beggar.getImagePath());
				this.World.Assets.addMoney(-10);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]10[/color] 克朗"
				});
				_event.m.Beggar.improveMood(0.5, "Got a few extra crowns from you");

				if (_event.m.Beggar.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Beggar.getMoodState()],
						text = _event.m.Beggar.getName() + this.Const.MoodStateEvent[_event.m.Beggar.getMoodState()]
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
			if (bro.getBackground().getID() == "background.beggar")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Beggar = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 5;

		do
		{
			local bro = brothers[this.Math.rand(0, brothers.len() - 1)];

			if (bro.getID() != this.m.Beggar.getID())
			{
				this.m.OtherGuy = bro;
			}
		}
		while (this.m.OtherGuy == null);
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"beggar",
			this.m.Beggar.getNameOnly()
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
		this.m.Beggar = null;
		this.m.OtherGuy = null;
	}

});

