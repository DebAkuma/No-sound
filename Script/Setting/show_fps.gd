extends Label


func _process(_delta):
	
	if SettingConfig.game_data.show_fps:
		text = "FPS: %d" % Engine.get_frames_per_second()
	else:
		text = ""
