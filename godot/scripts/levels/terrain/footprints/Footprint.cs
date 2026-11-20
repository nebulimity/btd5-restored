using System.Collections.Generic;
using System.Runtime.Versioning;

public readonly struct FootprintCell
{
	public readonly int Dx;
	public readonly int Dy;
	public readonly int Count;

	public FootprintCell(int dx, int dy, int count)
	{
		Dx = dx;
		Dy = dy;
		Count = count;
	}
}

public partial class Footprint
{
	public readonly FootprintBounds Bounds;

	private readonly bool _phases;
	private readonly FootprintCell[][][] _frames;
	private readonly Dictionary<(int, int), FootprintCell[][]> _exceptions = new();

	public Footprint(FootprintDef def, byte[] sheet, int sheetWidth, byte[] exceptions, int exceptionsWidth)
	{
		Bounds = def.Bounds;
		_phases = def.Phases;
		_frames = BuildFrames(sheet, sheetWidth, def.FrameWidth, def.FrameHeight);

		if (def.Exceptions.Count > 0)
		{
			FootprintCell[][][] exceptionFrames = BuildFrames(exceptions, exceptionsWidth, def.FrameWidth, def.FrameHeight);

			foreach (FootprintExceptionDef e in def.Exceptions)
			{
				_exceptions[(e.X, e.YPhase)] = exceptionFrames[e.Frame];
			}
		}
	}

	public FootprintCell[] GetCells(int px, int py)
	{
		int phase = (py & 3) * 4 + (px & 3);

		if (!_exceptions.TryGetValue((px, py & 3), out FootprintCell[][] frame))
		{
			frame = _phases ? _frames[phase] : _frames[0];
		}

		return frame[phase];
	}

	private static FootprintCell[][][] BuildFrames(byte[] alpha, int width, int frameWidth, int frameHeight)
	{
		int columns = width / frameWidth;
		int rows = alpha.Length / width / frameHeight;
		FootprintCell[][][] frames = new FootprintCell[columns * rows][][];

		for (int row = 0; row < rows; row++)
		{
			for (int column = 0; column < columns; column++)
			{
				frames[row * columns + column] = BuildFrame(alpha, width, column * frameWidth, row * frameHeight, frameWidth, frameHeight);
			}
		}

		return frames;
	}

	private static FootprintCell[][] BuildFrame(byte[] alpha, int width, int x0, int y0, int frameWidth, int frameHeight)
	{
		List<(int U, int V)> samples = new();

		for (int y = 0; y < frameHeight; y++)
		{
			for (int x = 0; x < frameWidth; x++)
			{
				if (alpha[(y0 + y) * width + x0 + x] > 0)
				{
					samples.Add((x - frameWidth / 2, y - frameHeight / 2));
				}
			}
		}

		FootprintCell[][] byPhase = new FootprintCell[16][];

		for (int b = 0; b < 4; b++)
		{
			for (int a = 0; a < 4; a++)
			{
				Dictionary<(int, int), int> counts = new();

				foreach ((int u, int v) in samples)
				{
					(int, int) cell = ((a + u) >> 2, (b + v) >> 2);
					counts[cell] = counts.GetValueOrDefault(cell) + 1;
				}

				FootprintCell[] cells = new FootprintCell[counts.Count];
				int i = 0;

				foreach (((int dx, int dy), int count) in counts)
				{
					cells[i++] = new FootprintCell(dx, dy, count);
				}

				byPhase[b * 4 + a] = cells;
			}
		}

		return byPhase;
	}
}
