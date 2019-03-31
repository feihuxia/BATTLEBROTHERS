this.civilwar_wounded_soldier_event <- this.inherit("scripts/events/event", {
	m = {
		NobleHouse = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_wounded_soldier";
		this.m.Title = "路上…";
		this.m.Cooldown = 25.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_21.png[/img]{走在路上的时候，你碰到了一名%noblehouse%的士兵，你的同伴。他站在地上，靠着一堵石墙。看着你，他嗤笑了一声。%SPEECH_ON%你想要啥，佣兵？来了结我的吗？拿走我身上的东西？%SPEECH_OFF%他穿着一套不错的盔甲而且身上也有一把武器。当然他现在是没办法用那东西了，但是如果给你手下人用的话应该很不错。%randombrother%走了过去。%SPEECH_ON%我们可以搞定他，先生，但得快点。谁知道会发生什么，毕竟他穿着贵族军队的衣服。%SPEECH_OFF%  |  你碰到了一名%noblehouse%的受伤士兵，你的盟友军队的一员。躺在草地上，他挣扎着站了起来，看着你，你也好好看了看他：男人穿着得体的盔甲，而且腿间还插着一把武器。你可以把这两个都拿走，但是这男人看上去应该不会自愿给你的。而且很有可能军队其他人就在不远的地方…… | %noblehouse%，你的盟友的一名受伤士兵，躺在了路上。他在挣扎着想要离开，但是听到你的声音之后他就停了下来，然后转了身。%SPEECH_ON%该死的。你最好转身，佣兵。我的人就在附近，而且如果你过来的话我会扯破嗓子叫的。%SPEECH_OFF%你挑了挑眉毛。%SPEECH_ON%你要像个女人一样去死吗？%SPEECH_OFF%男人吐了口唾沫。%SPEECH_ON%这样子我死的时候就能知道很快就能在阴间看见你了。%SPEECH_OFF%那兔崽子身上有一套不错的盔甲和武器，但是%randombrother%警告说了他是贵族军队中的一员。 |  一个%noblehouse%的受伤士兵躺在你面前。一方面，他身上有你可以夺走的武器和盔甲。另一方面，他肯定属于一个比你大得多的军队的。那军队正好只是在这一刻没有看着他而已。如果你决定夺取他的东西的话，这还是需要好好想想的。 |  运气还是即将到来的灾祸？你发现一名穿着相当不错的盔甲的受伤士兵。他腰间也挂了一把武器，而且如果给一个%companyname%的人的话就更加不错了。拿走他的东西应该轻而易举。附近又没有人看，闷死他应该不难。\n\n但话又说回来，附近很有可能有一只大部队，因为这个士兵正好穿着%noblehouse%，你的盟友的衣服。选选选…… | 你碰到乐一名带着%noblehouse%的破碎旗帜的受伤士兵。看见你之后，他很快在草地上爬了起来。他甩手想要骂人，但是嘴里面就吐出了血沫子。%randombrother%靠近了你。%SPEECH_ON%先生，他身上的武器和盔甲都不错啊。我们可以解决掉他的，如果你想的话，但是附近有可能有军队在。我们应该小心行事。%SPEECH_OFF%  |  你发现一名%noblehouse%的士兵正想要踢开一处无人农舍的大门。听见你之后，他马上转身过来，拿出了一把剑想要保护自己。但是握剑的手却是相当不稳。血从他的左臂流了出来，滴在了腰上，男人站着都费力了。%SPEECH_ON%退后，恶棍们！%SPEECH_OFF%一个害怕的男人被逼近了角落。真可惜他不是一头动物啊，那样子你就会三思而行了……\n\n %randombrother%抓住了你的手臂。%SPEECH_ON%等等，先生。如果他剩下来的部队看见我们的话就要出大事了。还是好好想一想吧？%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			Banner = "",
			Options = [
				{
					Text = "我们还是继续前进，别烦他了。",
					function getResult( _event )
					{
						return 0;
					}

				},
				{
					Text = "盔甲和武器还是有用的，但他以后不需要这些了。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-1);

						if (this.Math.rand(1, 100) <= 50)
						{
							return "B";
						}
						else
						{
							return "C";
						}
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_21.png[/img]{你拔出了剑，向那士兵走去。他大叫起来，紧接着一声凄厉的叫声，你的剑已从后脑勺刺入他的最终，转瞬之间，一切归于平静。吐着鲜血，他向着剑击打了几下，倒在了地上。死时，恐惧，绝望的眼神瞪在你的脸上。你收回剑，回头叫那人把他身上的东西全带上。你在死去的那人所带的旗帜上擦拭着剑刃。 | 那人明白了你的意图，提高了声量。但你已手持剑刃，迅速地踏过死去那人的身体，向前跑去。他的死给你带来了一丝痛苦。并非道德的谴责，而是陈年的往事所致。%randombrother%手搭在你的肩上抚慰你。%SPEECH_ON%首领，放轻松，你非从前柔弱的你了。%SPEECH_OFF%你点了点头，擦了下你的剑刃，告诉手下尽其所能地去抢掠。 | 士兵往后靠了靠。%SPEECH_ON%嗯，我知道了。%SPEECH_OFF%他抬了抬脖子%SPEECH_ON%你懂我的。不会让你失望的。%SPEECH_OFF%他不假思索地一刀砍去，把他的头砍落在地，鲜红的鲜血溢满了他的胸膛。你的手下尽可能地抢掠。你拿出了匕首。那人掏出了武器，但你一脚就把他踹到了一边。他的手臂无力地垂了下来，仿佛你只是卸去了他身上的负担。他盯着你。%SPEECH_ON%等等……%SPEECH_OFF%后话未出，就已死去。你用剑在他喉咙出开了一道大口子，他嘴里嘟囔着什么，但只见鲜血不停从其嘴中吐出。你命令%randombrother% 去拿走他身上一切能拿的东西。}",
			Image = "",
			Characters = [],
			List = [],
			Banner = "",
			Options = [
				{
					Text = "又一件平奇普通的战事。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.addLoot(this.List);
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_90.png[/img]{你拔出了剑，向那士兵走去。他举起了手，但你直接用剑洞穿了他的手掌，直入他的头骨之中。他下耷着舌头，口中溢出血与唾沫，含糊地说着遗言。清理着你的剑刃，你转向%randombrother%，只见站着那个旗帜男。%SPEECH_ON%操你妹的。大家，快跑。%SPEECH_OFF%%companyname%跑得些许凌乱，但速度很快，跳着跑过灌木丛和小溪，然后折路返回藏好，并把一只碍事的猎犬杀于无声之中。你成功地跑开了，但却没带走任何东西。 | 你抽出你的剑，刺入那人的胸膛之中。他伸手抓住你的上衣，把剑从身体中抽出。他咬着牙硬撑出笑容。%SPEECH_ON%佣兵，*你妹的。我呆会在那边跟你碰面。%SPEECH_OFF%他往后退，让剑从自己体内脱出，剑脱离他时，一道鲜血喷涌而出。突然，%randombrother%大声叫了你一下。%SPEECH_ON%首领，我们该走了！看那个旗帜男！%SPEECH_OFF%%noblehouse%的骑兵就在这附近的山顶上，他们肯定看到了刚才发生的事情。你大声呼喊，命令%companyname%赶快撤离。虽然你成功地逃离了，但你无疑得到了你潜在雇佣者的善意。 | 你咄咄地冲至他跟前，他却笑着。你用剑刺入他的胸膛，他仍笑着。最后，他仍大笑着，当你把剑抽离他的身体。他的眼睛逐渐失去生气，远远望着附近的那座山，原来，他笑是因为旗帜男就站在那，已经看到了你刚才的所作所为。\n\n你大叫着，命令%companyname%赶快撤离，以免被那整支军队追到，然后杀得一人不剩。在仓促的逃离中，你放弃了全部的战利品。但，能让自己保住性命，已经很值了。 | 你剑刃眨眼间刺穿了那人的喉咙。他用手捂住伤口，但鲜血在手指间一点点地流逝。他倒下之时，%randombrother%大声向你喊道。%SPEECH_ON%首领，你看！%SPEECH_OFF%这士兵的同伙——旗帜男正站在远处的山上，他肯定看到了刚才发生的事。你快速地下了指令，让%companyname%赶快撤离，在大部队来临之前尽快离开这个地方。在慌乱的撤退之中，你没暇带走的用血换来的战利品。",
			Image = "",
			Characters = [],
			List = [],
			Banner = "",
			Options = [
				{
					Text = "傲慢！长存的傲慢！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationOffense, "Killed one of their men");
			}

		});
	}

	function addLoot( _list )
	{
		local item;
		local banner = this.m.NobleHouse.getBanner();
		local r;
		r = this.Math.rand(1, 4);

		if (r == 1)
		{
			item = this.new("scripts/items/weapons/arming_sword");
		}
		else if (r == 2)
		{
			item = this.new("scripts/items/weapons/morning_star");
		}
		else if (r == 3)
		{
			item = this.new("scripts/items/weapons/military_pick");
		}
		else if (r == 4)
		{
			item = this.new("scripts/items/weapons/warbrand");
		}

		this.World.Assets.getStash().add(item);
		_list.push({
			id = 10,
			icon = "ui/items/" + item.getIcon(),
			text = "你获得了" + this.getArticle(item.getName()) + item.getName()
		});
		r = this.Math.rand(1, 4);

		if (r == 1)
		{
			item = this.new("scripts/items/armor/special/heraldic_armor");
			item.setFaction(banner);
		}
		else if (r == 2)
		{
			item = this.new("scripts/items/helmets/faction_helm");
			item.setVariant(banner);
		}
		else if (r == 3)
		{
			item = this.new("scripts/items/armor/mail_shirt");
		}
		else if (r == 4)
		{
			item = this.new("scripts/items/armor/mail_hauberk");
			item.setVariant(28);
		}

		item.setCondition(44.0);
		this.World.Assets.getStash().add(item);
		_list.push({
			id = 10,
			icon = "ui/items/" + item.getIcon(),
			text = "你获得了" + this.getArticle(item.getName()) + item.getName()
		});
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

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local nobleHouses = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local candidates = [];

		foreach( h in nobleHouses )
		{
			if (h.isAlliedWithPlayer())
			{
				candidates.push(h);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.NobleHouse = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"noblehouse",
			this.m.NobleHouse.getName()
		]);
	}

	function onClear()
	{
		this.m.NobleHouse = null;
	}

});

