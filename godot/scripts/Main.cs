using System.Collections.Generic;
using Godot;

public partial class Main : Node
{
	public static Main Instance { get; private set; }
	public Level Level;

	public RoundsDef DefaultRounds;
	public TowerFactory TowerFactory;
	public TowerMenuSet TowerMenu;

	public Dictionary<string, Footprint> Footprints;

	public override void _Ready()
	{
		Instance = this;

		DefaultRounds = RoundsDef.Load("default");
		TowerFactory = TowerFactory.Load();
		TowerMenu = TowerMenuSet.Load(TowerFactory);

		Footprints = TerrainLoader.LoadFootprints();
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
