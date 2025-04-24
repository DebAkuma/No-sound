extends Control

@onready var loudness_bar = $SoundLevel  # Reference to the ProgressBar for displaying loudness

var capture_bus_index: int
@warning_ignore("unused_signal")
signal WayTooLoud

const SIGNALPASSCD = 2.0
var time = 0.0

func _ready():
	# Set up microphone capture on "MicCheck" bus
	capture_bus_index = AudioServer.get_bus_index("MicCheck")


func _process(delta):
	# Update the loudness display every frame
	update_loudness_bar(delta)

func update_loudness_bar(delta):
	# Get the peak decibel level from the "PeakDisplay" bus
	var peak_db = AudioServer.get_bus_peak_volume_left_db(capture_bus_index, 0)
	time += delta
	if peak_db > -80:  # -80 dB is typically silence
		var loudness = (clamp((peak_db + 80) / 80.0, 0, 1) ) * 100
		
		if loudness >= 60 and time >= SIGNALPASSCD:
			time = 0.0
			emit_signal("WayTooLoud",Global.player.position)
		loudness_bar.value = loudness 
	else:
		loudness_bar.value = 0
