extends Control
var path = "user://SaveGameData.dat"

func enter():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if FileAccess.file_exists(path):
		$LoadGame.visible = true
	else:
		Global.items.clear()
		Global.stone_rune_pickUp = false
		Global.isDead = false
		$LoadGame.visible = false
		
func _on_main_menu_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	add_child(LoadingScene.create_loader("res://Scene/StartingMenu.tscn"))
	Global.isDead = false
	
func _on_load_game_pressed():
	var save_file = game_data_saver.new()
	save_file.load_game()
	Global.player.global_position = save_file.datasave.player_pos
	Global.player.global_rotation = save_file.datasave.player_rotation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.isDead = false
	self.visible = false

	
	
