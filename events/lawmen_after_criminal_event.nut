this.lawmen_after_criminal_event <- this.inherit("scripts/events/event", {
	m = {
		Criminal = null,
		OtherBro = null,
		NobleHouse = null
	},
	function create()
	{
		this.m.ID = "event.lawmen_after_criminal";
		this.m.Title = "沿路行走…";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_90.png[/img]骑手抵达附近一座山丘的顶部，他们古怪的黑色剪影轮廓就像是泛起黑色涟漪的礁石。你无法看清他们到底是谁，你下令让一些你的弟兄躲了起来。你或许还需要伏击来进行防守，否则面对这样的骑兵大军，你是毫无胜算的。当被选中的雇佣兵们躲进树丛时，骑兵们开始往山下行进。马蹄的踏鸣逐渐变响，但是你依然坚定地站着，希望能给你的手下勇气。\n\n你看到骑手举着%noblehousename%魔印。在他身后，另一个骑手拖着雪橇，上面运送着几个被困着的人。当那个人抵达的时候，他们的领导者站在马的鬐甲中间，在说话之前指着你。%SPEECH_ON%雇佣兵！奉领主之令，我们有权宣布 — 铐起来！— %criminal%先生！说话的人就在你们中间。他必须为自己的罪行付出代价。立刻把他交出来，你就能得到奖赏。%SPEECH_OFF%你把头转开，朝地上啐了一口。你在询问执法者问题之前，朝他点了点头。%SPEECH_ON%那你又有谁给你权力？这片大陆上有很多的领主，他们也不是所有人都会给我个好价钱。%SPEECH_OFF%执法者的队长坐回到他的马背上。他的手跨在马鞍上，带着那着甲的权力，休息着。他看上去完全没有觉得愉快，大声宣泄着自己的不满。%SPEECH_ON%故意包庇逃亡者的惩罚可是死亡。我再给你以此机会，把最烦交给我，否则你将好好感受到一个剑士走狗的命运。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Banner = [],
			Options = [
				{
					Text = "如果我们反抗，只会为战团带来麻烦。你可以把人带走。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "我们不会交出他。",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				if (this.World.Assets.getMoney() >= 1500)
				{
					this.Options.push({
						Text = "难道这件事就不能用一大袋克朗来解决吗？",
						function getResult( _event )
						{
							return "F";
						}

					});
				}

				if (this.World.Assets.getBusinessReputation() > 3000)
				{
					this.Options.push({
						Text = "你知道你在威胁谁吗？我们可是%companyname%。",
						function getResult( _event )
						{
							return "G";
						}

					});
				}
				else
				{
					this.Options.push({
						Text = "你有通缉犯的画像吗？然我看一下。",
						function getResult( _event )
						{
							return this.Math.rand(1, 100) <= 50 ? "D" : "E";
						}

					});
				}

				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Criminal.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_53.png[/img]你根本没有机会打赢这些人。尽管你很不情愿，但你还是将%criminal%交了出去。他一边咒骂着你，一边被执法者们带走了。执法者的队长驾马来到你面前。他冷笑着将一袋钱币丢在了你面前的地上。他的身体离你很近，你发现他的护甲上有一个缺口。这个缺口正好够一把小刀插进去，只要你瞄的准，就可以做到一刀毙命。但即便如此，这场胜利也只会是暂时的，因为你的所有手下都会被迅速灭杀。\n\n所以，你放下了自己的尊严，弯腰拾起钱袋，并道了一声谢。那些执法者很快便离去了。",
			Image = "",
			List = [],
			Characters = [],
			Banner = [],
			Options = [
				{
					Text = "我不能为了你而让整个战团陷入危险。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Criminal.getImagePath());
				this.List.push({
					id = 13,
					icon = "ui/icons/asset_brothers.png",
					text = _event.m.Criminal.getName() + " has left the company"
				});
				this.World.getPlayerRoster().remove(_event.m.Criminal);
				this.World.Assets.addMoney(100);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你获得 [color=" + this.Const.UI.Color.PositiveEventValue + "]" + 100 + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_10.png[/img]就在执法者注视着你并等待回答的时候，你吹了一个尖锐的口哨。一半战团的成员从树丛中蹿出，高呼着发起了突袭。拖着囚犯的战马受到了惊吓，将骑手摔在地上然后自己跑开了。一群囚犯也跟着它逃离。另一名执法者不顾自己的队伍，擅自脱逃了。\n\n%randombrother%将一个人从马鞍上拽了下来，另一名弟兄则用枪刺穿了战马的胸膛，使骑手连人带马翻到在地。那位队长也因战马受惊而跌下马来。这一跤可摔得不轻，在他全力爬起身来之后，等来的却是来自马蹄的强力一击。这一击命中了他的头部，在他的头盔上留下了深深的凹痕，同时他也一命呜呼。\n\n其他的执法者围到了队长的身边，他们扭头看着你，眼中充满了恨意。",
			Image = "",
			List = [],
			Characters = [],
			Banner = [],
			Options = [
				{
					Text = "冲啊！",
					function getResult( _event )
					{
						_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationAttacked, "You killed some of their men");
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.NobleTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						properties.TemporaryEnemies = [
							_event.m.NobleHouse.getID()
						];
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Noble, this.Math.rand(80, 100) * _event.getReputationToDifficultyLightMult(), _event.m.NobleHouse.getID());
						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Criminal.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_78.png[/img]执法者的队长朝其中一个骑手打了个响指。他递过来一个卷轴，在递给你之前，打开了它。你看到的那个人像极了%criminal%，但是你们已经赶了不少路，雇佣兵们的脸上都多少烙印上了伤痕，和纸上的人已经有所区别。但是他们才不吃这套。所以你选择撒谎。%SPEECH_ON%你寻找的那个人已经死了。他是个最烦，正如你所说的，我们发现他偷我们的食物。当我们发现的时候，%other_bro%已经杀了他。%SPEECH_OFF%那个弟兄看了看你，又看了看执法者。他点了点头。%SPEECH_ON%是我干的。他吃了我的面包，然后被我当成猪一样捅了。感谢上帝，我救下了剩下的面包。%SPEECH_OFF%执法者们发出了咯咯的笑声。他们的队长回头看了一眼他们，他的凝视让他们安静了下来。他看向你。你可以看出来他们为什么闭嘴了：他的眼神异常严厉，那是双静止，凶残的漆黑之眼。那个人用眼神盯着你整整半分钟，然后点了了点头，拉起了缰绳。%SPEECH_ON%好吧，雇佣兵。谢谢你告诉我们。%SPEECH_OFF%执法者们整装重回到自己的地盘去了。整个战团都松了口气，然后你让那个躲在树丛里的人出来。前路漫漫，你希望这样的问题不要再出现了。",
			Image = "",
			List = [],
			Characters = [],
			Banner = [],
			Options = [
				{
					Text = "Phew.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Criminal.getImagePath());
				_event.m.Criminal.improveMood(2.0, "Was protected by the company");

				if (_event.m.Criminal.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Criminal.getMoodState()],
						text = _event.m.Criminal.getName() + this.Const.MoodStateEvent[_event.m.Criminal.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_78.png[/img]队长把一幅画着%criminal%的卷轴交给你。没错，有相似之处。但是那个人在你的战团里已经很久，身上多了很多伤痕。或许他们不会注意到是他呢？你让那个罪犯走上前来，他紧张地照做了。你看向队长。%SPEECH_ON%这是你们在找的人吗？我明白你为什么觉得他是那个罪犯，但是看看这些伤疤。画里的人可没有这些伤疤。再看看他的头发！画里的那个人是直发，这个人很明显有着一头凌乱的卷发。%SPEECH_OFF%你停了下来，通过哪些观众的表情，你发现这样做根本没用。队长拔出了剑。%SPEECH_ON%你把我当傻子吗？把他们都杀了。%SPEECH_OFF%到此为止了。在执法者发起冲锋之前，你用最大的声音吹起了口哨。战团有一半人从树丛里涌上前来，像是报丧女妖一样大喊着。突然的战斗让马儿们发狂，把上面骑马的人给摔到了地上，马拉雪橇也连同里面困惑的几个罪犯一起，掉了下来。\n\n%randombrother%手里拿着长枪，穿过混乱的场地冲了过来。他把长矛狠狠地扎进队长的战马，让任何马一起摔在了地上。剩下的那些执法者聚集到他们队长的身边。那个人似乎在咆哮，他擦掉脸上的血，从嘴里吐出了一颗牙齿。他在下令让手下发起冲锋之前，露出了可怕的笑容。",
			Image = "",
			List = [],
			Characters = [],
			Banner = [],
			Options = [
				{
					Text = "组成阵型！",
					function getResult( _event )
					{
						_event.m.NobleHouse.addPlayerRelation(this.Const.World.Assets.RelationAttacked, "You killed some of their men");
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						properties.Music = this.Const.Music.NobleTracks;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						properties.TemporaryEnemies = [
							_event.m.NobleHouse.getID()
						];
						_event.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Noble, this.Math.rand(80, 100) * _event.getReputationToDifficultyLightMult(), _event.m.NobleHouse.getID());
						this.World.State.startScriptedCombat(properties, false, false, true);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Criminal.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_04.png[/img]在你拿出一大袋克朗之后，场面逐渐冷静了下来。在你举起钱袋的时候，那位队长的手下们相互看了一眼。%SPEECH_ON%我们没必要拼个你死我活。我这里有%bribe%克朗。你们拿上它离开吧。如果不走，那这里将会是你们的墓地。选择权在你们手里，执法者们。%SPEECH_OFF%在注意到自己手下们的目光之后，那位队长仔细考虑了一下当前的局势。他打量了一下你的队伍，然后扫了一眼自己的队伍。在认识到自己处于绝对劣势之后，他最终点头同意了。在勒紧了自己战马的缰绳之后，他来到了你的面前。你微笑着将钱交给他。%SPEECH_ON%好好享受吧。%SPEECH_OFF%那位队长接过了钱袋，然后把它挂在马鞍旁旁。接着，他在自己属下的注视中，将剑收回了鞘中。他点了点头，但脸上没有一丝笑容。%SPEECH_ON%我女儿还有两周就要结婚了。我要去参加她的婚礼。%SPEECH_OFF%你点了点头，然后与这位不苟言笑的队长告别了。%SPEECH_ON%愿她有一个好丈夫，愿她的孩子们健健康康。%SPEECH_OFF%这位队长掉转马头回到自己的队伍中。他们离去了，整个马队逐渐消失在远处，只留下风中飞扬的草屑。",
			Image = "",
			List = [],
			Characters = [],
			Banner = [],
			Options = [
				{
					Text = "看来我要赌一把了……",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Criminal.getImagePath());
				this.World.Assets.addMoney(-1000);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "你花[color=" + this.Const.UI.Color.NegativeEventValue + "]" + 1000 + "[/color] 克朗"
				});
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_12.png[/img]你朝那位队长走去，，并停在了双方队伍中间。你高声向那些执法者问道，他们是否听说过%companyname%的大名。你看到一些骑手在马鞍上仰起头来，努力去辨识你的战团旗帜。随后他们迅速返回了自己的阵线，然后开始窃窃私语。\n\n其中一个人向你发问，问你是否割下了你斩杀之人的鼻子。这当然不是真的，但你也没有理由现在就捅破这个流言。另一个问%randombrother%是不是在你的队伍中，还问他是不是有一个用耳朵做成的项链并且把骨粉当早餐吃。你屏住自己的笑意，一一点头作答。显然，你的对手们已经被这些流言所蛊惑，开始怀疑这场战斗根本毫无胜算。\n\n虽然他们的队长声称你所说的都是谎言并下令发动进攻，但没有人听从他的指令。最终，这位队长不得不转身离去，与他的队伍一同撤离。\n\n那位被当作是食人族的弟兄走到你跟前，挠了挠自己的头。%SPEECH_ON%把骨粉当早餐吃？%SPEECH_OFF%战团中随后爆发出一阵大笑。看来用不了多久，世间就会传唱着‘不要吃我呀！’这样的歌谣。",
			Image = "",
			List = [],
			Characters = [],
			Banner = [],
			Options = [
				{
					Text = "不要试图挑战%companyname%！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = _event.m.NobleHouse.getUIBannerSmall();
				this.Characters.push(_event.m.Criminal.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().Days < 10)
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		if (this.World.FactionManager.isGreaterEvil())
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (!currentTile.HasRoad)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		if (brothers.len() < 2)
		{
			return;
		}

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.killer_on_the_run" || bro.getBackground().getID() == "background.thief" || bro.getBackground().getID() == "background.graverobber" || bro.getBackground().getID() == "background.raider")
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.NobleHouse = this.getNearestNobleHouse(this.World.State.getPlayer().getTile());

		if (this.m.NobleHouse == null)
		{
			return;
		}

		this.m.Criminal = candidates[this.Math.rand(0, candidates.len() - 1)];

		do
		{
			this.m.OtherBro = brothers[this.Math.rand(0, brothers.len() - 1)];
		}
		while (this.m.OtherBro == null || this.m.OtherBro.getID() == this.m.Criminal.getID());

		this.m.Score = candidates.len() * 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"criminal",
			this.m.Criminal.getName()
		]);
		_vars.push([
			"other_bro",
			this.m.OtherBro.getName()
		]);
		_vars.push([
			"noblehousename",
			this.m.NobleHouse.getName()
		]);
		_vars.push([
			"bribe",
			"1000"
		]);
	}

	function onClear()
	{
		this.m.Criminal = null;
		this.m.OtherBro = null;
		this.m.NobleHouse = null;
	}

});

