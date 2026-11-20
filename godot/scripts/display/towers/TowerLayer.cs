using Godot;
using System.Collections.Generic;

public partial class TowerLayer : Node2D
{
	private Level _level;
	private Dictionary<Tower, TowerView> _views = new Dictionary<Tower, TowerView>();

	public void Initialize(Level level)
	{
		_level = level;

		level.TowerAdded += OnTowerAdded;
		level.TowerRemoved += OnTowerRemoved;
	}

	public void SyncAll(double alpha)
	{
		foreach (var view in _views.Values)
		{
			view.Sync(alpha);
		}
	}

	private void OnTowerAdded(Tower tower)
	{
		TowerView view = new TowerView();
		AddChild(view);
		view.Bind(tower);

		_views.Add(tower, view);
	}

	private void OnTowerRemoved(Tower tower)
	{
		if (_views.TryGetValue(tower, out TowerView view))
		{
			_views.Remove(tower);
			view.Unbind();
			view.QueueFree();
		}
	}

	public override void _ExitTree()
	{
		_level.TowerAdded -= OnTowerAdded;
		_level.TowerRemoved -= OnTowerRemoved;
	}
}
