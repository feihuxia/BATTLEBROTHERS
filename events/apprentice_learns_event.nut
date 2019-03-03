this.apprentice_learns_event <- this.inherit("scripts/events/event", {
	m = {
		Apprentice = null,
		Teacher = null
	},
	function create()
	{
		this.m.ID = "event.apprentice_learns";
		this.m.Title = "营地…";
		this.m.Cooldown = 90.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]学徒%apprentice%成为了%teacher%的守卫。剑圣岁数已经很大，他非常希望帮助这位年轻人成为一名更好的战士。学徒用了一把真正的剑，但剑圣用的是木剑。通过不同的武器选择，剑圣表达了定位，寻找突破口，以及远离危险的重要性。\n\n虽然他岁数已大，但还是十分敏捷，学徒根本无法打到他半分。学徒使用聪明的招数之后，剑圣知道自己会被困住，因此他拉进和学徒之间的距离，然后踩到他的脚上。学徒向后倾斜，拉开距离，但是他的脚没法移动。他突然失去平衡，倒在地上，抬头的时候发现自己正被一把木剑指着。\n\n他拍了拍自己身上的灰尘，再次站了起来。不得不说，这次他取得了一点小小的进步。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干的漂亮！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Apprentice.getImagePath());
				this.Characters.push(_event.m.Teacher.getImagePath());
				local meleeSkill = this.Math.rand(2, 4);
				local meleeDefense = this.Math.rand(2, 4);
				_event.m.Apprentice.getBaseProperties().MeleeSkill += meleeSkill;
				_event.m.Apprentice.getBaseProperties().MeleeDefense += meleeDefense;
				_event.m.Apprentice.getSkills().update();
				_event.markAsLearned();
				_event.m.Apprentice.improveMood(1.0, "Learned from " + _event.m.Teacher.getName());
				_event.m.Teacher.improveMood(0.5, "Has taught " + _event.m.Apprentice.getName() + " something");
				this.List = [
					{
						id = 16,
						icon = "ui/icons/melee_skill.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + meleeSkill + "[/color] 近战技能"
					},
					{
						id = 17,
						icon = "ui/icons/melee_defense.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + meleeDefense + "[/color] 近战防御"
					}
				];

				if (_event.m.Apprentice.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Apprentice.getMoodState()],
						text = _event.m.Apprentice.getName() + this.Const.MoodStateEvent[_event.m.Apprentice.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]退休后又重新工作的%teacher%很喜欢%apprentice%。他们俩一有机会就进行训练。这位老战士相信，在进攻中可以让他学会如何用刀，斧，还有权杖造成更多伤害。可是他们用的是战团的用餐装备，然后进攻人偶。少年在训练中用到那些盘子的时候，结果一团糟。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干的漂亮！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Apprentice.getImagePath());
				this.Characters.push(_event.m.Teacher.getImagePath());
				local meleeSkill = this.Math.rand(2, 4);
				local resolve = this.Math.rand(2, 5);
				_event.m.Apprentice.getBaseProperties().MeleeSkill += meleeSkill;
				_event.m.Apprentice.getBaseProperties().Bravery += resolve;
				_event.m.Apprentice.getSkills().update();
				_event.markAsLearned();
				_event.m.Apprentice.improveMood(1.0, "Learned from " + _event.m.Teacher.getName());
				_event.m.Teacher.improveMood(0.25, "Has taught " + _event.m.Apprentice.getName() + " something");
				this.List = [
					{
						id = 16,
						icon = "ui/icons/melee_skill.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + meleeSkill + "[/color] 近战技能"
					},
					{
						id = 16,
						icon = "ui/icons/bravery.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + resolve + "[/color] 决心"
					}
				];

				if (_event.m.Apprentice.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Apprentice.getMoodState()],
						text = _event.m.Apprentice.getName() + this.Const.MoodStateEvent[_event.m.Apprentice.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]佣兵%teacher%身边似乎围绕着一只小鸟：年轻的%apprentice%。在雇佣兵的战团中，学徒非常想向经验丰富的人学习。训练的时候，你发现佣兵主要把重点放在锻炼身体上。速度比对手快，超过对手，跟用剑刺穿他的脑袋一样重要。少年看起来十分坚定，获得了之前没有的勇气。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干的漂亮！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Apprentice.getImagePath());
				this.Characters.push(_event.m.Teacher.getImagePath());
				local meleeSkill = this.Math.rand(2, 4);
				local initiative = this.Math.rand(4, 6);
				local stamina = this.Math.rand(2, 4);
				_event.m.Apprentice.getBaseProperties().MeleeSkill += meleeSkill;
				_event.m.Apprentice.getBaseProperties().Initiative += initiative;
				_event.m.Apprentice.getBaseProperties().Stamina += stamina;
				_event.m.Apprentice.getSkills().update();
				_event.markAsLearned();
				_event.m.Apprentice.improveMood(1.0, "Learned from " + _event.m.Teacher.getName());
				_event.m.Teacher.improveMood(0.25, "Has taught " + _event.m.Apprentice.getName() + " something");
				this.List = [
					{
						id = 16,
						icon = "ui/icons/melee_skill.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + meleeSkill + "[/color] 近战技能"
					},
					{
						id = 17,
						icon = "ui/icons/initiative.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + initiative + "[/color] 主动性"
					},
					{
						id = 17,
						icon = "ui/icons/fatigue.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + stamina + "[/color] 最大疲劳"
					}
				];

				if (_event.m.Apprentice.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Apprentice.getMoodState()],
						text = _event.m.Apprentice.getName() + this.Const.MoodStateEvent[_event.m.Apprentice.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_05.png[/img]有好几次，你发现%apprentice%一直在远方看着%teacher%。年轻的学徒似乎对雇佣骑士的野蛮暴力更感兴趣。几天之后，骑士邀请青年过来谈谈。你不知道他们说了些什么，不过你发现他们开始一起训练了。雇佣骑士并不是一个友善的训练者。他经常打那位少年，让他变得更强壮。一开始的时候，学徒非常害怕被打，不过现在，他面对这种逆境的时候，已经变得十分坚决了。雇佣骑士告诉他如何更快，更有效率地击杀。在你听到的对话中，他们似乎并没有对防御做过多重视，不过如果对手已死，谁还需要防御呢？",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干的漂亮！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Apprentice.getImagePath());
				this.Characters.push(_event.m.Teacher.getImagePath());
				local meleeSkill = this.Math.rand(2, 4);
				local hitpoints = this.Math.rand(3, 5);
				local stamina = this.Math.rand(3, 5);
				_event.m.Apprentice.getBaseProperties().MeleeSkill += meleeSkill;
				_event.m.Apprentice.getBaseProperties().Hitpoints += hitpoints;
				_event.m.Apprentice.getBaseProperties().Stamina += stamina;
				_event.m.Apprentice.getSkills().update();
				_event.markAsLearned();
				_event.m.Apprentice.improveMood(1.0, "Learned from " + _event.m.Teacher.getName());
				_event.m.Teacher.improveMood(0.25, "Has taught " + _event.m.Apprentice.getName() + " something");
				this.List = [
					{
						id = 16,
						icon = "ui/icons/melee_skill.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + meleeSkill + "[/color] 近战技能"
					},
					{
						id = 17,
						icon = "ui/icons/health.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + hitpoints + "[/color] 生命值"
					},
					{
						id = 17,
						icon = "ui/icons/fatigue.png",
						text = _event.m.Apprentice.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + stamina + "[/color] 最大疲劳"
					}
				];

				if (_event.m.Apprentice.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Apprentice.getMoodState()],
						text = _event.m.Apprentice.getName() + this.Const.MoodStateEvent[_event.m.Apprentice.getMoodState()]
					});
				}
			}

		});
	}

	function markAsLearned()
	{
		this.m.Apprentice.getTags().add("learned");
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local apprentice_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() > 3 && bro.getBackground().getID() == "background.apprentice" && !bro.getTags().has("learned"))
			{
				apprentice_candidates.push(bro);
			}
		}

		if (apprentice_candidates.len() < 1)
		{
			return;
		}

		local teacher_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() < 6)
			{
				continue;
			}

			if (bro.getBackground().getID() == "background.swordmaster" || bro.getBackground().getID() == "background.old_swordmaster" || bro.getBackground().getID() == "background.retired_soldier" || bro.getBackground().getID() == "background.hedgeknight" || bro.getBackground().getID() == "background.sellsword")
			{
				teacher_candidates.push(bro);
			}
		}

		if (teacher_candidates.len() < 1)
		{
			return;
		}

		this.m.Apprentice = apprentice_candidates[this.Math.rand(0, apprentice_candidates.len() - 1)];
		this.m.Teacher = teacher_candidates[this.Math.rand(0, teacher_candidates.len() - 1)];
		this.m.Score = (apprentice_candidates.len() + teacher_candidates.len()) * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"apprentice",
			this.m.Apprentice.getNameOnly()
		]);
		_vars.push([
			"teacher",
			this.m.Teacher.getNameOnly()
		]);
	}

	function onDetermineStartScreen()
	{
		if (this.m.Teacher.getBackground().getID() == "background.swordmaster" || this.m.Teacher.getBackground().getID() == "background.old_swordmaster")
		{
			return "A";
		}
		else if (this.m.Teacher.getBackground().getID() == "background.retired_soldier")
		{
			return "B";
		}
		else if (this.m.Teacher.getBackground().getID() == "background.sellsword")
		{
			return "C";
		}
		else
		{
			return "D";
		}
	}

	function onClear()
	{
		this.m.Apprentice = null;
		this.m.Teacher = null;
	}

});

