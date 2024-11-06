extends Node2D

var item_name = null
var value = 0
@onready var sprite = $Sprite2D
@onready var label = $Label

signal item_collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Choose rnadom item sprite
	var item_sprites = ["thick_baguette", "thin_baguette", "loaf", "slice", "croissant", "pretzel"]
	var item_sprite = item_sprites[randi() % item_sprites.size()]
	item_name = item_sprite
	sprite.texture = load("res://Assests/Items/" + item_sprite + ".png")

	#Choose random item value and add label to item
	value = randi_range(5, 100)
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
		var hotbar = player.get_node("Hotbar")
		var item1 = hotbar.get_node("PanelContainer/MarginContainer/GridContainer/TextureRect")
		var item2 = hotbar.get_node("PanelContainer/MarginContainer/GridContainer/TextureRect2")

		if item1.texture != null and item2.texture != null:
			print("Hotbar is full, can't collect more items")
			return
		else:
			item_collected.emit(item_name, value)
			queue_free() # Dispawn item
