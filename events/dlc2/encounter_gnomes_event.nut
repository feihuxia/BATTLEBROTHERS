this.encounter_gnomes_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.encounter_gnomes";
		this.m.Title = "��;��..";
		this.m.Cooldown = 200.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_25.png[/img]���ô����Ϣһ���Լ�����̽��ǰ����ɭ�֡����������������������������������� �����彣�� ������һƬ���µ����ֱߣ��������ֵ���һ�� �� �������㿴����һȺС����������Ȧ���衣����һ�ߴ�����һ��˵��һЩ���������Ļ�����۵�������һ��Ģ����һЩ�ǳ����ĵ���ܣ�ż����Ҳ����С���˻�Ц����Ȧ�����Ƥ���ܽ��ܳ�,\n\n ร�С��������̫���ˣ�����ǰ��Ϊ�˿��ĸ��������С��Ū�������ε���֦��С�����Ƕ�ֹͣ�˸��裬�뿴������һ�������㣬 ͻȻ���Ǵ��������������Ծ����ȥ����Щ����������Щ�ؽ���ľ���С����ܵ����������ľ׮�ߣ�����ʲôҲû�ҵ���ֻ��һ��Ģ����һֻ��ذ�״̴�����ܡ�",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "�����.",
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
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		if (!this.World.getTime().IsDaytime)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Forest && currentTile.Type != this.Const.World.TerrainType.LeaveForest && currentTile.Type != this.Const.World.TerrainType.AutumnForest)
		{
			return;
		}

		local towns = this.World.EntityManager.getSettlements();
		local playerTile = this.World.State.getPlayer().getTile();

		foreach( t in towns )
		{
			if (t.getTile().getDistanceTo(playerTile) <= 25)
			{
				return false;
			}
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

