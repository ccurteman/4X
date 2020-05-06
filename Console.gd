extends Control
# Prototype for 4X style boardgame mechanics
# Everything is thrown into this one big file
# The game is played in turns, thus there is no need to call physics_process or process


# Resource Piles
export var crude_oil_pile := 100
export var copper_ore_pile := 100
export var cotton_pile := 100
export var fat_pile := 100
export var flour_pile := 100
export var food_pile := 100
export var gold_pile := 100
export var grain_pile := 100
export var iron_ore_pile := 100
export var lead_ore_pile := 100
export var leather_pile := 100
export var lumber_pile := 100
export var meat_pile := 100
export var ore_pile := 100
export var pickaxe_pile := 100
export var plow_pile := 100
export var stone_pile := 100
export var tin_ore_pile := 100
export var total_population := 100
export var woodaxe_pile := 100
export var wood_pile := 1000

# Tiles
export var exploited_forests := 0
export var exploited_mines := 0
export var exploited_farms := 0
export var exploited_oil_fields := 0

# Worker Management
export var workers := 100
export var lumberjacks := 100
export var carpenters := 100
var idle_workers_array : Array
var idle_carpenters_array : Array
var idle_lumberjacks_array : Array

# Crafting
export var wood_to_lumber_ratio := 10

# Time
export var worker_to_carpenter_train_time := 1
export var worker_to_lumberjacks_train_time := 1
export var start_year := 0
export var max_years_allowed := 30
export var seasons_list : Dictionary = {
	0: "Spring",
	1: "Summer",
	2: "Fall",
	3: "Winter"
}
var current_season_key := 0
var current_year := 1
var turn_counter := 0

# Interface Only
var actions_array : Array

# Ready Dependent Variables
onready var temp_carpenters = carpenters
onready var temp_workers = workers



#####----- BUILT-IN FUNCTIONS -----#####
func _ready():
	Check_Actions()
	Begin_Turn()


func _init() -> void:
	pass



#####-----  CUSTOM FUNCTIONS -----#####
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
	# First we check if there are any win conditions or lose conditions that have been met
	if current_year > max_years_allowed:
		$"Temp Win Popup".visible = true

	# If the player hasn't won, the turn begins
	else:
		# We want to change to the next season on a new turn
		# But first we need to check if the season key is 3
		# If it is, then we are going to start back at 0 and increment the year, else we increment it by 1
		if current_season_key == 3:
			current_season_key = 0
			current_year += 1
		else:
			current_season_key += 1

		# Next are aim is going to shift to checking what resources we are exploiting
		if exploited_forests > 0:
			wood_pile += exploited_forests * 100

		# We need to update the turn counter to keep track of how many turns have past
		turn_counter += 1

		# Now we are going to update every element on the interface that tracks information per turn
		$"Turn Counter".text = "Turn " + str(turn_counter)
		$"Year Counter".text = "Year " + str(current_year)
		$"Season Counter".text = seasons_list.get(current_season_key)
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

# Factory pattern based crafting function. This function takes items, ratio, and number of workers to craft what is being passed to it.
func Craft_Factory(item_being_used, item_being_made, ratio, required_number_of_workers):
	print(item_being_used, ratio, required_number_of_workers)
	match item_being_made:
		"Lumber":
			Log_Action("Crafting Lumber")




#####----- SIGNAL CONNECTIONS -----#####
func _on_End_Turn_pressed():
	Execute_Actions()
	Begin_Turn()
	$"Item List".clear()

	Log_Action("Turn " + str(turn_counter) + " has ended.")

# This function is called when an order is selected in the item list
func _on_Item_List_item_selected(_index):
	$"Remove".disabled = false

	Log_Action("A item was selected on the item list")

# --- Worker Management --- #
func _on_Train_Carpenter():
	if workers >= 1:
		workers -= 1
		carpenters += 1
	$"Carpenters".text = "Carpenters " + str(carpenters)
	$"Workers".text = "Workers " + str(workers)

	Log_Action("A Carpenter was trained.")

func _on_Train_Lumberjack():
	# We want players to instantly change worker values
	# But first we check there is atleast one worker
	if workers >= 1:
		workers -= 1
		lumberjacks += 1
	$"Lumberjacks".text = "Lumberjacks " + str(lumberjacks)
	$"Workers".text = "Workers " + str(workers)

	Log_Action("A Lumberjack was trained.")

func _on_Demote_Lumberjack() -> void:
	if lumberjacks >= 1:
		workers += 1
		lumberjacks -= 1
	$"Lumberjacks".text = "Lumberjacks " + str(lumberjacks)
	$"Workers".text = "Workers " + str(workers)
	Log_Action("A Lumberjack was demoted.")

func _on_Demote_Carpenter() -> void:
	if carpenters >= 1:
		workers += 1
		carpenters -= 1
	$"Carpenters".text = "Carpenters " + str(carpenters)
	$"Workers".text = "Workers " + str(workers)

	Log_Action("A carpenter was demoted to worker")


# --- Game State --- #
func _on_Restart_pressed() -> void:
	$"Restart Confirmation".visible = true

func _on_Restart_Confirmation_confirmed() -> void:
	Restart_Game()

func _on_Remove_Selected_Order() -> void:
	var selected_items = $"Item List".get_selected_items()
	for order_key in selected_items:
		$"Item List".remove_item(order_key)

	Log_Action("Order to remove an action from the order queue was made.")

# This function handles all the logic related to exploiting a forest tile
func _on_Exploit_Forest_pressed() -> void:
	exploited_forests += 1
	$"Item List".add_item("Start Forest Exploit")
	$"Available Resources/Forest".text = "Forests - " + str(exploited_forests)
	Log_Action("Order to start exploiting a forest was made.")
