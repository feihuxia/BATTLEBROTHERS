this.dogfighting_event <- this.inherit("scripts/events/event", {
	m = {
		Doghandler = null,
		Wardog = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.dogfighting";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 70.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_20.png[/img]%doghandler% 让你把一只%wardog%加进斗犬圈中。那听起来像是一个糟透了的主意，但是他解释道，赢了斗犬可以获得很多钱。训犬员只需要两百克朗的赌注。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好吧，但是我要跟你一起去。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "那不可能。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_20.png[/img]你拿出一袋克朗然后跟着%doghandler%一条条越来越暗的巷子。很快，就没什么能看见的了。潮湿的鹅卵石，在月光下泛出白光，懒洋洋地把你指引到城市深处，躲藏在白天的阴影中。突然，一个火把被点着，然后一个男人的脸出现在黑暗中，对着你说。%SPEECH_ON%那条狗就是要参加斗犬的？%SPEECH_OFF%%doghandler%点点头。陌生人把火把往前倾%SPEECH_ON%那好吧。这边走，先森。脚下留神。下面到处都是尿。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我们干吧。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "我改变主意了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_20.png[/img]你在男人的火把的指引下在黑暗中前进着，来到了一个门口有一个滑动入口的建筑前。陌生人有节奏的敲了敲门，然后门就如同收到命令一样打开了。你被催了进去，你一进去就被很多人恶意的瞥了几眼。你立即听到了咆哮和犬吠的喧闹声。你本来就是为了这些而来的，对吗？\n\n 你沿着楼梯进入一个大坑，一群人围在一个临时用泥巴和栅栏围成的竞技场旁边。还没有开始打斗，但是旁边已经可以看到一堆狗的尸体，而在那旁边坐着的就是它们的杀手，眼神中透着狂野，血腥的嘴巴张着喘着粗气。两条狗冲进竞技场，你看向%doghandler%。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "该拿出赌注，看我们的杂种狗有什么本事了。",
					function getResult( _event )
					{
						return "D";
					}

				},
				{
					Text = "这可不好。我们离开这里。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_47.png[/img]支付了两百克朗的赌注之后，你和%doghandler%带着%wardog%进入了竞技场。\n\n它的眼睛环顾四周，肩膀靠着你的裤腿，你都可以感觉到它快速的心跳。站在你的对面的是你的对手：一个长相下流的训犬员，旁边站着一个更像是狼而不是狗的野兽。杂种狗的没有了下唇，显现出一排锯齿状的牙齿，显得比平常更加致命。它的身上满是伤疤和溃疡，但是身形上的肌肉构架却十分明显，然后%doghandler%小声说道，这肯定会很惨烈。\n\n %wardog%向前吠了两声，这个杂种血液中就有战争的基因，你张开手，和对手同时将猎犬放入竞技场。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干掉它，孩子！",
					function getResult( _event )
					{
						local r = this.Math.rand(1, 100);

						if (r <= 33)
						{
							return "E";
						}
						else if (r <= 66)
						{
							return "F";
						}
						else
						{
							return "G";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
				this.World.Assets.addMoney(-200);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]200[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_47.png[/img]两条狗朝着彼此冲刺，转瞬之间就相遇了。它们碰撞在一起，粗糙的身体旋转着远离开，然后四脚着地，准备进行下一次的冲刺。对手的狗从%wardog% 的身下躲了过去，然后站了起来，抓住你的狗的脖子下部。\n\n%doghandler%用手捂着脸，透过指缝看着外面。你看着%wardog%颤抖着从一边走向另一边。随着它的叫喊，血从它的鼻子冲喷溅出来。你可以听到狗在土地上奋力蹬腿的声音。观众席大笑的嘲弄着。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我不能干预。",
					function getResult( _event )
					{
						return this.Math.rand(1, 100) <= 50 ? "H" : "I";
					}

				},
				{
					Text = "这必须被制止！",
					function getResult( _event )
					{
						return "J";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_47.png[/img]两条狗在竞技场中奔跑。%wardog%朝上方攻击，对手朝下。你恐惧地看着对手的狗从低处窜起来，一口咬住了%wardog%的脖子。它们在竞技场中翻腾，在这强烈的动量下，%wardog%的喉咙被撕开了。血液汹涌地喷溅出来，观众都不得不向后跳去。胜利的狗回到主人的位置，放下了嘴中的肉块邀起功来。\n\n%wardog%在土里蹒跚地挣扎。它努力的呼吸，喉咙发出喘息的声音。%doghandler%跳过栅栏，跪坐在杂种狗旁边。他试着捂住伤口，但是毫无用处。狗在临死之前一直盯着你。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Damnit!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
				_event.m.Wardog.getContainer().unequip(_event.m.Wardog);
				this.List.push({
					id = 10,
					icon = "ui/items/" + _event.m.Wardog.getIcon(),
					text = _event.m.Wardog.getName() + " dies."
				});
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_47.png[/img]两条狗在开始冲刺之前咆哮着。它们碰撞到一起，同时咬向对方的脖子，像毛茸茸的暴力纸风车一样在竞技场中翻滚。\n\n%wardog%把对手逼进一个栅栏杆。你看着你的狗死死咬住对手的脸，牙齿一口刺穿了一只眼睛，然后 又一口咬掉了一段舌头。被打败的杂种狗被咬成了碎片，毫不夸张，最终你的狗以失败告终，被撕破喉咙而死。\n\n你的对手大喊一声然后跳进了栅栏，但是观众把他拦了下来。%doghandler%拍了拍你的背。%SPEECH_ON%挣快钱，不是么？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "看来战团也有最强最坏的狗。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
				this.World.Assets.addMoney(500);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]500[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "H",
			Text = "[img]gfx/ui/events/event_47.png[/img]你觉得不进行干涉，而是允许了%wardog%的战斗，以及可能的死亡，任其自然。这个选择很快得到了回报：你看着你的狗后爪抵着竞技场周围的栅栏。猛踢了一下之后，它得以从对手下方滑了过去，然后扯下了对手的蛋蛋，展现出一种令人作呕的生存主义。那个可怜的被严格的杂种狗，发出一声尖叫，四下滚动，结果把脖子径直送到%wardog%的口中。战斗很快就结束了，几乎算是不幸中的万幸了。\n\n 你去领取你的奖金，%doghandler%拥抱着获胜了的%wardog%。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好孩子。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
				this.World.Assets.addMoney(500);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]500[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "I",
			Text = "[img]gfx/ui/events/event_47.png[/img]你不进行干涉，甚至需要在%doghandler%试着跳过栅栏的时候拦住他。你们两人只能惊恐地看着可怕的杂种狗把%wardog%的脸一点点咬下来。很快，你的狗的皮掉了一地，脖子被咬断。紧接着就是血腥的撕咬，%wardog%很快就死掉了。%doghandler%心烦意乱，只能倒在地上，双手捂脸。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Damnit!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
				_event.m.Wardog.getContainer().unequip(_event.m.Wardog);
				this.List.push({
					id = 10,
					icon = "ui/items/" + _event.m.Wardog.getIcon(),
					text = _event.m.Wardog.getName() + " dies."
				});
			}

		});
		this.m.Screens.push({
			ID = "J",
			Text = "[img]gfx/ui/events/event_20.png[/img]你把你的押注票扔在地上。%SPEECH_ON%去他妈的。%SPEECH_OFF%你纵身跳过栅栏进入了竞技场。%doghandler%就在你身后。两条狗还在撕咬，你猛踢一脚把它们分开了。训犬师迅速抓住%wardog%然后把它转移到了安全的地方。人群发出嘘声，把手中的瓶子和杯子朝你扔来。一个男人吹了声口哨让他们全部安静下来了。他走进竞技场。%SPEECH_ON%这些人来着掏钱是要看到血斗的。如果你不能满足他们，那你最好想别的办法来赔偿。两百克朗怎么样？要么那样，要么你就把你的狗放回来。%SPEECH_OFF%人群摩拳擦掌，拿出了刀、锁链以及其他残暴的武器。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拿走你的克朗。我们要带着狗走。",
					function getResult( _event )
					{
						return "K";
					}

				},
				{
					Text = "战斗会继续下去的。",
					function getResult( _event )
					{
						return "L";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "K",
			Text = "[img]gfx/ui/events/event_20.png[/img]你拿出%demand%克朗并交了出去。人群发出嘘声，但是负责的男人又吹了声口哨。%SPEECH_ON%你们都给我闭嘴！他付了钱，所以他可以带着他的蠢狗离开。%SPEECH_OFF%人群安静下来。你开始离开i啊，%doghandler%抱着失去意识的%wardog%跟在你后面。几个老顾客发出鄙夷地嘘声，但是他们也做不了更过分的事情了，你完全不在意。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "咱们回营地……",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
				this.World.Assets.addMoney(-200);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]200[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "L",
			Text = "[img]gfx/ui/events/event_20.png[/img]你命令%doghandler%把狗放下。他眼睛睁得老大。%SPEECH_ON%你在开玩笑吧。%SPEECH_OFF%点点头，你说你是认真的。%wardog%勉强醒过来，在害怕的警觉性和麻木的意识之间发出哼声。当%doghandler%再次犹豫的时候，你夺走了狗。你朝着人群点头，然后你的对手再一次放出了他凶残的猎犬。%wardog%抬起疲惫的眼睛看着你，眨了一眨，然后闭上了。你把狗放下，然后对手的猎犬带着狂野怒火冲了上来。你试着不去听脚下可怕的死亡之声。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "咱们回营地……",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Doghandler.getImagePath());
				_event.m.Wardog.getContainer().unequip(_event.m.Wardog);
				this.List.push({
					id = 10,
					icon = "ui/items/" + _event.m.Wardog.getIcon(),
					text = _event.m.Wardog.getName() + " dies."
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getMoney() < 250)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 3 && t.isAlliedWithPlayer())
			{
				nearTown = true;
				town = t;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			local item = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory);

			if (item != null && (item.getID() == "accessory.wardog" || item.getID() == "accessory.armored_wardog"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Doghandler = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Wardog = this.m.Doghandler.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory);
		this.m.Town = town;
		this.m.Score = candidates.len() * 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"doghandler",
			this.m.Doghandler.getNameOnly()
		]);
		_vars.push([
			"wardog",
			this.m.Wardog.getName()
		]);
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
		_vars.push([
			"demand",
			"200"
		]);
	}

	function onClear()
	{
		this.m.Doghandler = null;
		this.m.Wardog = null;
		this.m.Town = null;
	}

});

