using System;

public class WaveSet : IProcessable
{
	public RoundsDef RoundsDef;
	public Wave CurrentWave;
	public double Time;
	// public bleh rndm = new bleh();  // public var rndm:§'#§ = new §'#§(); what the actual hell bro

	public void InitializeFromRoundsDef(RoundsDef roundsDef)
	{
		RoundsDef = roundsDef;
		// rndm.Seed = 0;
	}

	public int CurrentRBE
	{
		get
		{
			if (CurrentWave == null)
			{
				return 0;
			}

			return CurrentWave.RBE;
		}
	}

	public double CurrentWaveLength
	{
		get
		{
			if (CurrentWave == null)
			{
				return 0;
			}

			double length = 0;
			foreach (var waveSpawner in CurrentWave.WaveSpawners)
			{
				length = Math.Max(waveSpawner.SpawnTimes[waveSpawner.SpawnTimes.Length - 1], length);
			}

			return length;
		}
	}

	public void Process(double delta)
	{
		if (CurrentWave == null)
		{
			return;
		}

		Time += delta;
		CurrentWave.Process(Time);
	}

	public void StartWave(int round)
	{
		Time = 0;

		if (RoundsDef.Rounds.Count == 0)
		{
			return;
		}
		// if (§?!!§.Mode == GameModes.Apopalypse)
		//  {
		// 	CurrentWave = CreateApopalypseWave(round);
		// }
		// else
		if (round < RoundsDef.Rounds.Count)
		{
			CurrentWave = new Wave();
			CurrentWave.CreateFromRoundDef(RoundsDef.Rounds[round]);
		}
		else
		{
			//CurrentWave = CreateFreePlayWave(round);
		}

		CurrentWave.Start();
	}

	public bool Running
	{
		get { return !CurrentWave.Complete; }
	}
	public int WaveCount
	{
		get { return RoundsDef.Rounds.Count; }
	}

	// private Wave CreateApopalypseWave(int round)
	// private Wave CreateFreePlayWave(int round)

	// private int GetTotalWaves(int roundsIntoFreeplay)
	// {
	// 	if (roundsIntoFreeplay > 10)
	// 	{
	// 		return Math.Min(16 + (roundsIntoFreeplay - 10) * 0.2, 20);
	// 	}

	// 	return roundsIntoFreeplay + 6;
	// }

	// private int GetRandomType(int param1)
	// private double GetInterval(int param1)

	public double GetRoundLength()
	{
		if (CurrentWave == null)
		{
			return 0;
		}

		return CurrentWave.WaveLength;
	}
}
