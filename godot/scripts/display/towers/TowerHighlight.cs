using Godot;

public partial class TowerHighlight : CanvasGroup
{
	public Tower Tower { get; private set; }
	private Sprite2D _main;
	private string _sourceDisplay;

	private Vector2 _blur;
	private int _quality;
	private Vector2 _lastScale;

	public override void _Ready()
	{
		_main = new Sprite2D();
		AddChild(_main);
		UpdateOutlineParams();
	}

	public void UpdateOutlineParams()
	{
		var material = (ShaderMaterial)Material;
		_blur = new Vector2((float)material.GetShaderParameter("blur_x"), (float)material.GetShaderParameter("blur_y"));
		_quality = (int)material.GetShaderParameter("quality");
		_lastScale = Vector2.Zero;
		UpdateMargins();
	}

	private void UpdateMargins()
	{
		Vector2 scale = GetViewportTransform().Scale.Abs();
		if (scale == _lastScale) return;
		_lastScale = scale;

		Vector2 reach = _quality * (_blur * scale * 0.5f + Vector2.One);
		FitMargin = Mathf.Ceil(Mathf.Max(reach.X, reach.Y));
		ClearMargin = FitMargin * 2f;
	}

	public void SetTower(Tower tower)
	{
		if (tower != null && tower == Tower && tower.Def != null && tower.Def.Display == _sourceDisplay)
		{
			return;
		}

		Tower = tower;

		if (tower == null || tower.Def == null)
		{
			Visible = false;
			return;
		}

		_sourceDisplay = tower.Def.Display;
		_main.Texture = GD.Load<Texture2D>($"res://assets/towers/{_sourceDisplay}/1.svg"); // TODO: use an asset manager in the future
		Visible = true;
	}

	public override void _Process(double delta)
	{
		if (Tower == null || Tower.Def == null)
		{
			return;
		}
		if (Tower.Def.Display != _sourceDisplay)
		{
			SetTower(Tower);
		}

		Position = new Vector2((float)Tower.X, (float)Tower.Y);
		Rotation = (float)Tower.Rotation;
		UpdateOutlineParams();
	}
}
