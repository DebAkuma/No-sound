extends Control
@onready var main_menu = %MainMenu
@onready var option_menu = %OptionMenu
@onready var setting_container = $OptionMenu/SettingContainer
@onready var play_button = $MainMenu/VBoxContainer/Play
@onready var load_game_button = $MainMenu/VBoxContainer/LoadGame
@onready var new_game_button = $MainMenu/VBoxContainer/NewGame
var path = "user://SaveGameData.dat"

func _ready():
	if FileAccess.file_exists(path):
		play_button.visible = false
		new_game_button.visible = true
		load_game_button.visible = true
	elif !FileAccess.file_exists(path):
		play_button.visible = true
		new_game_button.visible = false
		load_game_button.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("Pause_menu"):
		setting_container.current_tab = 0
		main_menu.visible = true
		option_menu.visible = false
		

func _on_play_pressed():
	add_child(LoadingScene.create_loader("res://Scene/first_cutscene.tscn"))
	

func _on_option_pressed():

	main_menu.visible = false
	option_menu.visible = true


func _on_exit_pressed():
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()



# Access back button in option menu
func _on_back_pressed():
	setting_container.current_tab = 0
	main_menu.visible = true
	option_menu.visible = false



func _on_load_game_pressed():
	add_child(LoadingScene.create_loader("res://Scene/node_3d.tscn"))
	Global.LoadGame = true
	

func _on_new_game_pressed():
	add_child(LoadingScene.create_loader("res://Scene/first_cutscene.tscn"))


	
