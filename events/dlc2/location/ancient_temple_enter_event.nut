this.ancient_temple_enter_event <- this.inherit("scripts/events/event", {
	m = {
		Volunteer = null,
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.location.ancient_temple_enter";
		this.m.Title = "随着你的接近...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_111.png[/img]{神殿的入口只有一半露出在地表，建筑的其余部分早已沉入地下，看上去像是个陵墓。沿着一条尚能辨认的梁带，你看见一幅石质的浮雕，描绘着被掀翻的桌子，以及一具披盔戴甲，拿着鞭子的骷髅，还有似乎是在试图逃离那具骷髅的贵族。有几个雇佣兵认为进入这个地方肯定是个馊主意，但你觉得正因为其他人也会这么想，所以这所陵墓很可能还从未被别人所踏足过。\n\n 你找来一根火把，带着雇佣兵的冒险精神和盗墓贼的熊心豹子胆决定进入建筑内。带好补给后，你趴下来，先把腿伸进洞口，然后滑下跳进底下的台阶上进入了神殿。你靴子发出的声音在大理石制成的的大厅里传开，你在身前挥舞着火把，就像要看清你脚步的回声传到哪去了一样。回头望去，教堂地砖与天花板之间的光亮将你战团成员的影子投射出来，他们看上去就像一堆对自己的作品十分满意的神官。 %volunteer% 摇摇头说他要跟你一起下来，而其他人都说要留在地表上望风。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "咱们进去瞧瞧。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "别管这些废墟了，继续前进。",
					function getResult( _event )
					{
						if (this.World.State.getLastLocation() != null)
						{
							this.World.State.getLastLocation().setVisited(false);
						}

						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_111.png[/img]{大厅的两边都覆盖着关于军队的壁画，规模达到都能把一场局部战争给整个儿展现出来了。其中一块壁画在其中的规模尤为突出，仿佛要在大厅的墙壁上无止境的延伸下去。画面描写了一批披坚执锐的重甲战士的勇猛冲锋，他们的对手似乎是一大堆野蛮部族，数量多到看起来不像是人而是一大群虫子。你的火把在黑暗中发出暗淡的光，艺术家创作的壁画在橘黄色火光的照耀下变得栩栩如生。在角落里你找到了对这场冠以正义之名的残杀与暴行的描述。在阵型紧凑的军团和乱成一坨的蛮族中间，这场战斗看上去就像秩序与混沌的正面冲突。尽管一般来说秩序必胜，但在这里看上去，却是混乱本身在向胜利迈进。\n\n %volunteer% 吹了声口哨。你看见他的火把跟团鬼火一样在大老远的地方闪着。你一路小跑过去，发现他正拿着个装着奇怪液体的小瓶。那雇佣兵把他的火把转向一边墙上的凹室。一根大理石柱子支撑着凹室的中心，底部堆着一堆骷髅。%SPEECH_ON%我是在这东西的底座上找着这瓶子的。我看见那边还有两瓶这样的东西，但它们都在门后边。%SPEECH_OFF%你询问雇佣兵为什么他没告诉你关于那些骷髅的事，他耸耸肩。%SPEECH_ON%他们一不呼吸二不动弹，管他们作甚。再说你还要不要那边那两个瓶子了？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "说干就干。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
				this.World.Assets.getStash().makeEmptySlots(1);
				local item;
				item = this.new("scripts/items/tools/holy_water_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了 " + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_111.png[/img]{你在一扇有人胸膛那么高的门后发现了下一瓶药水。瓶子被抓在一尊倒吊在天花板上的石像鬼雕像的爪子里。门前的一块石板上刻着些象形文字，但那些都是古代文字，就算不是古文，你也看不懂上面写的是啥。突然，一个声音炸响。%SPEECH_ON%群鸟居于田，而一猎户至其中。猎户拔箭悲呼，数鸟起而猎户尽射之。又数鸟惊起，而猎户复尽射杀之，猎户恸哭，拾群鸟之尸。见人之哭啼，群鸟尽闻声而至。猎户涕泪交零，御射发矢。然其射之不速，盖其隔少顷便止而拭泪也。一鸟视其友人，言其将往慰猎户。问鸟之友人以何言对之？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "勿视其涕泪，留心其弓矢！",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "遇失心之人则必救之。",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "咕咕咕。",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "你说啥？",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_111.png[/img]{那声音停顿片刻，然后回复。%SPEECH_ON%然也！%SPEECH_OFF%古老的机械结构开始震动，大门滑下，石像鬼的爪子也垂落到人臂可及的范围内，雕塑用冰冷的眼神注视着你们。你拿起瓶子，紧紧将其握住，好像那雕像会突然活过来把瓶子再抢走一样。你挥动火把，要求先前说话的声音报上名来。那声音笑笑，不作任何回复。 %volunteer% 看着你耸耸肩。%SPEECH_ON%好吧，至少咱拿着宝贝了不是？去拿最后一瓶吧，试试又不花钱。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好主意。",
					function getResult( _event )
					{
						return "G";
					}

				},
				{
					Text = "不，这地方看上去不安全，咱们走。",
					function getResult( _event )
					{
						return "F";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
				this.World.Assets.getStash().makeEmptySlots(1);
				local item;
				item = this.new("scripts/items/tools/holy_water_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了 " + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_111.png[/img]{你摇头否认。拿到第一瓶药水只是个巧合，也许稍有差池，那凹室中的骷髅就会再增加两具。你们能成功全凭运气。第二瓶药水来自于一个会问你莫名其妙的鸟问题的奇怪声音，这些已经够了。你命令 %volunteer% 离开神殿，而你自己也很快带着两瓶药水和意外获得财宝的惊喜离开了。\n\n 在外面，你发现 %companyname% 的人正对着一具还在飙血的尸体又踢又戳，他们说这家伙在你们还在神殿里的时候跑了出来。一个雇佣兵掏出一片纸，上面写着你们发现的药水的配方，他们顺便还展示了一下那种药水能像把铁水倒在蚂蚁头上一样把僵尸干掉的神奇功效。 %volunteer% 笑了起来。%SPEECH_ON%看来咱们知道这种东西是用来干嘛的了。%SPEECH_OFF%你点点头，询问那个死掉的家伙身上还有没有别的东西。另一个雇佣兵耸耸肩。%SPEECH_ON%他从你们下去的地方跑了出来。还说着什么 \'一披甲执锐之人，携一勇士伴其左右……我有个谜语要说给你们听\', 然后我就把丫给砍翻了。你懂的，这家伙看上去很危险。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "看来这就是那谜语的来历了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_111.png[/img]{最后一个瓶子在另一扇门后面，被放在一个从建筑学角度看相当让人糟心的位置。那地方没有护栏，取而代之的是带着灼烧痕迹的弯曲金属尖刺。大门也不像上一扇门一样在你胸膛的高度，而是只有人小腿那么高。瓶子被放置的高度还要更高，这意味着你得把自己弯成U字形才能拿到瓶子。那个声音又回来了。%SPEECH_ON%万物自我而生，万物终化为我。逢人踏地而行，我自紧随其后。%SPEECH_OFF%你在一片寂静中望向 %volunteer%。 他耸耸肩。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "灰尘。",
					function getResult( _event )
					{
						return "H";
					}

				},
				{
					Text = "我去你妈的！",
					function getResult( _event )
					{
						return "I";
					}

				},
				{
					Text = "过来帮我把那门砸开， %volunteer%！",
					function getResult( _event )
					{
						return "J";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "H",
			Text = "[img]gfx/ui/events/event_111.png[/img]{那个词刚从你嘴里说出，大门就震动着升起。你若有所思地盯着剩下的空隙。 %volunteer% 蹲下来，把他的胳膊伸过在门道的顶部去拿药瓶。大门的尖顶在他摸到瓶子的玻璃时嘎嘎作响，就像一头不情愿地被人刷牙的熊一样。他最终用两根手指夹住瓶子，把瓶子甩到手掌安全的怀抱中。雇佣兵站起来把瓶子交给你。%SPEECH_ON%挺简单的，是吧？%SPEECH_OFF%你点点头但是马上就甩过身去，举着火把大喊着是谁在说话。没人回应。在黑暗中快速搜索一番后，你没有发现什么隐藏的洞穴或通道，却发现了零散的图画和笔记。这几张纸似乎说明了你拿到的药水只要几滴就能干掉一只僵尸。在这之中还有张黏糊糊的纸，上面潦草的画着一个女人。你已经不关心那声音是谁了。你带上药水，回到 %companyname%。他们一听到你的声音就拔出剑，但在看见你们的脸后又尴尬地把剑收了起来。%SPEECH_ON%抱歉队长，我们还以为你们死了，而且变成了，呃，行尸走肉。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "虽然还有点问题，但至少我们拿到药水了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
				this.World.Assets.getStash().makeEmptySlots(1);
				local item;
				item = this.new("scripts/items/tools/holy_water_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你得到了 " + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "I",
			Text = "[img]gfx/ui/events/event_111.png[/img]{那个词刚从你嘴里说出，大门就震动着升起。你若有所思地盯着剩下的空隙。 %volunteer% 蹲下来，把他的胳膊伸过在门道的顶部去拿药瓶。大门的尖顶在他摸到瓶子的玻璃时嘎嘎作响。那声音突然以巨大的音量又响了起来。%SPEECH_ON%去-去我妈的？干你娘的吧，臭弟弟！%SPEECH_OFF%说完，大门便突然落下，尖头刺穿了 %volunteer%的手臂。他痛苦地大喊起来，你连忙跪下试图把大门拉起来。大门比预想中的要重，你放手的瞬间，大门飞快的落下，在雇佣兵的手臂上划出长长的伤口，划伤了他的静脉。你为他包扎伤处，带着他前往出口。一路上不断挥舞着火把，防范着任何可能的伏击。不过，当你快要出去的时候，你停下来，看向在第一个瓶子旁边发现的骷髅。你从药瓶里倒出一滴，用手指触摸。没有反应。然后你把手指放在其中一块骨头上，它发出咝咝的响声并开始冒烟。 %volunteer% 大笑起来。%SPEECH_ON%这就是为啥你能当上队长了，头儿。这样的直觉在干这行的时候可有用了！%SPEECH_OFF%你再也没听到那个神秘的声音，反正你也不想再听到那疯疯癫癫的话了。你也没有把那谜语人的事情说给 %companyname%.\n\n %volunteer%受的伤并不会要了他的命，这只不过是为了那些古代药水付出的一些代价而已。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "至少付出代价的不是我……",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
				local injury = _event.m.Volunteer.addInjury([
					{
						ID = "injury.pierced_arm_muscles",
						Threshold = 0.25,
						Script = "injury/pierced_arm_muscles_injury"
					}
				]);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.Volunteer.getName() + " 承受了 " + injury.getNameOnly()
				});
				_event.m.Volunteer.worsenMood(1.0, "在探索古代陵墓时受了伤");
				this.World.Assets.getStash().makeEmptySlots(1);
				local item;
				item = this.new("scripts/items/tools/holy_water_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了 " + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "J",
			Text = "[img]gfx/ui/events/event_111.png[/img]{你受够这些乱七八糟的事了。不管那声音是何方神圣，是古代的幽灵还是个脑子有坑的跳梁小丑，你都要亲自揭穿他那神神秘秘的伪装。你后退一步，用力一脚踹在大门上。大门的铁条在第一次踢击下弯成V字形，在第二次撞击下轰然倒塌。那个声音短促的尖叫起来。%SPEECH_ON%喂-喂！你不能那么干！%SPEECH_OFF%清理掉生锈的碎片和尖锐的尖顶后，你蹲下来看着那药水瓶。就在这时，你看到一个男人跳进了放瓶子的小房间里。他就像只坠崖的小鹿崽一样掉到地上，把药瓶从原本的位置打落，掉到地上摔得粉碎。你抓着那个人的脚，把他从大门的支架上拖了出去。 %volunteer% 将一把剑抵在他的喉咙上，那人把手举在身前不停乱挥。%SPEECH_ON%我我我不是那个意思-没别的意思-就是没有恶意。%SPEECH_OFF%你讯问他是谁，以及是不是他杀了第一个瓶子那边的人。%SPEECH_ON%我叫 %idiot% 还-还有他们是有肉的那种-不是骷髅-会走路的死人。它们闻闻那瓶子里的东西，然后就都跟喝醉了似的倒在那儿了。你看，大哥，我啥都没干！就是找点乐子，就是那样。别杀我，我-我什么都愿意干！呃，几乎什么都干。%SPEECH_OFF%他看起来很焦虑。你望向 %volunteer% ，他耸耸肩。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "成吧，你可以加入我们。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						return "K";
					}

				},
				{
					Text = "滚滚滚，玩蛋去。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						return "L";
					}

				}
			],
			function start( _event )
			{
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");
				_event.m.Dude.setStartValuesEx([
					"cripple_background"
				]);
				_event.m.Dude.getSprite("head").setBrush("bust_head_12");

				if (_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
				{
					_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand).removeSelf();
				}

				if (_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
				{
					_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand).removeSelf();
				}

				if (_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Head) != null)
				{
					_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Head).removeSelf();
				}

				this.Characters.push(_event.m.Volunteer.getImagePath());
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "K",
			Text = "[img]gfx/ui/events/event_111.png[/img]{那人的眼睛在黑暗中闪闪发光，眼神像是散落的余烬。%SPEECH_ON%你说真的？我可以加入你们？太好啦！%SPEECH_OFF%他慢慢站起来，好像动作快了你就会改变主意似的。他朝你伸出一只手，当然你是不会和他握手的。%SPEECH_ON%我叫 %idiot%。我的脑子只有一半，剩下一半是木头和纸糊的。当然，我是在开玩烁。玩乐，玩烁，懂？%SPEECH_OFF%你看着 %volunteer% 一剑捅进了那家伙的胸膛。那智障低头看着刺穿自己心脏的剑，脸色变得很紧张。%SPEECH_ON%啊哦。你刚是不是把我捅死了？%SPEECH_OFF%%volunteer% 点点头。%SPEECH_ON%对，是我干的，你还有几秒准备遗言，请开始你的表演。%SPEECH_OFF%那谜语家想了一小会儿。%SPEECH_ON%好吧，我还从来没想过这个，但…既然你…问…了……%SPEECH_OFF%他话没说完就扑街而亡。雇佣兵把剑上的血擦干，开始搜他的尸，结果在他的口袋里除了发霉的老鼠骨头什么都没找到。当他把尸体踹走的时候，尸体与地上的瓷砖撞击发出清脆的响声。你蹲下来观察那人的头骨，发现他还真没开玩笑。他的脑子有一半是木头做的！你看着 %volunteer% ，他耸耸肩。%SPEECH_ON%我不管他身上有没有值钱东西，我砍死他纯粹是因为这家伙的叨逼太烦人了。还有，你看他的眼睛！这蠢货比蝙蝠还瞎。%SPEECH_OFF%那谜语家的眼睛是一片空白的灰色。鬼知道他到底在这个神殿里呆了多久。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧，两瓶药水是我们的了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "L",
			Text = "[img]gfx/ui/events/event_111.png[/img]{你没时间和这智障扯皮。你让他哪凉快哪待着去，他跑开了。你听到他的脚步声在黑暗中传开，就像蝙蝠在自己熟悉的山洞里扑扇翅膀一样。没多久，你听到他离开神殿时发出的声音，而且他刚一走到那么远的地方，就被 %companyname% 的人在一阵叫喊和一声短暂的惨叫中砍倒。在你回到地表时，你看见雇佣兵们正把那白痴的尸体踢来踢去，翻捡着任何可能的战利品，其中大部分都是一堆字迹潦草的谜语。\n\n %volunteer% 大笑着把那几瓶看着很神奇的药水放进了仓库。你命令战团准备出发。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "还算不错，一切都在计划之中。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Volunteer.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
	}

	function onPrepare()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (!bro.getSkills().hasSkillOfType(this.Const.SkillType.Injury))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() != 0)
		{
			this.m.Volunteer = candidates[this.Math.rand(0, candidates.len() - 1)];
		}
		else
		{
			this.m.Volunteer = brothers[this.Math.rand(0, brothers.len() - 1)];
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"volunteer",
			this.m.Volunteer != null ? this.m.Volunteer.getNameOnly() : ""
		]);
		_vars.push([
			"idiot",
			this.m.Dude != null ? this.m.Dude.getNameOnly() : ""
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Volunteer = null;
		this.m.Dude = null;
	}

});

