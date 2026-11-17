public class Machine
{
	public State CurrentState;

	public void Send(Message message)
	{
		State state;
		if (CurrentState != null)
		{
			state = CurrentState.HandleMessage(message);
			if (state != null)
			{
				ChangeState(state, message);
			}
		}
	}

	public void ChangeState(State state, Message message)
	{
		if (CurrentState != null)
		{
			CurrentState.Exit();
		}

		CurrentState = state;
		CurrentState.Machine = this;
		CurrentState.Enter(message);
	}
}
