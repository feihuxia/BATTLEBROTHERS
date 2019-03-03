this.come_across_ritual_event <- this.inherit("scripts/events/event", {
	m = {
		Cultist = null
	},
	function create()
	{
		this.m.ID = "event.come_across_ritual";
		this.m.Title = "路上…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_33.png[/img]在旅途中尸体并不少见。尽管，这一具，相当不同。%randombrother%看了很久。%SPEECH_ON%他胸口是什么？%SPEECH_OFF%你蹲下来，扔回了尸体的衣服。伤疤在他身上纵横，画出了很熟悉的形状：森林，河流，山峦。%randombrother%走上来。%SPEECH_ON%没什么好看的。狼会这么做还是怎么样？%SPEECH_OFF%你站起来。%SPEECH_ON%我觉得是他自己弄的。%SPEECH_OFF%带血的足印从现场离开……",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们跟着脚印走。",
					function getResult( _event )
					{
						return "Arrival";
					}

				},
				{
					Text = "这不关我们的事。",
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
			ID = "Arrival",
			Text = "[img]gfx/ui/events/event_03.png[/img]你跟着脚印走，开始听到赞颂的声音。你让战团在原地休息，独自上前，最终发现了一处巨大的篝火，身披斗篷的人围绕在它周围。他们跺着脚，高举双手，对他们古老的神，达库尔念诵令词。这是个野蛮的仪式，充满了咆哮和怒吼，人们穿着过大的衣物起舞，好像阴郁的灵魂依然对离去的世界感到愤怒。%randombrother%在你身边匍匐前进，摇着头。%SPEECH_ON%这里发生了什么？我们怎么办？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们立刻想办法阻止这一切。攻击！",
					function getResult( _event )
					{
						return "Attack1";
					}

				},
				{
					Text = "等等看。",
					function getResult( _event )
					{
						return "Observe1";
					}

				},
				{
					Text = "该走了。马上。",
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
			ID = "Observe1",
			Text = "[img]gfx/ui/events/event_03.png[/img]你决定等一等，看看会发生什么。就在你说那句话的时候，异教徒把一个老头拉到了火堆前。他在火焰前低下头，张开双臂，然后倒下去。没有尖叫。另一个人被拉上前。他对一个异教徒低语，他们都点了头，然后这个人也跳进了火焰。第三个被退出来，但他不像其他人，他戴着枷锁，眼神疯狂。他对异教徒大喊大叫。%SPEECH_ON%让你们的神去死吧，他就是个屁！都是骗人的！%SPEECH_OFF%火焰中出现了一张脸，球状的，在烟火中搅动着。它表现的是残忍，由火焰刻画不比由黑暗本身刻画来得好。它转动着，发出笑声。一个异教徒喊道。%SPEECH_ON%达库尔等着你！%SPEECH_OFF%但囚犯踢了关押人一脚，企图逃跑。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我看够了。我们得帮他，快点！",
					function getResult( _event )
					{
						return "Attack2";
					}

				},
				{
					Text = "等等，看看接下来会怎么样。",
					function getResult( _event )
					{
						return "Observe2";
					}

				}
			],
			function start( _event )
			{
				if (_event.m.Cultist != null)
				{
					this.Options.push({
						Text = "%cultist%，这不是你的邪教吗？",
						function getResult( _event )
						{
							return "Cultist";
						}

					});
				}

				this.Options.push({
					Text = "该走了。马上。",
					function getResult( _event )
					{
						return 0;
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "Observe2",
			Text = "[img]gfx/ui/events/event_03.png[/img]你决定等等，看发生了什么。篝火中的脸又出现了，男人被腿上前时，岩浆大口张开了。他尖叫着往后倒，但毫无作用。他的衣服被烧没了，碎布往后飞到橙色的废墟上。他的皮肤剥落下来，就好像不是碰到火焰，而是一千把小刀划过他的身体一般。他被尖锐的白色火焰剥皮了。头骨露出来，像蜕皮的蛇一样蠕动扭曲着，眼睛永远睁着，尽管身体余下的部分已经没有了血肉，器官和骨头。当他变成有眼睛的头颅后，火焰中的脸庞闭上了嘴，献祭的咆哮变为沉寂。篝火立刻熄灭了，而那个人，或者说他剩下的部分，掉在了地上。眼睛被灼烧得闪闪发亮，像冷却下来的热铁一样缓缓熄灭。\n\n 有位异教徒弯下腰，捡起了头骨。他轻松把它分成两半，拿着曾经是脸的那部分，把脑壳掉了下来。他拿着这东西往外走，骨头开始发黑扭曲，生成的以骨圈环绕的残忍面容散发出黑暗。他戴上它，开始离去。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "现在行动吧！",
					function getResult( _event )
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.CivilianTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];

						for( local i = 0; i < 25; i = ++i )
						{
							local unit = clone this.Const.World.Spawn.Troops.Cultist;
							unit.Faction <- this.Const.Faction.Enemy;
							properties.Entities.push(unit);
						}

						properties.Loot = [
							"scripts/items/helmets/legendary/mask_of_davkul"
						];
						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				},
				{
					Text = "我们也离开。",
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
			ID = "Cultist",
			Text = "[img]gfx/ui/events/event_03.png[/img]你询问%cultist%他能不能做点什么。他只是走过你身边，下了山。异教徒队伍转过去看着他。他穿过人群到囚犯身边。他们进行了交谈。他低语着，囚犯点着头。等他们说完。%cultist%对异教徒队伍点点头。一位成员走上前，脱下衣物，投入了火焰，无声无息，也无抗议。另一个异教徒把叉子投入火焰，从中取出了什么东西，把它交给了%cultist%。囚犯，他的妻子表面上看来是因为交易而幸免，被释放了，你看着%cultist%抓起他，带他回到了山上。他边说便把那人推上前。%SPEECH_ON%你从达库尔那里拿走了东西，但债务已经付清。%SPEECH_OFF%你问他手里拿着什么。异教徒举起了从火焰中取回的东西。是个皮革包裹的头骨，紧贴在上面的是新近烤焦的面容，可能是那个投身到火焰中的人。他的脸扭曲着无声的暗示，嘴巴微张，因为残忍幽咽的黑暗而显得怪异。%cultist%还是像土著人炫耀战利品一样举着它，坦率道。%SPEECH_ON%达库尔等我们。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这是什么？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cultist.getImagePath());
				this.World.Assets.getStash().makeEmptySlots(1);
				local item = this.new("scripts/items/helmets/legendary/mask_of_davkul");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Attack1",
			Text = "[img]gfx/ui/events/event_03.png[/img]你下令进攻。你的人拿起武器冲向前方。火焰瞬间熄灭了，什么都没留下，只有漫天灰烬散了开来。等它散尽，怪异的人群张开双臂，一致喊道。%SPEECH_ON%达库尔在等待。来和他问好吧。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult( _event )
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.CivilianTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];

						for( local i = 0; i < 25; i = ++i )
						{
							local unit = clone this.Const.World.Spawn.Troops.Cultist;
							unit.Faction <- this.Const.Faction.Enemy;
							properties.Entities.push(unit);
						}

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
			ID = "Attack2",
			Text = "[img]gfx/ui/events/event_03.png[/img]你不支持这种不公之举，决定冲上去救下他。在你站出来举剑下令之时，篝火中伸出了火焰触手，抓住了被束缚的男人，将他拉进了火焰中。在短促的尖叫声中他已经消失了。火焰凝聚成火柱，很快崩塌了。一团灰烬炸裂开来。那人消失了，火焰仿佛不曾存在过一样。天空中甚至没有烟雾。\n\n 异教徒转向你，指着你，一致地开口说道。%SPEECH_ON%带来死亡吧，你的或我们的，因为达库尔等待着我们所有人。%SPEECH_OFF%你停了一会儿，然后下令冲锋。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult( _event )
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.CivilianTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];

						for( local i = 0; i < 25; i = ++i )
						{
							local unit = clone this.Const.World.Spawn.Troops.Cultist;
							unit.Faction <- this.Const.Faction.Enemy;
							properties.Entities.push(unit);
						}

						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		if (this.World.getTime().Days <= 200)
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();
		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d >= 4 && d <= 10)
			{
				nearTown = true;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 11 && (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() < 2)
		{
			return;
		}

		if (candidates.len() != 0)
		{
			this.m.Cultist = candidates[this.Math.rand(0, candidates.len() - 1)];
		}

		this.m.Score = 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"cultist",
			this.m.Cultist != null ? this.m.Cultist.getNameOnly() : ""
		]);
	}

	function onClear()
	{
		this.m.Cultist = null;
	}

});

