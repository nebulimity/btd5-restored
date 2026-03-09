class_name DisplayAddonDef
extends Node

var clip: String = ""
var z: int = 1
var ref: String = ""
var loop: bool = true
var offset: Vector2 = Vector2.ZERO

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
