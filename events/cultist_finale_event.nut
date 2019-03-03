this.cultist_finale_event <- this.inherit("scripts/events/event", {
	m = {
		Cultist = null,
		Sacrifice = null
	},
	function create()
	{
		this.m.ID = "event.cultist_finale";
		this.m.Title = "营地…";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_33.png[/img]%cultist%进入你的营帐，后面一阵强风，卷起了你的卷轴和其他便条。他走向前，手交叉在前，看着相当像祭祀。%SPEECH_ON%长官，我说了是墓地的事宜，那是由我负责的。%SPEECH_OFF%你询问他在讲什么东西。异教徒俯身仿佛言语的重量将其压下来。%SPEECH_ON%达库尔，长官。%SPEECH_OFF%啊，当然了，还有谁？你叫男人解释下他需要什么。男人回应道。%SPEECH_ON%不，不是我，达库尔。达库尔才是有需要的人——他笑血，需要献祭。%SPEECH_OFF%你告诉他如果这么重要战团可以在下个城镇停留然后弄些鸡、羊或是任何他需要的东西。%cultist%摇摇头。%SPEECH_ON%调皮动物的血？不，他需要一位战士的鲜血。一位真正的战士，而且他相信我能找到这样的人——我也找到了。%SPEECH_OFF%异教徒挺直身躯，营帐的烛光突然摇晃不安。%SPEECH_ON%达库尔要求%sacrifice%之血。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我同意或者不同意的话会怎样呢？",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cultist.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_33.png[/img]%cultist%走到闪烁的烛光前，用手挡着火焰直到火苗静止不动。你见过比这更活跃的焰尖。他盯着火苗说着。%SPEECH_ON%如果我们这样做，达库尔会很高兴的。如果不这样做，我们会知道代价的。连我也不知道会发生什么。%SPEECH_OFF%你告诉异教徒他这是让你杀了自己的部下。他得有更好的办法。听到这里，他走过来抓着你的肩膀。营帐被烧掉了，陷入巨大的黑暗之中。异教徒不见了。他的位置只剩下一件黑色斗篷，手臂在你的肩膀上，一块花岗岩作头，边缘破碎。似乎在这面具后面是其他东西，这徒劳让你看不到它真正的容颜。一阵从喉咙发出的声音，慢慢缩小到只有你听得见。%SPEECH_ON%我会给你死神，凡人，让你感受他的温暖，死神应该会拜访你的敌人。%sacrifice%不会丢失，他会永远跟随你，我向你保证这点。%SPEECH_OFF%一阵白色闪回，一阵风冲出，营帐卷曲向外，烛火倾斜成匪夷所思的角度却没有熄灭，你感到一阵严寒。%cultist%就这样消失了。你快速起身并摸了摸脸和皮肤，确保自己还安然无恙。不过那景象还在，它脉冲的痕迹留下了可怕的现实以至于你觉得应该认真考虑异教徒的提议。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "做该做的事情。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "根本不可能!",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cultist.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_33.png[/img]你非常确定 Davkul 会对你的不服从感到不愉快。但是%sacrifice% 从你那里得到了许可离开。擦干净你的脸之后，你走出帐篷和那个人说话。或许在他即将到达疯狂的边缘看不到自己行为的后果他听到他的声音会获得一些理智。\n\n 当你到他的帐篷那里，你注意了它已经被打开轻轻地在风里挥舞。你走了进去发现佣兵躺在床上，他的毯子被扔在他身上。你找了个位置坐下， 说了几句话， 深深的希望他会醒来。%SPEECH_ON%你态度很好， %sacrifice_short%， 好的不能再好了。一个真正的兄弟%companyname% 任何战士的队长都会引以为豪。\n\n嘿， 不要把我留在这里。我知道你是醒着的，你这个家伙。%SPEECH_OFF%你对毯子伸出手并且把它抽了回来。你跳了起来几乎把帐篷顶翻。在床上他不是一个%sacrifice%，而是一个躯体，在不知名的金属的铠甲下面，铆钉的牙齿，一捆一捆的肌肉，骨头的护肩，血肉的铠甲。%cultist% 站在打开的帐篷里面。%SPEECH_ON%Davkul 最为高兴而他的优雅带着一种 Death 的视角。%SPEECH_OFF%这... 这不是你所期盼的。你甚至不知道你在期盼什么，但是从来没有为此做准备想象过这种事情。做了就做了，而且希望 %sacrifice%灵魂会安息。似乎你绝对不会这个样子。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "希望众神不会在晚上观察我。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Sacrifice.getImagePath());
				local dead = _event.m.Sacrifice;
				local fallen = {
					Name = dead.getName(),
					Time = this.World.getTime().Days,
					TimeWithCompany = this.Math.max(1, dead.getDaysWithCompany()),
					Kills = dead.getLifetimeStats().Kills,
					Battles = dead.getLifetimeStats().Battles,
					KilledBy = "Sacrificed to Davkul"
				};
				this.World.Statistics.addFallen(fallen);
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.Sacrifice.getName() + " has died"
				});
				_event.m.Sacrifice.getItems().transferToStash(this.World.Assets.getStash());
				this.World.getPlayerRoster().remove(_event.m.Sacrifice);
				this.World.Assets.getStash().makeEmptySlots(1);
				local item = this.new("scripts/items/armor/legendary/armor_of_davkul");
				item.m.Description = "Davkul 可怕的一面，不是这个世界的一种股的力量，还有残余的" + _event.m.Sacrifice.getName() + " from whose body it has been fashioned. It shall never break, but instead keep regrowing its scarred skin on the spot.";
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你得到了" + item.getName()
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
					{
						bro.improveMood(2.0, "Appeased Davkul");

						if (bro.getMoodState() >= this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}
					else
					{
						bro.worsenMood(3.0, "Horrified by the death of " + _event.m.Sacrifice.getName());

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
			ID = "D",
			Text = "[img]gfx/ui/events/event_33.png[/img]尽管你刚刚见证了荣耀， 你决定 %sacrifice% 应该活下来。就在你站起来要告诉%cultist% 这件事情， 房间的一半蜡烛突然熄灭了。卷曲的烟雾上飘去， 一个扭曲的阴霾穿过，就一瞬间， 你发誓你看到一个僵硬而是愤怒的面孔转身并且消失了。你有一种感觉 %cultist% 已经知道你做了什么样的决定。你留在帐篷里重新把蜡烛点燃。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "在这条路上某个地方， 这个战团做了一个错误的决定。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Cultist.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
					{
						bro.worsenMood(2.0, "Was denied the chance to appease Davkul");

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

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 12)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local sacrifice_candidates = [];
		local cultist_candidates = [];
		local bestCultist;

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
			{
				cultist_candidates.push(bro);

				if ((bestCultist == null || bro.getLevel() > bestCultist.getLevel()) && bro.getBackground().getID() == "background.cultist")
				{
					bestCultist = bro;
				}
			}
			else if (bro.getLevel() >= 11)
			{
				sacrifice_candidates.push(bro);
			}
		}

		if (cultist_candidates.len() <= 5 || bestCultist == null || bestCultist.getLevel() < 11 || sacrifice_candidates.len() == 0)
		{
			return;
		}

		this.m.Cultist = bestCultist;
		this.m.Sacrifice = sacrifice_candidates[this.Math.rand(0, sacrifice_candidates.len() - 1)];
		this.m.Score = 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"cultist",
			this.m.Cultist.getName()
		]);
		_vars.push([
			"sacrifice",
			this.m.Sacrifice.getName()
		]);
		_vars.push([
			"sacrifice_short",
			this.m.Sacrifice.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Cultist = null;
		this.m.Sacrifice = null;
	}

});

