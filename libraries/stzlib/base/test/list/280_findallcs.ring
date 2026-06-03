# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #280.

load "../../stzBase.ring"

pr()

# Checking that Softanza function does not alter a gloabl
# svariable et in the calling program

nPos = 20
paList = [ "A", "B", "C" ]

? @FindAllCS([ 1, 2, "♥", 4, "♥", 6, "♥" ], "♥", TRUE)
#--> [ 3, 5, 7 ]

? paList
#--> [ "A", "B", "C" ]

? nPos
#--> 20

pf()
# Executed in almost 0 second(s) in Ring 1.22
