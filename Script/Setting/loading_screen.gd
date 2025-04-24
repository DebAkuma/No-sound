class_name LoadingScene
extends Node

static var LOADING_DIALOG = load("res://Scene/middle_screen.tscn")

static func create_loader(scenePath):
	var obj = LOADING_DIALOG.instantiate()
	obj.scene_to_load = scenePath
	return obj

var scene_to_load: String
var progress: Array = [0.0]  # Initialize with a default progress value

@onready var progress_bar: TextureProgressBar = $VBoxContainer/TextureProgressBar
@onready var tips_heading: Label = $VBoxContainer/TipsHeading
@onready var tips_labels: Label = $VBoxContainer/TipsLabels


var current_category = "lore"  # Start with lore tips; this could alternate each time
# Timer variable for debounce
var tip_timer: float = 0.0
const TIP_COOLDOWN: float = 1.0  # Cooldown time in seconds

# Define Lore Tips
var LoreTips = [
	{"heading": "Twisted Origins", "tip": "They say the creature was once human, twisted by rage and sorrow."},
	{"heading": "Forgotten Magic", "tip": "Ancient runes are said to repel the creature, but no one knows if they still work."},
	{"heading": "Unseen Hunters", "tip": "Many brave hunters entered these islands before you... none have ever returned."},
	{"heading": "Veil of Fog", "tip": "The fog wasn’t always here. It’s believed to be a veil between realms."}
]

# Define Gameplay Tips
var GameplayTips = [
	{"heading": "Move with Caution", "tip": "Move slowly to avoid alerting the creature to your presence."},
	{"heading": "Think Fast, Hide Faster", "tip": "Hiding spots aren’t always safe for long – plan your moves carefully."},
	{"heading": "Energy is Survival", "tip": "Keep an eye on your stamina; running drains it quickly."},
	{"heading": "Gather What You Can", "tip": "Collect gem-stones as quickly as possible; they might be your only means of defense."}
]

func _ready():
	print_tips()
	ResourceLoader.load_threaded_request(scene_to_load)


func show_progress(value):
	progress_bar.value = value * 100
	# Update shader parameter in the progress bar's material if it exists
	if progress_bar.material is ShaderMaterial:
		var shader_material = progress_bar.material as ShaderMaterial
		shader_material.set_shader_parameter("percentage", value)

func _process(delta):
	loading_interactive(delta)
	var load_status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)
	match load_status:
		0, 2:
			show_progress(progress[0])
		1:
			show_progress(progress[0])
		3:
			show_progress(progress[0])
			var load_resource = ResourceLoader.load_threaded_get(scene_to_load)
			get_tree().change_scene_to_packed(load_resource)
			queue_free()

func print_tips():
	var tip_info = get_random_tip(current_category)
	if tip_info.size() > 0:
		tips_heading.text = tip_info["heading"]
		tips_labels.text =  tip_info["tip"]
	
	# Alternate the category for the next tip
	if current_category == "lore":
		current_category = "gameplay"
	else:
		current_category = "lore"

func loading_interactive(delta):
	# Update the tip_timer by delta and check if it has reached the cooldown time
	tip_timer += delta
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and tip_timer >= TIP_COOLDOWN:
		print_tips()
		tip_timer = 0.0  # Reset the timer after showing a tip

func get_random_tip(category: String) -> Dictionary:
	if category == "lore":
		return LoreTips[randi() % LoreTips.size()]
	elif category == "gameplay":
		return GameplayTips[randi() % GameplayTips.size()]
	return {}
