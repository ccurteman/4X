extends Control
# Prototype for 4X style boardgame mechanics
# Everything is thrown into this one big file
# The game is played in turns, thus there is no need to call physics_process or process


# Conversion Factors
export var food_consumption_rate := 1
export var population_growth_factor := 10

# Resource Piles
export var crude_oil_pile := 100.0
export var copper_ore_pile := 100.0
export var cotton_pile := 100.0
export var fat_pile := 100.0
export var flour_pile := 100.0
export var food_pile := 1000.0
export var gold_pile := 100.0
export var grain_pile := 100.0
export var iron_ore_pile := 100.0
export var lead_ore_pile := 100.0
export var leather_pile := 100.0
export var lumber_pile := 100.0
export var meat_pile := 100.0
export var ore_pile := 100.0
export var pickaxe_pile := 100.0
export var plow_pile := 100.0
export var stone_pile := 100.0
export var tin_ore_pile := 100.0
export var woodaxe_pile := 100.0
export var wood_pile := 1000.0
export var bread_pile := 1000.0

# Tiles
export var exploited_forests := 0
export var exploited_mines := 0
export var exploited_farms := 0
export var exploited_oil_fields := 0

# Citizen Management
export var total_population : float = 100
var idle_workers_array : Array
var idle_carpenters_array : Array
var idle_lumberjacks_array : Array
export var workers := 10
export var lumberjacks := 10
export var carpenters := 10
export var miners := 0
var _worker_job_types := {
	0: "Unskilled",
	1: "Worker",
	2: "Lumberjack",
	3: "Miner",
	4: "Carpenter",
}

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
onready var combined_workers_and_population := workers + total_population + carpenters + lumberjacks

# Game State
var is_starving := false



#####----- BUILT-IN FUNCTIONS -----#####
func _ready():
	Update_Interface()


func _init() -> void:
	pass


#####-----  CUSTOM FUNCTIONS -----#####
# Update_Interface simply updates elements of the interface with new values
func Update_Interface():
	$"Turn Counter".text = "Turn " + str(turn_counter)
	$"Year Counter".text = "Year " + str(current_year)
	$"Season Counter".text = seasons_list.get(current_season_key)
	$"Wood".text = "Wood " + str(wood_pile)
	$"Lumber".text = "Lumber " + str(lumber_pile)
	$"Workers".text = "Workers " + str(workers)
	$"Carpenters".text = "Carpenters " + str(carpenters)
	$"Pop".text = "Pop - " + str(total_population)
	$"Food".text = "Food - " + str(food_pile)
	$"Flour".text = "Flour - " + str(flour_pile)
	$"Gold".text = "Gold - " + str(gold_pile)
	$"Iron Ore".text = "Iron Ore - " + str(iron_ore_pile)
	$"Lumberjacks".text = "Lumberjacks - " + str(lumberjacks)

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
	actions_array.append(action)

	# Log the order
	Log_Action(str(action) + " was added to the queue")


# This function handles updating the interface, usually after Execute_Actions has been called.
func Process_Turn():
	# First we check if there are any win conditions or lose conditions that have been met
	if current_year > max_years_allowed:
		$"Temp Win Popup".visible = true
		Restart_Game()

	# Now we are going to check if the population is starving
	# If it is, then we are going to subtract from the total population
	if is_starving:
		total_population = round(total_population / 2) - 1

	# If the player's population is below zero they lose the game
	if total_population <= 0:
		$"Lost Menu".visible = true
		Restart_Game()

	# If the player hasn't won, the turn begins
	else:
		# We'll call the Execute_Actions function to parse and process the orders queued up
		Execute_Actions()

		# Now that the actions have been executed, we are going to generate tax revenue
		Generate_Taxes()

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

		# Now we have updated exploited tiles, we look to updating the population
		# Population is being increased by a factor each turn
		if is_starving == false:
			total_population += population_growth_factor


		# With population taken care of, we are going to handle food math
		# Each population and worker consume food
		# We are using food_consumption_factor to determine the rate per citizen
		food_pile -= float(food_consumption_rate) * float(combined_workers_and_population)
		if food_pile < 0:
			is_starving = true
			food_pile = 0
		else:
			is_starving = false

		# Now we are going to update every element on the interface that tracks information per turn
		Update_Interface()


# Execute_Actions takes the action_array and uses it to execute the actions
func Execute_Actions():
	# Loop through each action and make that function call
	for action in actions_array:
		# First we are going to log that this action is being called
		Log_Action(str(action) + " is being executed")

		# The name of the action is used to match the function that will execute that action
		match action:
			"Craft Lumber":
				Craft_Factory(100, "Lumber", 0.1, 1)

			"Craft Grain":
				Craft_Factory(100, "Grain", 0.1, 1)

	# We have finished processing these actions so we clear them from the array and the interface
	$"Item List".clear()
	actions_array.clear()


# This function is going to handle generating resources for us from the tiles we are exploiting
func Exploit_Tiles():
	food_pile += exploited_farms * 50
	wood_pile += exploited_forests * 50
	iron_ore_pile += exploited_mines * 10
	stone_pile += exploited_farms * 5
	stone_pile += exploited_mines * 25
	stone_pile += exploited_forests * 1


