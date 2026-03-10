extends Node

@onready var net := $Net
@onready var draft := $Draft


func _ready() -> void:
	net.create_server()
	
