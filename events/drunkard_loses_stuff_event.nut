this.drunkard_loses_stuff_event <- this.inherit("scripts/events/event", {
	m = {
		Drunkard = null,
		OtherGuy = null,
		Item = null
	},
	function create()
	{
		this.m.ID = "event.drunkard_loses_stuff";
		this.m.Title = "营地…";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]昨晚盘货的时候，%drunkard%喝的多了点，最终弄丢了一些%item%！\n\n你把他抓了过来，站都站不稳，浑身酒气。他一边打嗝一边给自己开脱，但是他只能醉醺醺地倒在地上。男子不停地大笑，但是你看不出这其中有什么好笑的。%otherguy%问你想怎么处置他。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "每个人都有犯错的时候。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "打扫一个月的厕所！",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "如果他不能把酒戒了，那我就逼他戒。把鞭子拿来。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 75 ? "D" : "E";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Drunkard.getImagePath());
				this.List.push({
					id = 10,
					icon = "ui/items/" + _event.m.Item.getIcon(),
					text = "你失去了" + _event.getArticle(_event.m.Item.getName()) + _event.m.Item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]酒鬼倒在地上，眼睛无神地看向天空。你看到他眼睛里含着泪水，然后他捂住脸，不想让别人看到。他的过去有一些你不了解的事情，也许是什么事情导致了他的酗酒的习惯。你不能因为一个人不能控制的事情而惩罚他。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "把他弄出我的视线。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Drunkard.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]你拿起一把铁锹，一个桶，还有一根包裹着羊毛的棍子。%SPEECH_ON%扫厕所。一个月。%SPEECH_OFF%酒鬼睁大眼睛看着你，请求你的宽恕。%SPEECH_ON%长官，求求你。我 -打嗝- 不……大家，长官，他们 -打嗝- ……%SPEECH_OFF%你举起你的手，打断了他。男子摇摇摆摆地试图站起来。你捏了捏指关节，表明另一个选择。%SPEECH_ON%如果你不想扫厕所，那么我们可以用鞭子作为惩罚。你想选哪个？%SPEECH_OFF%令人吃惊的是，酒鬼还真考虑了一会儿，他的眉毛上上下下，嘴角露出一股无奈，然后发觉已经躲不过去了。终于，他选择了打扫厕所。你对这个决定还需要考虑感到有些震惊，开始思考战团的伙食是有多差。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "把他弄出我的视线。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Drunkard.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_38.png[/img]那个男人想去喝酒，所以你计划要好好让他清醒一下。你命令进行鞭打。几个兄弟把这个醉鬼拖走了。他正在打嗝和呻吟，他的脑袋晃来晃去看来他不知道发生了什么事情。他们把他绑在一棵树下撕破了他背上的衣服。过了一会儿，这个醉鬼清醒了开始不由自主的哭起来。他吐字不清的开始请求原谅， 就像是一个男人在噩梦之中挣扎。有一件事情是一定的: 他不会再次犯这个错误了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那肯定会教训他的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Drunkard.getImagePath());
				_event.m.Drunkard.addLightInjury();
				this.List = [
					{
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Drunkard.getName() + " receives an injury"
					}
				];
				_event.m.Drunkard.getSkills().removeByID("trait.drunkard");
				this.List.push({
					id = 10,
					icon = "ui/traits/trait_icon_29.png",
					text = _event.m.Drunkard.getName() + " is no longer a drunkard"
				});
				_event.m.Drunkard.worsenMood(2.5, "Was flogged on your orders");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Drunkard.getMoodState()],
					text = _event.m.Drunkard.getName() + this.Const.MoodStateEvent[_event.m.Drunkard.getMoodState()]
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Drunkard.getID())
					{
						continue;
					}

					if (!bro.getBackground().isOffendedByViolence() || bro.getLevel() >= 7)
					{
						continue;
					}

					bro.worsenMood(1.0, "Appalled by your order to have " + _event.m.Drunkard.getName() + " flogged");

					if (bro.getMoodState() < this.Const.MoodState.Neutral)
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
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_38.png[/img]这个男人想要喝酒，所以你确定要教育一下他。你命令要进行鞭挞。几个人把这个醉鬼拖走了。他正在打嗝和呻吟，他的头晃来晃去不知道发生了什么事情。他们把他绑在一棵树下并且撕烂了他背上的衣服。一会儿之后， 这个醉鬼清醒了意识到了当前的情况开始不由自主的哭泣。他口齿不清的想要求饶， 就像一个男人在噩梦之中想要为自由战斗。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "那肯定会教训他的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Drunkard.getImagePath());
				_event.m.Drunkard.addLightInjury();
				this.List = [
					{
						id = 10,
						icon = "ui/icons/days_wounded.png",
						text = _event.m.Drunkard.getName() + " receives an injury"
					}
				];
				_event.m.Drunkard.worsenMood(2.5, "Was flogged on your orders");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Drunkard.getMoodState()],
					text = _event.m.Drunkard.getName() + this.Const.MoodStateEvent[_event.m.Drunkard.getMoodState()]
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Drunkard.getID())
					{
						continue;
					}

					if (!bro.getBackground().isOffendedByViolence() || bro.getLevel() >= 7 || bro.getBackground().getID() == "background.flagellant")
					{
						continue;
					}

					bro.worsenMood(1.0, "Appalled by your order to have " + _event.m.Drunkard.getName() + " flogged");

					if (bro.getMoodState() < this.Const.MoodState.Neutral)
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

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.drunkard"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		local items = this.World.Assets.getStash().getItems();
		local hasItem = false;

		foreach( item in items )
		{
			if (item == null)
			{
				continue;
			}

			if (item.isItemType(this.Const.Items.ItemType.Legendary))
			{
				continue;
			}

			if (item.isItemType(this.Const.Items.ItemType.Weapon) || item.isItemType(this.Const.Items.ItemType.Shield) || item.isItemType(this.Const.Items.ItemType.Armor) || item.isItemType(this.Const.Items.ItemType.Helmet))
			{
				hasItem = true;
				break;
			}
		}

		if (!hasItem)
		{
			return;
		}

		this.m.Drunkard = candidates[this.Math.rand(0, candidates.len() - 1)];
		local other_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getID() != this.m.Drunkard.getID())
			{
				other_candidates.push(bro);
			}
		}

		if (other_candidates.len() == 0)
		{
			return;
		}

		this.m.OtherGuy = other_candidates[this.Math.rand(0, other_candidates.len() - 1)];
		this.m.Score = candidates.len() * 10;
	}

	function onPrepare()
	{
		local items = this.World.Assets.getStash().getItems();
		local candidates = [];

		foreach( item in items )
		{
			if (item == null)
			{
				continue;
			}

			if (item.isItemType(this.Const.Items.ItemType.Legendary) || item.isIndestructible())
			{
				continue;
			}

			if (item.isItemType(this.Const.Items.ItemType.Weapon) || item.isItemType(this.Const.Items.ItemType.Shield) || item.isItemType(this.Const.Items.ItemType.Armor) || item.isItemType(this.Const.Items.ItemType.Helmet))
			{
				candidates.push(item);
			}
		}

		this.m.Item = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.World.Assets.getStash().remove(this.m.Item);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"drunkard",
			this.m.Drunkard.getName()
		]);
		_vars.push([
			"otherguy",
			this.m.OtherGuy.getName()
		]);
		_vars.push([
			"item",
			this.getArticle(this.m.Item.getName()) + this.m.Item.getName()
		]);
	}

	function onClear()
	{
		this.m.Drunkard = null;
		this.m.OtherGuy = null;
		this.m.Item = null;
	}

});

