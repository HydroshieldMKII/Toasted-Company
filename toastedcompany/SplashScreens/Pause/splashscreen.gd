extends Control

@onready var resume_btn: Button = $HBoxContainer/VBoxContainer/Resume

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resume_btn.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resume_pressed() -> void:
	DongeonGlobal.is_paused = false
	self.queue_free()

func _on_main_menu_pressed() -> void:
	DongeonGlobal.is_paused = false
	get_tree().change_scene_to_file("res://Menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
