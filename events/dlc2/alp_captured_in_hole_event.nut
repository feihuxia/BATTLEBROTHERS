this.alp_captured_in_hole_event <- this.inherit("scripts/events/event", {
	m = {
		Beastslayer = null
	},
	function create()
	{
		this.m.ID = "event.alp_captured_in_hole";
		this.m.Title = "Along the road...";
		this.m.Cooldown = 170.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_51.png[/img]{你发现一个人坐在地上一个洞的旁边。 在他旁边有一根金属桩，上面连着一条通到洞里的链子。洞上盖着山羊皮。他挥手向你致意，说如果想看，就得付钱。你问他里面有什么。他咧嘴一笑。%SPEECH_ON%最肮脏黑暗的东西，先生。%SPEECH_OFF%一些全副武装的人站在一边，毫无疑问，这是他们计划的一部分。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧，我付点钱去看看。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "我们没事。",
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
			Text = "[img]gfx/ui/events/event_51.png[/img]{你给那个男人抛了几个硬币。他用牙咬了咬，你告诉他注意点，有些硬币上有血。 他耸了耸肩，把硬币装进了口袋。你走到洞口，那个人把防水布扔了下去。 一只面目狰狞的alp抬头嘶嘶叫的盯着你，它满嘴利牙，脸如白肉织成的帘子。它的脖子上戴着镣铐，那个人在洞口吹着口哨，仿佛这是他第一次在那里看到它。%SPEECH_ON%可怕的小家伙，不是吗？别离他太近，否则你会看见一些东西。当然，除非你想这么做。总有人会这样。 但是，如果你看到一些东西，并且乐在其中，那么你就得多付一点钱！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你应该杀了它。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "好吧，祝你好运。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local money = -10;
				this.World.Assets.addMoney(-10);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你失去了 [color=" + this.Const.UI.Color.NegativeEventValue + "]" + money + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_51.png[/img]{这种可怕的生物不会以这种方式活下来。你告诉他，这个怪物可能会在某个时候逃出牢笼，对世界大肆破坏, 而且可能会是更加原始暴力的复仇。那个男人啐了一口唾沫。%SPEECH_ON%滚你妈的。给我出去，你的钱拿不回来了。如果你走错一步，我将保护我和我的投资。你不知道这个怪物是哪个婊子抓的，对吗？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我要亲手杀了它。",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "好吧，让它活下去。",
					function getResult( _event )
					{
						return "E";
					}

				}
			],
			function start( _event )
			{
				if (_event.m.Beastslayer != null)
				{
					this.Options.push({
						Text = "%beastslayer%, 你是这方面的专家。 你怎么说？",
						function getResult( _event )
						{
							return "F";
						}

					});
				}
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_60.png[/img]{你从一个守卫手中夺过一支矛，把它扔向坑里，刺穿了alp的脑壳。 它苍白的肉围绕着矛杆收缩，好像你刚刚击落了一个巨大的幕布。怪物奴役者抽出一把匕首刺向你。 %randombrother% 躲过一击，割断了他的喉咙。 一些卫兵冲进战场，他们很快都死了，虽然也有一些雇佣兵在战斗中受伤。一些卫兵冲进战场, 他们都死得又快又急, 虽然也有一些雇佣兵在战斗中受伤。冲突结束后，你收集了怪物奴役者身上的所有黄金。你把尸体和死去的alp一起倒进洞里，然后把洞填满。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让我们回到路上吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local money = this.Math.rand(25, 100);
				this.World.Assets.addMoney(money);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] Crowns"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (this.Math.rand(1, 100) <= 33)
					{
						bro.addLightInjury();
						this.List.push({
							id = 10,
							icon = "ui/icons/days_wounded.png",
							text = bro.getName() + " 受了轻伤 "
						});
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_51.png[/img]{你不会和这些人吵架的。 你所见过的一些最好战士都是在毫无意义的酒吧斗殴中被打死的。如果这些白痴想留住怪物，那就随他们去吧。但队伍里的一些雇佣兵对alp的存活并不高兴，尤其是当这个生物凝视着他们时，它盯着他们中的许多人，它似乎点了点头，好像以后还会看到他们似的。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "让我们回到路上吧。",
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
					if (bro.getBackground().getID() == "background.beast_hunter" || bro.getBackground().getID() == "background.witchhunter" || bro.getSkills().hasSkill("trait.hate_beasts") || bro.getSkills().hasSkill("trait.fear_beasts") || bro.getSkills().hasSkill("trait.bloodthirsty") || bro.getSkills().hasSkill("trait.paranoid") || bro.getSkills().hasSkill("trait.superstitious"))
					{
						bro.worsenMood(0.75, "You let some alp live which may haunt the company later");

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
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_122.png[/img]{%beastslayer% 怪物猎人走到洞口，盯着里面看。他点了点头。%SPEECH_ON%你没有抓住它，alp不可能被抓住。%SPEECH_OFF%T怪物奴役者看了看，问他为什么。猎人笑了%SPEECH_ON%因为它不是凡物。这只alp在等待时机。 你说它会让人们做噩梦？ 没错，恐惧就是它的利刃。它在磨尖这把利刃，它在不断练习。Alps利用环境来安置它的受害者，目前只能将就着用泥土。但最终你会发现，它会等待，为那一刻做好准备，而你会发现自己与它一同陷入困境。 陷入困境的不是你的身体，而是你的思想，你的灵魂。它会把你心灵带到洞里。它会在那里。 你和那个怪物独自在那个黑暗世界中。 要多久？ 几天，几周。一种非常危险的alp甚至可以禁锢你的思想高达数年。如果到那时你还能说话的话，那么你出来的时候就会像个傻瓜一样，遍体鳞伤，流口水，乞求死亡。%SPEECH_OFF%猎人从其中一个奴役者的守卫那里鞠了一躬。他扣上箭。alp抬起头，张开嘴，露出一排排剃刀般锋利的牙齿。 猎人直接射中了它的胃，立刻杀死了它。 他把弓递回去，展开他的工单。%SPEECH_ON%这是我应得的报酬。 特别的，从一个alp那永远的拯救你的灵魂和思想。所以我还会收取一些alp的皮。成交？%SPEECH_OFF%怪物奴役者点头如捣蒜。%SPEECH_ON%是的先生，是的先生，你当然可以拿走！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你将和队伍平分这笔钱。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Beastslayer.getImagePath());
				local money = 25;
				this.World.Assets.addMoney(money);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] Crowns"
				});
				local item = this.new("scripts/items/misc/parched_skin_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + item.getName()
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

		if (this.World.getTime().Days < 30)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad || currentTile.Type == this.Const.World.TerrainType.Snow)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates_beastslayer = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.beast_hunter")
			{
				candidates_beastslayer.push(bro);
			}
		}

		if (candidates_beastslayer.len() != 0)
		{
			this.m.Beastslayer = candidates_beastslayer[this.Math.rand(0, candidates_beastslayer.len() - 1)];
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
			this.m.Beastslayer ? this.m.Beastslayer.getNameOnly() : ""
		]);
	}

	function onClear()
	{
		this.m.Beastslayer = null;
	}

});

