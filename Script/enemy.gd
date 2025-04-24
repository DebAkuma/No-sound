class_name Enemy
extends CharacterBody3D

@export var character: CharacterBody3D

const DETECTION_RADIUS: float = 15.0
const WANDER_RADIUS: float = 50.0
const CHASING_SPEED: float = 7.0
const WANDERING_SPEED: float = 3.0
const SOUND_COOLDOWN: float = 2.0
const ROTATION_SPEED: float = 4.0
const MIN_IDLE_TIME: float = 1.0
const MAX_IDLE_TIME: float = 2.0
const CHASE_TIMEOUT: float = 2.0  # Time in seconds to chase before giving up

enum State {
	WANDERING,
	CHASING,
	IDLE
}

var currentState: State = State.WANDERING
var currentSpeed: float
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var sound_cooldown_timer: float = 0.0
var navigation_ready: bool = false
var idle_timer: float = 0.0
var chase_timer: float = 0.0  # Timer to track chase duration
var nav_map: RID  # RID for the navigation map
var previousState: State = State.WANDERING  # Store the previous state
var idle_rotation_target: float = 0.0  # Target angle for idle rotation
var roar_timer: float = 1.0  # Timer to control when the roar plays

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var roar: AudioStreamPlayer3D = $Roar

@warning_ignore("unused_signal")
signal killPlayer

func _ready() -> void:
	Global.enemy = self
	nav.velocity_computed.connect(_on_velocity_computed)
	currentSpeed = WANDERING_SPEED
	# Access the Navigation Map
	nav_map = NavigationServer3D.map_create()
	NavigationServer3D.map_set_active(nav_map, true)
	NavigationServer3D.map_changed.connect(_on_navigation_ready)

func _on_navigation_ready(_map_id: RID):
	if _map_id == nav_map:
		navigation_ready = true

func _physics_process(delta: float) -> void:
	if Global.stone_rune_pickUp:
		
		roar_timer -= delta  # Decrease roar timer
		# Play roar randomly
		if roar_timer <= 0.0 and !roar.is_playing():
			roar.play()
			roar_timer = randf_range(2.0, 20.0)
		if !navigation_ready:
			return

		# Apply gravity
		if !is_on_floor():
			velocity.y -= gravity * delta
		
		# Decrease sound cooldown timer
		sound_cooldown_timer = max(sound_cooldown_timer - delta, 0.0)

		# Check if the player is within detection radius
		if character_in_detection_radius():
			if currentState != State.CHASING:
				currentState = State.CHASING
				chase_timer = CHASE_TIMEOUT  # Reset chase timer
		else:
			# Switch to wandering if player is out of detection range or unreachable
			if currentState == State.CHASING:
				currentState = State.WANDERING
				idle_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)

		# Process state-specific logic
		if nav.is_navigation_finished() or has_state_changed():
			match currentState:
				State.CHASING:
					chase(delta)
				State.WANDERING:
					wandering(delta)
				State.IDLE:
					idle(delta)

		# Update velocity based on navigation target
		if nav.is_navigation_finished():
			velocity.x = 0.0
			velocity.z = 0.0
		else:
			var direction = (nav.get_next_path_position() - global_position).normalized()
			velocity = velocity.lerp(direction * currentSpeed, delta * 10)
			rotate_toward_target(nav.get_next_path_position(), delta)
		
		# Consolidate velocity adjustment
		_on_velocity_computed(velocity)

# Wandering state logic
func wandering(delta: float):
	animation_tree.set("parameters/State/transition_request", "Walk")
	
	var next_position = nav.get_next_path_position()
	if global_position.is_equal_approx(next_position):
		return
	rotate_toward_target(next_position, delta)
	if nav.is_navigation_finished() or !nav.is_target_reachable():
		var new_target = randomPositionAroundPlayer()
		nav.set_target_position(new_target)

	if character_in_detection_radius():
		currentState = State.CHASING
		chase_timer = CHASE_TIMEOUT  # Start the chase timer

	
	currentSpeed = WANDERING_SPEED

func chase(delta: float):
	if character == null:
		push_error("Character reference is null in 'chase' function.")
		return

	animation_tree.set("parameters/State/transition_request", "Chasing")
	if !$Chase.is_playing():
		$Chase.play()

	currentSpeed = CHASING_SPEED

	var player_position = character.global_position

	# Temporarily set the target position to the player's position
	nav.set_target_position(player_position)

	# Check if the player's position is reachable
	if !nav.is_target_reachable():
		chase_timer -= delta  # Reduce the chase timer if the target is unreachable
		if chase_timer <= 0.0:
			currentState = State.WANDERING
			idle_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
		return  # Exit the chase function

	# Smoothly rotate towards the player
	rotate_toward_target(player_position, delta)

	# Countdown the chase timer
	chase_timer -= delta

	# Switch to wandering if chase timeout is reached or path is finished
	if nav.is_navigation_finished() or chase_timer <= 0.0:
		currentState = State.WANDERING
		idle_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)





# Idle state logic with a single target rotation
func idle(delta: float):
	
	animation_tree.set("parameters/State/transition_request", "Idle")
	roar.play()
	# Stop movement completely during idle state
	velocity = Vector3.ZERO
	_on_velocity_computed(velocity)  # Ensure velocity is reset

	idle_timer -= delta
	if idle_timer <= 0.0:
		currentState = State.WANDERING
		idle_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)

# Smooth rotation towards a target position
func rotate_toward_target(target_position: Vector3, delta: float) -> void:
	var direction = (target_position - global_position).normalized()
	var target_angle = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, ROTATION_SPEED * delta)

# Check if the player is within detection range
func character_in_detection_radius() -> bool:
	return global_position.distance_to(character.global_position) <= DETECTION_RADIUS

# Generate a random wandering target position around the player
func randomPositionAroundPlayer() -> Vector3:
	var new_target: Vector3
	while true:
		var random_angle = randf_range(0, 2 * PI)
		var random_distance = randf_range(10, WANDER_RADIUS)
		var random_offset = Vector3(cos(random_angle), 0, sin(random_angle)) * random_distance
		new_target = character.global_position + random_offset
		nav.set_target_position(new_target)  # Set the target position
		if nav.is_target_reachable():  # Check if the target is reachable
			break
	return new_target

# Handle sound detection and move towards sound source
func _on_mic_frequency_check_way_too_loud(sound_source_position: Vector3) -> void:
	if sound_cooldown_timer <= 0.0 and currentState != State.CHASING:
		nav.set_target_position(sound_source_position)
		rotate_toward_target(sound_source_position, 0.016)  # Approximate delta for instant rotation
		currentState = State.CHASING
		chase_timer = CHASE_TIMEOUT  # Start the chase timer
		sound_cooldown_timer = SOUND_COOLDOWN

# Handle velocity computation for movement
func _on_velocity_computed(p_safe_velocity: Vector3) -> void:
	velocity.x = p_safe_velocity.x
	velocity.z = p_safe_velocity.z
	velocity.y = p_safe_velocity.y
	move_and_slide()

# Check if the state has changed
func has_state_changed() -> bool:
	if previousState != currentState:
		previousState = currentState  # Update previous state to current
		return true
	return false

# Handle player kill and stop movement during killing animation
func _on_player_die_body_entered(body: Node3D) -> void:
	if body == Global.player:
		animation_tree.set("parameters/AttackFire/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		emit_signal("killPlayer")
		$Attack.play()
		Global.isDead = true
		_on_velocity_computed(Vector3.ZERO)
