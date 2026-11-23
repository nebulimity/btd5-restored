using Godot;

public class TowerSelectedState : InGameMenuState
{
	public Tower Tower;

	private RangeCombo _selectedRange;

	public TowerSelectedState(InGameMenu menu) : base(menu)
	{
		_selectedRange = Menu.SelectedRange;
	}

	public override void Enter(Message message)
	{
		// play select sound
		Tower = ((GameStateMessage)message).Tower;

		_selectedRange.Position = new Vector2((float)Tower.X, (float)Tower.Y);
		_selectedRange.SetRange(Tower.Def.RangeOfVisibility, true);
		_selectedRange.ShowRange();
	}

	public override void Exit()
	{
		_selectedRange.HideRange();
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
