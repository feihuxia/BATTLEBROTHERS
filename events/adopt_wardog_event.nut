this.adopt_wardog_event <- this.inherit("scripts/events/event", {
	m = {
		Bro = null,
		Houndmaster = null
	},
	function create()
	{
		this.m.ID = "event.adopt_wardog";
		this.m.Title = "路上…";
		this.m.Cooldown = 120.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_27.png[/img]你注意到背后不远处有条狗在跟着，往前走了几英里回头一看它还在哪里，躲躲闪闪地缩了回去。\n\n这样的流浪狗是不会随随便便跟着一群浑身都是危险气味的人的——可能有人在喂它。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "把流浪狗赶走！",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "把它干掉吧，免得它偷吃我们的补给。",
					function getResult( _event )
					{
						local r = this.Math.rand(1, 100);

						if (r <= 60)
						{
							return "C";
						}
						else
						{
							return "D";
						}
					}

				},
				{
					Text = "佣兵团需要一个吉祥物。收养它。",
					function getResult( _event )
					{
						local r = this.Math.rand(1, 100);

						if (r <= 75)
						{
							return "E";
						}
						else
						{
							return "F";
						}
					}

				}
			],
			function start( _event )
			{
				if (_event.m.Houndmaster != null)
				{
					this.Options.push({
						Text = "%houndmaster%，你接受过训练，可以对付狗，是吧？",
						function getResult( _event )
						{
							return "G";
						}

					});
				}
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_75.png[/img]这可不是狗崽子该出现的地方。看到狗又出现时，你拿起一块石头就砸向它的脑袋。狗耷拉着尾巴呜咽着逃跑了。而后它又顿了顿，似乎在想是不是搞错什么了，但你又猛地扔了块石头，让它改变了想法。于是那条狗消失的无影无踪。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "走开！",
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
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_75.png[/img]你搭弓拉弦。几名兄弟看着你。弯弓如满月，但是那条狗看明白了，于是拔腿仓皇逃跑。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我只想吓跑它。",
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
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_27.png[/img]你拿起弓箭。你瞄准的时候，几个战友看着你。一阵阵风吹过。你耐心地慢慢拉满弦，闭上一只眼睛，瞄准了流浪狗。他坐下定制内。\n\n你松开弓弦。箭飞射而出，狗哀嚎了一声。它滚倒在地，四肢乱蹬了一会儿，死了。你收起弓，挥手示意继续上路。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "可怜的小东西。",
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
		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_27.png[/img]你拿出一块肉，慢慢地走进流浪狗。它一开始有点害怕，随着你的走进退后了几步，但你手上肉的香味让它直流口水。流浪狗慢慢地接近你，时不时停下来警惕地看着四周，提防满腹。\n\n你能看见这只狗的肋骨，这只狗在路上流浪了很久了，饿得皮包骨、它的耳朵高高地竖起，尾巴紧紧绷着。这个动物战斗力挺强的，而以后它就为你而战了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "欢迎加入战团。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local item = this.new("scripts/items/accessory/wardog_item");
				item.m.Name = "战场兄弟";
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_37.png[/img]它这样落魄的流浪犬非常适合做机型无。这只狗对士气肯定有帮助。你命令%bro%给它点东西吃，希望它会跟着。他拿出一些剩饭，然后蹲下%SPEECH_ON%好孩子。%SPEECH_OFF%流浪狗闻了闻食物，然后张开口猛咬了一口——好像想把这位兄弟的受也咬掉。佣兵吓得往后挑了一步，手按在胸上发愣。而那只里狼狗把食物吞掉后转身跑掉了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "该死，它真的很适合加入战团。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bro.getImagePath());
				local injury = _event.m.Bro.addInjury(this.Const.Injury.FeedDog);
				this.List = [
					{
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.Bro.getName() + " suffers " + injury.getNameOnly()
					}
				];
			}

		});
		this.m.Screens.push({
			ID = "G",
			Text = "[img]gfx/ui/events/event_27.png[/img]你询问%houndmaster%训兽师能否尝试‘劝诱’这条狗。他点点头上前一步。这疯狂小东西立马竖直了耳朵。训兽师蹲伏着慢慢靠近那狗。他手掌中放着一块肉。饥饿感最终战胜了谨慎心，那条狗最终凑近训兽师的手闻了闻。狗伸出舌头舔了舔，然后开始大快朵颐。训狗师又喂了它一口。他拎了拎狗的后颈，在耳朵后面找到了有效点。%houndmaster%回头看你点点头。%SPEECH_ON%不错的野兽，很好训练。%SPEECH_OFF%太好了。你问他是否能战斗。训兽师厥起了嘴。%SPEECH_ON%狗和人差不多。能喘气儿就能战斗。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Nice.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Houndmaster.getImagePath());
				local item = this.new("scripts/items/accessory/wardog_item");
				item.m.Name = "战场兄弟";
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你获得了" + item.getName()
				});
			}

		});
	}

	function onUpdateScore()
	{
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type == this.Const.World.TerrainType.Forest || currentTile.Type == this.Const.World.TerrainType.Snow || currentTile.Type == this.Const.World.TerrainType.LeaveForest || currentTile.Type == this.Const.World.TerrainType.Mountains)
		{
			return;
		}

		if (!this.World.Assets.getStash().hasEmptySlot())
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.houndmaster")
			{
				candidates.push(bro);
			}
		}

		this.m.Bro = brothers[this.Math.rand(0, brothers.len() - 1)];

		if (candidates.len() != 0)
		{
			this.m.Houndmaster = candidates[this.Math.rand(0, candidates.len() - 1)];
		}

		this.m.Score = 5;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"bro",
			this.m.Bro.getName()
		]);
		_vars.push([
			"houndmaster",
			this.m.Houndmaster != null ? this.m.Houndmaster.getName() : ""
		]);
	}

	function onClear()
	{
		this.m.Bro = null;
		this.m.Houndmaster = null;
	}

});

