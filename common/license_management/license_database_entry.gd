@tool
class_name LicenseDatabaseEntry
extends Resource


enum Category {
	MISC,
	MODEL,
	TEXTURE,
	MUSIC,
	SFX,
}


enum License {
	UNKNOWN,
	CUSTOM,
	CC0,
	CC_BY_3,
	CC_BY_4,
}


const INCOMPLETE_PREFIX := "⚠ "


@export_file var asset : String

@export var license := License.UNKNOWN

@export var author : String

@export var original_name : String

@export var category := Category.MISC

@export var description : String

@export var source : String

@export var retrieved : String

@export_multiline var credits : String :
	set(value):
		credits = value
		_try_update_from_credits()
		_check_completeness(true)

@export var is_modified := false


@export_group("Custom License", "custom_license_")

@export var custom_license_name : String

@export var custom_license_url : String

@export_file var custom_license_file : String

@export_multiline var custom_license_text : String


static var _credits_parsers : Array[LicenseCreditsParser] = []


func generate_credits() -> String:
	assert(not original_name.is_empty())

	var generated_credits := "\"%s\"" % original_name
	if not author.is_empty():
		generated_credits += " by " + author
	generated_credits += " is licensed under " + get_license_name()
	var url := get_license_url()
	if not url.is_empty():
		generated_credits += " (%s)" % url
	return generated_credits


func get_license_name() -> String:
	match license:
		License.CC0: return "CC0"
		License.CC_BY_3: return "CC BY 3.0"
		License.CC_BY_4: return "CC BY 4.0"
		License.CUSTOM:
			return custom_license_name if not custom_license_name.is_empty() else "Custom License"

	return "Unknown License"


func get_license_url() -> String:
	match license:
		License.CC0: return "https://creativecommons.org/publicdomain/zero/1.0/"
		License.CC_BY_3: return "https://creativecommons.org/licenses/by/3.0/"
		License.CC_BY_4: return "https://creativecommons.org/licenses/by/4.0/"
		License.CUSTOM: return custom_license_url

	return ""


func update() -> void:
	assert(not asset.is_empty())

	if not FileAccess.file_exists(asset):
		_error("Asset not found.")
		return

	_try_update_from_credits()
	_try_update_license()
	_try_update_from_import_config()

	_check_completeness()


func _check_completeness(silent := false) -> void:
	var is_incomplete := false

	if license == License.UNKNOWN:
		if not silent:
			_warning("License is unknown.")
		is_incomplete = true

	if author.is_empty():
		if not silent:
			_warning("Author is unknown.")
		is_incomplete = true

	if original_name.is_empty():
		original_name = asset.get_file().get_basename()
		_warning("Using file name as original name.")

	if source.is_empty():
		if not silent:
			_warning("Source is unknown.")
		is_incomplete = true

	if retrieved.is_empty():
		retrieved = Time.get_datetime_string_from_system(true, true)
		_warning("Using current time as retrieval date.")

	if resource_name.is_empty() or resource_name == INCOMPLETE_PREFIX:
		resource_name = asset.get_file()

	var has_incomplete_prefix := resource_name.begins_with(INCOMPLETE_PREFIX)
	if is_incomplete != has_incomplete_prefix:
		resource_name = INCOMPLETE_PREFIX + resource_name if is_incomplete else resource_name.trim_prefix(INCOMPLETE_PREFIX)


func _try_update_from_import_config() -> void:
	var config := _load_import_config()
	if config == null:
		return

	var importer : String = config.get_value("remap", "importer", "")
	var type : String = config.get_value("remap", "type", "")
	_update_category_from_importer(importer, type)


func _update_category_from_importer(importer : String, type : String) -> void:
	match importer:
		"texture": _set_category([Category.TEXTURE])
		"scene": _set_category([Category.MODEL])
		_:
			if type.begins_with("AudioStream"):
				_set_category(
					[Category.SFX, Category.MUSIC],
					"Specific audio asset category cannot be determined. Assuming SFX."
				)
			else:
				_warning("Unable to determine asset category.")


func _set_category(valid_categories : Array[Category] = [], uncertainty_message := "") -> void:
	if not category in valid_categories:
		category = valid_categories[0]
		if valid_categories.size() > 1:
			_warning(uncertainty_message)
		else:
			_print("Determined asset category.")


func _try_update_license() -> void:
	var license_file := asset.get_basename() + ".license.txt"
	if FileAccess.file_exists(license_file):
		if license == License.UNKNOWN:
			license = License.CUSTOM
			custom_license_file = license_file
			_print("Found custom license file.")
		elif license != License.CUSTOM or custom_license_file == license_file:
			_warning("Found custom license file that does not match the configured license.")
	elif license == License.CUSTOM:
		if custom_license_file.is_empty() and custom_license_text.is_empty():
			_warning("Missing custom license text or file.")
		elif not custom_license_file.is_empty() and not FileAccess.file_exists(custom_license_file):
			_error("Custom license file not found: " + custom_license_file)


func _try_update_from_credits() -> void:
	var result := _try_parse_credits()
	if result == null:
		return

	var parsed_original_name := result.get_string("original_name")
	if not parsed_original_name.is_empty() and original_name != parsed_original_name:
		original_name = parsed_original_name
		_print("Parsed original name from credits.")

	var parsed_author := result.get_string("author")
	if not parsed_author.is_empty() and author != parsed_author:
		author = parsed_author
		_print("Parsed author from credits.")

	var parsed_source := result.get_string("source")
	if not parsed_source.is_empty() and source != parsed_source:
		source = parsed_source
		_print("Parsed source from credits.")

	var parsed_license_cc0 := result.get_string("license_cc0")
	if not parsed_license_cc0.is_empty() and license != License.CC0:
		license = License.CC0
		_print("Parsed license from credits.")

	var parsed_license_cc_by_3 := result.get_string("license_cc_by_3")
	if not parsed_license_cc_by_3.is_empty() and license != License.CC_BY_3:
		license = License.CC_BY_3
		_print("Parsed license from credits.")

	var parsed_license_cc_by_4 := result.get_string("license_cc_by_4")
	if not parsed_license_cc_by_4.is_empty() and license != License.CC_BY_4:
		license = License.CC_BY_4
		_print("Parsed license from credits.")


func _try_parse_credits() -> RegExMatch:
	if credits.is_empty():
		return null

	for parser in _credits_parsers:
		if parser != null:
			var result := parser.parse(credits)
			if result != null:
				return result
	return null


func _load_import_config() -> ConfigFile:
	var import_file := asset + ".import"
	if not FileAccess.file_exists(import_file):
		return null

	var config := ConfigFile.new()
	config.load(import_file)
	return config


func _print(message : String) -> void:
	print_rich("[b]Licenses[/b] | ", message)


func _warning(message : String) -> void:
	print_rich("[color=orange][b]Licenses[/b] | %s[/color]" % message)


func _error(message : String) -> void:
	print_rich("[color=tomato][b]Licenses[/b] | %s[/color]" % message)
