this.civilwar_refugees_event <- this.inherit("scripts/events/event", {
	m = {
		AggroDude = null,
		InjuredDude = null,
		RefugeeDude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_refugees";
		this.m.Title = "路上…";
		this.m.Cooldown = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_59.png[/img]{战争除了造成人员伤亡，还有许多幸存者，你在前进的时候，发现一群避难者挤成一团。他们正在小溪边清洗自己，看到你的到来，他们感到十分害怕。大多数都是女人和小孩，还有几个老人和男人，他们似乎已经拼命防御，牺牲自己的准备，不管防御是否会成功。一个人走上前来，%SPEECH_ON%你们想要什么？%SPEECH_OFF%%aggro_bro%走到你身边，%SPEECH_ON%长官，我们可以拿走他们的一切，不过他们肯定不会束手就擒。%SPEECH_OFF%%injured_bro%摇了摇头，%SPEECH_ON%这不值得，他们已经饱经风霜，没多少东西剩下了。%SPEECH_OFF%  |  你遇到一群避难者。女人，小孩，老人，还有几个瞪大眼睛的男人。他们没多少价值，不过他们有一些可以拿走的东西。 |  避难者。他们彼此排成一行走在路上。看到你之后，为首的人停下来，所有人慢慢地挤作一团，非常害怕。%aggro_bro%建议杀了他们，夺走他们的东西，尽管一眼望去，他们并没有多少东西。}",
			Image = "",
			Characters = [],
			Options = [
				{
					Text = "离开这群可怜的家伙。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local food = this.World.Assets.getFoodItems();

				if (food.len() > 2)
				{
					this.Options.push({
						Text = "把我们的食物分一些给那些人。",
						function getResult( _event )
						{
							return "D";
						}

					});
				}

				if (_event.m.RefugeeDude != null && food.len() > 1)
				{
					this.Options.push({
						Text = "%refugee_bro%，你以前是避难者，去和他们谈谈吧？",
						function getResult( _event )
						{
							return "E";
						}

					});
				}

				this.Options.push({
					Text = "寻找他们的贵重物品！",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-3);

						if (this.Math.rand(1, 100) <= 50)
						{
							return "B";
						}
						else
						{
							return "C";
						}
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_59.png[/img]你命令大家能拿什么拿走什么。避难者恐惧地往后退，有些人对你们表示抗议。突然，其中一个避难者拿着一块大石头砸向%injured_bro%的脑袋。女人和小孩尖叫起来，几个男人抓住雇佣兵，抢夺还没有拔出来的武器。不过他们已经好几天没吃东西了，身体太虚弱，不是你们的对手。%companyname%拿到了自己想要的。",
			Image = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "搞清楚自己的位置，白痴。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.InjuredDude.getImagePath());
				local injury = _event.m.InjuredDude.addInjury(this.Const.Injury.Accident3);
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.InjuredDude.getName() + " suffers " + injury.getNameOnly()
					}
				];
				_event.addLoot(this.List);
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_59.png[/img]你命令大家能拿什么拿走什么。避难者恐惧地向后退。女人们大声哭着，小孩们不知道发生了什么，也跟着哭起来。几个男人求你们离开。面对这群毫无抵抗力的家伙，%companyname%轻而易举拿到了自己想要的东西。你们穿过人群，带着他们的东西回来了。",
			Image = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "他们知道不该反抗。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				_event.addLoot(this.List);
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_59.png[/img]{你让%randombrother%给避难者一些吃的。他们感到十分恐惧，你给拿出面包和水的时候，他们感到十分怀疑。一个老人走上前来，颤抖地跪下亲吻你的脚。你扶他起来，告诉他不用这样做。几个雇佣兵偷偷笑着，称你为‘面团和面包之王’。 |  要想抢劫这些人很简单，不过如果消息传出去，对你们的名声没多少好处。你让%randombrother%给他们一些食物和水。避难者感到十分开心，围到你身边，你就好像一个施展恩惠的神。你刚好有一些要处理的旧食物。有些人说，神像人的时候，人就像神了。}",
			Image = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "一路顺风。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(3);
				local food = this.World.Assets.getFoodItems();

				for( local i = 0; i < 2; i = ++i )
				{
					local idx = this.Math.rand(0, food.len() - 1);
					local item = food[idx];
					this.List.push({
						id = 10,
						icon = "ui/items/" + item.getIcon(),
						text = "你输了" + item.getName()
					});
					this.World.Assets.getStash().remove(item);
					food.remove(idx);
				}

				this.World.Assets.updateFood();
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_59.png[/img]你决定把任务交给一个曾经有过避难者经历的人：%refugee_bro%。\n\n雇佣兵走进不停哭泣、疲惫不堪的旅行者中间。他和他们谈了一会儿，给了一些食物，并向他们诉说自己的过去的经历，很快收服了他们的人心。你看到有个老人给他一个羊皮纸包裹。佣兵鞠了一躬，握了握他的手然后返回。\n\n他把羊皮包裹扔过来，拿出一把闪闪发光，十分锋利的剑。%refugee_bro%路出微笑，%SPEECH_ON%我说过了，友好不会伤害任何人，但这把剑会！%SPEECH_OFF%",
			Image = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "如此谨慎，很不错。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(3);
				this.Characters.push(_event.m.RefugeeDude.getImagePath());
				local food = this.World.Assets.getFoodItems();
				local item = food[this.Math.rand(0, food.len() - 1)];
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你输了" + item.getName()
				});
				this.World.Assets.getStash().remove(item);
				this.World.Assets.updateFood();
				local r = this.Math.rand(1, 2);
				local sword;

				if (r == 1)
				{
					sword = this.new("scripts/items/weapons/arming_sword");
				}
				else if (r == 2)
				{
					sword = this.new("scripts/items/weapons/falchion");
				}

				this.List.push({
					id = 10,
					icon = "ui/items/" + sword.getIcon(),
					text = "你获得了" + _event.getArticle(sword.getName()) + sword.getName()
				});
				this.World.Assets.getStash().add(sword);
			}

		});
	}

	function addLoot( _list )
	{
		local r = this.Math.rand(1, 3);
		local food;

		if (r == 1)
		{
			food = this.new("scripts/items/supplies/dried_fish_item");
		}
		else if (r == 2)
		{
			food = this.new("scripts/items/supplies/ground_grains_item");
		}
		else
		{
			food = this.new("scripts/items/supplies/bread_item");
		}

		_list.push({
			id = 10,
			icon = "ui/items/" + food.getIcon(),
			text = "你获得了" + food.getName()
		});
		this.World.Assets.getStash().add(food);
		this.World.Assets.updateFood();

		for( local i = 0; i < 2; i = ++i )
		{
			r = this.Math.rand(1, 10);
			local item;

			if (r == 1)
			{
				item = this.new("scripts/items/weapons/wooden_stick");
			}
			else if (r == 2)
			{
				item = this.new("scripts/items/armor/tattered_sackcloth");
			}
			else if (r == 3)
			{
				item = this.new("scripts/items/weapons/knife");
			}
			else if (r == 4)
			{
				item = this.new("scripts/items/helmets/hood");
			}
			else if (r == 5)
			{
				item = this.new("scripts/items/weapons/woodcutters_axe");
			}
			else if (r == 6)
			{
				item = this.new("scripts/items/shields/wooden_shield_old");
			}
			else if (r == 7)
			{
				item = this.new("scripts/items/weapons/pickaxe");
			}
			else if (r == 8)
			{
				item = this.new("scripts/items/armor/leather_wraps");
			}
			else if (r == 9)
			{
				item = this.new("scripts/items/armor/linen_tunic");
			}
			else if (r == 10)
			{
				item = this.new("scripts/items/helmets/feathered_hat");
			}

			this.World.Assets.getStash().add(item);
			_list.push({
				id = 10,
				icon = "ui/items/" + item.getIcon(),
				text = "你获得了" + this.getArticle(item.getName()) + item.getName()
			});
		}
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isCivilWar())
		{
			return;
		}

		if (!this.World.State.getPlayer().getTile().HasRoad)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates_aggro = [];
		local candidates_other = [];
		local candidates_refugees = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().isCombatBackground()  ||  bro.getSkills().hasSkill("trait.bloodthirsty")  ||  bro.getSkills().hasSkill("trait.brute"))
			{
				candidates_aggro.push(bro);
			}
			else if (bro.getBackground().getID() == "background.refugee")
			{
				candidates_refugees.push(bro);
			}
			else
			{
				candidates_other.push(bro);
			}
		}

		if (candidates_aggro.len() == 0  ||  candidates_other.len() == 0)
		{
			return;
		}

		this.m.AggroDude = candidates_aggro[this.Math.rand(0, candidates_aggro.len() - 1)];
		this.m.InjuredDude = candidates_other[this.Math.rand(0, candidates_other.len() - 1)];

		if (candidates_refugees.len() != 0)
		{
			this.m.RefugeeDude = candidates_refugees[this.Math.rand(0, candidates_refugees.len() - 1)];
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"aggro_bro",
			this.m.AggroDude.getName()
		]);
		_vars.push([
			"injured_bro",
			this.m.InjuredDude.getName()
		]);
		_vars.push([
			"refugee_bro",
			this.m.RefugeeDude != null ? this.m.RefugeeDude.getName() : ""
		]);
	}

	function onClear()
	{
		this.m.AggroDude = null;
		this.m.InjuredDude = null;
		this.m.RefugeeDude = null;
	}

});

