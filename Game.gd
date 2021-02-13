extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var strings = []

var reference_tone = -1
var guessed_tone = -1

var rnd = RandomNumberGenerator.new()

func register_signals():
	for s in strings: 
		s.connect("pressed", self, "_on_tone_pressed")

# Called when the node enters the scene tree for the first time.
func _ready():
	strings.push_back($Fretboard/E)
	strings.push_back($Fretboard/A)
	strings.push_back($Fretboard/D)
	strings.push_back($Fretboard/G)
	register_signals()
	rnd.randomize()
	_on_bounds_changed(0)

func generate_interval(singleTone : bool):
	# ----- Gater tones -----
	var tones = {}
	for s in strings:
		var strTones : Dictionary = s.get_enabled_tones()
		for t in strTones.keys():
			tones[t] = true
			
	var toneArray = []
	for t in tones.keys():
		toneArray.push_back(t)
	
	# ----- Tone 1 -----
	var tone1index = rnd.randi() % toneArray.size()
	guessed_tone = toneArray[tone1index]
	
	# ----- Tone 2 -----
	if singleTone:
		reference_tone = -1
		return
	
	toneArray.remove(tone1index)
	
	# Interval bounds
	var intervalMin : int = int($BottomGUI/HBox/Vsplit1/IntervalMin.value)
	var intervalMax : int = int($BottomGUI/HBox/Vsplit2/IntervalMax.value)
	
	var newArray = []
	for tone in toneArray:
		var diff = abs((tone as int) - guessed_tone) 
		if diff >= intervalMin && diff <= intervalMax:
			newArray.push_back(tone)
	toneArray = newArray 
	
	var tone2index = rnd.randi() % toneArray.size()
	reference_tone = toneArray[tone2index]
	
func PlayReference():
	$TonePlayer.PlayTone(reference_tone)
	
func PlayGuessed():
	$TonePlayer.PlayTone(guessed_tone)

func _on_tone_pressed(tone : int):
	$TonePlayer.PlayTone(tone)
	if guessed_tone < 0:
		return
	
	if tone == guessed_tone:
		for s in strings:
			s.set_tone_mode(tone, Tone.MODE.HIGHLIGHT_CORRECT, false)
	else:
		for s in strings:
			s.set_tone_mode(tone, Tone.MODE.HIGHLIGHT_WRONG, false)	
			s.set_tone_mode(guessed_tone, Tone.MODE.HIGHLIGHT_CORRECT, false)	
	
	reference_tone = -1
	guessed_tone = -1
	

func _on_bounds_changed(value):
	var a = 0
	for s in strings:
		s.set_bounds(int($TopGUI/Hbox/VSplit1/FretMin.value), int($TopGUI/Hbox/VSplit2/FretMax.value))


func _on_RandomInterval_pressed():
	generate_interval(false)
	
	# Reset highlights
	for s in strings:
		s.clear_highlights()
		s.set_tone_mode(reference_tone, Tone.MODE.HIGHLIGHT_GENERAL, false)
		
	$Animator.play("PlayInteval")
	

func _on_Listen_pressed():
	if reference_tone >= 0:
		$Animator.play("PlayInteval")
	else:
		PlayGuessed()


func _on_RantomTone_pressed():
	# Just single tone
	generate_interval(true)
	
	PlayGuessed()
	
	# Reset highlights
	for s in strings:
		s.clear_highlights()

func _on_Clear_pressed():
	reference_tone = -1
	guessed_tone = -1
	for s in strings:
		s.clear_highlights()


func _on_ToneNames_toggled(button_pressed):
	for s in strings:
		s.set_show_tone_names(button_pressed)
