extends GenericCharacter
class_name Player

@onready var timer: Timer = $FlashTimer
const NB_FLASH: int = 16
var flash_counter: int
var flash_value: int = 0
var timer_timout_executed = true

@onready var death_timer: Timer = $DeathTimer

var is_dead = false
var health = 100
@onready var healthbar = $Healthbar

signal player_respawn

func _ready() -> void:
	healthbar.value = 100
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
		
	check_health(delta)

func _on_flashtimer_timeout() -> void:
	shader.set_shader_parameter("flash_modifier", flash_value * 0.5);
	flash_value = !flash_value

	if flash_counter < NB_FLASH:
		flash_counter += 1
	else:
		timer_timout_executed = true
		healthbar.value -= 100
		
		flash_counter = 0
		shader.set_shader_parameter("flash_modifier", 0);
		timer.stop()
		
func check_health(delta: float):
	health = healthbar.value
	
	if health <= 0 and not is_dead:
		print("Player died")
		is_dead = true
		healthbar.value = 0
		anim_player.play("die")
		death_timer.start()
		

	#Update health color
	if health <= 30:
		healthbar.modulate = Color(1, 0, 0)
	elif health <= 60:
		healthbar.modulate = Color(1, 1, 0)
	else:
		healthbar.modulate = Color(0, 1, 0)

func _on_death_timer_timeout() -> void:
	player_respawn.emit()
