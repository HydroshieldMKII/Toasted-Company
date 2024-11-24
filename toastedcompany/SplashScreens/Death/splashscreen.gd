extends CanvasLayer

@onready var try_again_btn: Button = $HBoxContainer/VBoxContainer/TryAgain
@onready var menu_btn: Button = $HBoxContainer/VBoxContainer/MainMenu
@onready var other_btn: Button = $HBoxContainer/VBoxContainer/TryOther
@onready var exit_btn: Button = $HBoxContainer/VBoxContainer/Exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DongeonGlobal.insane_mode:
		other_btn.text = "Try Normal Mode"
	else:
		other_btn.text = "Try Insane Mode"	
	try_again_btn.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_try_again_pressed() -> void:
	# Get dongeon scene and reload it while closing the current scene
	get_tree().change_scene_to_file("res://SplashScreens/Loading/splashscreen.tscn")

func _on_try_other_pressed() -> void:
	DongeonGlobal.insane_mode = !DongeonGlobal.insane_mode
	get_tree().change_scene_to_file("res://SplashScreens/Loading/splashscreen.tscn")
	
func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
