extends Node


signal player_health_changed(raw_percent, player)

var var_get_player: Callable
var var_get_leaderboard: Callable
var var_get_global_score_multi: Callable
var var_get_game_time_left: Callable


func _func_wrapper(callable: Callable, args: Array = []):
	assert(callable != null and callable.is_valid(), "Invalid callable")
	return callable.callv(args)


func get_player() -> Player:
	return _func_wrapper(var_get_player)


func get_leaderboard() -> Array[Character]:
	return _func_wrapper(var_get_leaderboard)


func get_global_score_multi() -> float:
	return _func_wrapper(var_get_global_score_multi)


func get_game_time_left() -> float:
	return _func_wrapper(var_get_game_time_left)


func index_to_cardinal(index: int) -> String:
	match index:
		0: return "1st"
		1: return "2nd"
		2: return "3rd"
		_: return "%sth" % (index + 1)


func index_to_rank_color(index: int, default := Color.WHITE) -> Color:
	match index:
		0: return Color.GOLD
		1: return Color.SILVER
		2: return Color.SIENNA
		_: return default
