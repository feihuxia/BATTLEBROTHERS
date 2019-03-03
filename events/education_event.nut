this.education_event <- this.inherit("scripts/events/event", {
	m = {
		DumbGuy = null,
		Scholar = null
	},
	function create()
	{
		this.m.ID = "event.education";
		this.m.Title = "路上…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_15.png[/img]在你的旅程中， %scholar% 对于 %dumbguy%知识的不足很感兴趣。%scholar_short%那么说， 如果有时间的话， 还可以教他们一点东西。%dumbguy_short% 可以把一只脚放在另一只前面 - 而且有时候非常自信 - 但是你想他的能力也只能到此为止了。不只是那样， 而且%scholar_short% 对于过去的事情非常容易沮丧。教育这个哑巴兄弟可能只是一种自我膨胀的练习。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "看你能教他些什么。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 60 ? "B" : "C";
					}

				},
				{
					Text = "不管 %dumbguy% 。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Scholar.getImagePath());
				this.Characters.push(_event.m.DumbGuy.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_15.png[/img]{你遇到了 %scholar% 还有%dumbguy% 盯着一片灰尘。沿着黄颜色的画布你看到 %scholar_short% 画出了几何形状， 字母， 数字， 还有那些看起来像是星座的东西。看来他们今天摆弄这个东西几个小时了。 \n\n他拿着一只教学杆子， %scholar% 疯狂地制造一个星座想要知道那是什么。%dumbguy%，带着痛苦的表情，猜测是一只羊。%scholar% 抓着他的教学杆子然后在他的图画上面踢了一堆泥巴。那是一匹马!一匹马!%scholar% 重重地叹了一口气然后走开了。个人而言， 你以为那是一只螃蟹。| 你发现 %scholar% 站在那里 %dumbguy%.数着甲壳虫，不要它们， 那个学习的人愤愤地说。%dumbguy% 看着他充满甲壳虫液体的双手 {昆虫的碎片 | 曾经是昆虫}点缀着他的双手。他点头， 明白了， 然后想要把甲壳虫的腿拉开。%scholar%发出你从未听过的誓言。| 你发现%scholar% 和%dumbguy%对彼此大声叫着。看起来他们两人争得面红耳赤。%dumbguy_short% 说他不管他是不是很蠢， 而且 %scholar_short%说每一个人都应该学习。看起来 %dumbguy_short% 宁愿走开留下他的装置 %scholar_short% 转身走开。估计那是两个人学习的终点。| 你发现 %dumbguy% 蹲在一条小溪旁边， 盯着水中的倒影在沉思。他一定是诚实好一会儿了因为他看起来有点晒伤了。你问他是不是还好，他解释说他还不是很 \'明白\' %scholar%教的东西，而且 %scholar% 在他最后放弃的时候几乎要发疯。你解释说 %dumbguy% 不需要看起来很聪明， 他只需要知道如何去使用剑和弓箭。毕竟那才是你雇佣他的目的。那个男人想要隐藏他的笑容， 但是流动的水出卖了他。你回到营地然后你告诉 %scholar%休息一会儿。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "{你怎么就学不进去呢？！ | 无知是福。}",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Scholar.getImagePath());
				this.Characters.push(_event.m.DumbGuy.getImagePath());
				_event.m.Scholar.worsenMood(2.0, "Failed to teach " + _event.m.DumbGuy.getName() + " anything");

				if (_event.m.Scholar.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List = [
						{
							id = 10,
							icon = this.Const.MoodStateIcon[_event.m.Scholar.getMoodState()],
							text = _event.m.Scholar.getName() + this.Const.MoodStateEvent[_event.m.Scholar.getMoodState()]
						}
					];
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_15.png[/img]{你遇上 %dumbguy% 盯着桌子上的几个硬币在思考。你问他他正在做什么他说他想要搞清楚要省下来多少钱才能够退休开始时， 你很惊讶他是怎么知道退休这个词的。然后， 计算？看来你可能应该欠 %scholar% 一品脱。| 你发现%dumbguy% 坐在树墩上在卷轴上写的东西。当你问他在做什么的时候， 他说他在写一封信。当你问他写给谁的时候， 这个男人腼腆的抬头笑着问道，有什么问题吗？就在那时，你发现 %scholar% 站在远处，交叉着手臂， 一副满足的表情在他脸上。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真有趣。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Scholar.getImagePath());
				this.Characters.push(_event.m.DumbGuy.getImagePath());
				_event.m.Scholar.improveMood(2.0, "Taught " + _event.m.DumbGuy.getName() + " something");
				_event.m.DumbGuy.getSkills().removeByID("trait.dumb");
				this.List.push({
					id = 10,
					icon = "ui/traits/trait_icon_17.png",
					text = _event.m.DumbGuy.getName() + " is no longer dumb"
				});

				if (_event.m.Scholar.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Scholar.getMoodState()],
						text = _event.m.Scholar.getName() + this.Const.MoodStateEvent[_event.m.Scholar.getMoodState()]
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

		local dumb_candidates = [];
		local scholar_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.dumb"))
			{
				dumb_candidates.push(bro);
			}
			else if ((bro.getBackground().getID() == "background.monk" || bro.getBackground().getID() == "background.historian") && !bro.getSkills().hasSkill("trait.hesitant"))
			{
				scholar_candidates.push(bro);
			}
		}

		if (dumb_candidates.len() == 0 || scholar_candidates.len() == 0)
		{
			return;
		}

		this.m.DumbGuy = dumb_candidates[this.Math.rand(0, dumb_candidates.len() - 1)];
		this.m.Scholar = scholar_candidates[this.Math.rand(0, scholar_candidates.len() - 1)];
		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"dumbguy",
			this.m.DumbGuy.getName()
		]);
		_vars.push([
			"dumbguy_short",
			this.m.DumbGuy.getNameOnly()
		]);
		_vars.push([
			"scholar",
			this.m.Scholar.getName()
		]);
		_vars.push([
			"scholar_short",
			this.m.Scholar.getNameOnly()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.DumbGuy = null;
		this.m.Scholar = null;
	}

});

