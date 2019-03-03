this.butcher_wardogs_event <- this.inherit("scripts/events/event", {
	m = {
		Butcher = null
	},
	function create()
	{
		this.m.ID = "event.butcher_wardogs";
		this.m.Title = "营地…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_27.png[/img]你打开一箱食物，找到自己最后的储备。箱子里躺着一个苹果，发出的声音和饿肚子的声音不太一样。旁边还有几根长面包，有块肉被叶子包着。就这样。\n\n你盖上盖子看着周围，%butcher%屠夫站在那里。%SPEECH_ON%嘿，老大，我们好像遇到问题了。让我来…处理下？%SPEECH_OFF%就在那时，他用手指着远方，那边拴着两条战犬。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "做必要的事情。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "我才不会让别人杀死我们的猎犬并吃掉。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Butcher.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_14.png[/img]猎犬坐在地上，气喘吁吁，看起来很满足的样子，他们幸福感的持续时间可真久。但是你要养活很多人，还要战斗。为了战团，你让%butcher%做必要的事情。\n\n屠夫朝狗走过去，一只手抓住其中一只的头，另一只手从背后拿出一把刀。你没有站在那儿看接下来发生的事情，但听到身后传来一阵短促的狗叫声。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "最起码他今晚不会饿了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Butcher.getImagePath());
				local numWardogsToSlaughter = 2;
				local stash = this.World.Assets.getStash().getItems();

				foreach( i, item in stash )
				{
					if (item != null && (item.getID() == "accessory.wardog" || item.getID() == "accessory.armored_wardog"))
					{
						numWardogsToSlaughter = --numWardogsToSlaughter;
						stash[i] = null;
						this.List.push({
							id = 10,
							icon = "ui/items/" + item.getIcon(),
							text = "你失去了" + item.getName()
						});

						if (numWardogsToSlaughter == 0)
						{
							break;
						}
					}
				}

				if (numWardogsToSlaughter != 0)
				{
					local brothers = this.World.getPlayerRoster().getAll();

					foreach( bro in brothers )
					{
						local item = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory);

						if (item != null && (item.getID() == "accessory.wardog" || item.getID() == "accessory.armored_wardog"))
						{
							numWardogsToSlaughter = --numWardogsToSlaughter;
							bro.getItems().unequip(item);
							this.List.push({
								id = 10,
								icon = "ui/items/" + item.getIcon(),
								text = "你失去了" + item.getName()
							});

							if (numWardogsToSlaughter == 0)
							{
								break;
							}
						}
					}
				}

				local item = this.new("scripts/items/supplies/strange_meat_item");
				this.World.Assets.getStash().add(item);
				item = this.new("scripts/items/supplies/strange_meat_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_27.png[/img]你摇了摇头。%SPEECH_ON%绝对不行。它们和大家一样，是战团的一份子，而且大家肯定宁愿挨饿，也不愿吃掉它们。%SPEECH_OFF%屠夫耸耸肩。%SPEECH_ON%它们只不过是狗而已，老大，杂种狗。畜生。只不过是一种知道自己的名字的野兽。如果有需要，我们可以找到很多小狗。%SPEECH_OFF%你再次摇摇头。%SPEECH_ON%我们不能杀掉那两只狗，%butcher%。不要以为我没发现你眼里的神情。要想喂饱大家，除了杀死的动物，还有其他办法。%SPEECH_OFF%%butcher%只能再次耸耸肩。%SPEECH_ON%我不知道哪种方法更好，长官，不过我愿意听从您的命令。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们会想其他办法的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Butcher.getImagePath());
				_event.m.Butcher.worsenMood(1.0, "Was denied a request");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Butcher.getMoodState()],
					text = _event.m.Butcher.getName() + this.Const.MoodStateEvent[_event.m.Butcher.getMoodState()]
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getFood() > 25)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];
		local numWardogs = 0;

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.butcher")
			{
				candidates.push(bro);
			}

			local item = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory);

			if (item != null && (item.getID() == "accessory.wardog" || item.getID() == "accessory.armored_wardog"))
			{
				numWardogs = ++numWardogs;
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		if (numWardogs < 2)
		{
			local stash = this.World.Assets.getStash().getItems();

			foreach( item in stash )
			{
				if (item != null && (item.getID() == "accessory.wardog" || item.getID() == "accessory.armored_wardog"))
				{
					numWardogs = ++numWardogs;

					if (numWardogs >= 2)
					{
						break;
					}
				}
			}
		}

		if (numWardogs < 2)
		{
			return;
		}

		this.m.Butcher = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 25;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"butcher",
			this.m.Butcher.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Butcher = null;
	}

});

