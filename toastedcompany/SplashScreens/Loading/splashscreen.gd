extends CanvasLayer

const target_scene_path = "res://Dongeon/dongeon.tscn"

@onready var title: Label = $HBoxContainer/VBoxContainer/Label
var loading_status: int
var progress: Array[float]

func _ready() -> void:
	# Request to load the target scene:
	if DongeonGlobal.insane_mode:
		var red = Color(1.0,0.0,0.0,1.0)
		title.set("theme_override_colors/font_color",red)
	ResourceLoader.load_threaded_request(target_scene_path)
	
func _process(_delta: float) -> void:
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			# When done loading, change to the target scene:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene_path))
		ResourceLoader.THREAD_LOAD_FAILED:
			# Well some error happend:
			print("Error. Could not load Resource")
