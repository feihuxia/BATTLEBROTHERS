this.civilwar_ambush_event <- this.inherit("scripts/events/event", {
	m = {
		NobleHouse = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_ambush";
		this.m.Title = "路上…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img]森林中隐藏了很多东西，是捕食者和有野心之人的胜地。但你很了解这一点，你知道怎么找出这种气候里最不自然的阴影。你没花多久就意识到这里不只有树，对着灌木深处猛挥一拳后你拖出一个拿弓的男孩。他大喊救命，增援像追逐美妙乐曲的黄莺一样涌来：一群人从阴影中现身，但战团准备好了，拔出武器，站到了对等的位置。\n\n 一个年纪稍大的人上前来，他举着双手。%SPEECH_ON%等等，没必要动手。%SPEECH_OFF%他独自朝你走来，语气柔和，像学者一样解释了发生的事。一小群农民准备伏击随时可能路过的%noblehouse%军队。他表示如果你愿意帮忙，就能获得奖励。如果你不愿意，就请离开。",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "帮帮这些农民吧。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "我们得警告士兵们。",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "我们没时间整这些事。",
					function getResult( _event )
					{
						return 0;
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
			Text = "[img]gfx/ui/events/event_10.png[/img]他们都是农民，跟乞丐一样，好像是来这里找留存的东西拿来穿的。但这些脆弱的弓箭碰上了久经沙场的老兵，他们技艺娴熟，能轻松射中目标。他们是属于森林的人。出于对此次伏击顺利进行的自信，你选择加入他们。\n\n 你没等多久，%noblehouse%的士兵就过来了。他们声音响亮，惹人憎恶，有人放着屁，抱怨着误食的蘑菇。\n\n 一个差不多到你一半高的孩子射出了第一支箭。箭矢飞过了两根树枝，带头的侦察兵摔倒了。引起了仿佛大风过境一般的混乱——箭矢，看不见的动作，呼啸到士兵队伍中，他们准头很好，目标死得悄无声息。一些士兵成功拉近了距离，举起了剑和盾牌，但%companyname%上前击杀了他们。很快，整个军队覆灭了。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "一切顺利。我们来分战利品吧。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_87.png[/img]你的人去搜查尸体，里面混杂了杀手。关于谁应该拿盾牌一事发生了混战。你解释说盾牌存在的唯一原因就是你的人杀掉了盾牌的主人。队伍的首领赞同的点点头。他大声宣布你的战团应该拿走这件重型装备，因为你的人能更好地使用这种东西。\n\n 在你们分摊战利品的时候，一位弓箭手走上前来。%SPEECH_ON%我觉得他们有人逃掉了。他留下了痕迹，但他肯定比死掉的兄弟聪明一点，因为他往回跑了，而且小心遮掩了行动。%SPEECH_OFF%你正好想着能逃过一些事情……",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "除了那个逃走的家伙，都很好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationOffense, "Ambushed some of their men");
				this.World.Assets.addMoralReputation(-1);
				_event.m.Town.getFactionOfType(this.Const.FactionType.Settlement).addPlayerRelation(this.Const.World.Assets.RelationFavor, "Helped in an ambush against " + _event.m.NobleHouse.getName());
				local item;
				local banner = _event.m.NobleHouse.getBanner();
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
					item = this.new("scripts/items/weapons/billhook");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				r = this.Math.rand(1, 4);

				if (r == 1)
				{
					item = this.new("scripts/items/shields/faction_wooden_shield");
					item.setFaction(banner);
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/shields/faction_kite_shield");
					item.setFaction(banner);
				}
				else if (r == 3)
				{
					item = this.new("scripts/items/armor/mail_shirt");
				}
				else if (r == 4)
				{
					item = this.new("scripts/items/armor/basic_mail_shirt");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_94.png[/img]你跟农民说你完全不想掺和他们的战争，你会远离它的。\n\n 他们一走到看不见听不着的地方，你就找到了%noblehouse%的士兵，告诉他们即将来临的麻烦。中尉不相信你，直到你带他到农民那儿，指出了他们，或者说，指出了他们徘徊在枝丫之后的细长影子。\n\n 你回到军队中阻止了一场袭击。很简单——你到伏击地点，从后方出现。老人，绝望的男人，还有天真的男孩依次被杀死。他们没想到这一切，但在最混乱的时刻，肯定有人逃了出去，说出了你的背叛。你从战场收集了一些物资，还获得了%noblehouse%旗手的好意。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "当地人可能会听说这件事，但有什么关系呢？",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationFavor, "Saved some of their men");
				_event.m.Town.getFactionOfType(this.Const.FactionType.Settlement).addPlayerRelation(this.Const.World.Assets.RelationOffense, "Killed some of their men");
				local money = this.Math.rand(200, 400);
				this.World.Assets.addMoney(money);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] 克朗"
				});
				local item;
				local r = this.Math.rand(1, 5);

				if (r == 1)
				{
					item = this.new("scripts/items/weapons/pitchfork");
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/weapons/short_bow");
				}
				else if (r == 3)
				{
					item = this.new("scripts/items/weapons/hunting_bow");
				}
				else if (r == 4)
				{
					item = this.new("scripts/items/weapons/militia_spear");
				}
				else if (r == 5)
				{
					item = this.new("scripts/items/shields/wooden_shield");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isCivilWar())
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();

		if (playerTile.Type != this.Const.World.TerrainType.Forest && playerTile.Type != this.Const.World.TerrainType.LeaveForest && playerTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local bestDistance = 9000;
		local bestTown;

		foreach( t in towns )
		{
			if (t.isMilitary() || t.getSize() >= 3)
			{
				continue;
			}

			local d = playerTile.getDistanceTo(t.getTile());

			if (d < bestDistance)
			{
				bestDistance = d;
				bestTown = t;
			}
		}

		if (bestTown == null || bestDistance > 10)
		{
			return;
		}

		local nobleHouses = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local candidates = [];

		foreach( h in nobleHouses )
		{
			if (h.getID() != bestTown.getOwner().getID())
			{
				candidates.push(h);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.NobleHouse = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Town = bestTown;
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
		_vars.push([
			"town",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.NobleHouse = null;
		this.m.Town = null;
	}

});

