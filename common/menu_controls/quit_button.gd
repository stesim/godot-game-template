extends "game_menu_button.gd"


func _ready() -> void:
	super()

	pressed.connect(get_tree().quit)
