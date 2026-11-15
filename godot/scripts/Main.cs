using Godot;

public partial class Main : Node
{
	public static Main Instance { get; private set; }

	public RoundsDef DefaultRounds;

	public Level Level;

	public override void _Ready()
	{
		Instance = this;

		DefaultRounds = RoundsDef.Load("default");
	}

	public override void _Input(InputEvent @event)
	{
		if (@event.IsActionPressed("fullscreen"))
		{
			DisplayServer.WindowMode mode = DisplayServer.WindowGetMode();
			bool isWindowed = mode != DisplayServer.WindowMode.Fullscreen;

			if (isWindowed)
			{
				DisplayServer.WindowSetMode(DisplayServer.WindowMode.Fullscreen);
			}
			else
			{
				DisplayServer.WindowSetMode(DisplayServer.WindowMode.Windowed);
			}
		}
	}
}
