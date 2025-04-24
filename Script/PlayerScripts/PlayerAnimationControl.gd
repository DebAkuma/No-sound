extends Node3D

# Animation variables
@onready var skeleton_ik_3d = $Armature/Skeleton3D/SkeletonIK3D
@onready var anime_tree = $AnimationTree  # Ensure this path is correct

# Variable to store the current state to avoid unnecessary transitions
var current_animation_state: String = ""

func _ready() -> void:
	anime_tree.set("parameters/TorchInHand/blend_amount", 1)
	skeleton_ik_3d.start()

# Function to change animation state only if needed
func change_animation_state(state: String) -> void:
	if current_animation_state != state:
		anime_tree.set("parameters/StateChanging/transition_request", state)
		current_animation_state = state  # Update the current state

# Idle animation
func idle_animations():
	change_animation_state("Idle")


# Run animation
func run_animations():
	change_animation_state("Run")


# Walk animation
func walk_animations():
	change_animation_state("Walk")

# Crouch walk animation
func crouchWalk_animations():
	change_animation_state("CrouchWalk")

# Crouch idle animation
func crouchIdle_animation():
	change_animation_state("CrouchIdle")

# Jump animation (using a one-shot animation request)
func jump():
	change_animation_state("Jump")
