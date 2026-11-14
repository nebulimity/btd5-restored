using Godot;
using System;

public partial class Game : Node2D
{
	public Level Level;
	private double _accumulator;
	const double TickLength = 1.0 / 30.0;

	public override void _Ready()
	{
		Level = new Level();
		Main.Instance.Level = Level;
		Level.Initialize();

		LevelDef levelDef = LevelDef.Load("MonkeyLane");
		Level.InitializeLevel(levelDef, GameMode.Easy);

		// temp
		PackedScene mapScene = GD.Load<PackedScene>("res://scenes/maps/monkey_lane.tscn");
		Node2D map = mapScene.Instantiate<Node2D>();
		AddChild(map);

		Bloon testBloon = new Bloon();
		testBloon.Initialize(BloonType.Red, Level.StartTile, 0);
		Level.AddBloon(testBloon);
	}

	public override void _Process(double delta)
	{
		_accumulator += Math.Min(delta, TickLength);
		while (_accumulator >= TickLength)
		{
			Level.Process(TickLength);
			_accumulator -= TickLength;
		}
	}

	public override void _ExitTree()
	{
		Main.Instance.Level = null;
	}
}