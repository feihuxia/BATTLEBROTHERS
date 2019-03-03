this.hedgeknight_vs_hedgeknight_event <- this.inherit("scripts/events/event", {
	m = {
		HedgeKnight1 = null,
		HedgeKnight2 = null,
		NonHedgeKnight = null,
		Monk = null
	},
	function create()
	{
		this.m.ID = "event.hedgeknight_vs_hedgeknight";
		this.m.Title = "营地…";
		this.m.Cooldown = 40.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_05.png[/img]%nonhedgeknight%冲进你的敞篷，差点弄倒了一根桩子把整个帐篷弄倒。他脸上的汗珠滴到了你的地图上。你盯着那个男人然后问他想要做什么。他解释道雇佣骑士%hedgeknight1%和%hedgeknight2%正在争斗。他们两人都拿起了武器，准备互相厮杀。战团中两个最大型的人相互争斗肯定对……呃，大家来说都不是好事。你迅速赶到了现场。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "带我去看他们。",
					function getResult( _event )
					{
						return "B";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.NonHedgeKnight.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_35.png[/img]你看到%hedgeknight1%手上拿着一把大剑，%hedgeknight2%耍着一把巨斧。大部分人都逃离了现场。%nonhedgeknight%解释道两个人｛两个人在一次长矛比赛上的账还没算完 | 以前在战场上以敌对的身份见过，现在想要继续过去的战斗 | 想要用传统的生死对决解决二人之间的纷争｝。另一个兄弟站了出来，请求雇佣骑士放下分歧，但是%hedgeknight2%把他扔到了一边。他们是全能和恐怖的魔像，也许应该制止这场纷争？",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "强者胜。",
					function getResult( _event )
					{
						return _event.m.Monk == null ? "C1" : "C2";
					}

				},
				{
					Text = "听我说，把这股劲省下来用在战场上！",
					function getResult( _event )
					{
						return _event.m.Monk == null ? "C3" : "C4";
					}

				},
				{
					Text = "每人1000克朗，立即停下来！",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight1.getImagePath());
				this.Characters.push(_event.m.HedgeKnight2.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C1",
			Text = "[img]gfx/ui/events/event_35.png[/img]%nonhedgeknight%呼唤着你，请求你制止这场战斗。两个雇佣骑士四目相向，胸口沉重地喘着气。你表示不屑一顾。骑士点点头，然后相互冲锋。碰撞声音很大，金属盔甲纷纷震裂，骨头破碎。在砍杀的同时发出咆哮，响亮的如同武器挥击的声音一样。剑抵住了巨斧的斧柄，两个武器同时断裂。雇佣骑士冷酷地看着对方，然后很快扔掉主武器，拿出匕首，相互刺杀着，一同倒在地上。两人都完全不在意自己受的伤。他们放弃了那可怜的小匕首，然后开始用自己的拳头，激烈的打斗中，你甚至看到血液中参杂着脱落的牙齿。\n\n战团又一次看向你请求做出行动，因为很明显两个人肯定是想死战到底。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这要失去控制了。所有人，制止他们！",
					function getResult( _event )
					{
						return "E";
					}

				},
				{
					Text = "咱们来看看到底谁在战斗中最强。",
					function getResult( _event )
					{
						return this.Math.rand(1, _event.m.HedgeKnight1.getLevel() + _event.m.HedgeKnight2.getLevel()) <= _event.m.HedgeKnight1.getLevel() ? "F" : "G";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight1.getImagePath());
				this.Characters.push(_event.m.HedgeKnight2.getImagePath());
				_event.m.HedgeKnight1.addLightInjury();
				_event.m.HedgeKnight2.addLightInjury();
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.HedgeKnight1.getName() + " suffers light wounds"
				});
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.HedgeKnight2.getName() + " suffers light wounds"
				});
			}

		});
		this.m.Screens.push({
			ID = "C3",
			Text = "[img]gfx/ui/events/event_35.png[/img]两个雇佣骑士站在那里，眼里只有对手，完全无视你的话，重重地喘息着。过了一小会儿，他们又朝着彼此冲锋。碰撞声音很大，金属盔甲纷纷震裂，骨头破碎。在砍杀的同时发出咆哮，响亮的如同武器挥击的声音一样。剑抵住了巨斧的斧柄，两个武器同时断裂。雇佣骑士冷酷地看着对方，然后很快扔掉主武器，拿出匕首，相互刺杀着，一同倒在地上。两人都完全不在意自己受的伤。他们放弃了那可怜的小匕首，然后开始用自己的拳头，激烈的打斗中，你甚至看到血液中参杂着脱落的牙齿。\n\n战团又一次看向你请求做出行动，因为很明显两个人肯定是想死战到底。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这要失去控制了。所有人，制止他们！",
					function getResult( _event )
					{
						return "E";
					}

				},
				{
					Text = "咱们来看看到底谁在战斗中最强。",
					function getResult( _event )
					{
						return this.Math.rand(1, _event.m.HedgeKnight1.getLevel() + _event.m.HedgeKnight2.getLevel()) <= _event.m.HedgeKnight1.getLevel() ? "F" : "G";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight1.getImagePath());
				this.Characters.push(_event.m.HedgeKnight2.getImagePath());
				_event.m.HedgeKnight1.addLightInjury();
				_event.m.HedgeKnight2.addLightInjury();
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.HedgeKnight1.getName() + " suffers light wounds"
				});
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.HedgeKnight2.getName() + " suffers light wounds"
				});
			}

		});
		this.m.Screens.push({
			ID = "C2",
			Text = "[img]gfx/ui/events/event_35.png[/img]%nonhedgeknight%呼唤着你，请求你制止这场战斗。两个雇佣骑士四目相向，胸口沉重地喘着气。你表示不屑一顾。骑士点点头，然后相互冲锋。碰撞声音很大，金属盔甲纷纷震裂，骨头破碎。在砍杀的同时发出咆哮，响亮的如同武器挥击的声音一样。剑抵住了巨斧的斧柄，两个武器同时断裂。雇佣骑士冷酷地看着对方，然后很快扔掉主武器，拿出匕首，相互刺杀着，一同倒在地上。两人都完全不在意自己受的伤。他们放弃了那可怜的小匕首，然后开始用自己的拳头，激烈的打斗中，你甚至看到血液中参杂着脱落的牙齿。\n\n战团又一次看向你请求做出行动，因为很明显两个人肯定是想死战到底。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这要失去控制了。所有人，制止他们！",
					function getResult( _event )
					{
						return "E";
					}

				},
				{
					Text = "咱们来看看到底谁在战斗中最强。",
					function getResult( _event )
					{
						return this.Math.rand(1, _event.m.HedgeKnight1.getLevel() + _event.m.HedgeKnight2.getLevel()) <= _event.m.HedgeKnight1.getLevel() ? "F" : "G";
					}

				},
				{
					Text = "%monk%僧侣！你能想出一个和平的解决办法吗？",
					function getResult( _event )
					{
						return "H";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight1.getImagePath());
				this.Characters.push(_event.m.HedgeKnight2.getImagePath());
				_event.m.HedgeKnight1.addLightInjury();
				_event.m.HedgeKnight2.addLightInjury();
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.HedgeKnight1.getName() + " suffers light wounds"
				});
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.HedgeKnight2.getName() + " suffers light wounds"
				});
			}

		});
		this.m.Screens.push({
			ID = "C4",
			Text = "[img]gfx/ui/events/event_35.png[/img]两个雇佣骑士站在那里，眼里只有对手，完全无视你的话，重重地喘息着。过了一小会儿，他们又朝着彼此冲锋。碰撞声音很大，金属盔甲纷纷震裂，骨头破碎。在砍杀的同时发出咆哮，响亮的如同武器挥击的声音一样。剑抵住了巨斧的斧柄，两个武器同时断裂。雇佣骑士冷酷地看着对方，然后很快扔掉主武器，拿出匕首，相互刺杀着，一同倒在地上。两人都完全不在意自己受的伤。他们放弃了那可怜的小匕首，然后开始用自己的拳头，激烈的打斗中，你甚至看到血液中参杂着脱落的牙齿。\n\n战团又一次看向你请求做出行动，因为很明显两个人肯定是想死战到底。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这要失去控制了。所有人，制止他们！",
					function getResult( _event )
					{
						return "E";
					}

				},
				{
					Text = "咱们来看看到底谁在战斗中最强。",
					function getResult( _event )
					{
						return this.Math.rand(1, _event.m.HedgeKnight1.getLevel() + _event.m.HedgeKnight2.getLevel()) <= _event.m.HedgeKnight1.getLevel() ? "F" : "G";
					}

				},
				{
					Text = "%monk%僧侣，你能想出一个和平的解决办法吗？",
					function getResult( _event )
					{
						return "H";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight1.getImagePath());
				this.Characters.push(_event.m.HedgeKnight2.getImagePath());
				_event.m.HedgeKnight1.addLightInjury();
				_event.m.HedgeKnight2.addLightInjury();
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.HedgeKnight1.getName() + " suffers light wounds"
				});
				this.List.push({
					id = 10,
					icon = "ui/icons/days_wounded.png",
					text = _event.m.HedgeKnight2.getName() + " suffers light wounds"
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_04.png[/img]你拿出一个装满金币的背包。两个雇佣骑士看了过来，金币叮叮当当的声响让人很难错过。%SPEECH_ON%给你们每人1000克朗，好吗？%SPEECH_OFF%两人交换了个眼神。他们耸耸肩。你点点头。%SPEECH_ON%好了，但是这种事情以后不能再发生了，明白了吗？%SPEECH_OFF%两人又点点头，走了过来，毫无羞耻地接受了克朗。有些兄弟们因为这两个人只是停止战斗就拿到了钱而感到有些恼火。雇佣骑士小气地停止了争斗，对他们而言数钱要比彼此残杀重要的多。你只是希望他们拿到的数量都一样多，以免这个‘庆典’会重新开始。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "这最好能持续下去。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight1.getImagePath());
				this.Characters.push(_event.m.HedgeKnight2.getImagePath());
				this.World.Assets.addMoney(-2000);
				this.List = [
					{
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "你失去了[color=" + this.Const.UI.Color.NegativeEventValue + "]2000[/color]克朗"
					}
				];
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.HedgeKnight1.getID() || bro.getID() == _event.m.HedgeKnight2.getID())
					{
						continue;
					}

					if (bro.getSkills().hasSkill("trait.greedy"))
					{
						bro.worsenMood(2.0, "Angry about you bribing men to stop their fight");
					}
					else if (this.Math.rand(1, 100) <= 50)
					{
						bro.worsenMood(1.0, "Concerned about you bribing men to stop their fight");
					}

					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[bro.getMoodState()],
						text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_35.png[/img]你看到的够多了，命令人进行干预。他们犹豫了一下，但是你很快提醒他们是有合约约束的。你的手下拿上大块的防水布和毯子、一些锅还有几个水桶。他们的策略很明显：用桶扣在雇佣骑士的脑袋上，短时间内挡住他们的视线，然后把所有东西扔过去。手下们就像跟公牛摔跤一样对付两个雇佣骑士，有几个被扔到空中，一个兄弟脸上被踢了一脚，门牙都被踢掉了。另一个被一同压在毯子下面，在两个雇佣骑士之间成为了可怜的出气筒。\n\n最终，两个人冷静了下来，战斗终于结束。他们小气地平息了下来，以免你让手下拿起真正的武器来制止这场争斗。战团其他的人恢复了过来，就好像是在台风过后一样重新振作了起来。你清点了一下受伤的情况，然后开始提供帮助。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "终于，结束了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight1.getImagePath());
				this.Characters.push(_event.m.HedgeKnight2.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.HedgeKnight1.getID() || bro.getID() == _event.m.HedgeKnight2.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 60)
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 75)
					{
						bro.addLightInjury();
						this.List.push({
							id = 10,
							icon = "ui/icons/days_wounded.png",
							text = bro.getName() + " suffers light wounds"
						});
					}
					else
					{
						local injury = bro.addInjury(this.Const.Injury.Brawl);
						this.List.push({
							id = 10,
							icon = injury.getIcon(),
							text = bro.getName() + " suffers " + injury.getNameOnly()
						});
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_35.png[/img]你坐在一根树桩上观看了这场战斗的剩余部分。两人一边在地上翻滚，一边扭打着。他们出拳的力道足以干翻一匹马。最终，%hedgeknight1%骑在了%hedgeknight2%的身上。在扫视了一下周围后，%hedgeknight1%顺势抓起一块石头朝他的对手头上砸去。瞬间，一块皮肤就这样被打飞了，底下的红白相间血肉也显现了出来。石头再一次落下。人的头颅已无法承受这样的重击，碎裂的骨片四散飞溅。%hedgeknight2%的身体开始抽搐，似乎已经命不久矣。%hedgeknight1%将自己的拳头打入对手的头颅之中，掏出了一大把无法描述的、血糊糊的物体。你瞬间感到一阵恶心，旁边围观的一些人也开始呕吐。\n\n%hedgeknight1%站了起来，然后将自己手中的战利品丢到了一旁的草丛里。他擦了擦自己的前额，然后就说了一个词。%SPEECH_ON%完事儿。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "至少，%hedgeknight2%也算是战死了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight1.getImagePath());
				local dead = _event.m.HedgeKnight2;
				local fallen = {
					Name = dead.getName(),
					Time = this.World.getTime().Days,
					TimeWithCompany = this.Math.max(1, dead.getDaysWithCompany()),
					Kills = dead.getLifetimeStats().Kills,
					Battles = dead.getLifetimeStats().Battles,
					KilledBy = "Killed in a duel by " + _event.m.HedgeKnight1.getName()
				};
				this.World.Statistics.addFallen(fallen);
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.HedgeKnight2.getName() + " has died"
				});
				_event.m.HedgeKnight2.getItems().transferToStash(this.World.Assets.getStash());
				this.World.getPlayerRoster().remove(_event.m.HedgeKnight2);
				local injury = _event.m.HedgeKnight1.addInjury(this.Const.Injury.Brawl);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.HedgeKnight1.getName() + " suffers " + injury.getNameOnly()
				});

				if (this.Math.rand(1, 2) == 1)
				{
					local v = this.Math.rand(1, 2);
					_event.m.HedgeKnight1.getBaseProperties().MeleeSkill += v;
					this.List.push({
						id = 16,
						icon = "ui/icons/melee_skill.png",
						text = _event.m.HedgeKnight1.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + v + "[/color] 近战技能"
					});
				}
				else
				{
					local v = this.Math.rand(1, 2);
					_event.m.HedgeKnight1.getBaseProperties().MeleeDefense += v;
					this.List.push({
						id = 16,
						icon = "ui/icons/melee_defense.png",
						text = _event.m.HedgeKnight1.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + v + "[/color] 近战防御"
					});
				}

				_event.m.HedgeKnight1.getSkills().update();
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_35.png[/img]你找到附近一处树桩正准备坐下，却发现两个骑士一边扭打着一边朝你冲过来。于是你连忙起身跳开。%hedgeknight1%一头扎进了你刚才的“座位”中。他迅速转身，面朝他的对手。然而，他眼前迎来的却是%hedgeknight2%的鞋帮。血肉和皮革，在发生了碰撞之后，发出了一种诡异的响声。%hedgeknight1%一口吐出了自己被打掉的牙齿，又向%hedgeknight2%发出了嘲讽，问他是不是已经尽全力了。作为回应，%hedgeknight2%朝他的头上一脚又一脚地踹去。每一脚之后，%hedgeknight1%的样子都变得更加惨不忍睹。他的鼻子已被踩扁，脸上也是皮开肉绽，嘴中的牙齿也被打得七零八落，牙龈有如被剥去指甲的手指一般。\n\n最后，殴打终于结束了，而四下散落的碎骨片看起来就像是冬天树上落下积雪。你一脸厌恶地将目光投向别处，但你的一些兄弟已经受不了了，其中一个开始呕吐。为了了解具体情况，你朝打斗现场望去，映入你视线的是%hedgeknight2%那已经深深陷入对手头颅中的靴子。他一边咒骂着，一边试图将靴子拔出来。\n\n这靴子显然已经被牢牢卡住，他不得不使出全身力气才连脚带靴一并拔出。在四下环顾之后，他像个玩了一整天的顽童一般，开始在草丛中拖行着自己的靴子，试图擦掉靴子上沾染的血迹。他像剥玉米一样将附着在靴子上的脑浆剔除，然后拍了拍自己的肚子，问了一声“有没有人饿了”，最后拿起一盘食物走回了自己的帐篷。\n\n那天晚上，出于为队伍的安全考虑，你动了处决%hedgeknight2%的念头。但在看到他像一个孩子般熟睡的样子后，你最终放弃了这个想法。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "至少，%hedgeknight1%也算是战死了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.HedgeKnight2.getImagePath());
				local dead = _event.m.HedgeKnight1;
				local fallen = {
					Name = dead.getName(),
					Time = this.World.getTime().Days,
					TimeWithCompany = this.Math.max(1, dead.getDaysWithCompany()),
					Kills = dead.getLifetimeStats().Kills,
					Battles = dead.getLifetimeStats().Battles,
					KilledBy = "Killed in a duel by " + _event.m.HedgeKnight2.getName()
				};
				this.World.Statistics.addFallen(fallen);
				this.List.push({
					id = 13,
					icon = "ui/icons/kills.png",
					text = _event.m.HedgeKnight1.getName() + " has died"
				});
				_event.m.HedgeKnight1.getItems().transferToStash(this.World.Assets.getStash());
				this.World.getPlayerRoster().remove(_event.m.HedgeKnight1);
				local injury = _event.m.HedgeKnight2.addInjury(this.Const.Injury.Brawl);
				this.List.push({
					id = 10,
					icon = injury.getIcon(),
					text = _event.m.HedgeKnight2.getName() + " suffers " + injury.getNameOnly()
				});

				if (this.Math.rand(1, 2) == 1)
				{
					local v = this.Math.rand(1, 2);
					_event.m.HedgeKnight2.getBaseProperties().MeleeSkill += v;
					this.List.push({
						id = 16,
						icon = "ui/icons/melee_skill.png",
						text = _event.m.HedgeKnight2.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + v + "[/color] 近战技能"
					});
				}
				else
				{
					local v = this.Math.rand(1, 2);
					_event.m.HedgeKnight2.getBaseProperties().MeleeDefense += v;
					this.List.push({
						id = 16,
						icon = "ui/icons/melee_defense.png",
						text = _event.m.HedgeKnight2.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + v + "[/color] 近战防御"
					});
				}

				_event.m.HedgeKnight2.getSkills().update();
			}

		});
		this.m.Screens.push({
			ID = "H",
			Text = "[img]gfx/ui/events/event_05.png[/img]僧侣点了点头，然后平静地走到两个人中间。他高举双手，并不断比划着什么，似乎是在模仿某种古老的宗教仪式。他开始诉说神明是如何审判人的一生。他还说，有一些神认为这场战斗是好的，而其他多数神则不这么认为。最重要的是，只要一个人真的想要去战斗，那么他在战死后必定会有一个归宿。不过，如果一个人杀死了另一个人，那被杀的一方会在后世受到更多优待，而胜利的一方则不会。这是因为暴力只不过是胜利者用来满足自己虚荣心的手段罢了。令人惊讶的是，这些宗教训戒居然奏效了。僧侣要他们多交流、少动粗，他们也照做了。最后他们三个人一边说笑着一边走开了。至于战团中的其他人，他们无不为冲突的和平解决而感到庆幸。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "感谢神明。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Monk.getImagePath());

				if (!_event.m.Monk.getTags().has("resolve_via_hedgeknight"))
				{
					_event.m.Monk.getTags().add("resolve_via_hedgeknight");
					_event.m.Monk.getBaseProperties().Bravery += 2;
					_event.m.Monk.getSkills().update();
					this.List = [
						{
							id = 16,
							icon = "ui/icons/bravery.png",
							text = _event.m.Monk.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+2[/color] 决心"
						}
					];
				}
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getMoney() < 2000)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.hedge_knight")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() < 2 || candidates.len() == brothers.len())
		{
			return;
		}

		this.m.HedgeKnight1 = candidates[this.Math.rand(0, candidates.len() - 1)];

		do
		{
			this.m.HedgeKnight2 = candidates[this.Math.rand(0, candidates.len() - 1)];
		}
		while (this.m.HedgeKnight2 == null || this.m.HedgeKnight2.getID() == this.m.HedgeKnight1.getID());

		do
		{
			this.m.NonHedgeKnight = brothers[this.Math.rand(0, brothers.len() - 1)];
		}
		while (this.m.NonHedgeKnight.getID() == this.m.HedgeKnight1.getID() || this.m.NonHedgeKnight.getID() == this.m.HedgeKnight2.getID() || this.m.NonHedgeKnight.getBackground().getID() == "background.hedge_knight");

		local candidates_monk = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.monk")
			{
				candidates_monk.push(bro);
			}
		}

		if (candidates_monk.len() != 0)
		{
			this.m.Monk = candidates_monk[this.Math.rand(0, candidates_monk.len() - 1)];
		}

		this.m.Score = candidates.len() * 6;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"hedgeknight1",
			this.m.HedgeKnight1.getName()
		]);
		_vars.push([
			"hedgeknight2",
			this.m.HedgeKnight2.getName()
		]);
		_vars.push([
			"nonhedgeknight",
			this.m.NonHedgeKnight.getName()
		]);
		_vars.push([
			"monk",
			this.m.Monk != null ? this.m.Monk.getName() : ""
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.HedgeKnight1 = null;
		this.m.HedgeKnight2 = null;
		this.m.NonHedgeKnight = null;
		this.m.Monk = null;
	}

});

