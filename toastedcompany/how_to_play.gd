extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.visible and Input.is_action_just_pressed("a"):
		self.visible = false
		get_parent().get_node("Menu/StartBtn").grab_focus()
		get_parent().get_node("Menu").visible = true
