this.aging_swordmaster_paycut_event <- this.inherit("scripts/events/event", {
	m = {
		Swordmaster = null
	},
	function create()
	{
		this.m.ID = "event.aging_swordmaster_paycut";
		this.m.Title = "营地中...";
		this.m.Cooldown = 100.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_17.png[/img]%swordmaster% 掀开门帘步入你的营帐. 你向他挥手示意他坐在你对面. 他十分缓慢的坐了下来,你担心他站起来可能需要两倍于此的时间. 他双手紧握成拳，手肘放置于桌面之上, 咕哝着来回挪动着双臂, 但很难找到一个舒适的姿势. 他的嘴唇干燥起皮, 面容衰老憔悴. 老年斑遍布他的脸颊,甚至他的鼻子与耳朵上都充斥着灰色的斑点.\n\n 对于 %swordmaster% 你总能抽出一些时间给他,你询问他有什么想要和你说的.%SPEECH_ON%这可能会听起来很奇怪,对于一位刀口舔血过日子的人, 但我认为我还是需要把这件事说出来, 这至少可以让我晚上睡的安心一些. 我和你直说吧: 我不像以前你雇佣时那样了. 你清楚. 我清楚. 一些其他人也都很清楚, 但他们依旧十分友好的尊重我.%SPEECH_OFF%你认可他所说的话, 但你没有点头附和. 相反, 你装作不明白他在说什么，询问他在说什么.%SPEECH_ON%我希望你降低我的薪水. 先不要拒绝我, 你不用说一些胡话来糊弄我. 我就长话短说吧. 钱对于我来说不是主要问题. 这些钱可以用来给战友们更换更好的装备,甚至给他们更好的报酬. 就连上帝都知道年轻人总会需要额外的一个或两个克朗.%SPEECH_OFF%在你开口讲话之前, 他以十分惊人的速度起身而立. 他咧嘴笑着向你点了点头,玩笑般的叫喊着.%SPEECH_ON%我同意你的决定, 好先生. 我可以好好利用这些省下来的钱!%SPEECH_OFF%你笑起来的时候他离开了你的帐篷，就像他进来时一样迅速.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "毋庸置疑,他是一位可敬的人.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Swordmaster.getImagePath());
				_event.m.Swordmaster.getBaseProperties().DailyWage -= _event.m.Swordmaster.getDailyCost() / 2;
				_event.m.Swordmaster.getSkills().update();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_daily_money.png",
					text = _event.m.Swordmaster.getName() + " 现在只需要 " + _event.m.Swordmaster.getDailyCost() + " 克朗一天"
				});
				_event.m.Swordmaster.getTags().add("aging_paycut");
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 6 && bro.getBackground().getID() == "background.swordmaster" && !bro.getTags().has("aging_paycut") && !bro.getSkills().hasSkill("trait.old"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() > 0)
		{
			this.m.Swordmaster = candidates[this.Math.rand(0, candidates.len() - 1)];
			this.m.Score = this.m.Swordmaster.getLevel();
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"swordmaster",
			this.m.Swordmaster.getName()
		]);
	}

	function onClear()
	{
		this.m.Swordmaster = null;
	}

});

