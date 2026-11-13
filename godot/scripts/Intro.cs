using Godot;

public partial class Intro : Node2D 
{
	private void OnAnimationPlayerAnimationFinished(StringName animName) 
	{
        if (animName.Equals("intro")) 
		{
			GetTree().ChangeSceneToFile("res://scenes/game.tscn");
		}
    }
}