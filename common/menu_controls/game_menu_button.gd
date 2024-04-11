extends BaseButton


@export var auto_focus := false


func _ready() -> void:
	if auto_focus:
		visibility_changed.connect(_on_visibility_changed)

		if is_visible_in_tree() and get_viewport().gui_get_focus_owner() == null:
			grab_focus.call_deferred()


func _on_visibility_changed() -> void:
	if is_visible_in_tree() and get_viewport().gui_get_focus_owner() == null:
		grab_focus()
