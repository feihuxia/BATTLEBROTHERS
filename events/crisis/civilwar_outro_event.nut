this.civilwar_outro_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_outro";
		this.m.Title = "营地…";
		this.m.Cooldown = 1.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_96.png[/img]你正待在帐篷，%dude%走进来。他坦率地说道，%SPEECH_ON%贵族一直在商量。那边有个搭帐篷，他们都在里面。%SPEECH_OFF%你放下羽毛笔对他说，%SPEECH_ON%就商量？%SPEECH_OFF%雇佣兵耸耸肩，%SPEECH_ON%那儿很安静，所以要么在商量，要么在秘密地杀人。%SPEECH_OFF%你起身走到外面，空气十分清新，混杂着各种香料的味道。你往逆风处看去，发现了那个帐篷。厨师们正因为自己收到的命令，忙着准备食物和其他东西。仆人们端着肉，蔬菜和水果。帐篷很华丽，黑底绣着金色的装饰物，贵族的标志。旗手站在外面。他们没有参加聚会。他们正在玩牌，时不时看看彼此。有些人身上绑着绷带，上面带着血迹。一个人弯着膝盖，拄着拐杖。你问%dude%怎么回事。他朝那边点点头，%SPEECH_ON%他们差不多一个小时前到的，那时候你正在看地图。我们没想打扰你，可是，他们似乎没打算离开了。%SPEECH_OFF%你仔细看着贵族的帐篷。从开口处，你能看到带着闪闪发光王冠的人走来走去。%dude%问道，%SPEECH_ON%你觉得谁赢了？%SPEECH_OFF%你摇了摇头，%SPEECH_ON%管他呢。%SPEECH_OFF%你只知道，和平时期的契约会更少。或许现在该放下手中的剑，好好享受生活了？或者去他的那些多愁善感，继续前进就行了，带着战团干更大的事。",
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
				this.World.Combat.abortAll();
				this.World.FactionManager.makeEveryoneFriendlyToPlayer();
				this.World.FactionManager.createAlliances();
				this.updateAchievement("Kingmaker", 1, 1);

				if (this.World.Assets.isIronman())
				{
					this.updateAchievement("ManOfIron", 1, 1);
				}

				if (this.World.Assets.isIronman())
				{
					local defeated = this.getPersistentStat("CrisesDefeatedOnIronman");
					defeated = defeated | this.Const.World.GreaterEvilTypeBit.CivilWar;
					this.setPersistentStat("CrisesDefeatedOnIronman", defeated);

					if (defeated == this.Const.World.GreaterEvilTypeBit.All)
					{
						this.updateAchievement("Savior", 1, 1);
					}
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.State.getPlayer().getTile().HasRoad)
		{
			return;
		}

		if (this.World.Statistics.hasNews("crisis_civilwar_end"))
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
		this.World.Statistics.popNews("crisis_civilwar_end");
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

