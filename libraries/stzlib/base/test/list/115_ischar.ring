# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #115.

load "../../stzBase.ring"

pr()

? IsChar(12.5)
#--> FALSE

? IsChar(-7)
#--> FALSE

? IsChar(14)
#--> FALSE

? IsChar(6)
#--> TRUE

? IsChar("A")
#--> TRUE

? IsChar("م")
#--> TRUE

? IsChar("♥")
#--> TRUE

? IsChar("Hi")
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.21
