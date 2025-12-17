class_name CollisionGrid
extends Node

const CELL_SIZE: int = 40
const GRID_OFFSET: int = -60 

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
	var c: int = floor((x - GRID_OFFSET) / CELL_SIZE)
	var r: int = floor((y - GRID_OFFSET) / CELL_SIZE)
	
	if c < 0 or c >= columns or r < 0 or r >= rows:
		return -1
		
	return r * columns + c

func add_to_cell(bloon: Node2D, index: int) -> void:
	if index == -1: return
	
	if bloon.bloon_type < bloon.BloonType.MOAB:
		cells[index].append(bloon)
		bloon.set_meta("is_moab", false) 
	else:
		var neighbor_lists = adjacency_data[index]
		for cell_list in neighbor_lists:
			cell_list.append(bloon)
		bloon.set_meta("is_moab", true)

func remove_from_cell(bloon: Node2D, index: int) -> void:
	if index == -1: return
	
	if not bloon.get_meta("is_moab", false):
		var list = cells[index]
		list.erase(bloon)
	else:
		var neighbor_lists = adjacency_data[index]
		for cell_list in neighbor_lists:
			cell_list.erase(bloon)

func switch_cells(bloon: Node2D, old_index: int, new_index: int) -> void:
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
	pass # Not implemented

func get_cell_and_adjacent_cells(x: float, y: float) -> Array:
	var idx = get_cell_index(x, y)
	if idx != -1:
		return adjacency_data[idx]
	return []

func test_circle_circle(p1: Vector2, r1: float, p2: Vector2, r2: float) -> bool:
	var dist_sq = p1.distance_squared_to(p2)
	var radius_sum = r1 + r2
	return dist_sq < (radius_sum * radius_sum)

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
		
		# if proj.effect_mask == Bloon.IMMUNITY_ALL: continue
		
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
					var tower_sees_camo = false
					if proj.owner_tower and proj.owner_tower.tower_def:
						if proj.owner_tower.tower_def.get("camo_detection"): 
							tower_sees_camo = true
					
					if not tower_sees_camo:
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
					
					if test_circle_circle(self.u, radius, self.c, bloon.radius) or \
					   test_circle_line(self.u, self.v, self.c, bloon.radius + radius):
						
						bloon.handle_collision(proj)
						proj.handle_collision()
						
						proj.hit_bloons.append(bloon.id)
						
						if proj.pierce <= 0 or proj.def == null:
							proj.queue_free() 
							break
			
			if not is_instance_valid(proj) or proj.pierce <= 0:
				break
