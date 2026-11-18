using Godot;

public class NeutralState : InGameMenuState
{
	private Tower _minTower;

	public Machine ChildState = new Machine();
	private Level _level;

	public NeutralState(InGameMenu menu) : base(menu)
	{
		_level = Main.Instance.Level;
		ChildState.ChangeState(menu.TowerNotSelectedState, null);
	}

	public override void Enter(Message message)
	{
		GD.Print("neutral state");
	}

	public override State HandleMessage(Message message)
	{
		if (((GameStateMessage)message).Type == GameStateMessageType.TowerPlacing)
		{
			return Menu.PlaceState;
		}

		ChildState.Send(message);
		return null;
	}

	public override void HandleInput(InputEvent e)
	{
		if (e is InputEventMouseButton mouseEvent && mouseEvent.ButtonIndex == MouseButton.Left && mouseEvent.Pressed)
		{
			ChildState.Send(new GameStateMessage(GameStateMessageType.TowerNotSelected));
		}
	}
}
