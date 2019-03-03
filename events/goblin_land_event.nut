this.goblin_land_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.goblin_land";
		this.m.Title = "路上…";
		this.m.Cooldown = 16.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_46.png[/img]{你找到一个死去的哥布林。但是这不是普通的哥布林 - 是一个长老。他/她好像是老死的。身上还有一些仪式用的小东西。这里的这个哥布林不是偶然出现在这里的，他死去后有一个不错的葬礼。这说明只有一种可能：你进入了受诅咒的绿皮怪物的领地。| 你在一个山坡上遇到了一条死狗。它的舌头伸了出来，眼睛几乎要从头骨里蹦出来。身上插着许多飞镖。%randombrother%拔出来一个然后看着金属部分。%SPEECH_ON%哥布林毒素。%SPEECH_OFF%你询问为什么要对狗用。他耸耸肩。%SPEECH_ON%我猜应该是受到惊吓的狗很适合用来做瞄准练习。%SPEECH_OFF%| 一个由奇怪的褪色的花朵、种子以及树枝组成的花环。中间是一群大甲虫紧紧地挤在一起。他们好像在贪婪地吸食这些植物中的浆汁或者其他的古怪东西。%randombrother%大声的询问。%SPEECH_ON%我以前见过这些东西。这好像是某种标记。%SPEECH_OFF%你瞥向他。%SPEECH_ON%我们应该留意古怪的老女人什么的吗？%SPEECH_OFF%他摇摇头。%SPEECH_ON%不用。这是哥布林做的。我们现在在他们的地盘上。%SPEECH_OFF%| 在这片土地上行进时，你遇到一个死去的兽人。他看起来几乎没有受伤，就好像睡着了一样。但是你靠近细看了之后，你发现他侧面有十来个小飞镖。你马上仔细观察了四周，然后转向你的手下。%SPEECH_ON%小心，伙计们，我们现在是在哥布林的领地了。%SPEECH_OFF%| 你发现一些石头被排列成圆形。中间是一个被开了瓢的人类头骨。头骨里面是一些像是骰子和鸡骨头的东西。这种萨满的东西出现在这里可不是意外 - 你到哥布林领地了。| 你遇到了一头被可怕的陷阱杀死的鹿。那符合所有普通陷阱的特点 - 打算用尖刺杀死猎物 - 如果不是发现了上面涂抹的毒素的话。那种毒素是一个种族独有的：哥布林。从现在开始最好小心一点。| 一个隐燃的火堆。周围排列着木棍和石头。一个立式武器架上面摆放着吹箭筒。弯刀。还有一个脖子上拴着绳子的死狼崽。观察了这个证据之后，你迅速将当前的情况通知给手下的人。%SPEECH_ON%这里是哥布林的领地了，伙计们，根据这些东西可以看出，他们离我们还不远。%SPEECH_OFF% |  一群死狼崽的尸体。肚子被刨开的母狼就在它们旁边，脖子上戴着一个项圈。现场有一条血迹朝向外面，草中还有一些小脚印。%SPEECH_ON%哥布林的坐骑变多了。%SPEECH_OFF%%randombrother%站在你旁边。他指向狼崽。%SPEECH_ON%他们说哥布林就喜欢野崽。他们寻找刚下崽的窝，只拿走最强壮的。%SPEECH_OFF%你关注的只有你们现在处在哥布林的领地了。你建议手下留意四周，以免那些狡猾的家伙们偷袭你们。}",
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
		local myTile = this.World.State.getPlayer().getTile();
		local settlements = this.World.EntityManager.getSettlements();

		foreach( s in settlements )
		{
			if (s.getTile().getDistanceTo(myTile) <= 10)
			{
				return;
			}
		}

		local goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getSettlements();
		local num = 0;

		foreach( s in goblins )
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

