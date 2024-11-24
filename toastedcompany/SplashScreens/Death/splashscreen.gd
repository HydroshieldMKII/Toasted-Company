extends CanvasLayer

@onready var try_again_btn: Button = $VBoxContainer/TryAgain
@onready var menu_btn: Button = $VBoxContainer/MainMenu
@onready var exit_btn: Button = $VBoxContainer/Exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	try_again_btn.grab_focus()

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
