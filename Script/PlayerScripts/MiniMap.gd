extends Camera3D

@export var player: CharacterBody3D
@export var offset:Vector3
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = player.global_position + offset
