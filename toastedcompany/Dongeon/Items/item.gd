extends Node2D

var item_name = null
var value = 0
@onready var sprite = $Sprite2D
@onready var label = $Label

func get_item_min_value() -> int:
	return 0 + DongeonGlobal.current_level * 5
	
	
func get_item_max_value() -> int:
	return 60 + DongeonGlobal.current_level * 20

signal item_collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Choose rnadom item sprite
	var item_sprites = ["thick_baguette", "thin_baguette", "loaf", "slice", "croissant", "pretzel"]
	var item_sprite = item_sprites[randi() % item_sprites.size()]
	item_name = item_sprite
	sprite.texture = load("res://Assests/Items/" + item_sprite + ".png")

	#Choose random item value and add label to item depending on dongone level
	value = randi_range(get_item_min_value(), get_item_max_value())
	label.text = str(value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Item got collected")

		#Access palyer intsaance
		var player = area.get_parent()

		#Check if player have more then 2 items (2 textures in hotbar)
		var hotbar = player.get_node("HUD")
		var item1 = hotbar.get_node("PanelContainer/MarginContainer/GridContainer/Item1")
		var item2 = hotbar.get_node("PanelContainer/MarginContainer/GridContainer/Item2")

		if item1.texture != null and item2.texture != null:
			print("Hotbar is full, can't collect more items")
			return
		else:
			item_collected.emit(item_name, value)
			queue_free() # Dispawn item
