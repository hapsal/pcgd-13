extends Block
class_name TheIcer

const TIME_BEFORE_EFFECT_PROCS = 1
const FREEZE_EFFECT_MATERIAL = preload("res://materials/frozen_overlay.tres")
var proc_timer = 0.0
var has_procced = false
var effect_area:Area2D

func _ready():
	effect_area = $EffectArea

func _physics_process(delta):
	if not has_procced:
		var effect_targets = get_contiguous_blocks()
		effect_targets.append_array(effect_area.get_overlapping_bodies())
		effect_targets.erase(self)
		if effect_targets:
			if proc_timer >= TIME_BEFORE_EFFECT_PROCS:
				for block in effect_targets:
					if block.mode == 3:
						mode = 3
					if not block.find_node("FreezeEffect", false, false):
						block.add_child(FreezeEffect.new())
				if mode == 3:
					has_procced = true
			else:
				proc_timer += delta
		else:
			proc_timer = max(0.0, proc_timer - delta)

class FreezeEffect extends Node:
	var effect_timer = 1.0
	var parent:Block
	
	func _ready():
		name = "FreezeEffect"
		parent = get_parent()
		assert(parent is Block)
		parent.material = FREEZE_EFFECT_MATERIAL
	
	func _physics_process(delta):
		for block in parent.get_colliding_blocks():
			if block != null and block.find_node("FreezeEffect", false, false):
				parent.lock_with(block)
		if effect_timer >= 0:
			get_parent().material.set_shader_param("effect_progress", 1.0 - effect_timer)
			effect_timer -= delta
