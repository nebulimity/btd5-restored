using System.Collections.Generic;

// not in as3
public class TileDef
{
	public string Type { get; set; }

	public double[] Start { get; set; }
	public double[] End { get; set; }
	public double[] Center { get; set; }

	public bool Reflex { get; set; }
	public List<int> Next { get; set; }
	public int Transition { get; set; }
	public int Layer { get; set; }
}