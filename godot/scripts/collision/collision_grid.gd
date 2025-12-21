class_name CollisionGrid
extends Node

const CELL_SIZE: int = 40
const GRID_OFFSET: int = -60
const VISIBILITY_RADIUS_SPECIAL: int = 52

var visible_bloon_buffer: Array[Bloon] = []
var camo_bloon_buffer: Array[Bloon] = []

var rows: int = 0
var columns: int = 0

var cells: Array[Array] = []

var adjacency_data: Array[Array] = []

var u: Vector2 = Vector2.ZERO
var v: Vector2 = Vector2.ZERO
var c: Vector2 = Vector2.ZERO
var test_position: Vector2 = Vector2.ZERO

var level: Level

func _init(_level: Level = null) -> void:
	level = _level
	
	rows = 0
	columns = 0
	
	while CELL_SIZE * columns < 700 - (GRID_OFFSET + GRID_OFFSET):
		columns += 1
		
	while CELL_SIZE * rows < 520 - (GRID_OFFSET + GRID_OFFSET):
		rows += 1
		
	cells.resize(columns * rows)
	for i in range(cells.size()):
		cells[i] = []
		
	adjacency_data.resize(columns * rows)
	
	for r in range(rows):
		@warning_ignore("shadowed_variable")
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
	@warning_ignore("shadowed_variable")
	var c: int = floor((x - GRID_OFFSET) / CELL_SIZE)
	var r: int = floor((y - GRID_OFFSET) / CELL_SIZE)
	
	if c < 0 or c >= columns or r < 0 or r >= rows:
		return -1
		
	return r * columns + c

func add_to_cell(bloon: Bloon, index: int) -> void:
	if index == -1: return
	
	if bloon.bloon_type < bloon.BloonType.MOAB:
		cells[index].append(bloon)
		bloon.set_meta("is_moab", false) 
	else:
		var neighbor_lists = adjacency_data[index]
		for cell_list in neighbor_lists:
			cell_list.append(bloon)
		bloon.set_meta("is_moab", true)

func remove_from_cell(bloon: Bloon, index: int) -> void:
	if index == -1: return
	
	if not bloon.get_meta("is_moab", false):
		var list = cells[index]
		list.erase(bloon)
	else:
		var neighbor_lists = adjacency_data[index]
		for cell_list in neighbor_lists:
			cell_list.erase(bloon)

func switch_cells(bloon: Bloon, old_index: int, new_index: int) -> void:
	if old_index != -1:
		remove_from_cell(bloon, old_index)
	if new_index != -1:
		add_to_cell(bloon, new_index)

func get_bloons_in_range(pos: Vector2, radius: float) -> Array:
	var candidates: Array = []
	var cell_buckets = get_cells_in_range_raw(pos.x, pos.y, radius)
	
	for bucket in cell_buckets:
		for bloon in bucket:
			candidates.append(bloon)
			
	return candidates

func get_cells_in_range_raw(x: float, y: float, radius: float) -> Array:
	if radius > 999:
		return cells.duplicate()
		
	var results: Array = []
	
	var min_row = max(int((y - radius - GRID_OFFSET) / CELL_SIZE), 0)
	var max_row = min(int((y + radius - GRID_OFFSET) / CELL_SIZE), rows - 1)
	var min_col = max(int((x - radius - GRID_OFFSET) / CELL_SIZE), 0)
	var max_col = min(int((x + radius - GRID_OFFSET) / CELL_SIZE), columns - 1)
	
	@warning_ignore("shadowed_variable")
	for c in range(min_col, max_col + 1):
		for r in range(min_row, max_row + 1):
			var cell_x = c * CELL_SIZE + GRID_OFFSET
			var cell_y = r * CELL_SIZE + GRID_OFFSET
			
			if (x - radius < cell_x and x + radius > cell_x + CELL_SIZE and 
				y - radius < cell_y and y + radius > cell_y + CELL_SIZE):
				results.append(cells[c + r * columns])
				
			elif intersection_circle_rect(x, y, radius, cell_x, cell_y, CELL_SIZE, CELL_SIZE):
				results.append(cells[c + r * columns])
				
	return results

func intersection_circle_rect(cx: float, cy: float, cr: float, rx: float, ry: float, rw: float, rh: float) -> bool:
	var test_x = cx
	var test_y = cy
	
	if cx < rx: test_x = rx
	elif cx > rx + rw: test_x = rx + rw
		
	if cy < ry: test_y = ry
	elif cy > ry + rh: test_y = ry + rh
	
	var dist_x = cx - test_x
	var dist_y = cy - test_y
	var distance = sqrt((dist_x * dist_x) + (dist_y * dist_y))
	
	return distance <= cr

