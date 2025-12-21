class_name DisplayAddonDef
extends Node

var clip: String = ""
var z: int = 1

func Clip(value: String) -> DisplayAddonDef:
	clip = value
	return self

func Z(value: int) -> DisplayAddonDef:
	z = value
	return self
