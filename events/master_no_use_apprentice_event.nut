this.master_no_use_apprentice_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.master_no_use_apprentice";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_20.png[/img]在走进%townname%的时候，你遇上了一个扯着一位年轻人耳朵的老者。%SPEECH_ON%想当大师，是需要时间！血！和汗水的！当然，如果你是个不知羞耻的娘炮，那也少不了要流大把的眼泪！瞧！一个佣兵！如果你这么想去战斗，为什么不去找他？%SPEECH_OFF%你抬起手来，询问这到底是怎么一回事。那位老者冷静了一下，松开了那个孩子的耳朵。%SPEECH_ON%是啊，我应该向你解释清楚。我是这个镇上的剑术导师。如果又有人想在我的门下拜师学艺，就必须守规矩、有耐性！显然，我这位愚昧的弟子两样都做不到！所以，我这样告诉他：如果你这么想去战斗，那就滚吧！%SPEECH_OFF%你看了看那个孩子。他的脸上充满稚气，但眼中却显现出了对某种事物的渴望。你向他求证，这位剑术大师所说的话是否属实。那个孩子点点头。%SPEECH_ON%是的，先生。而且我很乐意在你的手下战斗。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧，让他跟我们走吧。",
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						return 0;
					}

				},
				{
					Text = "谢了，请容我拒绝。这不关我的事。",
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
					"apprentice_background"
				]);
				_event.m.Dude.getBackground().m.RawDescription = "An impatient student of a fencing and swordmaster, %name% didn\'t have the mental aptitude to stick with the trials and tribulations of becoming a master of the blade himself. But what he lacks in mental fortitude he more than makes up for in effort. You \'hired\' him simply by taking him off the old man\'s hands.";
				_event.m.Dude.getBackground().buildDescription(true);
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (this.World.getPlayerRoster().getSize() >= this.World.Assets.getBrothersMax())
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.isMilitary() || t.getSize() <= 1)
			{
				continue;
			}

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
		this.m.Score = 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"town",
			this.m.Town.getNameOnly()
		]);
		_vars.push([
			"townname",
			this.m.Town.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
		this.m.Town = null;
	}

});

