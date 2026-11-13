# Narrative
# --------
# pr()
#
# Extracted from stzRegexTest.ring, block #47.
#
# CORRECTED 2026-11-13. This block built `new stzRegex("")` and asserted that an
# empty pattern matches any text. Two things were wrong, and both stayed invisible
# because the file could not run at all:
#
#   - the constructor has refused an empty pattern since it was tightened, so
#     nothing here executed and the promise below was charged as a divergence
#     rather than reported as a file that never ran
#   - the premise was false anyway. Reaching an empty pattern the way SetPattern
#     used to allow -- new stzRegex("x") then SetPattern("") -- and then asking it
#     to match answers 0: an empty pattern matched NOTHING, not anything.
#
# DECIDED 2026-11-13: an empty pattern is not legal. init refused one while
# SetPattern accepted one, so the object refused at birth a state it allowed one
# line later, and the state was useless when you reached it. SetPattern refuses it
# now too, and the two halves of the contract agree.
#
# This file asserts that refusal, which is what the library does.

load "../../stzBase.ring"


pr()

# An empty pattern is refused at construction.

try
	rx = new stzRegex("")
	? "NOT REFUSED"

catch
	? "empty pattern refused at construction"
done
#--> empty pattern refused at construction

# ...and refused by SetPattern too, which used to accept it silently.

rx = new stzRegex("abc")

try
	rx.SetPattern("")
	? "NOT REFUSED"

catch
	? "empty pattern refused by SetPattern"
done
#--> empty pattern refused by SetPattern

# The refusal leaves the object as it was -- the check runs before the compiled
# pattern is freed.

? rx.Pattern()
#--> abc

# And a real pattern still matches.

? rx.Match("abc")
#--> TRUE

pf()
