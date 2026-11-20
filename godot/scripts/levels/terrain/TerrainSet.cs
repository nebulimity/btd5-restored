public class TerrainSet
{
	public TerrainType Track;
	public TerrainType DeadZone;
	public TerrainType Water;
	public TerrainType Land;
	public TerrainType Unplaceable;

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

		// todo
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
		// todo: consumables: CompletelyOnTowerMadeWater(space), && !TouchingTowerMadeLand(space)
		return Water != null && Water.IsWithin(space.Footprint, space.DirectPixelX, space.DirectPixelY);
	}

	public bool OnLand(OccupiedSpace space)
	{
		// todo: consumables: CompletelyOnTowerMadeLand(space), && !TouchingTowerMadeWater(space)
		return Land.IsWithin(space.Footprint, space.DirectPixelX, space.DirectPixelY);
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
