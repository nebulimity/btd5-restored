class_name BehaviorDef
extends RefCounted

var process_behavior: BehaviorProcess = null
var lifespan_over_behavior: RefCounted = null # TODO
var collision_behavior: BehaviorCollision = null

func Process(behavior: BehaviorProcess) -> BehaviorDef:
	process_behavior = behavior
	return self

func LifespanOver(behavior: RefCounted) -> BehaviorDef:
	lifespan_over_behavior = behavior
	return self

func Collision(behavior: BehaviorCollision) -> BehaviorDef:
	collision_behavior = behavior
	return self
