this.civilwar_intro_event <- this.inherit("scripts/events/event", {
	m = {
		Town = null,
		NobleHouse = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_intro";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 1.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_92.png[/img]你进入%townname%，发现一群村民站在一个木制平台周围。你觉得可能有绞刑要发生，因此迅速挤到最前面。不过你只看到一个穿着奇怪的人，大声对市民们说这些什么，%SPEECH_ON%大家听好了，%noblehouse1%和%noblehouse2%已经达成一致。他们得出结论，所有人都对此表示赞同：他们讨厌彼此！%SPEECH_OFF%人群开始紧张地窃窃私语。一会儿之后，窃窃私语的声音安静下来。那个人继续说道，%SPEECH_ON%没错，市民们！战争就要来临了！啊，沉睡在所有人心中的野兽。充满悲伤，正义和荣誉！%SPEECH_OFF%站在你面前的一位老人抱怨起来。他摇着头，自言自语地离开了。吟游诗人继续，他的热情和面前那些被吓坏的面孔一点都不协调。%SPEECH_ON%我们别在这儿浪费时间了，我收到指示：男人们拿起武器，不要再耕地了。女人们，好好抚养你们的儿子，不要让他们连剑都不会拿！%SPEECH_OFF%最后，吟游诗人深吸一口气，%SPEECH_ON%还有那些想挣钱的人，贵族正在招募会用剑的人。那些缺乏荣誉感的人，失败者，小偷，走私犯，胡作非为、滥杀无辜的人，强盗，土匪，盗贼，被诅咒的人，佣兵，诗人，朋友们，属于你们的时代来临了。去吧，为贵族而战，开启全新的生活！战争不会永远持续下去，所以赶紧行动吧！%SPEECH_OFF%%companyname%的未来似乎变得更加明亮了，因为你即将挣不少金子。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "战争来了。",
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
		if (this.World.Statistics.hasNews("crisis_civilwar_start"))
		{
			local playerTile = this.World.State.getPlayer().getTile();
			local towns = this.World.EntityManager.getSettlements();
			local nearTown = false;
			local town;

			foreach( t in towns )
			{
				if (t.getTile().getDistanceTo(playerTile) <= 3 && t.isAlliedWithPlayer())
				{
					nearTown = true;
					town = t;
					break;
				}
			}

			if (!nearTown)
			{
				return;
			}

			this.m.Town = town;
			this.m.NobleHouse = this.m.Town.getOwner();
			this.m.Score = 6000;
		}
	}

	function onPrepare()
	{
		this.World.Statistics.popNews("crisis_civilwar_start");
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
		_vars.push([
			"noblehouse1",
			this.m.NobleHouse.getNameOnly()
		]);
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local noblehouse2;

		do
		{
			noblehouse2 = nobles[this.Math.rand(0, nobles.len() - 1)];
		}
		while (noblehouse2 == null || noblehouse2.getID() == this.m.NobleHouse.getID());

		_vars.push([
			"noblehouse2",
			noblehouse2.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Town = null;
		this.m.NobleHouse = null;
	}

});

