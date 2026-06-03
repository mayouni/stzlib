# Narrative
# --------
# CHANGE OPERATION
#
# Extracted from stznaturaltest.ring, block #17.
#ERR Error (C8) : Parentheses ')' is missing

load "../../stzBase.ring"


pr()

Naturally("
    Create a string with 'change me'
    Change 'me' to 'this'
    change 'me' to 'thisd' #ERR returns empy if = "this"
    Show the result
")
#--> change this

pf()
