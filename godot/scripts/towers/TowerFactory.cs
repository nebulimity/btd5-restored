using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

public class TowerFactory
{
	public const string RoadSpikes = "RoadSpikes";
	public const string Pineapple = "ExplodingPineapple";
	public const string SuperTemple = "TempleOfTheMonkeyGod";

	private class TowerIndex
	{
		public List<string> Towers { get; set; }
		public List<string> UpgradePaths { get; set; }
	}

	private readonly Dictionary<string, TowerDef> _baseTowers = new();

	private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
	{
		PropertyNameCaseInsensitive = true,
		Converters = { new JsonStringEnumConverter() },
	};

	public static TowerFactory Load()
	{
		string json = Godot.FileAccess.GetFileAsString("res://data/towers/index.json");
		TowerIndex index = JsonSerializer.Deserialize<TowerIndex>(json, JsonOptions);

		TowerFactory factory = new TowerFactory();

		foreach (string name in index.Towers)
		{
			string defJson = Godot.FileAccess.GetFileAsString($"res://data/towers/defs/{name}.json");
			TowerDef def = JsonSerializer.Deserialize<TowerDef>(defJson, JsonOptions);
			factory._baseTowers.Add(def.Id, def);
		}

		return factory;
	}

	public TowerDef GetBaseTower(string id)
	{
		return _baseTowers.TryGetValue(id, out TowerDef def) ? def : null;
	}
}
