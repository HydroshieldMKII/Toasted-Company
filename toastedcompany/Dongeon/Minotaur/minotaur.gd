extends CharacterBody2D
class_name Minotaur

signal mino_attack_player(damage: int)

var player: Player
var anim_minotaur: AnimationPlayer
var sprite: Sprite2D
var shader: ShaderMaterial
var base_attack_damage = 20
var big_attack_damage = 35
var big_attack_chance = 30 #in percent
var speed = 400

var is_dead = false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#shader = sprite.material as ShaderMaterial
	anim_minotaur = $AnimationMinotaur
	sprite = $Sprite2D
	player = self.get_parent().get_node("Player")
	anim_minotaur.play("idle")

	$StateMachine/Attack.connect("mino_attack", Callable(self, "_on_mino_attack_player"))

func _on_mino_attack_player(damage: int) -> void:
	print("Minotaur attack player")
	emit_signal("mino_attack_player", damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_animation_minotaur() -> AnimationPlayer:
	return anim_minotaur
	
func destroy() -> void:
	player = null
	queue_free()
