using System.Collections.Generic;

public class Level : Scene
{
	public Tile StartTile;
	public List<Tile> CurrentTileSet;
	public List<List<Tile>> TileSets;

	public int UpdateMultiplier = 1;
	public double RoundTime = 0;

	public void Initialize()
	{

	}

	public void InitializeLevel(LevelDef def)
	{
		TileSets = new List<List<Tile>>();

		foreach (var path in def.TileSets)
		{
			List<Tile> tiles = new List<Tile>();

			foreach (var tileDef in path)
			{
				tiles.Add(Tile.FromDef(tileDef));
			}

			foreach (var tile in tiles)
			{
				tile.Initialize(tiles);
			}

			TileSets.Add(tiles);
		}

		CurrentTileSet = TileSets[0];
		StartTile = CurrentTileSet[0];
	}

	public override void Process(double delta)
	{
		int tick = 0;
		while (tick < UpdateMultiplier)
		{
			RoundTime += delta;

			// process collision grid & bloons

			base.Process(delta);
			tick++;
		}
	}
}