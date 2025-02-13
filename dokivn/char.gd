extends RefCounted

class_name VNChar

var attr_address : int
var attr_parent : Scripted
var attr_name : String
var attr_color : Color

func _init(address : int, parent : Scripted) -> void:
	self.attr_address = address
	self.attr_parent = parent

func color(color : Color) -> VNChar:
	self.attr_color = color
	return self

func says(text : String) -> VNChar:
	assert(self.attr_parent != null)
	self.attr_parent.says(text, self.attr_address)
	#_parent.register(VNTree.DialogText.new(_address, text))
	return self

func name(name : String) -> VNChar:
	self.attr_name = name
	return self
