extends Node2D

@export var level_size := Vector2(1000, 750)
@export var rooms_size := Vector2(100, 140)
@export var rooms_max := 15
@export var corridor_width := 16
@export var player_scene := preload("res://Player/player.tscn") # Preload the player scene
@onready var fog: CanvasModulate = $Fog

@onready var tile_map := $Level

var room_data = {}
var room_center = []
var corridor_data = {}
var rooms = []

const TILE_SIZE := 16
const SCALE_FACTOR := 5
const SCALED_TILE_SIZE := TILE_SIZE * SCALE_FACTOR

var map_drawn = false

signal tunnel_entered

func _ready() -> void:
	if not map_drawn:
		_generate_dongeon_data()
		_draw_terrains()
		_generate_occluders_collisions()
		_spawn_random_items(0)
		_spawn_player()
	
func _process(delta: float) -> void:
	_manage_input()
	#_check_if_player_on_tunnel()

func _manage_input() -> void:
	if Input.is_action_just_pressed("f_key"): # toggle fog of war
		$Fog.visible = not $Fog.visible

	if Input.is_action_just_pressed("minus"): # zoom out
		$Player.get_node("Camera2D").zoom /= 1.3

	if Input.is_action_just_pressed("equal"): # zoom in
		$Player.get_node("Camera2D").zoom *= 1.3

	if Input.is_action_just_pressed("r"): # reset the game
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed("l_bracket"): # decrease light radius
		$Player.get_node("PointLight2D").texture_scale -= 1
		
	if Input.is_action_just_pressed("r_bracket"): # increase light radiu
		$Player.get_node("PointLight2D").texture_scale += 1

	if Input.is_action_just_pressed("semicol"): # decrease player speed
		$Player.get_node("StateMachine/Walk").move_speed -= 25

	if Input.is_action_just_pressed("quote"): # increase player speed
		$Player.get_node("StateMachine/Walk").move_speed += 25
		
	if Input.is_action_just_pressed("g"): # toggle player collision
		$Player.get_node("CollisionShape2D").disabled = not $Player.get_node("CollisionShape2D").disabled

func _check_if_player_on_tunnel() -> void:
	var player_position = $Player.global_position
	var standing_tile = tile_map.get_cell_tile_data(Vector2i(int(player_position.x / SCALED_TILE_SIZE), int(player_position.y / SCALED_TILE_SIZE)))

	print("Player standing on tile: ", standing_tile)
	
func _generate_dongeon_data() -> void:
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

	var x = rng.randi_range(0, level_size.x - width)
	var y = rng.randi_range(0, level_size.y - height)
	return Rect2(Vector2(x, y), Vector2(width, height))

func _add_room(room: Rect2) -> void:
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

func _generate_occluders_collisions() -> void:
	# Clear any existing occluders and collision bodies
	for child in get_children():
		if child is LightOccluder2D:
			child.queue_free()
		elif child is StaticBody2D:
			child.queue_free()

	# Check all tiles and add occluders / collision bodies where needed
	for x in range(0, level_size.x):
		for y in range(0, level_size.y):
			var tile = tile_map.get_cell_source_id(Vector2i(x, y))

			# Skip if no tile exists or if it's part of a corridor
			if tile == -1 or corridor_data.has(Vector2(x, y)):
				continue

			# Check the surrounding tiles (up, down, left, right)
			var up = tile_map.get_cell_source_id(Vector2i(x, y - 1))
			var down = tile_map.get_cell_source_id(Vector2i(x, y + 1))
			var left = tile_map.get_cell_source_id(Vector2i(x - 1, y))
			var right = tile_map.get_cell_source_id(Vector2i(x + 1, y))

			# Add occluder and collision bodies if needed
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

func _draw_terrains() -> void:
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
		
