extends RefCounted
class_name Buffer


## Generic purpose buffer, which can be used for input buffering, coyote jump, etc.[br]
## You'll see various times the terms pre-buffer and post-buffer. These are (probably) terms I made up myself.[br][br]
## Pre-buffering is buffering an input before the action can be done to then do the action when possible.[br]
## Post-buffering is buffering the possibility of doing an action to do it when input is asked to.
## pre_buffer_frames and post_buffer_frames with both 0 will result in no buffering


## If true, input is sent
var input: bool
## If true, action can be done
var allow: bool

var pre_buffer_frames: int = 0
var post_buffer_frames: int = 0

var _pre_b_frames: int = 0
var _post_b_frames: int = 0
# If true, all buffering is reset on update (action was done)
var _reset_buffer: bool = false


func _init(pre_buffer: int = 0, post_buffer: int = 0):
	pre_buffer_frames = pre_buffer
	post_buffer_frames = post_buffer


# Helper function for decreasing
func _decrease(value: int):
	return max(0, value - 1)


func update():
	if _reset_buffer:
		_pre_b_frames = 0
		_post_b_frames = 0
		_reset_buffer = false
	
	_pre_b_frames = _decrease(_pre_b_frames)
	_post_b_frames = _decrease(_post_b_frames)
	
	if input and not allow:
		_pre_b_frames = pre_buffer_frames
	if allow and not input:
		_post_b_frames = post_buffer_frames
	
#	print_debug_info()


func print_debug_info() -> void:
	printt(_pre_b_frames, _post_b_frames, can_do_action())


func can_do_action() -> bool:
	var result = (input and allow) or (allow and _pre_b_frames > 0) or (input and _post_b_frames > 0)
	if result:
		_reset_buffer = true
	return result
