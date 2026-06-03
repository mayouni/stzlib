# Narrative
# --------
# Face detection with python
#
# Extracted from stzpythoncodeTest.ring, block #8.

load "../../stzBase.ring"

pr()

#TODO ExterLib

View("face.jpg")

py() { BoxFaceXT("face.jpg", [ :SaveAs = "face2.jpg", :Details = TRUE ]) }

View("face2.jpg")

pf()
