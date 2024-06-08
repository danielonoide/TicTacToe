extends Control

class_name Game

@onready var grid : GridContainer = $GridRect/Centercontainer/GridContainer
@onready var turn_label : Label = $LabelContainer/TurnLabel
@onready var game_over_dialog : ConfirmationDialog = $GameOverDialog
@onready var pressing_sound : AudioStreamPlayer = $PressingSound
@onready var winning_sound : AudioStreamPlayer = $WinningSound
@onready var buttons = grid.get_children()

enum State {NONE = 0, CIRCLE = 1, CROSS = -1}

var matrix = [
	[State.NONE, State.NONE, State.NONE],
	[State.NONE, State.NONE, State.NONE],
	[State.NONE, State.NONE, State.NONE],
]

var cross_turn : bool = true

func _ready():
	initialize_buttons()
	if !GlobalScript.one_player_mode:
		choose_turn()
	change_turn_label()
	
	if !GlobalScript.game_music.is_playing():
		GlobalScript.game_music.play()
	
	#back button android
	get_tree().set_quit_on_go_back(false)

func choose_turn():
	var random = RandomNumberGenerator.new()
	var rand_num = random.randi_range(0,1)
	cross_turn = bool(rand_num)

func initialize_buttons():
	var currColumn = 0
	var currRow = 0
	
	for button in buttons:
		button.pressed.connect(_button_pressed.bind(button, currColumn, currRow))
		
		currColumn+=1
		
		if currColumn==3:
			currColumn = 0
			currRow+=1

func change_turn():
	cross_turn = !cross_turn
	change_turn_label()

func change_turn_label():
	if cross_turn:
		turn_label.text = "X turn"
	else:
		turn_label.text = "O turn"

func disable_buttons(disable: bool):
	for button in buttons:
		button.disabled = disable


func _button_pressed(button: Button, column: int, row: int):
	
	if matrix[row][column]!=State.NONE:
		return
	
	
	button.text = "X" if cross_turn else "O"
	matrix[row][column] = State.CROSS if cross_turn else State.CIRCLE
	pressing_sound.play()
	
	if Grid.evaluate(matrix, column, row) != State.NONE:
		game_over(false)
		return
	#elif State.NONE not in matrix:	
	elif Grid.is_full(matrix):
		game_over(true)
		return
	
	change_turn()
	
	if GlobalScript.one_player_mode:
		disable_buttons(!cross_turn)
		if !cross_turn:
			bot_move()
	
func game_over(tie: bool):
	game_over_dialog.show()
	
	if tie:
		game_over_dialog.title = "¡Empate!"
		return
	
	game_over_dialog.title = "¡X ha ganado!" if cross_turn else "¡O ha ganado!"
	winning_sound.play()

func _on_game_over_dialog_confirmed():
	get_tree().quit()

func _on_game_over_dialog_canceled():
	get_tree().reload_current_scene()

func bot_move():
	if GlobalScript.easy_diff:
		bot_easy_move()
		return
	bot_hard_move()
	
func bot_easy_move():
	var valid_move = false
	while not valid_move:
		var row = randi_range(0, 2)
		var col = randi_range(0, 2)
		if matrix[row][col] == State.NONE:
			#matrix[row][col] = State.CIRCLE
			valid_move = true
			var buttons_index = (row * 3) + col
			var chosen_button = buttons[buttons_index]
			_button_pressed(chosen_button, col, row)

func bot_hard_move():
	#var best_move = Grid.minimax(matrix.duplicate(true), false)
	var best_move = [0]
	Grid.minimax(matrix.duplicate(true), false, best_move)
	var row = best_move[0]/3
	var col = best_move[0]-row*3
	print("BEst MOVE: ", best_move[0], " row: ", row, " col: ", col)
	
	_button_pressed(buttons[best_move[0]], col, row)


#back button event
func _notification(what: int) -> void:
	match what:
		1007:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_back_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
