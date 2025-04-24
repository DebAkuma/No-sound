extends Node3D
@onready var omni: OmniLight3D = $OmniLight3D
@onready var anime: AnimationPlayer = $AnimationTree


func _on_area_3d_body_entered(body):
	if body ==Global.player:
		anime.play("FUU")
		$AudioStreamPlayer3D.play()
