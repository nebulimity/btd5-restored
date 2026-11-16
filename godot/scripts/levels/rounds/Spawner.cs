
public class Spawner
{
	public static int[] BloonLevelOffsets;
	public static bool[] ApplyCamoToo;
	public static bool[] ApplyRegenToo;

	public BloonType Type;
	public BloonType InitType;
	public bool Camo;
	public bool Regen;

	public int CurrentIndex { get; private set; }
	public double[] SpawnTimes { get; private set; }
	public int SpawnOrderOffset;

	public Spawner(int count, double start, double interval, BloonType type, bool camo, bool regen)
	{
		Type = type;
		InitType = type;
		Camo = camo;
		Regen = regen;

		if (BloonLevelOffsets != null)
		{
			Type += BloonLevelOffsets[(int)Type];
			Type = Type < 0 ? 0 : Type;
			Type = (int)Type > BloonLevelOffsets.Length - 1 ? (BloonType)(BloonLevelOffsets.Length - 1) : Type;
		}

		if (ApplyCamoToo != null && (int)Type < ApplyCamoToo.Length && ApplyCamoToo[(int)Type])
		{
			Camo = true;
		}
		if (ApplyRegenToo != null && (int)Type < ApplyRegenToo.Length && ApplyRegenToo[(int)Type])
		{
			Regen = true;
		}

		SpawnTimes = new double[count];

		for (int i = 0; i < count; i++)
		{
			SpawnTimes[i] = start + i * interval;
		}
	}

	public Spawner Clone()
	{
		double interval = 0;
		if (SpawnTimes.Length > 1)
		{
			interval = SpawnTimes[1] - SpawnTimes[0];
		}

		return new Spawner(SpawnTimes.Length, SpawnTimes[0], interval, InitType, Camo, Regen);
	}

	public void Process(double time)
	{
		while (CurrentIndex < SpawnTimes.Length && time > SpawnTimes[CurrentIndex])
		{
			Spawn(time - SpawnTimes[CurrentIndex], SpawnOrderOffset + Bloon.SpawnOrderStrideByType[(int)Type] * CurrentIndex);
			++CurrentIndex;
		}
	}

	public void Spawn(double overshoot, int spawnOrderIndex)
	{
		Level level = Main.Instance.Level;
		Bloon bloon = Pool<Bloon>.Get();
		double tileProgress = overshoot * Bloon.SpeedMultiplierByType[(int)Type] * Bloon.BaseSpeed; // as3 uses base speed only

		bloon.SpawnOrderIndex = spawnOrderIndex;
		bloon.Initialize(Type, level.StartTile, tileProgress, Regen, Camo, level.RoundTime);

		level.AddBloon(bloon);
	}

	public int RBE
	{
		get { return Bloon.RBEByType[(int)Type] * SpawnTimes.Length; }
	}
}
