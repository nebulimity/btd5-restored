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
	public TerrainSet TerrainSet;
	public Tile StartTile;
	public List<Tile> CurrentTileSet;
	public List<List<Tile>> TileSets;

	public WaveSet WaveSet;

	public int WaveIndex;
	public int Health;
	public double Cash;

	private static readonly double[] ModeCostMultipliers = [0.85, 1, 1.08, 1, 1, 1];
	private double _modeCostMultiplier;

	private static readonly int[] InitialCashByMode = [650, 650, 650, int.MaxValue, 50000, 650];
	private static readonly int[] InitialHealthByMode = [200, 150, 100, 200, 150, 150];
	private static readonly double[] BloonSpeedModsByMode = [0, 0.05, 0.125, 0, 0, 0];
	private static readonly int[] RoundsByMode = [50, 65, 85, 300, 300, 300];

	public List<Tower> AllTowers = new List<Tower>();
	public List<Bloon> AllBloons = new List<Bloon>();
	public event Action<Bloon> BloonAdded;
	public event Action<Bloon> BloonRemoved;

	public uint NextTowerId; // AS3: Coopinator.§;!$§

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
	// public ChallengeDef Challenge;
	public LevelDef LevelDef;

	public event Action RoundStarted;
	public event Action RoundEnded;
	public event Action CashChanged;
	public event Action HealthChanged;
	public event Action TowerAdded;

	public void Initialize()
	{

	}

	public void InitializeLevel(LevelDef def, GameMode mode, TerrainSet terrainSet)
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
		// Challenge = ;
		LevelDef = def;

		BetweenRounds = true;

		Spawner.ApplyCamoToo = null;
		Spawner.ApplyRegenToo = null;
		Spawner.BloonLevelOffsets = null;

		_modeCostMultiplier = ModeCostMultipliers[(int)mode];

		Cash = InitialCashByMode[(int)mode];
		CashMultiplier = 1; // TODO
		Health = InitialHealthByMode[(int)mode];
		Bloon.DifficultySpeedModifier = BloonSpeedModsByMode[(int)mode];

		TerrainSet = terrainSet;

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
			Pool<Bloon>.Release(bloon);
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

	public Tower CreateTower(uint owner, uint id, TowerDef def, double x, double y, double rotation, List<UpgradeDef> upgrades, double spentOn, uint seed)
	{
		Tower tower = new Tower { Owner = owner, Id = id, X = x, Y = y, SpentOn = spentOn, RootId = def.Id, BaseDef = def };

		tower.Initialize(def, true, unchecked((int)seed));
		tower.Rotation = rotation;

		if (tower.Def != null)
		{
			AddTower(tower);
		}

		return tower;
	}

	public void AddTower(Tower tower)
	{
		AddEntity(tower);
		AllTowers.Add(tower);

		// if not roadspikes and not pineapple
		// TerrainSet.AddTower(tower);
		// CollisionGrid.RegisterTower(tower);

		TowerAdded?.Invoke();
	}

	public bool IsPlaceable(OccupiedSpace space, bool isBoat = false, bool canPlaceOnTrack = false, bool isAmphibious = false)
	{
		if (canPlaceOnTrack)
		{
			return TerrainSet.IsOnTrack(space);
		}

		return TerrainSet.CanPlace(space, isBoat, isAmphibious);
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
		RoundStarted?.Invoke();
	}

	public void RoundOver()
	{
		BetweenRounds = true;
		RoundEnded?.Invoke();

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

	public int EndRound // temp: use ChallengeDef.EndRound instead of this (once challenges are ported)
	{
		get { return RoundsByMode[(int)Mode]; }
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
		HealthChanged?.Invoke();
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
		CashChanged?.Invoke();
	}

	public int Purchase(double cost, double x, double y, string towerId, Tower tower)
	{
		double newCost = CalcCostMods(cost, x, y, towerId, tower);

		if (Mode != GameMode.Sandbox)
		{
			Cash -= newCost;
			CashChanged?.Invoke();
		}

		return (int)newCost;
	}

	public int CalcCostMods(double cost, double x, double y, string towerId, Tower tower)
	{
		double newCost = CalcModeCostMod(cost);
		newCost = CalcSpecialtyCostMods(newCost, towerId);
		newCost = CalcAreaCostMods(newCost, x, y, tower);

		return (int)Math.Floor(newCost / 5 + 0.5) * 5;
	}

	public int CalcPrePlaceCostMods(double cost, string towerId)
	{
		double newCost = CalcModeCostMod(cost);
		newCost = CalcSpecialtyCostMods(newCost, towerId);

		return (int)Math.Floor(newCost / 5 + 0.5) * 5;
	}

	private int CalcSpecialtyCostMods(double cost, string towerId) // todo: ts gonna be boring asf ngl (all for tower cost btw)
	{
		// int _loc6_ = 0;
		// SpecialtyDef _loc7_;
		// if (Main.Instance.Profile.Specialties.SpecialtyActive == -1)
		{
			return (int)cost;
		}
		// double _loc3_ = cost;
		// TowerSpecialtiesDef _loc4_ = Main.Instance.SpecialtyFactory.§3f§();
		// int _loc5_ = Main.Instance.SpecialtyFactory.§< b§();
		//
		// if (_loc4_ != null)
		// {
		// 	if (_loc4_.TowerId == param2)
		// 	{
		// 		_loc6_ = 0;
		// 		while (_loc6_ < _loc4_.Tiers.Length && _loc6_ < _loc5_)
		// 		{
		// 			_loc7_ = _loc4_.tiers[_loc6_];
		// 			if (_loc7_.towerCostMod != 1)
		// 			{
		// 				_loc3_ *= _loc7_.towerCostMod;
		// 			}
		// 			_loc6_++;
		// 		}
		// 	}
		//
		// 	if (_loc4_.opposite != null && _loc4_.opposite.towerId == param2)
		// 	{
		// 		_loc3_ *= _loc4_.opposite.towerCostMod;
		// 	}
		// }
		// return _loc3_;
	}

	private int CalcAreaCostMods(double cost, double x, double y, Tower tower)
	{
		// double _loc5_ = param1;
		// List<AreaEffectDef> _loc6_ = GetAreaEffects(param2, param3, param4);

		// if (_loc6_ != null)
		// {
		// 	foreach (var _loc7_ in _loc6_)
		// 	{
		// 		_loc5_ *= _loc7_.CostScale;
		// 		if (_loc7_.CostScale != 1)
		// 		{
		// 			break;
		// 		}
		// 	}
		// }

		// return (int)_loc5_;

		return (int)cost;
	}

	public int CalcModeCostMod(double cost)
	{
		return (int)Math.Floor(cost * _modeCostMultiplier + 0.5);
	}

	public bool CanAfford(double cost, string towerId)
	{
		return CalcPrePlaceCostMods(cost, towerId) <= Cash;
	}

	public int GetReserveCount(string param1)
	{
		// var InventoryCount _loc2_ = null;
		//if (Reserves == null)
		{
			return 0;
		}

		// foreach (var _loc5_ in Reserves)
		// {
		// 	_loc2_ = _loc5_;
		// 	_loc5_;
		// 	if (_loc2_.id == param1)
		// 	{
		// 		return _loc2_.count;
		// 	}
		// }

		// return 0;
	}
}
