extends BaseState
class_name PlayerDie

@export var player : Player
var anim_player : AnimationPlayer

func enter():
	anim_player = player.get_animation_player()	
	player.sprite.flip_h = true
	
func update(delta: float) -> void:
	if not anim_player :
		anim_player = player.get_animation_player()
	
func physics_update(delta: float) -> void:
	if not anim_player : return
	anim_player.flip
	anim_player.play("die")
