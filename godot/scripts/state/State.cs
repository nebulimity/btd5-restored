public abstract class State
{
	public Machine Machine;

	public State Message(Message message)
	{
		return null;
	}

	public virtual void Enter(Message message) { }
	public virtual void Exit() { }
}
