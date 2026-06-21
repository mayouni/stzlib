# Narrative
# --------
# Demonstrates @FindAllCS(), the global case-sensitive "find all
# positions" function, and proves it leaves the caller's globals intact.
#
# @FindAllCS(list, item, bCaseSensitive) returns the 1-based positions
# of every occurrence of item in list. Here the heart emoji appears at
# slots 3, 5 and 7, so the result is [ 3, 5, 7 ]. The surrounding checks
# re-print paList and nPos to confirm the function is side-effect free:
# the global list [ "A", "B", "C" ] and the scalar 20 are untouched after
# the call. This guards the Softanza idiom that global helpers operate on
# copies and never silently mutate state in the calling program.
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
