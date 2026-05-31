# Narrative
# --------
# VIDEO PROCESSING
#
# Extracted from stzsystemcalldatatest.ring, block #17.

load "../../../stzBase.ring"

==========================================

pr()

# Convert video to GIF
Sy = new stzSystemCall(:VideoToGif)
Sy {
	SetParam(:video, "demo.mp4")
	SetParam(:output, "demo")
	Run()
	
	if Succeeded()
		? "GIF created: demo.gif"
	ok
}

# Extract audio
new stzSystemCall(:ExtractAudio) {
	SetParams([
		[:video, "demo.mp4"],
		[:output, "audio.mp3"]
	])
	Run()
}

pf()
