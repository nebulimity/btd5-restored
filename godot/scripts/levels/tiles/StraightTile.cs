using System;
using System.Collections.Generic;

public class StraightTile : Tile
{
	public Vec2 StartPoint;
	public Vec2 EndPoint;

	public StraightTile(Vec2 startPoint, Vec2 endPoint)
	{
		StartPoint = startPoint;
		EndPoint = endPoint;
	}

	public override void Initialize(List<Tile> tileSet)
	{
		base.Initialize(tileSet);

		double dx = EndPoint.X - StartPoint.X;
		double dy = EndPoint.Y - StartPoint.Y;

		SectionLength = TileLength = Math.Sqrt(dx * dx + dy * dy);
		Waypoints = new List<Vec2> { StartPoint, EndPoint };
	}

	public override double EndAngle
	{
		get { return Math.Atan2(EndPoint.Y - StartPoint.Y, EndPoint.X - StartPoint.X); }
	}
	public override double StartAngle
	{
		get { return Math.Atan2(StartPoint.Y - EndPoint.Y, StartPoint.X - EndPoint.X); }
	}

	public override double StartX
	{
		get { return StartPoint.X; }
	}
	public override double StartY
	{
		get { return StartPoint.Y; }
	}

	public override double EndX
	{
		get { return EndPoint.X; }
	}
	public override double EndY
	{
		get { return EndPoint.Y; }
	}
}
