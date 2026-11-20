using System.Collections.Generic;

public class TerrainSet
{
	public TerrainType Track;
	public TerrainType DeadZone;
	public TerrainType Water;
	public TerrainType Land;
	public TerrainType Unplaceable;

	private List<OccupiedSpace> _towerTestMapSource;

	private readonly Dictionary<Tower, TerrainType> _towerMadeWater = new();
	private readonly Dictionary<Tower, TerrainType> _towerMadeLand = new();
	private readonly Dictionary<Tower, TerrainType> _platforms = new();

	public TerrainSet(byte[] track, byte[] deadZone, byte[] water)
	{
		if (track != null)
		{
			Track = new TerrainType(track);
		}
		if (deadZone != null)
		{
			DeadZone = new TerrainType(deadZone);
		}
		if (water != null)
		{
			Water = new TerrainType(water);
		}

		Land = Water != null ? TerrainType.InverseOf(Water) : TerrainType.Solid();

		GenerateTestMaps();
	}

	public void GenerateTestMaps()
	{
		Unplaceable = new TerrainType();

		if (Track != null)
		{
			Unplaceable.MarkTouched(Track);
		}
		if (DeadZone != null)
		{
			Unplaceable.MarkTouched(DeadZone);
		}

		if (_towerTestMapSource != null)
		{
			foreach (OccupiedSpace space in _towerTestMapSource)
			{
				Unplaceable.MarkTouched(space.Footprint, space.NestedPixelX, space.NestedPixelY);
			}
		}
	}

	public void AddTower(Tower tower, List<Tower> allTowers)
	{
		if (tower.Def.ChangesTerrain != TerrainChange.No)
		{
			AddTerrainChangingTower(tower);
		}

		if (tower.Def.IsPlatform)
		{
			_platforms[tower] = new TerrainType(tower.OccupiedSpace);
		}
		else
		{
			CheckAndAddToPlatform(tower);
		}

		UpdateTowerMap(allTowers);
	}

	public void RemoveTower(Tower tower, List<Tower> allTowers)
	{
		if (tower.Def.ChangesTerrain != TerrainChange.No)
		{
			RemoveTerrainChangingTower(tower);
		}

		if (tower.Def.IsPlatform)
		{
			_platforms.Remove(tower);
		}
		else
		{
			CheckAndRemoveFromPlatform(tower);
		}

		UpdateTowerMap(allTowers);
	}

	public void UpdateTowerMap(List<Tower> towers)
	{
		_towerTestMapSource = null;

		if (towers != null)
		{
			foreach (Tower tower in towers)
			{
				if (tower.Def != null && tower.Def.IsPlatform)
				{
					continue;
				}

				_towerTestMapSource ??= new List<OccupiedSpace>();
				_towerTestMapSource.Add(tower.OccupiedSpace);
			}
		}

		GenerateTestMaps();
	}

	private void AddTerrainChangingTower(Tower tower)
	{
		switch (tower.Def.ChangesTerrain)
		{
			case TerrainChange.Water:
				_towerMadeWater[tower] = new TerrainType(tower.OccupiedSpace);
				break;
			case TerrainChange.Land:
				_towerMadeLand[tower] = new TerrainType(tower.OccupiedSpace);
				break;
		}
	}

	private void RemoveTerrainChangingTower(Tower tower)
	{
		switch (tower.Def.ChangesTerrain)
		{
			case TerrainChange.Water:
				_towerMadeWater.Remove(tower);
				break;
			case TerrainChange.Land:
				_towerMadeLand.Remove(tower);
				break;
		}
	}

	private void CheckAndAddToPlatform(Tower tower)
	{
		OccupiedSpace space = tower.OccupiedSpace;

		foreach ((Tower platform, TerrainType terrain) in _platforms)
		{
			if (terrain.IsWithin(space.Footprint, space.DirectPixelX, space.DirectPixelY))
			{
				platform.AddChildTower(tower);
				return;
			}
		}
	}

	private void CheckAndRemoveFromPlatform(Tower tower)
	{
		foreach (Tower platform in _platforms.Keys)
		{
			if (platform.IfRemovedChildTower(tower))
			{
				return;
			}
		}
	}

	public bool CanPlace(OccupiedSpace space, bool water = false, bool anywhere = false)
	{
		if (!IsInPlayArea(space))
		{
			return false;
		}

		int px = space.DirectPixelX;
		int py = space.DirectPixelY;

		if (anywhere)
		{
			return Unplaceable.IsOutside(space.Footprint, px, py);
		}
		if (water)
		{
			return OnWater(space) && Unplaceable.IsOutside(space.Footprint, px, py);
		}

		return OnLand(space) && Unplaceable.IsOutside(space.Footprint, px, py);
	}

	public bool IsOnTrack(OccupiedSpace space)
	{
		if (!IsInPlayArea(space))
		{
			return false;
		}

		return !Track.IsOutside(space.Footprint, space.DirectPixelX, space.DirectPixelY);
	}

	public bool OnWater(OccupiedSpace space)
	{
		return (Water != null && Water.IsWithin(space.Footprint, space.DirectPixelX, space.DirectPixelY) || CompletelyOnTowerMadeWater(space)) && !TouchingTowerMadeLand(space);
	}

	public bool OnLand(OccupiedSpace space)
	{
		return (Land.IsWithin(space.Footprint, space.DirectPixelX, space.DirectPixelY) || CompletelyOnTowerMadeLand(space)) && !TouchingTowerMadeWater(space);
	}

	private bool CompletelyOnTowerMadeWater(OccupiedSpace space) => AnyWithin(_towerMadeWater, space);
	private bool CompletelyOnTowerMadeLand(OccupiedSpace space) => AnyWithin(_towerMadeLand, space);
	private bool TouchingTowerMadeWater(OccupiedSpace space) => AnyTouching(_towerMadeWater, space);
	private bool TouchingTowerMadeLand(OccupiedSpace space) => AnyTouching(_towerMadeLand, space);

	private static bool AnyWithin(Dictionary<Tower, TerrainType> terrains, OccupiedSpace space)
	{
		foreach (TerrainType terrain in terrains.Values)
		{
			if (terrain.IsWithin(space.Footprint, space.DirectPixelX, space.DirectPixelY)) return true;
		}

		return false;
	}

	private static bool AnyTouching(Dictionary<Tower, TerrainType> terrains, OccupiedSpace space)
	{
		foreach (TerrainType terrain in terrains.Values)
		{
			if (!terrain.IsOutside(space.Footprint, space.DirectPixelX, space.DirectPixelY)) return true;
		}

		return false;
	}

	private static bool IsInPlayArea(OccupiedSpace space)
	{
		FootprintBounds bounds = space.Footprint.Bounds;
		double boundsX = bounds.Left / 20.0;
		double boundsY = bounds.Top / 20.0;
		double boundsWidth = bounds.Right / 20.0 - boundsX;
		double boundsHeight = bounds.Bottom / 20.0 - boundsY;

		return !(space.X + boundsX < 0 || space.Y + boundsY < 0 || space.X + boundsX + boundsWidth > TerrainType.PlayAreaWidth || space.Y + boundsY + boundsHeight > TerrainType.PlayAreaHeight);
	}
}
