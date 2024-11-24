extends Node2D
class_name Dongeon

@export var player_scene := preload("res://Player/player.tscn") # Preload the player scene
@export var splash_scene := preload("res://SplashScreens/splashscreen.tscn")
@export var spike_scene = preload("res://Dongeon/Spike/spike.tscn")
var player: Player = null
var splash: Splash = null
var minotaurs: Array = []
var mages: Array = []
var tunnels: Array = []

@onready var fog: CanvasModulate = $Fog

# TileMapLayer
@onready var tile_map := $Level

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

var max_death_per_level = 3
var speed_negation_per_item = 40
var ligth_negation_per_item = 2 # 2 scale

# Dynamic level configuration functions
func get_item_quantity_room() -> int:
	return round(3 + DongeonGlobal.current_level * 2)

func get_item_quantity_corridor() -> int:
	return round(1 + DongeonGlobal.current_level)

func get_respawn_quantity() -> int:
	return round(2 + DongeonGlobal.current_level * 3.66)

func get_points_per_level() -> int:
	if DongeonGlobal.insane_mode:
		return round(100 + 200 * pow(DongeonGlobal.current_level, 2))
	else:
		return round(100 + 200 * pow(DongeonGlobal.current_level, 1.2))

func get_dongeon_size() -> Vector2:
	var base_size = Vector2(1000, 750) # Starting dungeon size
	var scale = 1 + DongeonGlobal.current_level * 0.2 # Scale size by 20% per level
	return Vector2(round(base_size.x * scale), round(base_size.y * scale))

func get_rooms_max_per_level() -> int:
	return round(15 + DongeonGlobal.current_level * 2)

func get_corridor_width() -> int:
	return round(48)

func get_spike_quantity() -> int:
	if DongeonGlobal.insane_mode:
		return round(20 + DongeonGlobal.current_level * 12)
	else:
		return round(10 + DongeonGlobal.current_level * 5)

func get_minotaur_quantity() -> int:
	if DongeonGlobal.insane_mode:
		return round(6 + DongeonGlobal.current_level * 5)
	else:
		return round(2 + DongeonGlobal.current_level * 2)

func get_mage_quantity() -> int:
	if DongeonGlobal.insane_mode:
		return round(16 + DongeonGlobal.current_level * 6)
	else:
		return round(6 + DongeonGlobal.current_level * 2)
	
func get_tunnel_quantity() -> int:
	return round(2 + DongeonGlobal.current_level * 0.75)
	
var points_accumulated = 0

func _ready() -> void:
	dongeon_setup()
		
func _process(delta: float) -> void:
	_manage_input()
	pass

# Debug functions

func _manage_input() -> void:
	if player == null:
		return

	if Input.is_action_just_pressed("minus"): # zoom out
		player.get_node("Camera2D").zoom /= 1.5

	if Input.is_action_just_pressed("equal"): # zoom in
		player.get_node("Camera2D").zoom *= 1.5

	if Input.is_action_just_pressed("r"): # reset the game
		get_tree().reload_current_scene()
		DongeonGlobal.current_level = 0
		
	if Input.is_action_just_pressed("."):
		_go_next_level()
	
	#return
	
	if Input.is_action_just_pressed("f_key"): # toggle fog of war
		$Fog.visible = not $Fog.visible

	if Input.is_action_just_pressed("l_bracket"): # decrease light radius
		player.get_node("PointLight2D").texture_scale -= 1
		
	if Input.is_action_just_pressed("r_bracket"): # increase light radiu
		player.get_node("PointLight2D").texture_scale += 1

	if Input.is_action_just_pressed("semicol"): # decrease player speed
		player.get_node("StateMachine/Walk").move_speed -= 100

	if Input.is_action_just_pressed("quote"): # increase player speed
		player.get_node("StateMachine/Walk").move_speed += 100
		
	if Input.is_action_just_pressed("g"): # toggle player collision
		player.get_node("CollisionShape2D").disabled = not player.get_node("CollisionShape2D").disabled

