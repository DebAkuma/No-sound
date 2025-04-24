extends Interactable
var player_in_area = false



func _process(_delta: float) -> void:
	var savefile = SaveData.new()
	if savefile.stone_rune_pickUp:
		queue_free()
		
	if player_in_area and Input.is_action_just_pressed("interaction"):
		Global.stone_rune_pickUp = true
		DialogueManager.show_dialogue_balloon(load("res://Assets/dialogue/Quest_line.dialogue"), "AboutStoneRune")
		savefile.add_items("Stone Rune")
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:  # Same here for consistency
		player_in_area = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:  # Same here for consistency
		player_in_area = false
