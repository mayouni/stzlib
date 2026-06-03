# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #602.

load "../../stzBase.ring"

pr()

? L("[1, 2, 3 ]")	#--> [ 1, 2, 3 ]
? L("1:3")		#--> [ 1, 2, 3 ]
? L("A:C")		#--> [ "A", "B", "C"]

? L("#1 : #3")		#--> [ "#1", "#2", "#3" ]
? L("day1 : day3")	#--> [ "day1", "day2", "day3" ]

? L('"♥1" : "♥3"')	#--> [ "♥1", "♥2", "♥3" ]

pf()
# Executed in 0.46 second(s) in Ring 1.22
