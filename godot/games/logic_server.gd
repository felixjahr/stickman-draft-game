extends Node

const SIMULATION_TICK_RATE := 30
const SNAPSHOT_FREQUENCY := 2

const INPUT_BUFFER_SIZE := 128

const PlayerServer := preload("res://player/player_server.tscn")
const BulletServer := preload("res://bullet/bullet_server.tscn")

var tick := 0

var bullet_counter := 0

var players: Dictionary[String, CharacterBody2D] = {}
var bullets: Dictionary[String, Node2D] = {}

var player_ids: Array[String] = []

var inputs: Dictionary[String, Array] = {}
var last_inputs: Dictionary[String, PlayerInput] = {}
var last_acknowledged_input_ticks: Dictionary[String, int] = {}

var map: StaticBody2D

@onready var game_net := $"../../Net/GameNet"
@onready var map_container := $MapContainer
@onready var player_container := $PlayerContainer
@onready var bullet_container := $BulletContainer


func _ready() -> void:
	Engine.physics_ticks_per_second = SIMULATION_TICK_RATE
	game_net.connect("input_received", _on_net_input_received)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	tick += 1
	
	_tick_players(delta)
	_tick_bullets(delta)
	
	if tick % SNAPSHOT_FREQUENCY == 0:
		game_net.send_snapshot(_build_snapshot(), last_acknowledged_input_ticks)


func spawn_map(map_id: String) -> void:
	var new_map := Data.MAPS[map_id].instantiate()
	map_container.add_child(new_map)
	map = new_map


func spawn_player(player_id: String, weapon_ids: Array[String], armour_id: String, ability_id: String, hearts = null) -> void:
	var new_player := PlayerServer.instantiate()
	new_player.player_id = player_id
	new_player.weapon_ids = weapon_ids
	new_player.armour_id = armour_id
	new_player.ability_id = ability_id
	if hearts:
		new_player.hearts = hearts
	if not player_id in player_ids:
		player_ids.append(player_id)
	new_player.global_position = map.spawn_points[player_ids.find(player_id)].global_position
	player_container.add_child(new_player)
	players[player_id] = new_player
	var input_buffer: Array[PlayerInput] = []
	input_buffer.resize(INPUT_BUFFER_SIZE)
	inputs[player_id] = input_buffer
	last_inputs[player_id] = PlayerInput.new()
	last_acknowledged_input_ticks[player_id] = -1


func despawn_player(player_id: String) -> void:
	if not players.has(player_id):
		return
	players[player_id].queue_free()
	players.erase(player_id)
	inputs.erase(player_id)
	last_inputs.erase(player_id)
	last_acknowledged_input_ticks.erase(player_id)
	gameover()


func spawn_bullet(position: Vector2, speed: int, damage: int, self_hit: bool, direction: Vector2, player_id: String) -> void:
	var new_bullet := BulletServer.instantiate()
	new_bullet.bullet_id = str(bullet_counter)
	new_bullet.global_position = position
	new_bullet.speed = speed
	new_bullet.damage = damage
	new_bullet.self_hit = self_hit
	new_bullet.direction = direction
	new_bullet.player_id = player_id
	bullet_container.add_child(new_bullet)
	bullets[new_bullet.bullet_id] = new_bullet
	bullet_counter += 1


func despawn_bullet(bullet_id: String) -> void:
	if not bullets.has(bullet_id):
		return
	bullets[bullet_id].queue_free()
	bullets.erase(bullet_id)


func gameover() -> void:
	var ranking: Array[String] = players.keys()
	ranking.sort_custom(func(a, b): 
		if players[a].hearts == players[b].hearts:
			return players[a].health > players[b].health
		else:
			return players[a].hearts > players[b].hearts
	)
	get_parent().gameover(ranking)


func _tick_players(delta: float) -> void:
	for player_id in players.keys():
		var player := players[player_id]
		var input := _get_latest_input(player_id)
		player.tick(delta, input)


func _get_latest_input(player_id: String) -> PlayerInput:
	var player_inputs := inputs[player_id]
	var input: PlayerInput = player_inputs[tick % INPUT_BUFFER_SIZE]
	if input != null and input.tick == tick:
		last_inputs[player_id] = input
		return input
	var fallback_input: PlayerInput = last_inputs.get(player_id, PlayerInput.new())
	fallback_input.jumping = false
	fallback_input.attacking = false
	fallback_input.ability = false
	return fallback_input


func _tick_bullets(delta: float) -> void:
	for bullet in bullets.values():
		bullet.tick(delta)


func _build_snapshot() -> Snapshot:
	var snapshot := Snapshot.new()
	snapshot.tick = tick
	for player_id in players.keys():
		snapshot.players.append(_build_player_snapshot(player_id))
	for bullet_id in bullets.keys():
		snapshot.bullets.append(_build_bullet_snapshot(bullet_id))
	return snapshot


func _build_player_snapshot(player_id: String) -> PlayerSnapshot:
	var player: CharacterBody2D = players[player_id]
	var player_snapshot := PlayerSnapshot.new()
	player_snapshot.player_id = player_id
	player_snapshot.position = player.global_position
	player_snapshot.velocity = player.velocity
	player_snapshot.health = player.health
	player_snapshot.hearts = player.hearts
	player_snapshot.facing = player.facing
	player_snapshot.is_on_floor = player.is_on_floor()
	player_snapshot.current_weapon = player.current_weapon
	player_snapshot.attacking = player.attacking
	player_snapshot.ability_active = player.ability_active
	player_snapshot.armour_id = player.armour_id
	player_snapshot.ability_id = player.ability_id
	player_snapshot.weapon_ids = player.weapon_ids
	player_snapshot.weapon_aim_directions = player.weapon_aim_directions
	player_snapshot.weapon_ammunitions = player.weapon_ammunitions
	player_snapshot.last_hit = player.last_hit
	player_snapshot.last_ability = player.last_ability
	player_snapshot.ability_recharge_time = player.ability_recharge_time
	return player_snapshot


func _build_bullet_snapshot(bullet_id: String) -> BulletSnapshot:
	var bullet: Node2D = bullets[bullet_id]
	var bullet_snapshot := BulletSnapshot.new()
	bullet_snapshot.bullet_id = bullet_id
	bullet_snapshot.position = bullet.global_position
	bullet_snapshot.speed = bullet.speed
	bullet_snapshot.direction = bullet.direction
	return bullet_snapshot


func _on_net_input_received(player_id: String, input: PlayerInput) -> void:
	if not inputs.has(player_id):
		return
	var last_acknowledged_tick := int(last_acknowledged_input_ticks.get(player_id, -1))
	if last_acknowledged_tick == -1:
		last_acknowledged_tick = input.tick - 1
		last_acknowledged_input_ticks[player_id] = last_acknowledged_tick
	if input.tick <= last_acknowledged_tick:
		return

	inputs[player_id][input.tick % INPUT_BUFFER_SIZE] = input
	_advance_acknowledged_input_tick(player_id)


func _advance_acknowledged_input_tick(player_id: String) -> void:
	var player_inputs := inputs[player_id]
	var acknowledged_tick := int(last_acknowledged_input_ticks.get(player_id, -1))
	while true:
		var next_tick := acknowledged_tick + 1
		var input = player_inputs[next_tick % INPUT_BUFFER_SIZE]
		if input == null or input.tick != next_tick:
			break
		acknowledged_tick = next_tick
	last_acknowledged_input_ticks[player_id] = acknowledged_tick
