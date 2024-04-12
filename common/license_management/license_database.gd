@tool
class_name LicenseDatabase
extends Resource


@export var update := false :
	set(value):
		if value:
			_update()

@export var entries : Array[LicenseDatabaseEntry] = []

@export var credits_parsers : Array[LicenseCreditsParser] :
	get: return LicenseDatabaseEntry._credits_parsers
	set(value):
		LicenseDatabaseEntry._credits_parsers = value


var _scene_extensions := ResourceLoader.get_recognized_extensions_for_type("PackedScene")


func _update() -> void:
	_print("Updating ...")

	var known_assets := _update_entries()
	_create_entries_for_new_imports(known_assets)

	_print("Update finished.")


func _update_entries() -> Dictionary:
	var updated_assets := {}
	for i in entries.size():
		var entry := entries[i]
		if entry == null:
			_error("[%d] no entry" % i)
		elif entry.asset.is_empty():
			_error("[%d] missing asset reference" % i)
		else:
			_print("[%d] %s" % [i, entry.asset])
			entry.update()
			updated_assets[entry.asset] = true

	return updated_assets


func _create_entries_for_new_imports(known_assets : Dictionary) -> void:
	var imported_assets := _scan_for_imported_assets()
	var dependencies := _collect_dependencies(imported_assets)
	var new_assets_added := false
	for asset in imported_assets:
		if not asset in known_assets and not asset in dependencies:
			if not new_assets_added:
				_print("New assets found.")
				new_assets_added = true
			_create_entry_for_asset(asset)


func _scan_for_imported_assets(directory := "res://", assets : Array[String] = []) -> Array[String]:
	var files := DirAccess.get_files_at(directory)
	for file in files:
		if file.get_extension() == "import":
			var asset_file := directory.path_join(file).get_basename()
			assets.push_back(asset_file)

	var sub_directories := DirAccess.get_directories_at(directory)
	for sub_directory in sub_directories:
		_scan_for_imported_assets(directory.path_join(sub_directory), assets)

	return assets


func _collect_dependencies(imported_assets : Array[String]) -> Dictionary:
	var dependencies := {}
	for asset in imported_assets:
		if _is_scene(asset):
			var asset_dependencies := ResourceLoader.get_dependencies(asset)
			for dependency in asset_dependencies:
				var path := dependency.get_slice("::", 2)
				dependencies[path] = asset

	return dependencies


func _create_entry_for_asset(asset : String) -> void:
	var entry := LicenseDatabaseEntry.new()
	entry.asset = asset
	entries.push_back(entry)

	_print("[%d] %s" % [entries.size() - 1, asset])
	entry.update()


func _is_scene(asset : String) -> bool:
	return asset.get_extension() in _scene_extensions


func _print(message : String) -> void:
	print_rich("[b]Licenses[/b] | ", message)


func _error(message : String) -> void:
	print_rich("[color=tomato][b]Licenses[/b] | %s[/color]" % message)
