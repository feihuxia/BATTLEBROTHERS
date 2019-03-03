this.juggler_tempts_fate_event <- this.inherit("scripts/events/event", {
	m = {
		Juggler = null,
		NonJuggler = null
	},
	function create()
	{
		this.m.ID = "event.juggler_tempts_fate";
		this.m.Title = "营地…";
		this.m.Cooldown = 70.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]%juggler%这位身手敏捷杂耍者让一些弟兄们朝他丢匕首。看来他想展示一下自己的表演技巧。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让我们来瞧瞧你的能耐吧！",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 70 ? "C" : "Fail1";
					}

				},
				{
					Text = "我花钱雇你可不是让你做这个的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				_event.m.Juggler.getTags().add("juggler_tempted_fate");
			}

		});
		this.m.Screens.push({
			ID = "Fail1",
			Text = "[img]gfx/ui/events/event_05.png[/img]%nonjuggler%远远丢来一把匕首。匕首在空中旋转飞行着，从刀身上反射的光斑恰好划过了杂耍者的眼睛。他眨了一下眼，刀子正好扎进了他的肩上。他又眨了一下眼，这才感到阵阵刺痛。%juggler%不得不弯下腰，发出痛苦的呻吟声。一些人上前帮他料理伤口，而另一些人这忍不住捧腹大笑。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那伤口看上去就很疼！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				local injury = _event.m.Juggler.addInjury([
					{
						ID = "injury.injured_shoulder",
						Threshold = 0.25,
						Script = "injury/injured_shoulder_injury"
					}
				]);
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Juggler.getName() + " suffers " + injury.getNameOnly()
					}
				];
				_event.m.Juggler.worsenMood(1.0, "Failed his act and injured himself");

				if (_event.m.Juggler.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Juggler.getMoodState()],
						text = _event.m.Juggler.getName() + this.Const.MoodStateEvent[_event.m.Juggler.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Fail2",
			Text = "[img]gfx/ui/events/event_05.png[/img]按照%juggler%的要求，一位弟兄拿起斧子朝他丢去。斧子在空中旋转飞行着，其移动轨迹十分飘忽，似乎是投掷者有意而为的。杂耍者没有料到这一点。就在他试图抓取斧柄的时候，斧子直接击中其中一把匕首并砍中了他的肩膀上。他立刻跪倒在地，周围飞舞的匕首也散落一地。在一些人上前帮他处理伤口的同时，另一些人则禁不住放声大笑。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "他还好吗？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				local injury = _event.m.Juggler.addInjury(this.Const.Injury.Accident4);
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Juggler.getName() + " suffers " + injury.getNameOnly()
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "Fail3",
			Text = "[img]gfx/ui/events/event_05.png[/img]%nonjuggler%拿起了链枷，在犹豫片刻之后，把它扔给了%juggler%。那把武器的链子在飞行的途中绕住了把手。杂耍者似乎在为了拿住它在调整自己，但是在最后一颗，链子解了出来，带着致命的恶意抽打了过来。你看到那个人因为无法阻挡的灾祸而大睁的双眼。链枷犹如旋转的金属旋涡，钳向他的脸。链枷重重打在他的脸上，他打了个转，重重摔在了地上。一把掉下来的匕首插进他的腿里，而另一把掉下来的斧子也砍向了他的臀部。那个男人发出惊恐的喘气声，所有人都冲向他，想要帮忙。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "他还活着吗？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				local injury = _event.m.Juggler.addInjury(this.Const.Injury.BluntHead);
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Juggler.getName() + " suffers " + injury.getNameOnly()
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]你坐了下来，并让其他人朝%juggler%丢几下匕首和小刀。这些武器形态各异，但我们的表演者轻松地接到了所有的武器，并开始将它们丢到空中进行杂耍表演。这些武器在阳光的照射下闪闪发光。鉴于每把武器的重量各不相同，你对他那细致的操控技巧而感到震惊。\n\n 当然，精彩的表演还未结束。杂耍者现在腾出一只手来招呼大家朝他丢一把斧头。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这肯定会很有意思！",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 60 ? "D" : "Fail2";
					}

				},
				{
					Text = "到此为止。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 10)
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
			Text = "[img]gfx/ui/events/event_05.png[/img]%nonjuggler%拿起一把斧头朝正处于表演中的%juggler%丢去。杂耍者手中飞舞的武器似乎瞬间就收纳了这把斧头，一切都如同行云流水。旁观人群中发出了阵阵掌声和欢呼，而一些人则在奸笑着等待表演出错的瞬间。\n\n 但表演似乎仍未结束。这一次，杂耍者已经没有精力再腾出一只手了。他只是让围观的人再朝他丢一把连枷。有一个人站了起来。%SPEECH_ON%他刚刚是不是说要连枷？%SPEECH_OFF%杂耍者跺了跺脚。%SPEECH_ON%没错，就是连枷！朝我丢一个连枷！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "虽然这看似不可能……但我想见识一下！",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 50 ? "E" : "Fail3";
					}

				},
				{
					Text = "够了。到此为止吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				_event.m.Juggler.getBaseProperties().Bravery += 1;
				_event.m.Juggler.getBaseProperties().MeleeSkill += 1;
				_event.m.Juggler.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Juggler.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] 决心"
				});
				this.List.push({
					id = 16,
					icon = "ui/icons/melee_skill.png",
					text = _event.m.Juggler.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] 近战技能"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 20)
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
			ID = "E",
			Text = "[img]gfx/ui/events/event_05.png[/img]有人拿来了一把连枷，并朝%juggler%丢去。所有人都为杂耍者的‘表演’捏了一把汗。不过，与那把斧头一样，这把连枷很快就融入了那堆飞舞的武器中。人群中一下爆发出前所未有的欢呼和掌声。一些人松了一口气，擦了擦眉毛上的汗珠；而另一些人则一边奸笑一边拍手，似乎在为没有意外事件发生而感到失望，不过他们依然觉得这是一场非常震撼的表演。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Bravo!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				_event.m.Juggler.getBaseProperties().Bravery += 2;
				_event.m.Juggler.getBaseProperties().RangedDefense += 2;
				_event.m.Juggler.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Juggler.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+2[/color] 决心"
				});
				this.List.push({
					id = 16,
					icon = "ui/icons/ranged_defense.png",
					text = _event.m.Juggler.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+2[/color] 远程防御"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 30)
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

		local juggler_candidates = [];
		local nonjuggler_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				continue;
			}

			if (bro.getBackground().getID() == "background.juggler")
			{
				if (!bro.getTags().has("juggler_tempted_fate"))
				{
					juggler_candidates.push(bro);
				}
			}
			else
			{
				nonjuggler_candidates.push(bro);
			}
		}

		if (juggler_candidates.len() == 0 || nonjuggler_candidates.len() == 0)
		{
			return;
		}

		this.m.Juggler = juggler_candidates[this.Math.rand(0, juggler_candidates.len() - 1)];
		this.m.NonJuggler = nonjuggler_candidates[this.Math.rand(0, nonjuggler_candidates.len() - 1)];
		this.m.Score = juggler_candidates.len() * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"juggler",
			this.m.Juggler.getNameOnly()
		]);
		_vars.push([
			"nonjuggler",
			this.m.NonJuggler.getName()
		]);
	}

	function onClear()
	{
		this.m.Juggler = null;
		this.m.NonJuggler = null;
	}

});

