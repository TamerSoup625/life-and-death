class_name World
extends Node3D


@onready var characters = %Characters
@onready var random_pos_array = %RandomPositions.get_children()


func add_character(new_char: Character):
	characters.add_child(new_char)
	new_char.correct_warp()
	new_char.current_world = self


func remove_character(p_char: Character):
	characters.remove_child(p_char)


func get_random_position():
	return random_pos_array.pick_random().position
