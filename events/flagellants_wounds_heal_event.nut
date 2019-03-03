this.flagellants_wounds_heal_event <- this.inherit("scripts/events/event", {
	m = {
		Flagellant = null
	},
	function create()
	{
		this.m.ID = "event.flagellants_wounds_heal";
		this.m.Title = "营地…";
		this.m.Cooldown = 70.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_39.png[/img]%flagellant%苦修者盘腿坐在营火前。他独自一人想要拯救靠近火焰的飞蛾。他感觉到了你的存在，向你打了个招呼。你坐在他的旁边，然后朝你笑了笑。%SPEECH_ON%我加入战团之后变得更好了。%SPEECH_OFF%你点头表示赞同。他继续说道%SPEECH_ON%我为诸神流了很多鲜血，但是我的伤口……现在已经结痂了。我感觉比任何时候都要强大。%SPEECH_OFF%你又点了点头，但是很快就问起他什么时候才能停止这样伤害自己。男人的眼睛盯着红彤彤的余烬上。他摇了摇头。%SPEECH_ON%我会一直为诸神流血，知道他们说停下为止。%SPEECH_OFF%你表示疑问，问诸神到底会不会跟他说话。男人毫不停顿地又摇了摇头。%SPEECH_ON%他们并没有，所以我应该继续下去，直到他们不再沉默或者我永远加入他们的行列为止。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那么说来时间确实可以治愈全部的伤痛。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Flagellant.getImagePath());
				local hitpoints = this.Math.rand(4, 6);
				_event.m.Flagellant.getBaseProperties().Hitpoints += hitpoints;
				_event.m.Flagellant.getSkills().update();
				_event.m.Flagellant.getTags().add("wounds_scarred_over");
				this.List = [
					{
						id = 17,
						icon = "ui/icons/health.png",
						text = _event.m.Flagellant.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + hitpoints + "[/color] 生命值"
					}
				];
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidate_flagellant = [];

		foreach( bro in brothers )
		{
			if (bro.getTags().has("wounds_scarred_over"))
			{
				continue;
			}

			if (bro.getLevel() < 6)
			{
				continue;
			}

			if (bro.getBackground().getID() == "background.flagellant" || bro.getBackground().getID() == "background.monk_turned_flagellant")
			{
				candidate_flagellant.push(bro);
			}
		}

		if (candidate_flagellant.len() == 0)
		{
			return;
		}

		this.m.Flagellant = candidate_flagellant[this.Math.rand(0, candidate_flagellant.len() - 1)];
		this.m.Score = candidate_flagellant.len() * 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"flagellant",
			this.m.Flagellant.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Flagellant = null;
	}

});

