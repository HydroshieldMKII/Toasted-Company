extends Node2D

@export var player_scene := preload("res://Player/player.tscn") # Preload the player scene
var player: Player = null

@onready var fog: CanvasModulate = $Fog

# TileMapLayer
@onready var tile_map := $Level
var tunnel_tile_map: TileMapLayer = null

# Generation data
var room_data = {}
var room_center = []
var corridor_data = {}
var rooms = []

const TILE_SIZE := 16
const SCALE_FACTOR := 5
const SCALED_TILE_SIZE := TILE_SIZE * SCALE_FACTOR

var map_drawn = false

# Generation Config
@export var rooms_size := Vector2(100, 140) # Size in pixels
@export var corridor_width := 16

# Level config
var current_level = 0
var item_quantity_room = {
	0: 3,
	1: 3,
	2: 5,
	3: 7,
	4: 9,
	5: 11,
	6: 11,
	7: 12,
	8: 13,
	9: 14
}

var item_quantity_corridor = {
	0: 1,
	1: 2,
	2: 2,
	3: 3,
	4: 4,
	5: 5,
	6: 6,
	7: 7,
	8: 8,
	9: 8
}

var points_per_level = {
	0: 100,
	1: 300,
	2: 500,
	3: 700,
	4: 900,
	5: 1100,
	6: 1400,
	7: 2000,
	8: 3000,
	9: 5000
}

var dongeon_size_per_level = {
	0: Vector2(1000, 750),
	1: Vector2(1200, 900),
	2: Vector2(1400, 1050),
	3: Vector2(1600, 1200),
	4: Vector2(1800, 1350),
	5: Vector2(2000, 1500),
	6: Vector2(2200, 1650),
	7: Vector2(2400, 1800),
	8: Vector2(2600, 1950),
	9: Vector2(2800, 2100)
}

var rooms_max_per_level = {
	0: 15,
	1: 17,
	2: 19,
	3: 21,
	4: 23,
	5: 25,
	6: 27,
	7: 29,
	8: 31,
	9: 33
}

var corridor_width_per_level = {
	0: 16,
	1: 16,
	2: 16,
	3: 16,
	4: 16,
	5: 16,
	6: 16,
	7: 16,
	8: 16,
	9: 16
}

var points_accumulated = 0

func _ready() -> void:
	if not map_drawn:
		_generate_dongeon_data()
		_draw_terrains()
		_generate_occluders_collisions()
		_spawn_random_items(0)
		_spawn_player()
		_update_uhd()
	
func _process(delta: float) -> void:
	_manage_input()

func _manage_input() -> void:
	if player == null:
		return

	if Input.is_action_just_pressed("f_key"): # toggle fog of war
		$Fog.visible = not $Fog.visible

	if Input.is_action_just_pressed("minus"): # zoom out
		player.get_node("Camera2D").zoom /= 1.3

	if Input.is_action_just_pressed("equal"): # zoom in
		player.get_node("Camera2D").zoom *= 1.3

	if Input.is_action_just_pressed("r"): # reset the game
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed("l_bracket"): # decrease light radius
		player.get_node("PointLight2D").texture_scale -= 1
		
	if Input.is_action_just_pressed("r_bracket"): # increase light radiu
		player.get_node("PointLight2D").texture_scale += 1

	if Input.is_action_just_pressed("semicol"): # decrease player speed
		player.get_node("StateMachine/Walk").move_speed -= 25

	if Input.is_action_just_pressed("quote"): # increase player speed
		player.get_node("StateMachine/Walk").move_speed += 25
		
	if Input.is_action_just_pressed("g"): # toggle player collision
		player.get_node("CollisionShape2D").disabled = not player.get_node("CollisionShape2D").disabled
		
	if Input.is_action_just_pressed("."):
		_go_next_level()

func _update_uhd() -> void:
	var hud = player.get_node("HUD")
	var score_label = hud.get_node("Score")
	score_label.text = "Missing points: " + str(points_per_level[current_level] - points_accumulated)

	var inventoryWarning = hud.get_node("InventoryWarning")
	inventoryWarning.visible = false

func _generate_dongeon_data() -> void:
	room_data.clear()
	corridor_data.clear()
	rooms.clear()
	room_center.clear()
	_generate_data()

