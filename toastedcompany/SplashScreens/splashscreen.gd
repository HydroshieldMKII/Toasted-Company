extends Node2D
class_name Splash
@onready var overlay: PanelContainer = $CanvasLayer/PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("blurry")
	#overlay.material as ShaderMaterial
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
