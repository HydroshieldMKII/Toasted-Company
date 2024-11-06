extends Node2D

var item_name := "bread"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_entered() -> void:
	print("Object collected by player")
	pass # Replace with function body.
