this.dead_bodies_on_road_event <- this.inherit("scripts/events/event", {
	m = {
		Hunter = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.dead_bodies_on_road";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_02.png[/img] {A wagon, tipped over.旁边是一匹马的尸体。一个反抗过的驴的尸体。女人。儿童。一些老人。大部分残破的对任何人来说都没什么用了，但是你感觉你的战团应该是偶遇这样的废墟的最佳人选。你忍受的住，因为你创造过更糟糕的废墟。不过，真正让人恶心的是那些无辜的死者，为了纠正那道德上的疾病，你决定把死者埋葬以尽绵薄之力。可惜的是，他们的尸体上没有找到任何有价值的东西。| 路边的排水沟里流满了鲜血。路上一片血红。路边另一侧的排水沟里也流满了鲜血。马车的帆布上也被染成了红色。死者的眼睛和嘴巴里都是血。一个可怜的农夫，死了，看起来像是被一群贼为了抢夺他身上毫无价值的东西而杀死的。| 天上的鸟是最先的预兆：在远处的灾难上空不断盘旋。你认为不管它们看到的是什么，肯定还活着，但是当你赶过去的时候，鸟群已经落下，你看到一具靠在一个侧壁柱上的男士。\n\n你试着把鸟群吓跑。黑秃鹰仅仅向相反的方向跳了几步，然后转身盯着你。尸体还很新鲜，死去的过程是缓慢的：几支箭射入他的侧身。腰间的一根绳子表明他原本有一个钱包。有人打劫了他 - 两次。| 你碰到几个被挂起来的罪犯。他们在路边的一棵树上晃荡，头上套着羊毛袋，只能看到一点脸的轮廓。他们中的一些人身上有被折磨的痕迹：这里那里的伤口，紫色的淤青，有些还已经变成灰色。一具尸体脚下还有血迹，说明有人在他窒息而亡的同时还攻击了他。很自然，他们身上也没有什么有价值的东西，所以你又开始赶路了。| 一只带有铃铛的羊，被一个死去的牧羊人抱着。你在路边上发现了他们。动物的喉咙被割开，而且男人的尸体上没有伤口。也许是因为心碎而死。%randombrother%翻了翻死者的口袋，什么也没找到。你决定不管他们。| 两只秃鹰在争夺一根肠子，一点点吃下去，直到它们的鸟嘴碰到一起。要不是你知道这肠子是从哪来的，你可能就会觉得有趣了：那是一个死去的孩子的，他或者是她面朝下躺在地上。后背已经被撕开了，血红的胸腔在太阳下闪闪发光。\n\n你轰走了鸟 - 尽管它们很不情愿被吓到 - 然后埋葬了尸体。回到路上，你看到两只鸟在坟墓上坐着，戳着坟墓上的土{好像是在焦虑一样 | 仿佛是要反过来重现它们所看见的东西}。最终它们还是放弃了，然后飞走了，在你的队伍上方盘旋了一两英里然后往别处飞了。| 火焰噼啪作响，烧光了马车最后的部分。%randombrother%在熏黑的残骸中搜寻了一番，但是什么也没找到。几只一般黑的手从尘土和烟灰中伸了出来。尸体完全不见了踪迹，或者是被埋了，或者是被烧光了，又或者是被埋在被烧光了的东西下面了。你看到没什么可以打捞的，便迅速让队伍继续赶路了。| 一匹死马。骑手在路的对面，爬到了他最后安息的地方。路上到处都是被折断了的箭尾，箭头都被折下来回收了。男人的头皮不见了，他的头顶闪烁着红色。在迅速的搜寻之后，你发现这里什么也没有，然后决定继续前进。| 你在路边碰到一堆裸体的尸体。有些看起来已经是惨白的，好像已经死了很久了，但是其中一些的嘴中却有较为新鲜的血液。少许的尸体皮肤还有颜色，但是身上有一些像是咬痕的东西。看来他们是被先发制人了，每个人脖子都被猛斩了。像他们这样裸着，你自然是什么有用的东西也没找到。你继续前进。| 你感觉好像是被人盯上了，所以停了下来，迅速转身面对路边，手拿着剑。一个脑袋越过草地盯着你。%randombrother%走过去把它拾起来。面容十分呆滞，看来死的时候很震惊。你让佣兵把那脑袋放下，你还有更重要的事情要做。}",
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

		if (!currentTile.HasRoad)
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

