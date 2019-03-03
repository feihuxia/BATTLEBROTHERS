this.fountain_of_youth_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.location.fountain_of_youth";
		this.m.Title = "随着你的接近...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_114.png[/img]{你站在森林中一块空地的边缘，眼前的景象令人难以置信。\n\n 一个人形的躯干像一棵细长的树一样从地上长出来，光秃秃，直挺挺，长着坑坑洼洼的树皮，一直向上长到有两个你那么高。树干无枝，人身无臂。取而代之的是聚成一束的人头，出现在原本应该是树冠的地方。从左到右，他们面容稚嫩、美丽清秀、性别模糊，却面容扭曲，仿佛已经经历了无数岁月的折磨。他们的脸在阴影中看上去熟悉得奇怪，自然得诡异，他们盯着你们，就好像他们不知道自己为什么会在这个地方，并且随时准备询问你们这个问题一样。眼前所见让你回想起自己曾经溺水的情景，奔流的河水下是扭曲的面庞，与树木融为一体的血肉无时不刻不被自己为何会落到如此田地的想法所困扰。\n\n 低语声从树上传来。它们在地上流动，好像虫子在说话，它们爬上你的胳膊，擦过你的耳朵。它们要求你们停下。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "咱们去看看那是啥东西。",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "离这鬼地方越远越好，赶快。",
					function getResult( _event )
					{
						if (this.World.State.getLastLocation() != null)
						{
							this.World.State.getLastLocation().setVisited(false);
						}

						return 0;
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_114.png[/img]{进入空地后，那奇怪的生物挺直了身子，一堆脑袋左摇右晃，好像一只准备开屏的孔雀。他们开始和你说话。%SPEECH_ON%是。长者。对。在这。对。他。我们。知道。他。我们。知道。%SPEECH_OFF%他们的脸勃然色变，好像自己刚刚说了什么不该说的话。过了一会，他们又一次开口，这怪物有特别的说话技巧，各个脑袋交替发言，一个词一个词的往外蹦。%SPEECH_ON%喝。一点。治愈。所有。喝。全部。融为。一体。%SPEECH_OFF%你低下头，看见一个从土地中长出的突出物在一个有盘子那么大的水坑上弯曲着。一缕水流从突出末端滴入盘中，没人知道那水是从哪来的。你又一抬头，那些脸朝下看着，他们的表情有痛苦也有快乐，有惊讶也有恐惧和困惑。%SPEECH_ON%熟悉。永远。熟悉。喝。一点。对。错。喝。全部。%SPEECH_OFF%你又低下头，拿出水袋，打开瓶塞。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我只喝一点就好。",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "我全都要！",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "[img]gfx/ui/events/event_114.png[/img]{你蹲在那棵奇形怪状的树下。脑袋压低，树荫随之降下，好像有人把给篮子盖上了罩子。当你抬起头时，那些脸的目光在离你一英尺远的地方不断摆动。但离你最远的那张脸却丝毫未动。那张脸像个面目狰狞的老人，眉头紧锁，下巴紧绷，皱纹满面，好像要用愤怒把自己锻造成一把利剑。一团黑暗笼罩着他，阴影波动，好像那张脸是在另一个世界注视着你。\n\n 你用双手抓稳水袋，把里面的水往外倾倒。水袋倒空后，你把它放在滴水的突出下面，倾听着每一滴液体落在它底部的声音。那些脸离你越来越近，把你围在一个混沌的圆锥体中间。随着他们的靠近，你可以听到他们实体的撕裂声，就像他们在随着靠近你而扭曲变形。你手里的水袋抖得就像你把它放在了一个瀑布下面。你把它从突出下面猛抽出来，在你向后栽倒过去的时候，你发现那些头不知何时早已重新竖起。你连滚带爬地跑出空地，直到你觉得安全了才回头看去，发现那个生物消失了。哪里啥也没剩下。没有树。没有泉水。然而，你手中那装满的水袋，却依然存在着。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "最好把它好好保管起来。",
					function getResult( _event )
					{
						if (this.World.State.getLastLocation() != null)
						{
							this.World.State.getLastLocation().die();
						}

						return 0;
					}

				}
			],
			function start( _event )
			{
				this.World.Assets.getStash().makeEmptySlots(1);
				local item;
				item = this.new("scripts/items/special/fountain_of_youth_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "你得到了 " + _event.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "D",
			Text = "[img]gfx/ui/events/event_114.png[/img]{你把水袋扔到一边，把嘴直接凑到水流下面接水。水坑下的世界空虚而寂静。你的嘴唇颤动，喉咙咕噜作响，但却什么都没喝到。你在惊恐中大叫起来。什么都没有，你甚至感受不到知觉，只有无穷无尽的恐惧和永远无法满足的欲望。当你把手支在地上试图脱身，却发现自己无法离开水坑。\n\n 那些暗淡的脸在虚空中若隐若现。他们就像那棵树一样，滑稽诡异，毫无生机，痛苦地在从过去到现在再到未来的时光中受苦。他们在这里聚集起来，鼓动着挤上前来，把这漆黑的地狱染上空洞的惨白。随着他们的靠近，你发现你观察的方式错误了。单独而言，他们只是一张张没有明显特征的脸。但作为一个整体，作为一个巨大的白色实体看去时，你发现了他们共同组成了一张大脸：你的脸。而且他还在大笑。\n\n 你惨叫着着，终于从水坑里挣脱出来。 %randombrother% 用胳膊挽住你，脸上满是担忧。%SPEECH_ON%头儿，你没事吧？你在打盹，然后你的脑袋就滑进了那边的水里。%SPEECH_OFF%你抬头，想看看那棵奇形怪状的树和它可怖的脸。但它不在那里，不论你再怎么寻找，它已经不复存在了。}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "我……我不明白。",
					function getResult( _event )
					{
						if (this.World.State.getLastLocation() != null)
						{
							this.World.State.getLastLocation().die();
						}

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
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
	}

});

