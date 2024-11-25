extends Control

@onready var start_btn: Button = $Menu/StartBtn

@onready var main_menu: VBoxContainer = $Menu
@onready var high_score: HBoxContainer = $HighScore
@onready var normal_high_score: Label = $HighScore/HBoxContainer2/HS_Normal
@onready var insane_high_score: Label = $HighScore/VBoxContainer/HS_Insane

@onready var title: VBoxContainer = $Title
@onready var how_to_play: VBoxContainer = $HowToPlay
@onready var settings: VBoxContainer = $Settings
		
const SAVE_FILE_PATH: String = "user://high_scores.tres"
const SAVE_FILE_NAME: String = "Highscore.tres"
var high_score_data: HighScoreData

func _ready() -> void:
	verify_save_dir(SAVE_FILE_PATH)
	update_labels()
	start_btn.grab_focus()
	
func verify_save_dir(path: String) -> void:
	DirAccess.make_dir_absolute(path)
	if FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE_NAME):
		high_score_data = ResourceLoader.load(SAVE_FILE_PATH + SAVE_FILE_NAME)
		if high_score_data == null:
			high_score_data = HighScoreData.new()
	else:
		high_score_data = HighScoreData.new()
	
func update_labels() -> void:
	normal_high_score.text = "Highest Score (Normal): " + str(high_score_data.normal_high_score) + " (Level " + str(high_score_data.normal_level) + ")"
	insane_high_score.text = "Highest Score (Insane): " + str(high_score_data.insane_high_score) + " (Level " + str(high_score_data.insane_level) + ")"
	
func set_scores(score: int, level: int, insane: bool) -> void:
	verify_save_dir(SAVE_FILE_PATH) #Update object
	
	if insane:
		high_score_data.set_insane_score(score)
		high_score_data.set_insane_level(level)
	else:
		high_score_data.set_normal_score(score)
		high_score_data.set_normal_level(level)
	ResourceSaver.save(high_score_data, SAVE_FILE_PATH + SAVE_FILE_NAME)

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
