# Narrative
# --------
# TODO: ERROR
#
# Extracted from stzlistofstringstest.ring, block #51.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

# The Yield() function in stzListOfStrings calls the Yield() function
# in stzList. And sp its condition is evaluated there, and CaseSensitivity
# is not supported (==> Remove inheritance alltogethor!)

? @@( o1.Yield("[ @string, This.Find(@string, :CS = FALSE) ]") )

pf()
