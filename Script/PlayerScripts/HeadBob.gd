extends Node3D
@onready var fps_character = $".."  # Reference to the character node
@onready var eyes: Node3D = %Eyes

# Head bobbing vars

const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_sprinting_instensity = 0.2
const head_bobbing_walking_instensity = 0.1
const head_bobbing_crouching_instensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

func _process(delta: float) -> void:
	# Handle walking, crouching, sprinting, or idle states
	if fps_character.isWalking:
		head_bobbing_current_intensity = head_bobbing_walking_instensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif fps_character.isCrouching:
		if fps_character.isCrouchWalking:

			head_bobbing_current_intensity = head_bobbing_crouching_instensity
			head_bobbing_index += head_bobbing_crouching_speed * delta
		else:
			head_bobbing_current_intensity = 0
			head_bobbing_index = 0
	elif fps_character.isSprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_instensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	else:
		head_bobbing_current_intensity = 0
		head_bobbing_index = 0
	
	if fps_character.is_on_floor() :
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta * fps_character.lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity,delta * fps_character.lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * fps_character.lerp_speed)
		eyes.position.y = lerp(eyes.position.x, 0.0, delta * fps_character.lerp_speed)

		
	