func process(delta: float) -> void:
	update_bloon_detection()
	process_projectile_collisions(delta)

func update_bloon_detection() -> void:
	if not level: return
	
	var towers = level.placed_towers
	var bloons_in_range: Array
	var range_val: float
	
	visible_bloon_buffer.clear()
	camo_bloon_buffer.clear()
	
	for tower in towers:
		if not is_instance_valid(tower): continue
		
		range_val = tower.tower_def.range_of_visibility
		
		if is_special_visibility_tower(tower):
			if has_visibility_upgrade(tower):
				range_val = VISIBILITY_RADIUS_SPECIAL * (tower.tower_def.range_of_visibility / tower.tower_def.get("base_range", tower.tower_def.range_of_visibility))
			else:
				range_val = VISIBILITY_RADIUS_SPECIAL
		
		bloons_in_range = get_bloons_in_range(tower.global_position, range_val)
		
		for bloon in bloons_in_range:
			bloon.is_in_general_vision = true
			visible_bloon_buffer.append(bloon)
			
			var can_see_camo = false
			if (Bloon.BloonImmunity.IMMUNITY_NO_DETECTION & tower.target_mask) == 0:
				can_see_camo = true
			
			if can_see_camo:
				bloon.is_in_camo_vision = true
				camo_bloon_buffer.append(bloon)
	
	for bloon in level.bloons:
		if not is_instance_valid(bloon): continue
		
		if not (bloon in visible_bloon_buffer):
			bloon.is_in_general_vision = false
			
		if not (bloon in camo_bloon_buffer):
			bloon.is_in_camo_vision = false

func is_special_visibility_tower(tower: Tower) -> bool:
	var id = tower.tower_type
	return id == "SniperMonkey" or id == "MortarTower" or id == "DartlingGun"

func has_visibility_upgrade(_tower: Tower) -> bool:
	return false # not implemented

func get_cell_and_adjacent_cells(x: float, y: float) -> Array:
	var idx = get_cell_index(x, y)
	if idx != -1:
		return adjacency_data[idx]
	return []

func test_circle_circle(p1: Vector2, r1: float, p2: Vector2, r2: float) -> bool:
	var dist_sq = p1.distance_squared_to(p2)
	var radius_sum = r1 + r2
	return dist_sq < (radius_sum * radius_sum)

@warning_ignore("shadowed_variable")
func test_circle_line(u: Vector2, v: Vector2, c: Vector2, r: float) -> bool:
	var v_len_sq = v.length_squared()
	if v_len_sq == 0:
		return false
		
	var t = ((c.x - u.x) * v.x + (c.y - u.y) * v.y) / v_len_sq
	
	if t < 0: t = 0
	if t > 1: t = 1
	
	var closest_x = u.x + t * v.x
	var closest_y = u.y + t * v.y
	
	var dist_x = c.x - closest_x
	var dist_y = c.y - closest_y
	
	return (dist_x * dist_x + dist_y * dist_y) < (r * r)

func populate_tower_targets(tower: Tower) -> void:
	tower.targets_by_priority.clear()
	
	if not level or level.active_bloons == 0:
		return
	
	var range_val = tower.current_range
	var pos = tower.global_position
	
	var min_col = max(int((pos.x - range_val - GRID_OFFSET) / CELL_SIZE), 0)
	var max_col = min(int((pos.x + range_val - GRID_OFFSET) / CELL_SIZE), columns - 1)
	var min_row = max(int((pos.y - range_val - GRID_OFFSET) / CELL_SIZE), 0)
	var max_row = min(int((pos.y + range_val - GRID_OFFSET) / CELL_SIZE), rows - 1)
	
	@warning_ignore("shadowed_variable")
	for c in range(min_col, max_col + 1):
		for r in range(min_row, max_row + 1):
			var cell_list = cells[c + r * columns]
			if cell_list.size() > 0:
				get_targets(pos, range_val, tower.target_mask, tower.targets_by_priority, cell_list)
	
	if tower.targets_by_priority.size() > 1:
		level.collision_grid.sort_targets_by_priority(tower.target_priority, tower.targets_by_priority, tower.global_position)

func get_targets(pos: Vector2, range_val: float, mask: int, result_list: Array, cell_list: Array) -> void:
	var dist_x: float
	var dist_y: float
	var dist_sq: float
	var effective_range: float
	var range_sq: float
	
	for bloon in cell_list:
		if (mask & bloon.immunity) == 0:
			if bloon.bloon_type != -1:
				if not bloon.is_in_tunnel():
					if range_val >= 1200:
						result_list.append(bloon)
					else:
						dist_x = pos.x - bloon.global_position.x
						dist_y = pos.y - bloon.global_position.y
						dist_sq = dist_x * dist_x + dist_y * dist_y
						
						effective_range = range_val + bloon.target_addon
						range_sq = effective_range * effective_range
						
						if dist_sq <= range_sq:
							result_list.append(bloon)

