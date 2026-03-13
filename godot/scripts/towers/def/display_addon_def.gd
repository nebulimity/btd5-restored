class_name DisplayAddonDef
extends RefCounted

var clip: String = ""
var z: int = 1
var ref: String = ""
var loop: bool = true
var offset: Vector2 = Vector2.ZERO
var centered: bool = false

func Clip(value: String) -> DisplayAddonDef:
	clip = value
	return self

func Z(value: int) -> DisplayAddonDef:
	z = value
	return self

func Ref(value: String) -> DisplayAddonDef:
	ref = value
	return self

func Loop(value: bool) -> DisplayAddonDef:
	loop = value
	return self

func Offset(value: Vector2) -> DisplayAddonDef:
	offset = value
	return self

func Centered(value: bool) -> DisplayAddonDef:
	centered = value
	return self
