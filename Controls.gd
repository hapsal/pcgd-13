extends Resource
class_name Controls

const double_tap_window = 16

var controls:Dictionary

enum ControlState {
	NEUTRAL,
	PRESSED,
	DOUBLE_TAP,
}

func bind_control(action:String):
	controls[action] = VirtualControl.new(action)

func bind_control_axis(axis_name:String, action1:String, action2:String):
	controls[axis_name] = VirtualAxisControl.new(action1, action2)

func poll():
	for control_name in controls:
		if controls[control_name] is VirtualControl:
			solve_state(controls[control_name])
		elif controls[control_name] is VirtualAxisControl:
			solve_axis_state(controls[control_name])
		controls[control_name].increment_frames_since_tap()

func get_state(control_name:String) -> int:
	return controls[control_name].state
	
func get_direction(axis_name:String) -> int:
	assert(controls[axis_name] != null)
	return controls[axis_name].direction

func solve_state(control:VirtualControl):
	if Input.is_action_pressed(control.action_name):
		if Input.is_action_just_pressed(control.action_name):
			if control.frames_since_tap <= double_tap_window:
				control.state = ControlState.DOUBLE_TAP
			else:
				control.state = ControlState.PRESSED
			control.frames_since_tap = 0
		else:
			control.state = ControlState.PRESSED
	else:
		control.state = ControlState.NEUTRAL
	
func solve_axis_state(axis:VirtualAxisControl):
	if Input.is_action_pressed(axis.action_name1) and Input.is_action_pressed(axis.action_name2):
		if axis.frames_since_tap1 < axis.frames_since_tap2:
			axis.direction = 1
			axis.state = ControlState.PRESSED
		elif axis.frames_since_tap1 > axis.frames_since_tap2:
			axis.direction = -1
			axis.state = ControlState.PRESSED
		else:
			axis.direction = 0
			axis.state = ControlState.NEUTRAL
	elif Input.is_action_pressed(axis.action_name1):
		axis.direction = -1
		if Input.is_action_just_pressed(axis.action_name1):
			if axis.frames_since_tap1 <= double_tap_window:
				axis.state = ControlState.DOUBLE_TAP
			else:
				axis.state = ControlState.PRESSED
			axis.frames_since_tap1 = 0
		else:
			axis.state = ControlState.PRESSED
	elif Input.is_action_pressed(axis.action_name2):
		axis.direction = 1
		if Input.is_action_just_pressed(axis.action_name2):
			if axis.frames_since_tap2 <= double_tap_window:
				axis.state = ControlState.DOUBLE_TAP
			else:
				axis.state = ControlState.PRESSED
			axis.frames_since_tap2 = 0
		else:
			axis.state = ControlState.PRESSED
	else:
		axis.direction = 0
		axis.state = ControlState.NEUTRAL

class VirtualControl:
	var action_name:String
	var state = ControlState.NEUTRAL
	var frames_since_tap = double_tap_window + 1
	
	func _init(action:String):
		action_name = action
	
	func increment_frames_since_tap():
		frames_since_tap += 1
	
class VirtualAxisControl:
	var action_name1:String
	var action_name2:String
	var direction = 0
	var frames_since_tap1 = double_tap_window + 1
	var frames_since_tap2 = double_tap_window + 1
	var state = ControlState.NEUTRAL
	
	func _init(action1:String, action2:String):
		action_name1 = action1
		action_name2 = action2
	
	func increment_frames_since_tap():
		frames_since_tap1 += 1
		frames_since_tap2 += 1
