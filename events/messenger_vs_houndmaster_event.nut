this.messenger_vs_houndmaster_event <- this.inherit("scripts/events/event", {
	m = {
		Messenger = null,
		Houndmaster = null
	},
	function create()
	{
		this.m.ID = "event.messenger_vs_houndmaster";
		this.m.Title = "营地…";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_26.png[/img]%messenger%和%houndmaster%在营火旁闲聊着。信使大笑起来。%SPEECH_ON%我来给你讲讲我第一次送信的经历。那次，我要去一座被护城河环绕的要塞。河里最危险的东西不过是一些荷叶和青蛙。于是我满心欢喜，手里拿着信件，通过吊桥走进要塞。猜猜我听到了什么？汪汪汪汪！汪汪汪！一只该死的杂种狗从狗舍中张牙舞爪地冲了出来。我心想：真是见鬼了，没想到送个信也这么危险。于是我爬到了附近一个鸡笼子上，而那只毛茸茸的野兽则试图来咬我的脚。最终，要塞的领主走了出来，而那只狗就像什么事都没发生一样蹲坐在原处。那位贵族笑着接过我手上的信件。他说道，‘怎么？你没看到那个警告吗？’我说，‘呃，没看见，不过我马上就要离开了。’当我离开要塞的时候，随着吊桥缓缓升起，我终于在桥的背面看到了这则巨大的‘小心看门狗’标语！%SPEECH_OFF%%houndmaster%哈哈大笑起来。%SPEECH_ON%看来你第一趟活还不算太糟。不过现在你可以放心了，%companyname%的狗是绝不会伤害你的！我会把它们训练得服服帖帖的！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "当邮差真是命苦。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Messenger.getImagePath());
				this.Characters.push(_event.m.Houndmaster.getImagePath());
				_event.m.Messenger.improveMood(1.0, "Bonded with " + _event.m.Houndmaster.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Messenger.getMoodState()],
					text = _event.m.Messenger.getName() + this.Const.MoodStateEvent[_event.m.Messenger.getMoodState()]
				});
				_event.m.Houndmaster.improveMood(1.0, "Bonded with " + _event.m.Messenger.getName());
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Houndmaster.getMoodState()],
					text = _event.m.Houndmaster.getName() + this.Const.MoodStateEvent[_event.m.Houndmaster.getMoodState()]
				});
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local messenger_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() <= 3 && bro.getBackground().getID() == "background.messenger")
			{
				messenger_candidates.push(bro);
			}
		}

		if (messenger_candidates.len() == 0)
		{
			return;
		}

		local houndmaster_candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.houndmaster")
			{
				houndmaster_candidates.push(bro);
			}
		}

		if (houndmaster_candidates.len() == 0)
		{
			return;
		}

		this.m.Messenger = messenger_candidates[this.Math.rand(0, messenger_candidates.len() - 1)];
		this.m.Houndmaster = houndmaster_candidates[this.Math.rand(0, houndmaster_candidates.len() - 1)];
		this.m.Score = (messenger_candidates.len() + houndmaster_candidates.len()) * 3;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"messenger",
			this.m.Messenger.getNameOnly()
		]);
		_vars.push([
			"houndmaster",
			this.m.Houndmaster.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Messenger = null;
		this.m.Houndmaster = null;
	}

});