func _update_uhd() -> void:
	var hud = player.get_node("HUD")
	var score_label = hud.get_node("Score")
	score_label.text = "Missing points: " + str(get_points_per_level() - points_accumulated)
	
	var lives_left = hud.get_node("LiveLeft")
	lives_left.text = "Lives left: " + str(DongeonGlobal.current_lives)
	
	var inventoryWarning = hud.get_node("InventoryWarning")
	inventoryWarning.visible = false

# Generation

func _generate_dongeon_data() -> void:
	room_data.clear()
	corridor_data.clear()
	rooms.clear()
	room_center.clear()
	_generate_data()

func _generate_data() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for r in get_rooms_max_per_level():
		var room = _get_random_room(rng)
		if _intersects(rooms, room):
			continue

		_add_room(room)
		if rooms.size() > 1:
			var room_previous: Rect2 = rooms[-2]
			_add_connection(rng, room_previous, room)
		rooms.append(room)
		room_center.append((room.position + room.end) / 2)
	print("Generate data done")

func _get_random_room(rng: RandomNumberGenerator) -> Rect2:
	var width = rng.randi_range(rooms_size.x, rooms_size.y)
	var height = rng.randi_range(rooms_size.x, rooms_size.y)

	var x = rng.randi_range(0, get_dongeon_size().x - width)
	var y = rng.randi_range(0, get_dongeon_size().y - height)
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
		for offset in range(-int(get_corridor_width() / 2), int(get_corridor_width() / 2) + 1):
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
	for x in range(0, get_dongeon_size().x):
		for y in range(0, get_dongeon_size().y):
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
	body.collision_layer = 1
	body.collision_mask = 1
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

# Spawner
func _spawn_random_tunnels() -> void:
	var tunnels_spawned = 0
	var max_tunnels = get_tunnel_quantity()
	var rooms_with_tunnels = []

	# Clear any existing tunnels
	for tunnel in tunnels:
		tunnel.queue_free()
		tunnels.erase(tunnel)

	while tunnels_spawned < max_tunnels and rooms_with_tunnels.size() < room_center.size():
		# Choose a random room that hasn't had a tunnel spawned yet
		var random_room_index = randi() % room_center.size()
		if random_room_index in rooms_with_tunnels:
			continue

		# Mark the room as having a tunnel
		rooms_with_tunnels.append(random_room_index)
		var random_room_center = room_center[random_room_index]

		# Calculate top-left corner of the tunnel area
		var top_left_x = random_room_center.x - (3 * TILE_SIZE * SCALE_FACTOR) / 6
		var top_left_y = random_room_center.y - (3 * TILE_SIZE * SCALE_FACTOR) / 6

		# Create a new tilemap for the tunnel
		var tunnel_tile_map = TileMapLayer.new()
		tunnel_tile_map.tile_set = tile_map.tile_set
		tunnel_tile_map.scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)
		tunnels.append(tunnel_tile_map)

		# Set tunnel tiles
		for i in range(6):
			for j in range(6):
				var tile_x = int((top_left_x + i * TILE_SIZE) / TILE_SIZE)
				var tile_y = int((top_left_y + j * TILE_SIZE) / TILE_SIZE)
				var tile_coord = Vector2i(tile_x, tile_y)

				var atlas_coord = Vector2i(30 + i, 12 + j) # Example tile coordinates
				tunnel_tile_map.set_cell(tile_coord, 0, atlas_coord)

		# Create collision for the tunnel area
		var area = Area2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = TILE_SIZE * 2.5

		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = circle_shape
		area.add_child(collision_shape)
		area.position = random_room_center

		# Connect signals for area interactions
		area.connect("area_entered", Callable(self, "_on_tunnel_entered"))

		# Add the tunnel to the scene
		tunnel_tile_map.add_child(area)
		add_child(tunnel_tile_map)

		print("Tunnel spawned at room center:", random_room_center)
		tunnels_spawned += 1

	
func _spawn_random_items() -> void:
	# Clear any existing items
	var items = get_tree().get_nodes_in_group("item")
	for item in items:
		item.queue_free()
		items.erase(item)
	
	# Spawn items in random rooms
	var item_sceen = preload("res://Dongeon/Items/item.tscn")
	var item = item_sceen.instantiate()

	if room_center.size() > 0:
		for i in get_item_quantity_room():
			_spawn_item(true)
			
	for i in get_item_quantity_corridor():
		_spawn_item(false)

