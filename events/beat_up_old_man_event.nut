this.beat_up_old_man_event <- this.inherit("scripts/events/event", {
	m = {
		AggroDude = null
	},
	function create()
	{
		this.m.ID = "event.beat_up_old_man";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 60 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_17.png[/img]{你看到一位老人在路上蹒跚而行。他拄着拐杖停下来，等待你靠近。他的眼睛是灰色的，不过他歪着脑袋，似乎想用自己的耳朵看清你。%SPEECH_ON%有裂缝的盔甲，重重的脚步声，稳定的呼吸，许多参加战争的战士们。%SPEECH_OFF%他挺直身子，似乎在说‘我说得对吧？’你告诉他，你们不会伤害他，%SPEECH_ON%那么，我又猜对了。不过要想杀掉我，也并不难。我已经渐渐听不清东西了，等听力消失，我也就差不多了。%SPEECH_OFF%他停下来，转过脑袋。%SPEECH_ON%你说什么了吗？%SPEECH_OFF%你发现他手上戴着一个非常漂亮的戒指。%aggro_bro%凑过来，%SPEECH_ON%我们可以拿走那个……你知道的，就像从婴儿手里拿东西那样简单。他反正是个瞎子，可能还不如婴儿呢。%SPEECH_OFF% | 一个拄着拐杖的老人靠在墙角休息。他用手摸着石头。他盯着你，手上的戒指闪闪发光。%SPEECH_ON%晚上好，先生们。多美好的一天啊，对吧？%SPEECH_OFF%你仔细打量他之后，发现他是个盲人。| 你发现一个盲人站在路中央，他的身体靠在一根拐杖上。他盯着路标摇了摇头，%SPEECH_ON%我知道这儿有个标志，如果没记错，%randomtown%应该在那边。%SPEECH_OFF%他转身对你笑着，眼睛白蒙蒙一片，因为年老而看不见了。他的一只手上带着非常漂亮，昂贵的戒指。}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "保重，老人。",
					function getResult( _event )
					{
						return 0;
					}

				},
				{
					Text = "那只宝石戒指。交出来。",
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
			Text = "[img]gfx/ui/events/event_17.png[/img]{你靠近他。他歪着头，%SPEECH_ON%步伐很轻快，陌生人，不过我没听到兵器的声音，而是……%SPEECH_OFF%你突然把他推到在地上。他抓住自己的拐杖，拐杖一端指着上方，很可能把你刺穿。你把他的手踢开，踩住他的手腕，弯下腰想夺走戒指。%SPEECH_ON%杀了我吧，混蛋！%SPEECH_OFF%你放开他，并把拐杖还给他，扶他站了起来。%SPEECH_ON%别伤心，老家伙。%SPEECH_OFF% | 你一脚把他踢倒。他发出呻吟，似乎你刚刚踢倒的是一只怀孕的熊。你一把抓住他的肚子，他问为什么，你并没有回答，而是又给他了一脚。之后你很轻松就把戒指从他手上摘了下来，然后离开了。| 他咂了咂嘴唇，发出恶心的声音。你跳过去一拳打到他肚子上。那位老人根本没想到会这样，瞬间摔倒在地上。他大口喘着气，你拿走戒指然后离开了。| 老人靠在自己的拐杖上，他抬起头。%SPEECH_ON%嗯，沉默。代表着陌生人的不良意图。我什么都看不见，可你们看得一清二楚，接下来会怎样呢？%SPEECH_OFF%你踢了他的拐杖一脚，他马上倒了下去，骨头似乎随时会散架一般。他翻滚着，嘴里向周围的人普及暴力的知识。你一脚踩到他身上，让他闭嘴。你很容易就把戒指从他手上拿下来，然后离开了。| 你压响自己的指关节。老人向后靠了靠。%SPEECH_ON%暴力并不是答案，这个世界已经不再需要暴力了。%SPEECH_OFF%你迅速给他一拳，他重重倒在地上。你拿走了戒指，%SPEECH_ON%我才不在乎这个世界需要什么，我有自己的世界，你也有自己的。只不过刚好重合了，就这样。你猜怎么着，老家伙？我的世界可比你的大多了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "这就是生活。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.addMoralReputation(-1);
				local item = this.new("scripts/items/loot/signet_ring_item");
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
				this.World.Assets.getStash().add(item);
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (!bro.getBackground().isOffendedByViolence() && !bro.getBackground().isNoble() || bro.getSkills().hasSkill("trait.bloodthirsty") || bro.getSkills().hasSkill("trait.brute"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.AggroDude = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"aggro_bro",
			this.m.AggroDude.getName()
		]);
	}

	function onClear()
	{
		this.m.AggroDude = null;
	}

});

