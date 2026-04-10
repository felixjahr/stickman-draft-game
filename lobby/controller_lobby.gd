extends Node

const ROOM_SIZE := 2

const LOBBY_PORT := 8000

const GAME_IP_ADDRESS := "35.198.127.12"
const START_PORT := 9000
const PORT_RANGE_SIZE := 1000

const SERVER_PATH := "/home/felixjahr/server.x86_64"

var rooms: Dictionary[String, Dictionary] = {}
var next_port := START_PORT

@onready var net := $Net


func _ready() -> void:
	net.create_server(LOBBY_PORT)


func _on_net_room_created(pid: int) -> void:
	var code := _generate_room_code()
	
	var room := {
		"members": [pid],
		"game_id": "draft",
		"map_id": "mountains",#Data.MAPS.keys().pick_random(),
	}
	rooms[code] = room
	
	net.send_room_code(pid, code)


func _on_net_room_joined(pid: int, code: String) -> void:
	if not rooms.has(code):
		net.send_room_error(pid, "Room doesn't exist")
		return
	
	var room: Dictionary = rooms[code]
	room["members"].append(pid)
	
	if room["members"].size() == ROOM_SIZE:
		_start_match_for_room(code)


func _start_match_for_room(code: String) -> void:
	var room: Dictionary = rooms[code]
	rooms.erase(code)
	
	var args := [
		"--headless",
		"port=" + str(next_port),
		"game_id=" + room["game_id"],
		"map_id=" + room["map_id"],
	]
	var server_pid := OS.create_process(SERVER_PATH, args)
	print(server_pid)
	
	for pid in room["members"]:
		#net.send_room_start(pid, next_port, GAME_IP_ADDRESS, room["game_id"], room["map_id"])
		net.send_room_start(pid, 9000, "127.0.0.1", room["game_id"], room["map_id"])
	
	next_port = START_PORT + ((next_port - START_PORT + 1) % PORT_RANGE_SIZE)


func _generate_room_code() -> String:
	var code: String
	while not code or rooms.has(code):
		code = str(randi_range(0, 9999)).pad_zeros(4)
	return code