func _spawn_item(in_room: bool) -> void:
	var item_scene = preload("res://Dongeon/Items/item.tscn")
	var item = item_scene.instantiate()
	var random_tile

	if in_room:
		random_tile = room_data.keys()[randi() % room_data.size()]
	else:
		random_tile = corridor_data.keys()[randi() % corridor_data.size()]

	item.global_position = random_tile * SCALE_FACTOR
	#item.scale = Vector2(0.5, 0.5)
	item.connect("item_collected", Callable(self, "_on_player_collect_item"))
	item.add_to_group("item")
	call_deferred("add_child", item)

func _spawn_spikes() -> void:
	# Clear any existing spikes
	var spikes = get_tree().get_nodes_in_group("spike")
	for spike in spikes:
		spike.queue_free()

	for i in get_spike_quantity():
		var spike = spike_scene.instantiate()
		var random_tile = room_data.keys()[randi() % room_data.size()]
		
		var spawn_in_corridor = randi() % 2 == 0
		
		if spawn_in_corridor and corridor_data.size() > 0:
			random_tile = corridor_data.keys()[int(randi() % corridor_data.size())]
		else:
			random_tile = room_data.keys()[int(randi() % room_data.size())]

		spike.global_position = random_tile * SCALE_FACTOR
		spike.connect("trap_pressed", Callable(self, "_player_pressed_trap"))
		call_deferred("add_child", spike)

func _spawn_minotaurs() -> void:
	# Clear any existing ennemies
	for m in minotaurs:
		m.destroy()
		m.queue_free()
		minotaurs.erase(m)
		
	minotaurs.clear()

	var minotaur_scene = preload("res://Dongeon/Minotaur/minotaur.tscn")
	var used_tiles = []
	for i in get_minotaur_quantity():
		var minotaur = minotaur_scene.instantiate()
		var random_tile = room_data.keys()[randi() % room_data.size()]
		
		# Ensure the tile is not already used
		while random_tile in used_tiles:
			random_tile = room_data.keys()[randi() % room_data.size()]
		
		used_tiles.append(random_tile)
		minotaur.global_position = random_tile * SCALE_FACTOR
		minotaur.connect("mino_attack_player", Callable(self, "_on_minotaur_attack"))
		minotaur.add_to_group("minotaur")
		minotaur.player = player
		call_deferred("add_child", minotaur)

		minotaurs.append(minotaur)
		
	print("Ennemies spawn done")

func _spawn_mages() -> void:
	# Clear any existing ennemies
	for m in mages:
		m.destroy()
		m.queue_free()
		mages.erase(m)

	var mage_scene = preload("res://Dongeon/Mage/mage.tscn")
	var used_tiles = []
	for i in get_mage_quantity():
		var mage = mage_scene.instantiate()
		var random_tile = room_data.keys()[randi() % room_data.size()]
		
		# Ensure the tile is not already used
		while random_tile in used_tiles:
			random_tile = room_data.keys()[randi() % room_data.size()]
		
		used_tiles.append(random_tile)
		mage.global_position = random_tile * SCALE_FACTOR
		mage.get_node("StateMachine/DeathRay").connect("mage_attack_done", Callable(self, "_on_mage_attack_done"))
		mage.get_node("StateMachine/Idle").connect("mage_idle_timeout", Callable(self, "_on_mage_idle_timeout"))
		mage.add_to_group("mage")
		mage.player = player
		call_deferred("add_child", mage)

		mages.append(mage)
		

func _on_mage_idle_timeout(mage: Mage) -> void:
	print("Mage idle relocation")
	var random_tile = room_data.keys()[randi() % room_data.size()]
	mage.global_position = random_tile * SCALE_FACTOR
		
func _on_minotaur_attack(damage: int) -> void:
	player.take_damage(damage)

