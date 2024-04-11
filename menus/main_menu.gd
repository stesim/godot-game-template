extends Control


func _ready() -> void:
	%credits_button.toggled.connect(%credits_text_box.set_visible)

	_load_credits()


func _load_credits() -> void:
	# TODO: load license info
	var licenses := ""
	%credits_text_box.text += licenses
