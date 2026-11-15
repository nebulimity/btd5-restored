using System;
using System.Collections.Generic;

public class Wave
{
	public List<Spawner> WaveSpawners = new List<Spawner>();
	private List<Spawner> _activeSpawners = new List<Spawner>();

	public int RBE;
	public double RBEDensity;
	public double WaveLength;

	public static double CalculateSpawnInterval(int waveIndex)
	{
		if (waveIndex > 40)
		{
			return 1 - 0.4 - 0.0015 * waveIndex;
		}

		return 1 - 0.01 * waveIndex;
	}

	public void CreateFromRoundDef(RoundDef def)
	{
		foreach (var groupDef in def.Groups)
		{
			foreach (var spawnerDef in groupDef.Spawners)
			{
				double interval;

				if (spawnerDef.Count == 1)
				{
					interval = 0;
				}
				else
				{
					interval = spawnerDef.Length / (spawnerDef.Count - 1);
				}

				if (groupDef.Bloon.Camo)
				{
					Main.Instance.Level.WaveHasCamo = true;
				}

				Spawner spawner = new Spawner(spawnerDef.Count, spawnerDef.Start, interval, groupDef.Bloon.Type, groupDef.Bloon.Camo, groupDef.Bloon.Regen);
				RBE += spawner.RBE;
				WaveSpawners.Add(spawner);
				UpdateRoundLength(spawner);
			}
		}

		RBEDensity = RBE / WaveLength;
	}

	public void Start()
	{
		_activeSpawners.Clear();

		foreach (var spawner in WaveSpawners)
		{
			_activeSpawners.Add(spawner.Clone());
		}

		int offset = 0;
		for (int i = 0; i < _activeSpawners.Count; i++)
		{
			Spawner spawner = _activeSpawners[i];
			spawner.SpawnOrderOffset = offset;
			offset += Bloon.SpawnOrderStrideByType[(int)spawner.Type] * spawner.SpawnTimes.Length;
		}
	}

	// GetRoundDef() is unused

	public void AddSpawners(int count, BloonType type, double interval, double start, bool camo = false, bool regen = false)
	{
		if (camo)
		{
			Main.Instance.Level.WaveHasCamo = true;
		}

		Spawner spawner = new Spawner(count, start, interval, type, camo, regen);
		RBE += spawner.RBE;
		WaveSpawners.Add(spawner);
		UpdateRoundLength(spawner);
	}

	public void Process(double time)
	{
		foreach (var spawner in _activeSpawners)
		{
			spawner.Process(time);
		}
	}

	private void UpdateRoundLength(Spawner spawner)
	{
		double[] times = spawner.SpawnTimes;
		if (times.Length > 0)
		{
			double first = times[0];
			double last = times[times.Length - 1];

			WaveLength = Math.Max(WaveLength, first);
			WaveLength = Math.Max(WaveLength, last);
		}
	}

	public bool Complete
	{
		get
		{
			foreach (var spawner in _activeSpawners)
			{
				if (spawner.CurrentIndex != spawner.SpawnTimes.Length)
				{
					return false;
				}
			}

			return true;
		}
	}
}
