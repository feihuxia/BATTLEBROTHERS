this.greenskins_pet_goblin_event <- this.inherit("scripts/events/event", {
	m = {
		HurtBro = null
	},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_pet_goblin";
		this.m.Title = "路上…";
		this.m.Cooldown = 80.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img]穿过森林的时候，你走到了一块有小屋的空地上。墙上挂着捕熊陷阱，屋檐下挂着松树皮毛，窗台角落里装饰着湿树叶。有个老头在门廊下，在椅子中摇摇摆摆。他拿着弩箭瞄准你。%SPEECH_ON%这是我的财产。%SPEECH_OFF%有条锁链从椅子扶手一直连接到小屋门下的舱口。它跟着老头的话慢慢移动着，他转过去用弓弩撞了下门。%SPEECH_ON%你安静点！你，拿剑的那个，还有你的朋友们，都走吧。再走错一步，走到我的地盘，我就对你们的屁股射箭了。%SPEECH_OFF%%randombrother%放松走到你身边。%SPEECH_ON%我们怎么办？%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "再近一点看看。",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "C";
						}
						else
						{
							return "D";
						}
					}

				},
				{
					Text = "没时间做傻事。",
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
			Text = "[img]gfx/ui/events/event_25.png[/img]你没理由继续侵犯这个老头，所以你叫战团给他和他的小屋腾点地儿。你们走的每一步，老头都怀疑地看着。%SPEECH_ON%嗯嗯，祝你们愉快。%SPEECH_OFF%你点头回应道。%SPEECH_ON%是啊，你也是。%SPEECH_OFF%锁链又动了，老人又叫它安静。谁他妈知道这里怎么了，但战团有地方去。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "过得愉快。",
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
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_25.png[/img]你往前走了一步。老头从椅子上跳起来吐了口口水。%SPEECH_ON%王八蛋。%SPEECH_OFF%他举起弓弩射了一箭。箭射偏到了树上，发出噼啪一声，然后咔哒咔哒掉下来一堆树枝和灌木。%randombrother%冲上门廊把老头摁到了地上。%SPEECH_ON%把你的脏手拿开，你，你这个皮条客！%SPEECH_OFF%老人又骂又踢，你冷静地走上门廊，打开了小屋的大门。锁链掠过地板拉紧了。一道黑影闪到了角落里，破坏墙壁想要逃出束缚。你拿起火把对黑暗挥舞。你看到了一个囚犯。老头在门廊上大喊。%SPEECH_ON%你别管我们！你快滚，别管我们！%SPEECH_OFF%畏缩着退开你的火把的，是个哥布林。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "你为什么要把哥布林锁在这里？",
					function getResult( _event )
					{
						return "F";
					}

				},
				{
					Text = "最好现在就干掉这东西。",
					function getResult( _event )
					{
						return "E";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_25.png[/img]你往前走了一步。老头从椅子上跳起来吐了口口水。%SPEECH_ON%王八蛋，我警告过你们了！我好好地，清楚地警告过你们了！%SPEECH_OFF%他举起弓弩射了一箭。箭矢从你肩膀上飞过，射中了%hurtbro%的胳膊。佣兵往下看去，一丛羽毛在伤口一边晃动，另一边则是血淋淋的箭杆。他坐了下来。%SPEECH_ON%妈的。%SPEECH_OFF%%randombrother%大叫着冲上去。老头正向重新装箭，佣兵踢开了弓弩，把他砸到了地上。你叫他别把人弄死。老人又骂又踢，你冷静地走上门廊，打开了小屋的大门。门推得很开，锁链掠过地板拉紧了。一道黑影闪到了角落里，破坏墙壁想要逃出束缚。你拿起火把对黑暗挥舞。你看到了一个囚犯。老头在门廊上大喊。%SPEECH_ON%你别管我们！你快滚，别管我们！%SPEECH_OFF%畏缩着退开你的火把的，是个哥布林。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "你为什么要把哥布林锁在这里？",
					function getResult( _event )
					{
						return "F";
					}

				},
				{
					Text = "最好现在就干掉这东西。",
					function getResult( _event )
					{
						return "E";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HurtBro.getImagePath());
				local injury = _event.m.HurtBro.addInjury(this.Const.Injury.PiercedArm);
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.HurtBro.getName() + " suffers " + injury.getNameOnly()
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_25.png[/img]你拔出了剑，走进小屋。老头对你大叫。所有的威胁和虚张声势都不见了。他近乎急躁地求你别伤害那个哥布林。但你就是不听，把剑捅进了绿皮怪物的胸膛。它举起锁链，用细长恶心的手指抓着它。它眼中的光逐渐消失了，力量也随之减弱。你抽出剑，把血擦在了裤子上。悲痛好像用看不见的力量让他恢复了，老头大喊着，成功站了起来。他拔出匕首扑向你，但%randombrother%用自己的匕首阻止了他，把刀插进了他胸腔下方。血液随着他生命最后的跳动溅满了刀柄。老头的膝盖弯曲滑倒了，他紧紧抓着杀手的手臂。%SPEECH_ON%残忍的生物……残忍的……%SPEECH_OFF%他倒在了地板上。你叫战团搜查小屋，把能拿的都拿走。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "安息吧，隐士。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(-1);
				local item = this.new("scripts/items/weapons/light_crossbow");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				item = this.new("scripts/items/weapons/dagger");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/supplies/roots_and_berries_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_25.png[/img]你一直看着那个哥布林，问老头为什么要把绿皮怪物锁在小屋里。隐士哭倒在地板上。%SPEECH_ON%他是我的朋友！我唯一的朋友！%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "你疯了，隐士。疯了！",
					function getResult( _event )
					{
						return "G";
					}

				},
				{
					Text = "谁会把朋友锁起来啊？",
					function getResult( _event )
					{
						return "H";
					}

				},
				{
					Text = "那个哥布林应该获得自由去找自己真正的朋友！",
					function getResult( _event )
					{
						return "I";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_25.png[/img]你从小屋里退出来，蹲在老头面前。他蠕动着乞求。%SPEECH_ON%求求你，别杀他！%SPEECH_OFF%他已经疯了，你也没什么好说的。他在门廊的地板上啜泣，呼吸把木屑吹了起来。最终他放缓了呼吸冷静下来。%SPEECH_ON%你说的对。我脑子不太清楚。几天前我在陷阱里发现了这个哥布林，然后把他带了回来，治好了他。我在这里没有同伴。我很寂寞，你理解吧。%SPEECH_OFF%你拿起弓弩，装好箭给了老头。%SPEECH_ON%你行吗？%SPEECH_OFF%老头盯着弓弩。眨了好几次眼然后点头。你的佣兵让他站起来。他拿着弓弩走进了小屋。他瞄准得摇摇晃晃，还不停自言自语地道歉。哥布林蜷缩成了一个球，苍白的双手护着自己。%SPEECH_ON%对不起。很对不起。%SPEECH_OFF%老头准备射击，手指扣在扳机上，把弓弩放在下巴下，然后发射。他倒在了地板上，箭矢撞到天花板发出砰的一声，些微鲜血从羽毛上滴下来。你摇着头走进了小屋，亲自杀了哥布林。结束了，你叫战团搜查小屋，把能拿的都拿走。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "该死的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/weapons/light_crossbow");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/supplies/roots_and_berries_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "H",
			Text = "[img]gfx/ui/events/event_25.png[/img]出于谨慎，你回到了老头身边。你捡起锁链激怒了它，问老头道。%SPEECH_ON%被你锁起来的朋友？如果它真是你的朋友，你就不需要锁链，不是吗？%SPEECH_OFF%隐士耸耸肩。%SPEECH_ON%对。放开我，我能证明他是真正的朋友。%SPEECH_OFF%你让他站起来‘证明’。他拍拍衣服上的灰尘，走进了小屋。锁链松了一点，因为哥布林走远了一点。隐士在绿皮怪物面前蹲下来，伸出一只手。%SPEECH_ON%嘿，伙计。%SPEECH_OFF%他松开了绿皮怪物，哥布林咆哮着冲上去，一口咬在老头脸上。你冲进小屋，踢开了哥布林。它撞到角落里，血肉挂在它嘴边。%randombrother%一剑捅穿了它的脸。老头叫了出来，他的脸血肉模糊。%SPEECH_ON%你说的对，我知道那是真的，但我心里……很痛苦。%SPEECH_OFF%近一点看，你发现他鼻子的位置变成了渗血的伤口。隐士蜷缩成了一团，他指着小屋。%SPEECH_ON%在地板下面，尘埃飞舞的地方。我已经用不上它了。%SPEECH_OFF%你点点头，叫%randombrother%帮帮他。剩下的人开始撬地板，看看下面是什么。拿到他们需要的东西以后，你说该离开了。隐士回到了摇椅旁坐下来。他双手朝上放在膝盖上，血从手指上流下来，而化脓的地方流的血更多。你能听到他每次呼吸时险些阻塞的声音。%SPEECH_ON%我应该躲好的。那才是我一直以来的做法。我为什么不躲呢？%SPEECH_OFF%",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "冷静点。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				if (this.World.Assets.getMedicine() >= 2)
				{
					this.World.Assets.addMedicine(-2);
					this.List.push({
						id = 10,
						icon = "ui/icons/asset_medicine.png",
						text = "你失去了[color=" + this.Const.UI.Color.NegativeEventValue + "]-2[/color] 医疗物资。"
					});
				}

				local r = this.Math.rand(1, 4);
				local item;

				if (r == 1)
				{
					item = this.new("scripts/items/weapons/named/named_axe");
				}
				else if (r == 2)
				{
					item = this.new("scripts/items/weapons/named/named_spear");
				}
				else if (r == 3)
				{
					item = this.new("scripts/items/helmets/named/wolf_helmet");
				}
				else if (r == 4)
				{
					item = this.new("scripts/items/armor/named/black_leather_armor");
				}

				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "I",
			Text = "[img]gfx/ui/events/event_25.png[/img]你重新回到小屋外，向那男人喊道。%SPEECH_ON%你他妈以为自己在做什么？如果放了那玩意儿，它就会跑到最近的绿皮怪物营地，然后带领他们侵犯这片土地！%SPEECH_OFF%那个老人对锁链点了点头。%SPEECH_ON%我的好伙伴是很友好的，你不必担心，陌生人。你根本不了解他以及他的个性！%SPEECH_OFF%你一拳打倒了那个人，蹲了下来，好让他听清你说的话。%SPEECH_ON%那玩意儿不是你的伙伴。它很危险。%SPEECH_ON%你对%randombrother%点了点头，他走进小屋，干净利落地杀死了那个哥布林。老人哭喊起来，鲜血流淌在唇齿间。%SPEECH_ON%为什么要这么做？他难道冒犯过你什么吗？难道你毫无荣誉可言吗，竟然杀死了他这样可怜的生物？%SPEECH_OFF%你朝那个疯子摇了摇头，然后给剩下的战团成员下令，让他们散开去收集物资。收集得差不多后，你果断离开了那个老人。",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "真是个疯子。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/weapons/light_crossbow");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/weapons/knife");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/supplies/roots_and_berries_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
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

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d <= 5)
			{
				return;
			}
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (!bro.getSkills().hasSkillOfType(this.Const.SkillType.TemporaryInjury))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.HurtBro = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"hurtbro",
			this.m.HurtBro.getName()
		]);
	}

	function onClear()
	{
		this.m.HurtBro = null;
	}

});

