class_name Player
extends CharacterBody3D

# Access variables
@onready var crouching_collision = $crouching_collision
@onready var standing_collision = $standing_collision
@onready var ray_cast_3d = $Checking_celling
@onready var mouse_sens = SettingConfig.game_data.mouse_sens
@onready var head = %Head
@onready var hand = %Hand
@onready var hunter = %hunter
@onready var stamina_bar = %StaminaBar
@onready var stamina_bar_2 = %StaminaBar2
@onready var animation_player: AnimationPlayer = $Head/AnimationPlayer
@onready var step_cast: ShapeCast3D = $StepCast
@onready var torch_fbx: Torch = $Head/Eyes/Hand/torch_FBX



# Constant variables
const WALKING_SPEED = 5.0
const RUNNING_SPEED = 10.0
const CROUCH_SPEED = 3.0
const JUMP_VELOCITY = 4
const MAX_STAMINA = 100.0
const SPRINT_STAMINA_COST = 20.0  # Stamina cost per second
const STAMINA_RECOVERY_RATE = 10.0  # Stamina recovery per second
const STAMINA_RECOVERY_COOLDOWN = 2.0  # Cooldown in seconds
const CROUCH_Y = -0.5   # Crouch variables
const CROUCH_Z = -0.25

# Variables
var GameData = SaveData.new()
var lerp_speed = 10.0
var air_lerp_speed = 5.0
var current_speed = WALKING_SPEED
var last_velocity = Vector3.ZERO
var input_dir = Vector2.ZERO
var direction = Vector3.ZERO
var stamina = MAX_STAMINA
var stamina_recovery_timer = 0.1
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed_lerp_speed = 5.0
var flag = 0
var grounded = false
var isCrouching = false
var isCrouchWalking = false
var isSprinting = false
var isWalking = false

# Initialize the node, lock the mouse, and make it invisible
func _ready():
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
# Mouse movement and lock view angle
func _input(event):
	if event is InputEventMouseMotion:
		mouse_sens = SettingConfig.game_data.mouse_sens
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-50), deg_to_rad(40))

# Check per frame
func _physics_process(delta):
	if !Global.isDead:
		# Apply gravity if not on the floor
		if not is_grounded():
			velocity.y -= gravity * delta

	# Handle crouch & collision shape
		if Input.is_action_pressed("crouch") and is_grounded():
			flag +=1
			standing_collision.disabled = true
			crouching_collision.disabled = false
			isCrouching = true
			isWalking = false
			isSprinting = false
			current_speed = lerp(current_speed, CROUCH_SPEED, delta * lerp_speed)
			if flag == 1 :
				animation_player.play("StandToCrouch")
			if input_dir != Vector2.ZERO:
				isCrouchWalking = true
				hunter.crouchWalk_animations()
			else:
				isCrouchWalking = false
				hunter.crouchIdle_animation()
			
		elif !ray_cast_3d.is_colliding() and Input.is_action_just_released("crouch"):
			animation_player.play("CrouchToStand")
			standing_collision.disabled = false
			crouching_collision.disabled = true
			flag = 0
			
	
		elif Input.is_action_pressed("sprint") and is_grounded() and stamina > 0 and input_dir!= Vector2.ZERO:
			current_speed = lerp(current_speed, RUNNING_SPEED, delta * lerp_speed)
			isSprinting = true
			isCrouching = false
			isWalking = false
			isCrouchWalking = false
			stamina -= SPRINT_STAMINA_COST * delta
			stamina_recovery_timer = STAMINA_RECOVERY_COOLDOWN  # Reset the cooldown timer
			hunter.run_animations()
			stamina_bar.visible= true
			stamina_bar_2.visible = true
		elif is_grounded() and input_dir!= Vector2.ZERO or stamina == 0 :
			current_speed = lerp(current_speed, WALKING_SPEED, delta * lerp_speed)
			stamina_bar.visible= false
			stamina_bar_2.visible = false
			isWalking = true
			isSprinting = false
			isCrouching = false
			isCrouchWalking = false
			hunter.walk_animations()
		elif input_dir == Vector2.ZERO:
			hunter.idle_animations()
			isWalking = false
			isSprinting = false
			isCrouching = false
			isCrouchWalking = false
		
	
		# Handle jump
		if Input.is_action_just_pressed("jump") and is_grounded() and !ray_cast_3d.is_colliding() and not isCrouching:
			hunter.jump()
			velocity.y = JUMP_VELOCITY
		
	
		# Get the input direction and handle movement/deceleration
		input_dir = Input.get_vector("left", "right", "forward", "backward")
	
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * speed_lerp_speed)
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
		
	# Update stamina
		if not isSprinting and is_on_floor():
			if stamina <= 0:
				stamina_recovery_timer -= delta
				if stamina_recovery_timer <= 0:
					stamina += STAMINA_RECOVERY_RATE * delta
			else:
				stamina += STAMINA_RECOVERY_RATE * delta
				stamina = clamp(stamina, 0, MAX_STAMINA)
		stamina_bar.value = stamina
		stamina_bar_2.value = stamina
	
		last_velocity = velocity
	
		move(delta)
		if not Input.is_action_pressed("sprint") and is_grounded() :
			if stamina < MAX_STAMINA:
				stamina_recovery_timer -= delta
				if stamina_recovery_timer <= 0:
					stamina += STAMINA_RECOVERY_RATE * delta
				else:
					stamina += STAMINA_RECOVERY_RATE * delta
			stamina = clamp(stamina, 0, MAX_STAMINA)
		


func move(delta):
	step_cast.global_position.x = global_position.x + velocity.x * delta
	step_cast.global_position.z = global_position.z + velocity.z * delta
	
	if is_grounded():
		step_cast.target_position.y = -0.6
	
	else:
		step_cast.target_position.y = -0.5
		
		
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.exclude = [self]
	query.shape = step_cast.shape
	query.transform = step_cast.global_transform
	var result = get_world_3d().direct_space_state.intersect_shape(query,1)
	if !result :
		step_cast.force_shapecast_update()
	
	
	if step_cast.is_colliding() && velocity.y <= 0.0 && !result:
		global_position.y = step_cast.get_collision_point(0).y
		velocity.y = 0.0
		grounded = true
	else :
		grounded = false
	
	move_and_slide()

func is_grounded() -> bool:
	return grounded || is_on_floor()
