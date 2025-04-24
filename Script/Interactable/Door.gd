extends Interactable
class_name Door

@export var animation_player: AnimationPlayer 

# Flag to track if the player is in the area
var player_in_area = false
var door_is_open = false
var is_animating = false # Flag to avoid triggering multiple inputs during animation

# Continuously check for input
func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("interaction") and !is_animating:
		if !door_is_open:
			open_door()
		else:
			close_door()

# Function to open the door
func open_door() -> void:
	animation_player.play("OpenDoor")
	door_is_open = true
	is_animating = true

# Function to close the door
func close_door() -> void:
	animation_player.play("CloseDoor")
	door_is_open = false
	is_animating = true
	


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	is_animating = false


func _on_body_entered(body: Node3D) -> void:
	if body is Player:  
		player_in_area = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:  # Same here for consistency
		player_in_area = false
