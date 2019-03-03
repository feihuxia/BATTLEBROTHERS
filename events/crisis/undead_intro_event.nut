this.undead_intro_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.crisis.undead_intro";
		this.m.Title = "营地…";
		this.m.Cooldown = 1.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_84.png[/img] 你低头睡去。\n\n 你翻身的时候，丝滑的床单滑下你的身体。小鸟飞过圆滑的象牙制窗口。一个声音进入你的耳朵，你从未闻到过的一股香味出现。%SPEECH_ON%你醒了。%SPEECH_OFF%一个女人转过来，用手指划过你的胸膛，然后抓住你下巴。柔软，漂亮，阳光照耀在她光滑的脸上，点亮了淡绿色眼睛。她开始亲吻。你快速地滑下床，狂乱地看着四周。她抓住床单，跪起来，一脸困惑。你要去哪，我的皇帝？%SPEECH_OFF%你抬头看，看到高高的天花板上精美镶边的艺术作品。你打开一扇门，走到阳台上。高高的建筑，红色、白色、金色的旗帜，地平线上黑色的尖塔形状，一直延伸到眼睛看不到的地方。圆顶、喷泉、大拱门、雕像，高高耸立，他们似乎把建筑当做士兵一样指挥。每个屋顶上都是花园，比你见过的任何天然不朽喷泉都要更大更美。突然，两名男子带着鸽子笼出现在你的两侧，放飞鸽子。鸟儿四处飞散，就在这时，你下面爆发一阵吼叫。很多人跳着挥舞着旗帜。%SPEECH_ON%他们热爱他们的皇帝。%SPEECH_OFF%女人在门口说道。%SPEECH_ON%去找他们。%SPEECH_OFF%你往下看到一队士兵走进道路中间，每个人都迈着整齐的步伐，稳定的靴子拍打节奏。他们的脸在镀金的头盔里显得严肃，长柄武器闪闪发光，仿佛他们想用它的富贵打败敌人。%SPEECH_ON%他们将要走向战争。去面对彼端，去打败它。%SPEECH_OFF%这女人在你身边。她热情地笑着，拉着你的手臂。你准备好了同意这新的现实，不管它是怎样的。你摸着她的脸颊，准备投入她的怀抱，但下面的一声响亮而清晰的哀嚎结束了这一切。你往下看这些士兵，曾经是完美统一，现在一片混乱。远处，一座大山喷发出红色的火焰，巨大的火山灰云迅速涌入到城市。建筑瓦解，花园起火，人们……人们尖叫。他们转身逃跑，但是逃不掉这股热。士兵崩溃、尖叫。涌动的灼热，你很快看到人们在其中熔化，士兵变成金属傀儡，烧焦原本该保护他们的盔甲，没有护甲的人群只是突然燃烧。女人在你身边哭泣。%SPEECH_ON%太可怕了！真可怕！你要看看吗？不过没事的，明白吗？没事的。看着我。看着我！%SPEECH_OFF%女人抓住你旋转。她曾经柔软的五官已经硬化成了黑片，她的头顶部分已经烧光了，她的牙齿掉落牙龈。但她还在微笑。%SPEECH_ON%我们会再次崛起，皇帝！我们……会再次……崛起！%SPEECH_OFF%她的头骨碎裂，她的身体变成一堆燃烧的骨头。\n\n 你猛然惊醒发现%randombrother%在摇晃你。%SPEECH_ON%长官，醒醒！有一群难民说死人从土里爬起来，大肆杀戮！%SPEECH_OFF%女人的脸在你眼中闪烁。她伤痕累累，但是并不能阻止她笑。%SPEECH_ON%帝国崛起。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "战争来了。",
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
		if (this.World.getTime().IsDaytime)
		{
			return;
		}

		if (this.World.Statistics.hasNews("crisis_undead_start"))
		{
			this.m.Score = 6000;
		}
	}

	function onPrepare()
	{
		this.World.Statistics.popNews("crisis_undead_start");
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