func _spawn_random_tunnel(closed: bool) -> void:
	if room_center.size() > 0:
		# Choose a random room center
		var random_room_center = room_center[randi() % room_center.size()]

		# Calculate the top-left corner of the tunnel area, centered at the room center.
		# Adjust for the tunnel width and scale.
		var top_left_x = random_room_center.x - (3 * TILE_SIZE * SCALE_FACTOR) / 6
		var top_left_y = random_room_center.y - (3 * TILE_SIZE * SCALE_FACTOR) / 6

		# Create a new TileMap layer for the tunnel (closed or open)
		var tunnel_tile_map = TileMapLayer.new()
		tunnel_tile_map.tile_set = tile_map.tile_set
		tunnel_tile_map.scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)

		if closed:
			for i in range(6):
				for j in range(6):
					# Calculate the exact tile position based on the scale and tile size
					var tile_x = int((top_left_x + i * TILE_SIZE) / TILE_SIZE)
					var tile_y = int((top_left_y + j * TILE_SIZE) / TILE_SIZE)
					var tile_coord = Vector2i(tile_x, tile_y)
					print("Tile coord:", tile_coord)
					# Set atlas coordinates for the tile (example coordinates used here)
					var atlas_coord = Vector2i(30 + i, 12 + j)
					tunnel_tile_map.set_cell(tile_coord, 0, atlas_coord)
		else:
			print("Tunnel opened, state:", closed)


		# Add Area2D for detecting player entry into the tunnel (random room center)
		var area = Area2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = TILE_SIZE * 3.5
		
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = circle_shape
		area.add_child(collision_shape)
		area.position = random_room_center
		print("Area position:", area.position)

		area.connect("area_entered", Callable(self, "_on_tunnel_entered"))
		tunnel_tile_map.add_child(area)

		add_child(tunnel_tile_map)
		print("Tunnel spawned at room center:", random_room_center, ", closed state:", closed)
	
func _spawn_random_items(level: int) -> void:
	# Spawn items in random rooms
	var item_sceen = preload("res://Items/item.tscn")
	var item = item_sceen.instantiate()

	var quantity_in_room = {
		0: 3,
		1: 3,
		2: 2
	}
	
	var quantity_in_corridor = {
		0: 2,
		1: 2,
		2: 1,
		3: 0
	}

	var room_quantity = quantity_in_room[level]
	if room_center.size() > 0:
		for i in range(room_quantity):
			_spawn_item(true)
			
	var corridor_quantity = quantity_in_corridor[level]
	for i in range(corridor_quantity):
		_spawn_item(false)

func _spawn_item(in_room: bool) -> void:
	var item_scene = preload("res://Items/item.tscn")
	var item = item_scene.instantiate()
	var random_tile

	if in_room:
		random_tile = room_data.keys()[randi() % room_data.size()]
	else:
		random_tile = corridor_data.keys()[randi() % corridor_data.size()]

	item.global_position = random_tile * SCALE_FACTOR
	item.scale = Vector2(0.5, 0.5)
	item.connect("item_collected", Callable(self, "_on_player_collect_item"))
	add_child(item)

	
func _spawn_player() -> void:
	if room_center.size() > 0:
		# Choose a random room center
		var random_room_center = room_center[randi() % room_center.size()]
		
		# Calculate the player position and instantiate the player
		var player_position = random_room_center * SCALE_FACTOR
		var player = player_scene.instantiate()
		player.global_position = player_position
		add_child(player)
		
		print("Player spawn pos: ", player_position)

		_spawn_random_tunnel(true)

#Singal callback

func _on_player_collect_item(item_name: String, value: int) -> void:
	print("Player collected item: ", item_name, " with value: ", value)

	# Hotbar (canvas layer) > PanelContainer > MarginContainer > GridContainer > TextureRect (item icon)
	var hotbar = $Player.get_node("Hotbar")
	var item1 = hotbar.get_node("PanelContainer/MarginContainer/GridContainer/TextureRect")
	var item2 = hotbar.get_node("PanelContainer/MarginContainer/GridContainer/TextureRect2")

	if item1.texture == null:
		item1.texture = load("res://Assests/Items/" + item_name + ".png")
		item1.modulate = Color(1, 1, 1, 1)
	else:
		item2.texture = load("res://Assests/Items/" + item_name + ".png")
		item2.modulate = Color(1, 1, 1, 1)

func _on_tunnel_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Player entered tunnel")
