using System.Collections.Generic;

public enum TransitionTypes
{
	Road = 0,
	Underpass = 1,
	Teleport = 2,
}

public class Tile
{
	public TransitionTypes TransitionType;
	public int Layer;

	public List<int> NextTileIndices = new List<int>();
	public List<Tile> NextTiles = new List<Tile>();
	public List<Tile> PreviousTiles = new List<Tile>();

	protected const double MaxSectionLength = 1;
	public double TileLength;
	public double SectionLength;

	public List<Vec2> Waypoints = new List<Vec2>();

	private int _pathAlternator;

	public bool Initialized;
	public bool IsWind;

	private List<Tile> _precalculatedAllPreviousTiles = null;

	public double DistanceAtTileStart = -1;
	public double PrecalculatedDistanceToEnd = -1;
	public double PrecalculatedDistanceToStart = -1;

	public virtual void Initialize(List<Tile> tileSet)
	{
		if (Initialized)
		{
			return;
		}

		foreach (var i in NextTileIndices)
		{
			Tile nextTile = tileSet[i];
			NextTiles.Add(nextTile);
			nextTile.PreviousTiles.Add(this);
		}

		Initialized = true;
	}

	// UpdateBloonPosition()
	// UpdateBloonTrapPosition()

	public virtual double StartAngle
	{
		get { return 0; }
	}
	public virtual double EndAngle
	{
		get { return 0; }
	}

	public virtual double StartX
	{
		get { return 0; }
	}
	public virtual double StartY
	{
		get { return 0; }
	}

	public virtual double EndX
	{
		get { return 0; }
	}
	public virtual double EndY
	{
		get { return 0; }
	}

	// these are unused for some reason

	// public bool IsTunnelStart
	// {
	// 	get
	// 	{
	// 		if (TransitionType == TransitionTypes.Underpass)
	// 		{
	// 			return false;
	// 		}

	// 		foreach (var tile in NextTiles)
	// 		{
	// 			if (tile.TransitionType == TransitionTypes.Underpass)
	// 			{
	// 				return true;
	// 			}
	// 		}

	// 		return false;
	// 	}
	// }

	// public bool IsTunnelEnd
	// {
	// 	get
	// 	{
	// 		if (TransitionType == TransitionTypes.Underpass)
	// 		{
	// 			return false;
	// 		}

	// 		foreach (var tile in PreviousTiles)
	// 		{
	// 			if (tile.TransitionType == TransitionTypes.Underpass)
	// 			{
	// 				return true;
	// 			}
	// 		}

	// 		return false;
	// 	}
	// }

	public void GetAllPreviousTiles(List<Tile> result)
	{
		if (_precalculatedAllPreviousTiles != null)
		{
			foreach (var tile in _precalculatedAllPreviousTiles)
			{
				result.Add(tile);
			}

			return;
		}

		foreach (var tile in PreviousTiles)
		{
			tile.GetAllPreviousTiles(result);
			if (tile.TransitionType == TransitionTypes.Road)
			{
				result.Add(tile);
			}
		}

		_precalculatedAllPreviousTiles = new List<Tile>();
		foreach (var tile in result)
		{
			_precalculatedAllPreviousTiles.Add(tile);
		}
	}

	public double GetOverallProgress()
	{
		if (DistanceAtTileStart == -1)
		{
			DistanceAtTileStart = 0;
			if (PreviousTiles.Count != 0)
			{
				DistanceAtTileStart = PreviousTiles[0].GetOverallProgress();
				DistanceAtTileStart += PreviousTiles[0].TileLength;
			}
		}

		return DistanceAtTileStart;
	}

	public double GetDistanceToEnd()
	{
		if (PrecalculatedDistanceToEnd != -1)
		{
			return PrecalculatedDistanceToEnd;
		}

		double distance = TransitionType == TransitionTypes.Teleport ? 0 : TileLength;
		double longest = 0;
		double nextDistance;

		for (int i = 0; i < NextTiles.Count; i++)
		{
			nextDistance = NextTiles[i].GetDistanceToEnd();
			if (nextDistance > longest)
			{
				longest = nextDistance;
			}
		}

		distance += longest;
		PrecalculatedDistanceToEnd = distance;
		return distance;
	}

	public double GetDistanceToStart()
	{
		if (PrecalculatedDistanceToStart != -1)
		{
			return PrecalculatedDistanceToStart;
		}

		double distance = TransitionType == TransitionTypes.Teleport ? 0 : TileLength;
		// double longest = 0;
		double previousDistance = 0;

		for (int i = 0; i < PreviousTiles.Count; i++)
		{
			previousDistance = PreviousTiles[i].GetDistanceToStart();
			// if (previousDistance > longest)
			// {
			// 	longest = previousDistance;
			// }
		}

		distance += previousDistance; // checked with bytecode, adds the LAST previous distance, not the max, ninja kiwi bug
		PrecalculatedDistanceToStart = distance;
		return distance;
	}
}