# On Action
func _spawn_player() -> void:
	if room_center.size() > 0:
		# Destroy any existing player instance
		if player == null:
			player = player_scene.instantiate()
			player.connect("player_respawn", Callable(self, "_player_death"))
			call_deferred("add_child", player)
		else:
			#clear items and set back life
			var hud = player.get_node("HUD")
			var item1 = hud.get_node("PanelContainer/MarginContainer/GridContainer/Item1")
			var item2 = hud.get_node("PanelContainer/MarginContainer/GridContainer/Item2")
			item1.texture = null
			item2.texture = null
			hud.get_node("ItemScore1").text = ""
			hud.get_node("ItemScore2").text = ""
			player.health = 100
			player.is_dead = false
			player.get_node("StateMachine/Walk").move_speed = 425.0
			player.get_node("PointLight2D").texture_scale = 14
			

		# Choose a random room center
		var random_room_center = room_center[randi() % room_center.size()]
		
		# Calculate the player position and instantiate the player
		var player_position = random_room_center * SCALE_FACTOR
		player.global_position = player_position
		_update_uhd()

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
		player.get_node("StateMachine/Walk").move_speed -= speed_negation_per_item
		player.get_node("PointLight2D").texture_scale -= ligth_negation_per_item
	else:
		item2.texture = load("res://Assests/Items/" + item_name + ".png")
		item2.modulate = Color(1, 1, 1, 1)
		hud.get_node("ItemScore2").text = str(value)
		player.get_node("StateMachine/Walk").move_speed -= (speed_negation_per_item + 10)
		player.get_node("PointLight2D").texture_scale -= ligth_negation_per_item

		var inventoryWarning = hud.get_node("InventoryWarning")
		inventoryWarning.visible = true

func _go_next_level() -> void:
	#if DongeonGlobal.current_level == 9:
		#print("Game completed!")
		#get_tree().quit()
		#return
	
	map_drawn = false
	DongeonGlobal.current_level += 1
	get_tree().reload_current_scene() # @ _go_next_level(): Removing a CollisionObject node during a physics callback is not allowed and will cause undesired behavior. Remove with call_deferred() instead.

	#dongeon_setup()

func _on_tunnel_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		var hud = player.get_node("HUD")
		var item1 = hud.get_node("PanelContainer/MarginContainer/GridContainer/Item1")
		var item2 = hud.get_node("PanelContainer/MarginContainer/GridContainer/Item2")
		var item1_value = 0
		var item2_value = 0

		if hud.get_node("ItemScore1").text != "":
			item1_value = int(hud.get_node("ItemScore1").text)
			player.get_node("StateMachine/Walk").move_speed += speed_negation_per_item
			player.get_node("PointLight2D").texture_scale += ligth_negation_per_item
		if hud.get_node("ItemScore2").text != "":
			item2_value = int(hud.get_node("ItemScore2").text)
			player.get_node("StateMachine/Walk").move_speed += speed_negation_per_item + 10
			player.get_node("PointLight2D").texture_scale += ligth_negation_per_item

		points_accumulated += (item1_value + item2_value)

		if get_points_per_level() - points_accumulated <= 0:
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

func _player_death() -> void:
	DongeonGlobal.current_lives -= 1
	
	if DongeonGlobal.current_lives == -1:
		DongeonGlobal.current_level = 0
		DongeonGlobal.current_lives = 3
		get_tree().reload_current_scene()
	else:
		_spawn_player()
		_update_uhd()

func _player_pressed_trap(is_activated: bool) -> void:
	if is_activated:
		if DongeonGlobal.insane_mode:
			player.take_damage(10 + DongeonGlobal.current_level * 10)
		else:
			player.take_damage(10)
		
func dongeon_setup() -> void:
	if map_drawn: return
	map_drawn = true
	
	points_accumulated = 0
	
	# Clear old tilemap level
	tile_map.clear()

	# Generate dongeon shape
	_generate_dongeon_data()
	_draw_terrains()
	_generate_occluders_collisions()
	
	# Spawn goodies
	_spawn_random_items()
	
	# Spawn the player
	_spawn_player()
	_update_uhd()
	
	# Spawn goodies endpoint
	_spawn_random_tunnels()
	
	# Spawn danger
	_spawn_spikes()
	_spawn_minotaurs()
	_spawn_mages()
