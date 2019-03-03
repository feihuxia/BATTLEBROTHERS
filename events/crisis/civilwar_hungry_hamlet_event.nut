this.civilwar_hungry_hamlet_event <- this.inherit("scripts/events/event", {
	m = {
		NobleHouse = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_hungry_hamlet";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_79.png[/img]{你在路上发现了一个小村庄，所有村民都站在外面。他们的首领走过来，伸出手，似乎花了很大的力气才把双手合起来，他恳求道，%SPEECH_ON%求你了，帮帮我们好吗？我们已经一个礼拜没吃东西了。只能吃土啊！您一定要理解，我们什么都没有了！战争把我们摧残成什么样了。%SPEECH_OFF%  | 你发现一个小村庄，小到一眼就看完了，所有村民都站在外面，似乎在等你。首领上前一步，%SPEECH_ON%雇佣兵，我知道不该问，可你们有多余的食物吗？战争破坏了我们的作物，那些战士们把我们剩下的东西都拿走了！求你了，帮帮我们吧！%SPEECH_OFF%  | 你在道路旁发现了一个小村庄，村民们都站在外面，全部低着头，看起来十分虚弱。小孩子们尤其脆弱，但眼睛里仍然闪烁着光芒。村长走过来，%SPEECH_ON%先生……佣兵？嗯，佣兵。求你了，我们已经一个礼拜没吃东西了。只能吃宠物，昆虫……甚至泥土。能帮帮我们吗？%SPEECH_OFF%  | 你们沿着道路前进，看到附近一个小村庄的村民走过来。他们步履蹒跚，腿脚似乎有些站不稳，东倒西歪。村长举起双手，然后又放下，似乎对你的出现非常高兴。%SPEECH_ON%哦，佣兵，你们有吃的吗？拜托了。我们已经两天没吃东西了！我们吃的那些东西简直不能说！贵族之间的战争破坏了我们的村庄，你能帮帮我们吗？%SPEECH_OFF%}",
			Characters = [],
			Options = [
				{
					Text = "好吧，给那些可怜的家伙一些食物。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(3);
						local r = this.Math.rand(1, 3);

						if (r == 1)
						{
							return "B";
						}
						else if (r == 2)
						{
							return "C";
						}
						else if (r == 3)
						{
							return "D";
						}
					}

				},
				{
					Text = "自己想办法吧，农民。",
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
			Text = "[img]gfx/ui/events/event_79.png[/img]{出于典型的雇佣兵判断，你被选出来给那些村民食物。告诉%randombrother%尽量把手上的东西分配出去，不过很明显，东西并不多。大家非常感激，围绕在佣兵身边，似乎他要说一个巨大的事实一样。村长表示他会传播你的善行。你不是很确定，利他主义是否对雇佣兵有好处…… | 令村民们感到震惊的是，你命令%randombrother%给他们分一些食物。不是很多，刚好够他们吃。不过不要把好东西分出去！\n\n 村长走到你身边，用颤抖的双手拍了拍你的肩膀，%SPEECH_ON%你绝对不知道这对我们有多重要！所有人都应该听听你们的善行……%SPEECH_OFF%他看了你们的旗帜一眼，你点点头。%SPEECH_ON%%companyname%。%SPEECH_OFF%他笑了起来，%SPEECH_ON%当然！大家都应该听听%companyname%的善行！%SPEECH_OFF%}",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "希望他们以后会更好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				_event.distributeFood(this.List);
				this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
				this.List.insert(0, {
					id = 10,
					icon = "ui/icons/special.png",
					text = "战团获得声望"
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_79.png[/img]{你的善良得到了回报：你命令%randombrother%分发食物。他照办了，不过分配食物的时候，村民们非常激动，不停地互相争抢。因为肚子饿，脾气也变得火爆起来。雇佣兵想维持秩序，可不管他说什么，饥饿的人群都觉得全是他的错。暴力迅速扩展，讽刺的是，所有食物都掉到地上了。你们不得不拔剑维持秩序，结果死了几个农民，剩下的人用自相残杀的眼神看着尸体。\n\n趁情况没有变得更糟糕之前，你赶紧命令%companyname%继续前进。 | 因为一些原因，可能是晚上睡得太晚了，你命令%randombrother%给大家分配食物。他刚还没开始，一个村民迅速上来抢走了一袋食物。另一位村民抓着那个人的脑袋就往地上撞，然后抢走了他的食物。场面突然变得混乱起来，雇佣兵不得不拿出武器保护剩下的食物。最后几个村民躺在地上死了，你们也受到了一些损伤。已经没理由继续待在这儿了，你命令战团继续前进。请求你帮忙的村长在不远处，盯着地平线，任由寒风拍打着自己单薄的身体。}",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "失控得也太快了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				_event.distributeFood(this.List);
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_79.png[/img]好吧。这是个可怕的世界，如果你可以凭借自己的力量减少恐惧，为什么不去试试呢？你命令%randombrother%分配食物，不过不要给太多，并且不要把你喜欢的东西分出去。他刚准备分配食物，一群拿着%noblehouse%旗帜的战士出现了。他们穿过饥饿的人群，拿走食物，有人抵抗的话就拿出剑阻止。他们的首领开口说话了，%SPEECH_ON%%noblehouse%的军队需要这些食物。不许反抗。%SPEECH_OFF%你向他解释说，这些其实是你们的食物，只是分给他们而已。%SPEECH_ON%既然是你的食物，那为什么在他们手中？赶紧带着你们的东西走开！别耍花招，佣兵，不然只能采取暴力了。%SPEECH_OFF%%randombrother%盯着你，似乎在问，我们该怎么办？",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "这是我们的食物，因此由我们决定！",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "E";
						}
						else
						{
							return "F";
						}
					}

				},
				{
					Text = "这是我们的食物，但战斗对我们不利。",
					function getResult( _event )
					{
						return "G";
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.distributeFood(this.List);
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_79.png[/img]中尉转过身去，指导他们的人盗窃食物。你拔出剑，有些步履蹒跚，虽然身体仍感觉疼痛，但偷偷靠近一个人还是没问题的。你迅速用剑指着他的脖子，对其他人大声叫道，%SPEECH_ON%你们真的想使用暴力吗？%SPEECH_OFF%中尉举着双手开口说道，%SPEECH_ON%等等，等等，我们，呃，似乎误会了。弄错村庄了，伙计们。%SPEECH_OFF%你用剑在他脖子上划了一道口子，然后放了他。农民们非常开心，食物又回到了他们手里。毫无疑问，贵族很快就会听说你在这儿的善行，普通人也一样。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "有时候犯蠢的感觉还不错。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "You threatened some of their men");
				this.World.Assets.addMoralReputation(3);
				this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess * 2);
				this.List.insert(0, {
					id = 10,
					icon = "ui/icons/special.png",
					text = "战团获得声望"
				});
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_79.png[/img]你抓住中尉的肩膀，把他拉过来。他抓住你的手，把你扔出去，同时想拔剑。你跳过去，阻止了他的行为，迅速拿出一把匕首对着他的脖子。他的战士们想穿过人群，不过你的雇佣兵把他们打倒在地，农民们利用饥饿的野蛮之力，终结了他们。中尉慢慢倒下去。你盯着他的眼睛，%SPEECH_ON%没错，暴力。%SPEECH_OFF%农民们欢呼起来，你让他们把尸体埋了，或者不要留在这里也行。毫无疑问，很快就会有军队过来。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "我们该走了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationOffense, "You killed some of their men");
				this.World.Assets.addMoralReputation(1);
				this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess * 2);
				this.List.insert(0, {
					id = 10,
					icon = "ui/icons/special.png",
					text = "战团获得声望"
				});
				local brothers = this.World.getPlayerRoster().getAll();
				local bro = brothers[this.Math.rand(0, brothers.len() - 1)];
				local injury = bro.addInjury(this.Const.Injury.Accident1);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = bro.getName() + " suffers " + injury.getNameOnly()
				});
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_79.png[/img]你通知大家离开。食物又被抢走，村民们大声哀嚎起来。他们的哭声非常可怕，甚至有些人开始诅咒你，他们宁愿你从没出现，也不愿意受这种折磨。 | 给他们食物是一回事，可是和士兵争论又是另一回事了。你告诉战士们不会有战斗发生，他们尽管继续。村民们大声哭喊着，祈求你阻止他们。有些人太虚弱了，一句话都说不出来，这种突然事件带来的打击，比忍受几个礼拜的饥饿都要严重。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "抱歉……",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.World.Assets.addBusinessReputation(-this.Const.World.Assets.ReputationOnContractSuccess);
				this.List.insert(0, {
					id = 10,
					icon = "ui/icons/special.png",
					text = "战团损失声望"
				});
			}

		});
	}

	function distributeFood( _list )
	{
		local food = this.World.Assets.getFoodItems();

		for( local i = 0; i < 2; i = ++i )
		{
			local idx = this.Math.rand(0, food.len() - 1);
			local item = food[idx];
			_list.push({
				id = 10,
				icon = "ui/items/" + item.getIcon(),
				text = "你输了" + item.getName()
			});
			this.World.Assets.getStash().remove(item);
			food.remove(idx);
		}

		this.World.Assets.updateFood();
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

		local food = this.World.Assets.getFoodItems();

		if (food.len() < 3)
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();
		local towns = this.World.EntityManager.getSettlements();
		local bestDistance = 9000;
		local bestTown;

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d <= bestDistance)
			{
				bestDistance = d;
				bestTown = t;
				break;
			}
		}

		if (bestTown == null)
		{
			return;
		}

		this.m.NobleHouse = bestTown.getOwner();
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

