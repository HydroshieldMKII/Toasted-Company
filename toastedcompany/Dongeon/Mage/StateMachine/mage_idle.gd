extends BaseState
class_name MageIdle

@export var mage: Mage
var player: Player
var ray: RayCast2D
var anim_mage: AnimationPlayer
var is_player_in_range = false
var mage_is_spawn = false

func enter():
	anim_mage = mage.get_animation_mage()
	ray = mage.get_node("RayCast2D") as RayCast2D
	player = get_tree().get_nodes_in_group("player")[0]
	
func update(delta: float) -> void:
	if not anim_mage:
		anim_mage = mage.get_animation_mage()
		
	if not mage_is_spawn:
		anim_mage.play("teleport_in")
		
	if is_player_in_range and mage_is_spawn:
		#Check if mage sees the player
		ray.target_position = player.global_position - mage.global_position
		ray.force_raycast_update()
			
		if ray.is_colliding() and ray.get_collider() == player:
			mage_is_spawn = false
			Transitioned.emit(self, "Deathray")
	
func physics_update(delta: float) -> void:
	if not anim_mage: return
	if mage_is_spawn:
		anim_mage.play("idle")
		
func _on_animation_mage_animation_finished(anim_name: StringName) -> void:
	if anim_name == "teleport_in":
		mage_is_spawn = true

func _on_cast_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_player_in_range = true

func _on_cast_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_player_in_range = false
