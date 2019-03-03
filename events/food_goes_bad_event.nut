this.food_goes_bad_event <- this.inherit("scripts/events/event", {
	m = {
		FoodAmount = 0
	},
	function create()
	{
		this.m.ID = "event.food_goes_bad";
		this.m.Title = "营地…";
		this.m.Cooldown = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Options = [
				{
					Text = "我们可以利用这一个...",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local food = this.World.Assets.getFoodItems();
				food = food[this.Math.rand(0, food.len() - 1)];
				this.World.Assets.getStash().remove(food);

				if (food.getID() == "supplies.bread")
				{
					this.Text = "[img]gfx/ui/events/event_52.png[/img]{在进行库存管理工作时, %randombrother%告诉了你一个坏消息：大量食物坏掉了。你轻微而恰当地点了点头，向他的及时回报表示感谢。| %randombrother%揉着下巴向你走来。他说他吃面包的时候差点把牙齿咯掉了。他从食物箱里找到的那个，看来已经放了很久了。你拿出剑将面包砍成两半，几个兄弟讽刺地欢呼了一下。你拿起半个面包，把里面给手下们看：黑色的核心。那就是你吃了这个东西之后的下场，说完你便把面包扔进灌木丛中，然后听到石头落地一般的声音。}";
				}
				else if (food.getID() == "supplies.dried_fish")
				{
					this.Text = "[img]gfx/ui/events/event_52.png[/img]{当清点物品的时候， %randombrother% 警告你一个可怕的消息: 大量的食物腐败了。简单而直接， 你点头感谢他迅速的告诉你。| %randombrother% 尖叫着跳离他坐着的木头。你走过去看到他把一条鱼扔到路边不停地用手指那条鱼。当他亲到你不要走过去，你决定要走近看一看。很明显一只水蜘蛛在鱼的肚子里生了一堆蛋。你现在盯着这些小蜘蛛蠕动的头部和身体。\n\n把它们都扔到火里面， 你让兄弟检查剩下的鱼。不幸的是，他们的状况都差不多没有人愿意把鱼大餐换成蜘蛛大餐}";
				}
				else if (food.getID() == "supplies.dried_fruits")
				{
					this.Text = "[img]gfx/ui/events/event_52.png[/img]{在进行库存管理工作时, %randombrother%告诉了你一个坏消息：大量食物坏掉了。你轻微而恰当地点了点头，向他的及时回报表示感谢。| 你在几个食物箱中仔细筛选，发现一整箱的苹果上面都覆盖着灰色的毛绒物体。%randombrother%说了一个名字，但是你从来没有听说过。不管怎样，反正也都不能吃了，你便把所有腐烂的水果扔掉了。}";
				}
				else if (food.getID() == "supplies.smoked_ham" || food.getID() == "supplies.cured_venison")
				{
					this.Text = "[img]gfx/ui/events/event_52.png[/img]{在进行库存管理工作时, %randombrother%告诉了你一个坏消息：大量食物坏掉了。你轻微而恰当地点了点头，向他的及时回报表示感谢。| 在几块肉中爬满了蛆虫。你的手下盯着食物，有些人好像还是想冒着生病的危险去吃两口。你让所有人都退下然后在有人做出什么蠢事之前亲自把肉扔掉了。}";
				}
				else
				{
					this.Text = "{[img]gfx/ui/events/event_52.png[/img]等检查库存的时候， %randombrother% 警告你一个可怕的消息: 很大一堆食物变质了。简单而且直接， 一点头感谢他迅速的告诉你这个消息。| [img]gfx/ui/events/event_36.png[/img]孩子的笑声把你从小憩当中吵醒。你起来发现有一些食物不见了唯一的留下的证据是离开的时候还在移动的高高的草。快速的思考， 你拿了一把剑跟着他。不幸的是，老早你就迷失在巨大的绿色中间一只巨大的绿色的茎干带着风划过你的脸。笑声并没有停止， 但是， 你听到脚步的声音在你的前后穿过。一个声音说起话来， 听起来像是水井里的一个小孩。%SPEECH_ON%来追我们呀!在这里!来追我们!来追我们...来追我们。快来追我们!%SPEECH_OFF%你突然感觉没有获得粮食的冲动了。你慢慢的把剑放了回去并且退了回去。当你看着这些高高的草的时候， 他开始离开， 缓慢的，就像是你块皮革从线缝处被撕开。当树干破开的时候你听到了可怕的哭声。\n\n%randombrother%惊讶的看着你问你在做什么。你转过身去看他， 然后转回去对着田地微风轻轻的摇动着。没有回答， 你告诉他准备好你将快速行军。谢天谢地，雇佣兵没有问到失踪的食物的事情。}";
				}

				this.List = [
					{
						id = 10,
						icon = "ui/items/" + food.getIcon(),
						text = "你失去了" + food.getName()
					}
				];
			}

		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().Days <= 10)
		{
			return;
		}

		if (this.World.Assets.getFood() < 70)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Plains && currentTile.Type != this.Const.World.TerrainType.Swamp && currentTile.Type != this.Const.World.TerrainType.Farmland && currentTile.Type != this.Const.World.TerrainType.Steppe && currentTile.Type != this.Const.World.TerrainType.Hills)
		{
			return;
		}

		this.m.Score = this.World.Assets.getFood() / 10;
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
		this.m.FoodAmount = 0;
	}

});

