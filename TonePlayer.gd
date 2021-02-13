extends Node

export (Array, AudioStreamSample) var samples

func PlayTone(tone : int):
	if tone < 0 || tone >= samples.size():
		return
	
	$Player.stop()
	$Player.stream = samples[tone]
	$Player.play()

