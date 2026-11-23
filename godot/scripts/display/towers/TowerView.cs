using Godot;

public partial class TowerView : Node2D
{
	private Tower _tower;
	private Sprite2D _main;

	public void Bind(Tower tower)
	{
		_tower = tower;
		_main = new Sprite2D();
		_main.Texture = GD.Load<Texture2D>($"res://assets/towers/{tower.Def.Display}/1.svg"); // TODO: use an asset manager in the future

		Position = new Vector2((float)tower.X, (float)tower.Y);
		Rotation = (float)tower.Rotation;

		AddChild(_main);
	}

	public void Sync(double alpha)
	{
		// Rotation = Mathf.LerpAngle((float)_tower.PrevRot, (float)_tower.Rotation, (float)alpha);
	}

	public void Unbind()
	{

	}
}
