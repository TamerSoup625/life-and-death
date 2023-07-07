extends Control


func _ready():
	get_tree().root.mode = Window.MODE_WINDOWED
	get_tree().root.size = Vector2i(2048, 1024)


func _input(event):
	if event.is_action_pressed("jump"):
		var image: Image = get_viewport().get_texture().get_image()
		var x_size: int = image.get_size().x
		image = image.get_region(Rect2i(
				Vector2(x_size * 0.25, 0),
				Vector2(x_size * 0.5, image.get_size().y)
		))
		image.save_png("res://cover.png")
		get_tree().quit()
