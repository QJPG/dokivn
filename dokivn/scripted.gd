extends RefCounted

class_name Scripted

enum Error {
	ERR = -1,
	OK = 0
}

const NO_CHAR := -1

signal confirm
signal unlock_context

var from : Node
var char : Dictionary[int, VNChar]
var tree : VNTree
var dialog_displaying : bool
var double_layer : bool
var layer_child : VNTree.Child

var char_output : int = NO_CHAR
var text_output : String
var vrat_output : float = 0.0
var opacity_output : float = 1.0
var screen : Window

func _count_vratio(progress : int = 0, delay := 0.02) -> void:
	var cur := float(progress) / float(text_output.length())
	vrat_output = cur
	
	if not dialog_displaying:
		return
	
	if vrat_output < text_output.length() / text_output.length():
		if not from or not from.get_tree():
			return
		
		await from.get_tree().create_timer(delay).timeout
		_count_vratio(progress + 1, delay)

func _init() -> void:
	self.tree = VNTree.new()
	return

func pause() -> void:
	register(VNTree.Yield.new(false))
	return

func resume() -> void:
	register(VNTree.Yield.new(true))
	return

func layer_init() -> void:
	layer_child = VNTree.Child.new()
	double_layer = true

func layer_start() -> void:
	await exec(layer_child)
	layer_quit()

func layer_quit() -> void:
	layer_child = null
	double_layer = false

func hide() -> void:
	register(VNTree.Opacity.new(0.0))

func show() -> void:
	register(VNTree.Opacity.new(1.0))

func alert(text : String, title := "") -> void:
	OS.alert(text, title)

func character() -> VNChar:
	var address := randi()
	
	if char.has(address):
		randomize()
		return character()
	
	char[address] = VNChar.new(address, self)
	return char[address]

func get_character() -> VNChar:
	if char_output != NO_CHAR:
		return char[char_output]
	return null

func register(child : VNTree.Child, parent := tree.root) -> void:
	assert(tree != null and parent != null)
	
	if double_layer:
		if layer_child:
			parent = layer_child
	
	child.parent = parent
	parent.childs.push_back(child)
	return

func choices(label : String) -> VNOption:
	var o := VNOption.new(label, self)
	register(VNTree.Choice.new(o))
	return o

func says(text : String, character : int = NO_CHAR) -> void:
	show()
	register(VNTree.DialogText.new(character, text))
	return

func wait(time : float, async := false) -> void:
	register(VNTree.WaitTime.new(async, time))
	return

func entry(text : String, placeholder := "", hint := "", required : bool = true, ok : Callable = Callable()) -> void:
	register(VNTree.Entry.new(text, "", placeholder, hint, ok, required))
	return

func jump(callback : Callable, params := []) -> void:
	register(VNTree.Jump.new(callback, params))
	return

func exec(child : VNTree.Child) -> int:
	if not child:
		return Error.OK
	
	if child is VNTree.DialogText:
		dialog_displaying = true
		vrat_output = 0.0
		char_output = child.author if char.has(child.author) else NO_CHAR
		text_output = child.text
		await _count_vratio()
		await confirm
		dialog_displaying = false
	
	elif child is VNTree.WaitTime:
		if child.async:
			from.get_tree().create_timer(child.time).timeout.connect(func() -> void:
				for ch in child.childs:
					await exec(ch))
		else:
			await from.get_tree().create_timer(child.time).timeout
	
	elif child is VNTree.Entry:
		var e := AcceptDialog.new()
		var l := LineEdit.new()
		l.text = child.placeholder
		l.placeholder_text = child.hint
		l.text_submitted.connect(func(text : String) -> void:
			e.get_ok_button().grab_focus())
		e.title = child.title
		e.dialog_text = child.text
		#e.exclusive = true
		e.always_on_top = true
		e.dialog_close_on_escape = false
		e.add_child(BoxContainer.new())
		(e.get_child(0) as BoxContainer).vertical = true
		e.get_child(1, true).reparent(e.get_child(0), true)
		(e.get_child(0) as BoxContainer).add_child(l)
		e.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		e.borderless = true
		e.extend_to_title = true
		screen = e
		from.add_child(e)
		e.show()
		await e.confirmed
		e.queue_free()
		if child.required and l.text.length() < 1:
			return await exec(child)
		else:
			child.ok.call(l.text)
	
	elif child is VNTree.Jump:
		if child.callback.is_valid():
			child.callback.callv(child.params)
	
	elif child is VNTree.Choice:
		if child.option.attr_options.size() < 1:
			pass
		
		else:
			var p := PopupPanel.new()
			var v := VBoxContainer.new()
			var t := Label.new()
			t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			t.text = child.option.attr_label
			v.alignment = BoxContainer.ALIGNMENT_CENTER
			v.add_child(t)
		
			for option in child.option.attr_options:
				var op := Button.new()
				op.text = option.label
				op.pressed.connect(func() -> void:
					p.queue_free()
					option.callback.call())
				v.add_child(op)
			
			p.size = Vector2i(
				DisplayServer.window_get_size().x / 2,
				DisplayServer.window_get_size().y
			)
			p.always_on_top = true
			#p.exclusive = true
			p.transparent = true
			p.transparent_bg = true
			p.borderless = true
			p.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
			p.add_child(v)
			screen = p
			from.add_child(p)
			p.show()
			
			await p.tree_exited
	
	elif child is VNTree.Yield:
		if child.emit:
			unlock_context.emit()
		else:
			await unlock_context
	
	elif child is VNTree.Opacity:
		opacity_output = child.opacity
	
	for ch in child.childs:
		await exec(ch)
	
	return Error.OK

func start() -> void:
	await exec(tree.root)
	return