func sort_first_to_last(a: Bloon, b: Bloon) -> bool:
	if a.overall_progress != b.overall_progress:
		return a.overall_progress < b.overall_progress
	return a.id < b.id

func sort_last_to_first(a: Bloon, b: Bloon) -> bool:
	if a.overall_progress != b.overall_progress:
		return a.overall_progress > b.overall_progress
	return a.id < b.id

func sort_by_closeness(a: Bloon, b: Bloon) -> bool:
	var dist_a_x = test_position.x - a.global_position.x
	var dist_a_y = test_position.y - a.global_position.y
	var dist_sq_a = dist_a_x * dist_a_x + dist_a_y * dist_a_y
	
	var dist_b_x = test_position.x - b.global_position.x
	var dist_b_y = test_position.y - b.global_position.y
	var dist_sq_b = dist_b_x * dist_b_x + dist_b_y * dist_b_y
	
	return dist_sq_a > dist_sq_b

func sort_by_strength(a: Bloon, b: Bloon) -> bool:
	if a.bloon_type != b.bloon_type:
		return a.bloon_type < b.bloon_type
		
	if a.health != b.health:
		return a.health < b.health
		
	if a.overall_progress != b.overall_progress:
		return a.overall_progress < b.overall_progress
		
	return false

func sort_targets_by_priority(priority_type: String, targets: Array, tower_pos: Vector2) -> void:
	match priority_type:
		"first":
			targets.sort_custom(sort_first_to_last)
		"last":
			targets.sort_custom(sort_last_to_first)
		"close":
			test_position = tower_pos
			targets.sort_custom(sort_by_closeness)
		"strong":
			targets.sort_custom(sort_by_strength)

func process_projectile_collisions(delta: float) -> void:
	var candidate_cells: Array
	var radius: float
	var speed: float
	var cell_idx_current: int
	var cell_idx_next: int
	
	if not level: return
	
	for proj: Projectile in level.projectiles:
		if not is_instance_valid(proj) or proj.pierce <= 0:
			continue
		
		if proj.effect_mask == Bloon.BloonImmunity.IMMUNITY_ALL: 
			continue
		
		radius = proj.radius
		speed = proj.velocity.length()
		candidate_cells = []
		
		if proj.has_meta("cached_cells"):
			candidate_cells = proj.get_meta("cached_cells")
		elif radius < 11:
			if level.current_round > 69:
				cell_idx_current = get_cell_index(proj.global_position.x, proj.global_position.y)
				if cell_idx_current != -1:
					candidate_cells.append(cells[cell_idx_current])
				
				cell_idx_next = get_cell_index(proj.global_position.x + proj.velocity.x * delta, proj.global_position.y + proj.velocity.y * delta)
				
				if cell_idx_next != -1 and cell_idx_next != cell_idx_current:
					candidate_cells.append(cells[cell_idx_next])
			else:
				candidate_cells = get_cell_and_adjacent_cells(proj.global_position.x, proj.global_position.y)
		
		else:
			candidate_cells = get_cells_in_range_raw(proj.global_position.x, proj.global_position.y, radius)
		
		for cell_list in candidate_cells:
			for bloon: Bloon in cell_list:
				if not is_instance_valid(bloon) or bloon.bloon_type == -1:
					continue
				
				if bloon.is_camo:
					if proj.owner_tower and proj.owner_tower.tower_def:
						if (proj.effect_mask & bloon.immunity) != 0:
							continue
				elif int(proj.effect_mask & bloon.immunity) != 0:
					continue
				
				if bloon.is_in_tunnel():
					continue
					
				if bloon.hit_previously(proj): 
					continue
				
				self.u.x = proj.global_position.x
				self.u.y = proj.global_position.y
				
				self.v.x = proj.velocity.x * delta
				self.v.y = proj.velocity.y * delta
				
				self.c.x = bloon.global_position.x
				self.c.y = bloon.global_position.y
				
				if test_circle_circle(self.u, radius + speed * delta, self.c, bloon.radius):
					if test_circle_circle(self.u, radius, self.c, bloon.radius) or test_circle_line(self.u, self.v, self.c, bloon.radius + radius):
						
						bloon.handle_collision(proj)
						proj.handle_collision()
						
						proj.hit_bloons.append(bloon.id)
						
						if proj.pierce <= 0 or proj.def == null:
							break
			
			if not is_instance_valid(proj) or proj.pierce <= 0:
				break
