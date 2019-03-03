this.herbs_along_the_way_event <- this.inherit("scripts/events/event", {
	m = {
		Volunteer = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.herbs_along_the_way";
		this.m.Title = "路上…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "%terrainImage% 在你前往目的地的途中，%volunteer%拿着一束药草向你跑来。你知道这个蠢货对野生植物一窍不通，但他似乎坚持要亲身尝试这些药草。他认为这些药草中蕴含着有关‘听’的魔法力量。你们的谈话引起了战团中其他几个人的注意。没过多久，一些人就开始想要尝试这些‘神药’的功效。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "它们看起来似乎没什么问题，有人想试试看吗？",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 50 ? "C" : "B";
					}

				},
				{
					Text = "{最好不要冒这个险。 | 你们这帮蠢货只会毒死自己。}",
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
		this.m.Screens.push({
			ID = "B",
			Text = "%terrainImage% 这些药草似乎不仅没有危害，甚至还能治愈一些战团成员的身上的顽疾。%volunteer%的风寒似乎已被治愈，而%otherguy%的胃痛也减轻了不少。在你也试着服用了一些之后，一根深埋在你手指上的刺，似乎也自己冒了出来。太棒了！",
			Image = "",
			List = [],
			Options = [
				{
					Text = "太棒了！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local amount = this.Math.rand(5, 12);
				this.World.Assets.addMedicine(amount);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_medicine.png",
						text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + amount + "[/color]医疗用品"
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_18.png[/img]一个人开始呕吐，其他人也开始腹泻。看来这个药草根本没有效果。而当初主动以身试药的那位%volunteer%也难逃悲惨的下场。至少，他的排出体外的那些东西让你产生了一些不可思议的感觉。‘一个人的身体中真的能装下这么多东西吗？’你不禁产生了这样的怀疑。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Ewww.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local effect = this.new("scripts/skills/injury/sickness_injury");
				_event.m.Volunteer.getSkills().add(effect);
				this.List = [
					{
						id = 10,
						icon = effect.getIcon(),
						text = _event.m.Volunteer.getName() + " is sick"
					}
				];
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.Swamp)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getHitpoints() > 20 && !bro.getSkills().hasSkill("injury.sickness") && !bro.getSkills().hasSkill("trait.bright") && !bro.getSkills().hasSkill("trait.hesitant"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() > 0)
		{
			this.m.Volunteer = candidates[this.Math.rand(0, candidates.len() - 1)];
			this.m.Score = 10;

			do
			{
				local bro = brothers[this.Math.rand(0, brothers.len() - 1)];

				if (bro.getID() != this.m.Volunteer.getID())
				{
					this.m.OtherGuy = bro;
				}
			}
			while (this.m.OtherGuy == null);
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		local currentTile = this.World.State.getPlayer().getTile();
		local image;

		if (currentTile.Type == this.Const.World.TerrainType.Swamp)
		{
			image = "[img]gfx/ui/events/event_09.png[/img]";
		}
		else
		{
			image = "[img]gfx/ui/events/event_25.png[/img]";
		}

		_vars.push([
			"volunteer",
			this.m.Volunteer.getName()
		]);
		_vars.push([
			"otherguy",
			this.m.OtherGuy.getName()
		]);
		_vars.push([
			"image",
			image
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Volunteer = null;
		this.m.OtherGuy = null;
	}

});

