# Narrative
# --------
# IMAGE BATCH PROCESSING
#
# Extracted from stzsystemcalldatatest.ring, block #16.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

aImages = ["photo1.jpg", "photo2.jpg", "photo3.jpg"]

_nImages1Len_ = ring_len(aImages)
for _iLoopImages1_ = 1 to _nImages1Len_
	cImage = aImages[_iLoopImages1_]
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
