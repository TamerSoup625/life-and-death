extends Control


@onready var how_to_play = %HowToPlay
@onready var main_orbit = %MainOrbit


func _ready():
	randomize()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta):
	main_orbit.rotate_y(delta)


func _on_play_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_how_to_btn_pressed():
	how_to_play.show()
