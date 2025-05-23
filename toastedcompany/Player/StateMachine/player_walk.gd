extends BaseState
class_name PlayerWalk

@export var player: Player
var anim_player: AnimationPlayer

@export var move_speed := 425.0

func manage_input() -> Vector2:
	var dir: Vector2 = Input.get_vector("left", "right", "up", "down")

	if (dir.x != 0):
		dir.x = round(dir.x)
	if (dir.y != 0):
		dir.y = round(dir.y)

	return dir.normalized()

func update(delta: float) -> void:
	if player.is_dead:
		return
		
	if not anim_player:
		anim_player = player.get_animation_player()
	
	var dir := manage_input()
	
	if dir.length() > 0:
		player.velocity = dir * move_speed
	else:
		player.direction = Vector2.ZERO
		player.velocity = Vector2.ZERO
	
	if (player.velocity.length() == 0):
		#print("Transitionned to idle")
		Transitioned.emit(self, "idle")
	
	player.direction = dir

func physics_update(delta: float) -> void:
	if player.is_dead:
		player.direction = Vector2.ZERO
		player.velocity = Vector2.ZERO
		return
	if (player.velocity.length() > 0):
		round(player.velocity.x)
		round(player.velocity.y)
		if (player.velocity.x > 0 or player.velocity.x < 0):
			anim_player.play("walk_side")
			if (player.velocity.x > 0):
				#print("walking right")
				player.sprite.flip_h = false
			elif (player.velocity.x < 0):
				#print("walking left")
				player.sprite.flip_h = true
		elif (player.velocity.y < 0):
			#print("Walk Up")
			anim_player.play("walk_up")
		elif (player.velocity.y > 0):
			#print("walk down")
			anim_player.play("walk_down")
