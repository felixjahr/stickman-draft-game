extends Node

const DEFAULT_INPUT = {
	"input_dir" : 0,
	"jump_pressed" : false,
}

const Player := preload("res://player/player.tscn")
const Map := preload("res://maps/forest/forest.tscn")

var tick: int = 0

var players := {}
var input_buffer := {}

@onready var net := $"../Net"


func start_match() -> void:
	var new_map = Map.instantiate()
	add_child(new_map)


func game_tick(delta: float) -> void:
	tick += 1
	
	for pid in players.keys():
		var input := _get_input(pid, tick)
		players[pid].simulate(input["input_dir"], input["jump_pressed"], delta)
	
	if tick % 3 == 0:
		_send_snapshot()


func _get_input(pid: int, tick: int) -> Dictionary:
	if not input_buffer.has(pid):
		return DEFAULT_INPUT
	
	var buf: Dictionary = input_buffer[pid]
	if buf.has(tick):
		return buf[tick]
	
	return buf.get(tick - 1, DEFAULT_INPUT)


func _send_snapshot() -> void:
	var snapshot := {}
	for pid in players.keys():
		var player: CharacterBody2D = players[pid]
		snapshot[pid] = {
			"px": player.global_position.x,
			"py": player.global_position.y,
			"vx": player.velocity.x,
			"vy": player.velocity.y,
			"j" : player.jumping,
		}
	net.send_snapshot(tick, snapshot)


func _on_net_input_received(pid: int, tick: int, input: Dictionary) -> void:
	if not input_buffer.has(pid):
		input_buffer[pid] = {}
	input_buffer[pid][tick] = input


func _on_net_peer_connected(pid: int) -> void:
	var new_player := Player.instantiate()
	new_player.name = str(pid)
	add_child(new_player)
	players[pid] = new_player
	input_buffer[pid] = {}
