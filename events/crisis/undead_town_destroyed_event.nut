this.undead_town_destroyed_event <- this.inherit("scripts/events/event", {
	m = {
		News = null
	},
	function create()
	{
		this.m.ID = "event.crisis.undead_town_destroyed";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 7.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_99.png[/img]{你遇到一头驴站在一辆载满烧焦尸体的车子旁边。一个人站在它旁边看着，衣衫褴褛。他看着你摇头。%SPEECH_ON%希望你们不要前往%city%。%SPEECH_OFF%不要告诉陌生人你要去的地方，你只需问他为什么。他第二次摇了摇头。%SPEECH_ON%那里有行尸走肉。疾病传遍了全城，那些死人又复活了。不久整个地方陷落了。据说现在这个城市由死灵法师管理，但谁知道呢。我肯定不会靠近的。%SPEECH_OFF%  |  有个苍白的老头坐在路中间。他听到你来了，但没有转身看你。相反，他只是说。%SPEECH_ON%视野中看到你了。你们全部。佣兵在路上纠正这个世界的弊病，虽然你们对此目的的了解可能不及皇家婴儿对其君主的地方的了解。但你们太晚了。%SPEECH_OFF%他的头转动。白色的眼睛从浓密的眉毛下面盯着。他的鼻子不见了，他的嘴唇笑着露出病态的黄色皱纹。%SPEECH_ON%%city% 失守了！死者流浪街头，由那些你叫做死灵法师的人控制着。%SPEECH_OFF%你小心的上前问他怎么知道这些的。苍白的男人举起一个圆形小玩意，仿佛上帝手里拖着池塘。图像在它的反射中扭曲，来来去去的，事件没有开始或结束。他笑了。%SPEECH_ON%谁能比城市毁灭的策划者更加了解城市的名誉？%SPEECH_OFF%突然，陌生人的肉粉碎，什么都不剩，他的新形态的黑色碎片展开成一团蝙蝠。你拔出你的剑，但是这生物逃走了，尖叫着飞向地平线。 |  两名男子在路旁被发现。一个站在画架前，一只手拿着画笔，另一只手是混合颜色的调色板。另一个人摆着姿势，手放在头上，表达着绝对的恐怖。画家看了你一眼。%SPEECH_ON%啊，佣兵。我想你是要前往城市，是吗？%SPEECH_OFF%你问他为什么会这么说。他紧张的放下画笔。你看到他的画里是一座黑化的城市，蓝色的瘴气从城墙后升起，苍白的月亮压抑地挂在头顶。一个画了一半的任务站在前景位置，映射了画家的外表。模特纹丝不动地回答你的问题。%SPEECH_ON%%city%被摧毁了。嗯，不是被摧毁，而是行尸走肉泛滥。据说苍白的男人统治着它。%SPEECH_OFF%你问他们这是否真的。画家挥挥手拿出他的作品。%SPEECH_ON%要不是我亲眼所见，这不就成了一个疯子的作品？拜托，在这可怕的记忆褪去之前，我必须回去工作。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这场战争我们失败了吗？",
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
	}

	function onUpdateScore()
	{
		if (!this.World.State.getPlayer().getTile().HasRoad)
		{
			return;
		}

		if (this.World.Statistics.hasNews("crisis_undead_town_destroyed"))
		{
			this.m.Score = 2000;
		}
	}

	function onPrepare()
	{
		this.m.News = this.World.Statistics.popNews("crisis_undead_town_destroyed");
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"city",
			this.m.News.get("City")
		]);
	}

	function onClear()
	{
		this.m.News = null;
	}

});

