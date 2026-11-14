using Godot;
using System.Collections.Generic;

public partial class BloonLayer : Node2D
{
	private Level _level;
	private Dictionary<Bloon, BloonView> _views = new Dictionary<Bloon, BloonView>();

	public void Initialize(Level level)
	{
		_level = level;

		level.BloonAdded += OnBloonAdded;
		level.BloonRemoved += OnBloonRemoved;
	}

	public void SyncAll(double alpha)
	{
		foreach (var view in _views.Values)
		{
			view.Sync(alpha);
		}
	}

	private void OnBloonAdded(Bloon bloon)
	{
		BloonView view = new BloonView();
		AddChild(view);
		MoveChild(view, 0);
		view.Bind(bloon);

		_views.Add(bloon, view);
	}

	private void OnBloonRemoved(Bloon bloon)
	{
		if (_views.TryGetValue(bloon, out BloonView view))
		{
			_views.Remove(bloon);
			view.Unbind();
			view.QueueFree();
		}
	}

	public override void _ExitTree()
	{
		_level.BloonAdded -= OnBloonAdded;
		_level.BloonRemoved -= OnBloonRemoved;
	}
}
