# Narrative
# --------
# IMAGE BATCH PROCESSING
#
# Extracted from stzsystemcalldatatest.ring, block #16.

load "../../stzBase.ring"

==========================================

pr()

aImages = ["photo1.jpg", "photo2.jpg", "photo3.jpg"]

for cImage in aImages
	cOutput = "thumbnails/" + cImage
	
	new stzSystemCall(:ResizeImage) {
		SetParam(:input, cImage)
		SetParam(:size, "200x200")
		SetParam(:output, cOutput)
		Run()
		
		? "Resized: " + cImage
	}
next

pf()
