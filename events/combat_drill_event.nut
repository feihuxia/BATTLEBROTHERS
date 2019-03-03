this.combat_drill_event <- this.inherit("scripts/events/event", {
	m = {
		Teacher = null
	},
	function create()
	{
		this.m.ID = "event.combat_drill";
		this.m.Title = "营地…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]你走出帐篷，观察大家。很多新人都咕哝着什么，他们很紧张，彼此聚集在一起，或者拿着武器。%oldguard%走到你身边。%SPEECH_ON%我知道你在想什么。你觉得自己雇佣了一群无用之人。让我来训练他们，不让他们刚入战场就被兽人干掉，怎么样？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "很好，看看你是否能教他们如何对抗别人。",
					function getResult( _event )
					{
						return "B1";
					}

				},
				{
					Text = "很好，看看他们是否能学会使用弓箭。",
					function getResult( _event )
					{
						return "C1";
					}

				},
				{
					Text = "很好，让他们穿上真正的盔甲。",
					function getResult( _event )
					{
						return "D1";
					}

				},
				{
					Text = "不，他们得省点力气战斗。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Teacher.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B1",
			Text = "[img]gfx/ui/events/event_05.png[/img]%oldguard%要新宾拿起武器。等他们每个人都拿起剑以后，老卫兵对他们大喊，不是每个渴望你死透的敌人都都挥舞着同样的剑。不少人在急忙把剑换成斧子和长矛前点了头。队员装备好了，训练开始。通常，%oldguard%会教导基础知识，比如一个阵列怎么保护他人和自身。%SPEECH_ON%如果身边有兄弟，你就不需要眼观八方。但如果你们分开了，都是一个人，那就想想办法，别走上如今未知的道路，拿着把剑——我要先确保你们不会这样。%SPEECH_OFF%训练进行到了进攻，%oldguard%用各种武器展示了技巧。%SPEECH_ON%你可以用剑，斩，削，刺，还刺。躲过剑击有点难，因为它两边都能杀人。要是被我看见你们听了童话故事想拿剑去砍穿盔甲，我就亲自动手揍人。那是假的，别再幻想了！\n\n长矛对保持距离很有用。对盔甲伤害不大，但能保护你的安全。别拿尖的这头对着你。如果哪个穿盔甲的混蛋躲过了矛尖，那你应该合理动作别让那种事发生。\n\n最后，还有斧子。就把别人当成树然后砍就好了。现在开始练习吧！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让我看看你们的本事！",
					function getResult( _event )
					{
						return "B2";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Teacher.getImagePath());
				_event.m.Teacher.improveMood(0.5, "Has drilled the new recruits");
			}

		});
		this.m.Screens.push({
			ID = "B2",
			Text = "[img]gfx/ui/events/event_50.png[/img]训练进展十分顺利，虽然有些人身上碰到了，出现了淤青。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "做得好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Teacher.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getLevel() > 3)
					{
						continue;
					}

					local meleeSkill = this.Math.rand(0, 2);
					local meleeDefense = meleeSkill == 0 ? this.Math.rand(0, 2) : 0;
					bro.getBaseProperties().MeleeSkill += meleeSkill;
					bro.getBaseProperties().MeleeDefense += meleeDefense;
					bro.getSkills().update();

					if (meleeSkill > 0)
					{
						this.List.push({
							id = 16,
							icon = "ui/icons/melee_skill.png",
							text = bro.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + meleeSkill + "[/color] 近战技能"
						});
					}

					if (meleeDefense > 0)
					{
						this.List.push({
							id = 16,
							icon = "ui/icons/melee_defense.png",
							text = bro.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + meleeDefense + "[/color] 近战防御"
						});
					}

					local injuryChance = 33;

					if (bro.getSkills().hasSkill("trait.clumsy") || bro.getSkills().hasSkill("trait.drunkard"))
					{
						injuryChance = injuryChance * 2.0;
					}

					if (bro.getBackground().isCombatBackground())
					{
						injuryChance = injuryChance * 0.5;
					}

					if (bro.getSkills().hasSkill("trait.dexterous"))
					{
						injuryChance = injuryChance * 0.5;
					}

					if (this.Math.rand(1, 100) <= injuryChance)
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							bro.addLightInjury();
							this.List.push({
								id = 10,
								icon = "ui/icons/days_wounded.png",
								text = bro.getName() + " suffers light wounds"
							});
						}
						else
						{
							local injury = bro.addInjury(this.Const.Injury.Accident1);
							this.List.push({
								id = 10,
								icon = injury.getIcon(),
								text = bro.getName() + " suffers " + injury.getNameOnly()
							});
						}
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "C1",
			Text = "[img]gfx/ui/events/event_05.png[/img] %oldguard%把所有人召集在一起，发给他们训练用的弓。%SPEECH_ON%这些东西都不是用来杀人的，不过除非你们想用斧头杀死一个新生婴儿，现在我们练习就好。\n\n这种装置是这样使用的。哦，你们已经知道了？你们不是傻瓜？很好，让我看看你们这群神枪手有什么本事吧。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "看看你们是否能击中什么东西。",
					function getResult( _event )
					{
						return "C2";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Teacher.getImagePath());
				_event.m.Teacher.improveMood(0.5, "Has drilled the new recruits");
			}

		});
		this.m.Screens.push({
			ID = "C2",
			Text = "[img]gfx/ui/events/event_10.png[/img]所有人都在进行射击训练，箭朝着目标飞过去，只有几支射中目标。接下来的几天时间了，%oldguard%一直教他们射箭，射箭，射箭，直到最后运气都用光为止。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "做得好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Teacher.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getLevel() > 3)
					{
						continue;
					}

					local rangedSkill = this.Math.rand(0, 2);
					bro.getBaseProperties().RangedSkill += rangedSkill;
					bro.getSkills().update();

					if (rangedSkill > 0)
					{
						this.List.push({
							id = 16,
							icon = "ui/icons/ranged_skill.png",
							text = bro.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + rangedSkill + "[/color] 远程技能"
						});
					}

					local exhaustionChance = 33;

					if (bro.getSkills().hasSkill("trait.asthmatic"))
					{
						exhaustionChance = exhaustionChance * 4.0;
					}

					if (bro.getSkills().hasSkill("trait.athletic"))
					{
						exhaustionChance = exhaustionChance * 0.0;
					}

					if (bro.getSkills().hasSkill("trait.iron_lungs"))
					{
						exhaustionChance = exhaustionChance * 0.0;
					}

					if (this.Math.rand(1, 100) <= exhaustionChance)
					{
						local effect = this.new("scripts/skills/effects_world/exhausted_effect");
						bro.getSkills().add(effect);
						this.List.push({
							id = 10,
							icon = effect.getIcon(),
							text = bro.getName() + " is exhausted"
						});
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "D1",
			Text = "[img]gfx/ui/events/event_05.png[/img]%oldguard%吹响口哨，把所有新兵都召集在一起。他看着四周，露出笑容，点点头。%SPEECH_ON%大家注意了，我们要出发了！%SPEECH_OFF%老兵接下来几天时间都围着新兵转，直到把最后一个人弄得精疲力竭为止。%SPEECH_ON%呼吸，宝贝儿，呼吸！都听进去。我们还有很长的路要走，不要沮丧啊！把情绪全都吞进肚子里去。我扔出去的东西都比你们快，所以希望明天看到大家又打起精神来的样子。应该就在日出之前。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们明天再来！",
					function getResult( _event )
					{
						return "D2";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Teacher.getImagePath());
				_event.m.Teacher.improveMood(0.5, "Has drilled the new recruits");
			}

		});
		this.m.Screens.push({
			ID = "D2",
			Text = "%oldguard%毫无同情心，让他在将来的日子里一趟又一趟地跑。毕竟，他说了，这是为他们好。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "做得好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Teacher.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getLevel() > 3)
					{
						continue;
					}

					local stamina = this.Math.rand(0, 3);
					local initiative = stamina == 0 ? this.Math.rand(0, 3) : 0;
					bro.getBaseProperties().Stamina += stamina;
					bro.getBaseProperties().Initiative += initiative;
					bro.getSkills().update();

					if (stamina > 0)
					{
						this.List.push({
							id = 16,
							icon = "ui/icons/fatigue.png",
							text = bro.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + stamina + "[/color] 最大疲劳"
						});
					}

					if (initiative > 0)
					{
						this.List.push({
							id = 16,
							icon = "ui/icons/initiative.png",
							text = bro.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + initiative + "[/color] 主动性"
						});
					}

					local exhaustionChance = 75;

					if (bro.getSkills().hasSkill("trait.asthmatic"))
					{
						exhaustionChance = exhaustionChance * 2.0;
					}

					if (bro.getSkills().hasSkill("trait.athletic"))
					{
						exhaustionChance = exhaustionChance * 0.5;
					}

					if (bro.getSkills().hasSkill("trait.iron_lungs"))
					{
						exhaustionChance = exhaustionChance * 0.5;
					}

					if (this.Math.rand(1, 100) <= exhaustionChance)
					{
						local effect = this.new("scripts/skills/effects_world/exhausted_effect");
						bro.getSkills().add(effect);
						this.List.push({
							id = 10,
							icon = effect.getIcon(),
							text = bro.getName() + " is exhausted"
						});
					}
				}
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];
		local numRecruits = 0;

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 6 && bro.getBackground().isCombatBackground() && !bro.getBackground().isNoble())
			{
				candidates.push(bro);
			}
			else if (bro.getLevel() <= 3 && !bro.getBackground().isCombatBackground())
			{
				numRecruits = ++numRecruits;
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		if (numRecruits < 3)
		{
			return;
		}

		this.m.Teacher = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = 10 + numRecruits * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"oldguard",
			this.m.Teacher.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Teacher = null;
	}

});

