this.archery_stunt_event <- this.inherit("scripts/events/event", {
	m = {
		Clown = null,
		Archer = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.archery_stunt";
		this.m.Title = "营地中...";
		this.m.Cooldown = 90.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]外面的一些骚动把你引出了你的帐篷. 兄弟们分散坐在几个树桩上,有些人干脆直接席地而坐, 他们都十分急切的望着什么东西. 眯着双眼尝试看清远处的某项事物, 你发现 %clown% 和 %archer% 在做一件很奇怪的事情. 其中一人头上顶着一个苹果站在原地, 而另外一人背对着他正在走开 - 手里还拿着一张弓.\n\n你询问 %otherguy% 那两人在做什么,他向你解释说他们正在尝试某种特技或者把戏,包括用弓把一人顶在头上的水果射下来. 你感到很震惊, 你惊呼道那十分危险, 对此, 兄弟笑着说正是如此才精彩.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "马上给我停下来!",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "好吧... 这应该会很有趣.",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= _event.m.Archer.getCurrentProperties().RangedSkill)
						{
							return "C";
						}
						else
						{
							return "B1";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Clown.getImagePath());
				this.Characters.push(_event.m.Archer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B1",
			Text = "[img]gfx/ui/events/event_10.png[/img]你理清了这里正在发生什么. 兄弟们向你望过来, 等待着你的发言, 但你没有进行什么长篇大论, 相反, 你走过去在他们中间找了个空位坐了下来. 兄弟们欢呼了起来, 但人群很快就安静了下来, 低声询问 %clown% 和 %archer% 是否已准备好.%SPEECH_ON%你可一定要射中那个苹果啊!%SPEECH_OFF%一位兄弟呼喊着. 他喊完, 人们大声的笑了起来.%SPEECH_ON%从这距离看 %clown_short% 的鼻子在我看来都像是一个苹果.%SPEECH_OFF%人们笑的更欢了, 但他们始终是紧张的, 因为特技就要开始了.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "哦!",
					function getResult( _event )
					{
						return "B2";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Clown.getImagePath());
				this.Characters.push(_event.m.Archer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B2",
			Text = "[img]gfx/ui/events/event_10.png[/img]%archer% 调整他的肩膀朝向 %clown% 后提起了他的弓, 他手中的弓被拉起弓弦后化作新月的形状. 你看不到 %clown% 的脸, 但你认为他的双眼是紧闭的. 弓弦被释放开. 发出了震鸣声. 短暂的消失了. %clown% 像石头一般向后仰倒, 痛苦的捂着自己的脸. 这看起来可不妙. 他尖叫了起来. 人们发出了惋惜之声. %archer% 缓慢的垂下双臂, 死死的望着手中的弓, 仿佛一切错误都是由它铸就的一般.\n\n 最终, %clown% 从你身边走过, 一根箭死死的钉在他的头上. 一位兄弟绕过他, 趁着人群始终处于混乱之中悄无声息的偷吃掉了那枚苹果.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那可能会给他留下一个标记...",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Clown.getImagePath());
				this.Characters.push(_event.m.Archer.getImagePath());
				local injury = _event.m.Clown.addInjury(this.Const.Injury.Archery);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.Clown.getName() + " 遭受 " + injury.getNameOnly()
				});
				_event.m.Archer.worsenMood(2.0, "严重伤势 " + this.event.m.Clown.getName() + " 因为意外");

				if (_event.m.Archer.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Archer.getMoodState()],
						text = _event.m.Archer.getName() + this.Const.MoodStateEvent[_event.m.Archer.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Clown.getID() || bro.getID() == _event.m.Archer.getID())
					{
						continue;
					}

					if (bro.getSkills().hasSkill("trait.bright") || bro.getSkills().hasSkill("trait.fainthearted"))
					{
						bro.worsenMood(1.0, "Felt for " + _event.m.Clown.getName());

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
			Text = "[img]gfx/ui/events/event_10.png[/img]The men cheer as you give an affirming nod. You take a seat amongst them as %archer% and %clown% get ready, the former nocking an arrow while the latter balances an apple atop his head. When the fruit is good and steady, the archer draws back his bow, forming but a silhouette of man, wood, and string, a crescent of determination as he aims downfield. The men are exchanging bets on whether or not he misses. You want to look away, but the spectacle truly is too much.\n\n A great gasp follows the arrow\'s release, as though some ominous event long foretold had finally happened. Men reel back in their seats, wincing and gritting their teeth. The apple is shot off %clown%\'s head, fruit and arrow spinning away. After a brief silence, the men erupt in cheers. %clown% takes a bow, while %archer% slackens his draw and looks a bit relieved.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Nailed it.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Clown.getImagePath());
				this.Characters.push(_event.m.Archer.getImagePath());
				_event.m.Clown.getBaseProperties().Bravery += 1;
				_event.m.Clown.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Clown.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] Resolve"
				});
				_event.m.Archer.getBaseProperties().RangedSkill += 1;
				_event.m.Archer.getSkills().update();
				this.List.push({
					id = 17,
					icon = "ui/icons/ranged_skill.png",
					text = _event.m.Archer.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] Ranged Skill"
				});
				_event.m.Clown.improveMood(1.0, "Took part in a show");

				if (_event.m.Clown.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Clown.getMoodState()],
						text = _event.m.Clown.getName() + this.Const.MoodStateEvent[_event.m.Clown.getMoodState()]
					});
				}

				_event.m.Archer.improveMood(1, "Displayed his archery skills");

				if (_event.m.Archer.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Archer.getMoodState()],
						text = _event.m.Archer.getName() + this.Const.MoodStateEvent[_event.m.Archer.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Clown.getID() || bro.getID() == _event.m.Archer.getID())
					{
						continue;
					}

					if (bro.getMoodState() >= this.Const.MoodState.Neutral && this.Math.rand(1, 100) <= 10 && !bro.getSkills().hasSkill("trait.bright"))
					{
						bro.improveMood(1.0, "Felt entertained");

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
			ID = "D",
			Text = "You shake your head \'no\' as you walk out into the field and step between the two men.%SPEECH_ON%If y\'all wanted to play tricks, you should\'ve joined a circus. Now get back to work before someone gets seriously hurt.%SPEECH_OFF%A wave of disappointment washes over the men. A few even boo and give you a thumbs down or other, rowdier, gestures.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "It\'s for their own good.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Clown.getImagePath());
				this.Characters.push(_event.m.Archer.getImagePath());
				_event.m.Clown.worsenMood(1.0, "Was denied a request");

				if (_event.m.Clown.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Clown.getMoodState()],
						text = _event.m.Clown.getName() + this.Const.MoodStateEvent[_event.m.Clown.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Clown.getID())
					{
						continue;
					}

					if (bro.getMoodState() >= this.Const.MoodState.Neutral && this.Math.rand(1, 100) <= 10 && !bro.getSkills().hasSkill("trait.bright") && !bro.getSkills().hasSkill("trait.fainthearted"))
					{
						bro.worsenMood(1.0, "Didn\'t get the entertainment he had hoped for");

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
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local clown_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.bright") || bro.getSkills().hasSkill("trait.hesitant") || bro.getSkills().hasSkill("trait.craven") || bro.getSkills().hasSkill("trait.fainthearted") || bro.getSkills().hasSkill("trait.insecure"))
			{
				continue;
			}

			if ((bro.getBackground().getID() == "background.minstrel" || bro.getBackground().getID() == "background.juggler" || bro.getBackground().getID() == "background.vagabond") && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				clown_candidates.push(bro);
			}
		}

		if (clown_candidates.len() == 0)
		{
			return;
		}

		local archer_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.bright") || bro.getSkills().hasSkill("trait.hesitant") || bro.getSkills().hasSkill("trait.craven") || bro.getSkills().hasSkill("trait.fainthearted") || bro.getSkills().hasSkill("trait.insecure"))
			{
				continue;
			}

			if ((bro.getBackground().getID() == "background.hunter" || bro.getBackground().getID() == "background.poacher" || bro.getBackground().getID() == "background.sellsword" || bro.getBackground().getID() == "background.bowyer") && !bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				archer_candidates.push(bro);
			}
		}

		if (archer_candidates.len() == 0)
		{
			return;
		}

		this.m.Clown = clown_candidates[this.Math.rand(0, clown_candidates.len() - 1)];
		this.m.Archer = archer_candidates[this.Math.rand(0, archer_candidates.len() - 1)];
		this.m.Score = clown_candidates.len() * 3;

		do
		{
			this.m.OtherGuy = brothers[this.Math.rand(0, brothers.len() - 1)];
		}
		while (this.m.OtherGuy == null || this.m.OtherGuy.getID() == this.m.Clown.getID() || this.m.OtherGuy.getID() == this.m.Archer.getID());
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"clown",
			this.m.Clown.getName()
		]);
		_vars.push([
			"clown_short",
			this.m.Clown.getNameOnly()
		]);
		_vars.push([
			"archer",
			this.m.Archer.getName()
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
		this.m.Clown = null;
		this.m.Archer = null;
		this.m.OtherGuy = null;
	}

});

