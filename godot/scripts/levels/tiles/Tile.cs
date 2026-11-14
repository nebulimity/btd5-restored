using System;
using System.Collections.Generic;

public enum TransitionTypes
{
	Road = 0,
	Underpass = 1,
	Teleport = 2
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

	// not in as3
	public static Tile FromDef(TileDef def)
	{
		Tile tile;
		switch (def.Type)
		{
			case "straight":
				tile = new StraightTile(new Vec2(def.Start[0], def.Start[1]), new Vec2(def.End[0], def.End[1]));
				break;
			case "arc":
				tile = new ArcTile(new Vec2(def.Center[0], def.Center[1]), new Vec2(def.Start[0], def.Start[1]), new Vec2(def.End[0], def.End[1]), def.Reflex);
				break;
			default:
				throw new InvalidOperationException($"unknown tile type of '{def.Type}' used");
		}

		tile.NextTileIndices = new List<int>(def.Next);
		tile.TransitionType = (TransitionTypes)def.Transition;
		tile.Layer = def.Layer;
		return tile;
	}

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

	public void UpdateBloonPosition(Bloon bloon)
	{
		if (bloon.TileProgress < 0)
		{
			if (PreviousTiles.Count != 0)
			{
				Tile previousTile = PreviousTiles[0];
				if (previousTile.TransitionType != TransitionTypes.Teleport)
				{
					bloon.TileProgress += previousTile.TileLength;
				}

				bloon.Tile = previousTile;
				previousTile.UpdateBloonPosition(bloon);
			}
			else
			{
				bloon.X = -5000;
			}

			return;
		}

		if (bloon.Type == BloonType.Invalid)
		{
			return;
		}
		if (TransitionType == TransitionTypes.Teleport)
		{
			bloon.TileProgress += TileLength;
		}

		int sectionIndex = (int)Math.Floor((Waypoints.Count - 1) * bloon.TileProgress / TileLength);
		double sectionProgress = (bloon.TileProgress - sectionIndex * SectionLength) / SectionLength;

		Tile nextTile;
		if (sectionIndex >= Waypoints.Count - 1)
		{
			bloon.TileProgress -= TileLength;
			if (NextTiles.Count != 0)
			{
				if (NextTiles.Count == 1)
				{
					nextTile = this.NextTiles[0];
				}
				else if (false == false)
				{
					++_pathAlternator;
					nextTile = NextTiles[_pathAlternator % NextTiles.Count];
				}

				if (bloon.Tile.IsWind)
				{
					bloon.OverallProgress = GetOverallProgress();
				}

				bloon.Tile = nextTile;
				nextTile.UpdateBloonPosition(bloon);
			}
			else
			{
				bloon.CompletePath();
			}
			return;
		}

		Vec2 sectionStart = Waypoints[sectionIndex];
		Vec2 sectionEnd = Waypoints[sectionIndex + 1];

		bloon.X = sectionStart.X + (sectionEnd.X - sectionStart.X) * sectionProgress;
		bloon.Y = sectionStart.Y + (sectionEnd.Y - sectionStart.Y) * sectionProgress;
	}

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