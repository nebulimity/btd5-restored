public class TowerNotSelectedState : InGameMenuState
{
	public TowerNotSelectedState(InGameMenu menu) : base(menu)
	{

	}

	public override State HandleMessage(Message message)
	{
		GameStateMessage gameStateMessage = (GameStateMessage)message;
		if (gameStateMessage.Tower != null)
		{
			// return Menu.TowerSelectedState;
		}

		return null;
	}
}
