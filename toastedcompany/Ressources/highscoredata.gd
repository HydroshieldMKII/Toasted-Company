extends Resource
class_name HighScoreData

@export var normal_high_score: int = 0
@export var normal_level: int = 0

@export var insane_high_score: int = 0
@export var insane_level: int = 0

func set_normal_score(score: int) -> void:
	if score > normal_high_score:
		normal_high_score = score
		
func set_normal_level(level: int) -> void:
	if level > normal_level:
		normal_level = level

func set_insane_score(score: int) -> void:
	if score > insane_high_score:
		insane_high_score = score
		
func set_insane_level(level: int) -> void:
	if level > insane_level:
		insane_level = level
	
