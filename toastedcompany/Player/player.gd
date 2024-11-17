extends GenericCharacter
class_name Player

const NB_FLASH: int = 10
var flash_counter: int
var flash_value: int = 0
var timer_timout_executed = true

@onready var death_timer: Timer = $DeathTimer
@onready var spawn_protection_time = $SpawnProtection

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
	check_health(delta)

func damage_flash() -> void:
	while flash_counter < NB_FLASH:
		shader.set_shader_parameter("flash_modifier", flash_value * 0.5)
		flash_value = !flash_value
		flash_counter += 1
		await get_tree().create_timer(0.1).timeout
	
	flash_counter = 0
	shader.set_shader_parameter("flash_modifier", 0)

func take_damage(damage: int):
	if spawn_protection_time.time_left > 0:
		return
	health -= damage
	healthbar.value = health
	damage_flash()
	
func check_health(delta: float):
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
	shader.set_shader_parameter("flash_modifier", 0)
	player_respawn.emit()
