this.bad_omen_event <- this.inherit("scripts/events/event", {
	m = {
		Superstitious = null,
		OtherGuy = null
	},
	function create()
	{
		this.m.ID = "event.bad_omen";
		this.m.Title = "路上…";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "{[img]gfx/ui/events/event_12.png[/img]突然传来一阵哭声。但是附近没有敌人，你不知道这声音从哪来的。你穿过人群发现%superstitious%跪在地上大哭。他一只手抱着胸口，一支手指着天空，手指剧烈地颤抖着。%otherguy%解释说这个家伙看见天空的星星中爆出一团火焰。显然这混蛋把陨石当做是末日启示了。不管是什么，队伍也不能停下来，你下令继续前进。| [img]gfx/ui/events/event_12.png[/img]阴影慢慢地淡了，光线变得很奇怪。你转身发现有一块黑斑正在吞噬着太阳。很快太阳就全黑了。%superstitious%大喊审判日已经到来了，但他还没来得及喊出第二句话，黑斑又消失了，好像什么也没发生过。你让这混蛋站起身来。哭是解决不了问题的，你下令继续前进。| [img]gfx/ui/events/event_11.png[/img] %superstitious%突然拔出剑指着一个兔子洞大喊。他猛地从兔子洞旁跳开，尖叫着，洞里有两只兔子。显然这又是什么不吉利的兆头。不过你想的是晚上又可以加菜了。| [img]gfx/ui/events/event_11.png[/img]你从一棵树下走过，树枝上坐着一只黑猫和一只患白化病的牛。%superstitious%看见后大喊，说这肯定是末日审判的征兆。这混蛋，一惊一乍的。什么事到了他眼里都是征兆。烦人。| [img]gfx/ui/events/event_11.png[/img]你看见一个鹿的头骨。你不觉得这是什么重要的东西，但%superstitious%一脸严肃地捡了起来。他转动头骨的时候，流出了傻子。他双手颤抖中，把头骨扔了出去。摔在地上声音很空洞。这家伙吓坏了，说占卜者有次高数他说，他会碰上这样子的头骨。\n\n你反驳说这种头骨随处可见，因为生老病死是很正常的。你的话他一句也没听进去，他心事重重地回到了队伍中。| [img]gfx/ui/events/event_11.png[/img] 无聊的行进中，几个人开始猜天上的云是什么形状。他们开玩笑说这朵像是一只狗，那朵像是胖女人，甚至还有像家的，但游戏越玩越认真，%superstitious%看见一朵奇怪的云后跪了下来。他大喊道这征兆非常不激励，战团会遇到麻烦。幸好其他人没有把这话当真，他们很快地开玩笑说那朵云像不像%randombrother%的男棍。｝",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "{振作起来！| 只有小孩子才会感到害怕。}",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Superstitious.getImagePath());
				local effect = this.new("scripts/skills/effects_world/afraid_effect");
				_event.m.Superstitious.getSkills().add(effect);
				_event.m.Superstitious.worsenMood(1.0, "Has seen a bad omen");
				this.List.push({
					id = 10,
					icon = effect.getIcon(),
					text = _event.m.Superstitious.getName() + " is afraid"
				});

				if (_event.m.Superstitious.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Superstitious.getMoodState()],
						text = _event.m.Superstitious.getName() + this.Const.MoodStateEvent[_event.m.Superstitious.getMoodState()]
					});
				}
			}

		});
	}

	function onUpdateScore()
	{
		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2 || !this.World.getTime().IsDaytime)
		{
			return;
		}

		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getSkills().hasSkill("trait.superstitious") && !bro.getSkills().hasSkill("effects.afraid"))
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			return;
		}

		this.m.Superstitious = candidates[this.Math.rand(0, candidates.len() - 1)];
		this.m.Score = candidates.len() * 10;

		foreach( bro in brothers )
		{
			if (bro.getID() != this.m.Superstitious.getID())
			{
				this.m.OtherGuy = bro;
				break;
			}
		}
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"superstitious",
			this.m.Superstitious.getName()
		]);
		_vars.push([
			"otherguy",
			this.m.OtherGuy.getName()
		]);
	}

	function onClear()
	{
		this.m.Superstitious = null;
		this.m.OtherGuy = null;
	}

});

