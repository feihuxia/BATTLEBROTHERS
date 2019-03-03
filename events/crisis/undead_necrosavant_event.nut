this.undead_necrosavant_event <- this.inherit("scripts/events/event", {
	m = {
		Witchhunter = null
	},
	function create()
	{
		this.m.ID = "event.crisis.undead_necrosavant";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_76.png[/img]一堆碎石堆在路边。有个好学的老头儿热切地望着石头。他是如此地专注沉思，如果你走过他都可能不会注意到。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们看看他要干什么。",
					function getResult( _event )
					{
						if (_event.m.Witchhunter != null)
						{
							if (this.Math.rand(1, 100) <= 50)
							{
								return "B";
							}
							else
							{
								return "D";
							}
						}
						else if (this.Math.rand(1, 100) <= 50)
						{
							return "B";
						}
						else
						{
							return "C";
						}
					}

				},
				{
					Text = "继续走吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_17.png[/img]你不想把这个可怜的老家伙独自留在这里。你走过去问他要干什么。他看着你，至少有70个寒冬将他的皮肤风化成了坚韧粗糙。他笑了。%SPEECH_ON%试着想要说通。死人从土里爬起来了，那么我将会如何摆脱我自己的坟墓，我想为什么不确定自己不会加入他们的行列？这里有个寺庙，我小时候在这里得到了净化。我在这里结婚，我唯一的儿子也是在这里结婚。%SPEECH_OFF%你问是什么摧毁了建筑。那个人又笑了。%SPEECH_ON%人们到这里问了和我一样的问题。在这个大地证明了自己的神圣、复活了死者的世界里，算是个虔诚的问题。他们找到的答案是暴力——所以他们决定意一块一块地拆了它。我会告诫他们，但这是个诡计。如果我有办法我可能会做和他们一样的事，但是你知道的，我老了，动动手指都显得艰难了。连一只苍蝇都可以舔你的鼻子而不受惩罚的时候，当个和平使者就很容易了。%SPEECH_OFF%他又大笑。他给了你一个银碗。%SPEECH_ON%我找到了这个。僧侣曾用它泼水清洁病人。这不是我想要的答案，但你拿着它吧。我不需要这些东西。现在不行。没有任何意义。祝你好运，如果你再次这样见到我，请把我从痛苦中解救出来。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "上帝保佑，陌生人。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/loot/silver_bowl_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_29.png[/img]即使对强壮的人来说这也是个危险的时代，对于一个老头来说就更不安全了。你去叫他。他立即转过头，眼睛一闪，瞳孔放大，使得他的视线变成黯淡的深渊。他用手指指着你。%SPEECH_ON%你的血。给我。%SPEECH_OFF%陌生人慢慢抬起他的脚。他的斗篷掉落，露出一个赤裸裸的瘦骨嶙峋的骨架。他走向你。他的嘴巴张着，但是什么都没有表达出来。他好像在说着另一个世界的话。%SPEECH_ON%我估计，你的深红色，我估计，你的深红色。%SPEECH_OFF%%randombrother% 跳向前，手里拿着武器。%SPEECH_ON%他是个巫师！%SPEECH_OFF% 当死灵法师向后靠，人们武装自己，他的斗篷离开地面回到他身上，仿佛风是随叫随到的。突然，尸体从土里出来，咆哮着，哭泣着。他从帽子边缘下面盯着你，慢慢地低下眼睛。%SPEECH_ON%就这样吧。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult( _event )
					{
						if (this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnPartyDestroyed);
						}

						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.UndeadTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Zombies, this.Math.rand(80, 120), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getID());
						properties.Entities.push({
							ID = this.Const.EntityType.Necromancer,
							Variant = 0,
							Row = 2,
							Script = "scripts/entity/tactical/enemies/necromancer",
							Faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getID(),
							Callback = null
						});
						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_76.png[/img]突然，一把弩瞄准了你的肩膀，差点打中，你都能感觉到空气中其绳子的拨动。箭矢穿过老头的头骨，他向前倒下，头插进泥土，屁股朝上，两手还是沮丧的摊开。\n\n你转身看见女巫猎手%witchhunter%站在后面。他放下弩，走到尸体旁，抓住它的颈背，把木桩插进它的背。尸体发出一声尖叫，衣服膨胀，尸体爆炸，一缕粉尘离开了斗篷，仿佛它被抓到假扮一个人一样。\n\n 女巫猎人转向你。%SPEECH_ON%死灵学者。稀有。极度危险。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Uh huh.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Witchhunter.getImagePath());
				local item = this.new("scripts/items/misc/vampire_dust_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				_event.m.Witchhunter.improveMood(1.0, "Killed a Necrosavant on the road");

				if (_event.m.Witchhunter.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Witchhunter.getMoodState()],
						text = _event.m.Witchhunter.getName() + this.Const.MoodStateEvent[_event.m.Witchhunter.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return;
		}

		if (!this.World.State.getPlayer().getTile().HasRoad)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.witchhunter")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() != 0)
		{
			this.m.Witchhunter = candidates[this.Math.rand(0, candidates.len() - 1)];
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"witchhunter",
			this.m.Witchhunter != null ? this.m.Witchhunter.getName() : ""
		]);
	}

	function onClear()
	{
		this.m.Witchhunter = null;
	}

});

