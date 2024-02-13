extends Control

@onready var game_mode_container = $ButtonsContainer/GameModeBTNs
@onready var difficulty_container = $ButtonsContainer/DifficultyBTNs

@onready var buttons_container = $ButtonsContainer


const CONTAINER_MOV = Vector2(1000, 0)
const CONTAINER_MOV_DUR = 0.5
var can_cancel = false
var can_press = true

func _ready():
	GlobalScript.game_music.stop()
	get_tree().set_quit_on_go_back(true)


func _on_one_player_btn_pressed():
	if !can_press:
		return

	var tween = create_tween()	
	tween.tween_property(buttons_container, "position", buttons_container.position-CONTAINER_MOV, CONTAINER_MOV_DUR)
	can_press = false
	difficulty_container.visible = true
	await get_tree().create_timer(CONTAINER_MOV_DUR).timeout
	game_mode_container.visible = false
	can_cancel = true

func _on_two_players_btn_pressed():
	change_scene("res://scenes/game.tscn", false)

func _on_easy_diff_btn_pressed():
	change_scene("res://scenes/game.tscn", true, true)

func _on_hard_diff_btn_pressed():
	change_scene("res://scenes/game.tscn", true, false)

func _on_cancel_btn_pressed():
	if !can_cancel:
		return
		
	var tween = create_tween()
	can_cancel = false
	tween.tween_property(buttons_container, "position", buttons_container.position+CONTAINER_MOV, CONTAINER_MOV_DUR)
	game_mode_container.visible = true
	await get_tree().create_timer(CONTAINER_MOV_DUR).timeout
	difficulty_container.visible = false
	can_press = true

func change_scene(scene_path: String, one_player_mode=false, easy_diff=true) -> void:
	GlobalScript.one_player_mode = one_player_mode
	GlobalScript.easy_diff = easy_diff
	get_tree().change_scene_to_file(scene_path)
