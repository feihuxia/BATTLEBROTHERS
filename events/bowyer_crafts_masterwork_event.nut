this.bowyer_crafts_masterwork_event <- this.inherit("scripts/events/event", {
	m = {
		Bowyer = null,
		OtherGuy1 = null,
		OtherGuy2 = null
	},
	function create()
	{
		this.m.ID = "event.bowyer_crafts_masterwork";
		this.m.Title = "营地…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]%bowyer% 弓匠向你走过来，有个小请求：他希望给老人打造一把武器。这个人多年来一直想打造一把质量超群的弓，可是他一直到处奔波，希望学习更多的东西，填补自己的知识。他很相信自己这次一定能做到。他只需要一点资源，帮助生产建造弓箭所需要的材料。他只需要250克朗，还有你的优质木头。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "给我建造一把传奇之弓！",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 60 ? "B" : "C";
					}

				},
				{
					Text = "我们没时间。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bowyer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]{虽然弓不怎么具有传奇意义，但确实很不错。拿在手上很轻，弓弦很容易从一端滑到另一端。你试着拉了下。很显然，拉动这支弓的人必须十分强壮才行。你把箭射出去的时候，箭杆直接朝着目标飞了过去。这是你见过最棒的武器了！| 弓用一种你不知道名字的木头制成。木头的颜色，以及武器的曲线，看起来都具有花纹。试着拉了拉，弓弦非常强劲。你不是射手，可是当你把箭射出去的时候，几乎直接朝着目标飞过去了。真是一把了不起的武器，它让你看起来更威风了。你对弓匠表示祝贺。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "了不起的杰作！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bowyer.getImagePath());
				this.World.Assets.addMoney(-500);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]500[/color] 克朗"
				});
				local stash = this.World.Assets.getStash().getItems();

				foreach( i, item in stash )
				{
					if (item != null && item.getID() == "misc.quality_wood")
					{
						stash[i] = null;
						this.List.push({
							id = 10,
							icon = "ui/items/" + item.getIcon(),
							text = "你失去了" + item.getName()
						});
						break;
					}
				}

				local item = this.new("scripts/items/weapons/masterwork_bow");
				item.m.Name = _event.m.Bowyer.getNameOnly() + "\'s " + item.m.Name;
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				_event.m.Bowyer.improveMood(2.0, "Created a masterwork");

				if (_event.m.Bowyer.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Bowyer.getMoodState()],
						text = _event.m.Bowyer.getName() + this.Const.MoodStateEvent[_event.m.Bowyer.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]这是某种野外实验吗？木头弯曲的时候发出喀嚓的声音，绳子吱吱像个不停，每次往回拉的时候，都会更加紧绷，你发誓看到一只白蚁从拍杆后面伸出脑袋。每一支测试的箭都乱了套，避开这个或那个，反正就是射不中目标。\n\n你责怪弓箭太不准确，减轻弓匠的负担，但是%otherguy1%和%otherguy2%都试过了，结果更糟。弓匠完全乱套了，他拿着自己的弓，然后随手丢到武器堆里，你非常希望这把弓能跟其他武器一样普通，但它丑陋的外表实在是太出众了。很明显，没人会用这把弓。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我现在知道你为什么不再当弓匠了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bowyer.getImagePath());
				this.World.Assets.addMoney(-500);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]500[/color] 克朗"
				});
				local stash = this.World.Assets.getStash().getItems();

				foreach( i, item in stash )
				{
					if (item != null && item.getID() == "misc.quality_wood")
					{
						stash[i] = null;
						this.List.push({
							id = 10,
							icon = "ui/items/" + item.getIcon(),
							text = "你失去了 " + item.getName()
						});
						break;
					}
				}

				local item = this.new("scripts/items/weapons/wonky_bow");
				item.m.Name = _event.m.Bowyer.getNameOnly() + "\'s " + item.m.Name;
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				_event.m.Bowyer.worsenMood(1.0, "Failed in creating a masterwork");

				if (_event.m.Bowyer.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Bowyer.getMoodState()],
						text = _event.m.Bowyer.getName() + this.Const.MoodStateEvent[_event.m.Bowyer.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_05.png[/img]你告诉弓匠，%companyname%没有多余的资源。那个人磨着牙，很明显想说点什么，但最后一个字也没说就走开了。远处传来他骂骂咧咧的声音，还夹杂着各种诅咒，以及对你的失望之情。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "振作起来。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bowyer.getImagePath());
				_event.m.Bowyer.worsenMood(2.0, "Was denied a request");

				if (_event.m.Bowyer.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Bowyer.getMoodState()],
						text = _event.m.Bowyer.getName() + this.Const.MoodStateEvent[_event.m.Bowyer.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getMoney() < 2000)
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
			if (bro.getLevel() >= 6 && bro.getBackground().getID() == "background.bowyer")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		local stash = this.World.Assets.getStash().getItems();
		local numWood = 0;

		foreach( item in stash )
		{
			if (item != null && item.getID() == "misc.quality_wood")
			{
				numWood = ++numWood;
				break;
			}
		}

		if (numWood == 0)
		{
			return;
		}

		this.m.Bowyer = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 4;
	}

	function onPrepare()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		foreach( bro in brothers )
		{
			if (bro.getID() != this.m.Bowyer.getID())
			{
				this.m.OtherGuy1 = bro;
				break;
			}
		}

		foreach( bro in brothers )
		{
			if (bro.getID() != this.m.Bowyer.getID() && bro.getID() != this.m.OtherGuy1.getID())
			{
				this.m.OtherGuy2 = bro;
				break;
			}
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"bowyer",
			this.m.Bowyer.getNameOnly()
		]);
		_vars.push([
			"otherguy1",
			this.m.OtherGuy1.getName()
		]);
		_vars.push([
			"otherguy2",
			this.m.OtherGuy2.getName()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Bowyer = null;
		this.m.OtherGuy1 = null;
		this.m.OtherGuy2 = null;
	}

});

