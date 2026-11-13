public class Entity : IProcessable
{
	public double X;
	public double Y;
	public double Rotation;
	public Scene Scene;

	public virtual void Destroy()
	{
		if (Scene != null)
		{
			Scene.Cull(this);
			Scene = null;
		}
	}

	public virtual void Process(double dt)
	{
		
	}
}
