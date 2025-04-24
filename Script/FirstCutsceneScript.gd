extends Node3D

@onready var head = %Head
@onready var eyes = %Eyes
@onready var animation_player: AnimationPlayer = $MoveableScene/Boat_RigidBody/Head/Eyes/Camera3D/Control/AnimationPlayer
@onready var moveable_scene = $MoveableScene
@export var dialogue: DialogueResource
var mouse_sens = 0.2
@export var speed = 1.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DialogueManager.show_dialogue_balloon(load("res://Assets/dialogue/FirstCutScene.dialogue"), "First_cutscene")

func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotation.y = clamp(head.rotation.y, deg_to_rad(-30), deg_to_rad(30))
		eyes.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		eyes.rotation.x = clamp(eyes.rotation.x, deg_to_rad(-10), deg_to_rad(40))

func _process(delta):
	# Calculate forward direction (negative Z-axis in Godot)
	var forward_direction = -transform.basis.z
	moveable_scene.translate(forward_direction * speed * delta)


func end_part():
	animation_player.play("End_of_cutscene")
	await animation_player.animation_finished
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	add_child(LoadingScene.create_loader("res://Scene/node_3d.tscn"))

func _on_end_of_ocean_body_entered(_body: Node3D) -> void:
	get_tree().reload_current_scene()
