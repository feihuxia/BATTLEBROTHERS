this.minstrel_writes_song_event <- this.inherit("scripts/events/event", {
	m = {
		Minstrel = null,
		OtherBrother = null
	},
	function create()
	{
		this.m.ID = "event.minstrel_writes_song";
		this.m.Title = "营地…";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]{吟游诗人%minstrel%拿起一把鲁特琴。你不知道这乐器是他从哪里弄来的，但他用几下琴声吸引了战团其他成员的注意。他整理了一下自己的头发，闭上眼睛，开始弹唱%SPEECH_ON%我……-弹琴- 加入了一队佣兵，我的钱箱子也没了……-弹琴-……他们想要一个战士，但我只会唱歌。唱完了。%SPEECH_OFF%战团成员们一下子都笑了。| 吟游诗人%minstrel%像魔术师变出兔子一样掏出了一把鲁特琴。他随手弹奏了几下，然后开始唱歌。%SPEECH_ON%曾经有一只怪兽，威胁着和平的Riggabong……-弹琴-……如果我没记错的话，人们认为它是，一个大问题……-弹琴 弹琴-……\n\n这只怪兽只吃女人，而且只吃处女，没错，它的胃口可不小……-弹琴-……但显然，无论受害者是男是女，都不愿意接受这样的命运……-弹琴-……\n\n 所以那里的人雇佣了Sir Galicock，他是最强的剑士……-弹琴-……于是，他造访了那里每一户居民，并消灭了所有的处女！……-弹琴-……然后那怪兽就被饿死了。唱完了。%SPEECH_OFF% | 在劈啪作响的火堆旁，人们的眼中开始出现倦意。吟游诗人%minstrel%清了清自己的喉咙，意思就是‘大家听好了’。他站了起来，用手做出了拿着玻璃杯敬酒的姿势。%SPEECH_ON%没错，你们就是我碰到的最棒的男人。我这么说是因为我从未见过我的父亲，而我之前一直都生活在女人堆里。%SPEECH_OFF%他朝远方望去。%SPEECH_ON%唉，我真是采花无数啊。%SPEECH_OFF%说完后他就坐下了。在大家沉默了一会儿之后，营地中传出了一阵爆笑声。| 吟游诗人%minstrel%正在寻找他的鲁特琴。由于找不到它，他只好用一把‘空气鲁特琴’代替。在拨弄了一番之后。%SPEECH_ON%等一下，这个声音好像不太对，让我调一调。%SPEECH_OFF%他举起手，然后动了动手指，又弹奏了一下。%SPEECH_ON%什么鬼？这比之前更糟糕了。等等，我保证我肯定能调好。%SPEECH_OFF%他又尝试了一遍，但‘效果’依然不尽人意。%SPEECH_ON%这没用的破烂货！%SPEECH_OFF%吟游诗人站起来不断地将那把看不见的鲁特琴砸在地上，最后扔进了一旁的高草丛里。他擦了擦额上的汗珠。%SPEECH_ON%亲爱的父亲，你说的没错，我应该成为一名铁匠。%SPEECH_OFF%然后他一溜烟地跑开了，引得战团里的弟兄们疑惑地大笑。| 吟游诗人%minstrel%一边将土块丢进篝火中，一边开始说话，但没人知道他到底在对谁说。%SPEECH_ON%旧神们说过要有光，对不对？那是他们所做的第一件事，所以肯定相当重要。%SPEECH_OFF%他拾起一把土，似乎是在分析它。%SPEECH_ON%可为什么处于黑暗中的女人总是那么好玩呢？%SPEECH_OFF%那些最开始被他弄糊涂的人一下子就笑了起来。| 吟游诗人%minstrel%站起来跺了跺脚。%SPEECH_ON%要不要我给你们这些笨蛋讲讲如何跳舞啊？%SPEECH_OFF%一些人仰起脸来摇了摇头。%SPEECH_ON%唉，来嘛。这很简单的。看好了。%SPEECH_OFF%他抬起一条腿，然后以一种夸张的角度将它放回地面。他开始旋转，将手举过头顶。然后，他展开双臂，做出飞翔的动作。事实上，他的动作相当优美，只是你从未跟别人承认过。你看着吟游诗人继续他的舞蹈。他身体前倾，突然之间，他在%otherbrother%的面前放了一个响屁。\n\n %minstrel%立刻直起身体，好像这个屁是他故意放的一样。%SPEECH_ON%我，呃……好吧，就这样吧！希望你们能按照这个节拍来跳！%SPEECH_OFF%他一溜烟地跑开了，后面还追着一个臭烘烘的人。其他的人则已经笑的前仰后俯。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Bravo!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Minstrel.getImagePath());
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Minstrel.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 33)
					{
						bro.improveMood(1.0, "Felt entertained");

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
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 3)
		{
			return;
		}

		local candidates_minstrel = [];
		local candidates_other = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.minstrel")
			{
				candidates_minstrel.push(bro);
			}
			else
			{
				candidates_other.push(bro);
			}
		}

		if (candidates_minstrel.len() == 0)
		{
			return;
		}

		if (candidates_other.len() == 0)
		{
			return;
		}

		this.m.Minstrel = candidates_minstrel[this.Math.rand(0, candidates_minstrel.len() - 1)];
		this.m.OtherBrother = candidates_other[this.Math.rand(0, candidates_other.len() - 1)];
		this.m.Score = candidates_minstrel.len() * 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"minstrel",
			this.m.Minstrel.getNameOnly()
		]);
		_vars.push([
			"otherbrother",
			this.m.OtherBrother.getNameOnly()
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Minstrel = null;
		this.m.OtherBrother = null;
	}

});

