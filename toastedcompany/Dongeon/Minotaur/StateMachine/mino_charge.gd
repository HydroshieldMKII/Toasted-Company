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
		var current_position = minotaur.global_position
		var collision = minotaur.move_and_collide(target * minotaur.speed * delta)
		
		if collision:
			handle_collision(collision)

	#If charging, check for body overlap with player
	if charging and minotaur.get_node("CollisionDetection").overlaps_body(player):
		print("Mino contact!!")
		Transitioned.emit(self, "Attack")

func handle_collision(collision: KinematicCollision2D):
	# Scaling abilities
	minotaur.base_attack_damage *= 1.2
	if minotaur.base_attack_damage > 100:
		minotaur.base_attack_damage = 100

	minotaur.big_attack_damage *= 1.1
	if minotaur.big_attack_damage > 200:
		minotaur.big_attack_damage = 200

	minotaur.speed *= 1.1
	if minotaur.speed > 700:
		minotaur.speed = 700

	# Increase the chance of big attack
	var new_chance = minotaur.big_attack_chance * 1.1
	if new_chance <= 100:
		minotaur.big_attack_chance = new_chance

	# Make the minotaur bigger
	var new_charge_area = minotaur.get_node("ChargeArea/CollisionShape2D").shape as CircleShape2D
	if new_charge_area.radius <= 450:
		new_charge_area.radius *= 1.1
		minotaur.get_node("ChargeArea/CollisionShape2D").shape = new_charge_area

	var new_scale = minotaur.get_node("CollisionShape2D").scale * 1.1
	if new_scale.x <= 2.5 and new_scale.y <= 2.5:
		minotaur.get_node("CollisionShape2D").scale = new_scale

	var new_taunt_area = minotaur.get_node("TauntArea/CollisionShape2D").shape as CircleShape2D
	if new_taunt_area.radius <= 1000:
		new_taunt_area.radius *= 1.15
		minotaur.get_node("TauntArea/CollisionShape2D").shape = new_taunt_area

	var new_sprite_scale = minotaur.sprite.scale * 1.1
	if new_sprite_scale.x <= 8 and new_sprite_scale.y <= 8:
		minotaur.sprite.scale = new_sprite_scale

	# Handle transition based on collision
	if player.is_dead:
		Transitioned.emit(self, "Taunt")
	elif collision.get_collider().name == 'Player':
		Transitioned.emit(self, "Attack")
	elif minotaur.get_node("ChargeArea").overlaps_body(player):
		Transitioned.emit(self, "Charge")
	elif minotaur.get_node("TauntArea").overlaps_body(player):
		Transitioned.emit(self, "Taunt")
	else:
		Transitioned.emit(self, "Idle")

	charging = false
	target = null
	pre_charge_count = 0
	

func _on_animation_minotaur_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pre_charge" and not charging:
		if pre_charge_count < 3:
			pre_charge_count += 1
		else:
			charging = true
			#Check if player is in sight and can charge without hitting a wall
			# var ray = minotaur.get_node("RayCast2D") as RayCast2D
			# if ray:
			# 	ray.target_position = player.global_position - minotaur.global_position
			# 	ray.force_raycast_update()
				
			# if ray.is_colliding() and ray.get_collider() == player:
			# 	target = (player.global_position - minotaur.global_position).normalized()
			# 	charging = true
			# else:
			# 	print("Mino can't charge, player is behind a wall")
			# 	pre_charge_count = 0
			# 	if minotaur.get_node("ChargeArea").overlaps_body(player):
			# 		Transitioned.emit(self, "Charge")
			# 	elif minotaur.get_node("TauntArea").overlaps_body(player):
			# 		Transitioned.emit(self, "Taunt")
			# 	else:
			# 		Transitioned.emit(self, "Idle")

func _on_taunt_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player") and not charging: # Cancel charge early
		charging = false
		pre_charge_count = 0
		Transitioned.emit(self, "Idle")
