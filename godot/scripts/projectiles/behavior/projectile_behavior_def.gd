class_name ProjectileBehaviorDef
extends RefCounted

var process_behavior: ProjectileBehaviorProcess = null
var lifespan_over_behavior: RefCounted = null # TODO
var collision_behavior: BehaviorCollision = null

func Process(behavior: ProjectileBehaviorProcess) -> ProjectileBehaviorDef:
	process_behavior = behavior
	return self

func LifespanOver(behavior: RefCounted) -> ProjectileBehaviorDef:
	lifespan_over_behavior = behavior
	return self

func Collision(behavior: BehaviorCollision) -> ProjectileBehaviorDef:
	collision_behavior = behavior
	return self
