public static class ZIndices
{
	public const int MapBottom = -100;        // -999
	public const int RangeShade = 2;          // 0.6
	public const int Towers = 3;              // 1-1.5
	public const int Projectiles = 4;         // 2
	public const int AbilityEffects = 7;      // 3
	public const int Bursts = 10;             // 5
	public const int RangeOutline = 20;       // 10
	public const int Bananas = 30;            // 50
	public const int Lightning = 31;          // 55
	public const int HeartCrack = 40;         // 100
	public const int Reticle = 50;            // 300
	public const int MapTop = 60;             // 999
	public const int Moab = 70;               // 1200
	public const int Phoenix = 80;            // 1500
	public const int AceAircraft = 90;        // 2000
	public const int FullscreenEffects = 100;  // 3000
	public const int BloonsdayRay = 110;      // 9999
	public const int EntryMarkers = 130;      // 100000
	public const int TowerHighlight = 140;    // 9999999

	public static int BloonOnLayer(int tileLayer)
	{
		return tileLayer * 2;
	}
}
