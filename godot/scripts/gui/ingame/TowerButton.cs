using Godot;

public partial class TowerButton : TextureButton
{
	private static readonly Texture2D DefaultTexture = GD.Load<Texture2D>("res://assets/ui/tower_buttons/default.svg");
	private static readonly Texture2D InvalidTexture = GD.Load<Texture2D>("res://assets/ui/tower_buttons/invalid.svg");
	private static readonly Material ValidMaterial = GD.Load<Material>("res://materials/tower_button/valid.tres");
	private static readonly Material InvalidMaterial = GD.Load<Material>("res://materials/tower_button/invalid.tres");

	[Export] private Sprite2D _icon;
	private bool _valid = true;

	public bool Valid
	{
		get { return _valid; }
		set
		{
			if (_valid == value) return;
			_valid = value;

			Disabled = !_valid;
			TextureNormal = _valid ? DefaultTexture : InvalidTexture;
			_icon.Material = _valid ? ValidMaterial : InvalidMaterial;
			MouseDefaultCursorShape = Valid ? CursorShape.PointingHand : CursorShape.Arrow;
		}
	}
}
