extends Character


enum State {
	WANDER,
	ATTACK,
	SEARCH,
}

var _to_attack_connect := DynamicConnection.new()
var _attack_move_noise := FastNoiseLite.new()

var state: State = State.WANDER:
	set(value):
		match value:
			State.WANDER:
				nav_agent.target_position = current_world.get_random_position()
			State.ATTACK:
				_to_attack_connect.set_connection(
						char_to_attack.health_depleted,
						_on_enemy_hp_depleted,
				)
			State.SEARCH:
				_to_attack_connect.set_connection(
						char_to_attack.health_depleted,
						_on_enemy_hp_depleted,
				)
		state = value

var first_time: bool = true
var char_to_attack: Character
var to_attack_thought_vel := Vector3.ZERO
var last_char_pos: Vector3
# AI Behaviour
## For a randf called every frame, based on player position
var aggression_chances: PackedFloat32Array = [
		randf_range(0.003, 0.05),
		randf_range(0.003, 0.045),
		randf_range(0.002, 0.038),
		randf_range(0.002, 0.022),
		randf_range(0.001, 0.011),
		randf_range(0.001, 0.006),
		randf_range(0, 0.002),
		randf_range(0, 0.001),
]
### For a randf called every frame
#var first_agression_chance: float = randf_range(0.003, 0.012)
var manual_spread: float = deg_to_rad(randf_range(2, 6))
## Makes this much mistake of spread for every m/s of difference between real velocity and actual one
var vel_mistake_spread: float = deg_to_rad(randf_range(0.5, 1))
var vel_mistake_correction: float = randf_range(0.05, 0.2)
var attack_preferred_distance: float = randf_range(1, 12)
var counterattack_chance: float = randf_range(0, 1)
var rand_movement_multi: float = randf_range(0, 6)
var aggression_multi_after_wander_path_end: float = randf_range(10, 20)

@onready var nav_agent = %NavAgent
@onready var check_for_enemies = %CheckForEnemies
@onready var enemy_check = %EnemyCheck


func _init():
	super()
	leaderboard_name = "Bot %s" % randi_range(0, 999)


func _ready():
	super()
	enemy_check.add_exception(self)


func _get_input():
	# On the first time nav_agent.get_next_path_position() pushes error
	if first_time:
		first_time = false
		nav_agent.target_position = current_world.get_random_position()
		return
	
	# State-based
	match state:
		State.WANDER:
			input_fire = false
			
			# Possible state change
			for i in check_for_enemies.get_collision_count():
				var possible_enemy = check_for_enemies.get_collider(i)
#				var aggression: float = first_agression_chance if\
#				possible_enemy == GS.get_leaderboard()[0] else aggression_chance
				var aggression: float = aggression_chances[
						GS.get_leaderboard().find(possible_enemy) % aggression_chances.size()
				]
				if nav_agent.is_navigation_finished():
					aggression *= aggression_multi_after_wander_path_end
				if randf() <= aggression and possible_enemy is Character and can_see(possible_enemy, true):
					# Attack that guy
					char_to_attack = possible_enemy
					state = State.ATTACK
			
			# Change target after navigation finish
			if nav_agent.is_navigation_finished():
				nav_agent.target_position = current_world.get_random_position()
		State.ATTACK:
			input_fire = not die_on_touch
			var char_pos: Vector3 = char_to_attack.position
			var char_aim: Vector3 = char_to_attack.head.global_position
			var distance_dir: Vector3 = char_pos.direction_to(position)
			distance_dir.y = 0
			last_char_pos = char_pos
			nav_agent.target_position = char_pos +\
			distance_dir.normalized() * attack_preferred_distance +\
			Vector3(
					rand_movement_multi * _attack_move_noise.get_noise_1d(Time.get_ticks_msec()),
					0, rand_movement_multi * _attack_move_noise.get_noise_1d(-Time.get_ticks_msec()),
			)
			head.look_at(char_aim)
			var spread: float = manual_spread + vel_mistake_spread * (
					to_attack_thought_vel.distance_to(char_to_attack.velocity)
			)
			head.rotate_object_local(Vector3.UP, randf_range(-spread, spread))
			head.rotate_object_local(Vector3.RIGHT, randf_range(-spread, spread))
			
			to_attack_thought_vel = lerp(
					to_attack_thought_vel,
					char_to_attack.velocity,
					vel_mistake_correction,
			)
			
			# Possible state change
			if not can_see(char_to_attack, false):
				state = State.SEARCH
		State.SEARCH:
			input_fire = false
			nav_agent.target_position = last_char_pos
			if can_see(char_to_attack, false):
				state = State.ATTACK
			if nav_agent.is_navigation_finished():
				state = State.WANDER
	
	# Always
	var target_dir: Vector3 = position.direction_to(nav_agent.get_next_path_position())
	input_dir = Vector2(target_dir.x, target_dir.z).normalized()
	input_jump = is_on_wall()
	
#	name_label.text = "%s %s" % [can_see(GS.get_player(), true), can_see(GS.get_player(), false)]


func _on_health_depleted():
	nav_agent.target_position = current_world.get_random_position()
	state = State.WANDER


func _on_enemy_hp_depleted():
	state = State.WANDER


func _on_recieved_damage(dmg_data: DamageData):
	if randf() <= counterattack_chance:
		if dmg_data.dealer.is_in_alive_world == is_in_alive_world:
			char_to_attack = dmg_data.dealer
			state = State.ATTACK


func can_see(character: Character, first_xray: bool) -> bool:
	if first_xray and character == GS.get_leaderboard()[0]:
		return character.is_in_alive_world == is_in_alive_world
	enemy_check.target_position = enemy_check.to_local(character.head.global_position)
	enemy_check.force_raycast_update()
	return enemy_check.get_collider() == character
