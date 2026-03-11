class_name CollisionGrid
extends Node

const CELL_SIZE: int = 40
const GRID_OFFSET: int = -60
const VISIBILITY_RADIUS_SPECIAL: int = 52

var _visible_bloon_set: Dictionary = {}
var _camo_bloon_set: Dictionary = {}

var rows: int = 0
var columns: int = 0

var cells: Array[Array] = []
var adjacency_data: Array[Array] = []

var _u: Vector2 = Vector2.ZERO
var _v: Vector2 = Vector2.ZERO
var _c: Vector2 = Vector2.ZERO
var _test_position: Vector2 = Vector2.ZERO

var _candidate_cells_scratch: Array = []

var level: Level

func _init(_level: Level = null) -> void:
	level = _level
	
	while CELL_SIZE * columns < 700 - (GRID_OFFSET + GRID_OFFSET):
		columns += 1
	while CELL_SIZE * rows < 520 - (GRID_OFFSET + GRID_OFFSET):
		rows += 1
	
	cells.resize(columns * rows)
	for i in range(cells.size()):
		cells[i] = []
	
	adjacency_data.resize(columns * rows)
	
	for r in range(rows):
		for c in range(columns):
			var neighbors: Array = []
			
			var r_prev = r - 1
			var r_next = r + 1
			var c_prev = c - 1
			var c_next = c + 1
			
			var has_prev_row = r_prev >= 0
			var has_next_row = r_next < rows
			var has_prev_col = c_prev >= 0
			var has_next_col = c_next < columns
			
			if has_prev_row:
				if has_prev_col: neighbors.append(cells[c_prev + r_prev * columns])
				neighbors.append(cells[c + r_prev * columns])
				if has_next_col: neighbors.append(cells[c_next + r_prev * columns])
			
			if has_prev_col: neighbors.append(cells[c_prev + r * columns])
			neighbors.append(cells[c + r * columns])
			if has_next_col: neighbors.append(cells[c_next + r * columns])
			
			if has_next_row:
				if has_prev_col: neighbors.append(cells[c_prev + r_next * columns])
				neighbors.append(cells[c + r_next * columns])
				if has_next_col: neighbors.append(cells[c_next + r_next * columns])
			
			adjacency_data[c + r * columns] = neighbors

func get_cell_index(x: float, y: float) -> int:
	var col: int = int(floor((x - GRID_OFFSET) / CELL_SIZE))
	var row: int = int(floor((y - GRID_OFFSET) / CELL_SIZE))
	if col < 0 or col >= columns or row < 0 or row >= rows:
		return -1
	return row * columns + col

func get_cell_and_adjacent_cells(x: float, y: float) -> Array:
	var idx = get_cell_index(x, y)
	if idx != -1:
		return adjacency_data[idx]
	return []

func clear() -> void:
	for cell in cells:
		cell.clear()

func add_to_cell(bloon: Bloon, index: int) -> void:
	if index == -1:
		return
	
	if bloon.bloon_type < Bloon.BloonType.MOAB:
		cells[index].append(bloon)
	else:
		for cell_list in adjacency_data[index]:
			cell_list.append(bloon)

func remove_from_cell(bloon: Bloon, index: int) -> void:
	if index == -1:
		return
	if bloon.bloon_type < Bloon.BloonType.MOAB:
		cells[index].erase(bloon)
	else:
		for cell_list in adjacency_data[index]:
			cell_list.erase(bloon)

func switch_cells(bloon: Bloon, old_index: int, new_index: int) -> void:
	if old_index != -1:
		remove_from_cell(bloon, old_index)
	if new_index != -1:
		add_to_cell(bloon, new_index)

