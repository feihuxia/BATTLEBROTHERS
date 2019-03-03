this.bad_curse_event <- this.inherit("scripts/events/event", {
	m = {
		Cursed = null,
		Monk = null,
		Sorcerer = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.bad_curse";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]%superstitious%走进了你的帐篷，手里拿着一顶帽子。他不停地转动着帽子，好像在调掉上面的羽毛。虽然你一句话也没有说，但他不停地点头，眼神游移，好像想找点话来说。\n\n你放下与毛病，问他有什么事情吗。他舔了舔嘴唇，他有点了点头，开始解释他的窘境。他说的很快，你挺的不是很清楚，但大意大概是当地出了一个女巫，诅咒了他，使他丧失了某种性功能。\n\n你摇了摇头，问这个女巫想要什么，%superstitious%说要钱，要%payment%克朗。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧……我会解决这件事。给你。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "不可能的。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				if (_event.m.Monk != null)
				{
					this.Options.push({
						Text = "让%monk%和尚过来看看。",
						function getResult( _event )
						{
							return "D";
						}

					});
				}

				if (_event.m.Sorcerer != null)
				{
					this.Options.push({
						Text = "让术士%sorcerer%过来看看。",
						function getResult( _event )
						{
							return "E";
						}

					});
				}

				this.Characters.push(_event.m.Cursed.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_05.png[/img]你用手指按着眼睛，不知怎么处理这件事情。杀戮很简单，但这个？算了。你摆了摆手，站起身来，拿起以待克朗。这位迷信的人踉跄往前走了几步。%SPEECH_ON%请数清楚！可不能少了一个！%SPPECH_OFF%你不清不愿地把克朗倒在桌面上，开始数。数清楚后，你把钱装进袋子里，扔给%superstitious%他鞠了一躬，谢谢你的人吃。你挥了挥手，让他离开帐篷。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "真是受不了%",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cursed.getImagePath());
				_event.m.Cursed.improveMood(3.0, "Was cured of a curse");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Cursed.getMoodState()],
					text = _event.m.Cursed.getName() + this.Const.MoodStateEvent[_event.m.Cursed.getMoodState()]
				});
				this.World.Assets.addMoney(-400);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]" + 400 + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_05.png[/img]你开口拒绝了%superstitious%，他的脸色越来越难看了。%SPEECH_ON%树林里怪女人说的几句话会有上面作用。你只是被乞丐骗了，佣兵。不要这个乞丐的话，乞丐为了前什么谎话也说的出口。%SPEECH_OFF%话还没说完，%superstitious%转身抛出了帐篷，可能去找其他佣兵借钱娶了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "有些人真的是无可救药的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cursed.getImagePath());
				local effect = this.new("scripts/skills/effects_world/afraid_effect");
				_event.m.Cursed.getSkills().add(effect);
				this.List = [
					{
						id = 10,
						icon = effect.getIcon(),
						text = _event.m.Cursed.getName() + " is afraid"
					}
				];
				_event.m.Cursed.worsenMood(2.0, "Felt let down by you");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Cursed.getMoodState()],
					text = _event.m.Cursed.getName() + this.Const.MoodStateEvent[_event.m.Cursed.getMoodState()]
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_05.png[/img]你想或许%monk%和尚能帮得上忙，你去把和尚找来了。\n\n他说他的力量来源于旧神，因此与世界的邪恶势不两立。你趁他还没来得开始旧神那一套长篇大论，你排他去找%superstitious%了。几分钟过后，你的帐篷又恢复了安静。你明白这安静不了几分钟，因为你就像是站在山坡地步，等着山上滚下来一颗刻着你名字的巨石。\n\n但是，%superstitious%没回来找你。又过了几分钟，你发觉他还没过来找你。他没回来让你感觉到有点不敢，平静中蕴含着不想。你走出帐篷去找和尚，还有那个所谓被诅咒了的家伙，发现他们正聊的火热，话题都是些神神怪怪的。你微微一笑，转头走回了帐篷。如果硬要说和尚最厉害的是哪一方面，那肯定是和谐安详的气氛了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这应该可以解决这件事情了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cursed.getImagePath());
				this.Characters.push(_event.m.Monk.getImagePath());

				if (!_event.m.Cursed.getTags().has("resolve_via_curse"))
				{
					_event.m.Cursed.getTags().add("resolve_via_curse");
					_event.m.Cursed.getBaseProperties().Bravery += 1;
					_event.m.Cursed.getSkills().update();
					this.List.push({
						id = 16,
						icon = "ui/icons/bravery.png",
						text = _event.m.Cursed.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] 决心"
					});
				}

				if (!_event.m.Monk.getTags().has("resolve_via_curse"))
				{
					_event.m.Monk.getTags().add("resolve_via_curse");
					_event.m.Monk.getBaseProperties().Bravery += 1;
					_event.m.Monk.getSkills().update();
					this.List.push({
						id = 16,
						icon = "ui/icons/bravery.png",
						text = _event.m.Monk.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] 决心"
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_05.png[/img]你打了一个响指，想起了%sorcerer%，所谓的术士。你不想在让这件事烦心了，你让%superstitious%去找术士。他很快就离开了，可惜几分钟就回来了，解释说%sorcerer%已经解除他的诅咒了。%SPEECH_ON%我就做了……%SPEECH_OFF%你举起手打断了他的故事。他问你想不想知道发生了什么事情，你坚决说不想。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这应该可以解决这件事情了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cursed.getImagePath());
				this.Characters.push(_event.m.Sorcerer.getImagePath());
				_event.m.Cursed.improveMood(3.0, "Was cured of a curse");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Cursed.getMoodState()],
					text = _event.m.Cursed.getName() + this.Const.MoodStateEvent[_event.m.Cursed.getMoodState()]
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		if (this.World.Assets.getMoney() < 1000)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
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

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates_cursed = [];
		local candidates_monk = [];
		local candidates_sorcerer = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.superstitious"))
			{
				candidates_cursed.push(bro);
			}
			else if (bro.getBackground().getID() == "background.monk" || bro.getBackground().getID() == "background.monk_turned_flagellant")
			{
				candidates_monk.push(bro);
			}
			else if (bro.getBackground().getID() == "background.sorcerer")
			{
				candidates_sorcerer.push(bro);
			}
		}

		if (candidates_cursed.len() == 0)
		{
			return;
		}

		this.m.Cursed = candidates_cursed[this.Math.rand(0, candidates_cursed.len() - 1)];

		if (candidates_monk.len() != 0)
		{
			this.m.Monk = candidates_monk[this.Math.rand(0, candidates_monk.len() - 1)];
		}

		if (candidates_sorcerer.len() != 0)
		{
			this.m.Sorcerer = candidates_sorcerer[this.Math.rand(0, candidates_sorcerer.len() - 1)];
		}

		this.m.Town = town;
		this.m.Score = candidates_cursed.len() * 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"superstitious",
			this.m.Cursed.getNameOnly()
		]);
		_vars.push([
			"monk",
			this.m.Monk != null ? this.m.Monk.getNameOnly() : ""
		]);
		_vars.push([
			"sorcerer",
			this.m.Sorcerer != null ? this.m.Sorcerer.getNameOnly() : ""
		]);
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
		_vars.push([
			"payment",
			"400"
		]);
	}

	function onClear()
	{
		this.m.Cursed = null;
		this.m.Monk = null;
		this.m.Sorcerer = null;
		this.m.Town = null;
	}

});

