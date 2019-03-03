this.civilwar_savagery_event <- this.inherit("scripts/events/event", {
	m = {
		NobleHouse = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_savagery";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_79.png[/img]{While marching down a path, you come across a lieutenant of %noblehouse% leading a band of men in a slaughter. They\'ve gathered the inhabitants of a small hamlet and are preparing to put them all to the sword. One of the laymen calls out to you, begging for you to intervene. The lieutenant glances at you. He doesn\'t have enough men to stop you, and you him, but there\'s enough on both sides to ensure everyone loses.%SPEECH_ON%Don\'t bother, mercenary. There\'s no profit here for you. Just keep on walking.%SPEECH_OFF% | The march of the %companyname% is suddenly interrupted when you come across a band of men carrying the banner of %noblehouse%. Unfortunately, carrying a banner isn\'t the only thing they are doing - they\'ve lined up peasants of a nearby hamlet and look prepared to slaughter them all. The lieutenant of the troop stares you down.%SPEECH_ON%Let\'s not get messy, mercenary. I suggest you keep on walking.%SPEECH_OFF% | You come to a hovel. A few bannermen of %noblehouse% are standing guard outside its door. Inside, you hear the screams of a woman and man. The lieutenant steps out and sees you. He fixes himself, even combing his hair back, and tells you to git.%SPEECH_ON%Don\'t start nothing, sellsword. Just keep on keeping on.%SPEECH_OFF% | You come to sort of holy temple, sacred to this old god or that. A few bannermen of %noblehouse% are boarding up the door while their lieutenant waves around a torch. People are screaming for mercy inside the building. You raise an eyebrow and the lieutenant spots it.%SPEECH_ON%Hey, sellsword. Yeah, you. Get moving. This ain\'t your show.%SPEECH_OFF% | While stepping down a path, you come across a lieutenant of %noblehouse%. He\'s got a couple of women standing on stools beneath a tree. They\'ve got ropes around their necks and tears down from their eyes. The lieutenant glares at you.%SPEECH_ON%Don\'t get any heroic ideas, sellsword. This ain\'t your business.%SPEECH_OFF% | While marching, you suddenly hear the shrill cries of children. Their baying draws you near, and you find them on one side of the road while on the other their parents are kneeling beneath about a dozen executioners\' swords. A lieutenant of %noblehouse% stands nearby, proudly holding up his noble house\'s banner. He stares at you.%SPEECH_ON%Oh, sellsword. Have you come to watch? I hope so, because you best not intervene. This is not your fight.%SPEECH_OFF% | Needing a piss, you climb a nearby hill for a little privacy, but mostly just to get your thoughts in order. Sadly, that won\'t be happening. Down the opposite slopes stand a number of men from %noblehouse%, following the barking orders of their lieutenant who squats not far from where you were going to piss. The troops are rounding up women from a couple of hovels stitched into an adjacent hillside. The men of the hamlet are already slain, dead in the grass here and there. Little more than blotchy lumps at this distance.\n\n The lieutenant looks up at you.%SPEECH_ON%Hello there, sellsword, nice day, no?%SPEECH_OFF%He must have seen the disconcerting look on your face as his own soon sours.%SPEECH_ON%Hey. Listen. Don\'t be getting any ideas of heroism, yeah? Just keep on walking. I\'ve seen that look before and if you don\'t put it away there\'ll be trouble for all of us.%SPEECH_OFF% | While walking a path, you hear the baying of some hounds. Apparently, a band of men from %noblehouse% have cleared out a few hovels and all that\'s left are the poor mongrels holed up in a kennel. There\'s a few soldiers standing outside it with torches, ready to set every mutt ablaze. A lieutenant stands nearby, a horrid grin on his face, though it quickly fades upon seeing you.%SPEECH_ON%Oh, you a dog lover or something? Don\'t give me that look. You\'d best keep to stepping, sellsword, or I\'ll treat you like one of these dogs here.%SPEECH_OFF% | During times of war, roads are often the worst places to be - they bring the terror to and fro and today is no different. You find a couple of %noblehouse% soldiers idling beside the path, staring down at someone they\'ve hogtied and hung over a fire yet to be lit. As you walk up, the soldiers\' lieutenant turns to get a look at you.%SPEECH_ON%Hey, if you don\'t like what you see, then keep on marching. This is war, what did you expect? Now get outta here, we got a fire to start.%SPEECH_OFF% | While trudging down a path off the main roads, keeping clear of the carnage that a civil war will wrought, you come to find a few soldiers of %noblehouse% torturing a man. They\'ve lit torches partially wrapped in leather and are letting the scraps of burning hot strips fall onto their poor prisoner. He\'s screaming for mercy, but they\'ve certainly have none for him. Seeing you, though, he calls out, begging for help. One of the soldiers turns to you.%SPEECH_ON%Like what you see? My father made this form of torture up. You just let the fiery leather drip all over them. Much better than just simple little embers.%SPEECH_OFF%}",
			Text = "[img]gfx/ui/events/event_79.png[/img]{前进的时候，你遇到一名%noblehouse%中尉，他正在指导人们进行屠杀。他们召集了小村庄的村民，准备全部把他们杀死。其中一个村民大声向你请求帮助。中尉盯着你。他没有足够的人手可以阻止你，但如果发生冲突，双方肯定都会有损失。%SPEECH_ON%算了吧雇佣兵，这对你没好处。继续前进就行了。%SPEECH_OFF% | %companyname%正在前进，突然在前方发现一群扛着%noblehouse%旗帜的人。他们不仅仅扛着旗帜，更在屠杀附近一个小村庄的村民。他们的中尉盯着你，%SPEECH_ON%别让情况变得复杂好吗，雇佣兵。你们继续往前走吧。%SPEECH_OFF% | 你们来到一间小屋面前，几个%noblehouse%旗手站在外面放哨。你听见里面传来男人和女人的尖叫声。中尉走出来看着你。他整理了下自己，梳理了下自己的头发，让你赶紧离开，%SPEECH_ON%别惹事，佣兵。你们继续往前走。%SPEECH_OFF% | 你们来到一座神庙面前，崇拜古神。几个%noblehouse%旗手站在门外，他们的中尉手里拿着一支火把。神庙内部人们大声尖叫着。你皱起眉头，中尉停了下来，%SPEECH_ON%嘿，佣兵。嗯，就是你。走开。这和你没关系。%SPEECH_OFF% | 走在路上的时候，你遇到了%noblehouse%的中尉。他让几个女人站在树下的凳子上，脖子上套着绳子，那几个女人不停流着眼泪。中尉盯着你，%SPEECH_ON%别想什么英雄救美，佣兵。这不关你的事。%SPEECH_OFF% | 你在路上突然听到小孩子的尖叫。他们的叫声吸引了你，你发现他们站在道路一边，另一边是他们的父母，几个刽子手拿着剑准备砍头。%noblehouse%的中尉站在附近，骄傲地扛着旗帜。他看着你，%SPEECH_ON%哦，佣兵。你是来参观的吗？希望如此，不过你最好别打扰我们，这和你没有关系。%SPEECH_OFF% | 你想小便，爬上一座小山，更想整理下自己的思绪。可是这思绪怕是整理不了了。对面山坡上站着几个%noblehouse%的人，中尉正在对他们下达命令，他就坐在离你不远的地方。这些人把几个小屋里的女人围在一起，赶到附近的山坡上。村庄的男人们已经被杀死了，横七竖八地躺在草地上。从这边只能看到几个小点。\n\n 中尉看着你，%SPEECH_ON%你好啊，佣兵，美好的一天对吧？%SPEECH_OFF%看到你脸上令人不安的的表情后，他的脸色也变得难看起来。%SPEECH_ON%嘿，听着。别想英雄救美，知道吗？赶紧走，我之前见到过那种表情，如果你不赶紧收起来，我们都会有麻烦。%SPEECH_OFF% | 你正在路上走着，突然听到狗叫。一群%noblehouse%的人正在清理附近的小屋，如今这里只剩下几个可怜的动物了。有几个士兵拿着火把站在外面，准备把这里烧掉。中尉站在附近，脸上带着可怕的笑容，看到你之后，笑容马上消失了，%SPEECH_ON%噢，你是爱狗人士吗？别那样看着我，你最好赶紧走开，佣兵，不然下场就会变得跟那些狗一样。%SPEECH_OFF% | 战争期间，道路总是最可怕的地方，会给人们带来恐惧。你发现一些%noblehouse%士兵在路边闲逛，看着被绑起来的人，他被吊在一个还未点燃的火把上面。你靠近之后，中尉转过身来看着你，%SPEECH_ON%嘿，如果你不喜欢这里马厩赶紧离开。这就是战争，你还想怎样？赶紧离开，我们要点火了。%SPEECH_OFF% | 你走在一条小路上，想躲避战争带来的屠杀，发现几个%noblehouse%战士正在折磨一个人。他们用皮革把火把裹起来，然后让烧着的残渣掉落在那个家伙的身上。他不停尖叫着，可他们无动于衷。看到你之后，他大声求你帮忙。其中一个战士看着你，%SPEECH_ON%喜欢这样吗？这种办法是我爸爸发明的。点燃火把，让皮革滴到他们身上。比那些小火苗好用多了。%SPEECH_OFF%}",
			
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "我们得终结这疯狂。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(4);

						if (this.Math.rand(1, 100) <= 50)
						{
							return "B";
						}
						else
						{
							return "C";
						}
					}

				},
				{
					Text = "论不到我们去干预。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_79.png[/img]{随着一声怒吼的命令，%companyname%冲锋增援。%noblehouse%的人们被解决了，血腥，快速。哭喊着，永远感激着你，那些被救了的外行们基本上都在亲你的脚了。你告诉他们快点逃跑，不然贵族剩下来的部队就要出现了。| 你告诉%companyname%动作要快。%noblehouse%的士兵们想要防御，但是他们生命最后几分钟都是在准备屠杀无辜之人，而不是准备应对最厉害的家伙们。他们都被轻松砍翻了。被拯救的平民们跑走了，嘴里喊着感激的话语，但是并没有久留。| %companyname%今天将不会容忍此种暴行。你命令佣兵们杀掉那些%noblehouse%的士兵，他们以迅雷不及掩耳之势完成了你的命令。被拯救的农民和平民们表达了自己的感激。你告诉他们快点离开，这块地方已经不再是安全之地了。|虽然不是最有利的选择，你还是介入了。%companyname%的人们收到了前进的命令。并没有为真正的战斗做好准别的%noblehouse%的士兵们被迅速砍倒了。农民与平民们表达了谢意后就马上跑走了。}",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "今天这里有人做了件好事。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Killed some of their men");
				this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
				this.List.insert(0, {
					id = 10,
					icon = "ui/icons/special.png",
					text = "战团获得声望"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().isOffendedByViolence() && this.Math.rand(1, 100) <= 75)
					{
						bro.improveMood(0.5, "Helped save some peasants");

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
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_79.png[/img]{你命令手下去拯救那些可怜的农民，但是%noblehouse%的士兵们已经做好准备了。不是以作战的形式-不，他们没有足够的人手-附近的几匹快马。他们飞驰而去，毫不疑问这会毁掉你与贵族之间的关系，但是谁他妈管他们。平民们反而是永远都会感激你的。|你命令%companyname%的人们快速解决掉那些士兵。大部分都被瞬间砍翻了，但是中尉成功骑上了一匹马逃走了。那可是一匹相当快的马。就算你自己又一匹马的话都不一定赶得上，更何况你没有马。被拯救的农民们对你感激涕零，虽然这些感激之情应该对你和%noblehouse%之间的关系没有什么帮助了。| 你没能发现附近闲置的几匹马。虽然少数几个士兵都被迅速砍倒了，你的佣兵们还是没办法抓住骑上了马逃走的中尉，你与贵族之间的关系肯定是黄了。当然你才不关心那些傻逼是怎么想的。倒是平民们，几乎是哭着说出了他们的感激之情。你告诉他们快点离开。谁知道这些日子里大地上还有什么危险和恶意。}",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "好吧。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationOffense, "Attacked some of their men");
				this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
				this.List.insert(0, {
					id = 10,
					icon = "ui/icons/special.png",
					text = "战团获得声望"
				});
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().isOffendedByViolence() && this.Math.rand(1, 100) <= 75)
					{
						bro.improveMood(0.5, "Helped save some peasants");

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
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.FactionManager.isCivilWar())
		{
			return;
		}

		if (!this.World.State.getPlayer().getTile().HasRoad)
		{
			return;
		}

		local nobleHouses = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local candidates = [];

		foreach( h in nobleHouses )
		{
			if (h.isAlliedWithPlayer())
			{
				candidates.push(h);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.NobleHouse = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = 10;
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
	}

	function onClear()
	{
		this.m.NobleHouse = null;
	}

});

