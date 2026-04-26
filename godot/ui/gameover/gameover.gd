extends Control

var ranking: Array[String]

@onready var continue_button := $CenterContainer/VBoxContainer/Continue


func _ready() -> void:
	$CenterContainer/VBoxContainer/Label.text = "The winner is: " + ranking[0]
