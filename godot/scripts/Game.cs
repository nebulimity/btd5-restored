using Godot;

public partial class Game : Node2D {	
	public override void _Input(InputEvent @event) {
		if (@event.IsActionPressed("fullscreen")) {
			DisplayServer.WindowMode mode = DisplayServer.WindowGetMode();
			bool isWindowed = mode != DisplayServer.WindowMode.Fullscreen;
			
			if (isWindowed) {
				DisplayServer.WindowSetMode(DisplayServer.WindowMode.Fullscreen);
			} else {
				DisplayServer.WindowSetMode(DisplayServer.WindowMode.Windowed);
			}
		}
	}
}