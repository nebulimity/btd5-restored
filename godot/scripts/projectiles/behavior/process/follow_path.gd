class_name FollowPath
extends ProjectileBehaviorProcess

static var path_cache: Dictionary = {}

var path_defs: Array[CubicBezierDef] = []

func Path(p_path_defs: Array) -> FollowPath:
	path_defs.clear()
	for def in p_path_defs:
		if def is CubicBezierDef:
			path_defs.append(def)
	return self

func execute(projectile: Projectile, _delta: float) -> void:
	var owner_node = projectile.owner_tower
	if not is_instance_valid(owner_node):
		return

	var owner_id = owner_node.get_instance_id()
	var smooth_path: SmoothPath = path_cache.get(owner_id)
	
	if smooth_path == null:
		var curves: Array[CubicBezier] = []
		for def in path_defs:
			var bezier = CubicBezier.new()
			bezier.initialize(def)
			curves.append(bezier)
		
		smooth_path = SmoothPath.new()
		smooth_path.initialize(curves)
		path_cache[owner_id] = smooth_path
	
	var t = 1.0 - (projectile.lifespan / projectile.max_lifespan)
	t = clampf(t, 0.0, 1.0)
	
	var offset = Vector2(26, 8) # temp
	var rot: float = 0.0
	
	if projectile.get("velocity") is Vector2:
		rot = projectile.velocity.angle()
	else:
		rot = projectile.rotation
		
	var rotated_offset = offset.rotated(rot)
	
	var origin_x = owner_node.global_position.x + rotated_offset.x
	var origin_y = owner_node.global_position.y + rotated_offset.y
	
	var target_pos = smooth_path.get_transformed_value(t, rot, origin_x, origin_y)
	
	projectile.global_position = target_pos
	
	projectile.rotation = t * TAU * 3.0
