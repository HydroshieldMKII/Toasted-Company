extends GenericCharacter
class_name Player

const NB_FLASH: int = 10
var flash_counter: int
var flash_value: int = 0
var timer_timout_executed = true

@onready var hud: CanvasLayer = $HUD
@onready var light_intensity: PointLight2D = $PointLight2D
@onready var death_timer: Timer = $DeathTimer
@onready var spawn_protection_time = $SpawnProtection
@onready var regen_timer = $HealthRegen
@onready var paused_screen = preload("res://SplashScreens/Pause/splashscreen.tscn")

var health = 100
@export var is_dead = false
@onready var healthbar = $Healthbar

signal player_respawn

func _ready() -> void:
	light_intensity.energy = DongeonGlobal.brightness
	healthbar.value = 100
	anim_player = $AnimationPlayer
	sprite = $Sprite
	shader = sprite.material as ShaderMaterial
	anim_player.play("idle")
	

func _physics_process(delta: float) -> void:
	if DongeonGlobal.is_paused:
		return
	elif not hud.visible:
		hud.visible = true

	move_and_slide()
	check_health(delta)
	
	if Input.is_action_just_pressed("pause"):
		DongeonGlobal.is_paused = true
		var pause_instance = paused_screen.instantiate()
		if not has_node(NodePath(pause_instance.name)):
			hud.visible = false
			add_child(pause_instance)

func damage_flash() -> void:
	while flash_counter < NB_FLASH:
		shader.set_shader_parameter("flash_modifier", flash_value * 0.5)
		flash_value = !flash_value
		flash_counter += 1
		await get_tree().create_timer(0.1).timeout
	
	flash_counter = 0
	shader.set_shader_parameter("flash_modifier", 0)

func take_damage(damage: int):
	regen_timer.start() # Restart regen delay
	if spawn_protection_time.time_left > 0:
		return
	health -= damage
	healthbar.value = health
	damage_flash()
	
func check_health(delta: float):
	if health <= 0 and not is_dead:
		print("Player died")
		is_dead = true
		#healthbar.value = 0
		anim_player.play("die")

	#Update health color
	if health <= 30:
		healthbar.modulate = Color(1, 0, 0)
	elif health <= 60:
		healthbar.modulate = Color(1, 1, 0)
	else:
		healthbar.modulate = Color(0, 1, 0)

func _on_death_timer_timeout() -> void:
	flash_counter = 0
	shader.set_shader_parameter("flash_modifier", 0)
	healthbar.value = 100
	spawn_protection_time.start()
	player_respawn.emit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		death_timer.start()

func _on_health_regen_timeout() -> void:
	if health < 100 and not is_dead:
		health += 5
		if health > 100:
			health = 100
		healthbar.value = health
