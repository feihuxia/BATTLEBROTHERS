this.greenskins_investigation_event <- this.inherit("scripts/events/event", {
	m = {
		Noble = null,
		NobleHouse = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_investigation";
		this.m.Title = "在 %town%...";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_31.png[/img]你重新把存活存进去，让这些人前去休息一下，这时，城堡的主人，%nobleman%，叫你过去。他说城堡里有一只小妖精在游荡。他希望我把它找出来。%SPEECH_ON%我已经叫过我的手下去找过，但他们什么都没找到。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "我们要搜查一下餐具室。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "B1";
						}
						else
						{
							return "B2";
						}
					}

				},
				{
					Text = "我们要搜查一下大厅。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "E1";
						}
						else
						{
							return "E2";
						}
					}

				},
				{
					Text = "我们要搜查一下军械库。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "H1";
						}
						else
						{
							return "H2";
						}
					}

				},
				{
					Text = "我没时间浪费在这里。",
					function getResult( _event )
					{
						_event.m.NobleHouse.addPlayerRelation(-5.0, "Denied " + _event.m.Noble.getName() + " a favor");
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Noble.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B1",
			Text = "[img]gfx/ui/events/event_31.png[/img]你搜查了餐具室，打开门，看到了一排排的架子，摆放着各类食物，有奶酪，有腌肉，还有蔬菜。枝编的酸谭吸引到了你，当你伸出手想拿一点尝尝时，一道影子从你的身边掠过。你转过身，手里持着剑，刺向拿着破瓶向你冲来的小妖精。它不堪一击，一下就死了，打落了几袋面粉，把地上弄得一团糟。绿皮怪物死了，你不慌不忙地将之拖到%nobleman%面前。这个贵族吓得把手放到了屁股上。%SPEECH_ON%佣兵，太厉害了，但你有必要把他拖到这里来么？我的仆人得花好几周来清洗这块地板啊！%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "那很容易。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Noble.getImagePath());
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Did a favor for " + _event.m.Noble.getName());
				local food = this.new("scripts/items/supplies/wine_item");
				this.World.Assets.getStash().add(food);
				this.List.push({
					id = 10,
					icon = "ui/items/" + food.getIcon(),
					text = "你获得了酒"
				});
			}

		});
		this.m.Screens.push({
			ID = "B2",
			Text = "[img]gfx/ui/events/event_31.png[/img]你去楼下的餐具室，然后把门打开。你看到里面有成架成架的食物。碰巧有对男女在角落里做爱。他们像狗一样叫起来，并赶忙把身体遮住，男的用一个湿的面粉袋子遮住自己，女的巧妙地躲到一个甜瓜架子后面。那个男人清了清嗓子。%SPEECH_ON%先生，拜托了，别告诉%nobleman%。%SPEECH_OFF%你本来并不知道这是那个贵族的老婆，恰好现在知道了。那男的提了个建议。%SPEECH_ON%我只是个沉稳的男孩。我给不了你金子这样的东西，但我知道有个骑士在这里呆了一周了，我可以帮你拿到他的盾牌。你向你保证，这个东西非常棒，你肯定会喜欢的。我只求你别告诉主人！%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "我会告诉你的主人。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "放心吧，我不会跟他说的。",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_31.png[/img]这看起来像是与%townname%发展一段平稳关系的绝佳机会,但首先得彻底毁掉刚刚偶然建立的这段关系。你返回%nobleman%\'s房间，并向他汇报。他的脸骤然变红，指关节变成一片惨白。%SPEECH_ON%我觉得。我觉得。我**觉得！那个沉稳的男孩该怎么办？我怎么会受到这样的侮辱！%SPEECH_OFF%他突然指向他的警卫。%SPEECH_ON%把我的钳子和铁匠的煤火拿来。把我的妻子带到塔中。我呆会去对付她。另外，谢谢你，佣兵，感谢告诉我这件事。至于小妖精，既然已经找到了，就照顾一下。你不用再操心小妖精了。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "真是个恶毒的混蛋。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Noble.getImagePath());
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Did a favor for " + _event.m.Noble.getName());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_31.png[/img]你决定不告诉贵族他的老婆做了什么。两位小情人赶忙穿上衣服，走出餐具室。那个沉稳的男孩跟你说在你离开城堡前，会将那个盾牌准备好。与此同时，你向贵族报道，他伸出手请你留下来。%SPEECH_ON%啊，佣兵，你再也不用担心了。小妖精已经被找到了，就在马厩里。一匹马直接把他踢出了畜棚。那个沉稳的男孩把士兵的技能教授给了马，我必须得奖励他。%SPEECH_OFF%那当然了。\n\n 当你离开城堡时，那个沉稳的男孩等候在那，手里拿着一个疑似装有盾牌的袋子。%SPEECH_ON%嗯，这个给你。赶快！佣兵，再一次感谢你。%SPEECH_OFF%你对他说道：最好从现在开始管好你裤裆里的那玩意。他摇了摇头。%SPEECH_ON%不。她值得我我冒风险。佣兵，再见了！%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "有些人从来不曾知道。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.World.Assets.addMoralReputation(-1);
				local item = this.new("scripts/items/shields/faction_heater_shield");
				item.setFaction(_event.m.NobleHouse.getBanner());
				item.setVariant(2);
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "E1",
			Text = "[img]gfx/ui/events/event_31.png[/img]你仔细检查大厅，检查是否有小绿妖精的踪迹。路过走廊，你听到了两个女人哭着从旁边的房间内跑出来。你拔出剑，冲进那个房间。看见文员和财务站在桌子上，一个小妖精正跳上跳下地要拿小刀割他们的脚踝。你慢慢地靠近，突然出剑，一剑刺入小妖精的胸膛。然后你高高地举起，活像一串烤松鼠。他们两人终于缓过劲来，感谢你拯救了他们。你点了点头。%SPEECH_ON%随时恭候这，女士。%SPEECH_OFF%他们清了清嗓子，露出了尴尬的笑容。你回过身去找%nobleman%，去领你的报酬。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "那很容易。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Noble.getImagePath());
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Did a favor for " + _event.m.Noble.getName());
				this.World.Assets.addMoney(100);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你赚了[color=" + this.Const.UI.Color.PositiveEventValue + "]100[/color]克朗"
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "E2",
			Text = "[img]gfx/ui/events/event_31.png[/img]你觉得搜查最好从大厅开始搜查。没过多久，你听到财务传来一阵恼人的声响。你拔出剑，缓缓走到门的旁边，用肩膀将门顶开，用剑指着前方，防范可能站在门外可能的危险事物。发现并不是小妖精，而是一老一小，裤子都没穿，疯狂地在逃跑，仔细一看，桌上有一桶溢满了的黄油，他们之前是靠在那个地方。这个房间闻起来太糟糕了。\n\n 他们穿上裤子，年轻的那人告诉你他是财务，年老的说他是文员。财务赶忙给了你好多金币，让你别把刚才的糗事说出去。你大笑起来。%SPEECH_ON%我才没兴趣说出去。如果我拿了这些金币，你就会去你的主人那边说我偷了金币，是吧？有什么比让我死了更能保护你自己的方法么？%SPEECH_OFF%财务往后退了退，文员走了上来。他是个老者，身上有股屁股，蜡烛的味道。%SPEECH_ON%我在我的储藏室中存了很多我自己的东西。你可能会对这些东西感兴趣。有药剂，酒之类的。像你这样的战士可以好好利用这些。另外……我会附带送上一个军衔。一个当地的驯兽师欠我一个人情，我想现在就是个绝佳的时间让他把这个人情给还上。%SPEECH_OFF% 文员看到你一副思索的模样，大笑了起来。如果你把他们刚才的事说出去，没人能预料到会发生什么。他们鸡奸对你并没什么影响，只有这里的主人才会在意自己的城堡发生这种事。如果%nobleman%是这样的人的话,你把这些人供出去，可能会获得好处。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "城堡的主人会决定你的命运。",
					function getResult( _event )
					{
						return "F";
					}

				},
				{
					Text = "放心吧，我不会跟他说的。",
					function getResult( _event )
					{
						return "G";
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_31.png[/img]你关上壁橱门，急忙去找%nobleman%。你对贵族解释你已经看见了。等你说完，他表示哥布林被发现溺死在下水道中，已经脱离了苦海。%SPEECH_ON%至于鸡奸者，又怎么样呢？你四处查看了吗？对于人类的欲望来说，堡垒是无意义之地。能看见的都是甩来甩去的鸟，没地方放。我喜欢吗？不，当然不了。超级恶心的无稽之谈，真的。但我如果惩戒了这种行为，那就只剩一堆稻草人和家畜了，而后者我甚至都不能确定。%SPEECH_OFF%他总是挥手和你说再见。%SPEECH_ON%哥布林已经被解决了，佣兵，我有点别的事要跟你说。不过，如果可以的话，请你提醒仆人，你发现他们的房间需要打扫。我才懒得费劲儿去查看税收。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "Oh.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Noble.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_31.png[/img]在文士会按照约定给你报酬的借口之下，你决定帮他们保守秘密。老人点头送你离开。%SPEECH_ON%我会去院子里找你的，佣兵，带着你应得的一切。很感谢你对这件事的沉默。%SPEECH_OFF%等你回到%nobleman%身边，他解释说哥布林已经被发现处理掉了。见识到你有多不负责任以后，他没给钱就赶了你出去。\n\n 在外面，你果然见到了文士。他一手拿着皮带，一手拿着麻袋。他把两样东西都交给了你。%SPEECH_ON%再次感谢，佣兵。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "我应该了解更多秘密。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				local item;
				item = this.new("scripts/items/accessory/poison_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				item = this.new("scripts/items/accessory/antidote_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				item = this.new("scripts/items/accessory/berserker_mushrooms_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				item = this.new("scripts/items/accessory/wardog_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "H1",
			Text = "[img]gfx/ui/events/event_31.png[/img]如果你是哥布林，呆在所有人都想杀了你的城堡里，你会去哪里？设身处地想想，你会得出军械所是最好的搜查起点这个结论。等你到的时候，确实发现有个学徒站在外面，力图把门关上。他对里面杀死了铁匠的哥布林叫喊着。你拔出剑，要学徒站一边去。\n\n 他照做的一瞬间，门被撞飞了，跟废铁做成的稻草人一样的哥布林闯了出来，全副武装，笨拙地把长矛和盾牌竖在了前面。你忽略了眼见情形的荒唐感，发起攻击，穿透了这个畜生的脑壳，一击毙命。等你收回剑，所有的盔甲和武器都掉了下来，好像你刚才杀死了举着它们的幽灵一般。\n\n 学徒倒下来之前握着你的手，为铁匠的不幸哭泣着。你没时间掉眼泪，你带着哥布林的脑袋去找%nobleman%拿报酬。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "那很容易。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Noble.getImagePath());
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Did a favor for " + _event.m.Noble.getName());
				this.World.Assets.addMoney(100);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你赚了[color=" + this.Const.UI.Color.PositiveEventValue + "]100[/color]克朗"
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "H2",
			Text = "[img]gfx/ui/events/event_31.png[/img]好吧，如果你是个躲在敌方堡垒里的小矮子，第一个要去的地方肯定是军械所。等你到那里的时候，没发现哥布林，反而有个小孩从脸朝下倒在地上的人身上抽出一把匕首。凶手丢下了武器，举起双手。%SPEECH_ON%我别无选择！根本没有办法！%SPEECH_OFF%你问这孩子他和死者的身份。他很快解释道。%SPEECH_ON%我是学徒，这位是……铁匠。现在，必须这么做。必须！你根本不知道这家伙给我带来了多大的恐惧！我每次出错，他对我的惩罚就好像我是个弑君的白痴一样！看到了吗？%SPEECH_OFF%他撩开一片头发，露出了烧伤的疤痕。他放下头发，举起一只手，小指奇形怪状，扭成了直角，而另一只手上根本没有小指。他开始脱靴子，但你阻止了他，也明白了他的意思。学徒把双手勾在一起，他的小指像傲慢的贵族饮酒时那样翘着。%SPEECH_ON%你在追哥布林，对吗？跟他们说是哥布林干的！我……会看着，我不是很厉害的军械师，但我可以铸造一把有力的剑，我会尽全力帮你铸造这把剑。不要把这件事说出去，我只有这个请求。%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "这样的罪孽不能被宽恕！",
					function getResult( _event )
					{
						return "I";
					}

				},
				{
					Text = "放心吧，我不会跟他说的。",
					function getResult( _event )
					{
						return "J";
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "I",
			Text = "[img]gfx/ui/events/event_31.png[/img]你关上们，上了锁，确保凶手逃不出去。学徒叫喊着，撞着门，你回去找贵族了。\n\n %nobleman%听完你的报告点点头。%SPEECH_ON%嗯嗯，对。铁匠不是第一个落在他手里的人——我们已经遇上了一系列谋杀了，就是一直找不到罪犯。很多人认为他是因为双手被锤子猛击，脸被火炬烤焦。马童甚至看到他割下了一只老鼠的鸟。他精神失常，但你给了我们决定性证据。干得好，佣兵！你在追查的哥布林已经解决了，但这……这比追杀绿皮怪物强多了。你的报酬翻倍了！%SPEECH_OFF%贵族对文士叩叩手指，开始下命令，好像是在说处决令。他对这件事的后勤说得很详细：马匹，绳索，刀剑，钳子，烈火，让无聊的士兵高兴上几小时的恐怖。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "非常好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Noble.getImagePath());
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Did a favor for " + _event.m.Noble.getName());
				this.World.Assets.addMoney(200);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你赚了[color=" + this.Const.UI.Color.PositiveEventValue + "]200[/color] 克朗"
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "J",
			Text = "[img]gfx/ui/events/event_31.png[/img]你关上们，上了锁，确保凶手逃不出去。学徒叫喊着，撞着门，你回去找贵族了。\n\n %nobleman%听完你的报告点点头。%SPEECH_ON%嗯嗯，对。铁匠不是第一个落在他手里的人——我们已经遇上了一系列谋杀了，就是一直找不到罪犯。很多人认为他是因为双手被锤子猛击，脸被火炬烤焦。马童甚至看到他割下了一只老鼠的鸟。他精神失常，但你给了我们决定性证据。干得好，佣兵！你在追查的哥布林已经解决了，但这……这比追杀绿皮怪物强多了。你的报酬翻倍了！%SPEECH_OFF%贵族对文士叩叩手指，开始下命令，好像是在说处决令。他对这件事的后勤说得很详细：马匹，绳索，刀剑，钳子，烈火，让无聊的士兵高兴上几小时的恐怖。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "对对，现在可以出去了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				local item = this.new("scripts/items/weapons/arming_sword");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isGreenskinInvasion())
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();
		local towns = this.World.EntityManager.getSettlements();
		local bestTown;

		foreach( t in towns )
		{
			if (!t.isAlliedWithPlayer())
			{
				continue;
			}

			if (!t.isMilitary() || t.getSize() < 2)
			{
				continue;
			}

			local d = playerTile.getDistanceTo(t.getTile());

			if (d <= 4)
			{
				bestTown = t;
				break;
			}
		}

		if (bestTown == null)
		{
			return;
		}

		this.m.NobleHouse = bestTown.getOwner();
		this.m.Noble = this.m.NobleHouse.getRandomCharacter();
		this.m.Town = bestTown;
		this.m.Score = 25;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"noblehouse",
			this.m.NobleHouse.getName()
		]);
		_vars.push([
			"nobleman",
			this.m.Noble.getName()
		]);
		_vars.push([
			"town",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.NobleHouse = null;
		this.m.Noble = null;
		this.m.Town = null;
	}

});

