# Narrative
# --------
# CHANGE OPERATION
#
# Extracted from stznaturaltest.ring, block #17.

load "../../stzBase.ring"


pr()

Naturally('
    Create a string with "change me"
    Change "me" to "this"
    change "me" to "thisd"  // note: returns empty if equal to "this"
    Show the result
')
#--> change this

pf()
