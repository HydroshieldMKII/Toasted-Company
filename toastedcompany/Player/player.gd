extends GenericCharacter
class_name Player

func _ready() -> void:
	anim_player = $AnimationPlayer
	sprite = $Sprite
	anim_player.play("idle")

func _physics_process(delta: float) -> void:
	move_and_slide()
