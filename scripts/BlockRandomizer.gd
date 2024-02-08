class_name BlockRandomizer

var types:Dictionary

func _init(block_types:Array):
	for type in block_types:
		var type_instance = type.instance()
		types[type_instance] = type
	
func get_block_type_for(player):
	var rng_table = {}
	var table_position = 0
	for type in types:
		var adjusted_rarity = type.rarity
		if (player.tower.height < 3) and (type.difficulty <= 3):
			adjusted_rarity += 4-type.difficulty
		
		for i in range(0, player.upcoming_block_queue.size()-1):
			if player.upcoming_block_queue[i] == types[type]:
				adjusted_rarity += i/5.0
		
		adjusted_rarity = clamp(int(adjusted_rarity), 1, 10)
		# The magic numbers are from fitting a 3rd order polynomial for [(0,100),(1,75),(9,2),(10,1)]
		var frequency = int(100 - 27.53889*adjusted_rarity + 2.625*pow(adjusted_rarity, 2) - 0.08611111*pow(adjusted_rarity, 3))
		rng_table[table_position + frequency] = type
		table_position += frequency
	return pick_from_weighted_rng_table(rng_table, table_position)
		
func pick_from_weighted_rng_table(rng_table:Dictionary, highest_frequency:int):
	var rng = randi() % (highest_frequency + 1)
	for frequency_range in rng_table:
		if rng <= frequency_range:
			return  types[rng_table[frequency_range]]
