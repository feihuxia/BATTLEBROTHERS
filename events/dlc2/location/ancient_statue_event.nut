this.ancient_statue_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.location.ancient_statue";
		this.m.Title = "随着你的接近...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_116.png[/img]{足有一座城堡那么大的男性雕像端坐在他那石质的王座上。即使身为一个了无生气的雕塑，他那帝王霸主般的雄姿依旧能深深刻印在每一名亲睹此景者的脑海之中。这尊雕像的绝景足以让这整片大陆更添光彩，金像巨人的威严仪表足以让你这辈子所接触过的所有权贵乡绅无地自容。整尊雕像被置于一座由巨大的岩石方砖螺旋叠起的圆台之上，如果把那些构成基座的石砖做成棺材，那么只要两块这样的石砖就能把整个 %companyname% 安排得明明白白。 %randombrother% 抬起头望向雕像。%SPEECH_ON%这是我这辈子见过最大的东西，没有之一。%SPEECH_OFF%%randombrother2% 傻笑起来，指向那名雇佣兵的裤裆。%SPEECH_ON%有的村姑还说你下面那根针是她们见过最大的东西呢！%SPEECH_OFF%整个战团的人大笑起来。你上前一步，抬头望去。你当然不会被一个雕像吓到跪下，但你依然能感觉到扑面而来的压力。这尊雕像以傲视群雄的神态俯瞰着整个世界，它的双手探出王座，一手拄着一把深深插入土地的巨剑，另一只手则随意搭上扶手，姿态如同要代天理权量公义。你对着眼前这金光灿烂的瑰宝微微点头。眼前这尊雕像上连一点窃贼留下的刮痕都没有，好像金像真的在用那种仿佛世界尽在掌握的王者之气震慑一切宵小之辈。但这样可不好。真正的聪明人应该本着共同富裕的原则帮助这雕像分享一些这金光所带来的压力。几个雇佣兵询问他们可不可以从这雕像身上刮点细软下来留待自用。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这雕像又不会吃人。",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_116.png[/img]{这座雕像实在太大了，也许它光靠迷信就能吓跑那些小毛贼。但你没理由放过这宝贝东西。把这么老大一块金子雕刻得这么 \'漂亮\' 。去他娘的历史和文化吧。你让手下的人自由发挥。他们带着手头所有能找到的工具窜向雕像，但 %randombrother% 刚一接触到雕像就无力地摔倒在上面。另一个雇佣兵赶去帮忙，擦过那边雕像的巨大脚趾，然后他也跟着一起倒在先前那倒霉蛋身上。就在战团开始恐慌的前一瞬间，那两名雇佣兵猛地跳起来，大叫着他们看见了壮美的绝景，看见了这世界之外的景象，看见了未来本身！\n\n 受到他俩的鼓舞，整个战团的人兴奋地朝着雕像冲去，许多人扑在雕像的脚趾上，又像不小心撞到墙的喜剧演员一样倒下。这是你见过的最荒唐的事，但每个接触过雕像的人都兴奋地嚷着神奇的故事。你耸耸肩，亲自走到雕像前，看着那长着巨大脚趾盖的脚趾。雇佣兵们起着哄叫你上前，你叹了口气，伸出手摸了摸脚趾，毛都没有。什么都没发生。你把手放进脚指甲与金灿灿的脚趾间的缝隙。你愤怒地把两只手都放在脚趾上，好像那玩意欠你钱一样。还是毛都没有，行吧，看来至少你还可以发一笔财。你抽出了剑...}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "淘金时间到。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_116.png[/img]{你挥剑砍向雕像，但就在你的尖锋第二次与黄金接触的一瞬间，整个世界上所有的光芒在你眼中一闪而没，就像你刚才一剑戳死了太阳一样。而你的剑继续砍向黑暗之中，如划过夜空的流星闪烁，从它所属的另一个世界来到你所在的现实。刹那间，就像魔术师揭开幕布，你的眼前豁然开亮，你发现自己置身于一个房间之中，四处都是支撑的石柱，华美的丝绸布帐随处可见。你的剑继续挥舞，直至与一柄长枪的枪柄相击。你看见一名穿着镀金盔甲的红眼汉子，表情狰狞地戒备着你。他借着瓷砖地面一个滑步挪向右方，让你的重心跌向地面，然后将长枪迅速甩过背后，又一把向你刺来。你用力甩开臂膀，冲到与对手贴身的距离，用你的腋下死死夹住枪柄，然后一剑从他的肩甲下刺入，一直捅到心脏的位置。那人眼中的红色迅速褪去，只剩下纯粹的眼白，他一瘸一拐地挣扎着，直到带着盔甲砰然倒地。\n\n 随着眼前的对手瘫倒在地，你快速扫视四周。靠着墙的是一张有着大理石制成的角的大床，每块大理石都被制成或男或女的人形塑像，每个雕像都被塑造成屈服于一个像是旭日朝阳般物体的造型。在床上躺着一个老人，他注视着你，满面胡须，眼神黯淡，饱经沧桑。他的神态让你感觉无比熟悉。他微笑，但笑容又很快消失。他呼喊，那语言又无从理解。一道黑影投进房间，你闪电般转身，只见一个身形巨大，眼中燃烧着火焰的骑士挥动一把双手巨剑向你直劈而下。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我挡！",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_116.png[/img]{你后退一步，将剑斜向猛甩过去，然后屈膝跪地，准备迎接冲击。对手的巨剑与你的剑碰撞那一刻，仿佛整个世界都突然被击飞了。你保持着格挡的姿势僵在原地，却仍能感受到时间与空间像狂风一样在你身边奔流，无数人的痛苦、哀嚎、生与死以难以言表的形式掠过。一点微光从远处飞速接近，你的眼前光芒一闪，感觉灵魂重回身体，挥动的长剑狠狠地与眼前的雕像撞击，反弹的力量达到让你的武器脱手飞出，划过空中，在尘土飞扬中插进地里。佣兵们面面相觑。你走过去捡回长剑。%SPEECH_ON%我觉得你把它弄坏了，头儿。%SPEECH_OFF%  %randombrother% 局促不安地说着。你告诉他和战团里其余的人收拾东西准备离开这里。再次望向雕像，你发现它现在看上去只不过是一大坨生了锈的铜罢了。你想抓住一个雇佣兵问问这雕像早些时候是不是用金子做的，但你已经知道了问题的答案。你不再开口，而是望向雕像的头，望向那张脸——那张无比熟悉的脸。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "最好别在这久留了。",
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
					bro.improveMood(1.5, "被雄伟的古老雕像所激励");

					if (bro.getMoodState() >= this.Const.MoodState.Neutral)
					{
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[bro.getMoodState()],
							text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
						});
					}
				}
			}

		});
	}

	function onUpdateScore()
	{
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

