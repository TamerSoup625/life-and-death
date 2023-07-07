class_name DynamicConnection
extends RefCounted


##Handles a dynamic connection between a Signal and a Callable

##Made for connections that have to change, ensures there is only a connection between signal and callable[br]
##Connections are null safe


var _signal: Signal
var _callable: Callable


func _init(p_signal: Signal = Signal(), p_callable: Callable = Callable()):
	set_connection(p_signal, p_callable)


func _are_valid(p_signal: Signal, p_callable: Callable):
	return (not p_signal.is_null()) and is_instance_valid(p_signal.get_object()) and p_callable.is_valid()


func set_connection(new_signal: Signal, new_callable: Callable):
	# _signal and _callable are the old ones
	if _are_valid(_signal, _callable):
#		print(_signal.get_object())
		_signal.disconnect(_callable)
	
	if _are_valid(new_signal, new_callable):
		new_signal.connect(new_callable)
	
	_signal = new_signal
	_callable = new_callable


func remove_connection():
	set_connection(Signal(), Callable())


func set_signal(p_signal: Signal):
	set_connection(p_signal, _callable)


func get_signal() -> Signal:
	return _signal


func set_callable(p_callable: Callable):
	set_connection(_signal, p_callable)


func get_callable() -> Callable:
	return _callable


func is_valid() -> bool:
	return _are_valid(_signal, _callable)
