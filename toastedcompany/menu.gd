extends Control

@onready var start_btn: Button = $Menu/StartBtn
@onready var main_menu: VBoxContainer = $Menu
@onready var how_to_play: VBoxContainer = $HowToPlay

@onready var settings: VBoxContainer = $Settings
@onready var brightness_bar: HSlider = $Settings/HSlider

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func _ready() -> void:
	start_btn.grab_focus()

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://World/world.tscn")
	
	
func _on_insane_btn_pressed() -> void:
	DongeonGlobal.insane_mode = true
	get_tree().change_scene_to_file("res://World/world.tscn")
	
func _on_options_btn_pressed() -> void:
	main_menu.visible = false
	settings.visible = true
	
func _on_how_btn_pressed() -> void:
	main_menu.visible = false
	how_to_play.visible = true
	
func _on_exit_btn_pressed() -> void:
	get_tree().quit()
