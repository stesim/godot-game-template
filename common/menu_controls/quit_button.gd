extends "game_menu_button.gd"


@export var remove_in_web_export := true


func _ready() -> void:
	super()

	if remove_in_web_export and OS.has_feature(&"web"):
		hide()
		queue_free()
		return

	pressed.connect(get_tree().quit)
