using Godot;

public partial class InGameMenu : Node
{
	[Export] private TextureButton _playButton;
	[Export] private TextureButton _fastForwardButton;

	[Export] private Sprite2D _blueArrows;
	[Export] private DpiTexture _defaultTexture;
	[Export] private DpiTexture _pressedTexture;
}
