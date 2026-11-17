using Godot;

public abstract class InGameMenuState : State
{
	protected InGameMenu Menu;

	public InGameMenuState(InGameMenu menu)
	{
		Menu = menu;
	}

	public virtual void HandleInput(InputEvent e) { }
	public virtual void Process(double delta) { }
}
