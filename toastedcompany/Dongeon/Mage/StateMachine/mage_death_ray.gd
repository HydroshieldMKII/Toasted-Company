extends BaseState
class_name MageDeathRay

@export var mage: Mage
var anim_mage: AnimationPlayer
var is_casting = false
var is_cast_done = false

signal mage_attack_done(mage: Mage)

func enter():
	print("Deathray enter")
	anim_mage = mage.get_animation_mage()

	#Teleport in next to the player
	var directions = [
		Vector2(-100, -25), # Left
		Vector2(100, 25), # Right
	]
	var random_direction = directions[randi() % directions.size()]
	mage.global_position = mage.player.global_position + random_direction
	
	if random_direction.x > 0:
		mage.sprite.flip_h = true
	else:
		mage.sprite.flip_h = false
	
	anim_mage.play("teleport_in")
	
func update(delta: float) -> void:
	if not anim_mage:
		anim_mage = mage.get_animation_mage()
		
	if is_casting and not is_cast_done:
		anim_mage.play("death_ray")
	
func physics_update(delta: float) -> void:
	if not anim_mage: return

func _on_animation_mage_animation_finished(anim_name: StringName) -> void:
	if anim_name == "teleport_in":
		print("teleport done")
		is_casting = true
		
	if anim_name == "death_ray":
		print("Death ray done")

		# Check raycast if player got hit be the ray
		var cast_beam = mage.get_node("CastBeam")

		if mage.sprite.flip_h:
			cast_beam.scale = Vector2(-1, 1)
		else:
			cast_beam.scale = Vector2(1, 1)
		cast_beam.force_raycast_update()
		
		if cast_beam.is_colliding() and cast_beam.get_collider() == mage.player:
			print("Player got hit by the ray")
			mage.player.take_damage(20)

		is_cast_done = true
		anim_mage.play("teleport_away")
		
	if anim_name == "teleport_away":
		is_casting = false
		is_cast_done = false
		mage.sprite.flip_h = false
		mage_attack_done.emit(mage) # Relocate mage on map
		Transitioned.emit(self, "Idle")
