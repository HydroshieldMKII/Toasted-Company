extends VBoxContainer

@onready var brightness_value_label: Label = $Brightness_value
@onready var slider: HSlider = $HSlider
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.visible:
		if not slider.has_focus():
			slider.grab_focus()
		if Input.is_action_just_pressed("a"):
			self.visible = false
			get_parent().get_node("Menu/StartBtn").grab_focus()
			get_parent().get_node("Menu").visible = true
		if Input.is_action_just_pressed("left"):
			if slider.value > slider.min_value:
				slider.value -= 0.1
		if Input.is_action_just_pressed("right"):
			if slider.value < slider.max_value:
				slider.value += 0.1

func _on_h_slider_value_changed(value: float) -> void:
	DongeonGlobal.brightness = value
	brightness_value_label.text = "Brightness = " + str(value)
