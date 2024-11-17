extends CharacterBody2D
class_name Minotaur

var anim_minotaur: AnimationPlayer
var sprite: Sprite2D
var shader: ShaderMaterial

var is_dead = false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_minotaur = $AnimationMinotaur
	sprite = $Sprite2D
	#shader = sprite.material as ShaderMaterial
	anim_minotaur.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_animation_minotaur() -> AnimationPlayer:
	return anim_minotaur
