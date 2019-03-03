this.brawler_teaches_event <- this.inherit("scripts/events/event", {
	m = {
		Brawler = null,
		Student = null
	},
	function create()
	{
		this.m.ID = "event.brawler_teaches";
		this.m.Title = "营地…";
		this.m.Cooldown = 70.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]有个影子从你后面走过来。你往回看的时候，发现%brawler%正站在那儿，眼神十分深沉。他弯了弯自己的指关节，然后问是否可以训练%noncom%。你问为什么。好斗者看着你。%SPEECH_ON%因为他很弱小。%SPEECH_OFF%嗯，很好。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "看看你能让他坚持多久。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "让他变坚强，是吗？",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "告诉他如何打架。",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Brawler.getImagePath());
				this.Characters.push(_event.m.Student.getImagePath());
				_event.m.Brawler.getTags().add("brawler_teaches");
				_event.m.Student.getTags().add("brawler_teaches");
				_event.m.Brawler.improveMood(0.25, "Has toughened up " + _event.m.Student.getName());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_06.png[/img]%brawler%和%noncom%在泥浆池里，手上裹着布和叶子，保护指关节，不让它们出拳的时候被折断。好斗者让训练者沿着战斗圈逆时针行走，向空气出拳，训练员会不时地对他拳打脚踢。那些人工作的时候浑身闪烁着汗水。如果%noncom%动作放慢，%brawler%就会狠狠打他，就像骑师打马那样。\n\n 一个小时后，%brawler%退后一步，让训练者攻击他。可想而这，这种攻击毫无目的，让人看了都觉得可怜。他们的攻击枯燥而漫长，毫无力量可言。好斗者不停躲避，并且对那些攻击他的人发动反击。%SPEECH_ON%看看你疲劳的时候会发生什么？所以我们必须接受训练。即使是最强大的人，如果没了呼吸，没了强健的突破，那也一事无成。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "看着这些已经让我觉得厌烦了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Brawler.getImagePath());
				this.Characters.push(_event.m.Student.getImagePath());
				local skill = this.Math.rand(2, 4);
				_event.m.Student.getBaseProperties().Stamina += skill;
				_event.m.Student.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/fatigue.png",
					text = _event.m.Student.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + skill + "[/color] 最大疲劳"
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_06.png[/img]好斗者让%noncom%安静地站着。他围着这个人走着，一边打量着他，一边压响自己的指关节。最后，他说出了自己的意图。%SPEECH_ON%我要揍到你崩溃为止。%SPEECH_OFF%训练者花了一会儿工夫才明白即将发生的事。他深吸一口气，然后点点头。%brawler%没有浪费一点时间，抡起拳头朝着那个人的胸口砸去。每次他的肩膀被击中时都会倒下，然后重新爬起来，如此循环。\n\n好斗者继续循环发动进攻。并不是每次攻击都很坚定，大多数攻击都会造成痛苦，但不会造成永久性的伤害。如果好斗者愿意，完全可以用拳头杀了这个人，但这并不是此次训练的意义所在。你意识到，这种“变强大”的方式，可能正是好斗者自己所经历过的。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那些没有消灭你的东西,会使你变得更强壮？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Brawler.getImagePath());
				this.Characters.push(_event.m.Student.getImagePath());
				local skill = this.Math.rand(2, 4);
				_event.m.Student.getBaseProperties().Hitpoints += skill;
				_event.m.Student.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/health.png",
					text = _event.m.Student.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + skill + "[/color] 生命值"
				});
				_event.m.Student.addLightInjury();
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.Student.getName() + " suffers light wounds"
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_06.png[/img]%brawler%强力的好斗者斜靠着，手臂做出防御的姿势，%noncom%站在附近，想模仿他的姿势。好斗者地下身子，攻击%noncom%的手臂下方，他用双手握住那人的拳头，把他举起来扔到地上。%brawler%退后一步，压响自己的指关节，叫%noncom%站起来。%SPEECH_ON%你必须做好两手准备：我从下面攻击，或者从上面攻击。%SPEECH_OFF%%noncom%拍了拍身上的灰尘，抱怨了一两句。%SPEECH_ON%我怎么可能同时做到这两点？%SPEECH_OFF%好斗者忽略了他的问题，让他发动进攻。%noncom%答应了，握紧拳头就开始进攻。%brawler%侧着身子让攻击便宜，然后对%noncom%的脚下发动反攻。拳头战士再次压响自己的指关节，吐了口口水。%SPEECH_ON%多练习。就这样。起来，我们继续。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "或许有一天他会成为真正的雇佣兵。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Brawler.getImagePath());
				this.Characters.push(_event.m.Student.getImagePath());
				local attack = this.Math.rand(1, 2);
				local defense = this.Math.rand(1, 2);
				_event.m.Student.getBaseProperties().MeleeSkill += attack;
				_event.m.Student.getBaseProperties().MeleeDefense += defense;
				_event.m.Student.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/melee_skill.png",
					text = _event.m.Student.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + attack + "[/color] 近战技能"
				});
				this.List.push({
					id = 16,
					icon = "ui/icons/melee_defense.png",
					text = _event.m.Student.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + defense + "[/color] 近战防御"
				});
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates_brawler = [];
		local candidates_student = [];

		foreach( bro in brothers )
		{
			if (bro.getTags().has("brawler_teaches"))
			{
				continue;
			}

			if (bro.getLevel() >= 3 && bro.getBackground().getID() == "background.brawler")
			{
				candidates_brawler.push(bro);
			}
			else if (bro.getLevel() < 3 && !bro.getBackground().isCombatBackground())
			{
				candidates_student.push(bro);
			}
		}

		if (candidates_brawler.len() == 0 || candidates_student.len() == 0)
		{
			return;
		}

		this.m.Brawler = candidates_brawler[this.Math.rand(0, candidates_brawler.len() - 1)];
		this.m.Student = candidates_student[this.Math.rand(0, candidates_student.len() - 1)];
		this.m.Score = (candidates_brawler.len() + candidates_student.len()) * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"brawler",
			this.m.Brawler.getNameOnly()
		]);
		_vars.push([
			"noncom",
			this.m.Student.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Brawler = null;
		this.m.Student = null;
	}

});

