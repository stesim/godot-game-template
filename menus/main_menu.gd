extends Control


@export var licenses : LicenseDatabase


func _ready() -> void:
	%credits_button.toggled.connect(%credits_text_box.set_visible)

	_load_credits()


func _load_credits() -> void:
	if licenses == null:
		return

	var credits_by_category := {}
	for entry in licenses.entries:
		assert(entry != null)
		var string := credits_by_category.get(entry.category, "") as String
		var credits := entry.generate_credits() if entry.credits.is_empty() else entry.credits
		string += "\n" + credits + "\n"
		credits_by_category[entry.category] = string

	var generated_credits := ""
	for category in LicenseDatabaseEntry.Category.size():
		category = (category + 1) % LicenseDatabaseEntry.Category.size()
		var credits := credits_by_category.get(category, "") as String
		if not credits.is_empty():
			var category_name := _get_asset_category_name(category)
			generated_credits += (
				category_name + ":\n"
				+ credits + "\n"
			)

	%credits_text_box.text += generated_credits


func _get_asset_category_name(category : LicenseDatabaseEntry.Category) -> String:
	match category:
		LicenseDatabaseEntry.Category.MISC: return "Miscellaneous"
		LicenseDatabaseEntry.Category.MODEL: return "Models"
		LicenseDatabaseEntry.Category.TEXTURE: return "Textures"
		LicenseDatabaseEntry.Category.MUSIC: return "Music"
		LicenseDatabaseEntry.Category.SFX: return "Sound Effects"

	return "Other"
