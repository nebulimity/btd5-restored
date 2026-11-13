public class Level : Scene
{
	public int UpdateMultiplier = 1;
	public double RoundTime = 0;

	public void Initialize()
	{
		
	}

	public override void Process(double delta)
	{
		int tick = 0;
		while (tick < UpdateMultiplier)
		{
			RoundTime += delta;

			// process collision grid & bloons

			base.Process(delta);
			tick++;
		}
	}
}