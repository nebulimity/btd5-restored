using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

public class RoundsDef
{
	public List<RoundDef> Rounds { get; set; }

	private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
	{
		PropertyNameCaseInsensitive = true,
		Converters = { new JsonStringEnumConverter() },
	};

	public static RoundsDef Load(string version)
	{
		string json = Godot.FileAccess.GetFileAsString($"res://data/rounds/{version}.json");
		return JsonSerializer.Deserialize<RoundsDef>(json, JsonOptions);
	}
}
