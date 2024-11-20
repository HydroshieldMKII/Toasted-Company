extends CharacterBody2D
class_name Mage

signal mage_attack_player(damage: int)

var player: Player
var anim_mage: AnimationPlayer
var sprite: Sprite2D
var shader: ShaderMaterial
@onready var cast_delay: Timer = $CastDelay
@onready var idle_delay: Timer = $IdleTimer
@onready var cast_beam: RayCast2D = $CastBeam
@onready var player_detector: RayCast2D = $RayCast2D
var base_attack_damage = 20
var big_attack_damage = 35
var big_attack_chance = 30 #in percent
var speed = 400

var is_dead = false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#shader = sprite.material as ShaderMaterial
	anim_mage = $AnimationMage
	sprite = $Sprite2D
	player = self.get_parent().get_node("Player")
	anim_mage.play("idle")

	#$StateMachine/Attack.connect("mage_attack", Callable(self, "_on_mage_attack_player"))

func _on_mage_attack_player(damage: int) -> void:
	print("Mage attack player")
	emit_signal("mage_attack_player", damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_animation_mage() -> AnimationPlayer:
	return anim_mage
	
func destroy() -> void:
	player = null
	queue_free()
