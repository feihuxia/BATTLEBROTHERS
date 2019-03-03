this.undead_crusader_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.undead_crusader";
		this.m.Title = "路上…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_35.png[/img]一位穿着盔甲的男子在路上拦住了你。你握住了武器，让他说明自己的来意，同时扫视着四周，观察是否有伏击的迹象。那个陌生人向前走了一步，摘掉了头盔。%SPEECH_ON%我是%crusader%一名来自无名土地的战士。我阻挡着邪恶。我驱赶了戴夫厄加德的怪物。我为薛尔斯塔亚的灵魂带来和平。当先祖训诫时，我会聆听。所以我来到了这里。%SPEECH_OFF%你的手放开了武器，询问他关于先祖的问题。他点点头，说道。%SPEECH_ON%很久很久以前，先祖们统治了万物，帝国的边界延伸到很远很远的地方。这些混乱只是他们的毁灭带来的一小片碎片罢了。人或许会死，但帝国不会。帝国一点点地衰弱了，带走了它认识属于自己的一切。%SPEECH_OFF%那个十字军战士重新戴起了他的头盔，拔出了他的剑。%SPEECH_ON%逝去的先祖帝国现在动荡不安。而我想平息这份动荡。我愿意帮助你，佣兵。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "你可以加入我们。",
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						return 0;
					}

				},
				{
					Text = "不用了，谢谢。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						return 0;
					}

				}
			],
			function start( _event )
			{
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");
				_event.m.Dude.setStartValuesEx([
					"crusader_background"
				]);
				_event.m.Dude.getSkills().add(this.new("scripts/skills/traits/hate_undead_trait"));
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 3000)
		{
			return;
		}

		if (this.World.getPlayerRoster().getSize() >= this.World.Assets.getBrothersMax())
		{
			return;
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"crusader",
			this.m.Dude.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

