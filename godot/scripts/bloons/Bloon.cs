using System;
using System.Collections.Generic;

public enum BloonType
{
	Invalid = -1,
	Red = 0,
	Blue = 1,
	Green = 2,
	Yellow = 3,
	Pink = 4,
	Black = 5,
	White = 6,
	Lead = 7,
	Zebra = 8,
	Rainbow = 9,
	Ceramic = 10,
	MOAB = 11,
	BFB = 12,
	Boss = 13
}

[Flags]
public enum Immunities
{
	None = 0,
	NoDetection = 1,
	Ice = 2,
	Glue = 4,
	Splosion = 8,
	Wind = 16,
	Lead = 32,
	MOAB = 64,
	BFB = 128,
	ZOMG = 256,
	All = 65535
}

public class Bloon : Entity
{
	public const int BloonCount = 14;

	public static readonly BloonType[] AllBloonTypes = [BloonType.Red, BloonType.Blue, BloonType.Green, BloonType.Yellow, BloonType.Pink, BloonType.Black, BloonType.White, BloonType.Lead, BloonType.Zebra, BloonType.Rainbow, BloonType.Ceramic, BloonType.MOAB, BloonType.BFB, BloonType.Boss];

	public static bool WeakMoabs;

	public const double BaseSpeed = 70;
	public static double DifficultySpeedModifier;
	private const double MaxDeltaRotation = 0.12;

