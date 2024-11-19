extends Node2D

var item_name = null
var value = 0
@onready var sprite = $Sprite2D
@onready var label = $Label

var items_value_min_per_level = {
	0: 0,
	1: 5,
	2: 10,
	3: 15,
	4: 20,
	5: 25,
	6: 30,
	7: 35,
	8: 40,
	9: 45,
}

var items_value_max_per_level = {
	0: 60,
	1: 80,
	2: 100,
	3: 120,
	4: 140,
	5: 160,
	6: 180,
	7: 200,
	8: 220,
	9: 240,
}

signal item_collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Choose rnadom item sprite
	var item_sprites = ["thick_baguette", "thin_baguette", "loaf", "slice", "croissant", "pretzel"]
	var item_sprite = item_sprites[randi() % item_sprites.size()]
	item_name = item_sprite
	sprite.texture = load("res://Assests/Items/" + item_sprite + ".png")

	#Choose random item value and add label to item depending on dongone level
	value = randi_range(items_value_min_per_level[DongeonGlobal.current_level], items_value_max_per_level[DongeonGlobal.current_level])
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
