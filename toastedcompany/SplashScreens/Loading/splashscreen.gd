extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_try_again_pressed() -> void:
	# Get dongeon scene and reload it while closing the current scene
	get_tree().change_scene_to_file("res://Dongeon/dongeon.tscn")
	
func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
