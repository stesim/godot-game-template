extends Control


@export var pause_when_visible := true

@export var toggle_action : StringName


func _ready() -> void:
	if pause_when_visible:
		get_tree().paused = visible

	visibility_changed.connect(_on_visibility_changed)


func _exit_tree() -> void:
	if pause_when_visible:
		get_tree().paused = false


func _on_visibility_changed() -> void:
	if pause_when_visible:
		get_tree().paused = visible


func _unhandled_input(event : InputEvent) -> void:
	if not toggle_action.is_empty() and event.is_action_pressed(toggle_action):
		visible = !visible
