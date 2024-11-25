extends Control

@onready var start_btn: Button = $Menu/StartBtn

@onready var main_menu: VBoxContainer = $Menu
@onready var high_score: HBoxContainer = $HighScore
@onready var title: VBoxContainer = $Title

@onready var how_to_play: VBoxContainer = $HowToPlay
@onready var settings: VBoxContainer = $Settings
	
func _ready() -> void:
	start_btn.grab_focus()

func _on_start_btn_pressed() -> void:
	DongeonGlobal.insane_mode = false
	get_tree().change_scene_to_file("res://SplashScreens/Loading/splashscreen.tscn")
	
func _on_insane_btn_pressed() -> void:
	DongeonGlobal.insane_mode = true
	get_tree().change_scene_to_file("res://SplashScreens/Loading/splashscreen.tscn")
	
func _on_options_btn_pressed() -> void:
	main_menu.visible = false
	settings.visible = true
	
func _on_how_btn_pressed() -> void:
	title.visible = false
	main_menu.visible = false
	high_score.visible = false
	
	how_to_play.visible = true
	
func _on_exit_btn_pressed() -> void:
	get_tree().quit()
