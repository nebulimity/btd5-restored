using Godot;
using System;

public partial class Game : Node2D
{
	public Level Level;

	private double _accumulator;
	const double TickLength = 1.0 / 30.0;
	private double _alpha;

	[Export] private BloonLayer _bloonLayer;
	[Export] private TowerLayer _towerLayer;
	[Export] private InGameMenu _inGameMenu;

	public override void _Ready()
	{
		Level = new Level();
		Main.Instance.Level = Level;
		Level.Initialize();

		LevelDef levelDef = LevelDef.Load("MonkeyLane");
		TerrainSet terrainSet = TerrainLoader.LoadTerrainSet(levelDef);
		Level.InitializeLevel(levelDef, GameMode.Easy, terrainSet);
		PackedScene mapScene = GD.Load<PackedScene>(levelDef.Scene);
		Node2D map = mapScene.Instantiate<Node2D>();
		AddChild(map);

		if (levelDef.Music != null)
		{
			BGM.Instance.PlayTrack(levelDef.Music);
		}

		_bloonLayer.Initialize(Level);
		_towerLayer.Initialize(Level);
		_inGameMenu.Initialize(Level);
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
		_towerLayer.SyncAll(_alpha);
	}

	public override void _ExitTree()
	{
		Main.Instance.Level = null;
	}
}
