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