extends Node2D

@export var level_size := Vector2(1000, 750)
@export var rooms_size := Vector2(100, 140)
@export var rooms_max := 15
@export var corridor_width := 16
@export var player_scene := preload("res://Player/player.tscn") # Preload the player scene

@onready var tile_map := $Level

var room_data = {}
var room_center = []
var corridor_data = {}
var rooms = []

const TILE_SIZE := 16
const SCALE_FACTOR := 5
const SCALED_TILE_SIZE := TILE_SIZE * SCALE_FACTOR

var is_dead = false
var map_drawn = false

func _ready() -> void:
	if not map_drawn:
		_generate()
		_draw()
		_generate_occluders()
		_spawn_player()
	
func _process(delta: float) -> void:
	update_player_location()

func update_player_location() -> void:
	# Check if player on a tile
	var player_position = $Player.global_position
	var player_tile_position = Vector2i(int(player_position.x / SCALED_TILE_SIZE) + 1, int(player_position.y / SCALED_TILE_SIZE) + 1) # Check ahead
	var tile = tile_map.get_cell_source_id(player_tile_position)
	#if $Player and tile == -1:
		#DongeonGlobal.player_can_move = false


func _generate() -> void:
	room_data.clear()
	corridor_data.clear()
	rooms.clear()
	_generate_data()

func _generate_data() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for r in range(rooms_max):
		var room = _get_random_room(rng)
		if _intersects(rooms, room):
			continue

		_add_room(room)
		if rooms.size() > 1:
			var room_previous: Rect2 = rooms[-2]
			_add_connection(rng, room_previous, room)
		rooms.append(room)
		room_center.append((room.position + room.end) / 2)


func _get_random_room(rng: RandomNumberGenerator) -> Rect2:
	var width = rng.randi_range(rooms_size.x, rooms_size.y)
	var height = rng.randi_range(rooms_size.x, rooms_size.y)
	# Ensure the room's top-left position keeps the room within level_size
	var x = rng.randi_range(0, level_size.x - width)
	var y = rng.randi_range(0, level_size.y - height)
	return Rect2(Vector2(x, y), Vector2(width, height))


func _add_room(room: Rect2) -> void:
	# Use global positions for adding room tiles
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			room_data[Vector2(x, y)] = true

