extends Node
class_name game_data_saver

var path = "user://SaveGameData.dat"


@export var datasave = SaveData.new()


func save_game():
	var game_dat = {
		"ibanvu9bj":datasave.to_data()
	}
	var byte_array =var_to_bytes(game_dat) 
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_buffer(byte_array)
	file.close()

func load_game():
	var file = FileAccess.open(path,FileAccess.READ)
	if file == null : return false
	
	var byte_array = file.get_buffer(file.get_length())
	var game_dat = bytes_to_var(byte_array)
	datasave.from_data(game_dat["ibanvu9bj"])
	file.close()
	return true
