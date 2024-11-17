extends BaseState
class_name MinoCharge

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
	print("phys update idle")
	if not anim_minotaur : return
	if minotaur.is_dead: return
		
	anim_minotaur.play("idle")
	
func _on_taunt_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		Transitioned.emit(self, "Taunt")
