class_name Torch
extends StaticBody3D

@onready var spot_light_3d = $SpotLight3D
@export var inhand = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		spot_light_3d.visible = true
	elif Input.is_action_just_pressed("right_click"):
		spot_light_3d.visible = false
