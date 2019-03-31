this.undead_warnings_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.crisis.undead_warnings";
		this.m.Title = "路上…";
		this.m.Cooldown = 3.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "{[img]gfx/ui/events/event_17.png[/img]短暂休息时，一个陌生人靠近营地。他的一条腿是木制假肢，虽然使用的很熟练。他步履蹒跚走向你，顶着一顶帽子开口道。%SPEECH_ON%我猜你们是为了最近发生的事来的？%SPEECH_OFF%你看了眼%randombrother%然后又看向了这个男子。他耸耸肩。%SPEECH_ON%啊，或许你们还不知道吧。我也不是太清楚，但到处传着这附近所发生的的可怕传闻。我听到的说法是，死人在地上行走，但那简直是胡扯。我觉得不过是一群强盗的新把戏。总而言之，见到你很高兴。注意安全和那些传闻。%SPEECH_OFF%这名男子笑着走开了。  |  [img]gfx/ui/events/event_97.png[/img]路旁发现一个腿间放了个头骨的孩子。它被上下颠倒然后头盖骨中有昆虫在打架。孩子略微抬头看了一眼。%SPEECH_ON%你们好。%SPEECH_OFF%你询问他的父母在哪里。他从头骨中抓起一只死虫看了看，然后将其丢到了背后。他又放了另外一只角斗士进去那个灰色竞技场然后看向你。%SPEECH_ON%父母？怎么了，他们一时半会儿回不来。父亲去他父母那了，母亲则去她父母那了。他们都被吃掉了。%SPEECH_OFF%你眉毛上扬惊讶地让他再说一遍，但孩子无视了你，精神涣散地看着头骨中战斗的虫子门欢呼着。  |  [img]gfx/ui/events/event_18.png[/img]路上你碰到一个站着的人。他把铲子房子两边肩膀上，手十字交叉，滴着泥。这个泥人抬起头，询问你要去哪里。你还没来得及回答，他打断道。%SPEECH_ON%别去那里。哪都别去。到处都是他们。我正在挖，你看到了吗？我想先挖到他们。但他们知道。他们知道我们在哪。哪都别去，因为他们无所不在。哪都别去，因为他们无所不在，而且他们知道……他们知道，你难道还不明白吗？%SPEECH_OFF%他把头按到前面，谄媚的脸低吟着，手臂像沾有泥土的蝙蝠在享用你的梦境。你灵活地穿过这个男人。%randombrother%仔细地上下打量着他，耸耸肩跟上了你的步伐。%companyname%可没工夫为这样的疯子耽搁时间。  |  [img]gfx/ui/events/event_71.png[/img]路上你遇到了一个空的小屋。%randombrother%进去打探，你在他周围，你俩都抽出了剑。他摇了摇头。%SPEECH_ON%这什么都没有。%SPEECH_OFF%他抬起头指着一处。%SPEECH_ON%除了那里。%SPEECH_OFF%你也抬头看到天花板上沾有血迹。不单单是沾着……而是书写着什么。不幸的是，由于发霉和白蚁的侵蚀字迹已经辨识不清。\n\n 你读出可见的部分：DO---GO---IDE---WE---LL---R---OOMED.\n\n 显然是疯子所为。  |  [img]gfx/ui/events/event_46.png[/img]路上有具尸体，和几棵树，否则看起来就相当空旷平坦了。你在那停留休息，这样的小树能从它们的森林同胞那窃得一些安宁。但这棵树却没有。在这棵树下的草丛中你发现一个死去的孩子。\n\n %randombrother%走上来遮住了他的嘴巴。%SPEECH_ON%神啊，谁会做出这样的事？%SPEECH_OFF%你单膝跪地。整个地方都是脚印。看来这孩子是被追赶然后跑进草丛的。可能是被绑在这里，困住了。还有更多脚印跟着。非常多。他们停留了一会儿，然后离开时留下了带血的足迹。剩下那个孩子，身上全是咬痕。你转向雇佣兵回答道。%SPEECH_ON%我看应该说是什么东西，而不是谁干的这些。但它们没在了。远处，我敢打赌再过几天，但……%SPEECH_OFF%你数了数脚印，但实在太多了。%SPEECH_ON%我觉得无论是什么东西所为……我们很快就会见到了。%SPEECH_OFF%   |  [img]gfx/ui/events/event_76.png[/img]你遇到一个举着白旗的人，中间是没有螺纹的印章，剩下磨损的部分依然在风中飘荡。他点点头。%SPEECH_ON%能见到些肉是好的。%SPEECH_OFF%好吧，你并没料到他会这么说。你自然地询问他这话是什么意思。你看起来很难以置信。%SPEECH_ON%你知道的，有肉。跟骨头相反。我最近见过太多骨头了，所以，见些肉还是很不错的。%SPEECH_OFF%你继续追问，询问他见到的是怎样的骨头。他眯起眼仿佛更希望自己忘却那些记忆。%SPEECH_ON%那种会走的。能在午夜进到你家门的骨头。杀光眼前一切的骨头。希望看到跟他们一样的骨头。就是那种骨头，明白了吗？%SPEECH_OFF%他的脸色轻松了些，眼睛睁大。他绕着你旋转然后突然前倾。%SPEECH_ON%你不会是骨头做的吧，是吗？%SPEECH_OFF%%randombrother%从他的语气中感受到一丝威胁，跳了起来，在他能有所动作之前杀掉了他。你安抚大家。陌生人似乎很自在，但你下令%companyname%经过他的时候还是小心些。他没有动。他只是站着任由旗帜的最后部分飘散在风中。  |  [img]gfx/ui/events/event_40.png[/img]路上有一个人。他手和膝盖撑地，卷轴撒的到处都是。他像狗面对威胁一样跳来跳去。他摇摇头道。%SPEECH_ON%不不不，不！在哪儿？Ah!陌生人！我是说，呃，佣兵，呃，朋友！朋友？%SPEECH_OFF%你问这人在干嘛。他手臂颤抖地回答道。%SPEECH_ON%呃，我有个猜测。有关我们是谁，呃，我们曾是谁。过去。离今天很远的日子，明白吗？你当然懂的。%SPEECH_OFF%你看着他收集便条，将它们塞进袋子里。他继续道。%SPEECH_ON%我觉得我们的过去又回来困扰我们了，我亲爱的佣兵朋友，当它们回来时，它们会杀光我们。因为它们要夺回那一切。它们要夺回那一切。%SPEECH_OFF%这个人将袋子扛过肩头点点头道。%SPEECH_ON%现在我要去告诉其他人了。感谢你的聆听，还有，再见了。%SPEECH_OFF%好吧……再见。  |  [img]gfx/ui/events/event_75.png[/img]行军之时，有东西在脚下奇怪地嘎吱作响。你停下来单膝跪地查看。你掸走一些灰尘，发现陶器碎片。它们似乎是，或者说曾是艺术品的一部分。你将它们拼凑成一幅完整画面。%randombrother%站在你身后问道。%SPEECH_ON%所以这是什么？%SPEECH_OFF%你手指划过艺术品。描绘的是手持长矛的士兵身后站着更多手持长柄武器的人，它们的阵型和森林一样厚实。它们似乎在一次一步地前进，高效率地杀死沿路遇到的敌人。\n\n 你试图将碎片捡起。黏土发出低吟，每一片都突然变成了粉末，剩下的在你的指尖流走。那么老的东西……那么怪异……它在这鸟不拉屎的地方做什么？  |  [img]gfx/ui/events/event_11.png[/img]路上出现一个奇怪的身影。你抽出武器跟上，最终碰到一个怀抱婴儿的小姑娘。孩子转过来看向你，怀中的宝宝睡的很安详。你询问他们在这里做什么。女孩耸耸肩。%SPEECH_ON%逃离坏人。%SPEECH_OFF%没来得及问她什么意思你好奇地看向四周。她回答地好像答案非常显而易见。%SPEECH_ON%坏人。我们好好埋葬了他们，但他们复活了。现在他们要杀死所有人。所以我跑了。我逃离那些坏东西。%SPEECH_OFF%她看了眼婴儿然后看向外面。%SPEECH_ON%打扰一下，先生。我的祖父生活在那边。他正在等我，只是我。%SPEECH_OFF%你抓着她的肩膀问她的父母在哪里。她甩开你的肩膀道。%SPEECH_ON%他们跟那些坏东西在一起。现在请恕我失陪，我必须要走了。%SPEECH_OFF%那个女孩抱着婴儿快速地消失在灌木丛中。这么件小事，她之后连一点声音都没发出，你也有点担心她的沉默会让她陷入危险。  |  [img]gfx/ui/events/event_91.png[/img]路上你遇到一个老女人。她一手握着脖子一手挥手示意你下来。你靠近时发现她花白的头发在掉落，快要露出她的头骨，而她的每次呼吸都异常沉重。岁月不饶人。她的言语也果然很吃力。%SPEECH_ON%你有没有在路上看到一个老头？%SPEECH_OFF%你摇摇头问她怎么了。她露出有两个洞的脖子。洞中还开始流脓，于是她将其遮挡起来。%SPEECH_ON%我父亲和我昨晚被攻击了。我不知道他在哪儿。他们好像把他带走了。他们也想把我带走，但攻击我的人一定是闻到了肮脏的东西因为他不过是尝了一口然后就跑开了。或许是我的做的菜。我总是加太多的大蒜。我的丈夫，他那晚没吃晚饭，那个白痴。%SPEECH_ON%你伸出一只手，让她慢下来。你告诉她仔细解释下到底是谁攻击她的。她点点头回应道。%SPEECH_ON%对了，是……%SPEECH_OFF%她停顿下来，眼神似乎注意到了其他东西，好像眼睛从来没眨过。她回看向你笑道。%SPEECH_ON%你好，你有在路上见过一个老头吗？他是我丈夫。我们昨晚被攻击了，我觉得他们把他带走了……%SPEECH_OFF%   |  [img]gfx/ui/events/event_16.png[/img]你来到路边的一个小镇。显然是一个每个人都互相认识的与世隔绝之地。其中一间小屋外，有一堆篝火的残留。废墟中有一个病态的黑色人影。一个居民走了过来，点了点草帽将手放到甘草叉上。他很开心地开口道。%SPEECH_ON%那是为了彻底解决问题。%SPEECH_OFF%你好奇地问发生了什么。那个人诚挚地回答，仿佛在开心重现那瞬间。%SPEECH_ON%好吧，你所看到的那具尸体是%randomname%的。他生活在那边，这个偏僻城镇的偏僻角落。他过去常常看书，如你所知，从骨骼到血液或某种抽签。这白痴不停地说着有关死者复生然后杀光我们的事。我们队这种东西很排斥所以我们直接了当地告诉了他什么是正确和正义的。%SPEECH_OFF%男人吐口痰点点头。%SPEECH_ON%那就是答案。%SPEECH_OFF%恰巧这个时候，篝火碎了，骨头碎片分散开来。只剩下一缕灰烟。  |  [img]gfx/ui/events/event_57.png[/img]你在路边看到一个墓地。这地方一团乱。阴谋被揭露，墓碑被掀翻破坏。就好像是一群盗墓者蜂拥而至然后将其洗劫一空。只是……他们也夺走了尸体？%randombrother%站在你旁边摇摇头。%SPEECH_ON%食人者？%SPEECH_OFF%这可不是食人者做的，但你点头同意可能比揭露真相更让人安心些：无论是什么埋在这里的，他都出来了然后自己离开了……  |  [img]gfx/ui/events/event_46.png[/img]行军时你途径一个废弃的营地。%randombrother%穿过其中然后踢倒了一锅油。腐烂的培根和鸡蛋洒在草地上。他发现几个袋子但发现时空的。\n\n 地面上有比较新的足迹。火焰周围有一圈，但没有跳舞的迹象，相反显得很狂暴。朝它们走去的是一坨脚印，拖着脚无序地前行。然后，当两串脚印汇聚时，只剩下后一串继续前行。\n\n %randombrother%拨开一丛灌木发现一具尸体。其头骨被铲子砸穿。它的皮肤看起来像是至少两三周前死的——所以这些脚印对于这句尸体来说还是太新了。你不知道这里发生了什么，但不会是什么好事。继续向前，%companyname%的部下要保持警惕注意那些肮脏的东西。}",
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
		if (this.World.FactionManager.getGreaterEvilType() == this.Const.World.GreaterEvilType.Undead && this.World.FactionManager.getGreaterEvilPhase() == this.Const.World.GreaterEvilPhase.Warning)
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

