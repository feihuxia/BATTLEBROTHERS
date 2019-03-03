this.cat_on_tree_event <- this.inherit("scripts/events/event", {
	m = {
		Archer = null,
		Ratcatcher = null,
		Town = null
	},
	function create()
	{
		this.m.ID = "event.cat_on_tree";
		this.m.Title = "在%townname%";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_97.png[/img]你看到一个男孩和一个女孩朝树上看。女孩举起了手。%SPEECH_ON%好吧，你就在这儿呆到死吧！看我在不在乎！%SPEECH_OFF%男孩子，发现了你，问你能不能帮忙把他们的猫从树上抓下来。你抬头看，确实看到了一只小猫在树枝上晒太阳。",
			Image = "",
			List = [],
			Options = [],
			function start( _event )
			{
				if (_event.m.Archer != null)
				{
					this.Options.push({
						Text = "%archerfull%，想用箭让它下来？",
						function getResult( _event )
						{
							if (this.Math.rand(1, 100) <= 70)
							{
								return "ArrowGood";
							}
							else
							{
								return "ArrowBad";
							}
						}

					});
				}

				if (_event.m.Ratcatcher != null)
				{
					this.Options.push({
						Text = "%ratcatcherfull%袖子上面有东西。",
						function getResult( _event )
						{
							return "Ratcatcher";
						}

					});
				}

				this.Options.push({
					Text = "这不用我们操心。",
					function getResult( _event )
					{
						return "F";
					}

				});
			}

		});
		this.m.Screens.push({
			ID = "ArrowGood",
			Text = "[img]gfx/ui/events/event_97.png[/img]%archer%把箭搭在弦上，伸着舌头瞄准了树上。男孩和女孩似乎不怎么喜欢这主意，用手遮住了眼睛。弓箭手射出箭矢，折断了猫咪所在的树枝。猫咪像是恶魔棍游戏一样翻着跟斗跳了下来。等它着陆以后，男孩和女孩跑了过去。他们拍着它，感激了你的帮助。女孩热情地抱着猫咪。%SPEECH_ON%终于，我们有东西吃了！%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "等等，你说什么？",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Archer.getImagePath());
				_event.m.Archer.getBaseProperties().RangedSkill += 1;
				_event.m.Archer.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/ranged_skill.png",
					text = _event.m.Archer.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] 远程技能"
				});
			}

		});
		this.m.Screens.push({
			ID = "ArrowBad",
			Text = "[img]gfx/ui/events/event_97.png[/img]%archer%准备着，把箭搭在弦上，瞄准了目标。猫咪盯着弓箭手的动作，发出咕噜咕噜声，自杀性的姿势看着尤为庄严。弓箭手闭上一只眼，射出了箭。猫咪没有发出什么声音。它像恶魔棍游戏一样摔落下来，半根箭矢从它脑袋里穿出来。女孩蹲下来，看着箭尖上晃动的一点点脑浆。她抬头看着你，好像是你射了这一箭一样。%SPEECH_ON%那是我朋友。%SPEECH_OFF%你跟他说对不起，但她还能找到更多朋友。至于男孩，他收好了脑浆，把猫咪尸体挂在了肩上。他阴郁地说。%SPEECH_ON%最起码我们现在有吃的了。%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "安息吧，小猫。",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Archer.getImagePath());
				_event.m.Archer.worsenMood(1.0, "Accidentally shot a little girl\'s pet cat");

				if (_event.m.Archer.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Archer.getMoodState()],
						text = _event.m.Archer.getName() + this.Const.MoodStateEvent[_event.m.Archer.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Ratcatcher",
			Text = "[img]gfx/ui/events/event_97.png[/img]%ratcatcher%掰着手指。%SPEECH_ON%哦，我有个主意！你们这些小家伙就等一等！%SPEECH_OFF%捕鼠人从口袋里拿出了一只老鼠，你根本都想不到他还有这东西。他发出小猫喵呜的声音，把小老鼠举了起来。猫咪注意到了，竖起了耳朵。%SPEECH_ON%对，就是那样，小猫咪，下来吧，该吃午饭了。%SPEECH_OFF%捕鼠人把老鼠举到唇边低语。%SPEECH_ON%不，不是的，呵呵呵。%SPEECH_OFF%猫咪往下，%ratcatcher%就把他的小朋友拿远一点点。它开始在他手里扭动，也许不相信自己的主人能握住它。但当猫咪扑向大餐时，捕鼠人把老鼠装进了口袋，一把抓住了猫咪。他把猫咪交过去，孩子们拍手欢呼着。就连男人们都被这小伙像猫一样大的反应惊呆了！",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "技艺娴熟！",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Ratcatcher.getImagePath());
				_event.m.Ratcatcher.getBaseProperties().Initiative += 2;
				_event.m.Ratcatcher.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/initiative.png",
					text = _event.m.Ratcatcher.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+2[/color]主动性"
				});
				_event.m.Ratcatcher.improveMood(1.0, "Impressed everyone with his swiftness");

				if (_event.m.Ratcatcher.getMoodState() >= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Ratcatcher.getMoodState()],
						text = _event.m.Ratcatcher.getName() + this.Const.MoodStateEvent[_event.m.Ratcatcher.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "F",
			Text = "[img]gfx/ui/events/event_97.png[/img]你坦率地告诉孩子们应该找条狗，让你离开。",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "反正猫咪也不想当你的朋友。",
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
		local nearTown = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 4 && t.isAlliedWithPlayer())
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

		local brothers = this.World.getPlayerRoster().getAll();
		local candidates_archer = [];
		local candidates_ratcatcher = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.hunter" || bro.getBackground().getID() == "background.poacher" || bro.getBackground().getID() == "background.sellsword")
			{
				candidates_archer.push(bro);
			}
			else if (bro.getBackground().getID() == "background.ratcatcher")
			{
				candidates_ratcatcher.push(bro);
			}
		}

		if (candidates_archer.len() == 0 && candidates_ratcatcher.len() == 0)
		{
			return;
		}

		if (candidates_archer.len() != 0)
		{
			this.m.Archer = candidates_archer[this.Math.rand(0, candidates_archer.len() - 1)];
		}

		if (candidates_ratcatcher.len() != 0)
		{
			this.m.Ratcatcher = candidates_ratcatcher[this.Math.rand(0, candidates_ratcatcher.len() - 1)];
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
			"archer",
			this.m.Archer != null ? this.m.Archer.getNameOnly() : ""
		]);
		_vars.push([
			"archerfull",
			this.m.Archer != null ? this.m.Archer.getName() : ""
		]);
		_vars.push([
			"ratcatcher",
			this.m.Ratcatcher != null ? this.m.Ratcatcher.getNameOnly() : ""
		]);
		_vars.push([
			"ratcatcherfull",
			this.m.Ratcatcher != null ? this.m.Ratcatcher.getName() : ""
		]);
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
	}

	function onClear()
	{
		this.m.Archer = null;
		this.m.Ratcatcher = null;
		this.m.Town = null;
	}

});

