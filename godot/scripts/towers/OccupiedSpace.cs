public class OccupiedSpace
{
	public readonly Footprint Footprint;

	private int _twipsX;
	private int _twipsY;

	public OccupiedSpace(Footprint footprint)
	{
		Footprint = footprint;
	}

	public double X
	{
		get { return _twipsX / 20.0; }
		set { _twipsX = (int)(value * 20); }
	}

	public double Y
	{
		get { return _twipsY / 20.0; }
		set { _twipsY = (int)(value * 20); }
	}

	public int DirectPixelX => FloorDiv20(_twipsX);
	public int DirectPixelY => FloorDiv20(_twipsY);

	public int NestedPixelX => RoundHalfEvenDiv20(_twipsX);
	public int NestedPixelY => RoundHalfEvenDiv20(_twipsY);

	private static int FloorDiv20(int twips)
	{
		int q = twips / 20;
		if (twips % 20 < 0)
		{
			q--;
		}

		return q;
	}

	private static int RoundHalfEvenDiv20(int twips)
	{
		int q = FloorDiv20(twips);
		int r = twips - q * 20;

		if (r > 10)
		{
			return q + 1;
		}
		else if (r < 10)
		{
			return q;
		}

		return (q & 1) == 0 ? q : q + 1;
	}
}
