extends BaseState
class_name MinoAttack

signal mino_attack(damage: int)

@export var minotaur: Minotaur
@export var player: CharacterBody2D
var anim_minotaur: AnimationPlayer
var attack_damage

func enter():
	anim_minotaur = minotaur.get_animation_minotaur()
	player = minotaur.get_parent().get_node("Player")

	if randi() % 2 == 0:
		attack_damage = 10 # Small attack
		anim_minotaur.play("small_attack")
	else:
		attack_damage = 20 # Big attack
		anim_minotaur.play("big_attack")
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass


func _on_animation_minotaur_animation_finished(anim_name: StringName) -> void:
	if anim_name == "small_attack" or anim_name == "big_attack":
		mino_attack.emit(attack_damage)

		if minotaur.get_node("ChargeArea").overlaps_body(player):
			Transitioned.emit(self, "Charge")
		elif minotaur.get_node("TauntArea").overlaps_body(player):
			Transitioned.emit(self, "Taunt")
		else:
			Transitioned.emit(self, "Idle")
