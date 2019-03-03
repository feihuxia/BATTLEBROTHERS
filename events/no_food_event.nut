this.no_food_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.no_food";
		this.m.Title = "路上…";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_52.png[/img]{食物储备已被耗尽！虽然这个世界十分可怕，但%companyname%也没办法带着一堆骷髅上战场啊！你必须想办法赶快给佣兵们弄来食物，不然他们都会离你而去的。| 即便是最忠诚的手下，也无法跟着你饿上五六顿饭。在那之后，任何人都会离开并设法填饱自己的肚子。去找食物吧，一定要赶在战团分崩离析前找到啊！| 你在食物储备的预估上犯下大错，以至于让%companyname%陷入了一个非常危险的境地——饥饿。即便是最为勇猛的战团，只要几天不吃饭，就会分崩离析。如果你再不去改变现状，你的战团的下场也是一样！}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我要去给佣兵们找些吃的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getFood() > 0)
		{
			return;
		}

		this.m.Score = 50;
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

