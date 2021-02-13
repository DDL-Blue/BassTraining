tool

extends Node2D

export var base_tone : int = 0 setget set_base_tone
export var tone_number : int = 8 setget set_tone_number

export var tone_offset : float = 64.0

signal pressed(tone)

var active = true
var bound_high = 999
var bound_low = 0

var tones = []

func set_base_tone(value : int):
	base_tone = value
	generate_tones()

func set_tone_number(value : int):
	tone_number = value
	generate_tones()
	
func generate_tones():
	#string thickness
	if $String != null:
		$String.scale = Vector2($String.scale.x, 6.5 - base_tone/3 )
	
	for child in get_children():
		var tone = child as Tone
		if tone:
			tone.queue_free()
		
	tones.clear()
	
	for i in range(tone_number):
		var newTone = preload("res://Tone.tscn").instance()
		newTone.toneNumber = base_tone + i
		newTone.mode = Tone.MODE.NORMAL
		newTone.position = Vector2(i*tone_offset, 0.0)
		newTone.connect("pressed", self, "_on_Tone_pressed")
		add_child(newTone)
		tones.push_back(newTone)
	
func set_mode(value : int):
	for ch in tones:
		var tone = ch as Tone
		tone.mode = value
		
func set_tone_mode(note : int, value : int, canEnable : bool):
	for ch in tones:
		var tone = ch as Tone
		if tone.toneNumber == note:
			if canEnable || tone.mode != Tone.MODE.DISABLED:
				tone.mode = value
			
func clear_highlights():
	for ch in tones:
		var tone = ch as Tone
		tone.clear_highlights()

func set_show_tone_names(value : bool):
	for ch in tones:
		var tone = ch as Tone
		tone.show_name = value

func set_bounds(low : int, high : int):
	bound_low = low
	bound_high = high
	
	if !active:
		return
	
	for i in range(tones.size()):
		var mode = Tone.MODE.NORMAL
		if i< low || i > high:
			mode = Tone.MODE.DISABLED
		(tones[i] as Tone).mode = mode

func get_enabled_tones() -> Dictionary:
	var res = {}
	for ch in tones:
		var tone = ch as Tone
		if tone.mode != Tone.MODE.DISABLED:
			res[tone.toneNumber] = true
		
	return res

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_tones()

func _on_Tone_pressed(tone : int):
	emit_signal("pressed", tone)

func _on_Disable_toggled(button_pressed):
	active = button_pressed
	if active:
		set_bounds(bound_low, bound_high)
	else:
		set_mode(Tone.MODE.DISABLED)
