this.greenskins_outro_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_outro";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 1.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]你碰上了一群%randomnoblehouse%的士兵。他们跟你打招呼。%SPEECH_ON%晚上好，佣兵。%SPEECH_OFF%你不确定他们是不是会袭击，你对%dude%微妙地点点头。他把武器放在手能够到的地方，点头回应。你又把注意力放到士兵身上，友好地挥挥手。他们的中尉笑着走上来。%SPEECH_ON%啊，佣兵，我们现在用不上你。%SPEECH_OFF%你慢慢地放下手，停在剑柄上。你问他这是什么意思。他大笑。%SPEECH_ON%你没听见吗？战争结束了。几天前，绿皮怪物在%randomtown%溃败了。侦察兵报告说看见他们往山里逃了，自相残杀，兽人杀害哥布林，哥布林杀害兽人，完完全全的溃败。所以，贵族们不需要再给你们这种蠢货钱了，我们这样的真正的士兵能控制一切。你和可怜的手下们为何不趁早滚蛋呢。战士要有地方呆，明白了吗？%SPEECH_OFF%",
			Image = "",
			Characters = [],
			Options = [
				{
					Text = "我们让一让，让这些民族英雄过去。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "你来对付他， %dude% ",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
				this.updateAchievement("GreenskinSlayer", 1, 1);

				if (this.World.Assets.isIronman())
				{
					this.updateAchievement("ManOfIron", 1, 1);
				}

				if (this.World.Assets.isIronman())
				{
					local defeated = this.getPersistentStat("CrisesDefeatedOnIronman");
					defeated = defeated | this.Const.World.GreaterEvilTypeBit.Greenskins;
					this.setPersistentStat("CrisesDefeatedOnIronman", defeated);

					if (defeated == this.Const.World.GreaterEvilTypeBit.All)
					{
						this.updateAchievement("Savior", 1, 1);
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img] %dude% 摸上了武器，但你摇摇头。中尉对佣兵点点头。%SPEECH_ON%最好把狗拴住，对吗？%SPEECH_OFF%你伸出手臂，给士兵们让了条他们早就知道的‘道路’。士兵们做好了准备，中尉露出了得意的笑容。%SPEECH_ON%我知道你的选择没有错。我们只是在找点乐子，不是吗？女士们保持紧密。%SPEECH_OFF%他走的时候还来了个飞吻。%dude%站着的样子好像有人揍了他妈。你叫他坐回去，他勉强照做了。都是屁话，都是作秀，但你不会为此生气杀人。\n\n这件事确实让你开始考虑是不是该把事情结束了。绿皮怪物已经被击退了，你也赚到了足够的钱，可以永远告别这种生活，但你也讨厌把剩下的人生都拿来想‘如果’……",
			Image = "",
			Characters = [],
			Options = [
				{
					Text = "%companyname%需要他们的首领！",
					function getResult( _event )
					{
						return 0;
					}

				},
				{
					Text = "该从雇佣兵的生活退休了。（结束战役）",
					function getResult( _event )
					{
						this.World.State.getMenuStack().pop(true);
						this.World.State.showGameFinishScreen(true);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]士兵的中尉看着你。%SPEECH_ON%照我说的做，佣兵，否则就有麻烦了。%SPEECH_OFF%你无视了他，又对%dude%点了点头。他站起来，武器的刀锋用力刮起了尘埃。士兵们面向佣兵。他双手举起武器，盯了回去。中尉开始说话，%dude%迟钝地打断了。%SPEECH_ON%嘘，小家伙。我看到了你皮肤的柔软。连个疤都看不到。眼睛和出生时一样清亮。双手和未被触摸的蜡烛一样光滑。如果你真是战士，就该在战场上，而不是在这里迎风撒尿。我给你两个选择，因为我感觉挺好。第一，你听着吗？第一个选择是这样。去你要去的地方，一个字都别说。%SPEECH_OFF%他停下来伸出两根手指。%SPEECH_ON%第二个选项是秘密。说句话你就能知道了。%SPEECH_OFF%中尉的眼睛睁大了一点，嘴巴沉默了很多。他看看你，但你只是耸耸肩。良久，士兵们在坚定的沉默中离开了。\n\n%dude%大笑起来，但这件事让你开始考虑，是不是到了退休的时候。你将来还会碰到多少这样的垃圾？还有多少战斗？还要埋葬多少死人？站在你奠定的基础上，战团能走得很远。但另一方面，如果你现在退休，会错过什么样的冒险呢？",
			Image = "",
			Characters = [],
			Options = [
				{
					Text = "%companyname%需要他们的首领！",
					function getResult( _event )
					{
						return 0;
					}

				},
				{
					Text = "该从雇佣兵的生活退休了。（结束战役）",
					function getResult( _event )
					{
						this.World.State.getMenuStack().pop(true);
						this.World.State.showGameFinishScreen(true);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Statistics.hasNews("crisis_greenskins_end"))
		{
			local brothers = this.World.getPlayerRoster().getAll();
			local highest_hiretime = -9000.0;
			local highest_hiretime_bro;

			foreach( bro in brothers )
			{
				if (bro.getHireTime() > highest_hiretime)
				{
					highest_hiretime = bro.getHireTime();
					highest_hiretime_bro = bro;
				}
			}

			this.m.Dude = highest_hiretime_bro;
			this.m.Score = 6000;
		}
	}

	function onPrepare()
	{
		this.World.Statistics.popNews("crisis_greenskins_end");
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"dude",
			this.m.Dude.getNameOnly()
		]);
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		_vars.push([
			"randomnoblehouse",
			nobles[this.Math.rand(0, nobles.len() - 1)].getName()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

