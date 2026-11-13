using System;
using System.Collections.Generic;

public class Scene : IProcessable
{
	private List<IProcessable> _processables = new List<IProcessable>();
	private HashSet<IProcessable> _culled = new HashSet<IProcessable>();
	private HashSet<IProcessable> _removed = new HashSet<IProcessable>();
	private Predicate<IProcessable> _shouldRemove;

	public Scene()
	{
		_shouldRemove = processable => _culled.Contains(processable) && _removed.Add(processable);
	}

	public virtual void Process(double delta)
	{
		for (int i = 0; i < _processables.Count; i++)
		{
			if (!_culled.Contains(_processables[i]))
			{
				_processables[i].Process(delta);
			}
		}

		foreach (var processable in _culled)
		{
			if (processable is GameTimer timer)
			{
				timer.Destroy();
			}
		}

		_processables.RemoveAll(_shouldRemove);
		_culled.Clear();
		_removed.Clear();
	}

	public void Clear()
	{
		foreach (var processable in _processables)
		{
			if (processable is GameTimer timer)
			{
				timer.Destroy();
			}
		}

		_processables.Clear();
	}

	public void AddProcessable(IProcessable processable)
	{
		_processables.Add(processable);
	}

	public void AddEntity(Entity entity)
	{
		entity.Scene = this;
		_processables.Add(entity);

	}

	public void Cull(IProcessable processable)
	{
		_culled.Add(processable);
	}
}
