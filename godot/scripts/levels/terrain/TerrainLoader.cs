using System.Collections.Generic;
using System.Text.Json;
using Godot;

public static class TerrainLoader
{
	public static TerrainSet LoadTerrainSet(LevelDef def)
	{
		return new TerrainSet(LoadAlpha($"{def.Terrain}/track.png", out _), LoadAlpha($"{def.Terrain}/dead_zone.png", out _), LoadAlpha($"{def.Terrain}/water.png", out _));
	}

	private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
	{
		PropertyNameCaseInsensitive = true,
	};

	public static Dictionary<string, Footprint> LoadFootprints()
	{
		string json = FileAccess.GetFileAsString("res://data/terrain/footprints.json");
		FootprintsFile file = JsonSerializer.Deserialize<FootprintsFile>(json, JsonOptions);
		Dictionary<string, Footprint> footprints = new();

		foreach ((string name, FootprintDef def) in file.Footprints)
		{
			byte[] sheet = LoadAlpha($"res://data/terrain/footprints/{name}.png", out int sheetWidth);
			byte[] exceptions = null;
			int exceptionsWidth = 0;

			if (def.Exceptions.Count > 0)
			{
				exceptions = LoadAlpha($"res://data/terrain/footprints/{name}_exceptions.png", out exceptionsWidth);
			}

			footprints.Add(name, new Footprint(def, sheet, sheetWidth, exceptions, exceptionsWidth));
		}

		return footprints;
	}

	private static byte[] LoadAlpha(string path, out int width)
	{
		if (!ResourceLoader.Exists(path))
		{
			width = 0;
			return null;
		}

		Image image = GD.Load<Image>(path);
		width = image.GetWidth();

		image.Convert(Image.Format.Rgba8);
		byte[] rgba = image.GetData();
		byte[] alpha = new byte[rgba.Length / 4];

		for (int i = 0; i < alpha.Length; i++)
		{
			alpha[i] = rgba[i * 4 + 3];
		}

		return alpha;
	}
}
