this.undead_frozen_pond_event <- this.inherit("scripts/events/event", {
	m = {
		Lightweight = null,
		Other = null
	},
	function create()
	{
		this.m.ID = "event.undead_frozen_pond";
		this.m.Title = "路上…";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_08.png[/img]你穿越寒冷的废物，来到结冰池塘的边上。%randombrother% 发现有东西从它中间伸出。你知道那是个下半身被冻住的骑士，但是上半身还在移动。眼睛发亮，长满冻疮的黝黑手指紧紧抓着。它的下巴被冻在一起，肌肉像是腐朽的、半透明的肌腱。\n\n %randombrother%带着冰冷的脸指向巨大的亡灵。%SPEECH_ON%Hey, look!那混蛋有一把巨大的古剑。也许值得试着去拿？%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "有志愿者吗？",
					function getResult( _event )
					{
						if (this.Math.rand(1, 100) <= 50)
						{
							return "Good";
						}
						else
						{
							return "Bad";
						}
					}

				}
			],
			function start( _event )
			{
				if (_event.m.Lightweight != null)
				{
					this.Options.push({
						Text = "你很快站起来，%lightweightfull%。试试看？",
						function getResult( _event )
						{
							return "Lightweight";
						}

					});
				}

				this.Options.push({
					Text = "这不值得。",
					function getResult( _event )
					{
						return 0;
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "Good",
			Text = "[img]gfx/ui/events/event_08.png[/img]%chosenbrother% 选择去试试获得死亡骑士的剑。他踏入池塘的第一步，冰冻表面的脆弱点就发出了声音。他再次测试他的立足点。冰块移动，发出声音，但是没有破裂。每走一步，佣兵都会衡量自己的重量，冰层崩溃的可能性——同时，确保自己不会踩到散落的尸体。 \n\n 他成功到达了亡灵骑士。冰柱吊着剑，刀刃本身裹在一层冰里。佣兵抓起刀刃猛拉。亡灵骑士的手臂向前摇晃，然后在肘部断裂，使得佣兵一屁股滑倒。他滑倒边上，你的人帮他站起来。需要加热把冰融化，这武器绝对是可以利用的。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "做得好。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Other.getImagePath());
				local item = this.new("scripts/items/weapons/greatsword");
				item.setCondition(11.0);
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Bad",
			Text = "[img]gfx/ui/events/event_08.png[/img]%chosenbrother% 试了试冰面，把一只脚放在池塘边缘。婉转的回声穿过池塘寒冷的薄弱点，仿佛有人在封装的表面打水漂。他回头看着队伍摇摇头。%SPEECH_ON%似乎没问题。%SPEECH_OFF%他的下一步送他进入了破碎的冰里。碎片裂成了V形，当他伸手去抓的时候割到了手。人们快速地扔给他绳子把他拉出来。\n\n %chosenbrother% 满身血迹地颤抖着，裹着毯子摇头。%SPEECH_ON%这真是糟透了。糟糕的主意。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你已经尽力了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Other.getImagePath());
				local injury = _event.m.Other.addInjury([
					{
						ID = "injury.split_hand",
						Threshold = 0.5,
						Script = "injury/split_hand_injury"
					}
				]);
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Other.getName() + " suffers " + injury.getNameOnly()
					}
				];
				local effect = this.new("scripts/skills/injury/sickness_injury");
				_event.m.Other.getSkills().add(effect);
				this.List.push({
					id = 10,
					icon = effect.getIcon(),
					text = _event.m.Other.getName() + " is sick"
				});
			}

		});
		this.m.Screens.push({
			ID = "Lightweight",
			Text = "[img]gfx/ui/events/event_08.png[/img]%lightweight% 向前走。%SPEECH_ON%冰？冰不算什么。你可以向这样滑过去。%SPEECH_OFF%没有一丝停留，这人跳到冰冻的池塘上，滑过冰面。裂痕在他身后快速地出现，但他还是很镇定。他在亡灵骑士旁边晃动，抓住冰冻的剑。亡灵在手臂断掉的时候发出了呻吟。那人欢快地滑冰回到池塘边缘，把剑给你。%otherbrother% 向前走，裂开了亡灵的冰冻手臂，就像打破了蟹爪一样。%SPEECH_ON%你想看看那个吗？%SPEECH_OFF%他把手指压成粉碎，这粉末状的遗体里有一个图章。剑和珠宝，这个结果怎么能不喜欢？",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "太棒了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Lightweight.getImagePath());
				local item = this.new("scripts/items/weapons/greatsword");
				item.setCondition(11.0);
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + _event.getArticle(item.getName()) + item.getName()
				});
				item = this.new("scripts/items/loot/signet_ring_item");
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
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Snow)
		{
			return;
		}

		if (currentTile.HasRoad)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local nearTown = false;

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(currentTile) <= 6)
			{
				nearTown = true;
				break;
			}
		}

		if (nearTown)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates_lightweight = [];
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getCurrentProperties().getInitiative() >= 130)
			{
				candidates_lightweight.push(bro);
			}
			else
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Lightweight = candidates_lightweight[this.Math.rand(0, candidates_lightweight.len() - 1)];
		this.m.Other = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = 20;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"chosenbrother",
			this.m.Other.getNameOnly()
		]);
		_vars.push([
			"otherbrother",
			this.m.Other.getNameOnly()
		]);
		_vars.push([
			"lightweight",
			this.m.Lightweight != null ? this.m.Lightweight.getNameOnly() : ""
		]);
		_vars.push([
			"lightweightfull",
			this.m.Lightweight != null ? this.m.Lightweight.getName() : ""
		]);
	}

	function onClear()
	{
		this.m.Lightweight = null;
		this.m.Other = null;
	}

});

