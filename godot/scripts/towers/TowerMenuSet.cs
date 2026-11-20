using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

public class TowerMenuSet
{
	public List<TowerPickerDef> TowersInMenu { get; set; }

	private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
	{
		PropertyNameCaseInsensitive = true,
		Converters = { new JsonStringEnumConverter() },
	};

	public static TowerMenuSet Load(TowerFactory factory)
	{
		string json = Godot.FileAccess.GetFileAsString("res://data/towers/tower_menu.json");

		TowerMenuSet menuSet = JsonSerializer.Deserialize<TowerMenuSet>(json, JsonOptions);
		foreach (var def in menuSet.TowersInMenu)
		{
			def.Tower = factory.GetBaseTower(def.TowerId);
		}

		return menuSet;
	}
}
