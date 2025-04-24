extends Interactable
var player_in_area = false
@export var Book_Content : String
@export var dialouge_script : String


func _process(_delta: float) -> void:
	var savefile = SaveData.new()
	if Book_Content in savefile.bookList:
		queue_free()
		return
	if player_in_area and Input.is_action_just_pressed("interaction"):
		DialogueManager.show_dialogue_balloon(load("res://Assets/dialogue/"+dialouge_script+".dialogue"), Book_Content)
		savefile.add_books(Book_Content)
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:  # Same here for consistency
		player_in_area = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:  # Same here for consistency
		player_in_area = false
