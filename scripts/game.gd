extends Control

@onready var grid : GridContainer = $GridRect/Centercontainer/GridContainer
@onready var turn_label : Label = $LabelContainer/TurnLabel
@onready var game_over_dialog : ConfirmationDialog = $GameOverDialog
@onready var pressing_sound : AudioStreamPlayer = $PressingSound
@onready var winning_sound : AudioStreamPlayer = $WinningSound
@onready var buttons = grid.get_children()

enum State {EMPTY, CIRCLE, CROSS}

var matrix = [
	[State.EMPTY, State.EMPTY, State.EMPTY],
	[State.EMPTY, State.EMPTY, State.EMPTY],
	[State.EMPTY, State.EMPTY, State.EMPTY],
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

func _button_pressed(button: Button, column: int, row: int):
	if matrix[row][column]!=State.EMPTY:
		return
	
	button.text = "X" if cross_turn else "O"
	matrix[row][column] = State.CROSS if cross_turn else State.CIRCLE
	pressing_sound.play()
	
	if check_winner(column, row):
		game_over(false)
		return
	#elif State.EMPTY not in matrix:	
	elif !matrix.any(func(arr): return State.EMPTY in arr):
		game_over(true)
		return
	
	change_turn()
	
	if GlobalScript.one_player_mode && !cross_turn:
		bot_move()
	
	
func check_winner(column: int, row: int) -> bool:
	var state_to_look_for = matrix[row][column]
	return winner_in_row_or_column(state_to_look_for, column, row) || winner_in_diagonals(state_to_look_for)
	

func winner_in_row_or_column(state_to_look_for: State, column: int, row: int) -> bool:
	var currIndex = 0
	var three_in_col : bool = true
	var three_in_row : bool = true
	
	while currIndex<matrix[0].size():
		if matrix[row][currIndex] != state_to_look_for:
			three_in_col = false
			
		if matrix[currIndex][column] != state_to_look_for:
			three_in_row = false
		
		currIndex+=1
		
	return three_in_col || three_in_row
		
		
func winner_in_diagonals(state_to_look_for: State) -> bool:
	var currCol = 0
	var currRow = 0
	var currRow2 = matrix.size() -1
	
	var made_first_diag = true
	var made_second_diag = true
	
	while currCol<matrix.size() && currRow<matrix.size():
		if matrix[currRow][currCol] != state_to_look_for:
			made_first_diag = false
		
		if matrix[currRow2][currCol] != state_to_look_for:
			made_second_diag = false
			
		currCol+=1
		currRow+=1
		currRow2-=1

	return made_first_diag || made_second_diag
		
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
	bot_normal_move()
	
func bot_easy_move():
	var valid_move = false
	while not valid_move:
		var row = randi_range(0, 2)
		var col = randi_range(0, 2)
		if matrix[row][col] == State.EMPTY:
			#matrix[row][col] = State.CIRCLE
			valid_move = true
			var buttons_index = (row * 3) + col
			var chosen_button = buttons[buttons_index]
			_button_pressed(chosen_button, col, row)

func bot_normal_move():
	pass

#back button event
func _notification(what: int) -> void:
	match what:
		1007:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_back_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
