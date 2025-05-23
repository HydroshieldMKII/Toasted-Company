extends BaseState
class_name MageDeathRay

@export var mage: Mage
var anim_mage: AnimationPlayer
var is_casting = false
var is_cast_done = false
var player_got_it = false
var random_direction

signal mage_attack_done(mage: Mage)

func enter():
	is_casting = false
	is_cast_done = false
	player_got_it = false
	mage.sprite.flip_h = false
	mage.cast_beam.enabled = false
	anim_mage = mage.get_animation_mage()
	
	# Teleport in next to the player
	var directions = [
		Vector2(-100, 0), # Left
		Vector2(100, 0), # Right
	]
	random_direction = directions[randi() % directions.size()]
	mage.global_position = mage.player.global_position + random_direction
	
	if random_direction.x > 0:
		mage.scale = Vector2(-1, 1)
	else:
		mage.scale = Vector2(1, 1)
	
	anim_mage.play("teleport_in")
	
func update(delta: float) -> void:
	if not anim_mage:
		anim_mage = mage.get_animation_mage()
		
	if is_casting and not is_cast_done:
		anim_mage.play("death_ray")
	
func physics_update(delta: float) -> void:
	if not anim_mage: return
	
	# Check raycast if player got hit by the ray
	if is_casting and not player_got_it:
		mage.cast_beam.force_raycast_update()
		if mage.cast_beam.is_colliding() and mage.cast_beam.get_collider() == mage.player:
			player_got_it = true
			if DongeonGlobal.insane_mode:
				mage.player.take_damage(mage.base_attack_damage * 1.5)
			else:
				mage.player.take_damage(mage.base_attack_damage)
		
func _on_animation_mage_animation_finished(anim_name: StringName) -> void:
	if anim_name == "teleport_in":
		# Delay beam activation
		#mage.cast_delay.start()
		is_casting = true
		mage.cast_beam.force_raycast_update()
	
	if anim_name == "death_ray":
		if random_direction.x > 0:
			mage.scale = Vector2(-1, 1)
		else:
			mage.scale = Vector2(1, 1)
		is_cast_done = true
		anim_mage.play("teleport_away")
		
	if anim_name == "teleport_away":
		mage_attack_done.emit(mage) # Relocate mage on map
		Transitioned.emit(self, "Idle")

func _on_cast_delay_timeout() -> void:
	is_casting = true
