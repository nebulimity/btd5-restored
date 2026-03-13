class_name Pool

class Pooled:
	var free: Array = []
	var scene: PackedScene = null
	
	func _init(p_scene: PackedScene) -> void:
		scene = p_scene
	
	func acquire() -> Node:
		if free.size() > 0:
			return free.pop_back()
		return scene.instantiate()
	
	func release(instance: Node) -> void:
		free.push_back(instance)

static var pools: Dictionary = {}

static func get_obj(scene: PackedScene) -> Node:
	var key: String = scene.resource_path
	
	var pooled: Pooled = pools.get(key)
	if pooled == null:
		pooled = Pooled.new(scene)
		pools[key] = pooled
	
	var instance: Node = pooled.acquire()
	
	instance.set_meta("_pool_key", key)
	
	return instance

static func release(instance: Node) -> void:
	if instance == null:
		return
	
	var key: String = instance.get_meta("_pool_key", "")
	
	if key.is_empty() or not pools.has(key):
		instance.queue_free()
		return
	
	if instance.get_parent() != null:
		instance.get_parent().remove_child(instance)
	
	pools[key].release(instance)
