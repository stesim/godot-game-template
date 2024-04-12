@tool
extends EditorExportPlugin


const COI_SERVICEWORKER_FILE := "coi-serviceworker.min.js"

const COI_SCRIPT_INCLUDE := "<script src=\"" + COI_SERVICEWORKER_FILE + "\"></script>"

const COI_ENABLE_OPTION := &"coi_serviceworker/enable"


var _plugin_directory := (get_script() as Script).resource_path.get_base_dir()

var _check_option := false


func _get_name() -> String:
	return "COI Serviceworker"


func _supports_platform(platform : EditorExportPlatform) -> bool:
	return true


func _get_export_options(platform : EditorExportPlatform) -> Array[Dictionary]:
	if not platform is EditorExportPlatformWeb:
		return []

	if not _check_option:
		_check_option = true
	elif get_option(COI_ENABLE_OPTION) == true:
		var head_include := get_option(&"html/head_include") as String
		if not head_include.contains(COI_SCRIPT_INCLUDE):
			push_warning("To use coi-serviceworker add the following to html/head_include: ", COI_SCRIPT_INCLUDE)

	return [{
		option = {
			name = COI_ENABLE_OPTION,
			type = TYPE_BOOL,
		},
		default_value = false,
	}]


func _export_begin(features : PackedStringArray, _is_debug : bool, path : String, _flags : int) -> void:
	if not "web" in features:
		return

	if get_option(COI_ENABLE_OPTION) == true:
		var export_directory := path.get_base_dir()
		DirAccess.copy_absolute(
			_plugin_directory.path_join(COI_SERVICEWORKER_FILE),
			export_directory.path_join(COI_SERVICEWORKER_FILE),
		)


func _export_file(path : String, _type : String, _features : PackedStringArray) -> void:
	if path.begins_with(_plugin_directory):
		print(path)
		skip()
