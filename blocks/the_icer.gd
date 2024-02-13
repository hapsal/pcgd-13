extends Block
class_name TheIcer

const TIME_BEFORE_EFFECT_PROCS = 1
var proc_timer = 0.0
var has_procced = false

func _process(delta):
	if not has_procced:
		if colliding_blocks:
			if proc_timer >= TIME_BEFORE_EFFECT_PROCS:
				add_child(FreezeEffect.new())
				for block in get_contiguous_blocks():
					if block.mode == 3:
						mode = 3
					block.add_child(FreezeEffect.new())
				has_procced = true
			else:
				proc_timer += delta
		else:
			proc_timer = max(0.0, proc_timer - delta)

class FreezeEffect extends Node:
	func _ready():
		name = "FreezeEffect"
		assert(get_parent() is Block)
	
	func _process(_delta):
		var parent = get_parent()
		for block in parent.colliding_blocks:
			if block.find_node("FreezeEffect", false, false):
				parent.lock_with(block)
				block.lock_with(parent)
