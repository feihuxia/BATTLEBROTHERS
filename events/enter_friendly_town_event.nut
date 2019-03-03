this.enter_friendly_town_event <- this.inherit("scripts/events/event", {
	m = {
		Town = null
	},
	function create()
	{
		this.m.ID = "event.enter_friendly_town";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_85.png[/img]{你来到 %townname% 看来引发了一些庆祝。有一个镇子里的议会议员向你问好， 提供了一些饮料。| %townname% 显示出他对你所做的事情的感激给了你和你的人一盘点心。%randombrother%砸碎了几个杯子， 少女一般敬畏的表情在他脸上。他擦拭着他的嘴。%SPEECH_ON%非常感谢。请再来一些。%SPEECH_OFF% |%townname%那你的事业对当地人是有益处的他们看起来非常感谢你:在今天他们给你 {太多的毫无意义的感激 | 风暴般的感激 | 对你来说毫无意义的鲜花 | 在这些农民没有发现的时候你把那些小东西都扔掉了 |一小盘苹果酒你很快就喝掉了 | 一小桶苹果酒你的人称之为 \'有点味道的木头\' | 几次结婚请求被你婉拒掉了| 几个结婚请求你无法很快拒绝 |小镇里一个丑女的结婚请求。他的脸简直丑得遮天蔽日。你拒绝了请求 |几个人在胡乱地起着哄。他们的语气似乎很高兴， 反正是那样| 有几个人拍着背。你提醒他们这种行为可能导致他们在下一轮的时候会发现自己的手没有了 | 一个孤儿的请求。你不知道是什么让他们觉得你会接受这个礼物， 但是你把这些孩子送回他们的家里， 就是所谓的街道}。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "在那里 %townname%一切都很好。",
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
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();
		local nearTown = false;
		local town;

		foreach( t in towns )
		{
			if (t.isMilitary())
			{
				continue;
			}

			if (t.getTile().getDistanceTo(playerTile) <= 3 && t.isAlliedWithPlayer() && t.getFactionOfType(this.Const.FactionType.Settlement).getPlayerRelation() > 80)
			{
				nearTown = true;
				town = t;
				break;
			}
		}

		if (!nearTown)
		{
			return;
		}

		this.m.Town = town;
		this.m.Score = 15;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.Town = null;
	}

});

