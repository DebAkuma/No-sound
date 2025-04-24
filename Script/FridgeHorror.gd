extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Global.player:
		animation_player.play("JumpScare")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == Global.player:
		animation_player.play_backwards("JumpScare")
