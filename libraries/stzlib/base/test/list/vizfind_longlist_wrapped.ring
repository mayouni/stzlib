# Narrative
# --------
# VizFind on a long, NESTED list -- wrapping + shallow-vs-deep marking.
#
# The rendering wraps into fixed-width lines (default 50 cols), drawing the
# marker row(s) beneath EACH line with a blank line between wrapped blocks; the
# "(count)" of an XT form prints once at the end of the last block. The code
# line is indented by the label width so the "^" carets sit under their items.
#
# SHALLOW (VizFind / VizFindXT / VizFindMany): marks only TOP-LEVEL occurrences
# -- an "A" nested inside a sub-list [ "A", "B" ] is NOT marked. DEEP
# (VizDeepFind / VizDeepFindXT): marks occurrences at any depth. In both, the
# "(count)" is the total number of occurrences in the data.
#
# Authored example (not extracted).

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A","B","A",[ "A", "B" ], "C","A","D","E", [ "A", "B" ], "A","B" ])

# Shallow: the "A" inside each [ "A", "B" ] is left unmarked
? o1.VizFindXT("A")
#-->       [ "A", "B", "A", [ "A", "B" ], "C", "A", "D", "E",
#    "A" :  --^---------^-----------------------^------------
#
#           [ "A", "B" ], "A", "B" ]
#    "A" : ----------------^-------- (6)

? ""

# Deep: every "A" is marked, including the two nested in sub-lists
? o1.VizDeepFindXT("A")
#-->       [ "A", "B", "A", [ "A", "B" ], "C", "A", "D", "E",
#    "A" :  --^---------^------^----------------^------------
#
#           [ "A", "B" ], "A", "B" ]
#    "A" : ----^-----------^-------- (6)

pf()
# Executed in 0.01 second(s).
