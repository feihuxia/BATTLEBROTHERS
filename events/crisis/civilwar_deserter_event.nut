this.civilwar_deserter_event <- this.inherit("scripts/events/event", {
	m = {
		NobleHouse = null,
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.crisis.civilwar_deserter";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 50.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_02.png[/img]{你在路上遇到了%noblehouse%军队的两个士兵，他们好像要吊死一个自己人。那人的脑袋套在套索里，但一看到你就叫了出来。%SPEECH_ON%他们想要我杀孩子！这就是我不服从命令的下场？%SPEECH_OFF%%randombrother%带着一种‘也许我们能做点什么’的表情看着你。  |  你发现%noblehouse%军队的两个人正要吊死一个蒙着眼睛的人。你好奇地问了他犯了什么罪。一个刽子手大笑。%SPEECH_ON%他接到烧毁村庄的命令，但是拒绝服从。不想这种事发生，就不要拒绝贵族，%SPEECH_OFF%被蒙住眼睛的人吐了口痰。%SPEECH_ON%都下地狱去吧。最起码我到死都保持了自己的尊严和荣耀。%SPEECH_OFF%   |  你看到路边有个人正把绳索抛上树枝。另一个人推搡着一个蒙着眼睛的囚犯往前走，还拉扯着他脖子上的套索。刽子手们看到了你，于是举起手。%SPEECH_ON%退后，佣兵。这个人将在%noblehouse%的命令下被处以死刑。一旦干涉，你就要以类似的方式被处决。%SPEECH_OFF%囚犯大声叫道。%SPEECH_ON%他们想让我屠杀妇女和孩子。这就是我抗命的代价，但至少我能带着完整的荣耀离开这可怕的世界。%SPEECH_OFF%   |  道路通向坐在草地上的带着枷锁的男人，另外两个人正生气地把绳索挂到树枝上。他们用力地拉扯了几下测试牢固性，然后点点头，在下面放了个木桶，大概是让囚犯站上去用的。囚犯看到你，叫了出来。%SPEECH_ON%佣兵，救救我！我不过是拒绝烧毁一座神庙而已！%SPEECH_OFF%其中一个刽子手踢了他一脚。%SPEECH_ON%那座庙里窝藏了叛军，杀害我们中尉的叛军，蠢货！这种后果你比谁都活该。如果%noblehouse%要赢这场战争，我们就不能让你这种叛徒呆在我们中间。%SPEECH_OFF%}",
			Banner = "",
			Characters = [],
			Options = [
				{
					Text = "放开他！",
					function getResult( _event )
					{
						local roster = this.World.getTemporaryRoster();
						_event.m.Dude = roster.create("scripts/entity/tactical/player");
						_event.m.Dude.setStartValuesEx([
							"deserter_background"
						]);
						_event.m.Dude.setTitle("the Honorable");
						_event.m.Dude.getBackground().m.RawDescription = "Once a soldier of a noble army, %name% was almost hanged for refusing orders, until rescued by you and the %companyname%.";
						_event.m.Dude.getBackground().buildDescription(true);

						if (_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
						{
							_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand).removeSelf();
						}

						if (_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
						{
							_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand).removeSelf();
						}

						if (_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Head) != null)
						{
							_event.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Head).removeSelf();
						}

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
					Text = "关你屁事。",
					function getResult( _event )
					{
						return "D";
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
			Text = "[img]gfx/ui/events/event_02.png[/img]{你命令刽子手让他走，他们大笑着拔出剑，但那差不多是他们最后的动作了，因为%companyname%带着愤怒降临在他们身边，瞬间砍掉了两个士兵。囚犯感谢了你，作为营救他的回报，他愿意为你而战。  |  你不支持这样的处决，命令%companyname%的人进行干涉。他们迅速拔出武器，降落到士兵身边，瞬间击杀了他们。获救的囚犯跪倒在你面前。%SPEECH_ON%请让我加入你的队伍，我能做的只有这么多！%SPEECH_OFF%   |  你命令%companyname%救下囚犯。自以为是刽子手的人瞬间被斩于刀下似乎是很奇怪的景象。这样的翻转带来了疯狂的，女人般的尖叫。如果他们不逃跑，你的手下能让事情迅速解决，但急于保命的人通常都死得最慢。同时，囚犯跪在你面前想要效忠于你。}",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "欢迎加入%companyname%！",
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						return 0;
					}

				},
				{
					Text = "回去找你家人吧，士兵。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationUnitKilled);
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_02.png[/img]{你下令放了那人。其中一名士兵拔出了剑，然而立即就被教做人了。另一个士兵似乎脑子机灵点，已经拔腿就跑了。无疑他会将你的所作所为告诉%noblehouse%。获救的囚犯走到你身前，躬身几近要下跪。%SPEECH_ON%佣兵，多谢你。从此我这条命就是你的了。%SPEECH_OFF%   |  你心想两名刽子手不太可能抛弃高贵的家族加入你。但是如果让囚犯重获自由，那他还是有可能为你而战的。因此你下令放了他。其中一名士兵拔剑高喊誓死效忠%noblehouse%。那是他能做的最后一件事。另一名士兵落荒而逃。或许你有招募他的可能性，但鉴于他的同伴死于你的刀下，他不太可能回来的。他很可能将你的所作所为上报给上级了。\n\n 你前去释放囚犯。他匆忙躬身感谢并宣称为%companyname%而战。  |  你命令士兵放开囚犯。一名士兵大笑着紧了紧囚犯脖子上的绳子，然后就开始执行绞刑。%randombrother%跃身上前，一把将刽子手打翻在地。他用石头猛揍着士兵的脸，而另外一名士兵拔腿鼠窜。他明显是跑去将你的行为上报给指挥官了。\n\n 重获自由的囚犯来到你身前躬身致敬，并向你宣誓效忠以报答救命之恩。}",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "欢迎加入%companyname%！",
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						return 0;
					}

				},
				{
					Text = "回去找你家人吧，士兵。",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Killed one of their men");
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_02.png[/img]{虽然无视命令不能怪那人，但命令并非你下达的，就像惩罚也是他来承担，并非是你。你命令%companyname%继续前进。  |  没有理由让%companyname%卷入贵族的政治风暴总。囚犯理解地点点头。直到死的那一刻，他仍高昂着头颅。  |  刽子手看向你，或许是感觉到你是来找茬的。但你并没有，反而上前告诉囚犯落到如今这地方是他咎由自取。他脸色肃穆地点点头。刽子手匆忙吊死了他，以免这个危险的陌生人突然改变心意。}",
			Banner = "",
			Characters = [],
			List = [],
			Options = [
				{
					Text = "他的战争并非是我们的。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().getID() == "background.deserter")
					{
						bro.worsenMood(0.75, "You didn\'t help a deserting lieutenant");

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

		if (this.World.getPlayerRoster().getSize() >= this.World.Assets.getBrothersMax())
		{
			return;
		}

		local playerTile = this.World.State.getPlayer().getTile();
		local towns = this.World.EntityManager.getSettlements();
		local bestDistance = 9000;
		local bestTown;

		foreach( t in towns )
		{
			local d = playerTile.getDistanceTo(t.getTile());

			if (d <= bestDistance)
			{
				bestDistance = d;
				bestTown = t;
				break;
			}
		}

		if (bestTown == null)
		{
			return;
		}

		this.m.NobleHouse = bestTown.getOwner();
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
		this.m.Dude = null;
	}

});

