extends Control

@onready var start_btn: Button = $VBoxContainer/StartBtn

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func _ready() -> void:
	start_btn.grab_focus()
	#get_node("VBoxContainer/StartBtn").focused = 

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://World/world.tscn")
	
func _on_options_btn_pressed() -> void:
	pass # Replace with function body.
	
func _on_exit_btn_pressed() -> void:
	get_tree().quit()
