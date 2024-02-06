extends Resource
class_name Controls

const double_tap_window = 15

var controls:Dictionary

enum ControlState {
	NEUTRAL,
	JUST_PRESSED,
	PRESSED,
	DOUBLE_TAP
}

func bind_control(input:String):
	controls[input] = {"name": input, "control_state": ControlState.NEUTRAL, "time_since_tap" : double_tap_window+1, "axis_with" : null}

func bind_control_axis(input1:String, input2:String):
	controls[input1] = {"name": input1, "control_state": ControlState.NEUTRAL, "time_since_tap" : double_tap_window+1, "axis_with" : input2}
	controls[input2] = {"name": input2, "control_state": ControlState.NEUTRAL, "time_since_tap" : double_tap_window+1, "axis_with" : input1}

func poll():
	for control in controls:
		if control["axised_with"] != null:
			controls.erase(control["axised_with"])

func solve_state(var control) -> int:
	if Input.is_action_pressed(control["name"]):
		if Input.is_action_just_pressed(control["name"]):
			if control["time_since_tap"] <= double_tap_window:
				control["control_state"] = ControlState.DOUBLE_TAP
				return control["control_state"] # Return here to not increment time_since_tap
			else:
				control["control_state"] = ControlState.JUST_PRESSED
		else:
			control["control_state"] = ControlState.PRESSED
	else:
		control["control_state"] = ControlState.NEUTRAL
	control["time_since_tap"] += 1
	return control["control_state"]
	
func solve_axis_state(var control1, var control2):
	
	pass

func get_state(name:String) -> int:
	return controls[name]["control_state"]
