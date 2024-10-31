extends Node2D

@export var level_size := Vector2(1000, 750)
@export var rooms_size := Vector2(100, 140)
@export var rooms_max := 15
@export var corridor_width := 12
@export var player_scene := preload("res://Player/player.tscn") # Preload the player scene

@onready var tile_map := $Level

var room_data = {}
var room_center = []
var corridor_data = {}
var rooms = []

const TILE_SIZE := 16
const SCALE_FACTOR := 5 # Scale factor for tiles when drawing
const SCALED_TILE_SIZE := TILE_SIZE * SCALE_FACTOR

func _ready() -> void:
	_generate()
	_draw()
	_spawn_player()


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

func _draw() -> void:
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
		player.z_index = 1
		add_child(player)
