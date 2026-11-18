public class TowerSelectedState : InGameMenuState
{
	public Tower Tower;

	public TowerSelectedState(InGameMenu menu) : base(menu)
	{

	}

	public override void Enter(Message message)
	{
		// play select sound
		Tower = ((GameStateMessage)message).Tower;
	}

	public override State HandleMessage(Message message)
	{
		switch (((GameStateMessage)message).Type)
		{
			case GameStateMessageType.TowerSelected:
				return Menu.TowerSelectedState;
			case GameStateMessageType.TowerNotSelected:
				return Menu.TowerNotSelectedState;
			case GameStateMessageType.Cancel:
				return Menu.TowerNotSelectedState;
			default:
				return null;
		}
	}
}
