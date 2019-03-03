this.aging_swordmaster_event <- this.inherit("scripts/events/event", {
	m = {
		Swordmaster = null
	},
	function create()
	{
		this.m.ID = "event.aging_swordmaster";
		this.m.Title = "路上…";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[Img]gfx/ui/events/event_17.png[/img]你发现%swordmaster%缓慢而艰难地往树桩上坐。他慢慢地坐下去，你听见他的腿发出吱吱的声音，好像弯曲不聊了似的。他坐下后，长叹了一声。他的剑在他旁边。剑比它的主人年轻，因为不知换了多少吧。他好像不太喜欢它，但他握住剑的时候，你会感觉到他手上对的剑好像变成他身体的一部分，透出冰冷的杀起。你转身离开，想给剑豪一点私人时间，但他注意到你想离开，喊了你一生。%SPEECH_ON%嘿，队长，抱歉让你看到这一幕。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "你怎样？",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "呃，我看见了。走吧。",
					function getResult( _event )
					{
						return "E";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Swordmaster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_17.png[/img]他向后一靠，伸出长满茧子的手揉着膝盖。一阵风吹来，拂动着他灰色的头发。%SPEECH_ON%老了。就是这样。而我不是说我的年纪。这么多年，我已经老了很久了。我是说我的骨头已经生锈了。这些年我靠名声就把任务搞定了，我已经很久没出过手了。%SPEECH_OFF%你立即反驳，跟他说他是你见过最致命的剑豪。%SPEECH_ON%这些甜言蜜语留着跟女人说吧，提修斯。我的眼睛慢慢地不行了。你可能不喜欢听，但没办法。我的双腿已经不像从前那样了。膝盖卡卡作响，肿了起来。总有一天会坏事的。我的左手已经没有感觉了。%SPEECH_OFF%剑豪握了握左手。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "有什么感觉？",
					function getResult( _event )
					{
						return "C";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Swordmaster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_17.png[/img]%SPEECH_ON%什么也没有。我觉得神经已经坏死了。有时候我还会忘事。不是说我忘记把靴子放在哪了。有时候我会忘记身后有没有人。还有我对周围环境观察力——这是我真正的剑——已经钝了。时间在磨掉我的速度和直觉，缓慢却又不可阻挡，没什么波澜，但却逐渐消失。我一向觉得我会被其他剑豪超过。才华横溢的剑豪。现在看来我的剑太厉害了。%SPEECH_OFF%剑豪笑了笑，笑容非常耐人寻味。你问他时不时害怕没有荣耀地死去。%SPEECH_ON%很早之前我就悟到一个道理，一旦拥有与我等量的名气，哪条路走到最后都是失望在等着你。他们会在书中记载某个人杀死了大剑师，毁掉我的名声。胡说八道。如果你想听真话我就告诉你把。我害怕我的预感会成真。我的身体最终会背叛我。时间是它的武器，我的身体慢慢地杀死我。膝盖慢慢僵硬，手指越来越无力，肩膀慢慢地垮下去。我不怕死。死神不敢来在我，它只能等待。杀死我的是我的身体，然后死亡才有机会，这个混蛋。而作家和历史学家呢？去他们的。如果想要青史留名的话我早就去单挑一支军队了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "据说我知，你已经载入史册了。",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Swordmaster.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_17.png[/img]剑豪微微一笑了。%SPEECH_ON%好吧，队长。帮我站起来把，该上路了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "时间流逝。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Swordmaster.getImagePath());
				local old_trait = this.new("scripts/skills/traits/old_trait");
				_event.m.Swordmaster.getSkills().add(old_trait);
				_event.m.Swordmaster.setHitpoints(this.Math.min(_event.m.Swordmaster.getHitpoints(), _event.m.Swordmaster.getHitpointsMax()));
				this.List = [
					{
						id = 13,
						icon = old_trait.getIcon(),
						text = _event.m.Swordmaster.getName() + " has gotten older"
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_17.png[/img]你走开的时候听见老剑豪叹了一口气。好像跟上佣兵团的速度对他来说就已经是战斗了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "时间流逝。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Swordmaster.getImagePath());
				local old_trait = this.new("scripts/skills/traits/old_trait");
				_event.m.Swordmaster.getSkills().add(old_trait);
				_event.m.Swordmaster.setHitpoints(this.Math.min(_event.m.Swordmaster.getHitpoints(), _event.m.Swordmaster.getHitpointsMax()));
				this.List = [
					{
						id = 13,
						icon = old_trait.getIcon(),
						text = _event.m.Swordmaster.getName() + " has gotten older"
					}
				];
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getLevel() >= 9 && bro.getBackground().getID() == "background.swordmaster" && !bro.getSkills().hasSkill("trait.old"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() > 0)
		{
			this.m.Swordmaster = candidates[this.Math.rand(0, candidates.len() - 1)];
			this.m.Score = this.m.Swordmaster.getLevel() - 5;
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

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Swordmaster = null;
	}

});

