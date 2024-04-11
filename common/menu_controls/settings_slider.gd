extends Slider


@export var setting : StringName


func _ready() -> void:
	assert(setting in GameSettings)
	assert(typeof(GameSettings[setting]) == TYPE_FLOAT)

	value = GameSettings[setting]
	value_changed.connect(_on_value_changed)


func _on_value_changed(new_value : float) -> void:
	GameSettings[setting] = new_value
