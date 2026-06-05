# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #51.

load "../../stzBase.ring"

pr()

? Q('[  "ABC" , "EB" , "AA"  , 12 ]').ToList()
#--> [ "ABC", "EB", "AA", 12 ]

? Q(' "A" : "E" ').ToList()
#--> [ "A", "B", "C", "D", "E" ])

? Q(' "ا" : "ت" ').ToList()
#o--> [ "ا", "ب", "ة", "ت" ]

? Q(' "#1" : "#5" ').ToList()
#--> [ "#1", "#2", "#3", "#4", "#5" ]

pf()
# Executed in 0.12 second(s) in Ring 1.21
# Executed in 0.42 second(s) in Ring 1.18
