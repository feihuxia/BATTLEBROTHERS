this.choose_ambition_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.choose_ambition";
		this.m.Title = "营地…";
		this.m.HasBigButtons = true;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_58.png[/img]{一股清新的微风正在吹拂，你感觉是%companyname%改头换面的好时机。你集合了所有人……\n\n跟他们说什么？ | 你今天感觉很不错，已经准备好带领%companyname%穿越任何以及一切的艰辛困难了。你将所有人集合了起来，给%randombrother%来一一脚然后叫%randombrother2%过会再去挠脖子后面的头发。当他们的嘀咕声终于停下来之后，你开始跟他们讲话。\n\n你要告诉战团里的人们什么？ | 作为传统项目，你向大伙解释了战团的下一个目标。%SPEECH_ON%兄弟们，%companyname%必须让世界知道铸就我们的火焰比其他佣兵战团的要灸热十万倍。当我们的名声开始成长之后，随之而来的克朗也会变得越来越多。让我们共铸一条通往伟大的道路！%SPEECH_OFF%你告诉大伙们战团要做什么？ | 当战团修整时，你决定发表一次演讲。%SPEECH_ON%兄弟们，我想要所有人都知道%companyname%不只是一群杀手和信使，我们是最顶尖的老练战士。我们的事迹必须让众人皆知，这样子商人们和贵族们就会求着我们去接受他们的合约。%SPEECH_OFF%你将告诉战团里的大伙们下一步该怎么做？ | 在跟大伙一起坐着打磨刀剑，擦亮铠甲，嬉笑打闹的时候，你的念头瞬间飘到了一个新的点子上：提升战团的名声，让整个大陆都知道你们的名字。\n\n你的决定是什么，你要跟人们说什么？ | 职责在指挥官，你的身上，战团的成功不止要在战场沙灰姑娘，还要在名誉与财富的战场上成功。于是你花了整个晚上在你的帐篷里面思考着为%companyname%准备的大计划，大伙们则在篝火旁边聊着天。光是追捕倒着，做些小合同，这辈子都不可能成为传奇的。\n\n你将要战团里的人们宣布什么样的计划？}",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			Banner = "",
			function start( _event )
			{
				this.Banner = "ui/banners/" + this.World.Assets.getBanner() + "s.png";
				local selection = this.World.Ambitions.getSelection();
				this.Options = [];

				foreach( i, s in selection )
				{
					this.Options.push(_event.createOption(s));
				}
			}

		});
	}

	function createOption( _s )
	{
		return {
			Text = _s.getButtonText(),
			Icon = "ui/icons/ambition.png",
			function getResult( _event )
			{
				this.World.Ambitions.setAmbition(_s);
				return 0;
			}

		};
	}

	function onUpdateScore()
	{
		return;
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