func _add_connection(rng: RandomNumberGenerator, room1: Rect2, room2: Rect2) -> void:
	var room_center1 = (room1.position + room1.end) / 2
	var room_center2 = (room2.position + room2.end) / 2
	if rng.randi_range(0, 1) == 0:
		_add_corridor(room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)
		_add_corridor(room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
	else:
		_add_corridor(room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		_add_corridor(room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)

func _add_corridor(start: int, end: int, constant: int, axis: int) -> void:
	for t in range(min(start, end), max(start, end) + 1):
		for offset in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			var point = Vector2.ZERO
			match axis:
				Vector2.AXIS_X: point = Vector2(t, constant + offset)
				Vector2.AXIS_Y: point = Vector2(constant + offset, t)
			if point not in room_data:
				corridor_data[point] = true

func _intersects(rooms: Array, room: Rect2) -> bool:
	for room_other in rooms:
		if room.intersects(room_other):
			return true
	return false

func _generate_occluders() -> void:
	# Clear any existing occluders and collision bodies
	for child in get_children():
		if child is LightOccluder2D:
			child.queue_free()
		elif child is StaticBody2D:
			child.queue_free()

	# Check all tiles and add occluders where there are walls but not on corridors
	for x in range(0, level_size.x):
		for y in range(0, level_size.y):
			var tile = tile_map.get_cell_source_id(Vector2i(x, y))

			# Skip if no tile exists or if it's part of a corridor
			if tile == -1 or corridor_data.has(Vector2(x, y)):
				continue

			# Check the surrounding tiles (up, down, left, right) to determine where occluders and walls are needed
			var up = tile_map.get_cell_source_id(Vector2i(x, y - 1))
			var down = tile_map.get_cell_source_id(Vector2i(x, y + 1))
			var left = tile_map.get_cell_source_id(Vector2i(x - 1, y))
			var right = tile_map.get_cell_source_id(Vector2i(x + 1, y))

			# Add occluder and collision bodies
			if up == -1:
				_create_wall(x, y, 0) # Wall above
			if down == -1:
				_create_wall(x, y, 1) # Wall below
			if left == -1:
				_create_wall(x, y, 2) # Wall to the left
			if right == -1:
				_create_wall(x, y, 3) # Wall to the right

func _create_wall(x, y, direction) -> void:
	var body = StaticBody2D.new()
	var polygon_shape = CollisionPolygon2D.new()
	var points = PackedVector2Array()

	var wall_thickness = 10
	var top_left = Vector2(x * SCALED_TILE_SIZE, y * SCALED_TILE_SIZE)
	var bottom_right = Vector2((x + 1) * SCALED_TILE_SIZE, (y + 1) * SCALED_TILE_SIZE)

	# Rectangles based on direction
	if direction == 0: # Wall above
		points.push_back(top_left)
		points.push_back(Vector2(top_left.x + SCALED_TILE_SIZE, top_left.y))
		points.push_back(Vector2(top_left.x + SCALED_TILE_SIZE, top_left.y - wall_thickness))
		points.push_back(Vector2(top_left.x, top_left.y - wall_thickness))
	elif direction == 1: # Wall below
		points.push_back(Vector2(top_left.x, bottom_right.y))
		points.push_back(Vector2(top_left.x + SCALED_TILE_SIZE, bottom_right.y))
		points.push_back(Vector2(top_left.x + SCALED_TILE_SIZE, bottom_right.y + wall_thickness))
		points.push_back(Vector2(top_left.x, bottom_right.y + wall_thickness))
	elif direction == 2: # Wall to the left
		points.push_back(top_left)
		points.push_back(Vector2(top_left.x - wall_thickness, top_left.y))
		points.push_back(Vector2(top_left.x - wall_thickness, top_left.y + SCALED_TILE_SIZE))
		points.push_back(Vector2(top_left.x, top_left.y + SCALED_TILE_SIZE))
	elif direction == 3: # Wall to the right
		points.push_back(Vector2(bottom_right.x, top_left.y))
		points.push_back(Vector2(bottom_right.x + wall_thickness, top_left.y))
		points.push_back(Vector2(bottom_right.x + wall_thickness, top_left.y + SCALED_TILE_SIZE))
		points.push_back(Vector2(bottom_right.x, top_left.y + SCALED_TILE_SIZE))

	polygon_shape.polygon = points
	body.add_child(polygon_shape)

	body.collision_layer = 1 # Wall collision layer
	body.collision_mask = 1 # Player collision layer

	add_child(body)

	var occluder = LightOccluder2D.new()
	var occluder_polygon = OccluderPolygon2D.new()
	occluder_polygon.polygon = points
	occluder.occluder = occluder_polygon
	add_child(occluder)


func _draw() -> void:
	if map_drawn:
		return
	else:
		map_drawn = true
	print("Drawing dungeon...")

	# Tiles for corridors
	for position in corridor_data.keys():
		# Floor tile
		var random_x = randi_range(24, 27)
		var random_y = randi_range(25, 27)
		var coords = Vector2i(int(position.x / 16), int(position.y / 16))
		tile_map.set_cell(coords, 0, Vector2i(random_x, random_y))

	# Floor pattern
	for position in room_data.keys():
		var coords = Vector2i(int(position.x / 16), int(position.y / 16))

		var random_x = randi_range(24, 27)
		var random_y = randi_range(21, 23)
		var atlas_coord = Vector2i(random_x, random_y)

		tile_map.set_cell(coords, 0, atlas_coord)

func _spawn_player() -> void:
	if room_center.size() > 0:
		# Choose a random room center
		var random_room_center = room_center[randi() % room_center.size()]
		
		# Calculate the player position and instantiate the player
		var player_position = random_room_center * SCALE_FACTOR
		var player = player_scene.instantiate()
		player.global_position = player_position
		add_child(player)
