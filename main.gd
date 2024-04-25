extends Node
@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

var player: int
var moves: int
var temp_marker
var player_panel_pos: Vector2i
var grid_data: Array
var grid_pos: Vector2i
var board_size: int
var cell_size: int

var row_sum: int
var col_sum: int
var diagonal_1: int
var diagonal_2: int
var winner: int

# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = $Board.texture.get_width()
	# Divide board size by 3 to get size of individual cells
	cell_size = board_size / 3
	# Get coordnates of panel to show next player
	player_panel_pos = $PlayerPanel.get_position()
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.position.x < board_size:
				# Convert mouse position into grid position
				grid_pos = Vector2i(event.position / cell_size)
				if grid_data[grid_pos.y][grid_pos.x] == 0:
					moves += 1
					grid_data[grid_pos.y][grid_pos.x] = player
					create_marker(player, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
					# EndGame Call Here
					if not end_game():
						player *= -1
						temp_marker.queue_free()
						create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
				print(grid_data) 

func end_game():
	if check_win() != 0:
		get_tree().paused = true
		$GameOverMenu.show()
		if winner == 1:
			$GameOverMenu.get_node("ResultLabel").text = "Player 1 Wins" 
		elif winner == -1:
			$GameOverMenu.get_node("ResultLabel").text = "Player 2 Wins" 
		return true
	
	if moves >= 9:
		get_tree().paused = true
		$GameOverMenu.show() 
		$GameOverMenu.get_node("ResultLabel").text = "It's a tie" 						
		return true
	
	return false

func new_game():
	player = 1
	moves = 0
	winner = 0
	grid_data = [ 
		[0, 0, 0], 
		[0, 0, 0], 
		[0, 0, 0] 
	]
	row_sum = 0
	col_sum = 0
	diagonal_1 = 0
	diagonal_2 = 0
	# Clear existing markers
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	# create a marker to show strating players turn
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true )
	$GameOverMenu.hide()
	get_tree().paused = false
	
func create_marker(player, position, temp=false)	:
	# Create a marker tnode added as a child to Main
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
	if player == -1:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp: temp_marker = cross
		
func check_win():
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal_1 = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal_2 = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		
		if row_sum == 3 or col_sum == 3 or diagonal_1 == 3 or diagonal_2 == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal_1 == -3 or diagonal_2 == -3:
			winner = -1
	
	return winner	


func _on_game_over_menu_restart():
	new_game()
	
