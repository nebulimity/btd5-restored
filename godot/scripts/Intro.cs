using Godot;

public partial class Intro : Node2D
{
	private float _prevOversampling;
	private Camera2D _camera;

	public override void _Ready()
	{
		_camera = GetNode<Camera2D>("Camera2D");
		var vp = GetViewport();
		_prevOversampling = vp.OversamplingOverride;
		vp.SizeChanged += UpdateOversampling;
		UpdateOversampling();
	}

	public override void _ExitTree()
	{
		var vp = GetViewport();
		vp.SizeChanged -= UpdateOversampling;
		vp.OversamplingOverride = _prevOversampling;
	}

	private void UpdateOversampling()
	{
		var vp = GetViewport();
		Vector2 stretch = vp.GetStretchTransform().Scale;
		Vector2 zoom = _camera.Zoom;
		vp.OversamplingOverride = Mathf.Max(stretch.X, stretch.Y) * Mathf.Max(zoom.X, zoom.Y);
	}

	private void OnAnimationPlayerAnimationFinished(StringName animName)
	{
		if (animName.Equals("intro"))
		{
			GetTree().ChangeSceneToFile("res://scenes/game.tscn");
		}
	}
}
