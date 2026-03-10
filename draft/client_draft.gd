extends Node

const DraftScreen = preload("res://draft/ui/draft_screen.tscn")
const Overlay := preload("res://menus/overlay/overlay.tscn")

enum DraftState {
	DRAFT,
	FIGHT,
}

var state: DraftState

var match_init: MatchInit

@onready var net := $"../Net"
@onready var ui := $UI
@onready var view := $View


func _ready() -> void:
	net.connect("snapshot_received", view._on_net_snapshot_received)


func init_match(match_init: MatchInit) -> void:
	self.match_init = match_init
	_enter_state(DraftState.DRAFT)


func change_state(new_state: DraftState) -> void:
	if new_state == state:
		return
	_exit_state(new_state)
	_enter_state(new_state)
	state = new_state


func _enter_state(new_state: DraftState) -> void:
	if new_state == DraftState.DRAFT:
		view.spawn_map("forest")
		var new_draft_screen = DraftScreen.instantiate()
		new_draft_screen.draft_finished.connect(_on_draft_screen_draft_finished)
		ui.add_child(new_draft_screen)
		new_draft_screen.start_draft(match_init.gamemode_payload["draft_options"])
	elif new_state == DraftState.FIGHT:
		var new_overlay = Overlay.instantiate()
		ui.add_child(new_overlay)
		view.overlay = new_overlay
		view.spawn_local_player()
		view.set_physics_process(true)


func _exit_state(new_state: DraftState) -> void:
	if state == DraftState.DRAFT:
		print(ui.get_children())
		ui.get_child(0).queue_free()


func _on_draft_screen_draft_finished(selected_items: Dictionary) -> void:
	net.send_match_message(net.MessageTyp.DRAFT_FINISHED, selected_items)


func _on_net_game_message_received(type: int, payload: Dictionary) -> void:
	change_state(DraftState.FIGHT)
