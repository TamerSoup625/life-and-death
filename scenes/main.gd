extends Control


const PLAYER = preload("res://scenes/player.tscn")
const BOT = preload("res://scenes/bot.tscn")
const MAX_TIME_S: float = 240
const DOUBLE_SCORE_TIME: float = 60

var characters_by_score: Array[Character] = []
var time_left: float = MAX_TIME_S
var double_score_done: bool = false

@onready var life_world: World = %LifeWorld
@onready var death_world: World = %DeathWorld
@onready var life_contain = %LifeContain
@onready var death_contain = %DeathContain
@onready var health_bar = %HealthBar
@onready var health_label = %HealthLabel
@onready var score_rank = %ScoreRank
@onready var score = %Score
@onready var leaderboard_label = %LeaderboardLabel
@onready var time_label = %TimeLabel
@onready var final_result = %FinalResult
@onready var final_rank = %FinalRank
@onready var end_leaderboard = %EndLeaderboard
@onready var anim_player = %AnimPlayer
@onready var one_minute_left = %OneMinuteLeft


func _init():
	randomize()
	GS.var_get_leaderboard = func(): return characters_by_score
	GS.var_get_global_score_multi = func():
			return 2.0 if time_left <= DOUBLE_SCORE_TIME else 1.0
	GS.var_get_game_time_left = func(): return time_left
	GS.player_health_changed.connect(func(raw_percent, player: Player):
			health_bar.value = raw_percent
			if player.is_in_alive_world:
				health_label.text = "%d/%d" % [player.health, player.max_hp]
				health_bar.self_modulate = Color.RED
			else:
				health_label.text = "%d/%d" % [-player.health + player.max_hp, player.max_hp]
				health_bar.self_modulate = Color.CYAN
	, CONNECT_DEFERRED)


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var player = PLAYER.instantiate()
	add_character(player, get_random_spawn_pos())
	player.recieved_damage.connect(func(__):
			anim_player.stop()
			anim_player.play("screen_red")
	)
	
	for i in 7:
		var bot = BOT.instantiate()
		add_character(bot, get_random_spawn_pos())
#		bot.position = Vector3(randf_range(-3, 3), 2, randf_range(-3, 3))
#		life_world.add_character(bot)


func _process(delta):
	if Engine.get_process_frames() % 2 == 0:
		characters_by_score.sort_custom(func(a: Character, b: Character):
				return a.score > b.score
		)
		var player_pos: int = characters_by_score.find(GS.get_player())
		score_rank.text = GS.index_to_cardinal(player_pos)
		score_rank.modulate = GS.index_to_rank_color(player_pos)
#		match player_pos:
#			0: score_rank.text = "1st"
#			1: score_rank.text = "2nd"
#			2: score_rank.text = "3rd"
#			_: score_rank.text = "%sth" % (player_pos + 1)
		score.text = str(snappedf(GS.get_player().score, 0.1))
		
		var leaderboard_text: String = ""
		for i in characters_by_score.size():
			var character: Character = characters_by_score[i]
			leaderboard_text += "%s: %s (%s)\n" % [
					GS.index_to_cardinal(i),
					character.leaderboard_name,
					snappedf(character.score, 0.1),
			]
		leaderboard_label.text = leaderboard_text
	
	if time_left > 0.0:
		time_left -= delta
		var time: int = ceili(time_left)
		@warning_ignore("integer_division")
		time_label.text = "%d:%02d" % [time / 60, time % 60]
		if time_left <= DOUBLE_SCORE_TIME and not double_score_done:
			double_score_done = true
			one_minute_left.show()
			get_tree().create_timer(3, false).timeout.connect(one_minute_left.hide)
	else:
		final_rank.text = str(
				GS.index_to_cardinal(characters_by_score.find(GS.get_player()))
		)
		final_rank.modulate = GS.index_to_rank_color(characters_by_score.find(GS.get_player()))
		final_result.show()
		end_leaderboard.text = leaderboard_label.text
		set_process(false)


func _input(event):
	if event.is_action_pressed("pause") and time_left <= 0.0:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


func add_character(new_char: Character, pos: Vector3, is_in_alive_world: bool = true):
	assert(is_in_alive_world, "Haven't made logic here if new_char spawns on death world")
	new_char.position = pos
	new_char.health_depleted.connect(_on_char_health_depleted.bind(new_char))
	characters_by_score.append(new_char)
	life_world.add_character(new_char)


func get_random_spawn_pos():
	return life_world.get_random_position() + Vector3(randf_range(-2, 2), 20, randf_range(-2, 2))


func _on_char_health_depleted(p_char: Character):
	if p_char.is_in_alive_world:
		# Go to dead world
		life_world.remove_character(p_char)
		death_world.add_character(p_char)
		if p_char is Player:
			life_contain.hide()
			death_contain.show()
	else:
		# Go to alive world
		death_world.remove_character(p_char)
		life_world.add_character(p_char)
		if p_char is Player:
			death_contain.hide()
			life_contain.show()
	p_char.is_in_alive_world = not p_char.is_in_alive_world
