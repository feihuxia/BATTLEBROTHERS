this.last_stand_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		IsPlayerAttacking = true
	},
	function create()
	{
		this.contract.create();
		local r = this.Math.rand(1, 100);

		if (r <= 70)
		{
			this.m.DifficultyMult = this.Math.rand(95, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}

		this.m.Type = "contract.last_stand";
		this.m.Name = "防御 %objective%";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		this.m.MakeAllSpawnsResetOrdersOnContractEnd = false;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		if (this.m.Home == null)
		{
			this.setHome(this.World.State.getCurrentTown());
		}

		this.m.Flags.set("ObjectiveName", this.m.Origin.getName());
		this.m.Payment.Pool = 1600 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"前往%direction%的%objective%",
					"抵抗亡灵"
				];

				if (this.Math.rand(1, 100) <= this.Const.Contracts.Settings.IntroChance)
				{
					this.Contract.setScreen("Intro");
				}
				else
				{
					this.Contract.setScreen("Task");
				}
			}

			function end()
			{
				this.World.Assets.addMoney(this.Contract.m.Payment.getInAdvance());
				local r = this.Math.rand(1, 100);

				if (r <= 40)
				{
					this.Flags.set("IsUndeadAtTheWalls", true);
				}
				else if (r <= 70)
				{
					this.Flags.set("IsGhouls", true);
				}

				this.Flags.set("Wave", 0);
				this.Flags.set("Militia", 7);
				this.Flags.set("MilitiaStart", 7);
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
					this.Contract.m.Origin.setLastSpawnTimeToNow();
				}
			}

			function update()
			{
				if (this.Contract.m.Origin == null || this.Contract.m.Origin.isNull() || !this.Contract.m.Origin.isAlive())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
					return;
				}
				else if (this.Contract.isPlayerNear(this.Contract.m.Origin, 600) && this.Flags.get("IsUndeadAtTheWalls") && !this.Flags.get("IsUndeadAtTheWallsShown"))
				{
					this.Flags.set("IsUndeadAtTheWallsShown", true);
					this.Contract.setScreen("UndeadAtTheWalls");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerAt(this.Contract.m.Origin) && this.Contract.m.UnitsSpawned.len() == 0)
				{
					this.Contract.setScreen("ADireSituation");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Running_Wait",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"抵抗亡灵守卫%objective%"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
					this.Contract.m.Origin.setLastSpawnTimeToNow();
				}
			}

			function update()
			{
				if (this.Contract.m.Origin == null || this.Contract.m.Origin.isNull() || !this.Contract.m.Origin.isAlive())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Contract.m.UnitsSpawned.len() != 0)
				{
					local contact = false;

					foreach( id in this.Contract.m.UnitsSpawned )
					{
						local e = this.World.getEntityByID(id);

						if (e.isDiscovered())
						{
							contact = true;
							break;
						}
					}

					if (contact)
					{
						if (this.Flags.get("Wave") == 1)
						{
							this.Contract.setScreen("Wave1");
						}
						else if (this.Flags.get("Wave") == 2)
						{
							this.Contract.setScreen("Wave2");
						}
						else if (this.Flags.get("IsGhouls"))
						{
							this.Contract.setScreen("Ghouls");
						}
						else if (this.Flags.get("Wave") == 3)
						{
							this.Contract.setScreen("Wave3");
						}

						this.World.Contracts.showActiveContract();
					}
				}
				else if (this.Flags.get("TimeWaveHits") <= this.Time.getVirtualTimeF())
				{
					if (this.Flags.get("IsGhouls") && this.Flags.get("Wave") == 3)
					{
						this.Flags.set("IsGhouls", false);
						this.Flags.set("Wave", 2);
						this.Contract.spawnGhouls();
					}
					else
					{
						this.Contract.spawnWave();
					}
				}
			}

		});
		this.m.States.push({
			ID = "Running_Wave",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"抵抗亡灵守卫%objective%"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
					this.Contract.m.Origin.setLastSpawnTimeToNow();
				}

				foreach( id in this.Contract.m.UnitsSpawned )
				{
					local e = this.World.getEntityByID(id);

					if (e != null)
					{
						e.setOnCombatWithPlayerCallback(this.onCombatWithPlayer.bindenv(this));
					}
				}
			}

			function update()
			{
				if (this.Contract.m.Origin == null || this.Contract.m.Origin.isNull() || !this.Contract.m.Origin.isAlive())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Contract.m.UnitsSpawned.len() == 0)
				{
					if (this.Flags.get("Wave") < 3)
					{
						local militia = this.Flags.get("MilitiaStart") - this.Flags.get("Militia");
						this.logInfo("militia losses: " + militia);

						if (militia >= 3)
						{
							this.Contract.setScreen("Militia1");
						}
						else if (militia >= 2)
						{
							this.Contract.setScreen("Militia2");
						}
						else
						{
							this.Contract.setScreen("Militia3");
						}
					}
					else
					{
						this.Contract.setScreen("TheAftermath");
					}

					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatWithPlayer( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
				local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
				p.Music = this.Const.Music.UndeadTracks;
				p.CombatID = "ContractCombat";

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull() && this.World.State.getPlayer().getTile().getDistanceTo(this.Contract.m.Origin.getTile()) <= 4)
				{
					p.AllyBanners.push("banner_noble_11");

					for( local i = 0; i < this.Flags.get("Militia"); i = i )
					{
						local r = this.Math.rand(1, 100);

						if (r < 60)
						{
							p.Entities.push({
								ID = this.Const.EntityType.Militia,
								Variant = 0,
								Row = -1,
								Script = "scripts/entity/tactical/humans/militia",
								Faction = 2,
								Callback = null
							});
						}
						else if (r < 85)
						{
							p.Entities.push({
								ID = this.Const.EntityType.Militia,
								Variant = 0,
								Row = -1,
								Script = "scripts/entity/tactical/humans/militia_veteran",
								Faction = 2,
								Callback = null
							});
						}
						else
						{
							p.Entities.push({
								ID = this.Const.EntityType.Militia,
								Variant = 0,
								Row = 2,
								Script = "scripts/entity/tactical/humans/militia_ranged",
								Faction = 2,
								Callback = null
							});
						}

						i = ++i;
					}
				}

				this.World.Contracts.startScriptedCombat(p, this.Contract.m.IsPlayerAttacking, true, true);
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_combatID == "ContractCombat" && _actor.getTags().has("militia"))
				{
					this.Flags.set("Militia", this.Flags.get("Militia") - 1);
				}
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"返回 " + this.Contract.m.Home.getName()
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = false;
				}

				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					this.Contract.setScreen("Success1");
					this.World.Contracts.showActiveContract();
				}
			}

		});
	}

	function createScreens()
	{
		this.importScreens(this.Const.Contracts.NegotiationDefault);
		this.importScreens(this.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_45.png[/img]{你看见%employer%正在帮助一个手拿弓箭的年轻贵族男孩瞄准一个稻草人。他把孩子的背拉直，命令他在放箭钱先深呼吸。业余的弓箭手点了点头，照做了。弓箭被放了出去。它摇晃着，飘离了地面，晃晃悠悠地飞进了一个马厩里面，马儿发出了让人毛骨悚然的惨叫声。回族拍了拍男孩的后背。%SPEECH_ON%相信我，我第一次比这还要糟糕。再接再厉。我过会回来。%SPEECH_OFF%贵族靠近了你，摇了摇头，压低了声音。%SPEECH_ON%事情很紧迫，佣兵。年轻人已经不知道这些日子徘徊着的是什么危险，但是你知道。我们有一个殖民地，%objective%，就在%direction%，那里被……世界的灾祸包围了。我没有空余的人手了，但是还好有你在。去那里，救下村庄，我会好好报答你的！%SPEECH_OFF%  |  %employer%在盯着他的一柄长剑。他将剑拔了出来，凝视着钢铁之上自己脸庞的倒影。%SPEECH_ON%我那时候学使用这些东西的时候，这是用来针对活人的。而现在？人们说着各式各样的死人，绿皮怪物，野兽之类的恐怖故事！%SPEECH_OFF%他将剑猛扔回剑鞘中然后将他和剑鞘一起扔开了。他用手捋着头发。%SPEECH_ON%%SPEECH_ON%%direction%的%objective% 需要你的帮助。你来被那些……那些东西包围了！我不知道它们到底是什么东西，只知道它们在不停地杀戮！我没有剩余的人手了，但是如果你去那里帮助镇子的话我将会好好报答你的！%SPEECH_OFF%  |  你发现%employer%坐在两个用老头的嗓音颤颤巍巍吵架的修士和文士之间。死者已经复苏，道德与死后生活的争辩变得愈演愈烈了。贵族看见了你，马上就跳了起来。他赶紧跑到你这边。争辩还在持续着。%SPEECH_ON%谢天谢地你来了，佣兵。就在%direction%，%objective%正被一只可怖之物的军队包围着。不死怪物都是一些，我没有足够的人手自己去保护村庄了。去那里，保证那些人们的安全，我会好好报答你的！%SPEECH_OFF%  |  你发现%employer%正在监管着一群司仪将一个箱子搬进土里面去。棺材已经被钉牢了，看上去是匆匆茫茫做的：钉子弯掉了，直接穿过了木头，边上还有一些抓痕。看见你之后，贵族就走了过来。%SPEECH_ON%这个盒子里面的居民决定要出来了。杀掉了一个孩子和一条狗。在守卫干掉它之前差点又杀了一个。%SPEECH_OFF%一团黑色液体从棺材底溢了出来。挖墓人跳开了，棺材直接掉进了坟墓里面，发出了重重的碰撞声。%employer%摇了摇头。%SPEECH_ON%现在这些“不死人”哪里都是，我的部队全分散开来了。我刚刚知道%direction%的%objective%也遭到了攻击。佣兵，你能去那里拯救那个村庄吗？%SPEECH_OFF%  |  你看见%employer%正在研究摊在他的桌子上的一大堆书籍。他摇着头，脖子每转一下就又翻了一页。失望着，他匆匆茫茫挥手要你进来。%SPEECH_ON%不要耽搁时间了，佣兵，没时间了。我需要你去%direction%的%objective%。我的探子说那里遭到攻击了，更多该死的“死人”复苏了，如果可以这么说的话。你有兴趣吗？报酬绝对丰富。%SPEECH_OFF%  | 你看见%employer%正在看着一群石匠将切割整齐的石块拼接在一起。他握了握你的手。%SPEECH_ON%在建修道院，佣兵，看上去怎么样？%SPEECH_OFF%看上去不错，但是你指了指路对面又有一个修道院。贵族笑了。%SPEECH_ON%死者又一次在大地上行走了，那些担惊受怕的人们没有足够的地方呆了。听着，我叫你来这里是因为我的部队因为处理这个……不死人的奇怪事件而人手不足了。%direction%有个村庄，%objective%，那里急需帮助。我的探子告诉我说那里遭到了攻击，你看上去应该会有兴趣去拯救那里。当然，会给钱的。%SPEECH_OFF%  |  %employer%，一个财吏和一个指挥官在交谈。财务说有很多克朗，但是指挥官突兀地指出没有人可以付钱去战斗。说曹操斜支撑到，你进入了房间，所有人都开始谈论起你了。%SPEECH_ON%佣兵！急需你的服务！%direction%有一个村庄，%objective%，那里被这些，呃，那些东西攻击了。%SPEECH_OFF%指挥官靠近了贵族，说了那些是什么东西。他靠后了一步。%SPEECH_ON%被这些……“不死人”攻击了。好吧。你愿意娶那里保护这些可怜人吗？%SPEECH_OFF%  |  你最后在%employer%的马厩里面找到了他。他将一个马鞍放在了马背上，很快意识到你离得有点远。%SPEECH_ON%害怕了，是不是？%SPEECH_OFF%耸了耸肩，你告诉他说你从来就不怕这东西。贵族也耸了耸肩，然后骑了上去，将腿放在了马鞍两边。%SPEECH_ON%随便你。我的探子们告诉我说%objective%遇到麻烦了，这些麻烦试一大群不死人，我觉得他们不是给这些村名去送牛奶的。如果你去那里帮助保护村庄的话，就有一大袋钱币等你回来了。%SPEECH_OFF%  |  %employer%在他的堡垒上踱步。他身边的护卫处于一种不寻常的紧张状态，背挺得笔直，眼睛寻找着潜在的危险。看见你之后，贵族挥挥手示意你过来。你们一起盯着城墙跺外。大地在你眼前扩张，巨大的森林变成了小点，山岭成了小小的箭头，鸟儿们以紧密的阵型飞翔着。%SPEECH_ON% %direction%有一个叫做%objective%的地方。信使告诉我说那里被某种不可思议的部队，不死人部队攻击了。对，相当不可思议。不管是什么在攻击，我都没有剩余的人手去处理这事件。但是你，佣兵，这个事件需要你的帮助。你感兴趣吗？%SPEECH_OFF%  |  你看见%employer%在和一个憔悴的文士一起盯着躺在一块石头上的无头尸体。头在角落里，眼球斜视，钢管从它的头骨中插了出去。看见你之后，贵族挥挥手示意。%SPEECH_ON%别害怕，佣兵。我肯定你已经知道了，死者已经复苏，这是个需要探讨的大问题。%SPEECH_OFF%文士突然打断。%SPEECH_ON%或者应该问它们是怎么……%SPEECH_OFF%笑着，贵族继续了。%SPEECH_ON%不管怎么说，%direction%的%objective%正被这些怪物，前人类攻击了。但是我没有人手去处理了。但是，你，很适合这份工作。你愿意接受吗？%SPEECH_OFF%  |  %employer%正在倾听着一名文士的低语。文士用敌视的双眼瞟了你一眼，然后继续。等他说完知乎，两个人都点了点头，老人离开了。他走出去的时候一眼都没有看你。%employer%叫你。%SPEECH_ON%你好啊，佣兵！现在是生死时刻。我的人正分布在大陆上处理各种怪奇恶物。我肯定你已经听说了，但是“死者”那些东西，复苏了。而且他们正在袭击%direction%的%objective%。我手下没有多余人手了，就靠你了，佣兵。你愿意娶拯救这个村庄吗？%SPEECH_OFF%  |  %employer%正在听着一群农民的乞求。你在对话的结尾，贵族愤怒地挥手让他们退下的时候来了。当那些农民吵吵嚷嚷起来之后，守卫们靠近了把他们送了出去，现在已经安安静静了。他们没有抗议就离开了大门，尽管有一个农民瞟了你一眼，然后做了个“救救我们”的口型之后就离开了。%employer%挥了挥手手。%SPEECH_ON%诶呀呀，这不是佣兵吗！时机正好，我见钱眼开的朋友。我有个村庄，%objective%，就在%direction%，继续帮助。那里现在正在，被不死人围攻。如果你那里帮助守护那里的话，有一大袋克朗等着你回来。怎么说？%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{这事对你值多少？ |  价格不合理的话，我们可不会守卫%objective%…}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。 |  恐怕%objective%得靠他们自己了。}",
					function getResult()
					{
						this.World.Contracts.removeContract(this.Contract);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "UndeadAtTheWalls",
			Title = "%objective%…",
			Text = "[img]gfx/ui/events/event_29.png[/img]{接近%objective%的时候，%randombrother%突然大声叫唤。%SPEECH_ON%长官，快来！%SPEECH_OFF%你冲向他身边，看向前方。城镇被亡灵包围了起来，哀嚎遍野，仿若一片苍茫的白色海洋。唯有杀出一条血路，%companyname%才能进去。 |  一个男人向%companyname%跑来。他抱着一只手臂，头上流着血。他大喊着。%SPEECH_ON%走，快走！这里简直就是一场恐怖剧！%SPEECH_OFF%%randombrother%将陌生人撂倒在地，拔出武器让他不许动。你压下佣兵的手，然后看向前面：%objective%已经被一群亡灵包围了。%companyname%必须迅速行动！ |  你抵达地刚好及时：亡灵已经在攻击%objective%的墙壁了。 |  绕过一条路，你突然停了下来。前方的%objective%已经被一群亡灵包围了。有几只在你近处徘徊着，竟然与亡灵群分离了。%companyname%得杀出一条血路才能进去%objective%。 |  奇怪，%objective%的墙壁竟然是灰色的—不对，那不是木材，亡灵！你感受到恐惧了，这些苍白怪物已经发动攻势了，但是你还有拯救%objective%的时候，得杀出一条血路进去。你拔出利剑，号令%companyname%开始战斗！ |  毫无阵型可言的亡灵已经在%objective%墙壁外四处徘徊了。你能看到守卫者躲在防御设施后小心翼翼地探头观察，尽量不让自己暴露身形。你拔出利剑，号令%companyname%杀出一条血路进入城镇。 |  数只亡灵已经在%objective%大门前了！城门上的卫兵向你挥手，将一根手指放在嘴上，然后指了指下面。似乎这群食尸鬼因为没有察觉到，所以尚未发动攻势？你不太确定，但有点很明确，唯有战斗%companyname%才能进去！ |  好消息是，你发现%objective%仍安然无恙。坏消息是，一群亡灵正在攻击城墙。%companyname%不得不杀出一条血路！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.Contract.spawnUndeadAtTheWalls();
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ADireSituation",
			Title = "%objective%…",
			Text = "[img]gfx/ui/events/event_79.png[/img]{你发现%objective%内的卫兵虽然似乎数周没睡觉了，但是他们仍微笑着。显而易见，至少你来到前门的尴尬旅程对他们来说是种乐子。 |  虽然笨手笨脚，但%companyname%终于穿过了前门。里面的卫兵似乎很开心，仿佛一场惨烈的战斗结束，看到了一幕奇怪的笑话。其中一人拍拍你的肩。%SPEECH_ON%佣兵，那一幕实在太逗了，我的人正需要这样提升士气的东西。多谢。%SPEECH_OFF%  |  环顾一周，你发现卫兵一个个都孱弱而瘦骨嶙峋，而他们守护着已经看似半死不活的城镇居民。泥泞的道路上满是粪便，垃圾和动物尸体。妇孺小孩在一座临时坟场前哭泣：一道沟渠，有写着名字的卷轴。墨水尚未干涸，明显是刚贴上去的亡魂之名。 |  你进入%objective%城门，发现几名卫兵瘦弱的手中握着长矛看守着。他们穿的衣服都是乱的，就像是敞开窗户前的窗帘。饥饿感不言而喻，从咂嘴声和盯着健康的你的眼神就能看得出来。一名卫兵还挺欢迎你的。%SPEECH_ON%虽然我们疲惫而饥饿，但是我们能撑过来的。我们仍能战斗，这点你无需质疑。%SPEECH_OFF%  |  当你进入%objective%时，首先欢迎你到来的是一条狗，它舔着你的腿，在你裤子上嗅来嗅去。一个男人突然拿着棍子，大喊着跑来，很快人和狗沿着泥泞道路跑开，而且两者似乎都咋咋呼呼的。野狗躲闪了饥饿人群的缓慢拦截，然后完全消失了。一名微笑着的卫兵撑着木棍走过来。%SPEECH_ON%你好，佣兵。食物不多了，所以狗肉在一群饿死鬼居住的地方可是抢手货。%SPEECH_OFF%你问他们是否还能战斗，那人笑了。%SPEECH_ON%当然，我们只有战斗了！%SPEECH_OFF%  |  %objective%前门就像遮挡住惨剧地狱的正常面纱。村民们拖着脚步，无事可做，越来越饿。卫兵们说着笑话，仿佛那是食粮一般，手捂着胃部痛苦地笑着。卫兵头目走了过来。他胡子拉碴，疤痕累累，半张着嘴，眼神中透着疲惫。虽然人就近在咫尺，但却感觉他从另一个世界盯着你。%SPEECH_ON%佣兵，你来了真是太好了。我们真的需要你们的帮助。%SPEECH_OFF%  |  你穿过%objective%大门，发现其后静静等着你的就是地狱。士兵们都准备好了，就像疯子操控的骷髅。而村民或是无所事事的站着，或是躺在泥土中，或是一头靠在墙上。孩童站在茅草屋顶上，在稻草总寻觅着虫子。卫兵队长直率地欢迎你。%SPEECH_ON%佣兵，多谢你们前来，但是你们应该待在家里的。%SPEECH_OFF%  |  看门人吃力的推动着，%objective%前门缓慢的打开了。进入城镇的你发现一帮杂役正挖着一个巨坑。他们将尸体扔进洞里，准备用火焚烧。卫兵队长走上前来。%SPEECH_ON%虽然有时候亡者重生，但我们明白尘归尘，土归土就不会了呃，或许也会吧，但至少不会伤害别人了。%SPEECH_OFF%你本来想提及那恶臭，但转念一想，他们应该早就习惯了。 |  %objective%城门后面，你感觉城镇就仿佛已经屈服于亡灵群了。村民漫无目的且意志消沉的拖着脚步走着。几名卫兵在货车旁一家一户的分发着食物。你看到几名卫兵睡在城墙旁，手臂放在雉堞上，还紧紧地握着武器，就像是被仍在角落的傀儡娃娃。卫兵队长走上前来。%SPEECH_ON%佣兵，多谢前来。这里简直是地狱，很多人以为你们不会来了。%SPEECH_OFF%  |  %objective%前门打开，你们走了进去。你看到两名卫兵将一具尸体拖向燃烧着的尸体堆。一名妇女抓着尸体的鞋子，恳求卫兵让她再看最后一眼。卫兵视而不见，将尸体扔进火里，而妇女瘫倒在火葬台前，眼睁睁地看着丈夫在火中燃烧，发出噼里啪啦的声响。卫兵队长走上前来。他拍拍你的肩。%SPEECH_ON%佣兵，还好你们来了。%SPEECH_OFF%  |  穿过%objective%城门后，一个人就抓住了你的衣领。%SPEECH_ON%有吃的吗？嗯？我闻得到，还是说你就是食物？%SPEECH_OFF%一名卫兵用矛的末端将他赶走。那疯子捂着肚子，在眉毛中挑虱子吃，嘴上还咋咋呼呼的。%SPEECH_ON%你们带来了更多剑刃，但我们不需要！%SPEECH_OFF%卫兵将那人带走了，队长走上前来。%SPEECH_ON%别管他。他以前不愁吃的，现在的局势让他变得有点神经质。我们还有些食物，只是得定量配给。佣兵，你们的战力会派上用场的，而且相信我，很快就来临了。%SPEECH_OFF%  |  你穿过%objective%城门，然后就闻到了尸体燃烧的味道。尸体堆还冒着烟，一名卫兵拿着木棍在灰烬中翻动着，仿若站在大坩埚前的大厨。村民站在烧焦的遗体旁，哭泣着举行祭祀仪式。城镇卫兵队长走上前来。%SPEECH_ON%攻势随处都可能发生。亡灵，他们会卷土重来，而我们备受折磨。这里的是一家子。妻子在晚上死了，趁着夜色，不停的吃啊吃啊吃啊。我们烧掉了所有尸体。这也是没办法的事。%SPEECH_OFF%队长奉承地看着你。他露出笑容。%SPEECH_ON%今天怎么样啊？%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们得为即将来临的屠杀做好准备…",
					function getResult()
					{
						this.Flags.set("Wave", 1);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 8.0);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Wave1",
			Title = "%objective%…",
			Text = "[img]gfx/ui/events/event_29.png[/img]{等待会让你丢掉小命，而其他东西会完成任务：亡灵！%objective%的警铃响起，卫兵急匆匆地准备行动。你命令%companyname%做好战斗准备。 |  当你在看兄弟们玩牌时，城镇警铃响起了。你看向修道院，发现有个老人病态地掏出了自己的心脏。听到钟声的卫兵打起精神。城门上响起了喊声。%SPEECH_ON%来了，拿起武器，准备战斗！%SPEECH_OFF%  |  正当你觉得自己已经加入了站在周围居民的行列时，前门突然打开，一名骑着马的侦察兵冲了进来。精疲力竭的马儿瘫倒在泥泞中，骑手摔下马来，在地上滚了几圈。他站起来大喊道。%SPEECH_ON%亡灵来了！我们得做好准备！%SPEECH_OFF%  |  哨所上的人大喊道。%SPEECH_ON%消息来了，小心！%SPEECH_OFF%你看到一支箭矢在空中划过一条弧线，径直落在你几步前的泥泞中。队长打开箭矢上的卷轴。他的嘴唇变得惨白，而后便将纸仍在一边。%SPEECH_ON%佣兵，该做准备了，亡灵要来了。%SPEECH_OFF%他转头看向士兵。%SPEECH_ON%%objective%的卫兵们！准备战斗！%SPEECH_OFF%  |  一名卫兵大声喊道。%SPEECH_ON%开城门，避难者来了！%SPEECH_OFF%一群孩童冲进打开的城门。一个孩子说一群苍白的人要来了。队长看着你。%SPEECH_ON%佣兵，准备作战吧。%SPEECH_OFF%亡灵朝这边来了，准备战斗！ |  一名侦察兵骑着马进入%objective%，马儿的腿上有血，而且尾巴都没了。骑手拖着一只没有手的手臂，而且少了只耳朵和眼睛。队长快步冲上前，说完话侦察兵就昏迷过去了。队长叹着气站了起来。%SPEECH_ON%亡灵要发动攻势了，做好准备！让那匹战马摆脱痛苦吧！%SPEECH_OFF%你点点头，让%companyname%准备迎接战斗。佣兵在做准备的时候，一个身着屠夫服饰的人走向前用切肉刀将那匹马砍死了。队长拍拍你的肩。%SPEECH_ON%嘿，如果想熬过去的话，至少现在咱们能吃点好的了。%SPEECH_OFF%  |  你坐在队长身边。他掰着面包。%SPEECH_ON%自从你们来到这儿后这里静的可怕。%SPEECH_OFF%吃了一口，你问他是否怀疑自己是亡灵的双面间谍。他大笑。%SPEECH_ON%如今这日子什么事都说不准。%SPEECH_OFF%就在这时，塔楼警铃响了，卫兵们冲向城墙。猛然爆发出呼喊和尖叫声。亡灵开始攻击了！\n\n 队长戴上头盔，搭手让你站了起来。%SPEECH_ON%佣兵，证明自我价值的时候到了。%SPEECH_OFF%  |  一名卫兵拿着皮革裹着的长玻璃通过城墙雉堞观察着。他的手开始颤抖，玻璃从皮革中掉了出来，在地上摔碎了。他指向远方大声喊道。%SPEECH_ON%亡—亡灵来了！准—准备战斗！敲警铃！%SPEECH_OFF%你看向城外，不用望远镜就能看到如浪潮的苍白生物涌来。你让卫兵冷静，然后冲去让%companyname%准备战斗。 |  一群狗来到%objective%前面，嚎叫着想进去。饥肠辘辘的居民们满足了它们的愿望，然后下一秒就用刀和镰刀招呼它们。虽然屠宰继续，但狗仍然进来，不断挣扎企图在屠宰场中找到安全地。你看向城墙外，明白了它们愿意冒险的原因了：亡灵来了！在远方拖着脚步，步履蹒跚的移动着。\n\n 你吹口哨示意塔楼上的人，然后指向了远方。他迅速站了起来，金属头盔都掉在石塔上叮当作响。他赶紧敲响警钟，巨大的钟声平息了下方的犬类暴乱。人和动物都看向上面，镇子里静的可怕。慢慢地，亡者的喧闹声，空气中弥漫着呻吟和嚎叫。卫兵队长出现了，武器早已拿在手中。%SPEECH_ON%兄弟们，战斗！战斗！%SPEECH_OFF%  |  一具亡灵尸体在%objective%城墙外摇摇晃晃地走着。卫兵轮流想用箭矢射它。%SPEECH_ON%看啊，射中脚了！%SPEECH_OFF%又一名卫兵搭弓准备射箭。%SPEECH_ON%他还在走。蠢货，瞄准头射啊。%SPEECH_OFF%随着“嗵”的一声脆响，箭矢正中靶心，刺进头部。尸体短暂失去平衡，停了下来，接着便仿佛记起来了本来的目的，继续前进。另一名卫兵摇摇头，准备射箭。他闭上一只眼睛，然后慢慢睁开。他手开始抖动，箭杆在弓上发出咯咯的声音。%SPEECH_ON%准、准备…战斗！敲响警钟！%SPEECH_OFF%你看向城外，发现远方仿佛一片灰蒙蒙的海洋，如涌潮般移动着。亡灵开始攻击了！ |  镇子静悄悄的，唯有火焰燃烧的噼啪声。你看着人们将一只老鼠放在火上烤，然后切成块互相分享。随后，你登上城墙发现卫兵队长正用望远镜看着远方。他冷酷地放下望远镜。%SPEECH_ON%操蛋了，他们来了。%SPEECH_OFF%他将望远镜交给你，让你瞧瞧。一大群死鱼眼的诡异亡灵正步履蹒跚地向%objective%走来。队长拿回望远镜。%SPEECH_ON%佣兵，赚钱时间到了。%SPEECH_OFF%  |  一声女人的尖叫吸引了你的注意。你恰巧看到一个男人从塔楼上跳下，绳子拗断了他的脖子。尸体摇摆着，在石墙上碰撞着。卫兵队长生气地吐了口唾沫。%SPEECH_ON%妈的，他本该盯着远方的。%randomname%！上来，把他的绳子割了，你来干他的活儿！%SPEECH_OFF%另一名卫兵咕哝着照做了，但是当他在卫兵尸体上方时，突然没有执行命令了。他反而发出歇斯底里的叫喊声。%SPEECH_ON%长官！长官！他们来了！那些死人来了！%SPEECH_OFF%队长招呼着自己手下准备战斗，而你也是如此。他看着你，眼中透着希望。%SPEECH_ON%佣兵，无论他们付出了多少钱，希望你值得那个价钱。%SPEECH_OFF%  |  一名卫兵找到了一窝老鼠，正是这导致了庆典。镇子里弥漫着居民的欢呼声，哭泣声，还有老鼠被扔进火里的尖锐叫声，卫兵队长向你走来。他面带微笑的看着，但笑容随着一声尖叫逝去。所有人看向城墙，上面的一名卫兵指着远方。即使你都能看到他眼中的恐惧。%SPEECH_ON%亡灵来了！他们来杀我们了！我们人手不足！%SPEECH_OFF%队长让自己手下别怂，然后静静地看向你。%SPEECH_ON%佣兵，召集你的人吧，证明价值的时候到了。%SPEECH_OFF%  |  逮到了一名想逃跑的卫兵。他跪在地上，卫兵队长失望地打量着。%SPEECH_ON%我们人手不多了，而你却做出这样的选择？%SPEECH_OFF%一名居民扔去一团泥，虽然散开了，但其中意味不言而喻。%SPEECH_ON%活埋他！又少了个分食物的！%SPEECH_OFF%正当农民们开始暴乱时，城镇警钟响起了。哨塔上的人声嘶力竭地喊道。%SPEECH_ON%他们来了！那些亡灵就在那边！%SPEECH_OFF%队长低头看向卫兵。%SPEECH_ON%重拾荣耀的机会到了。你愿意战斗吗？%SPEECH_OFF%那人小鸡啄米似地猛点头。队长看向你，而你却举手示意。%SPEECH_ON%不用问%companyname%这样的问题了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "守卫城镇！",
					function getResult()
					{
						this.Contract.setState("Running_Wave");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Wave2",
			Title = "%objective%…",
			Text = "[img]gfx/ui/events/event_73.png[/img]{当%companyname%都在整顿，清理剑刃上的腐肉时，钟楼又传来了信号。亡灵又开始攻击了！ |  卫兵队长四处走动，确保自己手下都好好休息，补充水分。正当他打算和你聊聊时，钟声响起，看守人大喊着敌人又发动攻击了！你笑着拍了拍队长的肩。%SPEECH_ON%我们会履行职责的。再简单不过了，对么？%SPEECH_OFF%队长点点头然后就去召集手下了。 |  你看着%randombrother%清理剑刃上的腐肉和破布。%SPEECH_ON%古神在上，他们还真是一团糟。%SPEECH_OFF%就在那时，看守人大喊亡灵又开始攻击了！雇佣兵恼火地甩掉武器上的一股脑浆。%SPEECH_ON%这下我又能当镜子使了！%SPEECH_OFF%你帮助那人站起来，拍了拍他的肩。%SPEECH_ON%相信我，你没错过多少。%SPEECH_OFF%  |  一名卫兵将一块硬面包弄成了几份，分给了众人。其他人问他从哪搞到的，他率直地回答了。%SPEECH_ON%那些死人伙计的口袋里找到的。%SPEECH_OFF%那些吃下去的人瞬间吐了出来，甚至还有个人开始呕吐。你看着人们打起来，但是很快就被看守人的声音打断了。塔楼上的卫兵指向远方。%SPEECH_ON%他们又来了！准备战斗！%SPEECH_OFF%准备战斗，别从那些视你为午饭的家伙身上抢食物！ |  当你的人在休息整顿时，看守人大喊着。%SPEECH_ON%他们又来了！%SPEECH_OFF%战争从来都没有消息，尤其是与亡灵的战争。 |  你看到%randombrother%将泥抹在脸上。他停了下来，看着你。%SPEECH_ON%长官，泥浴。你懂的，为了清理…血渍。%SPEECH_OFF%你滚动眼珠。就在那时，城镇警钟响起，瞭望人大喊着，亡灵很快又会发动攻击！你让佣兵赶紧结束他的‘泥浴’并且做好战斗的准备。 |  你看到%randombrother%正从耳朵后面弄下一串灰色的内脏物。%SPEECH_ON%妈妈以前总是说别忘记耳朵后面，但是看来她肯定没料想到会如此糟糕！%SPEECH_OFF%你说好妈妈会料想到一切。那人大笑着点点头。%SPEECH_ON%是啊，她会扯着嗓子问我怎么弄得这么脏的！%SPEECH_OFF%就在那时，瞭望人大喊着亡灵又开始攻击了。你看向雇佣兵。%SPEECH_ON%好了，肮脏时间又到了。%SPEECH_OFF%  |  你发现一名农民在石墙上刻着什么。他看到你于是解释道。%SPEECH_ON%统计阵亡人数而已。虽然名字多到无法记住了，但是数量还是能记下的。%SPEECH_OFF%你看向记载数量的城墙长度。%SPEECH_ON%我们得尽力缅怀他们，对吧？%SPEECH_OFF%你点点头，就在这时，瞭望人大声呼喊，亡灵马上又要开始攻击了。农民眼神恳求地抓住你的胳膊。%SPEECH_ON%将你的名字告诉我，若发生了不幸，我也会记下你的名字的。%SPEECH_OFF%你扯出胳膊，愤怒的眼神逼退了他。%SPEECH_ON%蠢货，我是刽子手，并非你的朋友。要不是看在雇主的面子上，你现在已经人头落地了。如果你再问同样的问题，我很愿意免费将你的名字记在那墙上，明白了？%SPEECH_OFF%他点点头。你也点头，离开招呼手下准备战斗了。 |  正当你们准备休息时，瞭望人的声音和钟声同时响起。亡灵又要发动攻击了！你命令%companyname%做好战斗准备。 |  你爬上%objective%城墙，找到卫兵队长。他唉声叹气。%SPEECH_ON%他们。又开始攻击了。%SPEECH_OFF%你看向远方，的确，亡灵又要来了。队长和你都开始召集手下准备迎接战斗。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "守卫城镇！",
					function getResult()
					{
						this.Contract.setState("Running_Wave");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Wave3",
			Title = "%objective%…",
			Text = "[img]gfx/ui/events/event_73.png[/img]{正当所有士兵休息时，顿时响起了瞭望人挫败而沮丧的声音。%SPEECH_ON%又来了。他们…又来了。%SPEECH_OFF%若想保住%objective%，%companyname%必须迎接挑战！ |  一名卫兵盯着火堆，双手颤抖着。他在喃喃自语，但是越来越响，所有人都听到了。%SPEECH_ON%没错，我们就那么做！我们能赌一把！和他们做个交易！和他们聊聊！我来和他们聊聊！%SPEECH_OFF%他站了起来。几个人试图拦住他，但没能成功。他跑向城墙冲了出去。你快步跑去，发现那个蠢货冲向了战场—径直冲向一大群亡灵！另一名卫兵看着直摇头。%SPEECH_ON%古神在上，来了更多？怎么数量就更多了？%SPEECH_OFF%你无视了他的话，然后看着那疯子消失在尸体群中。他们步履蹒跚地消化了入侵者，然后继续，就仿佛一块石头在苍白池塘中溅起了涟漪。你朝手下大喊。%SPEECH_ON%兄弟们，战斗！我们再次冲进战火！%SPEECH_OFF%  |  瞭望人发现了又一场进攻！他声嘶力竭地叫着，最后晕了过去。%objective%民兵快弹尽粮绝了，希望这是最终决战了！ |  瞭望人发出警告声，更多亡灵来了。卫兵队长摇摇头。%SPEECH_ON%古神在上，为什么他们就仿佛源源不断？佣兵，你们还真是值得雇佣。%SPEECH_OFF%你本来打算开个应该挣更多钱的玩笑，但似乎时机不太对。所以你点点头，召集%companyname%准备迎接战斗。 |  当你和卫兵队长正在互相叙述战争故事时，一名民兵走上前来。你注意到他本该看守城墙的。他坦率地说了。%SPEECH_ON%长官，他们又开始攻击了。%SPEECH_OFF%然后他就跑向了城镇军械所。你站了起来，顺便也搭手将队长扶了起来。他脸上露出庄严的笑容，拍了拍你的肩。%SPEECH_ON%一起上战场？%SPEECH_OFF%你只能耸耸肩。%SPEECH_ON%那是我们的职责。队长，战场上见。%SPEECH_OFF%  |  你看向%objective%城墙外，一群亡灵正在逼近。先前战斗的兴奋已经无影无踪。如今卫兵们一言不发地看着尸体颤颤巍巍地向前挺进。卫兵队长来到你身边。%SPEECH_ON%佣兵，很荣幸与你并肩作战。%SPEECH_OFF%你点头回答道。%SPEECH_ON%嗯，当然了。%SPEECH_OFF%队长看着你。%SPEECH_ON%你是在考虑酬劳吧？%SPEECH_OFF%你又点点头回答道。%SPEECH_ON%我在想酬金能买些什么：温暖的床，丰盛的食物还有诱人的美女。%SPEECH_OFF%  |  你站在%objective%城墙上看向远方。虽然战争即将再次袭来，但是毫无骚动。没有尖叫，没有歇斯底里。一切皆无。就那么来临了。一支奇形怪状的尸体行军步履蹒跚地挺进着，寻找再次交锋的机会。你命令%companyname%做好战斗准备。%randombrother%怀疑地敞开双臂，一半身子都粘着亡灵湿哒哒的遗体。%SPEECH_ON%长官，我们搞定了。%SPEECH_OFF%那人大笑着，而后民兵也笑了起来，很快空气中弥漫着欢乐气氛。其中还有疯狂亡灵军团的呻吟声。 |  %randombrother%走向篝火，从肩膀上拉出一长串内脏然后甩在地上。一名农民盯着那内脏，仿佛想去咬上一口。雇佣兵充满怨气地坐下。%SPEECH_ON%如果再看到视我为午餐的尸体向我走来，我就…%SPEECH_OFF%话还没说完，城墙上的瞭望人就吹响了号角，所有人都听到了警告声。他将号角扔在一边，面颊潮红，上气不接下气。%SPEECH_ON%亡…亡灵…他们又开始攻击了！%SPEECH_OFF%雇佣兵的脸色仿若死灰。他一言不发地站起来，慢吞吞地准备迎接战斗。 |  一名农夫站在%objective%城门处。他与守门人争论着。%SPEECH_ON%放我出去！你们是想与他们战斗，而我想回到自己的农场。我还有两头牛！%SPEECH_OFF%农夫伸出两根手指，以免守门人没有听到。他们耸耸肩便打开了城门，但是农夫一动不动。他反而后退一步。%SPEECH_ON%我又想了想，牛可以等我回家的。%SPEECH_OFF%你在城墙上看到远方出现了一群亡灵。片刻后，警告声便响起了，%objective%的人们四处跑动，开始准备迎接第二场战斗。 |  你在城墙上遇到了卫兵队长。他正在与民兵分享面包，看到你时于是分了你一块。你拒绝了，问他远方出现了什么。队长指向战场。%SPEECH_ON%噢，没什么，他们又进攻了而已。%SPEECH_OFF%他递给你一个望远镜。通过它，你看到了一大群尸体拖着脚步向%objective%走来。你放下望远镜，问他为什么还没有拉响警报。他耸耸肩。%SPEECH_ON%让人们再缓缓。这些行尸或许想杀了我们，但是他们速度不是很快，不是么？%SPEECH_OFF%可以理解。你接过了面包，过了一两分钟后便召集%companyname%准备迎接战斗。 |  一名民兵抓住了一具丧尸。他将其绑在锁链上，胳膊都切了。原来嘴部的地方垂着一根长舌头。卫兵队长走了过来。他面色通红，仿佛溺水之人想要呼吸，嘴中疯狂咒骂着。%SPEECH_ON%你他娘的小兔崽子以为他妈的自己在干啥？%SPEECH_OFF%民兵扯了扯锁链，将丧尸拉倒在地上。他紧张地解释道。%SPEECH_ON%或许我们能了解到什么？了解他们的行动方式和方法，我也不知道，或许能让他们恢复？%SPEECH_OFF%争论突然被一声大喊打断了。瞭望塔上的卫兵警告攻击即将再次来临。队长手握剑刃，一刀砍下丧尸的头。下巴都没有的头颅从脖子上滚落下来，舌头在地上晃动着，仿佛罐子里的蛇。队长抓住民兵的衣领。%SPEECH_ON%小兔崽子你他妈的别再搞这破事了，懂？他们死了。已经就这样子了。现在滚去拿起武器。%SPEECH_OFF%无需你多言，%companyname%就已经准备就绪了。 |  你发现铁匠正在打造%objective%最‘精良’的武器。壮实的胳膊一手挥舞着铁锤，一手紧握着铁钳，仿佛就像是用木棍做的。手部有一个双纽线刺青。萤火虫般的火花四处飞溅，他很快注意到自己的露天商铺上有着你的身影。%SPEECH_ON%你好，雇佣兵。%SPEECH_OFF%既是真心好奇，也是出于纯粹的无聊，你询问他最近如何。他锤平钢铁然后翻了过来，不断反复。%SPEECH_ON%最近当然是好多了。情况本有可能更糟糕的。看起来如何？%SPEECH_OFF%铁匠翻过剑刃让你打量打量。你还没回答，镇子上就想起了警钟声，一帮人急匆匆地跑去准备守卫城镇。民兵们跑过，顺手拿走他店里的武器。他发下剑刃大笑道。%SPEECH_ON%呸，去战斗吧，雇佣兵。反正那也是反问句。%SPEECH_OFF%  |  %objective%的文士拿着一张羊皮纸踱着步子。他将它放在仆从的背上记载见到的一切。而你十分好奇，他在混乱的战场上都看到了什么？他直率地回答你。%SPEECH_ON%研究情感。我感觉悲伤是种会蔓延的疾病。%SPEECH_OFF%奇怪问题的奇怪答案，需要再问问。你询问他的研究。他无视了你的问题，上下打量着你。%SPEECH_ON%就我来看，佣兵，你十分健康。好吧，除了你的身体。你走路像受伤的狗一瘸一拐，左转的时候脸部还会抽搐。这些都是显而易见的。但是这些疼痛都不能让你退缩。事实上，我觉得它…驱使着你。你是在弥补什么吗？%SPEECH_OFF%你本想让他闭嘴，但是这时警钟声响了起来。人们开始四处跑动，为即将到来的战斗做准备。当你转身时，文士已经离开了，站在某个远处的角落，在面露痛苦的仆从背上奋笔疾书。 |  当你准备休息一会儿时，警钟声和瞭望人的尖叫声都响了起来。似乎亡灵又开始攻击了！你赶紧召集%companyname%准备再次战斗。 |  你发现城墙上面停满了秃鹰。这些大鸟就像披着斗篷的出殡队伍盯着城镇。突然，一名民兵从塔楼门中出来，手拿着一根木棍疯狂戳向其中一只鸟。短暂的聒噪鸟叫后，剩余的秃鹰换了只爪子，就像荡起涟漪池塘上的睡莲叶子。然后民兵一棍打落第二只鸟，这些拾荒者便明白情况了，于是展翅飞了起来。猎手沾沾自喜地拽着战利品的脚回到瞭望塔。%SPEECH_ON%嘿。%SPEECH_OFF%卫兵队长拍拍你的肩。当你转身时，他竖起了拇指。%SPEECH_ON%亡灵又要攻击了。我命令手下警钟声音敲小点。你也懂得，以免咱们的声音真的吸引了更多的王八羔子来咱们这儿。%SPEECH_OFF%似乎是个很合理的主意。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "守卫城镇！",
					function getResult()
					{
						this.Contract.setState("Running_Wave");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Militia1",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_46.png[/img]{你们已经赢了，不过自卫队可能输了：城镇守卫损失惨重，许多市民都准备离开村庄，他们并不想留下帮忙！ |  胜利……但是代价呢？许多民兵在战斗中失去了生命，没有一个%objective%市民愿意代替他们的位置！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "不管怎样，还是胜利了。",
					function getResult()
					{
						this.Flags.set("Wave", this.Flags.get("Wave") + 1);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 3.0);
						this.Flags.set("Militia", 3);
						this.Flags.set("MilitiaStart", 3);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Militia2",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_46.png[/img]{战斗已经胜利，但损失惨重。几个%objective%市民愿意帮助防御，其他人都已经打包好行李准备离开。 |  虽然你获胜了，但亡灵让你们付出了巨大的代价。一些市民愿意帮助自卫队，帮助填补人数不足，可以保持距离，准备最坏的情况。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "不管怎样，还是胜利了。",
					function getResult()
					{
						this.Flags.set("Wave", this.Flags.get("Wave") + 1);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 3.0);
						this.Flags.set("Militia", 6);
						this.Flags.set("MilitiaStart", 6);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Militia3",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_80.png[/img]{胜利了！不仅仅亡灵被击退，而且你的胜利给%objective%的市民带来了深刻印象，他们纷纷加入民兵，准备接下来的战斗！ |  亡灵已经完全被打败，许多%objective%市民都加入民兵准备接下来的战斗！}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "胜利！",
					function getResult()
					{
						this.Flags.set("Wave", this.Flags.get("Wave") + 1);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 3.0);
						this.Flags.set("Militia", 8);
						this.Flags.set("MilitiaStart", 8);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Ghouls",
			Title = "%objective%…",
			Text = "[img]gfx/ui/events/event_69.png[/img]{你正在准备战斗的时候，发现亡灵中混入了奇怪的东西，食尸鬼。那家伙跟着队伍，杀死什么就吃什么，就跟海鸥跟着渔船一样。 |  食尸鬼！那些邪恶的家伙在尸体当中大步走着，毫无疑问，他们在寻找下一顿食物。 | 亡灵在身后留下了许多死者和濒死的家伙，毫无疑问，清道夫已经跟着他们很久了。他们是一群食尸鬼，这些丑陋的家伙咆哮着，饥饿地寻找着下一顿美餐。 |  如果你突袭储藏室，肯定会发现老鼠。亡灵正在攻击%objective%，一群食尸鬼跟着他们。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "守卫城镇！",
					function getResult()
					{
						this.Contract.spawnGhouls();
						this.Contract.setState("Running_Wave");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TheAftermath",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_46.png[/img]{你盯着战场。这里躺着许多死人，还有濒死的人，以及半死不活的人。还活着的人走在泥泞的道路上，干掉所有可能复活的人。战斗结束后，城镇得救了，%employer%应该正在等你。 |  战斗已经结束，城镇得救了。该回%employer%那儿领取报酬了。 |  %objective%根本不像一座城市，更像一座坟墓。大大小小的尸体堆积在地面，血流一地。这种恶臭让你想起了之前在小溪旁边找到了一条死狗，那条狗的骨头已经全部腐烂，身体上爬满了龙虾和蛆虫。\n\n攻击终于停止，%objective%已经安全了。%objective%正在等你，你也很想马上逃离这个鬼地方。 |  城市已经得救。农民拿着长棍进入战场，像塘鹅一样小心翼翼地戳着地面。%randombrother%走过来，擦了擦刀上的泥土，问是否可以回去找%employer%了。你点点头。越早回去领取报酬越好。 |  战斗结束了。许多农民和民兵都失去了性命，幸存者们一边哭泣，一边用布把尸体包裹起来。至于那些死掉的亡灵，没人在乎。那些尸体杂乱无章地躺在地上，而且已经完全腐烂了。看到这些混乱的尸体，你感到十分愤怒。你不想在这里继续待下去了，通知大家准备回去找%employer%。 |  你和%companyname%获得了胜利。城镇和人们得救了，你可以回去找%employer%领取报酬。 |  卫兵的中尉感谢你拯救了城镇。你说自己来这里的唯一原因，是因为有人给了钱。他耸耸肩。%SPEECH_ON%不管你们喜不喜欢，我还是要感谢你们。%SPEECH_OFF%  |  战争已经结束，而且你们获胜了。亡灵的尸体杂乱无章地躺在地上，和之前走路的样子没什么区别。不过最近出现的都没有这种情况。他们被哭泣的女人和困惑的孩子包围着。你看着这种场景，转身向%companyname%下令，准备回去找%employer%。 |  一个死人躺在你脚下，旁边有一具亡灵的尸体。这种现象很奇怪，因为他们似乎平等地离开了这个世界，不过那个人似乎还有呼吸。包含最近记忆的呼吸。你看到他抽搐了几下。这名战士死得十分光荣。这具尸体？什么样的？你会记得它用锋利的牙齿撕碎了某人的喉咙。或者它之前有过不一样的形象，或许它有家人，或许之前是个十分友善的人。但现在记得的只是一个撕碎别人喉咙的怪物。将会被如此铭记。\n\n对%objective%的攻击终于停止，你赶紧召集战团，准备回%townname%去找%employer%。去领取报酬总比看着这种场面好。 |  死人是什么？一个被杀死两次的人又如何呢？那么一个被杀死三次的人呢？不幸，悲惨，玩笑。\n\n 你穿过战场，搜集%companyname%的兄弟。%objective%暂时得救了，你该回%townname%去找%employer%领取报酬了。 |  %randombrother%用一块布擦了擦额头，上面留下了恶心的白色液体。%SPEECH_ON%妈的，这是什么？脑浆吗？先生，可以帮帮忙吗？%SPEECH_OFF%你帮助那个人清理，他往后退了退，摊开双手。他身上沾着血迹，内脏，还有一些不知名的东西。.%SPEECH_ON%我看起来怎么样？%SPEECH_OFF%他露出牙齿笑了笑，看起来像天空中的月亮一样。你没有回答，只是让他去找别人。%objective%已经安全，%employer%正在等待战团回到%townname%，战团也希望得到报酬。 |  %randombrother%走到你身边，你们两一起看着战场。你看到许多人在战场寻找自己的家人。他们悲伤地哭泣着，至少比听亡灵的咆哮声要好得多。雇佣兵拍了拍你的肩膀，%SPEECH_ON%我去召集大家回%townname%领取报酬。%SPEECH_OFF%  |  你看着女人们拖着脚在战场上走着，她们穿着整齐，就像躲避池塘里脏东西的家禽一样。找到想找的人之后，她们再也顾不上光鲜的外表，倒在地上大声哭起来，她们被恐惧笼罩，父亲和丈夫们显得有些冷漠和愤怒。\n\n %randombrother%来到你身边，%SPEECH_ON%先生，攻击已经停止，大家已经准备回到%townname%了。下令吧。%SPEECH_OFF%  |  卫兵的中尉来到你身边，和你握了握手，已经干燥的鲜血掉落下来。他把手放在背后擦了擦，面向战场。%SPEECH_ON%你做的很好，佣兵，如果没有你，我们根本无法成功。我很想感谢你，但城镇的重建需要不少资源。真心希望%employer%能给你丰厚的报酬。%SPEECH_OFF%你也是这么希望的。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们成功了！",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你走进%townname%，发现%employer%正站在阳台上。他刚开口教你，一个守卫就把一袋子克朗扔到你手上。%SPEECH_ON%佣兵！你回来真是太好了！我的鸟儿们已经把你的情况汇报给我了。希望你好好使用这些克朗！%SPEECH_OFF%你还没说什么，那个人就转身离开了。那个给你克朗的守卫也走了。农民们在你身边来来去去，像一个路标一样，指着他们永远不会去的地方。 |  你发现%employer%把一个小孩踢到一边，最后一脚踩在他胸口，把他踹到泥土里。看到你之后，这位贵族擦了擦脸上的汗解释说，%SPEECH_ON%这不关你的事。%SPEECH_OFF%那个孩子的手和膝盖不停颤抖，一只手捂着肚子，另一只手擦着从鼻子里流出的鲜血。他慢慢站起来，显得有些摇晃，眼睛变得血红。一位仆人走过来，用水和毛巾给他清洗，但是贵族一把抢过毛巾丢在一边。%SPEECH_ON%你以为他那样就能学乖了么。如果你想帮忙，那就帮帮这位佣兵吧。欠他%reward_completion%克朗。%SPEECH_OFF%仆人点点头迅速离开了。你停留了一会儿，看着那男孩继续挨揍。他没有哭，也没有叫喊，希望从这次惩罚中学到点什么。一会儿之后，仆人再次出现，手里拿着一个包裹。他把包裹交给你，并希望你赶紧离开。 |  %employer%站在桌子旁边，双手撑在桌面上，低着脑袋，盯着一只死去的乌鸦。%SPEECH_ON%今天早上我在床上发现了这只乌鸦。就躺在那儿，死了。你知道这是什么意思吗？%SPEECH_OFF%你说这可能是个玩笑。那名贵族嘲弄地说到，%SPEECH_ON%不，我觉得这和你有关系，佣兵。你拯救了城镇，可如果那个城镇不该被拯救呢？那可能就是这只鸟的意义。或许下次，死的就是我了。%SPEECH_OFF%你慢慢讲话题引到报酬上。虽然他很生气，但还是很快恢复理智，给了你%reward_completion%克朗。 |  %employer%正在听一群文士的话，他们是按年龄和资历的顺序排列的。年轻的那一组很安静，只听得见笔在纸上写字的声音。年老的那一组争吵十分激烈，放开嗓门彼此理论。这已经是一种常态了，怪不得有人担心死人会从坟墓里爬出来。你尽量大声介绍自己，用自己的沉着打断了他们的交谈。%employer%笑了笑，挥手让你进去。%SPEECH_ON%啊，佣兵！解决问题的人来了，过来和大家谈谈吧？%SPEECH_OFF%你摇了摇头，告诉他你是来领取报酬的。贵族点了点头。%SPEECH_ON%当然，你拯救了城镇，做得很好。我听说了你的许多英雄事迹。%reward_completion%克朗正在角落等着你呢。%SPEECH_OFF%你走过房间，鞋子踏在地板上发出清脆的响声。文士扭过头来看着你，喃喃自语。你拿起包裹，听到克朗发出叮叮当当的声音，十分叫人愉快。你安静里离开了，关上门的那一瞬间，文士们又开始争论了。 |  %employer%身边站着几个女人。她们向他诉说着自己死去的父亲，丈夫，和兄弟。他点点头，时不时看着最年轻的那个姑娘，%SPEECH_ON%嗯，当然。太可怕了，真可怕！等等，佣兵！%SPEECH_OFF%他向你挥挥手，你进来的时候，那些女人都散开了。那位最年轻的女孩打量着你，迅速擦去眼里的泪水，顺便打理了下自己。贵族看到这一幕，在你和她之间看了看。%SPEECH_ON%啊，对了，你的克朗在墙角，你走吧，马上。我还有事情。%SPEECH_OFF%他站起来指着%reward_completion%克朗，然后立即拉着那个女孩的手。%SPEECH_ON%姑娘，你说你丈夫死了，这个世界上只剩下你一个人了？没有别人了吗？%SPEECH_OFF%  |  一群狗在路上吃着什么东西。不管是什么，以前都有生命，那些骨头和器官早已变得惨白，腐烂，不过既然那些狗能吃的话，也可能是牛排之类的东西。%employer%向你打个招呼，他身边站着守卫。%SPEECH_ON%鸟儿们告诉我说城镇得救了。你做的很好，雇佣兵，比我想象中还要好。这些是你的报酬。%SPEECH_OFF%他递给你装着%reward_completion%克朗的袋子。狗停了下来，转过头看着你，嘴里还叼着肉，眼神里反射出饥饿的神情。守卫拿着长矛对着狗，于是它们又慢慢转过身继续吃了起来。 |  %employer%坐在椅子上。他挥手让你进去，意志似乎十分消沉。%SPEECH_ON%我听说了十分可怕的消息。预言家说我给人们带来了诅咒。所以死人才会复活。%SPEECH_OFF%你耸耸肩，说预言家的话不可信。贵族也耸耸肩。%SPEECH_ON%我当然也希望如此，我们之前怎么说来着？%reward_completion%克朗？%SPEECH_OFF%你刚想多说点，但还是放弃了，不敢惹这么迷信的一个人。你回答后，他露出了微笑。%SPEECH_ON%很好，佣兵。你通过了测试。虽然我可能疯了，但没人能糊弄我。%SPEECH_OFF%你问诚实有没有奖励。他皱了皱眉头，%SPEECH_ON%你的头还在肩膀上，难道这不是吗？%SPEECH_OFF%有道理。 |  %employer%站在阳台上。你和他一起，守卫就在附近，警惕地看着你。他向城镇挥了挥手。%SPEECH_ON%我知道你并没有直接拯救城镇，但还是做到了。在别的地方阻止亡灵，总比让它们到这儿来要好。你同意吗？%SPEECH_OFF%他手里拿着%reward_completion%克朗问道。你收下报酬点了点头。他也点了点头。%SPEECH_ON%很高兴你同意我的一间，希望我们下次合作。%SPEECH_OFF%  |  你走进%employer%的房间。窗户都被窗帘挡住了，蜡烛基本都没点燃。只有一个文士拿着一只拿住，他的脸在烛光的照耀下显得很红，就像拿着三叉戟的魔鬼一样。他看着你，安静地把蜡烛放下来。他出去的时候，就好像沉入黑暗的湖泊一样，他的脸慢慢消失在黑暗中。他仍站在那儿，静静地呼吸着，拉着自己的斗篷，但你看不见他。%employer%让你进去。%SPEECH_ON%佣兵！古神啊，你拯救了城镇！%SPEECH_OFF%你走上前，发现黑暗慢慢消退。%employer%给你一个包裹。最上面的硬币在闪闪发光。%SPEECH_ON%%reward_completion%克朗，之前说好的。请离开吧。我还有更多要看的东西。%SPEECH_OFF%你拿着自己的报酬离开了。关门的时候，你看到文士又出现了，像个幽灵似的，瘦骨嶙峋的双手又拿起了烛台。 |  %employer%在书房。守卫站在角落里，一名文士安静地在书架边，把书卷放回原来的地方。你走进去，他迅速把报酬给你。%SPEECH_ON%干得好，佣兵。你在一些地方已经是英雄了。希望以后你也能被记入史书中，永远被人们铭记。%SPEECH_OFF%你听到文士发出嘲笑声。%employer%指了指门，%SPEECH_ON%请吧，我还有好多事情要做，时间总是不够。%SPEECH_OFF%  |  你进入%employer%的房间，发现他坐在椅子上。农民们在两边不停争吵，%SPEECH_ON%他就是个杀人犯！%SPEECH_OFF%被指责的人发出嘲笑声，%SPEECH_ON%杀人犯？那件事只是个意外！我以为他是亡灵的走狗！%SPEECH_OFF%其他人也笑了。%SPEECH_ON%亡灵？他只是喝醉了！%SPEECH_OFF%气氛十分紧张。%SPEECH_ON%我听到了咆哮！也可能是呼噜声！%SPEECH_OFF%你的雇主意志消沉地让你进去，%SPEECH_ON%佣兵，你拯救了城镇，干得漂亮。这是你的报酬。%SPEECH_OFF%他指着桌子上%reward_completion%克朗。农民们停了下来，盯着那袋硬币。你拿起包裹，假装拿不动。%SPEECH_ON%哎呀，好重啊！祝你们过得开心！%SPEECH_OFF%  |  %employer%欢迎你进入他的房间，%SPEECH_ON%我的鸟儿们告诉我城镇得救了。你做的很好，雇佣兵，对这个黑暗的世界来说，已经够好了。你的%reward_completion%克朗，之前说好了的。%SPEECH_OFF%  |  %employer%站在外面，盯着一个墓地，自从你上次离开，又多了不少坟墓。他递给你一个装着%reward_completion%克朗的呆子。%SPEECH_ON%你做得很好，雇佣兵。你的所作所为已经传开了。一次成功无法拯救我们所有人，但能带我们走上正确的道路。要想赢得这场该死的战斗，我们必须打起精神，召集人手。%SPEECH_OFF%你收下报酬之后，说佣兵们需要更多的克朗。这样才能打气精神嘛。贵族笑了笑。%SPEECH_ON%我只是在假装虔诚而已，并不是真的仁慈。马上离开这儿。%SPEECH_OFF%  |  %employer%的守卫带你进入他的房间。他身边放着基本打开的书卷，坏掉的羽毛笔放在桌子上，就好像是刚从鸟儿身上拔下来的。%SPEECH_ON%佣兵！见到你真是太高兴了！你拯救了城镇，真是太好了。%SPEECH_OFF%他扔给你一个装着%reward_completion%克朗的包裹。%SPEECH_ON%一次胜利就能让城镇安然无恙，一次胜利能让大家心怀希望，我应该给你更多钱的。不过我不会这么做。%SPEECH_OFF%你闷闷不乐地拿着钱，点点头作为回应。%SPEECH_ON%心意最重要。%SPEECH_OFF%贵族打了打响指。%SPEECH_ON%没错！%SPEECH_OFF%  |  你发现%employer%皱着眉头坐在椅子上。他的衣服闪闪发光，烛台甚至比拿着他们的仆人更值钱。他挥挥手让你进去，挖苦地说道，%SPEECH_ON%一个人获胜，下次给我们带来更多胜利。嗯，谢谢你，佣兵。%SPEECH_OFF%你慢慢走上前，仆人恐惧地盯着你。你拿着报酬然后退下。%employer%示意让你离开。%SPEECH_ON%走吧，希望我们还能见面，如果你生病了或死了，那就可惜了。不过反正我们迟早都会那样，对吧？%SPEECH_OFF%你什么都没说，然后离开了。和亡灵的战争似乎让他变得疲惫不堪。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "%objective%救出来了",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Defended " + this.Flags.get("ObjectiveName") + " against undead");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCriticalContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] 克朗"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Origin, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "%objective%周围",
			Text = "[img]gfx/ui/events/event_30.png[/img]{亡灵数量太多，你不得不撤退。很不幸，整个城镇已经失去自由，%objective%也已经被包围了。你并没有留下来看市民们的下场，不过不用猜也知道。 |  %companyname%被亡灵打败了！你们失败后，%objective%很快也被包围了。一群农民从城镇跑出来，那些速度不够快的人已经变成了尸体。 |  你没能拖住亡灵！它们渐渐堆聚集在%objective%的墙边，吃掉并杀死遇到的所有人。你逃离战场的时候，发现中尉拖着脚，走在亡灵队伍中。}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "%objective%沦陷了。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to defend " + this.Flags.get("ObjectiveName") + " against undead");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function spawnWave()
	{
		local undeadBase = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getNearestSettlement(this.m.Origin.getTile());
		local originTile = this.m.Origin.getTile();
		local tile;

		while (true)
		{
			local x = this.Math.rand(originTile.SquareCoords.X - 5, originTile.SquareCoords.X + 5);
			local y = this.Math.rand(originTile.SquareCoords.Y - 5, originTile.SquareCoords.Y + 5);

			if (!this.World.isValidTileSquare(x, y))
			{
				continue;
			}

			tile = this.World.getTileSquare(x, y);

			if (tile.getDistanceTo(originTile) <= 4)
			{
				continue;
			}

			if (tile.Type == this.Const.World.TerrainType.Ocean)
			{
				continue;
			}

			local navSettings = this.World.getNavigator().createSettings();
			navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;
			local path = this.World.getNavigator().findPath(tile, originTile, navSettings, 0);

			if (!path.isEmpty())
			{
				break;
			}
		}

		local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).spawnEntity(tile, "Undead Horde", false, this.Const.World.Spawn.UndeadArmy, (80 + this.m.Flags.get("Wave") * 10) * this.getDifficultyMult() * this.getReputationToDifficultyMult());
		this.m.UnitsSpawned.push(party.getID());
		party.getLoot().ArmorParts = this.Math.rand(0, 15);
		party.getSprite("banner").setBrush(undeadBase.getBanner());
		party.setDescription("A legion of walking dead, back to claim from the living what was once theirs.");
		party.setSlowerAtNight(false);
		party.setUsingGlobalVision(false);
		party.setLooting(false);
		party.setAttackableByAI(false);
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(originTile);
		c.addOrder(move);
		local attack = this.new("scripts/ai/world/orders/attack_zone_order");
		attack.setTargetTile(originTile);
		c.addOrder(attack);
		local destroy = this.new("scripts/ai/world/orders/convert_order");
		destroy.setTime(60.0);
		destroy.setSafetyOverride(true);
		destroy.setTargetTile(originTile);
		destroy.setTargetID(this.m.Origin.getID());
		c.addOrder(destroy);
	}

	function spawnUndeadAtTheWalls()
	{
		local undeadBase = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getNearestSettlement(this.m.Origin.getTile());
		local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).spawnEntity(this.m.Origin.getTile(), "Undead Horde", false, this.Const.World.Spawn.ZombiesOrZombiesAndGhosts, 100 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
		party.setPos(this.createVec(party.getPos().X - 50, party.getPos().Y - 50));
		this.m.UnitsSpawned.push(party.getID());
		party.getLoot().ArmorParts = this.Math.rand(0, 15);
		party.getSprite("banner").setBrush(undeadBase.getBanner());
		party.setDescription("A legion of walking dead, back to claim from the living what was once theirs.");
		party.setSlowerAtNight(false);
		party.setUsingGlobalVision(false);
		party.setLooting(false);
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		local wait = this.new("scripts/ai/world/orders/wait_order");
		wait.setTime(15.0);
		c.addOrder(wait);
		local destroy = this.new("scripts/ai/world/orders/convert_order");
		destroy.setTime(90.0);
		destroy.setSafetyOverride(true);
		destroy.setTargetTile(this.m.Origin.getTile());
		destroy.setTargetID(this.m.Origin.getID());
		c.addOrder(destroy);
	}

	function spawnGhouls()
	{
		local originTile = this.m.Origin.getTile();
		local tile;

		while (true)
		{
			local x = this.Math.rand(originTile.SquareCoords.X - 5, originTile.SquareCoords.X + 5);
			local y = this.Math.rand(originTile.SquareCoords.Y - 5, originTile.SquareCoords.Y + 5);

			if (!this.World.isValidTileSquare(x, y))
			{
				continue;
			}

			tile = this.World.getTileSquare(x, y);

			if (tile.getDistanceTo(originTile) <= 4)
			{
				continue;
			}

			if (tile.Type == this.Const.World.TerrainType.Ocean)
			{
				continue;
			}

			local navSettings = this.World.getNavigator().createSettings();
			navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;
			local path = this.World.getNavigator().findPath(tile, originTile, navSettings, 0);

			if (!path.isEmpty())
			{
				break;
			}
		}

		local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).spawnEntity(tile, "Nachzehrers", false, this.Const.World.Spawn.Ghouls, 110 * this.getDifficultyMult() * this.getReputationToDifficultyMult());
		this.m.UnitsSpawned.push(party.getID());
		party.getSprite("banner").setBrush("banner_beasts_01");
		party.setDescription("A flock of scavenging nachzehrers.");
		party.setSlowerAtNight(false);
		party.setUsingGlobalVision(false);
		party.setLooting(false);
		party.setAttackableByAI(false);
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(originTile);
		c.addOrder(move);
		local attack = this.new("scripts/ai/world/orders/attack_zone_order");
		attack.setTargetTile(originTile);
		c.addOrder(attack);
		local destroy = this.new("scripts/ai/world/orders/convert_order");
		destroy.setTime(60.0);
		destroy.setSafetyOverride(true);
		destroy.setTargetTile(originTile);
		destroy.setTargetID(this.m.Origin.getID());
		c.addOrder(destroy);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"objective",
			this.m.Flags.get("ObjectiveName")
		]);
		_vars.push([
			"direction",
			this.m.Origin == null || this.m.Origin.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Origin.getTile())]
		]);
	}

	function onOriginSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Origin.addSituation(this.new("scripts/entity/world/settlements/situations/besieged_situation"));
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			foreach( id in this.m.UnitsSpawned )
			{
				local e = this.World.getEntityByID(id);

				if (e != null && e.isAlive())
				{
					e.setAttackableByAI(true);
					e.setOnCombatWithPlayerCallback(null);
				}
			}

			if (this.m.Origin != null && !this.m.Origin.isNull() && this.m.Origin.hasSprite("selection"))
			{
				this.m.Origin.getSprite("selection").Visible = false;
			}

			if (this.m.Home != null && !this.m.Home.isNull() && this.m.Home.hasSprite("selection"))
			{
				this.m.Home.getSprite("selection").Visible = false;
			}
		}

		if (this.m.Origin != null && !this.m.Origin.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Origin.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(2);
			}
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return false;
		}

		return true;
	}

	function onSerialize( _out )
	{
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.contract.onDeserialize(_in);
	}

});

