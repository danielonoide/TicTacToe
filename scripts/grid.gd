class_name Grid

static func is_full(matrix) -> bool:
	return !matrix.any(func(arr): return Game.State.NONE in arr)

static func to_single_coordinate(col: int, row: int) -> int:
	return (row * 3) + col

static func evaluate(matrix: Array, column: int, row: int) -> Game.State: #returns the winner
	#column and row mean the position of the last placed cross/circle
	var row_or_col = _winner_in_row_or_column(matrix, column, row)
	
	if row_or_col != Game.State.NONE:
		return row_or_col
	
	return _winner_in_diagonals(matrix)

static func _winner_in_row_or_column(matrix: Array, column: int, row: int) -> Game.State:
	var currIndex = 0
	var three_in_col : bool = true
	var three_in_row : bool = true
	
	var state_to_look_for : Game.State = matrix[row][column]
	
	while currIndex<matrix[0].size():
		if matrix[row][currIndex] != state_to_look_for:
			three_in_col = false
			
		if matrix[currIndex][column] != state_to_look_for:
			three_in_row = false
		
		currIndex+=1
		
	if three_in_col || three_in_row:
		return state_to_look_for
	
	return Game.State.NONE
		
		
static func _winner_in_diagonals(matrix: Array) -> Game.State:
	var currCol = 0
	var currRow = 0
	var currRow2 = matrix.size() -1
	
	var made_first_diag = true
	var made_second_diag = true
	
	var state_to_look_for : Game.State = matrix[currRow][currCol]
	var state_to_look_for2 : Game.State = matrix[currRow2][currCol]
		
	while currCol<matrix.size() && currRow<matrix.size():
		if matrix[currRow][currCol] != state_to_look_for:
			made_first_diag = false
		
		if matrix[currRow2][currCol] != state_to_look_for2:
			made_second_diag = false
			
		currCol+=1
		currRow+=1
		currRow2-=1

	if made_first_diag:
		return state_to_look_for
	
	if made_second_diag:
		return state_to_look_for2
	
	return Game.State.NONE
	
#The player is always the cross
#static func get_score(matrix: Array, cross_turn: bool) -> int: #devuelve el score de la jugada
	#var state_to_put = Game.State.CROSS if cross_turn else Game.State.CIRCLE
	#
	#var score = 1000 if cross_turn else -1000
	#
	#for row in range(matrix.size()):
		#for col in range(matrix[0].size()):
			#if matrix[row][col] == Game.State.NONE:
				#matrix[row][col] = state_to_put
				##print("GetScore. Turn: ", cross_turn, " Matrix: ", matrix)
				#
				#var winner = evaluate(matrix, col, row)
				#
				#if winner == Game.State.NONE and Grid.is_full(matrix):
					#return 0
				#elif winner != Game.State.NONE:
					#return winner
				#
				#var curr_score = get_score(matrix.duplicate(true), !cross_turn)
				#if cross_turn:
					#score = min(score, curr_score)
				#else:
					#score = max(score, curr_score)
				#
				#matrix[row][col] = Game.State.NONE
	##print("Score: ", score)
	#return score
	#
#static func minimax(matrix: Array, cross_turn: bool) -> int: #devuelve la mejor posición a jugar, de 0 al 8
	#var state_to_put = Game.State.CROSS if cross_turn else Game.State.CIRCLE
	#var max_score = -1000
	#var result = 0
	#var curr_score : int = 0
	#for row in range(matrix.size()):
		#for col in range(matrix[0].size()):
			#if matrix[row][col] == Game.State.NONE:
				#matrix[row][col] = state_to_put
				##print("Minimax. Turn: ", cross_turn, " Matrix: ", matrix)
				#curr_score = get_score(matrix.duplicate(true), !cross_turn)
				#
				#if curr_score > max_score:
					#max_score = curr_score
					#result = (row*3) +col
				#
				#matrix[row][col] = Game.State.NONE
	#
	#print("RESULT: ", result)
	#return result
	#

#El bot es MAX, es decir, el score a su favor es el mayor
#El bot usa los circulos
static func minimax(matrix: Array, cross_turn: bool, best_pos: Array) -> int: #devuelve la mejor posición a jugar, de 0 al 8 en el arreglo best_pos
	var state_to_put = Game.State.CROSS if cross_turn else Game.State.CIRCLE
	var score = 1000 if cross_turn else -1000
	for row in range(matrix.size()):
		for col in range(matrix[0].size()):
			if matrix[row][col] == Game.State.NONE:
				matrix[row][col] = state_to_put
				var winner = evaluate(matrix, col, row)
				
				if winner == Game.State.NONE and Grid.is_full(matrix): #empate
					return 0
				elif winner != Game.State.NONE:
					best_pos[0] = (row*3) + col
					return winner
				
				var curr_score = minimax(matrix.duplicate(true), !cross_turn, best_pos)
				if cross_turn:
					score = min(score, curr_score)
				elif curr_score > score:
					score = curr_score
					best_pos[0] = (row*3) + col
					#score = max(score, curr_score)
				
				matrix[row][col] = Game.State.NONE
	return score
	

	
