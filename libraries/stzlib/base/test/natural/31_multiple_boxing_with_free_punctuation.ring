# Narrative
# --------
# MULTIPLE BOXING (WITH FREE PUNCTUATION)
#
# Extracted from stznaturaltest.ring, block #31.
#ERR Error (R14) : Calling Method without definition: findantisectionszz

load "../../stzBase.ring"


pr()

Naturally("
    Make a string with 'i ♥ niamey'
    @box it ~ Spacify it ~ and Uppercase it
    the box@ must be rounded
    @box it again
    yet this second box@ should be rounded as well
    Display the result
    @box it, spacify it, and Uppercase it.
    the box@ must be rounded...
    @box it again!
    Yet: this second box@ should be rounded as well.
    Display the result...
")
#-->
# ╭─────────────────────────╮
# │ ╭─────────────────────╮ │
# │ │ I   ♥   N I A M E Y │ │
# │ ╰─────────────────────╯ │
# ╰─────────────────────────╯

pf()
# Executed in 0.03 second(s) in Ring 1.24

#-----------------------------#
#  MULTILINGUAL NATURAL CODE  #
#-----------------------------#