# Restart_Game will reset all the piles, exploited tiles, log contents and year to their default values and start the turn.
func Restart_Game():
	# Set all the resources back to 0

	# Make sure exploits reset back to 0
	wood_pile = 0
	lumber_pile = 0
	workers = 10
	carpenters = 0
	current_year = 1
	pickaxe_pile = 0
	food_pile = 1000
	total_population = 100
	workers = 10
	carpenters = 10
	lumberjacks = 10
	miners = 10
	combined_workers_and_population = workers + total_population + carpenters + lumberjacks

	$"Item List".clear()
	Process_Turn()


# Factory pattern based crafting function. This function takes items, ratio, and number of workers to craft what is being passed to it.
func Craft_Factory(amount_being_used, item_being_made, ratio, required_number_of_workers):
	match item_being_made:
		"Lumber":
			if lumberjacks >= required_number_of_workers and wood_pile >= amount_being_used:
				var total_made = amount_being_used * ratio
				wood_pile = wood_pile - amount_being_used
				lumber_pile += total_made
				Log_Action("Crafted " + str(total_made) + " lumber")
			else:
				Log_Action ("You do not have enough lumberjacks or enough wood to do that.")

		"Grain":
			if grain_pile >= amount_being_used:
				var total_made = amount_being_used * ratio
				grain_pile = grain_pile - amount_being_used
				flour_pile += total_made
				Log_Action("Crafted " + str(total_made) + " flour")
			else:
				Log_Action("You do not have enough millers or enough grain to do that")

		"Bread":
			if flour_pile >= amount_being_used:
				var total_made = amount_being_used * ratio
				flour_pile = flour_pile - amount_being_used
				bread_pile += total_made
				Log_Action("Crafted " + str(total_made) + " bread")
			else:
				Log_Action("You do not have enough bakers or enough flour to do that")

		"Pickaxe":
			if iron_ore_pile >= amount_being_used / 2 and lumber_pile >= amount_being_used / 2:
				var total_made = amount_being_used * ratio
				iron_ore_pile = iron_ore_pile - (amount_being_used / 2)
				lumber_pile = lumber_pile - (amount_being_used / 2)
				pickaxe_pile += total_made
				Log_Action("Crafted " + str(total_made) + " pickaxes")
			else:
				Log_Action("You do not have enough blacksmiths or enough lumber or iron ore to do that")


func Generate_Taxes():
	var taxes = total_population * 10
	gold_pile += taxes

	Log_Action("Generated " + str(taxes) + " during turn " + str(turn_counter))


#####----- SIGNAL CONNECTIONS -----#####
func _on_End_Turn_pressed():
	Process_Turn()

	Log_Action("Turn " + str(turn_counter) + " has ended.")


# This function is called when an order is selected in the item list
func _on_Item_List_item_selected(_index):
	$"Remove".disabled = false

	Log_Action("A item was selected on the item list")


# --- Worker Management --- #
# When called, we use this function to promote workers into carpenters.
func _on_Train_Carpenter():
	if workers >= 1:
		workers -= 1
		carpenters += 1
	$"Carpenters".text = "Carpenters " + str(carpenters)
	$"Workers".text = "Workers " + str(workers)

	Log_Action("A Carpenter was trained.")


# When called, we use this function to promote workers into lumberjacks.
func _on_Train_Lumberjack():
	# We want players to instantly change worker values
	# But first we check there is atleast one worker
	if workers >= 1:
		workers -= 1
		lumberjacks += 1
	$"Lumberjacks".text = "Lumberjacks " + str(lumberjacks)
	$"Workers".text = "Workers " + str(workers)

	Log_Action("A Lumberjack was trained.")


# When called, we use this function to demote lumberjacks to workers.
func _on_Demote_Lumberjack() -> void:
	if lumberjacks >= 1:
		workers += 1
		lumberjacks -= 1
	$"Lumberjacks".text = "Lumberjacks " + str(lumberjacks)
	$"Workers".text = "Workers " + str(workers)
	Log_Action("A Lumberjack was demoted.")


# When called, we use this function to demote carpenters to workers.
func _on_Demote_Carpenter() -> void:
	if carpenters >= 1:
		workers += 1
		carpenters -= 1
	$"Carpenters".text = "Carpenters " + str(carpenters)
	$"Workers".text = "Workers " + str(workers)

	Log_Action("A carpenter was demoted to worker")


# --- Game State --- #
# This function is called when the player pressed the restart button, which then opens a confirmation window.
func _on_Restart_pressed() -> void:
	$"Restart Confirmation".visible = true


# We call this function if the player has pressed the restart button, if they accept, this function starts the restart process.
func _on_Restart_Confirmation_confirmed() -> void:
	Restart_Game()


# _on_Remove_Selected_Order is used to delete items off the order queue.
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


func _on_Exploit_Farm_pressed() -> void:
	exploited_farms += 1
	$"Item List".add_item("Start Farm Exploit")
	$"Available Resources/Farms".text = "Farms - " + str(exploited_farms)
	Log_Action("Order to start exploiting a farm was made.")


func _on_Lost_Menu_confirmed() -> void:
	pass


func _on_Convert_Wood_to_Lumber_pressed() -> void:
	Add_Action("Craft Lumber")



func _on_Map_Button_pressed() -> void:
	get_tree().change_scene("res://Map.tscn")


func _on_Job_Button_pressed() -> void:
	get_tree().change_scene("res://Job.tscn")


func _on_Crafting_Button_pressed() -> void:
	get_tree().change_scene("res://Crafting.tscn")
