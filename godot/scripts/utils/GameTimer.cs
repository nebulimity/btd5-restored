using System;

public class GameTimer : IProcessable
{
	public double Delay;
	public double Current;
	public bool Running;
	public int Repeat = 1;
	public int InitialRepeat = 1;

	public event Action<GameTimer> Completed;
	public event Action<GameTimer> Destroyed;

	public GameTimer(double delay, int repeat = 1)
	{
		Delay = delay;
		Repeat = repeat;
		InitialRepeat = repeat;
		Start();
	}

	public static double BTD4FramesToSeconds(int number)
	{
		return number / 35.0;
	}

	public static double BTD4FrameTime()
	{
		return BTD4FramesToSeconds(1);
	}

	public void Initialize(double delay, int repeat = 1)
	{
		Delay = delay;
		Repeat = repeat;
		InitialRepeat = repeat;
		Current = 0;
		Running = false;
		Start();
	}

	public virtual void Destroy()
	{
		Destroyed?.Invoke(this);
	}

	public void Start()
	{
		if (!Running)
		{
			Main.Instance.Level.AddProcessable(this);
			Running = true;
		}
	}

	public void Stop()
	{
		if (Running)
		{
			Main.Instance.Level.Cull(this);
			Running = false;
		}
	}

	public void Reset()
	{
		Stop();
		Current = 0;
		Repeat = InitialRepeat;
		Start();
	}

	public virtual void Process(double delta)
	{
		if (Delay <= 0.011)
		{
			Delay = 0.011;
		}

		Current += delta;
		while (Current >= Delay)
		{
			Current -= Delay;
			--Repeat;

			if (Repeat <= 0)
			{
				Stop();
				Destroy();
			}

			Completed?.Invoke(this);

			if (Repeat <= 0)
			{
				break;
			}
		}
	}
}
