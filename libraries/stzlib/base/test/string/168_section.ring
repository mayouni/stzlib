# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #168.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

? Q("SOFTANZA").Section(:From = "F", :To = "A") #--> "FTA"

? Q("SOFTANZA").CharsQ().Section(:From = "F", :To = "A")
#--> ["F", "T", "A"]

pf()
# Executed in 0.10 second(s)
