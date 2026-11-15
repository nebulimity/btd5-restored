using System;
using System.Collections.Generic;

public enum GameMode
{
	Easy = 0,
	Medium = 1,
	Hard = 2,
	Sandbox = 3,
	Deflation = 4,
	Apopalypse = 5
}

public class Level : Scene
{
	public Tile StartTile;
	public List<Tile> CurrentTileSet;
	public List<List<Tile>> TileSets;

	public int WaveIndex;
	public int Health;
	public double Cash;

	private static readonly double[] BloonSpeedModsByMode = { 0, 0.05, 0.125, 0, 0, 0 };

	public List<Bloon> AllBloons = new List<Bloon>();
	public event Action<Bloon> BloonAdded;
	public event Action<Bloon> BloonRemoved;

	public int UpdateMultiplier = 1;
	public double RoundTime = 0;

	// temp
	public RoundsDef Rounds;

	public void Initialize()
	{

	}

	public void InitializeLevel(LevelDef def, GameMode mode)
	{
		TileSets = new List<List<Tile>>();

		foreach (var path in def.TileSets)
		{
			List<Tile> tiles = new List<Tile>();

			foreach (var tileDef in path)
			{
				tiles.Add(Tile.FromDef(tileDef));
			}
			foreach (var tile in tiles)
			{
				tile.Initialize(tiles);
			}

			TileSets.Add(tiles);
		}

		CurrentTileSet = TileSets[0];
		StartTile = CurrentTileSet[0];
		// WaveSet

		Bloon.DifficultySpeedModifier = BloonSpeedModsByMode[(int)mode];

		Spawner.ApplyCamoToo = null;
		Spawner.ApplyRegenToo = null;
		Spawner.BloonLevelOffsets = null;

		Rounds = RoundsDef.Load("default");
		Godot.GD.Print(Rounds.Rounds.Count);
		Godot.GD.Print(Rounds.Rounds[0].Groups[0].Bloon.Type);
		Godot.GD.Print(Rounds.Rounds[0].Groups[0].Spawners[0].Start);
		Godot.GD.Print(Rounds.Rounds[0].Groups[0].Spawners[0].Length);
		Godot.GD.Print(Rounds.Rounds[0].Groups[0].Spawners[0].Count);
		Godot.GD.Print(Rounds.Rounds[84].Groups[0].Bloon.Type);
	}

	public override void Process(double delta)
	{
		for (int i = 0; i < AllBloons.Count; i++) // for BloonView interpolation only
		{
			Bloon bloon = AllBloons[i];
			bloon.PrevX = bloon.X;
			bloon.PrevY = bloon.Y;
			bloon.PrevRot = bloon.Rotation;
		}

		int tick = 0;
		while (tick < UpdateMultiplier)
		{
			RoundTime += delta;

			// process collision grid

			for (int i = 0; i < AllBloons.Count; i++)
			{
				AllBloons[i].Process(delta);
			}

			base.Process(delta);
			tick++;
		}
	}

	public void AddBloon(Bloon bloon)
	{
		bloon.Scene = this;
		AllBloons.Add(bloon);
		BloonAdded?.Invoke(bloon);
		// CollisionGrid.AddToCell(bloon, bloon.CollisionCellIndex);
		// menu tips/bloon warning popups
	}
	public void RemoveBloon(Bloon bloon)
	{
		int index = AllBloons.IndexOf(bloon);
		if (index != -1)
		{
			AllBloons.RemoveAt(index);
			// CollisionGrid.RemoveFromCell(bloon, bloon.CollisionCellIndex);
			Cull(bloon);
			bloon.Tile = null;
			BloonRemoved?.Invoke(bloon);
			// Pool.Release(bloon);
			// CheckForRoundOver()
		}
	}

	public void LoseLives(int RBE = 1)
	{
		// return if sandbox or co-op

		Health -= RBE;
		if (Health < 0)
		{
			Health = 0;
		}

		// dispatchEvent health changed
	}
}
