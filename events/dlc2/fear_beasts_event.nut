this.fear_beasts_event <- this.inherit("scripts/events/event", {
	m = {
		Casualty = null
	},
	function create()
	{
		this.m.ID = "event.fear_beasts";
		this.m.Title = "在扎营期间...";
		this.m.Cooldown = 25.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]{%brother% 正在将一截木头雕刻一只兔子，突然他愤怒的把整个雕刻扔进了篝火。%SPEECH_ON% 谁和我开玩笑吗？我希望我在这里是在进行打猎游戏，但是这根本不是个游戏！这些全是怪物！夜晚的魔鬼！艹！所有的这些，他们从哪里来？唉，我告诉你，我不希望被它们杀死啊！%SPEECH_OFF% 队伍的所有人都盯着愤怒的他。但是他却静静的看着火中的雕刻慢慢的燃烧。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这事儿对他造成了一些创伤.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Casualty.getImagePath());
				local trait = this.new("scripts/skills/traits/fear_beasts_trait");
				_event.m.Casualty.getSkills().add(trait);
				this.List.push({
					id = 10,
					icon = trait.getIcon(),
					text = _event.m.Casualty.getName() + " 现在害怕野兽"
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		local fallen = [];
		local fallen = this.World.Statistics.getFallen();

		if (fallen.len() < 2)
		{
			return;
		}

		if (fallen[0].Time < this.World.getTime().Days || fallen[1].Time < this.World.getTime().Days)
		{
			return;
		}

		if (this.World.Statistics.get().LastCombatFaction != this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts))
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.companion" || bro.getBackground().getID() == "background.beast_hunter" || bro.getBackground().getID() == "background.hunter" || bro.getBackground().getID() == "background.witchhunter" || bro.getBackground().getID() == "background.wildman")
			{
				continue;
			}

			if (bro.getLevel() <= 7 && !bro.getSkills().hasSkill("trait.fear_beasts") && !bro.getSkills().hasSkill("trait.hate_beasts") && !bro.getSkills().hasSkill("trait.fearless") && !bro.getSkills().hasSkill("trait.brave") && !bro.getSkills().hasSkill("trait.determined") && !bro.getSkills().hasSkill("trait.bloodthirsty"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Casualty = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = 50;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"brother",
			this.m.Casualty.getName()
		]);
	}

	function onClear()
	{
		this.m.Casualty = null;
	}

});

