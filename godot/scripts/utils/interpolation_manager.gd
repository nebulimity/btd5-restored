extends Node

var _registry: Dictionary = {}

func register(logic_node: Node2D) -> void:
	var visual_container = logic_node.get_node_or_null("Visuals")
	if not visual_container: return
		
	visual_container.set_as_top_level(true)
	
	visual_container.global_position = logic_node.global_position
	visual_container.global_rotation = logic_node.global_rotation
	
	_registry[logic_node] = {
		"visual": visual_container,
		"prev_pos": logic_node.global_position,
		"prev_rot": logic_node.global_rotation
	}

func unregister(logic_node: Node2D) -> void:
	_registry.erase(logic_node)

func save_previous_transforms() -> void:
	var dead_nodes: Array = []
	
	for logic_node in _registry:
		if is_instance_valid(logic_node) and is_instance_valid(_registry[logic_node].visual):
			_registry[logic_node].prev_pos = logic_node.global_position
			_registry[logic_node].prev_rot = logic_node.global_rotation
		else:
			dead_nodes.append(logic_node)
			
	for node in dead_nodes:
		_registry.erase(node)

func interpolate_all(fraction: float) -> void:
	for logic_node in _registry:
		if is_instance_valid(logic_node):
			var data = _registry[logic_node]
			if is_instance_valid(data.visual):
				
				data.visual.global_position = data.prev_pos.lerp(logic_node.global_position, fraction)
				data.visual.global_rotation = lerp_angle(data.prev_rot, logic_node.global_rotation, fraction)
