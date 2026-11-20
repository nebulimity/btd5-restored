using System.Collections.Generic;

public class FootprintsFile
{
	public Dictionary<string, FootprintDef> Footprints { get; set; }
}

public class FootprintDef
{
	public FootprintBounds Bounds { get; set; }
	public int FrameWidth { get; set; }
	public int FrameHeight { get; set; }
	public bool Phases { get; set; }
	public List<FootprintExceptionDef> Exceptions { get; set; }
}

public class FootprintBounds
{
	public int Right { get; set; }
	public int Left { get; set; }
	public int Top { get; set; }
	public int Bottom { get; set; }
}

public class FootprintExceptionDef
{
	public int X { get; set; }
	public int YPhase { get; set; }
	public int Frame { get; set; }
}
