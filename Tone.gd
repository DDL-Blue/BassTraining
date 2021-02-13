tool
extends Node2D

class_name Tone

enum MODE {
	DISABLED,
	NORMAL,
	HIGHLIGHT_GENERAL,
	HIGHLIGHT_CORRECT,
	HIGHLIGHT_WRONG,
}

export var toneNumber : int = 0 setget set_tone_number
export(MODE) var mode : int = MODE.NORMAL setget set_mode

export var show_name : bool = true setget set_show_name

signal pressed(tone)

var TONES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]

func set_mode(value : int):
	mode = value
	$Button.disabled = value == MODE.DISABLED
	match value:
		MODE.HIGHLIGHT_CORRECT:
			$Button.modulate = Color.green
		MODE.HIGHLIGHT_GENERAL:
			$Button.modulate = Color.yellow
		MODE.HIGHLIGHT_WRONG:
			$Button.modulate = Color.red
		_:
			$Button.modulate = Color.white
	update_name()
				


func set_tone_number(value : int):
	if value < 0:
		return
	toneNumber = value
	update_name()
	
func set_show_name(value : bool):
	show_name = value
	update_name()
	
func update_name():
	if show_name || mode == MODE.HIGHLIGHT_CORRECT:
		$Button.text = TONES[toneNumber % 12]
	else:
		$Button.text = "o"
	
func clear_highlights():
	if mode != MODE.DISABLED:
		set_mode(MODE.NORMAL)
	update_name()

func _on_Button_pressed():
	emit_signal("pressed", toneNumber)
