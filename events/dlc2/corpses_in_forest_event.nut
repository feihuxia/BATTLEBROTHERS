this.corpses_in_forest_event <- this.inherit("scripts/events/event", {
	m = {
		BeastSlayer = null,
		Killer = null
	},
	function create()
	{
		this.m.ID = "event.corpses_in_forest";
		this.m.Title = "一路上...";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_132.png[/img]{当部队行进在树林中时你注意到了林中有一堆被烧焦的尸体，他们紧紧地抱在一起。它只剩下了一团扭曲的黑色躯体与一张可怖的脸死死的凝视着天空。附近弥漫着类似烤猪肉的味道并且还未散去，然而这里完全连猪都没有。 %randombrother% 看着这片场景，点了点头。%SPEECH_ON%看来这里发生了什么可怕的事情。%SPEECH_OFF%你也点了点头，确实是这样。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "也许我们还能在这里找到什么有用的东西。",
					function getResult( _event )
					{
						if (_event.m.BeastSlayer != null && this.Math.rand(1, 100) <= 75)
						{
							return "D";
						}
						else if (_event.m.Killer != null && this.Math.rand(1, 100) <= 75)
						{
							return "E";
						}
						else
						{
							return this.Math.rand(1, 100) <= 50 ? "B" : "C";
						}
					}

				},
				{
					Text = "此地不宜久留。",
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
			Text = "[img]gfx/ui/events/event_132.png[/img]{佣兵们跨过尸体。大部分的尸体都是三四个的被捆在了一起，仿佛就是个破裂的鸡蛋。尸体粘连在一起，需要废一些力气才能把他们分开。但当大家试图这么做时，烧焦的尸体也会随之被撕裂，一些被烧焦的孩童尸体，像是鱼肉一样被削平，他们的胸膛被剖开，手直直的伸在半空。翻开尸体但是并没有找到什么有用的物资，最多也只是翻到了一些钱。 %randombrother% 则找到了一个外形诡异的面具。你不敢完全确定这到底是什么东西，但至少现在证明这面具不会咬人，也许未来就会有商人发现它的价值吧。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "继续上路吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/misc/petrified_scream_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + _event.getArticle(item.getName()) + item.getName()
				});
				local money = this.Math.rand(10, 100);
				this.World.Assets.addMoney(money);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_132.png[/img]{%randombrother% 蜷缩在被烧焦的尸体球旁边，摇了摇头。%SPEECH_ON%长官，我真的真的不认为这里边会有任何东西。%SPEECH_OFF%没等你回应他，忽然一只焦炭般的手从尸体堆中钻出，并且抓在了他的脚踝上。手的主人站了起来，随后开始移动。一个孤独的受害者从灼热的尸山里爬了出来，背上像烧蛇一样，身上压着烧焦的尸体，还披着斗篷。他的嘴简直惨不忍睹，他的嘴唇已经被烧没了，同时脸颊也被挖空，他的眼睛现在只剩下了两个空洞的口。 他的手掌仿佛石化怪兽的利爪，当雇佣兵们向后逃窜时，他只是尝试把烧焦的人拉到他身边。整个尸堆开始翻滚，一些尸体从顶上滚落下来，他们的四肢像桌腿一样僵硬地伸出来，其他人依然还只是盯着天空，另一个尝试逃离尸山的焦炭人将头撞到地上，你们看着他头颅的一部分化作了黑色的粉尘，看着他呻吟着，幸存者们恳求着喝水。最终你选择了拔出剑刺向了他们的喉咙，结束了他们的痛苦。 %randombrother% 则只能扯断那些干枯的手指，以让自己的脚摆脱束缚。不少人被这片场景深深的震撼到了。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们继续上路吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (!bro.getBackground().isOffendedByViolence() || bro.getLevel() >= 7)
					{
						continue;
					}

					bro.worsenMood(0.75, "Shaken by a gruesome scene");

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
			ID = "D",
			Text = "[img]gfx/ui/events/event_132.png[/img]{%beastslayer% 举起了手。%SPEECH_ON%他们不是被谋杀的，而是被净化掉的。%SPEECH_OFF%他蹲在尸堆的边缘，抬起一只烧焦的手臂，手只能从肘部被抬起。他随后翻转了一下手臂，并且尝试按压了一下它。绿色的脓汁从血管中流了出来，一滴一滴的落在了地上。%beastslayer% 拿出了一个小瓶子，收集了所有他能收集到的东西。%SPEECH_ON%这些人明显是被某种病毒感染了，这些病毒经常以溶解器官的方式杀死被感染者，但是有时候，我是指偶尔，他们会有其他功能。使浓密毛发的毛发在手臂上长出来，指甲明显变长，肩胛骨开始疼痛并从背部突出。看起来会十分怪异，然后，病毒会攻击他们的脑神经，导致他们彻底疯狂。%SPEECH_OFF%当你问到这些尸体是否都被感染了。%beastslayer% 摇了摇头。%SPEECH_ON%这个尸体我是从他的肩膀上判断出他被感染的，剩下这些，我就不太清楚了。当疾病袭击一个村庄之时，也许谁都跑不了，很快混乱会成为真正的传染病，而疾病本身只是在它开始的篝火中一片被遗忘的火花罢了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们还是继续赶路吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.BeastSlayer.getImagePath());
				local item = this.new("scripts/items/accessory/spider_poison_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_132.png[/img]{%killer% 他跑上了尸体堆，哼着歌，他点了点头，随后吐了一口唾沫，又点了点头。 他指了指这堆尸体。%SPEECH_ON%这作案手法太残暴了，我真的不认为有人在干了这种事之后还能活下去。%SPEECH_OFF%你询问他的具体意思, 但是他伸出了一根手指，随后走入了树林。你跟着他走过了一棵一棵树，直到他停下了脚步。%SPEECH_ON%和我想的差不多。%SPEECH_OFF%你走上前去，发现了一个在这里上吊自杀的人。他的指尖是泛黑，脸上还留着一些灰烬，脖子上则有一个绳子套索。手中紧握着一份笔记，上边写着全是道歉的话，但没有描述他的究竟做了什么或者为什么而做。尸体之下，摆放着他的盔甲与武器。他曾经也许是个贵族。但不论如何，放下了上吊的尸体，并把物资洗劫一空。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "走吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Killer.getImagePath());
				local item = this.new("scripts/items/weapons/morning_star");
				item.setCondition(this.Math.rand(5, 30) * 1.0);
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/armor/basic_mail_shirt");
				item.setCondition(this.Math.rand(25, 60) * 1.0);
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		if (!currentTile.HasRoad)
		{
			return;
		}

		local myTile = this.World.State.getPlayer().getTile();

		foreach( s in this.World.EntityManager.getSettlements() )
		{
			local d = s.getTile().getDistanceTo(myTile);

			if (d <= 6)
			{
				return;
			}
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates_beastslayer = [];
		local candidates_killer = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.beast_hunter")
			{
				candidates_beastslayer.push(bro);
			}
			else if (bro.getBackground().getID() == "background.killer_on_the_run")
			{
				candidates_killer.push(bro);
			}
		}

		if (candidates_beastslayer.len() != 0)
		{
			this.m.BeastSlayer = candidates_beastslayer[this.Math.rand(0, candidates_beastslayer.len() - 1)];
		}

		if (candidates_killer.len() != 0)
		{
			this.m.Killer = candidates_killer[this.Math.rand(0, candidates_killer.len() - 1)];
		}

		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"beastslayer",
			this.m.BeastSlayer != null ? this.m.BeastSlayer.getNameOnly() : ""
		]);
		_vars.push([
			"killer",
			this.m.Killer != null ? this.m.Killer.getNameOnly() : ""
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.BeastSlayer = null;
		this.m.Killer = null;
	}

});

