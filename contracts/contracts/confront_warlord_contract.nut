this.confront_warlord_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Destination = null,
		Dude = null,
		IsPlayerAttacking = false
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

		this.m.Type = "contract.confront_warlord";
		this.m.Name = "和兽人军阀决斗";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function onImportIntro()
	{
		this.importNobleIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 1800 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		local r = this.Math.rand(1, 2);

		if (r == 1)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else if (r == 2)
		{
			this.m.Payment.Completion = 1.0;
		}

		this.m.Flags.set("Score", 0);
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"摧毁任何绿皮的营地来引诱他们的军阀",
					"杀死兽人军阀"
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
				this.Flags.set("MaxScore", 10 * this.Contract.getDifficultyMult());
				this.Flags.set("LastRandomTime", 0.0);
				local r = this.Math.rand(1, 100);

				if (r <= 10)
				{
					this.Flags.set("IsBerserkers", true);
				}

				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
			}

			function update()
			{
				if (this.Flags.get("Score") >= this.Flags.get("MaxScore"))
				{
					this.Contract.setScreen("FinalConfrontation1");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("JustDefeatedGreenskins"))
				{
					this.Flags.set("JustDefeatedGreenskins", false);
					this.Contract.setScreen("MadeADent");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("LastRandomTime") + 300.0 <= this.Time.getVirtualTimeF() && this.Contract.getDistanceToNearestSettlement() >= 5 && this.Math.rand(1, 1000) <= 1)
				{
					this.Flags.set("LastRandomTime", this.Time.getVirtualTimeF());
					this.Contract.setScreen("ClosingIn");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsBerserkersDone"))
				{
					this.Flags.set("IsBerserkersDone", false);

					if (this.Math.rand(1, 100) <= 50)
					{
						this.Contract.setScreen("Berserkers3");
					}
					else
					{
						this.Contract.setScreen("Berserkers4");
					}

					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsBerserkers") && !this.TempFlags.has("IsBerserkersShown") && this.Contract.getDistanceToNearestSettlement() >= 7 && this.Math.rand(1, 1000) <= 1)
				{
					this.TempFlags.set("IsBerserkersShown", true);
					this.Contract.setScreen("Berserkers1");
					this.World.Contracts.showActiveContract();
				}
			}

			function onLocationDestroyed( _location )
			{
				local f = this.World.FactionManager.getFaction(_location.getFaction());

				if (f.getType() == this.Const.FactionType.Orcs  ||  f.getType() == this.Const.FactionType.Goblins)
				{
					this.Flags.set("Score", this.Flags.get("Score") + 4);
					this.Flags.set("JustDefeatedGreenskins", true);
				}
			}

			function onPartyDestroyed( _party )
			{
				local f = this.World.FactionManager.getFaction(_party.getFaction());

				if (f.getType() == this.Const.FactionType.Orcs  ||  f.getType() == this.Const.FactionType.Goblins)
				{
					this.Flags.set("Score", this.Flags.get("Score") + 2);
					this.Flags.set("JustDefeatedGreenskins", true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Berserkers")
				{
					this.Flags.set("IsBerserkersDone", true);
					this.Flags.set("IsBerserkers", false);
					this.Flags.set("Score", this.Flags.get("Score") + 2);
				}
			}

		});
		this.m.States.push({
			ID = "Running_Warlord",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"杀死兽人军阀"
				];

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onCombatWithWarlord.bindenv(this));
				}

				this.Flags.set("IsWarlordEncountered", false);
			}

			function update()
			{
				if (this.Flags.get("IsWarlordDefeated")  ||  this.Contract.m.Destination == null  ||  this.Contract.m.Destination.isNull()  ||  !this.Contract.m.Destination.isAlive())
				{
					this.Contract.setScreen("FinalConfrontation3");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatWithWarlord( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;

				if (!this.Flags.get("IsWarlordEncountered"))
				{
					this.Flags.set("IsWarlordEncountered", true);
					this.Contract.setScreen("FinalConfrontation2");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					properties.Music = this.Const.Music.OrcsTracks;
					properties.AfterDeploymentCallback = this.OnAfterDeployment.bindenv(this);
					this.World.Contracts.startScriptedCombat(properties, this.Contract.m.IsPlayerAttacking, true, true);
				}
			}

			function OnAfterDeployment()
			{
				local all = this.Tactical.Entities.getAllInstances();

				foreach( f in all )
				{
					foreach( e in f )
					{
						if (e.getType() == this.Const.EntityType.OrcWarlord)
						{
							e.getAIAgent().getProperties().BehaviorMult[this.Const.AI.Behavior.ID.Retreat] = 0.0;
							e.getTags().add("IsFinalBoss", true);
							break;
						}
					}
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getTags().get("IsFinalBoss") == true)
				{
					this.Flags.set("IsWarlordDefeated", true);
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{你发现%employer%从他的马厩走过。他用手抚摸着他的马。%SPEECH_ON%你知道兽人可以用蛮力打断这个生物的脖子吗？我见过它。我知道，这死的是我的马，它的头是一个很生气的绿皮怪物打断的。%SPEECH_OFF%回忆固然很美好，但那不是你来这儿的目的吧。你小心翼翼地询问这个贵族来访的真实目的。他要求。%SPEECH_ON%对的。这场战争没有按我们想要的那个方向发展，所以我得出了一个结论，我们必须杀掉他们一个军阀。我跟你们说实话吧：那个兽人比他所有的兄弟都要强大，所以对于我们这些血肉之躯来说，他简直就是个噩梦。你最好先把他引出来，然后就尽量多地把它的绿皮怪物兄弟给杀掉。我知道这听起来不怎么样，但如果我们真的成功了，那么我们赢得这场战争的几率就会增大不少。%SPEECH_OFF%  |  %employer% 在他房间等你，他在很认真的看一张地图。.%SPEECH_ON%{我的侦察兵在这片地区发现了一个军阀，但我们不确定他具体在哪里。我有一种直觉，如果你跑出去然后故意找这些绿皮怪物的麻烦，他可能就会出来了。明白了吗？我们收到报告说发现一个兽人军阀在附近漫步。我认为如果我们能杀了他，兽人的士气就会大降，我们就可能赢得这场战争。当然了，要找到他肯定不容易。你必须让那个狗杂种自己现身，最好的办法就是你模仿那些兽人讲话：能杀多少杀多少。当然了，杀死那个绿皮怪物。对这个需要鉴别一下。 |  你来的正好，佣兵，我正好有个任务要交给你。我们收到消息说兽人军阀就在这个地方，但我们不知道他具体在哪里。我想让你去学习一下那些兽人的外交：尽可能多地杀死那些绿色的野蛮人，那个军阀一定会主动现身的。如果我们能把他除掉的话，那战局就对对我们有利多了。.}%SPEECH_OFF%  |  %employer%被一堆中尉还有一个看起来很疲倦的孩子包围着，那个孩子穿着脏兮兮的靴子，脸上都是汗水。其中一个指挥官往前把你带到旁边。%SPEECH_ON%我们发现了那个兽人军阀的踪迹。这个孩子的家人亲眼看到了那个兽人，现在他们全都死了。%employer%相信，只要我和大人同心协力，然后尽可能多地杀掉那些绿皮怪物，那个军阀就会主动现身。%SPEECH_OFF%你往后靠了一下，然后回答%SPEECH_ON%让我猜猜，你们是想让我去取他的人头吧？%SPEECH_OFF%那个指挥官耸了耸肩。.%SPEECH_ON%这个要求不过分吧？只要你答应去做这件事，我的君主会给你很丰厚的报酬。%SPEECH_OFF%  |  %employer%坐在他那群昏昏欲睡的狗的中间。他们的胃里有野鸡羽毛，在打鼾的时候会飘起来大人挥手示意你进去。%SPEECH_ON%进来吧，佣兵。完成这场狩猎吧。刚好，我需要你去做一件事儿。%SPEECH_OFF%坐下来说吧。其中一只狗抬起了它的头，喘了口气，然后又低下头去睡觉了。你问那个贵族想要什么。他揉搓其中一只狗的耳朵解释道。%SPEECH_ON%我得到消息那个兽人军阀正在外面漫步。在哪？我不知道。但我认为你能把他揪出来。你知道该怎么做的，对吗？%SPEECH_OFF%你点了点头，回答道。%SPEECH_ON%Y是的。你要一直杀他们的士兵直到他非常生气然后跑出来跟你单挑。但这绝不是个廉价的请求。%employer%.%SPEECH_OFF%那个贵族咧着嘴笑了，然后把他的手摊开，好像在说，“让我们来谈谈生意吧。”他的狗看起来好像在说“只要这个生意意味着你要不断挠我的耳朵”。 |  %employer%坐在一张长桌后面，桌上铺着比桌子还长的地图。有位文士对着他的耳朵说完悄悄话又急忙走向你。%SPEECH_ON%我的君主有个请求。我们认为有个兽人军阀在这里，自然，我们想要除掉他。为此，我们……%SPEECH_OFF%你举起手打断了他。%SPEECH_ON%既然如此，我知道怎么做了。我们会尽量多杀几个王八蛋，直到这个绿色的大块头找上门来。%SPEECH_OFF%文士热情地笑了。%SPEECH_ON%哦，你也看了战略书吗？很好！%SPEECH_OFF%你的眼神逐渐模糊，但你接着开始问报酬。 |  %employer%在书房见你。他从书架上拿书下来，每抽出一本书就带出一大片灰尘。%SPEECH_ON%来，坐吧。%SPEECH_OFF%你照着做了，他拿来一本卷册。他打开翻到其中一页，指着一个巨大兽人的华丽图片。%SPEECH_ON%你知道这些东西吧？%SPEECH_OFF%你点头。这是个军阀，兽人队伍的首领也是世界暴力之风的连接。贵族点点头，继续道。%SPEECH_ON%我的侦察兵给我带来了目击消息，所以我在调查。当然，我们从来都没有完全掌握过这该死玩意儿的行踪。他随心所欲地乱跑，不管到了哪里，都会搞破坏。%SPEECH_OFF%你打断了贵族的话，给他解释了一个简单的策略：如果你杀了足够多的绿皮怪物，军阀就会进攻，或者受到这种挑战的鼓励，谁也不知道，但它就会出来战斗。%employer%笑了。%SPEECH_ON%你看，佣兵，所以我才这么喜欢你。你很有脑子。当然，我想这种事情不容易做。价格肯定在标准以上。%SPEECH_ON%丨 %employer%认真地阅读着一大堆文士搬进来的卷轴。他一直在摇头。%SPEECH_ON%这里面全都没说怎么找到它！如果我们不能真正找到它，那又怎么杀掉它？很简单！我觉得你知道怎么办！%SPEECH_OFF%文士闪开了，抽噎着，看着地面匆忙跑出了房间。你问问题出在哪儿。%employer%叹着气说有个兽人军阀在这里，但他们不知道怎么阻止它。你笑着回答了。%SPEECH_ON%那很简单：说他们的话。你多杀几个兽人，直到军阀被逼着现身就好了。兽人喜欢暴力，他们生于此，甚至养于此。当然，真正杀死军阀并不怎么简单……%SPEECH_OFF%%employer%靠过来，搭起了手指。%SPEECH_ON%对，当然不简单，但你听着像是能干这事儿的人。而这事儿能真正让我们占据这场战争的优势。我们做个交易吧。%SPEECH_OFF%  |  你发现%employer%在花园里走来走去。他好像对植物茎秆很有兴趣。%SPEECH_ON%很奇怪，是不是？我们有这么绿的植物，而那些绿皮怪物也那么绿，我根本不觉得他们这辈子吃过什么蔬菜。%SPEECH_OFF%你想说这观察真傻逼，但还是忍住了。反而问起了绿皮怪物有什么问题，因为这听着好像没什么毛病。%employer%点点头。%SPEECH_ON%对，当然了。我的侦察兵在这地方发现了一个军阀。问题在于，我们不知道它在哪里或者说它去了哪里。侦察兵不能长时间跟踪它，否则会因为明显的原因被它弄死。我相信杀死这个军阀能帮助我们向结束战争迈进，但我对怎么做毫无头绪，你呢？%SPEECH_OFF%你点头回应了。%SPEECH_ON%你为什么想杀死这个军阀，因为他杀了你的人，对吗？所以他对我们下手可能有什么原因呢？尽量多杀几个他的同族。%SPEECH_OFF%贵族鼓起了掌，扔了个西红柿给你。%SPEECH_ON%这主意真好，佣兵。我们来谈谈生意吧！%SPEECH_OFF%  |  你发现%employer%和他的指挥官站在一张地图旁边。随着你进门时好像老鹰发现兔子的模样，他们都转向了你。贵族欢迎了你的到来。%SPEECH_ON%你好，佣兵，我们有点紧张。侦察兵报告说有兽人军阀在这片地区游荡。问题在于我们并不能完全确定它去了哪里或者怎么找到它。我的指挥官相信如果我们尽可能多的杀死绿皮怪物，军阀就会现身，那时我们就能干掉它了。你觉得自己能胜任这个任务吗？如果可以，那我们做个交易吧。%SPEECH_OFF%  |  你走进%employer%的房间，发现他在向一群文士征询意见。他们明显在发抖，捏着项链不安地动来动去。其中一个指着你。%SPEECH_ON%也许他有主意？%SPEECH_OFF%其他人嘲笑了起来，但你问他们有什么问题。%employer%解释说有个兽人军阀在当初游荡，但他们没办法追踪它。你忠实地点点头，并解释了一个非常简单的解决方法。%SPEECH_ON%多杀几个绿皮怪物，军阀出于动物野兽的高傲天性，一定会现身迎战你的。或者说，在这种情况下，现身迎战……我？%SPEECH_OFF%%employer%点点头。%SPEECH_ON%你头脑真好用，佣兵。我们做个交易吧。%SPEECH_OFF%  |  %employer%和他的指挥官们站在地图旁边。%SPEECH_ON%我们有个艰难的任务给你，佣兵。我们的侦察兵发现有个军阀在这里游荡，需要你杀掉尽可能多的绿皮怪物把它引出来。如果能拿到军阀的脑袋，我们就离结束战争更近一步了。%SPEECH_OFF%   |  你进入%employer%房间的时候，他问你对猎杀兽人军阀有没有了解。你耸耸肩回答了。%SPEECH_ON%他们会回应暴力。如果你想跟哪一个沟通，那就多杀几个他手底下的兽人。可以说，这是让他现身的唯一办法。%SPEECH_OFF%贵族理解地点头。他把一张纸从桌上推过来。%SPEECH_ON%我也许有点东西给你。我们已经知道了这里有个兽人军阀，却难于追踪它。我希望你把它引出来杀掉。如果我们能成功，赢得这场对抗绿皮怪物的战争的几率就增加了十倍！%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{我相信你可以胜任。 |  只要价钱合理，什么都能做。 |  用叮当响的金币来说服我好了。}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{这不够。 |  我们需要去别的地方。}",
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
			ID = "ClosingIn",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_46.png[/img]{一个人类骷髅的石冢最近被移除了。%randombrother%看着痛苦人面的图腾，摇摇头。%SPEECH_ON%你觉得他们把这当成艺术？好像有哪个野蛮人会退后一步说，“对啊，看起来真不错”似的。%SPEECH_OFF%你不确定。你很希望人类不是绿皮怪物的绘画工具。 |  你碰到了一大片被屠宰的家畜。内脏铺在农场起伏的土地上，好像某种血腥的灌溉。要么就是农夫误解了天气，否则肯定是兽人来过。 |  死尸。有的一分为二，其他的平和一些，但背上插着很多飞镖。两种死状都是绿皮怪物在附近的明确标志。 |  你到了一个废弃的绿皮怪物营房。有个脑袋被碾碎的哥布林。也许它和更大更强壮的兽人发生了冲突。一些吓人的影子围着口水坐着。你只希望这不是你想的那样。%randombrother%指着食物下面爆裂的余烬。%SPEECH_ON%这是新的。他们还没走远，先生。%SPEECH_OFF%  |  你到了一个畜棚，它的门被强风吹得嘎吱作响，开开合合。%randombrother%探向里面，又很快摸着鼻子退后了。%SPEECH_ON%没错，绿皮怪物来过这里。%SPEECH_OFF%你自己看了看畜棚内的情形，要其他人做好战斗准备，因为它们真的来了。 |  你发现了一个背上挂着死去哥布林的死兽人。推开两具尸体后，你看到了下面死去的农民。%randombrother%点点头。%SPEECH_ON%好吧，他经历了一番苦战。我们没早点赶到真可惜。%SPEECH_OFF%你指出了泥土中新鲜的痕迹。%SPEECH_ON%他寡不敌众，其他人还没走远。叫他们准备战斗。%SPEECH_OFF%  |  你碰到一个被锁链缠绕的人，显然，是被他们勒死的。他发紫破碎的身体随着锁链摇摆扭曲叮当作响。%randombrother%放下了尸体。尸体嘴里喷出了黑色血液，佣兵跳开了。%SPEECH_ON%见鬼，这家伙才死！不管是谁干的都还没走远！%SPEECH_OFF%你指着泥土里的痕迹告诉他这无疑是绿皮怪物做的好事，事实上，它们就在附近。 |  你在路上发现了一个用肉做成的袋子。里面是人类耳朵，已经晒黑了，穿钥匙扣的孔已经僵硬了。%randombrother%差点吐出来。你告诉他们绿皮怪物就在附近。毫无疑问要战斗了！ |  你路过了一幢小屋的废墟。余烬在焦黑的废墟下爆裂。%randombrother%发现了几具骨架，注意到它们有一半身体不见了。你看到灰烬覆盖的泥土上有很深的脚印，提醒他们做好准备，绿皮怪物肯定还在附近。 |  你遇到一个在路边哭泣的男人。他交叉双腿坐着，身体前后摆动着。你靠近的时候，他扭着脑袋，眼睛鼻子都没有了，嘴唇也被切了下来。%SPEECH_ON%不要！放过我把！%SPEECH_OFF%他倒到了一边，开始颤抖，然后就一动不动了。%randombrother%在尸体周围戳了戳，然后站起来，摇着头。%SPEECH_ON%绿皮怪物？%SPEECH_OFF%你指着泥土里深深地痕迹，点点头。 |  你碰到一个在尸体旁哭泣的女人。她在流血，她膝旁的尸体的脑袋完全凹进去了。你在她身旁蹲下来。她瞟了你一眼，发出了悲鸣。你问她谁或者说什么干的。女人清清嗓子，回答了。%SPEECH_ON%绿皮怪物。有大的。有小的。他们动手的时候还在笑。他们的棍棒上上下下，一下又一下，中间还不停笑着。%SPEECH_OFF%  |  你发现路边有匹死马，它的肚子翻了过来倒在路上。胸腔还在滴血。%randombrother%注意到心脏，肝脏，还有其他可食用部分都不见了。你指着沿路走远的大大小小的带血脚印。%SPEECH_ON%哥布林和兽人。%SPEECH_OFF%他们还没走远。你命令%companyname%为战斗好好准备一番。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "时刻警惕！",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "MadeADent",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_81.png[/img]{死了这么多绿皮怪物，好像他们的军阀现身也只是时间问题了。 |  你留下了一连串死掉的绿皮怪物。他们的军阀很快就会知道你。 |  绿皮怪物的军阀现在肯定听说了自己的战士被杀死的消息。他肯定会追着你来。 |  如果你是绿皮怪物的军阀，你可能准备好了要干掉杀死自己军队的混蛋了。继续杀戮，你肯定能明白自己和那个畜生的想法有多相似。 |  畜生能理解暴力，而你无疑在这里留下了一系列血腥。如果军阀是记教训的生物，它肯定很快会来找你。 |  出于暴怒的估算，兽人军阀肯定很生气，因为某些任性的人类打乱了他的计划。迟早，你会等到那个畜生的。也许很快。 |  死了这么多兽人和哥布林，他们的首领亲自来找你也只是时间问题了。 |  如果兽人说的语言是暴力，那你无疑是拿整个地区写了封求爱信。兽人军阀肯定很想回答你。 |  如果暴力是兽人表达爱的语言，那你肯定是站在了他们军阀的院子里对着窗户扔了不少石子来吸引他的注意。不过，石子不是石子，而是它的士兵的手脚和脑袋。现在那个暴君随时可能会作出回应。 |  你留下了一连串死去的绿皮怪物，无疑会吸引他们军阀的注意。 |  秃鹫很满意：你杀了一路的绿皮怪物，很可能，他们的军阀随时会出现，看你想干什么。 |  屠杀绿皮怪物，就像你这么做肯定能吸引兽人军阀一样——那样热度就会上升了。 |  如果事情继续按照计划发展，也就是说畅快地屠杀绿皮出生，那兽人军阀现身也只是时间问题了。 |  军队溃散也不会比你过去一周闹出来的动静更大了。如果你继续屠杀绿皮怪物，他们的军阀现身只是时间问题。 |  你有种感觉，在某个地方，有个非常非常疯狂的兽人军阀正盯着你的画像。 |  你觉得自己已经在绿皮怪物圈子里产生了‘通缉’海报。一张黏贴的人像，下面写着价格。死或死得不能再死。问题在于你会杀死每一个挡你路的人，除非兽人军阀亲自来——而且你感觉这也很快了。 |  到了现在，绿皮怪物们肯定会在篝火旁边分享关于你的故事。某个该死的人类威胁了他们的地位。你不怎么怀疑，兽人军阀会听到那些故事，然后迫切地想要亲眼看看他们说的对不对…… |  继续这样屠杀绿皮怪物，他们的军阀肯定会现身。 |  你现在踩在危险的水域里。杀了这么多绿皮怪物，兽人军阀迟早会出现。 |  你有种强烈的感觉，兽人军阀很快会来。可能会因为你杀光他的士兵做点什么。只是预感而已。 |  你杀了小绿皮怪物，也杀了大绿皮怪物。现在，是时候杀掉他们当中的最大个了：军阀。那畜生肯定在这里某个地方…… |  你对绿皮怪物宣战了，他们的军阀迟早会现身。 |  绿皮怪物到处在死。等到了时候，他们的军阀会意识到这不是自然原因。等他明白了这点，就会立刻来找你。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{胜利！ |  该死的绿皮怪物。}",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "FinalConfrontation1",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_81.png[/img]{你从农民那里听来了很多谣言，说一名兽人军阀集结了他的士兵朝你而来。如果这些谣言是真的，你最好赶快开始准备。 |  嗯，有很多人说一名兽人军阀正在穿过该区域。巧的是，他正在朝你的方向进军—这意味着你的计划成功了！%companyname%得开始为这场硬仗好好准备一番了。 |  谣言说一名兽人军阀正在向你进发！%companyname%得开始为这场硬仗好好准备一番了！ |  你遇到的每一位农民都在说着同一件事情：有一位兽人军阀正在朝你进发！这似乎并不是巧合，所以%companyname%得开始好好准备一番了。 |  嗯，据说%companyname%已成为了一名兽人军阀的目标，他率领着一支小型军队向你赶来。看起来你的计划生效了。战团得开始为这场硬仗好好准备一番了！ |  看起来你遇到的每一位农民都在说同一件事情：一名兽人军阀率领着一支小型军队正在向你进发。%companyname%得开始为这场硬仗好好准备一番了！ |  一位矮小的老妇人匆忙向你赶来。她说大家都在谈论，有一名兽人军阀正在向你进发。你不清楚这消息是否是真的，但考虑到过去几天中你的目的，这或许也太过巧合了。%companyname%得好好准备一番。 |  %companyname%得为战斗好好准备一番。你遇到的每个人都在说同一件事情：一名兽人军阀率领着一支小型军队正在向你进发！ |  很显然计划起作用了：据说一名兽人军阀率领着他的军队正向你赶来。%companyname%得开始为这场硬仗好好准备一番了！ |  一个小孩向你靠近走来。他瞥了一眼%companyname%的徽章，然后看向了你。他微笑了起来。%SPEECH_ON%看起来你们都需要帮助。%SPEECH_OFF%的确是的，但这句话从一个小孩子口中说出来给人的感觉怪异极了。你问他为什么，他回应道。%SPEECH_ON%我爸爸说有一个邪恶的兽人正向你们赶来，准备杀光你们所有人。他说那群商人们整天都在谈论这事儿呢！%SPEECH_OFF%唔，如果这是真的，说明计划成功了，%companyname%得开始为战斗好好准备一番了。你向小孩道了谢。他耸了耸肩。%SPEECH_ON%我救了你的命，你跟我说句谢谢就完了？你们这些人啊！%SPEECH_OFF%小孩啐了一口，踢着路边的石头离开了。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们得为此做好准备。",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				local playerTile = this.World.State.getPlayer().getTile();
				local nearest_orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getNearestSettlement(playerTile);
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 9, 15);
				local party = this.World.FactionManager.getFaction(nearest_orcs.getFaction()).spawnEntity(tile, "Greenskin Horde", false, this.Const.World.Spawn.GreenskinHorde, 130 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult());
				party.getSprite("banner").setBrush(nearest_orcs.getBanner());
				party.getSprite("body").setBrush("figure_orc_05");
				party.setDescription("A horde of greenskins led by a fearsome orc warlord.");
				this.Contract.m.UnitsSpawned.push(party);
				local hasWarlord = false;

				foreach( t in party.getTroops() )
				{
					if (t.ID == this.Const.EntityType.OrcWarlord)
					{
						hasWarlord = true;
						break;
					}
				}

				if (!hasWarlord)
				{
					this.Const.World.Common.addTroop(party, {
						Type = this.Const.World.Spawn.Troops.OrcWarlord
					}, false);
				}

				party.getLoot().ArmorParts = this.Math.rand(0, 35);
				party.getLoot().Ammo = this.Math.rand(0, 10);
				party.addToInventory("supplies/strange_meat_item");
				party.addToInventory("supplies/strange_meat_item");
				party.addToInventory("supplies/strange_meat_item");
				party.addToInventory("supplies/strange_meat_item");
				this.Contract.m.Destination = this.WeakTableRef(party);
				party.setAttackableByAI(false);
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local intercept = this.new("scripts/ai/world/orders/intercept_order");
				intercept.setTarget(this.World.State.getPlayer());
				c.addOrder(intercept);
				this.Contract.setState("Running_Warlord");
			}

		});
		this.m.Screens.push({
			ID = "FinalConfrontation2",
			Title = "但你靠近……",
			Text = "[img]gfx/ui/events/event_49.png[/img]{那个军阀是一群兽人和哥布林的首领。他高高地站在一大群围绕着他的战士中。你下令让手下们进入战线各就各位，可还没等你说话，那个军阀和他的战士们就大吼一声向你们冲来了！ |  一大群兽人和哥布林站在了你的面前，他们的军阀站在队伍的最前方。他往前走了几步，并将一只背包向你扔了过来。背包在半空中松了开来，落在了地面上。一堆头颅像孩童玩得弹珠一般从背包里滚了出来。军阀高举着他的武器，大声吼叫着。当那群绿皮怪物们向你们冲来时，你立刻下令让%companyname%组成阵列迎战。 |  %companyname%面前是一大群绿皮怪物：兽人，哥布林，以及他们的军阀，一位残忍的兽人，即便在那群怪物中也显得丑陋无比。大群兽人战士们高举他们的武器并咆哮着，惊起了大片飞鸟，胆小的动物们也都躲进了坑洞之中。\n\n当他们开始冲锋时，你立即让手下们组成战阵迎战，并让再三强调你们是属于%companyname%的光荣战士！ |  你和%companyname%终于与那位军阀和他的兽人哥布林大军正面交锋了。虽然你很想进行战前演讲，然而你还没说出一句话，那些残忍的家伙们就开始冲锋了！ |  最终，战团和兽人们还是相遇了，双方都摆好了架势。在%companyname%对面的是一支由兽人和哥布林组成的小型军队，一位凶残的军阀站在他们的前方。你拔出了剑，军阀也举起了他的武器。在那瞬间，你们双方都明白了一点，今天，不是你死，就是我亡。 |  兽人军阀和它的军队开始冲锋！你告诉%companyname%的兄弟们，所有的训练与准备都是为了面对今天这场战斗。%SPEECH_ON%如果我们不想这样，我们今天也不会站在这里！%SPEECH_OFF%兄弟们大吼着，拔出了武器组成战阵。 |  当那位体型巨大的军阀率领着大群哥布林和兽人冲过战场时，你告诉手下们不要慌张。%SPEECH_ON%伙计们，今晚我们可得大肆庆祝一番！%SPEECH_OFF%他们拔出了武器大声吼叫着，震耳欲聋的咆哮声回荡在上空中，第一次让那群绿皮怪物们感到了惊讶。 |  %randombrother%向你走了过来，指向了那在军阀带领下一支朝你们冲来的由兽人和哥布林组成的小型军队。%SPEECH_ON%不用提醒，你应该知道那群绿皮怪物们已经来了。%SPEECH_OFF%你点了点头，向你的手下们喊道。%SPEECH_ON%这里还有谁？%SPEECH_OFF%兄弟们全都拔出了武器。%SPEECH_ON%%companyname%！%SPEECH_OFF%  |  你和%randombrother%看着一位兽人军阀带领着手下的兽人与哥布林向你们冲来。身边的雇佣兵笑了笑。%SPEECH_ON%好了，他们冲过来了。%SPEECH_OFF%你点了点头，向手下们大声喊道。%SPEECH_ON%他们这样冲锋，是因为他们感到畏惧。因为他们没有可以坚守的地方。但是我们有，这里就是我们坚守的战场！%SPEECH_OFF%你将%companyname%的军旗重重地插在了地面上。飘扬的徽章下，兄弟们大声怒吼着。 |  你看着兽人军阀带着手下的绿皮怪物们向你冲来。你拔出了武器，向手下大喊道。.%SPEECH_ON%今天是取下那些野蛮人首级的好日子。今晚谁能安然入眠？%SPEECH_OFF%手下们拔出了武器，传来一阵阵金属碰撞声，他们大吼着。%SPEECH_ON% %companyname%！%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "拿起武器！",
					function getResult()
					{
						this.Contract.getActiveState().onCombatWithWarlord(this.Contract.m.Destination, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "FinalConfrontation3",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_81.png[/img]{那位兽人军阀正待在它该待的地方：毫无声息地死在地面上。你还看到剩下的那些绿皮怪物们逃回了山丘中。你的雇主，%employer%，将会对今天%companyname%完成的业绩感到非常高兴。 |  %companyname%今天凯旋而归！兽人军阀的尸体倒在了泥土之中，而他手下们也逃回了山丘中。这个结果你的雇主，%employer%，一定会很高兴的 |  你的雇主，%employer%，支付了一大笔报酬给你：因为兽人军阀已被消灭，而其凶残的手下也都四散逃离。没有了领袖，不用怀疑，那些野兽将会四散在各地并最终自取灭亡。你应该回去向那位贵族讨要你的报酬。 |  你消灭了那些绿皮怪物，杀死了他们的首领军阀，并把他们赶回了山岭中。你的雇主，%employer%，会对%companyname%取得的成果感到非常高兴的。 |  兽人军阀已经死了，没有了首领，那群绿皮怪物们迟早会灭亡的。你的雇主，%employer%，会很高兴听到这个消息的。 |  兽人的军阀已经死了。考虑到其给这个世界带来了那么多的恐惧与混乱，这一刻显得是多么地平静。%randombrother%走了过来，大笑道。%SPEECH_ON%虽然他大的惊人，但到底还是死了。我觉得人们总是会忘记后面那一部分。%SPEECH_OFF%你点了点头，并让其他人准备一下，开始返回%townname%去找%employer%。 |  军阀死在了你的脚下，正所谓死得其所。%companyname%从%employer%拿取了应得的报酬。剩下要做的只有回到贵族那把这个消息告诉他了。 |  %employer%可能不怎么相信你。他或许根本没想到此时此刻，你，一个雇佣军首领，竟然踩在了一名兽人军阀的尸体上。但今天，这一切都已成真，因为%companyname%可不是闹着玩的。是时候回到贵族那里拿回你的报酬了。 |  兽人军阀死了，它的军队也作鸟兽散了。你环顾四周，并向你的手下大喊道。%SPEECH_ON%伙计们，我的朋友想要杀死他最糟糕的敌人，那他应该找谁？%SPEECH_OFF%他们高举起拳头。%SPEECH_ON%%companyname%！%SPEECH_OFF%你大笑着继续道。%SPEECH_ON%一位老妇人想杀死她阁楼上的那群老鼠，她应该找谁？%SPEECH_OFF%这次手下们倒显得很安静。%SPEECH_ON%%companyname%吗？%SPEECH_OFF%你咧嘴笑着，继续道。%SPEECH_ON%如果有个矮小的男子畏惧一只墙面上的蜘蛛，那他应该找谁？%SPEECH_OFF%%randombrother%啐了一口。%SPEECH_ON%我们还是赶快回%townname%找%employer%吧！%SPEECH_OFF%  |  你看着那群绿皮怪物们作鸟兽散。%randombrother%似乎想追上去，但你阻止了他。%SPEECH_ON%让他们跑吧。%SPEECH_OFF%那名雇佣兵摇了摇头。%SPEECH_ON%但他们会对别人提起我们的！他们知道我们是谁。%SPEECH_OFF%你咧嘴笑道，拍了拍男人的肩膀。%SPEECH_ON%正是如此。好了，我们快返回%townname%去找%employer%吧。%SPEECH_OFF%  |  你穿过了遍地的尸体，走到了已被杀死的兽人军阀面前。已有苍蝇在其尸体处飞舞了。%randombrother%站在了你身边，看着那个野兽。%SPEECH_ON%他也没那么糟。我的意思是，是的，他看起来的确很恐怖。可能还会让我做噩梦，但总归来说，也不算太糟糕。%SPEECH_OFF%你微笑着拍了拍他的肩膀。%SPEECH_ON%希望你以后能用这些故事吓唬你的孙子。%SPEECH_OFF%  |  战局已定。丧命者都已死得其所。绿皮怪物们都四散向山岭跑去。而%companyname%则在为胜利欢呼。%employer%一定会对这样的事情感到高兴的。 |  %companyname%站在凶残的绿皮怪物们的尸体上高奏凯旋之歌。他低头看向那位兽人军阀，心中想着，很多必须得死的存在，无论有多么强大，终究还是……会死。奇怪的世界奇怪的规则，但事实就是如此。\n\n%employer%一定会对此感到高兴的，而且会付给你大笔报酬—你最能理解的，就是这样的金钱世界。 |  你和%randombrother%看着兽人军阀的尸体。苍蝇早就在上面飞舞个不停了，欢快地散播着疾病。雇佣兵看向了你，笑道。%SPEECH_ON%这也是你以后会遭受的情形吗？一大群昆虫在你脸上乱搞？%SPEECH_OFF%你耸了耸肩，答道。%SPEECH_ON%到身缠白布，被痛哭的亲人们环绕的那一步，还有很长的路要走呢，这是绝对的。%SPEECH_OFF%你拍了拍那名士兵的胸膛。%SPEECH_ON%好了，咱们也不多说了。快回到%employer%那儿拿报酬吧。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{%companyname%占了上风！ |  胜利！}",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.setState("Return");
			}

		});
		this.m.Screens.push({
			ID = "Berserkers1",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_93.png[/img]在路上走着的时候， %randombrother%突然伸手拦住了其他人，并让大家保持安静。你蹲着挪到了他身边。他指向了一堆灌木丛。%SPEECH_ON%那里。有麻烦。很大的麻烦。%SPEECH_OFF%你凝神望去，在其间发现了一群兽人狂战士。他们点着一小堆火，火上烤着肉。旁边有一堆笼子，每个笼子里都关着几条咆哮不停的狗。你看到一个绿皮怪物打开了一只笼子的门，猛地拉出了一条狗。尽管那条狗不停地蹬着腿，吠叫着，兽人还是把它捆在了火焰上方。\n\n 雇佣兵看了你一眼。%SPEECH_ON%我们要怎么做，长官？%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们正处于战争中，每一战都很重要。准备迎战！",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "Berserkers";
						p.Music = this.Const.Music.OrcsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Contract.addUnitsToCombat(p.Entities, this.Const.World.Spawn.BerserkersOnly, 80 * this.Contract.getDifficultyMult() * this.Contract.getReputationToDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				},
				{
					Text = "这不是我们的战斗。",
					function getResult()
					{
						return "Berserkers2";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Berserkers2",
			Title = "路上…",
			Text = "[img]gfx/ui/events/event_93.png[/img]这不是，也永远不会是你的战斗。你让手下悄悄绕过营地，避免被那群狂战士发现而遭受毁灭性的打击。你离开那里后，狗的吠叫声似乎一直追随着你，在你的耳边久久无法散去。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "把头看向前方，伙计们。",
					function getResult()
					{
						this.Flags.set("IsBerserkers", false);
						this.Flags.set("IsBerserkersDone", false);
						return 0;
					}

				}
			],
			function start()
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().getID() == "background.houndmaster")
					{
						bro.worsenMood(1.0, "You didn\'t help wardogs being eaten by orcs");

						if (bro.getMoodState() < this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}
				}
			}

		});
		this.m.Screens.push({
			ID = "Berserkers3",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_32.png[/img]战斗结束了，你在狂战士的营地好好地看了一圈。每只笼子中都关着一只萎靡，走投无路的狗。当你打开其中一个笼子后，里面的狗冲了出来，一边狂吠着一边消失在了山岭中。其余大部分的狗也做出了同样的事。不过，仍有两只狗留了下来。他们跟着你一起检查了营地剩余的其他地方。%randombrother%发现它们其实是战犬。%SPEECH_ON%看看它们的体格。又大又魁梧。他们的主人应该是被那群兽人们杀死了，看来它们现在很信任我们。欢迎来到战团，小伙计。%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "干得好，伙计们。",
					function getResult()
					{
						this.Flags.set("IsBerserkers", false);
						this.Flags.set("IsBerserkersDone", false);
						return 0;
					}

				}
			],
			function start()
			{
				local item = this.new("scripts/items/accessory/wardog_item");
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
			ID = "Berserkers4",
			Title = "战斗之后……",
			Text = "[img]gfx/ui/events/event_32.png[/img]在最后一位狂战士被杀死后，你走进了他们的营地。你在营火上发现了一些散落着的被烧焦的狗骨头。肉已经被吃完了，而被堆积起来的脑袋就像松散的岩石堆一般摇摇欲坠。%randombrother%打开了那些笼子。所有的狗，在看到缝隙的那一刻，都疯狂地冲了出来，逃之夭夭。雇佣兵试图抓住一只，但它却虚弱地吠叫着，因恐慌和畏惧而死。营地中除了兽人的屎就没有其他的东西了，这让整个战团都感到非常失望。",
			Image = "",
			List = [],
			Options = [
				{
					Text = "不过我们仍算是做了件好事。",
					function getResult()
					{
						this.Flags.set("IsBerserkers", false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "在你回来之时……",
			Text = "[img]gfx/ui/events/event_04.png[/img]{你发现%employer%正在与他的将军谈话。他微笑着向你转过身，张开了双臂。%SPEECH_ON%你做到了，佣兵。我必须承认，我真没想到你们能做到。击杀兽人真是笔有趣的生意。%SPEECH_OFF%其实一点都不有趣，但你还是点了点头。那位贵族拿取了一只装着%reward%克朗的袋子，亲自将其交给了你。%SPEECH_ON%干得不错。%SPEECH_OFF% |  找到%employer%时他正躺在床上，身边伴着几个女人。他的守卫站在门边，耸了耸肩，做出了个‘是你让他进来’的表情。那位贵族朝你挥了挥手。%SPEECH_ON%我现在有点忙，不过我已经完全明白了你通过……呃，努力，获得的巨大成功。%SPEECH_OFF%他打了个响指，其中一个女人滑出了毛毯。她优雅地走过了冰冷的石头地面，拿了一只袋子并将其交给了你。%employer%接着说道。%SPEECH_ON%数数吧，%reward%克朗，对吧？就你完成的事情来说，这应该是笔不错的报酬了。我听说击杀一名兽人军阀是一件很困难的事情。%SPEECH_OFF%那名女人紧紧地盯着你的双眼，同时将钱送到了你的手上。%SPEECH_ON%你杀死了一名兽人军阀？真是勇敢啊……%SPEECH_OFF%你点了点头，而那名轻盈的女人垫了垫脚趾。贵族再次打了个响指，而她则回到了他的床上。%SPEECH_ON%注意着点，雇佣兵。%SPEECH_OFF%  |  一名守卫将你带到了正在做园艺的%employer%处。他剪下了一颗蔬菜，将其扔进了一只侍从拿着的篮子中。%SPEECH_ON%就你没有死这件事看来，我可以推论出你已经成功杀死了那名兽人军阀了吧。%SPEECH_OFF%你回应道。%SPEECH_ON%那件事并不简单。%SPEECH_OFF%贵族点了点头，盯着地面，然后继续剪下了一串番茄。%SPEECH_ON%站在那边的守卫会把报酬交给你。跟我们说好的一样，%reward%克朗。我现在很忙，但你应该知道，我和这座城市的居民们欠了你很多。%SPEECH_OFF%很显然，‘很多’的意思是指%reward%克朗。 |  %employer%将你迎入了他的房间。%SPEECH_ON%我的小鸟们这些天叫得都很欢快，告诉我一名雇佣兵杀死了一位兽人军阀，并驱散了他的军队。然后我意识到，嘿，我应该认识那家伙。%SPEECH_OFF%那名贵族咧开嘴笑了起来，将一个装着%reward%克朗的袋子递向了你。%SPEECH_ON%干得好，雇佣兵。%SPEECH_OFF%  |  %employer%拿着一个装着%reward%克朗的袋子向你打了个招呼。%SPEECH_ON%我的间谍们已经把事情告诉我了。你的确是个值得信赖的人，佣兵。%SPEECH_OFF%  |  当你进入%employer%的房间时，你发现那名贵族正在聆听他的一位文士的低声汇报。看到你进来，男子立刻挺直了身子。%SPEECH_ON%真是说曹操，曹操到啊。你现在已经成为这个城镇的热门人物了，佣兵。杀死一名兽人军阀，还驱散了它的军队？我必须得说这%reward%克朗是你应得的。%SPEECH_OFF%  |  %employer%仔细地盯着地图。%SPEECH_ON%对此我一定会好好感激你的—我的意思是用实际行动感激你。杀死那名兽人军阀可以让我们这片饱受苦难的土地上重新扎根发展。%SPEECH_OFF%你点了点头，然后微妙地提到了报酬的事情。贵族笑了起来。%SPEECH_ON%%reward%克朗，对吗？不过，你本应该稍等一会儿的，佣兵。金钱可不会消失，而今天你所感受到的荣耀终会消失的。%SPEECH_OFF%你并不同意这个观点。那些金钱可是会消失在一堆蜂蜜酒中的。 |  %employer%在他的房间中不停地踱步，而将军们则尽忠而安静地站在一旁。你询问他遇到了什么麻烦，男子猛地站直了身子。%SPEECH_ON%真是日了上帝的狗了，我真没想到你能成功。%SPEECH_OFF%你无视了他的发言，并把你完成的事情都告诉那名贵族。他不停地点着头，然后拿出了一只装有%reward%克朗的袋子，把它递了过来。%SPEECH_ON%干得真漂亮，佣兵。真他妈漂亮！%SPEECH_OFF%  |  你发现%employer%正在看一名侍从在砍木头。看到了你的影子后，那名贵族转过头来。%SPEECH_ON%啊，快看看谁来了，当代的风云人物！我早就听说你做的事情了。实际上我们正准备庆祝此事呢—得准备好烧菜的木柴和夜间的篝火，不是吗。我非常想邀请你，但这场宴会只向贵族开放，我相信你一定能够理解这点的。%SPEECH_OFF%你耸了耸肩回应道。%SPEECH_ON%如果你能把说好的%reward%克朗交给我的话，我能理解地更加透彻一些。%SPEECH_OFF%%employer%大笑起来，朝护卫打了个响指，让他把你想要东西拿了过来。 |  找到%employer%时他正在和另一支佣兵团的首领谈话。他是一名瘦小的首领，可能是刚开始干这行的。但当看到你时，那名贵族立刻抛弃了他，转过来欢迎你。%SPEECH_ON%哦老天，见到你可真让人开心啊，雇佣兵！这边的情况有点令人绝望。%SPEECH_OFF%你注意到刚才看到的那位首领估计不适合从事任何这方面的工作，更别提狩猎一名兽人军阀了。贵族拿过一只装着%reward%克朗的袋子交给了你，回应道。%SPEECH_ON%听着，你今天干得很不错。我们终于可以了却一切问题，开始重建这片土地了。%SPEECH_OFF%对你来说手中的克朗才是最重要的，同时你也不想继续在这里浪费时间了。",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "一笔数量可观的克朗。",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Killed a renowned orc warlord");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isGreenskinInvasion())
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
			}

		});
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Destination != null && !this.m.Destination.isNull())
			{
				this.m.Destination.getSprite("selection").Visible = false;
				this.m.Destination.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isGreenskinInvasion())
		{
			return false;
		}

		return true;
	}

	function onSerialize( _out )
	{
		if (this.m.Destination != null && !this.m.Destination.isNull())
		{
			_out.writeU32(this.m.Destination.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local destination = _in.readU32();

		if (destination != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}

		this.contract.onDeserialize(_in);
	}

});

