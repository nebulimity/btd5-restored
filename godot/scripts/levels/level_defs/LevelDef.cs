using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

public enum Difficulty
{
	Beginner = 1,
	Intermediate = 2,
	Advanced = 3,
	Expert = 4,
	Extreme = 5
}

public class LevelDef
{
	public Difficulty Difficulty { get; set; }

	public string Id { get; set; }
	public string Name { get; set; }
	public string Scene { get; set; }
	public string Terrain { get; set; }
	public string Music { get; set; }

	public List<List<TileDef>> TileSets { get; set; }

	private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
	{
		PropertyNameCaseInsensitive = true,
		Converters = { new JsonStringEnumConverter() },
	};

	public static LevelDef Load(string id)
	{
		string json = Godot.FileAccess.GetFileAsString($"res://data/levels/{id}.json");
		return JsonSerializer.Deserialize<LevelDef>(json, JsonOptions);
	}
}
