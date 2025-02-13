*DokiVN is inspired by the "renpy" language, making it easy to program dialogues and interactions of a Visual Novel using only GDScript.*

![image](https://github.com/user-attachments/assets/a81a7ae1-f474-4133-a0b9-9f3eff5be9ac)

- Hello, World w/ DokiVN Lib:
```gdscript
extends Node

var s := Scripted.new()
var e : VNChar

@export var text : RichTextLabel
@export var author : Label

func _init() -> void:
	s.from = self
	e = s.character().name("Eileen").color(Color.GREEN)

func _on_name(response : String) -> void:
	s.layer_init()
	s.alert("Hello, %s!" % response)
	s.layer_start()
	return

func _on_yes() -> void:
	"""
	Layers are needed to create coroutines in the main routine.
	"""
	
	s.layer_init()
	e.says("[b]Nice!![/b]")
	e.says("...")
	s.entry("What is your name?", "", "Insert your name:", true, _on_name)
	e.says("Hehe......")
	s.layer_start()
	s.resume()

func _on_no() -> void:
	s.layer_init()
	e.says("Sorry! :(")
	s.layer_start()
	s.resume()

func _ready() -> void:
	s.says("This is a dialogue without an author!")
	s.hide()	#Set Opacity to 0
	s.wait(1.5)
	e.says("Hello, [wave]Stranger![/wave]")
	s.choices("All good?")\
		.option("Yes!", _on_yes)\
		.option("Leave me alone! :(", _on_no)
	s.pause()	#Wait until a routine unpauses the current routine with ".resume()"!
	s.says("END")
	s.start()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		s.confirm.emit()	#Skip Dialogs
	
	text.text = s.text_output
	text.modulate.a = s.opacity_output
	text.visible_ratio = s.vrat_output
	
	author.text = s.get_character().attr_name if s.get_character() != null else ""
	author.modulate = s.get_character().attr_color if s.get_character() != null else Color.WHITE
	author.modulate.a = s.opacity_output
```
