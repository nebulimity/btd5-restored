public class TowerSelectedState : InGameMenuState
{
	public Tower tower;

	public TowerSelectedState(InGameMenu menu) : base(menu)
	{

	}

	public override void Enter(Message message)
	{
		// play select sound
		tower = ((GameStateMessage)message).Tower;
	}
}
