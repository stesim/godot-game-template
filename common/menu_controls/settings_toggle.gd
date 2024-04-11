extends BaseButton


@export var setting : StringName


func _ready() -> void:
	assert(setting in GameSettings)
	assert(typeof(GameSettings[setting]) == TYPE_BOOL)

	button_pressed = GameSettings[setting]
	toggled.connect(_on_toggled)


func _on_toggled(state : bool) -> void:
	GameSettings[setting] = state