func get_cells_in_range(x: float, y: float, radius: float) -> Array:
	if radius > 999:
		return cells.duplicate()
	
	var results: Array = []
	
	var min_row = maxi(int((y - radius - GRID_OFFSET) / CELL_SIZE), 0)
	var max_row = mini(int((y + radius - GRID_OFFSET) / CELL_SIZE), rows - 1)
	var min_col = maxi(int((x - radius - GRID_OFFSET) / CELL_SIZE), 0)
	var max_col = mini(int((x + radius - GRID_OFFSET) / CELL_SIZE), columns - 1)
	
	for col in range(min_col, max_col + 1):
		for row in range(min_row, max_row + 1):
			var cell_x: float = col * CELL_SIZE + GRID_OFFSET
			var cell_y: float = row * CELL_SIZE + GRID_OFFSET
			
			if (x - radius < cell_x and x + radius > cell_x + CELL_SIZE and
				y - radius < cell_y and y + radius > cell_y + CELL_SIZE):
				results.append(cells[col + row * columns])
			elif _circle_intersects_rect(x, y, radius, cell_x, cell_y, CELL_SIZE, CELL_SIZE):
				results.append(cells[col + row * columns])
	
	return results

func register_tower(tower: Tower) -> void:
	if tower == null or tower.tower_def == null:
		return
	tower.collision_test_cells = get_cells_in_range(tower.global_position.x, tower.global_position.y, tower.tower_def.range_of_visibility)

func deregister_tower(tower: Tower) -> void:
	tower.collision_test_cells.clear()

func process(delta: float) -> void:
	_update_bloon_detection()
	_process_projectile_collisions(delta)

func _update_bloon_detection() -> void:
	if not level:
		return
	
	_visible_bloon_set.clear()
	_camo_bloon_set.clear()
	
	for tower: Tower in level.placed_towers:
		if not is_instance_valid(tower) or tower.tower_def == null:
			continue
		
		var range_val: float = tower.tower_def.range_of_visibility
		
		if _is_special_range_tower(tower):
			if _has_proportional_range_upgrade(tower):
				range_val = VISIBILITY_RADIUS_SPECIAL * (tower.tower_def.range_of_visibility / tower.base_def.range_of_visibility)
			else:
				range_val = VISIBILITY_RADIUS_SPECIAL
		
		var bloons_in_range: Array = level.get_bloons_in_range(tower.global_position.x, tower.global_position.y, range_val)
		
		for bloon: Bloon in bloons_in_range:
			bloon.is_in_general_vision = true
			_visible_bloon_set[bloon] = true
			
			if (Bloon.BloonImmunity.IMMUNITY_NO_DETECTION & tower.target_mask) == 0:
				bloon.is_in_camo_vision = true
				_camo_bloon_set[bloon] = true
	
	for bloon: Bloon in level.bloons:
		if not is_instance_valid(bloon):
			continue
		if not _visible_bloon_set.has(bloon):
			bloon.is_in_general_vision = false
		if not _camo_bloon_set.has(bloon):
			bloon.is_in_camo_vision = false

func update_tower_targets(tower: Tower) -> void:
	if tower.tower_def != null and tower.tower_def.shared_camo_vision:
		_update_camo_tower_targets(tower)
	else:
		_update_standard_tower_targets(tower)

func _update_standard_tower_targets(tower: Tower) -> void:
	tower.targets_by_priority.clear()
	if not level or level.active_bloons == 0:
		return
	
	var pos = tower.global_position
	_u.x = pos.x
	_u.y = pos.y
	
	for cell_list in tower.collision_test_cells:
		if cell_list.size() > 0:
			get_targets(_u, tower.tower_def.range_of_visibility, tower.target_mask, tower.targets_by_priority, cell_list)
	
	sort_targets_by_priority(tower.target_priority, tower.targets_by_priority, _u)

func _update_camo_tower_targets(tower: Tower) -> void:
	if not level or level.active_bloons == 0:
		return
	
	var scratch_targets: Array = []
	var pos_vec: Vector2 = Vector2.ZERO
	tower.targets_by_priority.clear()
	
	for other: Tower in level.placed_towers:
		pos_vec.x = other.global_position.x
		pos_vec.y = other.global_position.y
		
		var eff_mask: int = tower.target_mask
		if (Bloon.BloonImmunity.IMMUNITY_NO_DETECTION & other.target_mask) == 0 or (Bloon.BloonImmunity.IMMUNITY_NO_DETECTION & tower.target_mask) == 0:
			eff_mask &= ~Bloon.BloonImmunity.IMMUNITY_NO_DETECTION
		
		if _is_normal_attack_tower(other):
			for cell_list in other.collision_test_cells:
				if cell_list.size() > 0:
					get_targets(pos_vec, other.tower_def.range_of_visibility, eff_mask, scratch_targets, cell_list)
		elif _is_special_range_tower(other):
			var distant = get_bloons_sorted(pos_vec, VISIBILITY_RADIUS_SPECIAL, eff_mask, other.target_priority)
			for b in distant:
				scratch_targets.append(b)
	
	_u.x = tower.global_position.x
	_u.y = tower.global_position.y
	sort_targets_by_priority(tower.target_priority, scratch_targets, _u)
	for b in scratch_targets:
		tower.targets_by_priority.append(b)

