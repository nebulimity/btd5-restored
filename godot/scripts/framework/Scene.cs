using System;
using System.Collections.Generic;

public class Scene : IProcessable
{
	List<IProcessable> processables = new List<IProcessable>();
	HashSet<IProcessable> culled = new HashSet<IProcessable>();
	HashSet<IProcessable> removed = new HashSet<IProcessable>();
	Predicate<IProcessable> shouldRemove;

	public Scene()
	{
		shouldRemove = processable => culled.Contains(processable) && removed.Add(processable);
	}

	public virtual void Process(double dt)
	{
		for (int i = 0; i < processables.Count; i++)
		{
			if (!culled.Contains(processables[i]))
			{
				processables[i].Process(dt);
			}
		}

		foreach (var processable in culled)
		{
			if (processable is GameTimer timer)
			{
				timer.Destroy();
			}
		}

		processables.RemoveAll(shouldRemove);
		culled.Clear();
		removed.Clear();
	}

	public void Clear()
	{
		foreach (var processable in processables)
		{
			if (processable is GameTimer timer)
			{
				timer.Destroy();
			}
		}

		processables.Clear();
	}

	public void AddProcessable(IProcessable processable)
	{
		processables.Add(processable);
	}

	public void AddEntity(Entity entity)
	{
		entity.Scene = this;
		processables.Add(entity);
		
	}

	public void Cull(IProcessable processable)
	{
		culled.Add(processable);
	}
}
