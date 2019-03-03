this.greenskins_slayer_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_slayer";
		this.m.Title = "路上…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_35.png[/img]进军期间，%companyname%在路上遇到了一个男人。他全副武装，而且有着相当明显的骑士特征：脖子上挂着串骨制项链。每走一步，项链都会跟他的胸甲碰撞产生令人厌恶的声音。你谨慎地打量着这位陌生人和他的骨头饰品，以免碰上意外。%SPEECH_ON%晚上好，佣兵。%SPEECH_OFF%那名战士招了招手。他的身上似乎负担着某种无形的重量，可能是环绕着他的死亡气息，也可能是死在他手下的受害者的灵魂。他点了点头，继续说道。%SPEECH_ON%看起来你们也在对付那些绿皮怪物们，我想加入的就是你们这种战团。%SPEECH_OFF%%randombrother%和你交换了个眼神，然后耸了耸肩。他冷淡地低语道。%SPEECH_ON%如果他是个麻烦，我们也能够对付他。%SPEECH_OFF%那个男子突然摇了摇头。%SPEECH_ON%哦，我不会是麻烦的。我只想杀兽人和哥布林罢了。你还需要知道什么吗？只要消灭了那些怪物，我就会离开你们。%SPEECH_OFF%",
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
						_event.m.Dude = null;
						return 0;
					}

				},
				{
					Text = "不用了，谢谢。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						_event.m.Dude = null;
						return 0;
					}

				}
			],
			function start( _event )
			{
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");
				_event.m.Dude.setStartValuesEx([
					"orc_slayer_background"
				]);
				_event.m.Dude.getSkills().add(this.new("scripts/skills/traits/hate_greenskins_trait"));
				local necklace = this.new("scripts/items/accessory/special/slayer_necklace_item");
				necklace.m.Name = _event.m.Dude.getNameOnly() + "\'s Necklace";
				_event.m.Dude.getItems().equip(necklace);
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isGreenskinInvasion())
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
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

