class_name TowerDef
extends RefCounted

var id: String = ""
var display: String = ""
var display_addons: Array[DisplayAddonDef] = []
var label: String = ""
var description: String = ""
var occupied_space: float = 0.0
var range_of_visibility: float = 0.0
var rotates: bool = true
var weapons: Array[Weapon] = []
var weapon_offsets: Array[Vector2] = []
var target_mask: Array[int] = []
var behavior: TowerBehaviorDef = null
var position_offset: Vector2 = Vector2.ZERO
var rotation_offset: float = -90.0
var idle_frame: int = -1
var fire_frame: int = -1

var cost: int = 0                     # temp
var can_place_on_water: bool = false  # temp
var can_place_on_track: bool = false  # temp
var requires_track: bool = false      # temp
var requires_water: bool = false      # temp

func _init(tower_name: String) -> void:
	id = tower_name
	target_mask.resize(Bloon.BloonImmunity.size())
	target_mask.fill(Bloon.BloonImmunity.IMMUNITY_NO_DETECTION)

func Display(value: String) -> TowerDef:
	display = value
	return self

func DisplayAddons(value: Array[DisplayAddonDef]) -> TowerDef:
	display_addons = value
	return self

func Label(value: String) -> TowerDef:
	label = value
	return self

func Description(value: String) -> TowerDef:
	description = value
	return self

func OccupiedSpace(value: float) -> TowerDef:
	occupied_space = value
	return self

func RangeOfVisibility(value: float) -> TowerDef:
	range_of_visibility = value
	return self

func TargetMask(value: Array[int]) -> TowerDef:
	target_mask = value
	return self

func Rotates(value: bool) -> TowerDef:
	rotates = value
	return self

func Weapons(value: Array[Weapon]) -> TowerDef:
	weapons = value
	return self

func Behavior(value: TowerBehaviorDef) -> TowerDef:
	behavior = value
	return self

func WeaponOffsets(value: Array[Vector2]) -> TowerDef:
	weapon_offsets = value
	return self

func PositionOffset(value: Vector2) -> TowerDef:
	position_offset = value
	return self

func RotationOffset(value: float) -> TowerDef:
	rotation_offset = value
	return self

func IdleFrame(value: int) -> TowerDef:
	idle_frame = value
	return self

func FireFrame(value: int) -> TowerDef:
	fire_frame = value
	return self

func Cost(value: int) -> TowerDef:
	cost = value
	return self
