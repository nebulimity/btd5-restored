class_name TowerBehaviorDef
extends RefCounted

var process_behavior: TowerBehaviorProcess = null

func Process(behavior: TowerBehaviorProcess) -> TowerBehaviorDef:
	process_behavior = behavior
	return self
