using Godot;

public class PlaceState : InGameMenuState
{
	public static string LastTowerPlaced;

	private TowerPickerDef _pickerDef;

	private Level _level;

	public PlaceState(InGameMenu menu) : base(menu)
	{
		_level = Main.Instance.Level;
	}

	public override void Enter(Message message)
	{
		LastTowerPlaced = ((GameStateMessage)message).TowerPickerDef.Tower.Id;

		_pickerDef = ((GameStateMessage)message).TowerPickerDef;

		GD.Print("place state");
	}

	public override State HandleMessage(Message message)
	{
		switch (((GameStateMessage)message).Type)
		{
			case GameStateMessageType.TowerPlaced:
				Machine.ChangeState(Menu.NeutralState, message);

				return null; // temp
			case GameStateMessageType.TowerPlacing:
				return Menu.PlaceState;
			case GameStateMessageType.Cancel:
				return Menu.NeutralState;
			default:
				return null;
		}
	}

	public override void HandleInput(InputEvent e)
	{
		if (e is InputEventMouseButton mouseEvent && mouseEvent.ButtonIndex == MouseButton.Right && mouseEvent.Pressed)
		{
			Menu.Cancel();
		}
		else if (e is InputEventKey keyEvent && keyEvent.Keycode == Key.Escape && keyEvent.Pressed && !keyEvent.Echo)
		{
			Menu.Cancel();
		}
	}
}
