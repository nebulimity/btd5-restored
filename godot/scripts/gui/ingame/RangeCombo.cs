using Godot;

public partial class RangeCombo : Node2D
{
	private Node2D _rangeShade;
	private Node2D _rangeOutline;

	private float _radius = -1;
	private bool _valid = true;
	private Color _color;

	private static readonly Color ValidColor = Color.Color8(51, 51, 51, 127);
	private static readonly Color InvalidColor = Color.Color8(255, 0, 0, 127);

	public override void _Ready()
	{
		_rangeShade = new Node2D { ZIndex = ZIndices.RangeShade, ZAsRelative = false };
		_rangeOutline = new Node2D { ZIndex = ZIndices.RangeOutline, ZAsRelative = false };

		_rangeShade.Draw += OnShadeDraw;
		_rangeOutline.Draw += OnOutlineDraw;

		AddChild(_rangeShade);
		AddChild(_rangeOutline);
	}

	public void SetRange(double range, bool valid)
	{
		if (range >= 1000)
		{
			range = 50;
		}

		if (_radius == range && _valid == valid)
		{
			return;
		}

		_radius = (float)range;
		_valid = valid;
		_color = valid ? ValidColor : InvalidColor;

		_rangeShade.QueueRedraw();
		_rangeOutline.QueueRedraw();
	}

	private void OnShadeDraw()
	{
		if (_radius > 0)
		{
			_rangeShade.DrawCircle(Vector2.Zero, _radius, _color);
		}
	}

	private void OnOutlineDraw()
	{
		if (_radius > 0)
		{
			_rangeOutline.DrawCircle(Vector2.Zero, _radius + 1, _color, false, 2);
		}
	}
}
