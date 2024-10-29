extends CharacterBody2D
class_name GenericCharacter

var anim_player : AnimationPlayer
var sprite : Sprite2D
var direction : Vector2

func get_animation_player () -> AnimationPlayer:
	return anim_player
