this.greenskins_warnings_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.crisis.greenskins_warnings";
		this.m.Title = "路上…";
		this.m.Cooldown = 3.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "{[img]gfx/ui/events/event_49.png[/img]你走出了帐篷，看着那闪着火光的荒地。那些没有着火的，其实已经被烧成了焦炭，那些还未死亡的生命，正尖叫着，忍受着火焰吞噬肉体的痛苦。浓烟滚滚的废墟中，一队魁梧的兽人正大步行走着，身后拉着一群被锁链捆在一起的人类，旁边一群哥布林上蹿下跳着，享受着这份混乱。还有……%randombrother%？那名佣兵戳醒了你，那个燃烧的世界瞬间消失了。你看到他正站着看着你。%SPEECH_ON%很抱歉吵醒了你，长官，但是你的床被蜡烛点燃了。我及时把它扑灭了。嘿，你没事吧？%SPEECH_OFF%你点了点头，让他把这里清理一下，然后让大伙儿准备出发。你试图忘掉那场梦，然而它却牢牢地印在了你的脑海中。| [img]gfx/ui/events/event_76.png[/img]一名男子从路边的树林中猛然窜出。他穿着破烂的衣衫，脸上还被拉开了个大口子，他的舌头似乎已经不听使唤，只能发出模糊而绝望的嘶吼声。%randombrother%向后跳了一步，避开了那人试图抓住他的双手。你拔出了剑，然而那个陌生人却倒在了地上，你发现他的背部还插着一根飞镖，飞镖上的毒已经让他的皮肤变成了绿色。\n\n 战团警戒了一段时间，然而却没有发生任何事。根据经验，这应该是那些绿皮怪物们做得好事，很显然这附近有兽人和哥布林的存在…… |  [img]gfx/ui/events/event_97.png[/img]一位年轻的小伙子跑了过来，身后还跟着条狗。他在战团前停下了脚步，抚摸着狗的脑袋。%SPEECH_ON%你们是在追那些绿皮怪物吗？我听说，高大的家伙很强壮，难以杀死，而那些矮小的家伙又非常狡猾。%SPEECH_OFF%你问他是从哪里来的。他耸耸肩。%SPEECH_ON%我从很远的地方来。我们是流浪者，长官，我和我的狗。但在旅途中，我已经见过很多事情了。%SPEECH_OFF%%randomname%向前走了一步。%SPEECH_ON%你是说你看到了兽人和哥布林在一起做事吗？%SPEECH_OFF%那个小伙子点了点头。%SPEECH_ON%是的！的确如此。哈，好吧，看来你也不是我想的那种人。愿你白日常在，黑夜短暂，同时祝你美梦依然。%SPEECH_OFF%说完他就走进了灌木丛中。你追了上去，然而那人和他的狗已经消失了。 | [img]gfx/ui/events/event_94.png[/img]你听到不远处有一群苍蝇嗡嗡飞舞的声音。靠近后，你看到了一座小屋，屋顶是用茅草铺成的，上面还挂着一些锅和壶，木质风铃在空中发出令人愉悦的声音，而旁边的草地上躺着3具被严重破坏的尸体，一大群虫子正在其上方盘旋着。%randombrother%在一具尸体前蹲下，检查了一番。%SPEECH_ON%一定是兽人干得。旁边有它们的脚印。%SPEECH_OFF%你点了点头，同时发现小屋的门边还插着一些飞镖。你拿起了一支，闻了闻。%SPEECH_ON%有毒。看来不仅是兽人来到过这里。%SPEECH_OFF%%randombrother%也闻了闻一支飞镖，点了点头。%SPEECH_ON%是的，兽人和哥布林。它们在一起行动？见鬼，真希望不是如此。%SPEECH_OFF%如果它们真的是一起行动，那的确是场灾难，但现在你只能希望这些证据只是巧合凑在一块的。 | [img]gfx/ui/events/event_02.png[/img]你看了看地图，然后看了看眼前的情形。%SPEECH_ON%这里本应该有个村落。%SPEECH_OFF%%randombrother%走过来，满足地咬了口从树上摘下来的苹果。%SPEECH_ON%唔，或许得重新编辑一下这里了，长官。%SPEECH_OFF%村庄已经被毁了。原本的那些村民都已经被吊死在了木桩或是树木上了。那些没被吊死的人，其白骨正堆积在原本是村镇广场的地方。你盯着地面，发现了这场大屠杀始作俑者的足迹。脚印有小有大。哥布林，兽人。%randombrother%摇了摇头。%SPEECH_ON%它们应该不是一起行动的吧，对吗？%SPEECH_OFF%你耸耸肩，回答道。%SPEECH_ON%我认为是兽人们先把这里清洗了一次，而随后到来的哥布林们解决了其他幸存下来的人，不过顺序也可能是相反的。%SPEECH_OFF%佣兵点了点头，相信了你的解释，不过你们的内心深处都清楚，这种事不会是简单的巧合。 | [img]gfx/ui/events/event_97.png[/img]你遇到了一个正蹲在河床边的小孩。他正用木棍在泥土上画着什么—头戴长角头盔的人，身后还跟着矮小的人，虽然身形矮小，他们仍然全副武装着。%randombrother%问那个小孩他到底在画什么。%SPEECH_ON%我在画绿皮怪物们。我曾看到过很多，快速且散乱地翻过了山丘，用我爸爸的话说，那样子就像是我们家储物柜里的老鼠。%SPEECH_OFF%你问他住在哪里。他指向了一个附近的长着茂密树林的山丘。%SPEECH_ON%就在那边。有很好的视野，能看清附近的情形。也能帮助你及时应对紧急事件。%SPEECH_OFF%远处一位老人呼唤了男孩，男孩也作出了回应，扔下了作画的工具，朝山丘走去。%SPEECH_ON%我得去干活了。祝你们好运！还有，别踩了我的画！%SPEECH_OFF%你现在明白了，画中的那些人物原来是兽人和哥布林，不过也有可能是那个小孩的遐想。 | [img]gfx/ui/events/event_36.png[/img]你看到了一位把手臂放在胸口站在路边的人。他的两只手都不见了。他抬起头看向你，之后突然向后倒去，那个可怜的家伙倒在地面，凝视着天空，双臂无力地摆动着。%SPEECH_ON%它们是一起行动的。杀死了……杀死了所有人。不敢相信我真的看到了那种情形。我一直认为，如果它们来了，我会做好准备，无论是哪种，我都能对付。然而事实却是这样。它们是一起来的。%SPEECH_OFF%你问他到底在说谁。男子努力地抬起身子，痛苦扭曲了他的表情，直至咽下最后一口气。天空的影子映在他那尚未闭上的双眼中，死亡如期而至。%randombrother%检查了尸体，但是没有任何发现。 | [img]gfx/ui/events/event_95.png[/img]一个骷髅组成图腾，被剥下的人皮披在上面，每个骷髅头上还戴着可怕的斗篷。地面上充斥着血迹。以及更多的骨头。肌肉和肌腱，未被使用或食用的东西。地面上的焦土痕迹表明这里曾点过一个篝火。%randombrother%检查着四周，寻找线索。他找到了一个非常原始的武器，还在山羊皮包里找到了几枚飞镖。.%SPEECH_ON%这玩意儿对人类来说太大了，而这些飞镖显然，嗯，是涂过毒的。毫无以为，绿皮怪物们曾来到过这里，它们是一起行动的。.%SPEECH_OFF%一起行动？这是种可怕的看法，但很显然这是真的。这个野蛮部落到底有什么目的？ | [img]gfx/ui/events/event_71.png[/img]你发现了一个被焚毁的小屋。里面混杂着碎石，骸骨，显然里面的人是在极度的绝望中死去的。灰烬当中有一只锁，那里本应是门的位置，那些人躲在里面，关起了门，然而外面却着起了大火，烧毁了一切。%SPEECH_ON%长官，你得看看这个。%SPEECH_OFF%%randombrother%招呼着你。他正站在一棵树面前。一只死去的哥布林正依靠着树木，空洞的表情凝结在它脸上，胸口还插着一支草叉。它的旁边还有具兽人的尸体，头骨上插着一支铲子。%randombrother%在想这两个家伙是不是互相残杀而死。你也希望如此，但从它们的伤口上可以看出，这都是人类所为，如果真是这样的话，这些绿皮怪物们应该是一起行动的。这种想法让你不由感到害怕。 | [img]gfx/ui/events/event_59.png[/img]一路走来，到处都是避难者，背着婴儿的妇女，拿着草叉当手杖的男人，赤着脚边走边祈祷的修士。你本想上去问问他们情况，然而他们却畏惧地向后退去，瞪大着惊恐的双眼。最终，一位老者向你开口说道。%SPEECH_ON%不用试了，长官，他们经历了太多的苦难。那些绿皮怪物们……趁夜间发动了袭击。兽人冲进了村庄，而哥布林则在外侧伏击着那些逃跑的人。民兵队伍全都被屠杀了。只有我们这些懦弱的农民活了下来，而且还是跑得最快的几个。%SPEECH_OFF%你问他兽人和哥布林是否是一起行动的。他点了点头，拍了拍你的肩膀。%SPEECH_ON%是的，我看到了。祝你一路顺风，陌生人。%SPEECH_OFF% | [img]gfx/ui/events/event_76.png[/img]一名身着华丽的男子站在路边。他抬着头，双臂摆在身侧，或许是因为喝多了想这样保持平衡。你抓着他摆动了几下。他的脸颤抖了几下，眼神十分空洞，面颊传来一阵阵小龙虾腐烂般的恶臭。两条无手的手臂拍打着你，似乎是想抓住你。他的脸庞扭曲着，喉咙发出了痛苦的嘶吼声，显示了他经历了怎样的苦难。\n\n %randombrother%迅速地跳上前来，推开了他。那个陌生人慢慢地倒了下去，他华丽的貂皮大衣散开，遍体鳞伤的裸体就这样展示在了你的面前，更可怕的是，他的下体是空荡荡的。当他落地后，肢体散落开来，那些残暴的伤痕将他几近肢解。他的内脏慢慢地从伤口处滑落而出。男子尖叫道。%SPEECH_ON%兽人！哥布林！兽人！哥布林！兽人！哥布……林……%SPEECH_OFF%他咽下了最后一口气。哦，感谢诸神，他终于死了。他的遗言又代表着什么呢？}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "得好好思索一番……",
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
		if (this.World.FactionManager.getGreaterEvilType() == this.Const.World.GreaterEvilType.Greenskins && this.World.FactionManager.getGreaterEvilPhase() == this.Const.World.GreaterEvilPhase.Warning)
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
	}

	function onClear()
	{
	}

});

