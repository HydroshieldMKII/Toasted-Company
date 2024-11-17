extends Node2D

var is_activated = false # Spike out
var is_trigger = false # Spike incoming
var is_player_inside_trap = false
@onready var timer_fadein: Timer = $Fadein
@onready var timer_fadeout: Timer = $Fadeout
@onready var timer_attack_delay: Timer = $AttackDelay
@onready var spike_sprite: Sprite2D = $Sprite2D

signal trap_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_player_inside_trap and timer_attack_delay.time_left == 0:
		timer_attack_delay.start()
		trap_pressed.emit(is_activated)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_player_inside_trap = true
		trap_pressed.emit(is_activated) # Signal dongeon player pressed on activated trap
		if not is_trigger:
			print("TRAP TRIGGERED")
			is_trigger = true
			timer_fadein.start()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_player_inside_trap = false

func _on_timer_timeout() -> void:
	print("TRAP ACTIVATED")
	is_activated = true
	for i in range(12):
		var textures = [
			preload("res://Assests/Spike/spike_1.png"),
			preload("res://Assests/Spike/spike_2.png"),
			preload("res://Assests/Spike/spike_3.png"),
			preload("res://Assests/Spike/spike_4.png")
		]
		
		for texture in textures:
			spike_sprite.texture = texture
			await get_tree().create_timer(0.05).timeout
		
		textures = [
			preload("res://Assests/Spike/spike_4.png"),
			preload("res://Assests/Spike/spike_3.png"),
			preload("res://Assests/Spike/spike_2.png"),
			preload("res://Assests/Spike/spike_1.png")
		]
		
		for texture in textures:
			spike_sprite.texture = texture
			await get_tree().create_timer(0.05).timeout

	spike_sprite.texture = preload("res://Assests/Spike/spike_2.png")	
	timer_fadeout.start()

func _on_fadeout_timeout() -> void:
	print("TRAP DEACTIVATED")

	var textures = [
		preload("res://Assests/Spike/spike_1.png"),
		preload("res://Assests/Spike/spike_0.png")
	]

	for texture in textures:
		spike_sprite.texture = texture
		await get_tree().create_timer(0.05).timeout

	is_activated = false
	is_trigger = false
