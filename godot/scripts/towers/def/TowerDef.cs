public class TowerDef
{
	public string Id { get; set; }

	public double RangeOfVisibility { get; set; }
	public string Display { get; set; }

	public bool Rotates { get; set; } = true;
	public bool IsLand { get; set; } = true;
	public bool CanPriorityTarget { get; set; } = true;
	public bool RequiresTarget { get; set; } = true;
}
