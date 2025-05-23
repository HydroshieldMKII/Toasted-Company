extends BaseState
class_name MinoAttack

signal mino_attack(damage: int)

@export var minotaur: Minotaur
@export var player: CharacterBody2D
var anim_minotaur: AnimationPlayer

func enter():
	anim_minotaur = minotaur.get_animation_minotaur()
	player = get_tree().get_nodes_in_group("player")[0]

	var rand_value = randi() % 100
	if rand_value < (100 - minotaur.big_attack_chance):
		anim_minotaur.play("small_attack")
		if DongeonGlobal.insane_mode:
			mino_attack.emit(minotaur.base_attack_damage * 1.5)
		else:
			mino_attack.emit(minotaur.base_attack_damage)
	else:
		anim_minotaur.play("big_attack")
		if DongeonGlobal.insane_mode:
			mino_attack.emit(minotaur.big_attack_damage * 1.5)
		else:
			mino_attack.emit(minotaur.big_attack_damage)
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass


func _on_animation_minotaur_animation_finished(anim_name: StringName) -> void:
	if anim_name == "small_attack" or anim_name == "big_attack" and player:
		if minotaur.get_node("ChargeArea").overlaps_body(player):
			Transitioned.emit(self, "Charge")
		elif minotaur.get_node("TauntArea").overlaps_body(player):
			Transitioned.emit(self, "Taunt")
		else:
			Transitioned.emit(self, "Idle")
