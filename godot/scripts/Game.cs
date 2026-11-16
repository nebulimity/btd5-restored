using Godot;
using System;

public partial class Game : Node2D
{
	public Level Level;
	private BloonLayer _bloonLayer;

	[Export] private InGameMenu _inGameMenu;

	private double _accumulator;
	const double TickLength = 1.0 / 30.0;
	private double _alpha;

	public override void _Ready()
	{
		Level = new Level();
		Main.Instance.Level = Level;
		Level.Initialize();

		LevelDef levelDef = LevelDef.Load("MonkeyLane");
		Level.InitializeLevel(levelDef, GameMode.Easy);

		_bloonLayer = GetNode<BloonLayer>("BloonLayer");
		_bloonLayer.Initialize(Level);

		_inGameMenu.Initialize(Level);

		// temp
		PackedScene mapScene = GD.Load<PackedScene>("res://scenes/maps/monkey_lane.tscn");
		Node2D map = mapScene.Instantiate<Node2D>();
		AddChild(map);
	}

	public override void _Process(double delta)
	{
		_accumulator += Math.Min(delta, TickLength);
		while (_accumulator >= TickLength)
		{
			Level.Process(TickLength);
			_accumulator -= TickLength;
		}

		_alpha = _accumulator / TickLength;
		_bloonLayer.SyncAll(_alpha);
	}

	public override void _ExitTree()
	{
		Main.Instance.Level = null;
	}
}
