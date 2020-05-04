extends Control
# Prototype for 4X style boardgame mechanics
# Everything is thrown into this one big file
# If development is to move forward past Monday, May 4th, 2020, refactoring will take place
# The game is played in turns, thus there is no need to call physics_process or process


# Exported Variables
export var wood_to_lumber_ratio := 10
export var wood_pile := 1000
export var lumber_pile := 0
export var workers := 10
export var carpenters := 0
export var worker_to_carpenter_train_time := 1
export var lumberjacks := 0
export var worker_to_lumberjacks_train_time := 1
export var start_year := 0
export var exploited_forests := 0

# Private Variables
var current_year := 1
var actions_array : Array

# Ready Dependent Variables
onready var temp_carpenters = carpenters
onready var temp_workers = workers



# ---  BUILT-IN FUNCTIONS  --- #
func _ready():
	Check_Actions()
	Begin_Turn()


func _init() -> void:
	pass



# ---  CUSTOM FUNCTIONS  --- #
# Takes in a string and prints it to the log. The action parameter will be converted to type string before being logged.
func Log_Action(action):
	$"Log/Log Text Line".insert_text_at_cursor(str(action) + "\n")


# Checks every action in the game to see validate if said action.
func Check_Actions():
	if wood_pile < wood_to_lumber_ratio:
		$"Convert Wood to Lumber".disabled = true
	else:
		$"Convert Wood to Lumber".disabled = false


# Adds the action parameter to the action queue, and logs that action into the interface.
func Add_Action(action):
	$"Item List".add_item(str(action))

	# Log the order
	Log_Action(str(action))


# This function handles updating the interface, usually after Execute_Actions has been called.
func Begin_Turn():
	# Update Interface with new counts
	$"Year Counter".text = "Year " + str(current_year)
	# $"Item List".add_item("Test Order")
	$"Wood".text = "Wood " + str(wood_pile)
	$"Lumber".text = "Lumber " + str(lumber_pile)
	$"Workers".text = "Workers " + str(workers)
	$"Carpenters".text = "Carpenters " + str(carpenters)


# Execute_Actions takes the action_array and uses it to execute the actions
func Execute_Actions():
	# Loop through each action and make that function call
	for action in actions_array:
		# First we are going to log that this action is being called
		Log_Action(action)

		# The name of the order will be the name of the function, we use call() to execute the function of that action
		call(action)


# This function is usually called by Execute_Actions. It takes in a parameter, wood, and converts it into lumber at wood_to_lumber_ratio
func Make_Lumber(wood):
	var total_lumber_made = round(wood / wood_to_lumber_ratio)
	wood_pile -= wood
	lumber_pile += total_lumber_made


# This function is usually called by Execute_Actions. It takes a parameter, total_workers, and
func Train_Carpenters(total_workers):
	# Validate that there are workers to convert
	if total_workers < workers:
		workers -= total_workers


# Restart_Game will reset all the piles, exploited tiles, log contents and year to their default values and start the turn.
func Restart_Game():
	# Set all the resources back to 0
	wood_pile = 0
	lumber_pile = 0
	workers = 10
	carpenters = 0
	current_year = 1
	$"Item List".clear()
	Begin_Turn()

	

# ---  SIGNAL CONNECTIONS  --- #
func _on_End_Turn_pressed():
	print("Turn Ended")
	current_year += 1
	Execute_Actions()
	Begin_Turn()
	$"Item List".clear()


func _on_Item_List_item_selected(_index):
	$"Up".disabled = false
	$"Down".disabled = false
	$"Delete".disabled = false


func _on_Convert_Worker__Carpenter_pressed():
	# Checking if there are any available workers
	if workers > 0:
		# Adding Actions to the Queue
		Add_Action("train_carpenters")

		# Removing 1 workers for 1 carpenter and updating console
		temp_workers -= 1
		$"Workers".text = "Workers " + str(workers)

		# Adding 1 carpenter for 1 worker and updating console
		temp_carpenters += 1
		$"Carpenters".text = "Carpenters " + str(carpenters)


func _on_Convert_Worker_to_Lumberjack_pressed():
	# We want to queue the order into the Add_Action so it will be executed on turn
	Add_Action("Make_Lumberjack")


func _on_Restart_pressed() -> void:
	$"Restart Confirmation".visible = true


func _on_Restart_Confirmation_confirmed() -> void:
	Restart_Game()