func _generate_data() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for r in range(rooms_max_per_level[current_level]):
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

	var x = rng.randi_range(0, dongeon_size_per_level[current_level].x - width)
	var y = rng.randi_range(0, dongeon_size_per_level[current_level].y - height)
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
	for x in range(0, dongeon_size_per_level[current_level].x):
		for y in range(0, dongeon_size_per_level[current_level].y):
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
	body.call_deferred("add_child", polygon_shape)

	body.collision_layer = 1 # Wall collision layer
	body.collision_mask = 1 # Player collision layer

	call_deferred("add_child", body)

	var occluder = LightOccluder2D.new()
	var occluder_polygon = OccluderPolygon2D.new()
	occluder_polygon.polygon = points
	occluder.occluder = occluder_polygon
	call_deferred("add_child", occluder)

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

		tunnel_tile_map = TileMapLayer.new()
		# Create a new TileMap layer for the tunnel (closed or open)
		tunnel_tile_map.tile_set = tile_map.tile_set
		tunnel_tile_map.scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)

		if closed:
			for i in range(6):
				for j in range(6):
					# Calculate the exact tile position based on the scale and tile size
					var tile_x = int((top_left_x + i * TILE_SIZE) / TILE_SIZE)
					var tile_y = int((top_left_y + j * TILE_SIZE) / TILE_SIZE)
					var tile_coord = Vector2i(tile_x, tile_y)

					# Set atlas coordinates for the tile (example coordinates used here)
					var atlas_coord = Vector2i(30 + i, 12 + j)
					tunnel_tile_map.set_cell(tile_coord, 0, atlas_coord)
		else:
			print("Tunnel created, state:", closed)


		# Add Area2D for detecting player entry into the tunnel (random room center)
		var area = Area2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = TILE_SIZE * 2.5
		
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = circle_shape
		area.call_deferred("add_child", collision_shape)
		area.position = random_room_center
		print("Area position:", area.position)

		area.connect("area_entered", Callable(self, "_on_tunnel_entered"))
		tunnel_tile_map.call_deferred("add_child", area)

		call_deferred("add_child", tunnel_tile_map)
		print("Tunnel spawned at room center:", random_room_center, ", closed state:", closed)
	
func _spawn_random_items(level: int) -> void:
	# Clear any existing items
	var items = get_tree().get_nodes_in_group("item")
	for item in items:
		item.queue_free()
	
	# Spawn items in random rooms
	var item_sceen = preload("res://Items/item.tscn")
	var item = item_sceen.instantiate()

	var room_quantity = item_quantity_room[level]
	if room_center.size() > 0:
		for i in range(room_quantity):
			_spawn_item(true)
			
	var corridor_quantity = item_quantity_corridor[level]
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
	item.add_to_group("item")
	call_deferred("add_child", item)

	
func _spawn_player() -> void:
	if room_center.size() > 0:
		# Destroy any existing player instance
		if player != null:
			player.queue_free()

		# Choose a random room center
		var random_room_center = room_center[randi() % room_center.size()]
		
		# Calculate the player position and instantiate the player
		var player_position = random_room_center * SCALE_FACTOR
		player = player_scene.instantiate()
		player.global_position = player_position
		call_deferred("add_child", player)
		
		print("Player spawn pos: ", player_position)

		_spawn_random_tunnel(true)

#Signal callback

func _on_player_collect_item(item_name: String, value: int) -> void:
	print("Player collected item: ", item_name, " with value: ", value)

	# hud (canvas layer) > PanelContainer > MarginContainer > GridContainer > TextureRect (item icon)
	var hud = player.get_node("HUD")
	var item1 = hud.get_node("PanelContainer/MarginContainer/GridContainer/Item1")
	var item2 = hud.get_node("PanelContainer/MarginContainer/GridContainer/Item2")


	if item1.texture == null:
		item1.texture = load("res://Assests/Items/" + item_name + ".png")
		item1.modulate = Color(1, 1, 1, 1)
		hud.get_node("ItemScore1").text = str(value)
	else:
		item2.texture = load("res://Assests/Items/" + item_name + ".png")
		item2.modulate = Color(1, 1, 1, 1)
		hud.get_node("ItemScore2").text = str(value)

		var inventoryWarning = hud.get_node("InventoryWarning")
		inventoryWarning.visible = true

func _go_next_level() -> void:
	if current_level == 9:
		print("Game completed!")
		get_tree().quit()
		return

	current_level += 1
	points_accumulated = 0
	map_drawn = false

	tunnel_tile_map.queue_free()
	tile_map.clear()

	_generate_dongeon_data()
	_draw_terrains()
	_generate_occluders_collisions()
	_spawn_random_items(current_level)
	_spawn_player()
	_update_uhd()

func _on_tunnel_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Player entered tunnel")

		var hud = player.get_node("HUD")
		var item1 = hud.get_node("PanelContainer/MarginContainer/GridContainer/Item1")
		var item2 = hud.get_node("PanelContainer/MarginContainer/GridContainer/Item2")
		var item1_value = 0
		var item2_value = 0

		if hud.get_node("ItemScore1").text != "":
			item1_value = int(hud.get_node("ItemScore1").text)
		if hud.get_node("ItemScore2").text != "":
			item2_value = int(hud.get_node("ItemScore2").text)

		points_accumulated += (item1_value + item2_value)

		if points_per_level[current_level] - points_accumulated <= 0:
			print("Level completed!")
			_go_next_level()

		else:
			# If no more items in the map, spawn new ones
			var items = get_tree().get_nodes_in_group("item")
			if items.size() == 0:
				_spawn_item(true)

		_update_uhd()

		item1.texture = null
		item2.texture = null
		hud.get_node("ItemScore1").text = ""
		hud.get_node("ItemScore2").text = ""
