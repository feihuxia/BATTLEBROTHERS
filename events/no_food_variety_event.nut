this.no_food_variety_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.no_food_variety";
		this.m.Title = "营地…";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_52.png[/img]{你看到佣兵们围坐在营火旁，可是他们却没有任何像样的食物可以烹制。其中一个佣兵将手中的汤碗打翻在地。那碗汤是如此的粘稠，以至于汤汁几乎没有被洒出来，说实话，那样子真有点恶心。%randombrother%看着你。%SPEECH_ON%头儿，给我们弄点肉吃吧！或者其他什么比这坨屎强的东西也行！%SPEECH_OFF%在食物上弄点花样没什么坏处，你表示同意。| %randombrother%来找你并将一把勺子甩在了你的桌子上。勺子上沾着某种你无法描述的东西。那位佣兵向后靠去，一边喘着粗气，一边将手插在了自己的皮带上。随后，他叹了一口气，因为他意识到自己不应在你面前有如此粗鲁的举动。不过，他还是阐明了自己的来意。%SPEECH_ON%头儿，我们的食物太难吃了，大家都在抱怨。我觉得，如果我们能在经过下一个城镇时弄点肉或是其他好吃的，肯定对提升战团的士气很有帮助。当然，这只是一个建议。%SPEECH_OFF%他迅速离开了。你拿起那把勺子，仔细观察勺子上的东西。这……他们该不会真的在吃这种东西吧？或许在食物上弄点花样也没什么坏处……| %randombrother%手里拿着一个碗朝你走来。他将碗朝你倾斜了一点，好让你看到碗中无色的粘稠物质。这位佣兵摇了摇头。%SPEECH_ON%关于最近的晚餐，大家都很不满意，这其中也包括我。无论是什么样的人，长时间吃同样的东西都会产生厌倦，尤其是当人们知道自己理应得到更好的待遇的时候。所以，为了我和其他所有人，我想提一个建议：我希望我们的食物能换换花样……至少，别再让我们吃这种东西了。%SPEECH_OFF%他把碗放下后转身离开了。| 你手下的一些佣兵正围坐在营火旁边抱怨。于是你侧耳倾听，想知道他们背着你会谈论些什么。万幸的是，他们并不是想策反，不过他们对食物颇有微词。战团的食物供应过于单调。他们已经对千篇一律的食物感到厌烦。或许借着%companyname%造访下一个城镇的机会，我们就可以解决这个问题？}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "不过，他们也不要奢望能吃上什么美味佳肴。",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local brothers = this.World.getPlayerRoster().getAll();

				foreach( bro in brothers )
				{
					if (bro.getBackground().isLowborn() || bro.getSkills().hasSkill("trait.spartan"))
					{
						continue;
					}

					if (bro.getSkills().hasSkill("trait.gluttonous"))
					{
						bro.worsenMood(1.0, "Has eaten nothing but ground grains for days");
					}
					else
					{
						bro.worsenMood(0.5, "Has eaten nothing but ground grains for days");
					}

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

		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().Days < 5)
		{
			return;
		}

		if (this.World.State.getEscortedEntity() != null)
		{
			return;
		}

		local brothers = this.World.getPlayerRoster().getAll();
		local hasBros = false;

		foreach( bro in brothers )
		{
			if (bro.getBackground().isLowborn() || bro.getSkills().hasSkill("trait.spartan"))
			{
				continue;
			}

			hasBros = true;
			break;
		}

		if (!hasBros)
		{
			return;
		}

		local stash = this.World.Assets.getStash().getItems();
		local hasOtherFood = false;

		foreach( item in stash )
		{
			if (item != null && item.isItemType(this.Const.Items.ItemType.Food))
			{
				if (item.getID() != "supplies.ground_grains")
				{
					hasOtherFood = true;
					break;
				}
			}
		}

		if (hasOtherFood)
		{
			return;
		}

		this.m.Score = 10;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}

});

