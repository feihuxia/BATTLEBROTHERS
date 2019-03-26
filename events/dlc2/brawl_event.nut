this.brawl_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.brawl";
		this.m.Title = "驻扎之时...";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_06.png[/img]{你暂时离开想去找个地方小解，当你小解正欢时，战斗的喧嚣声忽然从你身后响起。你迅速解决问题，系好裤子随后迅速赶回了营地。但你发现你的部队并非在与敌人战斗，反而在自己打成了一团。雇佣兵们正在奋力爬向自己的武器与营地篝火，挥舞着拳头，众人扭打在地上。任何摔倒的人都会遭到字面意思上的一顿狂踹。直到有人来干扰这些施暴者，倒地者才会挣扎着爬起来随后继续跳进互相殴打的人群中。随着骚动逐渐减缓，大家慢慢意识到了你的存在，他们立刻开始整队，就像之前的野蛮争斗完全没发生过一样。你摇了摇头，询问他们为何忽然互怼。大家只是耸耸肩，完全没有人能回忆起究竟发生了什么。你进行了一次报数以保证没有任何人送掉性命。然后你便组织大家互相握手言和，并且互相监督，以免这种事情再次发生。这并非有人为非作歹，只是一场奇妙的争斗罢了，完全不需要担忧。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "应该只是一场友善的争吵, 吧？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 33)
					{
						bro.improveMood(0.5, "Had a good brawl");

						if (bro.getMoodState() > this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}

					if (this.Math.rand(1, 100) <= 33)
					{
						bro.addLightInjury();
						this.List.push({
							id = 10,
							icon = "ui/icons/days_wounded.png",
							text = bro.getName() + " suffers light wounds"
						});
					}
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 10)
		{
			return;
		}

		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

