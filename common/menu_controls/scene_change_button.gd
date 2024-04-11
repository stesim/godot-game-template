extends "game_menu_button.gd"


@export_file("*.tscn") var scene_path : String

@export var preloaded_scene : PackedScene


func _ready() -> void:
	super()

	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if preloaded_scene != null:
		get_tree().change_scene_to_packed(preloaded_scene)
	elif not scene_path.is_empty():
		get_tree().change_scene_to_file(scene_path)
	else:
		assert(preloaded_scene != null or not scene_path.is_empty())
