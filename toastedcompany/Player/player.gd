extends GenericCharacter
class_name Player

@onready var timer : Timer = $FlashTimer
const NB_FLASH : int = 16
var flash_counter : int
var flash_value : int = 0
var timer_timout_executed = true

func _ready() -> void:
	anim_player = $AnimationPlayer
	sprite = $Sprite
	shader = sprite.material as ShaderMaterial
	anim_player.play("idle")

func _physics_process(delta: float) -> void:
	move_and_slide()

	if (Input.is_action_just_pressed("ui_select")):
		timer_timout_executed = false
		timer.start()
		
	if timer.timeout and not timer_timout_executed:
		_on_flashtimer_timeout()
		

func _on_flashtimer_timeout() -> void:
	shader.set_shader_parameter("flash_modifier", flash_value * 0.5);
	flash_value = !flash_value

	if flash_counter < NB_FLASH:
		flash_counter += 1
	else:
		timer_timout_executed = true
		
		flash_counter = 0
		shader.set_shader_parameter("flash_modifier", 0);
		timer.stop()
