using System;

public class Vec2
{
	public double X;
	public double Y;

	public Vec2(double x = 0, double y = 0)
	{
		X = x;
		Y = y;
	}

	public static Vec2 Add(Vec2 a, Vec2 b)
	{
		return new Vec2(a.X + b.X, a.Y + b.Y);
	}

	public static Vec2 Subtract(Vec2 a, Vec2 b)
	{
		return new Vec2(a.X - b.X, a.Y - b.Y);
	}

	public static Vec2 Project(Vec2 v, Vec2 onto)
	{
		double scale = v.Dot(onto) / onto.Dot(onto);
		return new Vec2(onto.X * scale, onto.Y * scale);
	}

	public void FromPolar(double angle, double length)
	{
		X = Math.Cos(angle) * length;
		Y = Math.Sin(angle) * length;
	}

	public double Rotation
	{
		get { return Math.Atan2(Y, X); }
		set
		{
			double magnitude = Magnitude;
			X = magnitude * Math.Cos(value);
			Y = magnitude * Math.Sin(value);
		}
	}

	public double Magnitude
	{
		get { return Math.Sqrt(X * X + Y * Y); }
		set
		{
			if (X == 0 && Y == 0)
			{
				X = 1;
				Y = 0;
				ScaleBy(value);
			}
			else
			{
				ScaleBy(value / Magnitude);
			}
		}
	}

	public void ScaleBy(double factor)
	{
		X *= factor;
		Y *= factor;
	}

	public double GetMagnitudeSquared()
	{
		return X * X + Y * Y;
	}

	public double Dot(Vec2 other)
	{
		return other.X * X + other.Y * Y;
	}

	public double Cross(Vec2 other)
	{
		return X * other.Y - Y * other.X;
	}

	public void RotateBy(double angle)
	{
		double newAngle = angle + Math.Atan2(Y, X);
		double magnitude = Math.Sqrt(X * X + Y * Y);
		X = Math.Cos(newAngle) * magnitude;
		Y = Math.Sin(newAngle) * magnitude;
	}

	public Vec2 GetPerpendicular()
	{
		return new Vec2(-Y, X);
	}

	// public Vec2 ApplyTransform()

	public double AngleBetween(Vec2 other)
	{
		double angle = Math.Acos(Dot(other) / (Magnitude * other.Magnitude));
		bool isPositive = other.X * -Y + other.Y * X > 0; // GetPerpendicular().Dot(other) > 0;

		if (!isPositive)
		{
			angle = -angle;
		}

		return angle;
	}

	public void AddVec(Vec2 other)
	{
		X += other.X;
		Y += other.Y;
	}
}
