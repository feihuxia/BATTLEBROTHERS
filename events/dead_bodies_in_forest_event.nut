this.dead_bodies_in_forest_event <- this.inherit("scripts/events/event", {
	m = {
		Hunter = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.dead_bodies_in_forest";
		this.m.Title = "路上…";
		this.m.Cooldown = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_02.png[/img] {朝着森林前进的时候，%randombrother%召唤战团。你看着他指着远处的小树丛。你走到他身边的时候，看到树上吊着三具尸体。他们的脸变成了紫色，腿一直摇晃，因为刮风的缘故，他们都面对着面。%randombrother%发现他们身上都挂着木牌：上面写着他们的罪行。‘小偷’，其中一个写着。另一个写着‘淫妇’。最后一个写着‘叛徒’。看够之后，你让他们继续前进。| 森林一点都不轻松，没有小路，也没有近路。到处都是浓密的树木，而且似乎一点都不欢迎你。你很快发现，森林也不欢迎其他人，你在荆棘从里发现了一具尸体，他的双腿和手臂弯曲，原来的意图已经不知道了。他的嘴巴张的很大，眼里的神情似乎受到了挫折。%randombrother%追上你，看着尸体，然后点点头。%SPEECH_ON%除了荆棘造成的痕迹之外，尸体很干净。我敢说，连动物都找不着那个家伙。就是死了而已，没什么用处。%SPEECH_OFF%你指着死人牙齿上的一只蚂蚁说道。他笑着摇了摇头。%SPEECH_ON%你确定他没有迷路？%SPEECH_OFF% | 你抬头看着森林上方，想看光线从哪儿射进来的。你弄清方位的时候，%randombrother%心烦意乱地走过来。%SPEECH_ON%长官，你最好过来看看这个。%SPEECH_OFF%你点点头让他带路。他带你来到一片还算比较干净的地方。\n\n腿。到处都是腿。有的从脚踝被割断，有的是大腿，还有各种其他地方。毫无规则。散乱的分布，有的单独在一个地方，有的扎成一堆，有的被用棍子立起来，就好像是正在行走的笑话一样，有少数甚至被扔到树上，倒挂在树枝上。有一个挂在树杈上，小腿被烧成黑色，好像是某人逃跑了一样，把它留在一堆已经熄灭已久的火上。\n\n发现这个恶心的场面的兄弟站在你旁边。%SPEECH_ON%没有尸体，长官。只有……腿。%SPEECH_OFF%你转身看向雇佣兵，但是他只能耸耸肩。%SPEECH_ON%我们一具尸体也没发现，长官。我是说，没有上半身。你觉得这有什么意味吗？我是说，谁会做出那种事？砍掉别人的腿然后带着其他部分离开？%SPEECH_OFF%你难以置信地摇摇头。你看够了，也无法找到答案之后，便迅速带领着剩下的人离开，继续行进。| 你在一个溪床处停下来，想要洗一下顺便喝点东西，但是你还没开始喝，%randombrother%抓住了你的肩膀。他指着上游。一个女人的尸体脸朝下漂在水上，她长长的头发顺着水波上下摆动。你对佣兵让你免受尸体所带来的病菌的侵害而表示感谢。| 树冠扭曲而厚重。上面的光线难以穿透，一道道光束在你的人行进过程中围绕着他们。但是你在前方看见一道光照向森林。自然地，有人先看到了。而那就是他们生前看到的最后一样东西了。\n\n在光束下，一个男孩背靠着一棵树休息。他的头懒洋洋地靠着，双手向上张开。手掌上有紫色的污渍。%randombrother%走上前去然后立即摇了摇头。%SPEECH_ON%毒浆果。这孩子一点机会也没有。%SPEECH_OFF%你转向战斗伙伴询问这个男孩死的是否平静。他又摇了摇头。%SPEECH_ON%不。%SPEECH_OFF% |一具尸体。更确切地说是，本应该是一具尸体。胸腔被打开，内脏到处都是，已经发灰变软，开始下垂。看不出是个男人还是女人，只知道是一个被缩小了的成人。你想不出什么样的生物会做出这种事，不过%randombrother%建议说可能是一个非常有决心的人所为。| 你看到一具女尸背靠着一棵树休息。她的胸口插着一把刀，伤口非常致命，她很快就死掉了。在她前面，另一个女人挂在一个树枝上。她身穿红衣。尸体的头向前倾着，好像是想要盯着她的罪行，她身上的绳子在风中发出呻吟一般的响声。| 你看到一些战斗的场面。人员，盔甲，武器，没有一个可以用。死者因为某种你根本不想了解的极端的残忍手段变成那样。地上的脚印表明有很大的东西从这里通过，留下了这片废墟和灾难，你完全不想跟着这些脚印前进。| 继续行进，你看到一个悲伤插着断箭的男尸。还有很多刺伤，应该是杀手得以完整取回了弹药。男人身上有一封情书，他的收信人是一个女人，很显然，在前面已经死了。啊，浪漫。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "安息吧。",
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
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest)
		{
			return;
		}

		local myTile = this.World.State.getPlayer().getTile();

		foreach( s in this.World.EntityManager.getSettlements() )
		{
			if (s.getTile().getDistanceTo(myTile) <= 6)
			{
				return;
			}
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
	}

});

