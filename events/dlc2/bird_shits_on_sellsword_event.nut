this.bird_shits_on_sellsword_event <- this.inherit("scripts/events/event", {
	m = {
		Victim = null,
		Superstitious = null,
		Archer = null,
		Historian = null
	},
	function create()
	{
		this.m.ID = "event.bird_shits_on_sellsword";
		this.m.Title = "一路上...";
		this.m.Cooldown = 60.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "%terrainImage%{当大家还在四处游历时，%birdbro%却遭到了鸟粪的热情款待。鸟粪精准的命中了他的武器，并且溅在了他的盔甲上。%SPEECH_ON%啊啊啊！啊啊啊啊啊啊！%SPEECH_OFF% 他看着这些令人抓狂的污渍，手臂如鸡翅一般胡乱扑腾着 %SPEECH_ON%草，真吉尔倒霉! %SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "好了，别纠结这点破事了，我们还要赶路呢。",
					function getResult( _event )
					{
						if (_event.m.Historian == null)
						{
							return "Continue";
						}
						else
						{
							return "Historian";
						}
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Victim.getImagePath());

				if (_event.m.Superstitious != null)
				{
					this.Options.push({
						Text = "这难不成是什么预兆？",
						function getResult( _event )
						{
							return "Superstitious";
						}

					});
				}

				if (_event.m.Archer != null)
				{
					this.Options.push({
						Text = "来人给我搞定这个长着羽毛的罪犯！！",
						function getResult( _event )
						{
							return "Archer";
						}

					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Continue",
			Text = "%terrainImage%{%birdbro% 点了点头. %SPEECH_ON%当然。美好的一天就这么被彻底毁掉了。%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "唉，行吧……",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Victim.getImagePath());
				_event.m.Victim.worsenMood(0.5, "Got shit on by a bird");

				if (_event.m.Victim.getMoodState() <= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Victim.getMoodState()],
						text = _event.m.Victim.getName() + this.Const.MoodStateEvent[_event.m.Victim.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Superstitious",
			Text = "%terrainImage%{有点迷信的 %superstitious% 用堪比珠宝商一样的眼神分析了这坨鸟粪。他噘着嘴，点了点头，一如既往的给鸟粪做了一段不错的解释。他说。%SPEECH_ON%这是件好事啊。%SPEECH_OFF%面对众人及其不信任的表情，他冷静地解释道，被鸟儿盯上是即将发生好事的预兆。一部分的雇佣兵似乎还被说服了。能被一只鸟唯独选中去来一泡，感觉确实是一件十分奇妙的事情。你点了点头并表示 %birdbro% 再遇到这种事应该尽可能张着嘴，以获得额外的好运。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "幸运的家伙。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Victim.getImagePath());
				this.Characters.push(_event.m.Superstitious.getImagePath());
				_event.m.Victim.improveMood(1.0, "Got shit on by a bird for good luck");

				if (_event.m.Victim.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Victim.getMoodState()],
						text = _event.m.Victim.getName() + this.Const.MoodStateEvent[_event.m.Victim.getMoodState()]
					});
				}

				_event.m.Superstitious.improveMood(0.5, "Witnessed " + _event.m.Victim.getName() + " being shat on by a bird");

				if (_event.m.Superstitious.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Superstitious.getMoodState()],
						text = _event.m.Superstitious.getName() + this.Const.MoodStateEvent[_event.m.Superstitious.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Archer",
			Text = "[img]gfx/ui/events/event_10.png[/img]{%archer% 抬起了头，双手为眼睛遮蔽了阳光，仔细观察着。他看着天上的鸟并点了点头。随后舔了舔指尖，并伸在半空中，随后他又点了点头。弓箭手笑着从箭袋中拿出弓箭上弦。%SPEECH_ON% 罪犯必须受到惩罚 %SPEECH_OFF%雇佣兵们低声嘲笑着他的道德论，但他看起来很冷静，并且很快射出了一箭。你只是看着箭矢飞速的消失在了空中不见了踪影，但你看到了鸟忽然失衡，并且坠向大地。弓箭手笑着点了点头，随后看向了自己的战友，%SPEECH_ON%你们再笑？%SPEECH_OFF%但这只迎来了更多地嘲笑声。弓箭手用这种方法，狡猾的解释了他在团队中的重要性，并且为这些前排肉盾和后排输出之间提供了一次友好的辩论。你告诉这些人，如果真的想要讨论出一个结果，还需要看战场上表现才能揭晓答案。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "干得漂亮！",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Victim.getImagePath());
				this.Characters.push(_event.m.Archer.getImagePath());
				_event.m.Victim.improveMood(0.5, "Got revenge on a bird that shat on him");

				if (_event.m.Victim.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Victim.getMoodState()],
						text = _event.m.Victim.getName() + this.Const.MoodStateEvent[_event.m.Victim.getMoodState()]
					});
				}

				_event.m.Archer.improveMood(1.0, "Exacted revenge on a bird that shat on " + _event.m.Victim.getName() + " with pinpoint accuracy");

				if (_event.m.Archer.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Archer.getMoodState()],
						text = _event.m.Archer.getName() + this.Const.MoodStateEvent[_event.m.Archer.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Archer.getID() || bro.getID() == _event.m.Victim.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 25)
					{
						bro.improveMood(1.0, "Witnessed " + _event.m.Archer.getName() + "\'s fine display of archery");

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
		this.m.Screens.push({
			ID = "Historian",
			Text = "%terrainImage%{你告诉 %birdbro% 运气差只是生活的一部分随后要求部队继续上路。但谦虚的 %historian% 上前表示这位雇佣兵没必要现在就清理掉这些排泄物，这位大学者先是看了看鸟粪，随后有瞧了瞧那只鸟。%SPEECH_ON%没错，没错...我认得那只鸟！就是那个神奇的生物！%SPEECH_OFF%大家抬头看着那鸟，眼神仿佛就是陷入绝境的船员发现大陆了一样。%historian% 指了指 %birdbro%。%SPEECH_ON%你被一只青红仿声雀给看上了！我必须得说，真的，我已经很久很久没见过这些小家伙了，我想说的就是这么多，你……你可以继续清理了。%SPEECH_OFF% 大家差点笑出了声。 %birdbro% 抓起了这位可怜的学者，用他的袖子擦净了鸟粪，雇佣兵们又热闹了起来。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "看来问题解决了。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Victim.getImagePath());
				this.Characters.push(_event.m.Historian.getImagePath());
				_event.m.Victim.worsenMood(0.5, "Got shit on by a bird");

				if (_event.m.Victim.getMoodState() <= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Victim.getMoodState()],
						text = _event.m.Victim.getName() + this.Const.MoodStateEvent[_event.m.Victim.getMoodState()]
					});
				}

				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getID() == _event.m.Victim.getID() || bro.getID() == _event.m.Historian.getID())
					{
						continue;
					}

					if (this.Math.rand(1, 100) <= 25)
					{
						bro.improveMood(1.0, "Felt entertained by " + _event.m.Historian.getName());

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
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type == this.Const.World.TerrainType.Snow)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();

		if (brothers.len() < 2)
		{
			return;
		}

		local candidates_victim = [];
		local candidates_archer = [];
		local candidates_super = [];
		local candidates_historian = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.historian")
			{
				candidates_historian.push(bro);
			}
			else if (bro.getSkills().hasSkill("trait.superstitious"))
			{
				candidates_super.push(bro);
			}
			else if (bro.getBackground().getID() == "background.hunter" || bro.getCurrentProperties().RangedSkill > 70)
			{
				candidates_archer.push(bro);
			}
			else if (!bro.getSkills().hasSkill("trait.lucky"))
			{
				candidates_victim.push(bro);
			}
		}

		if (candidates_victim.len() == 0)
		{
			return;
		}

		this.m.Victim = candidates_victim[this.Math.rand(0, candidates_victim.len() - 1)];

		if (candidates_historian.len() != 0)
		{
			this.m.Historian = candidates_historian[this.Math.rand(0, candidates_historian.len() - 1)];
		}

		if (candidates_archer.len() != 0)
		{
			this.m.Archer = candidates_archer[this.Math.rand(0, candidates_archer.len() - 1)];
		}

		if (candidates_super.len() != 0)
		{
			this.m.Superstitious = candidates_super[this.Math.rand(0, candidates_super.len() - 1)];
		}

		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"birdbro",
			this.m.Victim.getNameOnly()
		]);
		_vars.push([
			"superstitious",
			this.m.Superstitious != null ? this.m.Superstitious.getName() : ""
		]);
		_vars.push([
			"archer",
			this.m.Archer != null ? this.m.Archer.getName() : ""
		]);
		_vars.push([
			"historian",
			this.m.Historian != null ? this.m.Historian.getName() : ""
		]);
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Victim = null;
		this.m.Superstitious = null;
		this.m.Archer = null;
		this.m.Historian = null;
	}

});

