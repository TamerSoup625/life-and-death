class_name Character
extends CharacterBody3D


signal health_depleted
signal health_changed(dmg_data)
signal dealt_damage(dmg_data)
signal recieved_damage(dmg_data)

const SPEED = 8.0
const JUMP_VELOCITY = 7.0
const Y_FOR_RESPAWN: float = -5
const RESPAWN_POS: Vector3 = Vector3(0, 25, 0)
const KILL_POINTS: float = 3

var _jump_buffer := Buffer.new(7, 7)
var _weapon_fire_buffer := Buffer.new(5)

## If using export, make sure weapon is child of Head
@export var weapon: Weapon
@export var max_hp: float = 100
@export var use_look_accum: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2
var is_in_alive_world: bool = true
var score: float = 0

var input_dir: Vector2
var input_jump: bool
var input_fire: bool
var look_accum := Vector2.ZERO
var current_world: World
var die_on_touch: bool = true
var leaderboard_name: String

@onready var health: float = max_hp:
	set(value):
		health = maxf(value, 0.0)
@onready var head: Marker3D = %Head
@onready var warp_correction = %WarpCorrection
@onready var name_label = %NameLabel
@onready var mesh_instance_3d = %MeshInstance3D
@onready var ALIVE_MAX_HP: float = max_hp
@onready var DEAD_MAX_HP: float = max_hp * 2


func _init():
	health_depleted.connect(func():
			if is_in_alive_world:
				# Going to death world
				max_hp = DEAD_MAX_HP
			else:
				# Going to alive world
				max_hp = ALIVE_MAX_HP
			health = max_hp
	)


func _ready():
	name_label.text = leaderboard_name
	if is_instance_valid(weapon):
		weapon.owner_char = self
	mesh_instance_3d.set_instance_shader_parameter("albedo", Color.from_hsv(randf(), 1, 1))


func _process(delta):
	if use_look_accum:
		head.basis = Basis()
		head.rotate(Vector3.LEFT, look_accum.y)
		head.rotate(Vector3.DOWN, look_accum.x)
	# Points stop increasing at timeout
	if is_in_alive_world and GS.get_game_time_left() > 0.0:
		score += delta * GS.get_global_score_multi()
	
	if Engine.get_process_frames() % 2 == 0:
		name_label.no_depth_test = GS.get_leaderboard().find(self) == 0


func _physics_process(delta):
	_get_input()
	
	# Update buffers
	_jump_buffer.input = input_jump
	_jump_buffer.allow = is_on_floor()
	_jump_buffer.update()
	if is_instance_valid(weapon):
		_weapon_fire_buffer.input = input_fire
		_weapon_fire_buffer.allow = weapon.can_fire_weapon()
	else:
		_weapon_fire_buffer.input = false
		_weapon_fire_buffer.allow = false
	_weapon_fire_buffer.update()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Jump.
	if _jump_buffer.can_do_action():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.DOWN, look_accum.x).normalized()
#	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Fire weapon
	if is_instance_valid(weapon):
		weapon.input = _weapon_fire_buffer.can_do_action()
	
	# Respawn if fell off
	if position.y <= Y_FOR_RESPAWN:
		position = RESPAWN_POS
	
	move_and_slide()
	
	if die_on_touch and is_instance_valid(get_last_slide_collision()):
		# Take a ton of damage to travel
		deal_damage(DamageData.new(self, 9999999999.0))
		die_on_touch = false


## Virtual, called on physics frame
func _get_input():
	pass


func deal_damage(dmg_data: DamageData):
	assert(is_instance_valid(dmg_data.target))
	
	dmg_data.dealer = self
	# In death world, health works in the opposite way, attacking gives you health
	var target: Character = dmg_data.target if is_in_alive_world else self
	target.health -= dmg_data.damage
	target.health_changed.emit(dmg_data)
	dealt_damage.emit(dmg_data)
	dmg_data.target.recieved_damage.emit(dmg_data)
	
	if target.health <= 0.0:
		target.health_depleted.emit()


## new_weapon must NOT be in tree
func set_weapon(new_weapon: Weapon):
	if is_instance_valid(weapon):
		weapon.queue_free()
	
	head.add_child(new_weapon)
	new_weapon.owner_char = self
	weapon = new_weapon


func correct_warp():
	warp_correction.force_shapecast_update()
	if warp_correction.is_colliding():
		# Probably inside something
		position = warp_correction.get_collision_point(0)
