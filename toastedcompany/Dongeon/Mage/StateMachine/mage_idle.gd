extends BaseState
class_name MageIdle

@export var mage: Mage
var player: Player
var anim_mage: AnimationPlayer
var is_player_in_range = false
var mage_is_spawn = true

signal mage_idle_timeout(mage: Mage)

func enter():
	anim_mage = mage.get_animation_mage()
	player = get_tree().get_nodes_in_group("player")[0]
	
func update(delta: float) -> void:
	if not anim_mage:
		anim_mage = mage.get_animation_mage()
		
	if mage.idle_delay.is_stopped():
		mage.idle_delay.start()
		
	if is_player_in_range and mage_is_spawn:
		#Check if mage sees the player
		mage.player_detector.target_position = player.global_position - mage.global_position
		mage.player_detector.force_raycast_update()
			
		if mage.player_detector.is_colliding() and mage.player_detector.get_collider() == player:
			mage_is_spawn = false
			mage.idle_delay.stop()
			Transitioned.emit(self, "Deathray")
	
func physics_update(delta: float) -> void:
	if not anim_mage: return
	if mage_is_spawn:
		anim_mage.play("idle")
		
func _on_animation_mage_animation_finished(anim_name: StringName) -> void:
	if anim_name == "teleport_in":
		mage_is_spawn = true
	if anim_name == "teleport_away":
		print("Tp away done")
		mage_idle_timeout.emit(mage)
		anim_mage.play("teleport_in")

func _on_cast_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_player_in_range = true

func _on_cast_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_player_in_range = false

func _on_idle_timer_timeout() -> void:
	print("Idle timeout")
	mage_is_spawn = false
	anim_mage.play("teleport_away")
