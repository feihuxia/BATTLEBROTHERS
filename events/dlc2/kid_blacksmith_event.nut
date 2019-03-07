this.kid_blacksmith_event <- this.inherit("scripts/events/event", {
	m = {
		Juggler = null,
		Apprentice = null,
		Killer = null,
		Other = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.kid_blacksmith";
		this.m.Title = "在 %townname%";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_97.png[/img]{走在%townname%武器店的附近,你的袖子被拉住了，你转过身来，发现是一个脸上涂满黑色的孩子，只有两对明亮雪白的眼睛看着你，他问你对剑是否有了解，你点头肯定。%SPEECH_ON%太棒了！他激动的拍手，我正在为一个铁匠工作，铁匠让我用铁锭制作一柄特殊的剑，但是..剑掉地上散架，你能帮我把它重新拼装起来吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "谁能帮帮这孩子？",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 70)
						{
							return "Good";
						}
						else
						{
							return "Bad";
						}
					}

				}
			],
			function start( _event )
			{
				if (_event.m.Juggler != null)
				{
					this.Options.push({
						Text = "看起来%juggler%想帮助你。",
						function getResult( _event )
						{
							return "Juggler";
						}

					});
				}

				if (_event.m.Apprentice != null)
				{
					this.Options.push({
						Text = "看起来%apprentice%想帮助你。",
						function getResult( _event )
						{
							return "Apprentice";
						}

					});
				}

				if (_event.m.Killer != null)
				{
					this.Options.push({
						Text = "看起来%killer%想帮助你。",
						function getResult( _event )
						{
							return "Killer";
						}

					});
				}

				this.Options.push({
					Text = "不，滚蛋！",
					function getResult( _event )
					{
						return "No";
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "No",
			Text = "[img]gfx/ui/events/event_97.png[/img]{你让着孩子滚蛋，因为城里小偷太多了，你赶紧检测了口袋，确保一切都在。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "谢天谢地，没丢东西。",
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
			ID = "Good",
			Text = "[img]gfx/ui/events/event_97.png[/img]{%other% 被选去帮助孩子。他将剑的手柄和剑身放在一起，小孩自己动手加工，齐力地将剑修复一新。你对孩子的技巧感到惊讶，并想知道如果这仅仅是学徒的话，那么铁匠本身技术要有多好。 修复工作完成后，男孩提出帮助%companyname% 佣兵团修复武器，你愉快的答应了。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干得漂亮!",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Other.getImagePath());
				local stash = this.World.Assets.getStash().getItems();
				local items = 0;

				foreach( item in stash )
				{
					if (item != null && item.isItemType(this.Const.Items.ItemType.Weapon) && item.getCondition() < item.getConditionMax())
					{
						item.setCondition(item.getConditionMax());
						this.List.push({
							id = 10,
							icon = "ui/items/" + item.getIcon(),
							text = "你的 " + item.getName() + " 被修复了"
						});
						items = ++items;

						if (items > 3)
						{
							break;
						}
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "Bad",
			Text = "[img]gfx/ui/events/event_97.png[/img]{%other% 你要求他帮助这个孩子，他懒洋洋的走到铁砧前，铁砧的样子像臼齿一样，铁匠的货物挂在墙上的铁钩上，小孩拍了拍手。%SPEECH_ON%现在什么也别碰，仅仅帮我处理这个。%SPEECH_OFF% %other% 他转过身来，场面混乱不堪，剑从铁砧侧面掉了下来，孩子赶紧抓住它，但是还是重重的摔在了鹅卵石上，剑刃四周卷曲起来，就像一只被按在拇指下的蟋蟀。你从远处看到了这一切，让佣兵在事情变麻烦前赶紧回来。正如大家看到的一样，佣兵仓皇而逃。%SPEECH_ON%先生我们现在什么都不做吗？%SPEECH_OFF%你点了点头.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我想你应该保持一段时间低调",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Other.getImagePath());
				_event.m.Other.worsenMood(1.5, "Accidentally crippled a little boy");

				if (_event.m.Other.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Other.getMoodState()],
						text = _event.m.Other.getName() + this.Const.MoodStateEvent[_event.m.Other.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Juggler",
			Text = "[img]gfx/ui/events/event_97.png[/img]{你发现杂耍者把铁匠铺的匕首和斧子都扔到空中，人群中一阵叫好者，你怀疑自己派出杂耍者去帮助这孩子的决定是否正确，人群渐渐聚集，杂耍者戴上帽子继续表演。人们纷纷投来硬币，在最后表演同时投掷五根狼牙棒时，掌声震耳欲聋。表演结束，他拿起帽子跑回来。%SPEECH_ON%真是美好的一天，先生%SPEECH_OFF%你点头，你问这个孩子武器修复的情况，他擦了擦额头的汗水。%SPEECH_ON%你说什么，先生？回到队伍中？好的，我马上回去！%SPEECH_OFF%你舔舔嘴唇，回头看见那个男孩正弯腰站在铁砧前，帮助回来的铁匠卸下皮革。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "太秀了！真棒！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Juggler.getImagePath());
				_event.m.Juggler.improveMood(1.0, "Basked in the admiration of a crowd");

				if (_event.m.Juggler.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Juggler.getMoodState()],
						text = _event.m.Juggler.getName() + this.Const.MoodStateEvent[_event.m.Juggler.getMoodState()]
					});
				}

				local money = this.Math.rand(10, 100);
				this.World.Assets.addMoney(money);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "Apprentice",
			Text = "[img]gfx/ui/events/event_97.png[/img]{%apprentice% 年轻的学徒前往铁匠铺帮助孩子。但他所做的不仅仅是帮助：他以一种比开始时更有效的方式将剑拼装在了一起。铁匠回来后，乞求学徒把这种工艺传授给他。 %apprentice% 哈哈哈.%SPEECH_ON%你给我这把剑，我告诉你这个秘密。%SPEECH_OFF%你甚至都不知道学徒还有这一手，年轻的学徒与铁匠进行了交易，双方皆大欢喜！.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我以为你只会编篮子。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Apprentice.getImagePath());
				_event.m.Apprentice.improveMood(1.0, "Brought his blacksmithing skills to bear");

				if (_event.m.Apprentice.getMoodState() > this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Apprentice.getMoodState()],
						text = _event.m.Apprentice.getName() + this.Const.MoodStateEvent[_event.m.Apprentice.getMoodState()]
					});
				}

				local item = this.new("scripts/items/weapons/arming_sword");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得 " + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Killer",
			Text = "[img]gfx/ui/events/event_97.png[/img]{你要求%killer% 去帮助这个孩子。 这个男人带着微笑，孩子似乎感觉被冒犯了。他向后退了几步。%SPEECH_ON%不用了，先生，我觉得我很好。谢谢你！我想一个男人必须做一个男人必须做的事，对吧？%SPEECH_OFF%杀手依然保持着微笑，蹲下，用手摸了摸孩子的脸。%SPEECH_ON%对的，孩子，一个人该做他应该做的事儿。%SPEECH_OFF%杀手摸了摸小孩子的头发，小孩子跑开了，但是很快又回来了，并带着一把匕首%SPEECH_ON% 先生，我在这里，请拿走这个匕首并让那个家伙远离我。我不想与那个男人做生意，请接受它！%SPEECH_OFF%你觉得这个孩子从未在他的生活中讨价还价，或者这是他第一次感受到他的生命危险了。总之你了接受匕首。在众人离开铁匠铺之后，孩子松了一口气。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你是这个孩子的杀手。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Killer.getImagePath());
				local item = this.new("scripts/items/weapons/rondel_dagger");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了 " + _event.getArticle(item.getName()) + item.getName()
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

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates_other = [];
		local candidates_juggler = [];
		local candidates_apprentice = [];
		local candidates_killer = [];

		foreach( b in brothers )
		{
			if (b.getBackground().getID() == "background.juggler")
			{
				candidates_juggler.push(b);
			}
			else if (b.getBackground().getID() == "background.apprentice")
			{
				candidates_apprentice.push(b);
			}
			else if (b.getBackground().getID() == "background.killer_on_the_run")
			{
				candidates_killer.push(b);
			}
			else
			{
				candidates_other.push(b);
			}
		}

		if (candidates_other.len() == 0)
		{
			return;
		}

		this.m.Other = candidates_other[this.Math.rand(0, candidates_other.len() - 1)];

		if (candidates_juggler.len() != 0)
		{
			this.m.Juggler = candidates_juggler[this.Math.rand(0, candidates_juggler.len() - 1)];
		}

		if (candidates_apprentice.len() != 0)
		{
			this.m.Apprentice = candidates_apprentice[this.Math.rand(0, candidates_apprentice.len() - 1)];
		}

		if (candidates_killer.len() != 0)
		{
			this.m.Killer = candidates_killer[this.Math.rand(0, candidates_killer.len() - 1)];
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
			"other",
			this.m.Other.getName()
		]);
		_vars.push([
			"juggler",
			this.m.Juggler != null ? this.m.Juggler.getName() : ""
		]);
		_vars.push([
			"apprentice",
			this.m.Apprentice != null ? this.m.Apprentice.getNameOnly() : ""
		]);
		_vars.push([
			"killer",
			this.m.Killer != null ? this.m.Killer.getNameOnly() : ""
		]);
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.Juggler = null;
		this.m.Apprentice = null;
		this.m.Killer = null;
		this.m.Other = null;
		this.m.Town = null;
	}

});

