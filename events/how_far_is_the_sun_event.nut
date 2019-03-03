this.how_far_is_the_sun_event <- this.inherit("scripts/events/event", {
	m = {
		Historian = null,
		Monk = null,
		Cultist = null,
		Archer = null,
		Other = null
	},
	function create()
	{
		this.m.ID = "event.how_far_is_the_sun";
		this.m.Title = "营地…";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]在休息的时候，手下的人讨论起太阳到底有多远。%otherbrother%抬头看着太阳，在差点把自己弄瞎之前咬紧牙关，不再凝视太阳。最终，他看回了地面。%SPEECH_ON%我敢打赌，大约有10到15英里那么远。%SPEECH_OFF%他点着头表示赞同自己的大致估计。%SPEECH_ON%可能没有那么远呢。我听说过远方大陆上的一个弓箭手用弓箭射太阳的故事。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [],
			function start( _event )
			{
				if (_event.m.Historian != null)
				{
					this.Options.push({
						Text = "%historianfull%，你有什么要说的吗？",
						function getResult( _event )
						{
							return "Historian";
						}

					});
				}

				if (_event.m.Monk != null)
				{
					this.Options.push({
						Text = "我敢打赌%monkfull%知道真相。",
						function getResult( _event )
						{
							return "Monk";
						}

					});
				}

				if (_event.m.Cultist != null)
				{
					this.Options.push({
						Text = "我知道你在思考，%cultistfull%。你怎么说？",
						function getResult( _event )
						{
							return "Cultist";
						}

					});
				}

				if (_event.m.Archer != null)
				{
					this.Options.push({
						Text = "%archerfull%，你为什么不试试？",
						function getResult( _event )
						{
							return "Archer";
						}

					});
				}

				this.Options.push({
					Text = "别说废话了。重新上路吧。",
					function getResult( _event )
					{
						return 0;
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "Historian",
			Text = "[img]gfx/ui/events/event_05.png[/img]历史学家%historian%说了起来。%SPEECH_ON%我对用弓箭射太阳这件事表示怀疑。跟你说说我读到过的一个更具有真实性的故事吧：东方的山上有一些人，他们用巨大的望远镜凝望夜空。他们认为太阳离我们很远。至少有1万英里那么远。他们还认为夜间的光来自于其他的太阳，还不是来自于死去英雄的灵魂。%SPEECH_OFF%%otherbrother%站了起来。%SPEECH_ON%说话经点脑子，蠢货，别在这说我们祖先的坏话。%SPEECH_OFF%历史学家点了点头。%SPEECH_ON%当然了！这只是种想法。%SPEECH_OFF%多么愚蠢的想法。这对%historian%这样的“智者”来说真是愚蠢至极。不少弟兄嘲笑起历史学家这样愚蠢的想法。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "他可真是个笑柄。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Historian.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Historian.getID() || bro.getBackground().getID() == "background.historian" || bro.getSkills().hasSkill("trait.bright"))
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 33)
					{
						bro.improveMood(0.5, "Entertained by " + _event.m.Historian.getName() + "\'s silly notions about the sun");

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
			ID = "Monk",
			Text = "[img]gfx/ui/events/event_05.png[/img]僧人%monk%开始说了起来。%SPEECH_ON%太阳既不远也不近。它是众神的眼睛，众神曾通过它来守望着我们。%SPEECH_OFF%%otherbrother%点了点头，但是接着，他又好气地问起了有关月亮的事。僧侣自信地笑着。%SPEECH_ON%你以为神会一直都照耀着我们吗？他们当然会让光线暗下来，好让我们能在夜里睡个好觉。%SPEECH_OFF%你点了点头。没错，古神们总是在照看着我们。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "保佑他们。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Monk.getID() || bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist" || bro.getBackground().getID() == "background.historian")
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 33)
					{
						bro.improveMood(0.5, "Encouraged by " + _event.m.Monk.getName() + "\'s preaching");

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
			ID = "Cultist",
			Text = "[img]gfx/ui/events/event_05.png[/img]异教徒%cultist%站了起来，看着太阳。在他一直盯着太阳的时候，一个阴影出现，遮住了他的脸，好像有什么实体物为他遮蔽着光。突然之间他抬起一只手，用他的手画下了某种空中的仪式。你确信他脸上的黑暗似乎跟着他画下的印记移动，就像某种变形纹身一样。当他完成这一切时，他坐了下来。%SPEECH_ON%太阳正在死去。%SPEECH_OFF%大家看上去很担心。有人插了句话。%SPEECH_ON%死去？你这话是什么意思？%SPEECH_OFF%%cultist%盯着他。%SPEECH_ON%Davkul的意志表明一切都会死亡。%SPEECH_OFF%一个人问道这是否意味着“Davkul”也会死亡。异教徒点了点头。%SPEECH_ON%当一切都已死亡，Davkul将会最终得到安息。一个更残酷的神将会死去。在Davkul的恩宠之下，他会在最后离开，为此，我们应该赞颂他。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "呃，好吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cultist.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Cultist.getID())
					{
						bro.improveMood(1.0, "Relished the opportunity to talk about the dying sun");

						if (bro.getMoodState() >= this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}
					else if (bro.getBackground().getID() == "background.cultist")
					{
						bro.improveMood(0.5, "Relished " + _event.m.Cultist.getName() + "\'s speech about the dying sun");

						if (bro.getMoodState() >= this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}
					else if (bro.getSkills().hasSkill("trait.superstitious"))
					{
						bro.worsenMood(1.0, "Terrified at the prospect of a dying sun");

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
			ID = "Archer",
			Text = "[img]gfx/ui/events/event_05.png[/img]%archer%接受了挑战，拿上了他的弓和几支箭矢。他舔了舔自己的手指，支撑着。%SPEECH_ON%风正合适来一次完美的射击。%SPEECH_OFF%弓箭手拔出一根箭矢，拉起弓，开始瞄准。那股猛烈的光非常迅速而刺眼。%SPEECH_OFF%该死，我什么也看不清。%SPEECH_OFF%他的视线被黑点占领，让他无法瞄准。箭矢射出，漫无目的地在太阳的宽广无边里飞行着。非常的宽广。他看向战团，眼神黯淡了下来，伸出手举着，好像在视线回来的时候试图稳住自己。%SPEECH_ON%我射中了吗？%SPEECH_OFF%%otherbrother%都强忍着不笑。%SPEECH_ON%正中目标！%SPEECH_OFF%人们爆发出一阵大笑。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "射得好，阁下！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Archer.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 33)
					{
						bro.improveMood(0.5, "Entertained by " + _event.m.Archer.getName() + "\'s attempt to shoot the sun");

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

		local candidate_historian = [];
		local candidate_monk = [];
		local candidate_cultist = [];
		local candidate_archer = [];
		local candidate_other = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.historian")
			{
				candidate_historian.push(bro);
			}
			else if (bro.getBackground().getID() == "background.monk")
			{
				candidate_monk.push(bro);
			}
			else if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
			{
				candidate_cultist.push(bro);
			}
			else if (bro.getBackground().getID() == "background.hunter" || bro.getBackground().getID() == "background.poacher" || bro.getBackground().getID() == "background.sellsword")
			{
				candidate_archer.push(bro);
			}
			else
			{
				candidate_other.push(bro);
			}
		}

		if (candidate_other.len() == 0)
		{
			return;
		}

		local options = 0;

		if (candidate_historian.len() != 0)
		{
			options = ++options;
		}

		if (candidate_monk.len() != 0)
		{
			options = ++options;
		}

		if (candidate_cultist.len() != 0)
		{
			options = ++options;
		}

		if (candidate_archer.len() != 0)
		{
			options = ++options;
		}

		if (options < 2)
		{
			return;
		}

		if (candidate_historian.len() != 0)
		{
			this.m.Historian = candidate_historian[this.Math.rand(0, candidate_historian.len() - 1)];
		}

		if (candidate_monk.len() != 0)
		{
			this.m.Monk = candidate_monk[this.Math.rand(0, candidate_monk.len() - 1)];
		}

		if (candidate_cultist.len() != 0)
		{
			this.m.Cultist = candidate_cultist[this.Math.rand(0, candidate_cultist.len() - 1)];
		}

		if (candidate_archer.len() != 0)
		{
			this.m.Archer = candidate_archer[this.Math.rand(0, candidate_archer.len() - 1)];
		}

		this.m.Other = candidate_other[this.Math.rand(0, candidate_other.len() - 1)];
		this.m.Score = options * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"historian",
			this.m.Historian != null ? this.m.Historian.getNameOnly() : ""
		]);
		_vars.push([
			"historianfull",
			this.m.Historian != null ? this.m.Historian.getName() : ""
		]);
		_vars.push([
			"monk",
			this.m.Monk != null ? this.m.Monk.getNameOnly() : ""
		]);
		_vars.push([
			"monkfull",
			this.m.Monk != null ? this.m.Monk.getName() : ""
		]);
		_vars.push([
			"cultist",
			this.m.Cultist != null ? this.m.Cultist.getNameOnly() : ""
		]);
		_vars.push([
			"cultistfull",
			this.m.Cultist != null ? this.m.Cultist.getName() : ""
		]);
		_vars.push([
			"archer",
			this.m.Archer != null ? this.m.Archer.getNameOnly() : ""
		]);
		_vars.push([
			"archerfull",
			this.m.Archer != null ? this.m.Archer.getName() : ""
		]);
		_vars.push([
			"otherbrother",
			this.m.Other.getName()
		]);
	}

	function onClear()
	{
		this.m.Historian = null;
		this.m.Monk = null;
		this.m.Cultist = null;
		this.m.Archer = null;
		this.m.Other = null;
	}

});

