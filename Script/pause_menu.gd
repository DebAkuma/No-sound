extends Control
@onready var tab_container = %TabContainer
@onready var animation_player = %AnimationPlayer
@onready var saving: Label = $Saving
@onready var itemList = preload("res://Scene/iteam_list.tscn")
@onready var iteam_box: VBoxContainer = $PanelContainer/TabContainer/Options/IteamBox

@export var player : CharacterBody3D
@export var enemy : CharacterBody3D

var save_data_instance = SaveData.new()

@onready var mission_title: Label = %MissionTitle
@onready var mission_desciption: Label = %MissionDesciption


func _ready() -> void:
	create_item_list()

func _process(_delta):
	updateQuest()
	create_item_list()
	if !Global.isDead:
		pause_menu()
		

func resume():
	get_tree().paused = false
	tab_container.current_tab = 0
	animation_player.play_backwards("Blur")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	
func pause():
	get_tree().paused = true
	animation_player.play("Blur")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	
func main_menu():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE




func pause_menu():
	if Input.is_action_just_pressed("Pause_menu"):
		if !get_tree().paused:
			pause()
		elif get_tree().paused:
			resume()
	elif Global.isDead :
		pass
	
func _on_resume_pressed():
	resume()


func _on_quit_pressed():
	get_tree().quit()


func _on_save_game_pressed():
	saving.visible = true
	animation_player.play("Saving")
	var save_file = game_data_saver.new()
	save_file.datasave.player_pos = player.global_position
	save_file.datasave.player_rotation = player.global_rotation
	save_file.datasave.stone_rune_pickUp = Global.stone_rune_pickUp
	save_file.datasave.items = Global.items
	save_file.datasave.bookList = Global.bookList
	save_file.datasave.enemy_pos = enemy.global_position
	save_file.datasave.enemy_rotation = enemy.global_rotation 
	save_file.datasave.SDquestTitle = Global.questTitle 
	save_file.datasave.SDquestDetails = Global.questDetails 
	save_file.datasave.firstGemStone = Global.firstGemStone
	save_file.save_game()
	
	await get_tree().create_timer(4.0).timeout
	_on_done_saving()

# Define what happens when the signal is emitted
func _on_done_saving():
	saving.visible = false
	animation_player.clear_queue()
	
	
	
func _on_load_game_pressed():
	var save_file = game_data_saver.new()
	save_file.load_game()
	player.global_position = save_file.datasave.player_pos
	player.global_rotation = save_file.datasave.player_rotation
	Global.stone_rune_pickUp = save_file.datasave.stone_rune_pickUp
	Global.items = save_file.datasave.items
	enemy.global_position = save_file.datasave.enemy_pos
	enemy.global_rotation = save_file.datasave.enemy_rotation
	Global.questTitle = save_file.datasave.SDquestTitle
	Global.questDetails = save_file.datasave.SDquestDetails
	Global.isDead = false
	Global.bookList = save_file.datasave.bookList
	Global.firstGemStone = save_file.datasave.firstGemStone



func _on_main_menu_pressed():
	main_menu()
	Global.LoadGame = false
	add_child(LoadingScene.create_loader("res://Scene/StartingMenu.tscn"))

func create_item_list():
	# Clear out existing items from `iteam_box`
	for item in iteam_box.get_children():
		item.queue_free()
		
	# Get the item list array from the save_data_instance
	var items_array = Global.items
	var array_size = items_array.size()
	
	# Loop through each item in the array and create an instance
	for i in range(array_size):
		var item_name = items_array[i]
		var item_instance = itemList.instantiate() # Instantiate the ItemList scene
		
		# Assuming `ItemName` is a child node of `itemList`
		var item_name_label = item_instance.get_node("ItemName") # Use get_node if it's directly in the scene
		if item_name_label:
			item_name_label.text = item_name # Set the item's name
		
		iteam_box.add_child(item_instance) # Add the instance to item_box

func updateQuest():
	mission_title.text = Global.questTitle
	mission_desciption.text = Global.questDetails
	
