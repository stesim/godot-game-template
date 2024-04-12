@tool
extends EditorPlugin


const CoiExportPlugin := preload("coi_export_plugin.gd")


var _export_plugin : EditorExportPlugin


func _enter_tree() -> void:
	_export_plugin = CoiExportPlugin.new()
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null
