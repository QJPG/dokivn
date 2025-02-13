"""
Unsupported Yet
"""
extends RefCounted

class_name VNView

class Intent extends RefCounted:
	pass

class IntentDraw extends Intent:
	var image : Image
	var offset : Vector2
	
	func _init(image : Image) -> void:
		self.image = image

var attr_parent : Scripted
var attr_intents : Dictionary[String, Intent]

func _init(parent : Scripted) -> void:
	self.attr_parent = parent

func image(name : String, image : Image) -> IntentDraw:
	
	return
