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

	public WaveSet WaveSet;

	public int WaveIndex;
	public int Health;
	public double Cash;

	private static readonly int[] InitialCashByMode = [650, 650, 650, int.MaxValue, 50000, 650];
	private static readonly int[] InitialHealthByMode = [200, 150, 100, 200, 150, 150];
	private static readonly double[] BloonSpeedModsByMode = [0, 0.05, 0.125, 0, 0, 0];

	public List<Bloon> AllBloons = new List<Bloon>();
	public event Action<Bloon> BloonAdded;
	public event Action<Bloon> BloonRemoved;

	public int UpdateMultiplier = 1;
	public double RoundTime = 0;

	public bool WaveHasCamo;

	public double CashMultiplier;

	private GameTimer _endWaveTimer;
	public bool BetweenRounds = true;

	public GameMode Mode;
	public bool Reverse;
	public bool FastTrack;
	public bool IsGameOver;
	//public ChallengeDef Challenge;
	public LevelDef LevelDef;

	public event Action<Level> RoundStarted;
	public event Action<Level> RoundEnded;

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

		Mode = mode;
		Reverse = false;
		FastTrack = false;
		IsGameOver = false;
		LevelDef = def;

		BetweenRounds = true;

		Spawner.ApplyCamoToo = null;
		Spawner.ApplyRegenToo = null;
		Spawner.BloonLevelOffsets = null;

		if (def.Music != null)
		{
			// #playdat
		}

		Cash = InitialCashByMode[(int)mode];
		CashMultiplier = 1; // TODO
		Health = InitialHealthByMode[(int)mode];
		Bloon.DifficultySpeedModifier = BloonSpeedModsByMode[(int)mode];

		CurrentTileSet = TileSets[0];
		StartTile = CurrentTileSet[0];
		WaveSet = new WaveSet();
		WaveSet.InitializeFromRoundsDef(Main.Instance.DefaultRounds);
		AddProcessable(WaveSet);
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

		for (int tick = 0; tick < UpdateMultiplier; tick++)
		{
			RoundTime += delta;

			// process collision grid

			for (int i = 0; i < AllBloons.Count; i++)
			{
				AllBloons[i].Process(delta);
			}

			base.Process(delta);
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
			CheckForRoundOver();
		}
	}

	public void CheckForRoundOver()
	{
		if (_endWaveTimer == null && !IsRoundInProgress && (Health > 0 || Mode == GameMode.Sandbox))
		{
			_endWaveTimer = new GameTimer(0.5);
			_endWaveTimer.Completed += _ =>
			{
				RoundOver();
				_endWaveTimer = null;
			};
		}
	}

	public void StartRound()
	{
		BetweenRounds = false;
		WaveHasCamo = false;

		if (Mode != GameMode.Sandbox)
		{
			WaveSet.StartWave(WaveIndex);
		}

		Bloon.Counter = 0;

		RoundTime = 0;
		RoundStarted.Invoke(this);
	}

	public void RoundOver()
	{
		BetweenRounds = true;
		RoundEnded.Invoke(this);

		WaveSet.CurrentWave = null;
		WaveIndex += 1;

		if (Mode == GameMode.Sandbox && WaveIndex > 84)
		{
			WaveIndex = 0;
		}
		if (Mode == GameMode.Apopalypse)
		{
			StartRound();
		}
		else
		{
			AddCash(100 + WaveIndex - 1);
		}
	}

	public bool IsRoundInProgress
	{
		get
		{
			if (WaveSet == null)
			{
				return false;
			}
			if (Mode == GameMode.Sandbox && AllBloons.Count > 0)
			{
				return true;
			}
			if (WaveSet.CurrentWave != null)
			{
				return !(WaveSet.CurrentWave.Complete && (AllBloons.Count == 0 || Mode == GameMode.Apopalypse));
			}

			return false;
		}
	}

	public void LoseLives(int RBE = 1)
	{
		if (Mode == GameMode.Sandbox)
		{
			return;
		}

		Health -= RBE;
		if (Health < 0)
		{
			Health = 0;
		}

		CheckForGameOver();
		// dispatchEvent health changed
	}

	public void CheckForGameOver()
	{
		if (Mode != GameMode.Sandbox)
		{
			if (!IsGameOver && Health <= 0)
			{
				SetGameOver();
			}
		}
	}

	public void SetGameOver()
	{
		IsGameOver = true;
	}

	public void AddCash(double amount)
	{
		Cash += amount * CashMultiplier;
	}
}
