extends Node3D

@export var max_distance = 100.0  # Maximum distance to check
var check_interval = 0.3  # Time in seconds between checks
var time_since_last_check = 0.0  # Timer to track time between checks

func _ready():
	# Initial check when the game starts
	check_nodes_in_player_fov()

# Continuously check the nodes every frame, with an interval
func _process(delta):
	time_since_last_check += delta
	if time_since_last_check >= check_interval:
		check_nodes_in_player_fov()
		time_since_last_check = 0.0  # Reset the timer

# Function to check if the child nodes are within the player's FOV
func check_nodes_in_player_fov():
	# Assuming Global.player holds a reference to the player node
	var get_player = Global.player

	if not get_player:
		print("Player not found")
		return

	# Iterate through all child nodes
	for child in get_children():
		# Ensure the child is a Node3D (only apply visibility check on 3D nodes)
		if child is Node3D or child is MeshInstance3D:
			# Get the vector from the player to the child
			var player_to_child = child.global_transform.origin - get_player.global_transform.origin
			# Check if the child is within the maximum distance
			if player_to_child.length() <= max_distance:
				child.visible = true
			else:
				child.visible = false
