extends RefCounted

class_name VNOption

class Option extends RefCounted:
	var label : String
	var callback : Callable
	
	func _init(label : String, callback : Callable) -> void:
		self.label = label
		self.callback = callback

var attr_options : Array[Option]
var attr_label : String
var attr_parent : Scripted

func _init(label : String, parent : Scripted) -> void:
	self.attr_label = label
	self.attr_parent = parent

func option(name : String, callback : Callable) -> VNOption:
	attr_options.push_back(Option.new(name, callback))
	return self