func get_targets(pos: Vector2, range_val: float, mask: int, result_list: Array, cell_list: Array) -> void:
	for bloon: Bloon in cell_list:
		if (mask & bloon.immunity) != 0:
			continue
		if bloon.bloon_type == -1:
			continue
		if bloon.is_in_tunnel():
			continue
		if range_val >= 1200:
			result_list.append(bloon)
		else:
			var dx: float = pos.x - bloon.global_position.x
			var dy: float = pos.y - bloon.global_position.y
			var eff: float = range_val + bloon.target_addon
			if dx * dx + dy * dy <= eff * eff:
				result_list.append(bloon)

func get_bloons_sorted(pos: Vector2, radius: float, mask: int, priority: int, exclude: Array = []) -> Array:
	var result: Array = []
	for cell_list in get_cells_in_range(pos.x, pos.y, radius):
		for bloon: Bloon in cell_list:
			if bloon.bloon_type == -1:
				continue
			if (mask & bloon.immunity) != 0:
				continue
			if bloon.is_in_tunnel():
				continue
			if exclude.size() > 0 and bloon in exclude:
				continue
			result.append(bloon)
	_v.x = pos.x
	_v.y = pos.y
	sort_targets_by_priority(priority, result, _v)
	return result

func sort_first_to_last(a: Bloon, b: Bloon) -> bool:
	return a.get_distance_to_end() > b.get_distance_to_end()

func sort_last_to_first(a: Bloon, b: Bloon) -> bool:
	return a.get_distance_to_start() > b.get_distance_to_start()

func _sort_by_closeness(a: Bloon, b: Bloon) -> bool:
	var ax = _test_position.x - a.global_position.x
	var ay = _test_position.y - a.global_position.y
	var bx = _test_position.x - b.global_position.x
	var by = _test_position.y - b.global_position.y
	
	return (ax * ax + ay * ay) > (bx * bx + by * by)

func _sort_by_strength(a: Bloon, b: Bloon) -> bool:
	if a.bloon_type != b.bloon_type:
		return a.bloon_type < b.bloon_type
	if a.health != b.health:
		return a.health < b.health
	return a.overall_progress < b.overall_progress

func sort_targets_by_priority(priority_type: int, targets: Array, tower_pos: Vector2) -> void:
	match priority_type:
		Tower.TARGET_FIRST:
			targets.sort_custom(sort_first_to_last)
		Tower.TARGET_LAST:
			targets.sort_custom(sort_last_to_first)
		Tower.TARGET_CLOSE:
			_test_position = tower_pos
			targets.sort_custom(_sort_by_closeness)
		Tower.TARGET_STRONG:
			targets.sort_custom(_sort_by_strength)

