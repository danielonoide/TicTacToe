extends Node


var one_player_mode : bool = false
var easy_diff : bool = false

@onready var game_music = get_tree().root.get_node("/root/GlobalScene/GameMusic")

#func _ready():
	#match OS.get_name():
		#"Windows": 
