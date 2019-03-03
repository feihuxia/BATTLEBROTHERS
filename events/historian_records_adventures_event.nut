this.historian_records_adventures_event <- this.inherit("scripts/events/event", {
	m = {
		Historian = null
	},
	function create()
	{
		this.m.ID = "event.historian_records_adventures";
		this.m.Title = "营地…";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_15.png[/img]%historian%手里拿着一本皮质书，踱步走进了你的帐篷。他一言不发，把书放在桌上，往后退了一步。你放下手中的羽毛笔，问他这是什么。他说，打开它。你叹着气打开了这本书，翻看着那些写着你所熟知的名字与事件的书页。那是段有关战团与其冒险的历史。你浏览着这本书，看着那些或暖心或令人伤心的传说。你关上了那本书，把它推回到桌上。历史学家问你这些是否属实，你点了点头。你说，把这书拿给营地里的那些人看，一定会让他们士气大增的。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "%companyname%的故事当永垂不朽。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Historian.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) >= 90)
					{
						continue;
					}

					bro.improveMood(1.0, "Proud of the company\'s achievements");

					if (bro.getMoodState() >= this.Const.MoodState.Neutral)
					{
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[bro.getMoodState()],
							text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
						});
					}
				}
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 9 && bro.getBackground().getID() == "background.historian")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Historian = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"historian",
			this.m.Historian.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Historian = null;
	}

});

