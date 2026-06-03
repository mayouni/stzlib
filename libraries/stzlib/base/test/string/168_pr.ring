# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #168.

load "../../stzBase.ring"


? Q("SOFTANZA").Section(:From = "F", :To = "A") #--> "FTA"

? Q("SOFTANZA").CharsQ().Section(:From = "F", :To = "A")
#--> ["F", "T", "A"]

pf()
# Executed in 0.10 second(s)
