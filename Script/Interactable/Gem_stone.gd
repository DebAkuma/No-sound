extends Interactable

var player_in_area = false
@warning_ignore("unused_signal")
signal pickUPItem

func _process(_delta: float) -> void:
	var savefile = SaveData.new()
	if message in savefile.items:
		queue_free()
		return
	if player_in_area and Input.is_action_just_pressed("interaction"):
		savefile.add_items(message)
		emit_signal("pickUPItem")
		if Global.firstGemStone:
			Global.firstGemStone = false
			DialogueManager.show_dialogue_balloon(load("res://Assets/dialogue/Quest_line.dialogue"), "afterPickingFirstGemstone")
		queue_free()


func _on_body_entered(body) -> void:
	if body is Player:  # Same here for consistency
		player_in_area = true


func _on_body_exited(body) -> void:
	if body is Player:  # Same here for consistency
		player_in_area = false
