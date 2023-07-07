class_name Weapon
extends Node3D


signal attack_worked

@export var usetime: float = 1.0
@export var damage: float = 0.0

var input: bool = false
var cooldown: float = 0.0
## Auto-set by Character
var owner_char: Character:
	set(value):
		if is_instance_valid(owner_char):
			raycast.remove_exception(owner_char)
		owner_char = value
		if is_instance_valid(owner_char):
			raycast.add_exception(owner_char)

@onready var raycast = %RayCast
@onready var visual = %Visual
@onready var fire_position = %FirePosition
@onready var fire_sfx = %FireSfx


func _ready():
	if is_instance_valid(owner_char):
		raycast.add_exception(owner_char)


func _process(delta):
	if input and can_fire_weapon():
		# Fire the weapon
		visual.look_at_from_position(
				fire_position.global_position,
				raycast.get_collision_point() if raycast.is_colliding() else raycast.to_global(raycast.target_position)
		)
#		flare.translate_object_local(Vector3(0, 0, -16))
#		flare.rotate_object_local(Vector3.RIGHT, 0.5 * PI)
		visual.show()
		fire_sfx.play()
		get_tree().create_timer(0.05, false).timeout.connect(visual.hide)
		if raycast.is_colliding() and raycast.get_collider() is Character:
			owner_char.deal_damage(DamageData.new(raycast.get_collider(), damage))
			attack_worked.emit()
		cooldown = usetime
	
	cooldown = maxf(cooldown - delta, 0.0)


func can_fire_weapon() -> bool:
	return cooldown <= 0.0
