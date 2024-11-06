extends Node2D

var item_name := "bread"
var value = 0
@onready var sprite = $Sprite2D
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Choose rnadom item sprite
	var item_sprites = ["thick_baguette", "thin_baguette", "loaf", "slice", "croissant", "pretzel"]
	var item_sprite = item_sprites[randi() % item_sprites.size()]
	sprite.texture = load("res://Assests/Items/" + item_sprite + ".png")

	#Choose random item value and add label to item
	value = randi_range(5, 100)
	label.text = str(value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_entered() -> void:
	print("Object collected by player")
	pass # Replace with function body.