func _process_projectile_collisions(delta: float) -> void:
	if not level:
		return
	
	for proj: Projectile in level.projectiles:
		if not is_instance_valid(proj):
			continue
		if proj.pierce <= 0 or proj.def == null:
			continue
		if proj.effect_mask == Bloon.BloonImmunity.IMMUNITY_ALL:
			continue
		
		var radius: float = proj.radius
		var speed: float = proj.velocity.length()
		
		var candidate_cells: Array
		if proj.is_stationary:
			if proj.cached_cells == null:
				proj.cached_cells = get_cells_in_range(proj.global_position.x, proj.global_position.y, radius)
			candidate_cells = proj.cached_cells
		elif radius < 11:
			if level.current_round > 69:
				_candidate_cells_scratch.clear()
				var idx_cur = get_cell_index(proj.global_position.x, proj.global_position.y)
				if idx_cur != -1:
					_candidate_cells_scratch.append(cells[idx_cur])
				var idx_next = get_cell_index(
					proj.global_position.x + proj.velocity.x,
					proj.global_position.y + proj.velocity.y)
				if idx_next != -1 and idx_next != idx_cur:
					_candidate_cells_scratch.append(cells[idx_next])
				candidate_cells = _candidate_cells_scratch
			else:
				candidate_cells = get_cell_and_adjacent_cells(proj.global_position.x, proj.global_position.y)
		else:
			candidate_cells = get_cells_in_range(proj.global_position.x, proj.global_position.y, radius)

		var broke_outer = false
		for cell_list in candidate_cells:
			for bloon: Bloon in cell_list:
				if bloon.bloon_type == -1:
					continue
				
				if bloon.is_camo:
					if proj.owner_tower != null and proj.owner_tower.tower_def != null:
						if not (bloon.is_in_camo_vision and proj.owner_tower.tower_def.can_detect_camo):
							if (proj.effect_mask & bloon.immunity) != 0:
								continue
				elif (proj.effect_mask & bloon.immunity) != 0:
					continue
				
				if bloon.is_in_tunnel():
					continue
				if bloon.hit_previously(proj):
					continue
				
				if proj.locked_target != null and proj.locked_target.bloon_type != -1 and proj.locked_target != bloon:
					continue
				
				_u.x = proj.global_position.x
				_u.y = proj.global_position.y
				_v.x = proj.velocity.x * delta
				_v.y = proj.velocity.y * delta
				_c.x = bloon.global_position.x
				_c.y = bloon.global_position.y
				
				if _test_circle_circle(_u, radius + speed, _c, bloon.radius):
					if _test_circle_circle(_u, radius, _c, bloon.radius) or _test_circle_line(_u, _v, _c, bloon.radius + radius):
						bloon.handle_collision(proj)
						proj.handle_collision()
						if proj.pierce <= 0 or proj.def == null:
							break
			
			if not is_instance_valid(proj) or proj.pierce <= 0 or proj.def == null:
				broke_outer = true
				break

func _circle_intersects_rect(cx: float, cy: float, cr: float,
		rx: float, ry: float, rw: float, rh: float) -> bool:
	var tx: float = clampf(cx, rx, rx + rw)
	var ty: float = clampf(cy, ry, ry + rh)
	var dx: float = cx - tx
	var dy: float = cy - ty
	return dx * dx + dy * dy <= cr * cr

func _test_circle_circle(p1: Vector2, r1: float, p2: Vector2, r2: float) -> bool:
	var dx = p1.x - p2.x
	var dy = p1.y - p2.y
	var rs = r1 + r2
	return dx * dx + dy * dy < rs * rs

func _test_circle_line(pu: Vector2, pv: Vector2, pc: Vector2, r: float) -> bool:
	var len_sq = pv.length_squared()
	if len_sq == 0.0:
		return false
	var t: float = ((pc.x - pu.x) * pv.x + (pc.y - pu.y) * pv.y) / len_sq
	t = clampf(t, 0.0, 1.0)
	var dx: float = pc.x - (pu.x + t * pv.x)
	var dy: float = pc.y - (pu.y + t * pv.y)
	return dx * dx + dy * dy < r * r

func _is_normal_attack_tower(tower: Tower) -> bool:
	var id: String = tower.root_id
	return id != "BananaFarm" and id != "BloonberryBush" and id != "BloonberryBushPro" and id != "PortableLake" and id != "PortableLakePro" and id != "Pontoon" and id != "PontoonPro" and id != "BloonsdayDevice" and id != "BloonsdayDevicePro" and id != "DartlingGun" and id != "SniperMonkey" and id != "MortarTower" and id != "MonkeyAce" and tower.tower_def.id != "AircraftCarrier"

func _is_special_range_tower(tower: Tower) -> bool:
	var id: String = tower.root_id
	return id == "DartlingGun" or id == "SniperMonkey" or id == "MortarTower" or id == "MonkeyAce" or tower.tower_def.id == "AircraftCarrier"

func _has_proportional_range_upgrade(tower: Tower) -> bool:
	var id: String = tower.root_id
	return id != "DartlingGun" and id != "MortarTower" and id != "SniperMonkey" and id != "Meerkat" and id != "MeerkatPro" and tower.tower_def.id != "Spectre"
