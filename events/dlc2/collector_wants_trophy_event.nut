this.collector_wants_trophy_event <- this.inherit("scripts/events/event", {
	m = {
		Peddler = null,
		Reward = 0,
		Item = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.collector_wants_trophy";
		this.m.Title = "在 %townname%";
		this.m.Cooldown = 25.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_01.png[/img]{当你还在城镇里逛街时，一个穿着丝绸的男人朝你走了过来。他的着装看起来十分漂亮，并且每个手指上都带着金光闪闪的戒指。 | 当你还在集市中走来走去时，一个陌生人朝你走了过来。他的臀部上挂着一些装着奇怪的液体的小玩意，并且有一种奇怪的木头取代了他的大部分的牙齿。 | 说实话，没有奇怪的人的陪伴，这怎么可能叫做一次正常的集市之旅呢？这一次又是一个胖脸的男人，他的嘴好似一个巨大的捕兽夹，他的脸颊很高，整个人活脱脱仿佛就是个绞刑架。把这外貌放在一边不谈，他此时正在四处溜达，行为上看起来绝对是个有钱之人。}%SPEECH_ON%{哈，佣兵，你身上似乎带了一些很有趣的玩意。 不如你将 %trophy% 卖给我，开个价吧，%reward% 克朗? | 你似乎有一个看起来不错的东西带在身上, 这个 %trophy%。我希望用 %reward% 克朗买下它，你平常可没这么容易赚到这么多钱吧！ | 哟嚯，你看起来应该是个冒险家。如果是你手里有 %trophy% 的话，你应该还是身怀一些绝技的吧。但是正好我身怀一些金银，并且我愿意开 %reward% 克朗来换你的这个饰品。}%SPEECH_OFF% 你思考了一下这个男人的提议。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "老铁成交！",
					function getResult( _event )
					{
						if (_event.m.Peddler != null)
						{
							return "Peddler";
						}
						else
						{
							this.World.Assets.addMoney(_event.m.Reward);
							local stash = this.World.Assets.getStash().getItems();

							foreach( i, item in stash )
							{
								if (item != null && item.getID() == _event.m.Item.getID())
								{
									stash[i] = null;
									break;
								}
							}

							return 0;
						}
					}

				},
				{
					Text = "老铁不成交！",
					function getResult( _event )
					{
						if (_event.m.Peddler != null)
						{
							return "Peddler";
						}
						else
						{
							return 0;
						}
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "Peddler",
			Text = "[img]gfx/ui/events/event_01.png[/img]{%peddler% 走上前并把你推了回来，感觉你根本就不是什么站团长。他对买主大吼大叫，并且举起一只手，买家也予以回应，这就像两只狗正在互相狂吠，而且速度如此之快，只是一瞬间许多的数字就已经被提了出来，也许是另一种语言吧。一分钟过后，%peddler% 回来了。%SPEECH_ON%事情是这样，他现在愿意付 %reward% 个克朗。我得走了，我还得去看看锅和罐子，祝你好运。%SPEECH_OFF%他拍了拍你的肩膀，随后离开了。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "老铁成交！",
					function getResult( _event )
					{
						this.World.Assets.addMoney(_event.m.Reward);
						local stash = this.World.Assets.getStash().getItems();

						foreach( i, item in stash )
						{
							if (item != null && item.getID() == _event.m.Item.getID())
							{
								stash[i] = null;
								break;
							}
						}

						return 0;
					}

				},
				{
					Text = "老铁不成交！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Peddler.getImagePath());
				_event.m.Reward = this.Math.floor(_event.m.Reward * 1.33);
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 4 && t.isAlliedWithPlayer())
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

		local stash = this.World.Assets.getStash().getItems();
		local candidates_items = [];

		foreach( item in stash )
		{
			if (item != null && item.isItemType(this.Const.Items.ItemType.Crafting) && item.getValue() >= 300)
			{
				candidates_items.push(item);
			}
		}

		if (candidates_items.len() == 0)
		{
			return;
		}

		this.m.Item = candidates_items[this.Math.rand(0, candidates_items.len() - 1)];
		this.m.Reward = this.m.Item.getValue();
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates_peddler = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.peddler")
			{
				candidates_peddler.push(bro);
			}
		}

		if (candidates_peddler.len() != 0)
		{
			this.m.Peddler = candidates_peddler[this.Math.rand(0, candidates_peddler.len() - 1)];
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
			"peddler",
			this.m.Peddler != null ? this.m.Peddler.getName() : ""
		]);
		_vars.push([
			"reward",
			this.m.Reward
		]);
		_vars.push([
			"trophy",
			this.m.Item.getName()
		]);
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.Peddler = null;
		this.m.Reward = 0;
		this.m.Item = null;
		this.m.Town = null;
	}

});

