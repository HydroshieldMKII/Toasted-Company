extends BaseState
class_name MinoTaunt

@export var minotaur: Minotaur
@export var player: CharacterBody2D # Reference to the player node
var anim_minotaur: AnimationPlayer

func enter():
	anim_minotaur = minotaur.get_animation_minotaur()
	player = get_tree().get_nodes_in_group("player")[0]
		
func update(delta: float) -> void:
	#if minotaur.is_dead:
		#return
		
	if not anim_minotaur:
		anim_minotaur = minotaur.get_animation_minotaur()
	
func physics_update(delta: float) -> void:
	if not anim_minotaur: return

	anim_minotaur.play("taunt")
	
	if player:
		if player.global_position.x < minotaur.global_position.x:
			minotaur.sprite.flip_h = true
		else:
			minotaur.sprite.flip_h = false
		
func _on_charge_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		Transitioned.emit(self, "Charge")

func _on_taunt_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"): # Cancel charge early
		Transitioned.emit(self, "Idle")
