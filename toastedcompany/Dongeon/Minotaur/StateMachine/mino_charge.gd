extends BaseState
class_name MinoCharge

@export var minotaur: Minotaur
@export var player: CharacterBody2D # Reference to the player node
var anim_minotaur: AnimationPlayer
var pre_charge_count = 0
var charging = false
var target = null

func enter():
	anim_minotaur = minotaur.get_animation_minotaur()
	player = get_tree().get_nodes_in_group("player")[0]

func update(delta: float) -> void:
	if not anim_minotaur:
		anim_minotaur = minotaur.get_animation_minotaur()

	if charging:
		anim_minotaur.play("charge")
	else:
		anim_minotaur.play("pre_charge")

		if player:
			if player.global_position.x < minotaur.global_position.x:
				minotaur.sprite.flip_h = true
			else:
				minotaur.sprite.flip_h = false

func physics_update(delta: float) -> void:
	if charging and not target:
		var direction = player.global_position
		target = (direction - minotaur.global_position).normalized()

	if charging and target:
		var collision = minotaur.move_and_collide(target * minotaur.speed * delta)
		if collision: # Charge into the player
			charging = false
			target = null
			pre_charge_count = 0

			# Scaling abilities
			minotaur.base_attack_damage *= 1.2
			minotaur.big_attack_damage *= 1.1
			minotaur.speed *= 1.1

			# Increase the chance of big attack
			var new_chance = minotaur.big_attack_chance * 1.1
			if new_chance <= 100:
				minotaur.big_attack_chance = new_chance

			# Make the mintaur bigger
			minotaur.get_node("ChargeArea/CollisionShape2D").scale *= 1.05
			minotaur.sprite.scale *= 1.1
			var new_scale = minotaur.get_node("CollisionShape2D").scale * 1.1
			if new_scale.x <= 3.0 and new_scale.y <= 3.0:
				minotaur.get_node("CollisionShape2D").scale = new_scale
			
			# If collide with player, transition to attack state
			if collision.get_collider().name == 'Player':
				Transitioned.emit(self, "Attack")
			elif minotaur.get_node("ChargeArea").overlaps_body(player):
				Transitioned.emit(self, "Charge")
			elif minotaur.get_node("TauntArea").overlaps_body(player):
				Transitioned.emit(self, "Taunt")
			else:
				Transitioned.emit(self, "Idle")

func _on_animation_minotaur_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pre_charge" and not charging:
		if pre_charge_count < 3:
			pre_charge_count += 1
		else:
			charging = true

func _on_taunt_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player") and not charging: # Cancel charge early
		charging = false
		pre_charge_count = 0
		Transitioned.emit(self, "Idle")
