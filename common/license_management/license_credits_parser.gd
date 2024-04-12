@tool
class_name LicenseCreditsParser
extends Resource


@export var description : String

@export_multiline var regex : String :
	set(value):
		regex = value
		_compiled_regex.compile(regex)


var _compiled_regex := RegEx.new()


func parse(string : String) -> RegExMatch:
	return _compiled_regex.search(string) if _compiled_regex.is_valid() else null
