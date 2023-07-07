class_name Player
extends Character


const CAMERA_SENSIVITY: float = 0.003

#@onready var camera = %Camera
@onready var hit_mark = %HitMark


func _init():
	super()
	GS.var_get_player = func(): return self
	leaderboard_name = "You"
	
	health_changed.connect(func(_dmg_data):
			GS.player_health_changed.emit(remap(
					health,
					0,
					max_hp,
					0 if is_in_alive_world else 1,
					1 if is_in_alive_world else 0,
			), self)
	)


func _get_input():
	input_jump = Input.is_action_just_pressed("jump")
	input_dir = Input.get_vector("left", "right", "foward", "backward")
	input_fire = Input.is_action_pressed("fire_weapon")


func _input(event):
	if event is InputEventMouseMotion:
		look_accum += event.relative * CAMERA_SENSIVITY
	if OS.is_debug_build() and event.is_action_pressed("debug_travel"):
		# Take a ton of damage to travel
		deal_damage(DamageData.new(self, 9999999999.0))


func _on_attack_worked():
	# IF CHANGING WEAPON, REMEMBER TO CONNECT SIGNAL TO THIS
	hit_mark.play()
