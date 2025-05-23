extends BaseState
class_name MinoIdle

@export var minotaur: Minotaur
var anim_minotaur: AnimationPlayer

func enter():
	anim_minotaur = minotaur.get_animation_minotaur()
	
func update(delta: float) -> void:
	if not anim_minotaur:
		anim_minotaur = minotaur.get_animation_minotaur()
	
func physics_update(delta: float) -> void:
	if not anim_minotaur: return
		
	anim_minotaur.play("idle")
	

# Spawned in range
func _on_taunt_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# Register the player in the minotaur
		minotaur.player = area.get_parent()

		Transitioned.emit(self, "Taunt")


func _on_charge_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		Transitioned.emit(self, "Charge")
