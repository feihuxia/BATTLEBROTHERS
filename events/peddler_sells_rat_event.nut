this.peddler_sells_rat_event <- this.inherit("scripts/events/event", {
	m = {
		Peddler = null,
		Ratcatcher = null
	},
	function create()
	{
		this.m.ID = "event.peddler_sells_rat";
		this.m.Title = "营地…";
		this.m.Cooldown = 80.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]%SPEECH_ON%我再说最后一次，不，我是不会去买一只老鼠的。%SPEECH_OFF%你看到捕鼠人%ratcatcher%正在和小贩%peddler%争论着什么。那位推销员改变了说话的音调。%SPEECH_ON%你当然不用去买老鼠！你是个捕鼠人，干嘛还要去买老鼠？可如果……%SPEECH_OFF%捕鼠人用手戳着小贩的胸口。%SPEECH_ON%那些用来驯养的老鼠，可不是从街上抓来的，%peddler%！他们的品种完全不一样！如果我需要一只老鼠，我会自己去找的！不过，如果你需要有人帮你去灭鼠，那就是另一码事了。%SPEECH_OFF%%peddler%低头看着地面，陷入了思考中。突然，他兴奋地抬起头来，伸出一根手指。%SPEECH_ON%啊，那来一条金鱼怎么样？你想买金鱼吗？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这里一切正常。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Peddler.getImagePath());
				this.Characters.push(_event.m.Ratcatcher.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates_peddler = [];
		local candidates_ratcatcher = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.peddler")
			{
				candidates_peddler.push(bro);
			}
			else if (bro.getBackground().getID() == "background.ratcatcher")
			{
				candidates_ratcatcher.push(bro);
			}
		}

		if (candidates_peddler.len() == 0 || candidates_ratcatcher.len() == 0)
		{
			return;
		}

		this.m.Peddler = candidates_peddler[this.Math.rand(0, candidates_peddler.len() - 1)];
		this.m.Ratcatcher = candidates_ratcatcher[this.Math.rand(0, candidates_ratcatcher.len() - 1)];
		this.m.Score = candidates_peddler.len() * candidates_ratcatcher.len() * 3 * 50000;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"peddler",
			this.m.Peddler.getName()
		]);
		_vars.push([
			"ratcatcher",
			this.m.Ratcatcher.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Peddler = null;
		this.m.Ratcatcher = null;
	}

});

