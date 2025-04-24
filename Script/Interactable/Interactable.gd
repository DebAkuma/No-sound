extends Area3D
class_name Interactable

@export var message = "Interact"
var key

func get_promt():
	var input_events = InputMap.action_get_events("interaction")
	var key_map : InputEvent = input_events[0]
	key = key_map.as_text().split(" ")[0]
	return message + "\n["+key+"]"

func pickUpSomeThing():
	# Delete the scene after pickup
	queue_free()
