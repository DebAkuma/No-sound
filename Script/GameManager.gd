extends Node
class_name GameManager

@onready var death_scene: Control = $"../PlayerUI/DeathScene"
@onready var world_boundary = %WorldBoundary
@export var enemy: CharacterBody3D
@onready var player_ui: CanvasLayer = $"../PlayerUI"
@export var Chracter: CharacterBody3D
@onready var starting_area_access: StaticBody3D = %Starting_Area_Access

func _ready() -> void:
	if Global.LoadGame:
		await get_tree().create_timer(1.0).timeout
		loadGame()
	else :
		await get_tree().create_timer(1.0).timeout
		DialogueManager.show_dialogue_balloon(load("res://Assets/dialogue/Quest_line.dialogue"), "afterentringisland")
func _process(_delta: float) -> void:
	if Global.stone_rune_pickUp:
		$"../Starting_Area_Access/CollisionShape3D".disabled = true
		

func _on_world_boundary_body_entered(body):
	if body == Global.player :
		Global.isDead = true
		death_scene.visible = true
		death_scene.enter()

func _on_enemy_kill_player() -> void:
	Global.isDead = true
	Chracter.look_at(enemy.global_transform.origin,Vector3.UP)
	death_scene.visible = true
	death_scene.enter()

func loadGame():
	var save_file = game_data_saver.new()
	save_file.load_game()
	Global.enemy.global_position = save_file.datasave.enemy_pos
	Global.enemy.global_rotation = save_file.datasave.enemy_rotation
	Global.player.global_position = save_file.datasave.player_pos
	Global.player.global_rotation = save_file.datasave.player_rotation
	Global.stone_rune_pickUp = save_file.datasave.stone_rune_pickUp
	Global.questTitle = save_file.datasave.SDquestTitle
	Global.questDetails = save_file.datasave.SDquestDetails
	Global.isDead = false
	Global.items = save_file.datasave.items
	Global.bookList = save_file.datasave.bookList
	Global.firstGemStone = save_file.datasave.firstGemStone
func Update_quest(questT:String , questD:String):
	Global.questTitle = questT
	Global.questDetails = questD 
