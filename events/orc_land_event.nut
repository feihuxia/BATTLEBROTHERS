this.orc_land_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.orc_land";
		this.m.Title = "路上…";
		this.m.Cooldown = 16.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_46.png[/img]{一个上端镶着奇异骷髅的石冢。也许是用来纪念伟大的兽人战士。无论它对绿皮怪物有何种意义，对你来说却很简单：你现在在他们的地盘上了。| 你发现一个木制图腾，上面有弯曲的刀痕。%randombrother%相信他们是夜空的轨迹，也许是其中某个星座。\n\n%randombrother2%啐了一口，并说这意味着你现在进入了兽人的地盘，你最好做足思想准备。| 你在草丛中找到骨头。弯曲的肋骨非常猥琐 - 绝对不是人类的，太大了。你想知道那是不是驴的，但是这巨大的，奇怪的人形头骨确认了你的怀疑：你进入了兽人领地。| 尖刺上插着人类的脑袋。他们的身体被穿刺在长矛上。他们的身体已被撕碎。只能从他们破碎身体上的衣物看出他们曾经是人类。\n\n%randombrother%走上前，点了点头。.%SPEECH_ON%我们现在真是遇到麻烦了。这是兽人的领地。%SPEECH_OFF% | 你看到一具无头尸体。那不见了。他的小鸡鸡也不见了。还有他的手脚。尸体上还插着标枪，看来有人用剩下的残肢当靶子练习。\n\n 靠近查看这武器，%randombrother%点了点头并转向你。.%SPEECH_ON%是兽人，先生。我们现在在他们的地盘，额，很明显我们不会善待越境者。%SPEECH_OFF% | 你发现一具残破的骷髅被大斧子钉在树上。这具骷髅架已经支离破碎。树干上刻着奇怪的图画。%SPEECH_ON%这是绿皮怪物的地盘。%SPEECH_OFF%%randombrother%边走边说。他摸着斧柄，斧子深深陷入树干。%SPEECH_ON%我觉得兽人领地看起来……%SPEECH_OFF% | 你发现小山旁边有一堆小石头，明显是故意放在这里的。查看了一下，你发现石头上雕刻着什么东西。每个图案貌似都是一个故事 - 巨大野兽四处徘徊，杀戮弱小的故事。%randombrother%看着图画大笑。%SPEECH_ON%那兽人挺好玩 - 怎么会有这种东西。我们就是图画里那些小人。%SPEECH_OFF% | 在小山丘上还有一张皮革制造的防水布。这个营地似乎被遗弃 - 地上有逃跑的脚印，还有奇怪的碎片。%randombrother%指着它。%SPEECH_ON%这里仍然有它们的气味。一种兽人的气味。%SPEECH_OFF%%randombrother2%啐了一口。%SPEECH_ON%你鼻子很灵啊，先生。%SPEECH_OFF%%randombrother%点头。%SPEECH_ON%这可不是瞎说。我们在兽人的领地。%SPEECH_OFF% | %randombrother% 走到一堆人类头骨前。他看着上面的伤痕 - 他们的身体已不在，砍头实在太残忍。他点了点头。%SPEECH_ON%兽人图画，兄弟们。仔细研究。%SPEECH_OFF%你也点点头并告诉大家小心前方的危险。| 有一种狂野且文明的感觉。你觉得似乎进入了别人的领地。一堆黏糊糊的死尸出现在你面前，看来你进入了兽人领地。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "保持警惕。",
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
		if (this.World.getPlayerRoster().getSize() < 2)
		{
			return;
		}

		local myTile = this.World.State.getPlayer().getTile();
		local settlements = this.World.EntityManager.getSettlements();

		foreach( s in settlements )
		{
			if (s.getTile().getDistanceTo(myTile) <= 10)
			{
				return;
			}
		}

		local orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getSettlements();
		local num = 0;

		foreach( s in orcs )
		{
			if (s.getTile().getDistanceTo(myTile) <= 8)
			{
				num = ++num;
			}
		}

		if (num == 0)
		{
			return;
		}

		this.m.Score = 20 * num;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

