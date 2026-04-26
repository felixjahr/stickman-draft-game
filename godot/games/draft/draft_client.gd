extends Node

signal ended

const DraftScreen = preload("res://ui/draft_screen/draft_screen.tscn")
const Overlay := preload("res://ui/overlay/overlay.tscn")
const Gameover := preload("res://ui/gameover/gameover.tscn")

enum DraftState {
	DRAFT,
	FIGHT,
	GAMEOVER,
}

var state: DraftState

var map_id: String

var draft_screen: Control

@onready var ui := $"../UI"
@onready var game_net := $"../Net/GameNet"
@onready var logic := $Logic


func _ready() -> void:
	logic.spawn_map(map_id)
	game_net.connect("snapshot_received", logic._on_net_snapshot_received)
	game_net.connect("game_event_received", _on_net_game_event_received)


func _change_state(new_state: DraftState, data = null) -> void:
	if new_state == state:
		return
	_exit_state(new_state, data)
	_enter_state(new_state, data)
	state = new_state


func _enter_state(new_state: DraftState, data = null) -> void:
	if new_state == DraftState.DRAFT:
		var new_draft_screen = DraftScreen.instantiate()
		new_draft_screen.connect("draft_finished", _on_draft_screen_draft_finished)
		new_draft_screen.draft_options = data
		ui.add_child(new_draft_screen)
		draft_screen = new_draft_screen
	elif new_state == DraftState.FIGHT:
		var new_overlay = Overlay.instantiate()
		logic.overlay = new_overlay
		ui.add_child(new_overlay)
		logic.start()
	elif new_state == DraftState.GAMEOVER:
		logic.stop()
		var new_gameover = Gameover.instantiate()
		new_gameover.ranking = data
		ui.add_child(new_gameover)
		new_gameover.continue_button.connect("pressed", _on_gameover_continue_pressed)


func _exit_state(new_state: DraftState, data = null) -> void:
	for child in ui.get_children():
		child.queue_free()


func _on_net_game_event_received(game_event: GameEvent) -> void:
	if game_event.type == GameEvent.Type.DRAFT_OPTIONS:
		_enter_state(DraftState.DRAFT, game_event.payload)
	elif game_event.type == GameEvent.Type.DRAFT_FINISHED:
		_change_state(DraftState.FIGHT)
	elif game_event.type == GameEvent.Type.DRAFT_GAMEOVER:
		_change_state(DraftState.GAMEOVER, game_event.payload)


func _on_draft_screen_draft_finished(draft_result: Array[int]) -> void:
	var new_game_request := GameRequest.new()
	new_game_request.type = GameRequest.Type.DRAFT_RESULT
	new_game_request.payload = draft_result
	game_net.send_game_request(new_game_request)


func _on_gameover_continue_pressed() -> void:
	emit_signal("ended")