	private static readonly int[] MaxHealthByType = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 200, 700, 4000];
	public static readonly double[] SpeedMultiplierByType = [1, 1.4, 1.8, 3.2, 3.5, 1.8, 2, 1, 1.8, 2.2, 2.5, 1, 0.25, 0.18];
	private static readonly Immunities[] BaseImmunitiesByType = [Immunities.None, Immunities.None, Immunities.None, Immunities.None, Immunities.None, Immunities.Splosion, Immunities.Ice, Immunities.Lead, Immunities.Ice | Immunities.Splosion, Immunities.None, Immunities.None, Immunities.Glue | Immunities.Ice | Immunities.MOAB, Immunities.Glue | Immunities.Ice | Immunities.BFB, Immunities.Glue | Immunities.Ice | Immunities.ZOMG];
	public static readonly int[] RBEByType = [1, 2, 3, 4, 5, 11, 11, 23, 23, 47, 104, 616, 3164, 16656];
	private static readonly int[] ChildCountByType = [1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4, 4];
	public static readonly double[] TargetRangeAddonsByType = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 110, 140];

	// sounds and stuff

	public const int WindLayer = 3;
	public const int MoabLayer = 1200;

	public static uint Counter = 0;

	public static readonly int[] SpawnOrderStrideByType = [1, 1, 1, 1, 1, 2, 2, 4, 4, 8, 16, 64, 256, 1024];
	public bool Sabotaged;
	public double SpawnTime;

	private Tile _tile;
	public Tile Tile
	{
		get { return _tile; }
		set { _tile = value; }
	}

	public double TileProgress;
	public double ProgressStep;
	public double OverallProgress;

	public BloonType Type = BloonType.Invalid;

	public int MaxHealth;
	public int Health;
	public int RBE;
	public Immunities Immunity;
	public bool IsMoving = true;
	public bool IsCamo;
	public bool IsRegen;

	public BloonType RegenCeiling;
	private double _regenCountdown;
	private double _regenInterval = 3;

	public double Radius;
	public int CollisionCellIndex = -1;
	public double TargetAddon;

	// effects: iced, glued, stunned

	public bool WasWhite;

	public uint Id = uint.MaxValue;
	public uint LifetimeId = uint.MaxValue;
	public List<uint> ParentIds = new List<uint>();

	public int SpawnOrderIndex;

	private Vec2 _lastPosition = new Vec2();
	public double PrevX;
	public double PrevY;
	public double PrevRot;

	public void Initialize(BloonType type, Tile tile, double tileProgress, bool regen = false, bool camo = false, double spawnTime = 0)
	{
		Id = Counter++;
		LifetimeId = Id;
		SpawnTime = spawnTime;
		OverallProgress = 0;
		WasWhite = false;
		_tile = tile;
		TileProgress = tileProgress;
		ParentIds.Clear();

		IsCamo = camo && type < BloonType.MOAB;
		IsRegen = regen && type < BloonType.MOAB;
		RegenCeiling = type;
		SetType(type);

		tile.UpdateBloonPosition(this);
		Vec2 start = tile.Waypoints[0];
		Vec2 next = tile.Waypoints[1];
		Rotation = Math.Atan2(next.Y - start.Y, next.X - start.X);

		PrevX = X;
		PrevY = Y;
		PrevRot = Rotation;
	}

	public void SetType(BloonType newType)
	{
		if (IsRegen)
		{
			if (Type == RegenCeiling)
			{
				_regenCountdown = _regenInterval;
			}
		}

		Type = newType;
		Health = MaxHealth = MaxHealthByType[(int)newType];
		ProgressStep = BaseSpeed * (SpeedMultiplierByType[(int)newType] + DifficultySpeedModifier);

		if (Main.Instance.Level.WaveIndex >= 85 && newType == BloonType.Ceramic)
		{
			Health = 38;
		}

		if (newType >= BloonType.MOAB)
		{
			int roundsIntoFreeplay = Main.Instance.Level.WaveIndex - 85;
			if (roundsIntoFreeplay >= 0)
			{
				if (roundsIntoFreeplay > 30)
				{
					Health = MaxHealth = (int)(Health * (1.5 + (roundsIntoFreeplay - 30) * 0.05 + 30 * 0.02));
				}
				else
				{
					Health = MaxHealth = (int)(Health * (1.5 + roundsIntoFreeplay * 0.02));
				}
			}
		}

		if (newType >= BloonType.MOAB && WeakMoabs)
		{
			Health /= 2;
		}

		RBE = RBEByType[(int)newType];
		TargetAddon = TargetRangeAddonsByType[(int)newType];

		if (newType == BloonType.White)
		{
			WasWhite = true;
		}

		CalculateImmunity();
	}

	private void CalculateImmunity()
	{
		if (Type == BloonType.Invalid)
		{
			return;
		}

		Immunity = BaseImmunitiesByType[(int)Type];
		if (IsCamo)
		{
			Immunity |= Immunities.NoDetection;
		}
		// TODO
		// if (GlueCountdown != 0)
		// {
		// 	Immunity |= Immunities.Glue;
		// }
	}

	public void CompletePath()
	{
		Destroy();
		Main.Instance.Level.LoseLives(RBE);
		// dispatchEvent attack
	}

	public override void Process(double delta)
	{
		if (_tile == null || Type == BloonType.Invalid)
		{
			return;
		}

		double speedScale = Math.Max(6.6 * ((Main.Instance.Level.WaveIndex - 85) / (200.0 - 85)), 1);

		if (Sabotaged)
		{
			speedScale *= 0.5;
		}
		// if (ArticWindCountdown > 0)
		// if (Stunned)
		// if (Iced)
		// if (Glued)
		// if (Burning)

		_lastPosition.X = X;
		_lastPosition.Y = Y;

		if (_tile == null || Type == BloonType.Invalid)
		{
			return;
		}

		if (IsMoving)
		{
			TileProgress += ProgressStep * delta * speedScale; // * PermafrostSpeedScale;
			OverallProgress += ProgressStep * delta * speedScale; // * PermafrostSpeedScale;
			_tile.UpdateBloonPosition(this);

			if (_tile == null || Type == BloonType.Invalid)
			{
				return;
			}
		}

		if (Type >= BloonType.MOAB && _lastPosition.X != X || _lastPosition.Y != Y)
		{
			double targetRotation = Math.Atan2(Y - _lastPosition.Y, X - _lastPosition.X);
			while (targetRotation - Rotation > Math.PI)
			{
				targetRotation -= 2 * Math.PI;
			}
			while (targetRotation - Rotation <= -Math.PI)
			{
				targetRotation += 2 * Math.PI;
			}
			if (targetRotation > Rotation)
			{
				Rotation = Math.Min(targetRotation, Rotation + MaxDeltaRotation);
			}
			else if (targetRotation < Rotation)
			{
				Rotation = Math.Max(targetRotation, Rotation - MaxDeltaRotation);
			}
		}

		// collision grid stuff
		// if (IsRegen)

		//base.Process(delta);
	}

	public override void Destroy()
	{
		Type = BloonType.Invalid;
		Main.Instance.Level.RemoveBloon(this);

		//base.Destroy();
	}
}
