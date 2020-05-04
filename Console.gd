extends Control

export var wood_to_lumber_ratio := 100

export var wood_pile := 1000
export var lumber_pile := 0

export var workers := 10
export var carpenters := 0
export var lumberjacks := 0


var current_year := 0

var orders : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	set_actions()
	handle_turn()

	var temp_carpenters = carpenters
	var temp_workers = workers



func set_actions():
	if wood_pile < wood_to_lumber_ratio:
		$"Convert Wood to Lumber".disabled = true
	else:
		$"Convert Wood to Lumber".disabled = false



func add_order(order_to_add):
	$"Item List".add_item(order_to_add)



func handle_turn():
	# Update Information
	$"Year Counter".text = "Year " + str(current_year)
#	$"Item List".add_item("Test Order")
	$"Wood".text = "Wood " + str(wood_pile)
	$"Lumber".text = "Lumber " + str(lumber_pile)
	$"Workers".text = "Workers " + str(workers)
	$"Carpenters".text = "Carpenters " + str(carpenters)



func handle_orders():
	# Loop through each order and make that function call
	# The name of the order will be the name of the function
	pass



func make_lumber(wood):
	var total_lumber_made = round(wood / 10)
	wood_pile -= wood
	lumber_pile += total_lumber_made



func train_carpenters(total_workers):
	if total_workers > workers:
		print("you cant do that")
	else:
		workers -= total_workers



func _on_End_Turn_pressed():
	print("Turn Ended")
	current_year += 1
	handle_orders()
	handle_turn()
	$"Item List".clear()



func _on_Restart_pressed():
	print("Game Reset")
	wood_pile = 1000
	lumber_pile = 0
	workers = 10
	carpenters = 0
	current_year = 0
	$"Item List".clear()
	handle_turn()



func _on_Item_List_item_selected(_index):
	$"Up".disabled = false
	$"Down".disabled = false
	$"Delete".disabled = false




func _on_Convert_Worker__Carpenter_pressed():
	# Checking if there are any available workers
	if workers > 0:
		# Adding Actions to the Queue
		add_order("train_carpenters")

		# Removing 1 workers for 1 carpenter and updating console
		workers -= 1
		$"Workers".text = "Workers " + str(workers)

		# Adding 1 carpenter for 1 worker and updating console
		carpenters += 1
		$"Carpenters".text = "Carpenters " + str(carpenters)



func _on_Convert_Worker_to_Lumberjack_pressed():
	# Checking if there are any available workers
	if workers > 0:

		# Adding Actions to the Queue
		add_order("train_lumberjack")

		# Removing 1 workers for 1 carpenter and updating console
		workers -= 1
		$"Workers".text = "Workers " + str(workers)

		# Adding 1 lumberjack for 1 worker and updating console
		lumberjacks += 1
		$"Lumberjacks".text = "Lumberjacks " + str(lumberjacks)
