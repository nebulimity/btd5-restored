using Godot;

public partial class BloonView : Sprite2D
{
	private Bloon _bloon;
	private BloonType _lastType;
	private bool _wasRegen;
	// private bool _wasCamo;
	// private int _lastDamageFrame;
	private int _lastLayer;

	public void Bind(Bloon bloon)
	{
		_bloon = bloon;
		_lastType = bloon.Type;
		_wasRegen = bloon.IsRegen;
		_lastLayer = bloon.Tile.Layer;

		Texture = GD.Load<Texture2D>($"res://assets/bloons/normal/{(int)bloon.Type + 1}.svg"); // TODO: use an asset manager in the future
		Rotation = (float)bloon.Rotation;
		ZIndex = _lastType >= BloonType.MOAB ? Bloon.MoabLayer : _lastLayer;
		Visible = true;
	}

	public void Sync(double alpha)
	{
		double x = _bloon.PrevX + (_bloon.X - _bloon.PrevX) * alpha;
		double y = _bloon.PrevY + (_bloon.Y - _bloon.PrevY) * alpha;
		int layer = _bloon.Tile.Layer;

		Position = new Vector2((float)x, (float)y);

		if (_lastType != _bloon.Type)
		{
			Texture = GD.Load<Texture2D>($"res://assets/bloons/normal/{(int)_bloon.Type + 1}.svg"); // TODO
			_lastType = _bloon.Type;
		}
		if (_lastLayer != layer)
		{
			_lastLayer = layer;

			if (_lastType >= BloonType.MOAB)
			{
				ZIndex = Bloon.MoabLayer;
			}
			else
			{
				ZIndex = layer;
			}
		}
		if (_bloon.Type >= BloonType.MOAB)
		{
			Rotation = Mathf.LerpAngle((float)_bloon.PrevRot, (float)_bloon.Rotation, (float)alpha);
		}
	}

	public void Unbind()
	{
		_bloon = null;
		Visible = false;
	}
}
