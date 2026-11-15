using System;
using System.Collections.Generic;

public class ArcTile : Tile
{
	public Vec2 BaseCenter;
	public Vec2 BaseStart;
	public Vec2 BaseEnd;

	public bool Reflex;
	public bool Clockwise;

	public ArcTile(Vec2 baseCenter, Vec2 baseStart, Vec2 baseEnd, bool reflex)
	{
		BaseCenter = baseCenter;
		BaseStart = baseStart;
		BaseEnd = baseEnd;
		Reflex = reflex;
	}

	public override void Initialize(List<Tile> tileSet)
	{
		base.Initialize(tileSet);

		Vec2 startOffset;
		Vec2 endOffset;
		double radius;

		startOffset = Vec2.Subtract(BaseStart, BaseCenter);
		endOffset = Vec2.Subtract(BaseEnd, BaseCenter);
		radius = startOffset.Magnitude;
		double angle = Math.Acos(startOffset.Dot(endOffset) / (startOffset.Magnitude * endOffset.Magnitude));

		if (Reflex)
		{
			angle = 2 * Math.PI - angle;
		}

		TileLength = angle * radius;

		int sections = (int)Math.Ceiling(TileLength / MaxSectionLength);
		SectionLength = TileLength / sections;
		double startAngle = Math.Atan2(startOffset.Y, startOffset.X);
		double endAngle = Math.Atan2(endOffset.Y, endOffset.X);

		while (endAngle > startAngle && Math.Abs(endAngle - startAngle) > Math.PI)
		{
			endAngle -= 2 * Math.PI;
		}
		while (endAngle < startAngle && Math.Abs(endAngle - startAngle) > Math.PI)
		{
			endAngle += 2 * Math.PI;
		}

		Clockwise = !(endAngle < startAngle && !Reflex || endAngle > startAngle && Reflex);
		if (Reflex && Math.Abs(endAngle - startAngle) < Math.PI)
		{
			if (Clockwise)
			{
				endAngle += 2 * Math.PI;
			}
			else
			{
				endAngle -= 2 * Math.PI;
			}
		}

		Waypoints = new List<Vec2>();
		for (int i = 0; i <= sections; i++)
		{
			double pointAngle = startAngle + (endAngle - startAngle) * i / sections;
			Waypoints.Add(new Vec2(BaseCenter.X + Math.Cos(pointAngle) * radius, BaseCenter.Y + Math.Sin(pointAngle) * radius));
		}
	}

	public override double StartAngle
	{
		get
		{
			if (Clockwise)
			{
				return Math.Atan2(BaseCenter.X - BaseStart.X, BaseStart.Y - BaseCenter.Y);
			}

			return Math.Atan2(BaseStart.X - BaseCenter.X, BaseCenter.Y - BaseStart.Y);
		}
	}
	public override double EndAngle
	{
		get
		{
			if (!Clockwise)
			{
				return Math.Atan2(BaseCenter.X - BaseEnd.X, BaseEnd.Y - BaseCenter.Y);
			}

			return Math.Atan2(BaseEnd.X - BaseCenter.X, BaseCenter.Y - BaseEnd.Y);
		}
	}

	public override double StartX
	{
		get { return BaseStart.X; }
	}
	public override double StartY
	{
		get { return BaseStart.Y; }
	}

	public override double EndX
	{
		get { return BaseEnd.X; }
	}
	public override double EndY
	{
		get { return BaseEnd.Y; }
	}
}
