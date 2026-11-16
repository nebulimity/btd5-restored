public enum GameStateMessageType
{
	Cancel = 0,
	TowerSelected = 2,
	TowerNotSelected = 3,
	TowerPlaced = 4,
	TowerPlacing = 5
}

public class GameStateMessage : Message
{
	public GameStateMessageType Type;
	// public TowerPickerDef TowerPickerDef;
	// public Tower Tower;

	public GameStateMessage(GameStateMessageType type)
	{
		Type = type;
	}
}
