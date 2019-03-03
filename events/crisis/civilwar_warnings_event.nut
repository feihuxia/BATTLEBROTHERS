this.civilwar_warnings_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_warnings";
		this.m.Title = "路上…";
		this.m.Cooldown = 3.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "{[img]gfx/ui/events/event_76.png[/img]你在路上碰到了一个陌生人。他朝你投去了坚毅的目光，绵阳与猎犬的军队在他身旁一动不动。%SPEECH_ON%嗯，侬是要去给%noblehouse%打仗吗？我听说他们和王国的其他家族正在起争执。不知道为啥子的。只是知道他们会来我这里然后问说，“%randomname%，你为什么不来帮我们战斗呢，不来的话就吊死侬，我就会说“好吧，因为一群脸上贴金的贵族们毁掉我的青春也是生活的一部分啦，而且生活本身就不是公平的。%SPEECH_OFF% | [img]gfx/ui/events/event_91.png[/img]一个女人站在路边看着你的战队路过。他上下打量了一下你的徽章。%SPEECH_ON%嗯，没见过这个。大概贵族们会马上叫你的。%SPEECH_OFF%你问她是什么意思。她耸了耸肩。%SPEECH_ON%我听说，有个傻逼对一次出岔子的皇室婚礼很生气。很多人都在说这有可能意味着战争什么的狗屎东西。那些贵族们整天都在争论什么东西，不需要多久他们就会兵戎相见，或者叫我们这些平民帮他们去打仗。%SPEECH_OFF% |[img]gfx/ui/events/event_17.png[/img]一个老头坐在那里抽着烟斗，用一种恍惚地眼神看着你的战团。%SPEECH_ON%佣兵，是吧？应该很快就有事情做了。%SPEECH_OFF%你问他是什么意思。他清了清烟斗，敲击着自己的脸颊。%SPEECH_ON%哦，你知道的。那些金缕玉衣的贵族们又他妈在吵了。战争要来了，毫无疑问-不能浪费他们身上的华服异彩啊。%SPEECH_OFF% | [img]gfx/ui/events/event_75.png[/img]一个信使路过，他的箩筐里面什么也没有。%SPEECH_ON%啊，我都没有新闻了，但是我有些小道消息，感兴趣吗。%SPEECH_OFF%你点了点头。他笑了笑。%SPEECH_ON%我也这么觉得。好了，有时候贵族们会叫我去，给我点要发的报纸。有时候我会偷听他们的对话。我听见了很多关于军队的话题，我们得政府那些狗娘养的那种事情。所以，佣兵，你应该很快就有好工作了。%SPEECH_OFF%|[img]gfx/ui/events/event_97.png[/img]%SPEECH_ON%嘁。嘁！嘿！%SPEECH_OFF%你转过身看见一个男孩从灌木丛中钻了出来。他朝你笑了笑。%SPEECH_ON%嘿，我有东西要说。战争要来了。%SPEECH_OFF%相信这个怪怪的小兔崽子可不是你会做的。你问他是怎么知道的。他朝你笑了笑。%SPEECH_ON%我帮一个穿丝绸裤子的男人取水的。他说“我可以给你点糖果，或者给你点可以好好思考的事情。”我说告诉我些好玩的东西。他说“贵族们要互相打架了。”所以我就告诉你了。%SPEECH_OFF%小孩停了下来。%SPEECH_ON%话说，你身上有糖果吗？嘿……嘿！%SPEECH_OFF%你把孩子的头推回了灌木丛去。| [img]gfx/ui/events/event_75.png[/img]一个老头子和一个皮肤白净的女子在路上见到了你。她正在玩弄着肩膀上的一串头发，弯月般的眼睛看着你的队伍中几个好看点的男人。在你说话之前，她问你是为%noblehouse1%还是%noblehouse2%而战的。%SPEECH_ON%人们说有一个王子跟一个公主私奔了，说这是爱情。那真是太梦幻了。%SPEECH_OFF%你耸了耸肩肩。年老的男人踩了踩脚然后吐了口唾沫。%SPEECH_ON%不要用你的那些幻想打扰佣兵们，女人。不好意思，佣兵，她一直有这些奇怪的想法，我也不知道是从哪里俩的。贵族们都在谈论战争，但是肯定不是因为什么傻逼王子或者公主的事情。经济！那才是问题所在。以前的交易协定都跟写就的羊皮纸一样烂掉了。告诉你，我那时候跟他们在……%SPEECH_OFF%老头子不停说着。你更加倾向女士的故事，就算听上去很疯狂也是。| [img]gfx/ui/events/event_75.png[/img]你碰到了一个坐在路标上的男人。他在调试着鲁特琴的琴弦。%SPEECH_ON%嗯，那样子更好了，是不是？同意我的观点吧。%SPEECH_OFF%你耸了耸肩，问这男人在做什么。他跳下了路标牌，像一个弄臣弄臣一样做了个后空翻。%SPEECH_ON%练习！战争要来了，我听说了，战争来了的话就需要……就需要……就需要，表演者了！没错！任何夜晚的愉悦都是在呼唤着我-而且不止一种愉悦。%SPEECH_OFF%他自顾自地笑了起来。你从来没有见过牙齿这么白的男人，你有种给他一拳的冲动。游方艺人继续走了下去。%SPEECH_ON%不要担心，佣兵，贵族们内斗的话，你肯定不缺活。日安！%SPEECH_OFF% |[img]gfx/ui/events/event_16.png[/img]你在路上碰到的农民和商人们的喃喃自语中听见了越来越多的关于贵族之间即将到来的战争的消息。你作为佣兵的身份让他们询问你准备为谁举大旗。如果这些传闻是真的话，那么%companyname%能够在这些趾高气昂的贵族之间的战斗中获得很多利润。| [img]gfx/ui/events/event_45.png[/img]你在路上碰到了一群赌徒。他们放了一些代表这片大地上所有贵族家族的小旗子。下注员正在书写记录，查看着自己的卷轴。%SPEECH_ON%记好了，贵族间的战争的结果得花些时间才会明朗起来。该死的，我打赌你们大部分人都会被招募入伍的。但是那些活下来的可以在一年后回我这里来。那时候我们就会支付那些押对战争走向人。听懂了吗？%SPEECH_OFF%呆诺木鸡的农民们耸了耸肩。%SPEECH_ON%听上去可以！%SPEECH_OFF%书记员咧开了嘴，嘴里的金牙亮闪闪。%SPEECH_ON%棒极了！%SPEECH_OFF%他把赌注都放进了袋子里面，然后离开了，很有可能这辈子都不会回来了。真是可惜了，那些愚蠢的农民们完全没有意识到这到底是怎么一回事。| [img]gfx/ui/events/event_75.png[/img]在旅行期间，你一直听到一个有趣的传闻：贵族们已经在为战争动员了。如果是真的话，%companyname%可以弄到一大笔钱，如果挑选正确的话更加能大赚特赚。| [img]gfx/ui/events/event_23.png[/img]每一个农民最近都在讲述同一个故事。事实上，似乎每一次你看见他们的时候都在重复这个故事……\n\n 战争。战争要来了。贵族们正在因为你一点也不会关心的事情争吵着，但是那意味着战争，而战争对于佣兵来说就是克朗，而且克朗很不错，所以战争也很不错。如果这些留言是真的话，%companyname%应该谨慎衡量自己的选择，在即将到来的争斗中挑选正确的贵族势力。| [img]gfx/ui/events/event_80.png[/img]你注意到贵族们的招募者正在活动，征召年轻力壮的男人。征兵不是什么不寻常的申请，但是基本上你还是需要有人去种地的。如果贵族们把那些交给女人的话，那就意味着有什么更加重要的东西，而那种东西毫无疑问正在酝酿着战事。%companyname%应该做好最坏的打算-好吧，给其他人做好最坏的打算。有钱的混蛋们之间的战争对于佣兵来说是最棒的了！}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "太好了。",
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
		if (this.World.FactionManager.getGreaterEvilType() == this.Const.World.GreaterEvilType.CivilWar && this.World.FactionManager.getGreaterEvilPhase() == this.Const.World.GreaterEvilPhase.Warning)
		{
			local playerTile = this.World.State.getPlayer().getTile();
			local towns = this.World.EntityManager.getSettlements();

			foreach( t in towns )
			{
				if (t.getTile().getDistanceTo(playerTile) <= 4)
				{
					return;
				}
			}

			this.m.Score = 80;
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		_vars.push([
			"noblehouse",
			nobles[0].getName()
		]);
		_vars.push([
			"noblehouse1",
			nobles[0].getName()
		]);
		_vars.push([
			"noblehouse2",
			nobles[1].getName()
		]);
	}

	function onClear()
	{
	}

});

