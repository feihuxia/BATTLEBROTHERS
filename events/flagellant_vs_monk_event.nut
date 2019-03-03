this.flagellant_vs_monk_event <- this.inherit("scripts/events/event", {
	m = {
		Monk = null,
		Flagellant = null
	},
	function create()
	{
		this.m.ID = "event.flagellant_vs_monk";
		this.m.Title = "营地…";
		this.m.Cooldown = 45.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]篝火明亮的闪耀着， 人们扭曲的面孔在黄色的火焰上面就像他们是燃烧的树干。\n\n 在这里你能够找到 %monk% 和%flagellant% 相互说话。他们是在讨论，首先是，一个心酸的话题。僧侣很高兴苦行僧把他的鞭子拿开了。你不想介入，你禁不住同意破坏你自己的身体弄得自己浑身是伤并不是最佳的生活方式。但是之后苦行僧的反驳让你们都哑口无言。那是一个如此巧妙的短语你们可以通过你们的第一反应判断出你们各人的习惯。也很令人不安， 这就是他随口说出的东西。他这样平和的语气说出的东西是如此温暖可以化解皮和肉。吃什么呢？\n\n 僧侣结巴了一会儿， 然后把他的手放到了苦行僧的肩膀上，他们彼此对视着。他说着悄悄话， 让你的耳朵发痒， 但是发出的声音不是很大你听不懂真正的意思。你只能推测他们的意思，再一次， 劝诫苦行僧过一个愉快， 少些暴力的生活。\n\n 但是， 再一次， 苦行僧开始回应所以他们又继续开战。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真是奇妙极了。我们看看这会发展成什么样子。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 50 ? "B" : "C";
					}

				},
				{
					Text = "好了，狗了。我们还有正事要做。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk.getImagePath());
				this.Characters.push(_event.m.Flagellant.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]决定让这个男人说话， 你离开一段时间。等你回来的时候， 你发现苦行僧坐在僧侣的旁边。两个人来回看着一段木头， 他们的手紧握着在祷告轻声念的祈祷词。你不紧不慢的走过去听他们说什么那真是让人感到舒适的景象。当你不知道如何平息神灵的时候， 你看到苦行僧放下他自我折磨的工具之后你不禁感觉到舒服一点了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "愿他能找到属于自己的宁静。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk.getImagePath());
				this.Characters.push(_event.m.Flagellant.getImagePath());
				local background = this.new("scripts/skills/backgrounds/pacified_flagellant_background");
				_event.m.Flagellant.getSkills().removeByID("background.flagellant");
				_event.m.Flagellant.getSkills().add(background);
				_event.m.Flagellant.m.Background = background;
				background.buildDescription();
				this.List = [
					{
						id = 13,
						icon = background.getIcon(),
						text = _event.m.Flagellant.getName() + " is now a Pacified Flagellant"
					}
				];
				_event.m.Monk.getBaseProperties().Bravery += 2;
				_event.m.Monk.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Monk.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+2[/color] 决心"
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]决定要让这个男人说话， 你离开一小会。\n\n等你回来的时候， 僧侣赤身裸体流着眼泪弯着腰。他的身体畏缩，但是他的脸就像是他一直想要的那样。大吸一口气他振作起来把手腕挥到他的肩膀上。把苦行僧的鞭子拿在手上你听到皮鞭抽打着僧侣背上的声音。他把工具抽开你可以听到玻璃和倒刺撕裂肉体的声音像是铃铛在你耳边响着。我心中自己什么都没有说。他就在僧侣的旁边。他看着打的，但是在他的眼睛里似乎没有任何生命， 但是当你看到它抽打自己的时候你可以从他的眼睛里看到他生命的血。\n\n你再一次走开， 但是你脚下的草不再有同样的声音因为空气里有一股黄铜的味道。小东西一路跟着你回到你的帐篷。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "一个只能自我鞭笞的人会找到最真实的恐惧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk.getImagePath());
				this.Characters.push(_event.m.Flagellant.getImagePath());
				local background = this.new("scripts/skills/backgrounds/monk_turned_flagellant_background");
				_event.m.Monk.getSkills().removeByID("background.monk");
				_event.m.Monk.getSkills().add(background);
				_event.m.Monk.m.Background = background;
				background.buildDescription();
				this.List = [
					{
						id = 13,
						icon = background.getIcon(),
						text = _event.m.Monk.getName() + " is now a Monk turned Flagellant"
					}
				];
				_event.m.Flagellant.getBaseProperties().Bravery += 2;
				_event.m.Flagellant.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/bravery.png",
					text = _event.m.Flagellant.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+2[/color] 决心"
				});
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

		local flagellant_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.flagellant")
			{
				flagellant_candidates.push(bro);
			}
		}

		if (flagellant_candidates.len() == 0)
		{
			return;
		}

		local monk_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.monk")
			{
				monk_candidates.push(bro);
			}
		}

		if (monk_candidates.len() == 0)
		{
			return;
		}

		this.m.Flagellant = flagellant_candidates[this.Math.rand(0, flagellant_candidates.len() - 1)];
		this.m.Monk = monk_candidates[this.Math.rand(0, monk_candidates.len() - 1)];
		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"monk",
			this.m.Monk.getName()
		]);
		_vars.push([
			"flagellant",
			this.m.Flagellant.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Monk = null;
		this.m.Flagellant = null;
	}

});

