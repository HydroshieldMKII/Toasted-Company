extends BaseState
class_name MinoRun

@export var minotaur : Minotaur
var anim_minotaur : AnimationPlayer

func enter():
	anim_minotaur = minotaur.get_animation_minotaur()	
	
func update(delta: float) -> void:
	if minotaur.is_dead:
		return
		
	if not anim_minotaur :
		anim_minotaur = minotaur.get_animation_minotaur()
	
func physics_update(delta: float) -> void:
	if not anim_minotaur : return
	if minotaur.is_dead: return
		
	anim_minotaur.play("run")
	
