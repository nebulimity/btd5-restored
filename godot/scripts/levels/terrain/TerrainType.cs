using System;

public enum CellState : byte
{
	Empty,
	Touched,
	Full
}

public class TerrainType
{
	public const double StandardPrecisionScale = 0.25;
	public const int PlayAreaWidth = 700;
	public const int PlayAreaHeight = 520;

	public const int Width = (int)(PlayAreaWidth * StandardPrecisionScale);
	public const int Height = (int)(PlayAreaHeight * StandardPrecisionScale);

	private readonly CellState[] _cells = new CellState[Width * Height];

	public TerrainType() { }
	public TerrainType(byte[] alpha)
	{
		if (alpha.Length != PlayAreaWidth * PlayAreaHeight)
		{
			throw new ArgumentException("expected 700x520 alpha values", nameof(alpha));
		}

		for (int cy = 0; cy < Height; cy++)
		{
			for (int cx = 0; cx < Width; cx++)
			{
				bool anyCovered = false;
				bool allFull = true;

				for (int j = 0; j < 4; j++)
				{
					for (int i = 0; i < 4; i++)
					{
						byte a = alpha[(cy * 4 + j) * PlayAreaWidth + cx * 4 + i];

						if (a > 0)
						{
							anyCovered = true;
						}
						if (a != 255)
						{
							allFull = false;
						}
					}
				}

				if (allFull)
				{
					_cells[cy * Width + cx] = CellState.Full;
				}
				else if (anyCovered)
				{
					_cells[cy * Width + cx] = CellState.Touched;
				}
			}
		}
	}

	public static TerrainType InverseOf(TerrainType map)
	{
		TerrainType inverse = new TerrainType();

		for (int i = 0; i < map._cells.Length; i++)
		{
			if (map._cells[i] == CellState.Empty)
			{
				inverse._cells[i] = CellState.Full;
			}
			else if (map._cells[i] == CellState.Touched)
			{
				inverse._cells[i] = CellState.Touched;
			}
		}

		return inverse;
	}

	public static TerrainType Solid()
	{
		TerrainType solid = new TerrainType();
		Array.Fill(solid._cells, CellState.Full);

		return solid;
	}

	public void MarkTouched(TerrainType other)
	{
		for (int i = 0; i < other._cells.Length; i++)
		{
			if (other._cells[i] != CellState.Empty && _cells[i] == CellState.Empty)
			{
				_cells[i] = CellState.Touched;
			}
		}
	}

	public bool IsWithin(Footprint footprint, int px, int py)
	{
		foreach (FootprintCell cell in footprint.GetCells(px, py))
		{
			int cx = (px >> 2) + cell.Dx;
			int cy = (py >> 2) + cell.Dy;

			if (cx < 0 || cy < 0 || cx >= Width || cy >= Height)
			{
				continue;
			}
			if (_cells[cy * Width + cx] != CellState.Full)
			{
				return false;
			}
		}

		return true;
	}

	public bool IsOutside(Footprint footprint, int px, int py)
	{
		foreach (FootprintCell cell in footprint.GetCells(px, py))
		{
			int cx = (px >> 2) + cell.Dx;
			int cy = (py >> 2) + cell.Dy;

			if (cx < 0 || cy < 0 || cx >= Width || cy >= Height)
			{
				continue;
			}
			if (_cells[cy * Width + cx] != CellState.Empty)
			{
				return false;
			}
		}

		return true;
	}
}
