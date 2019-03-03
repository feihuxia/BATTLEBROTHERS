this.farmer_old_tricks_event <- this.inherit("scripts/events/event", {
	m = {
		Farmer = null
	},
	function create()
	{
		this.m.ID = "event.farmer_old_tricks";
		this.m.Title = "营地…";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_82.png[/img]你发现 %farmhand% 坐在战团的马车旁边。他衔着麦秆，走来走去并且朝地上吐痰。你问他在想什么。这个农夫耸耸肩。%SPEECH_ON%我爸爸告诉我打干草的事情。他这样旋转的手腕一次又一次放松自己。总是搞不清楚第二部分。%SPEECH_OFF%这个男人把麦秆拿出来弹开。你问道。%SPEECH_ON%你能搞清楚第一部分吗？你把干草和叉子放在哪里？%SPEECH_OFF%他点头。你告诉那个男人他只需要第一部分把一个男人开膛破肚的技术。你看着他的脸容光焕发。%SPEECH_ON%是的... 就是那样!为什么我以前没想到？你是个天才， 先生!我下次就试一试!就像打干草一样!%SPEECH_OFF%会有很多人尖叫和流血， 就是那样。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "不要把他们抛在身后。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Farmer.getImagePath());
				local meleeSkill = this.Math.rand(2, 4);
				_event.m.Farmer.getBaseProperties().MeleeSkill += meleeSkill;
				this.List.push({
					id = 16,
					icon = "ui/icons/melee_skill.png",
					text = _event.m.Farmer.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + meleeSkill + "[/color] 近战技能"
				});
				_event.m.Farmer.improveMood(1.0, "Realized he has some fighting knowledge");

				if (_event.m.Farmer.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Farmer.getMoodState()],
						text = _event.m.Farmer.getName() + this.Const.MoodStateEvent[_event.m.Farmer.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() <= 2 && bro.getBackground().getID() == "background.farmhand")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Farmer = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"farmhand",
			this.m.Farmer.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Farmer = null;
	}

});

