# Narrative
# --------
# VizFind on a long, NESTED list -- wrapping, shallow-vs-deep, and any value.
#
# Rendering wraps into fixed-width lines (default 50 cols) with a marker row
# beneath each, a blank line between wrapped blocks, and the "(count)" once at
# the end. The code line is indented by the label width so the "^" carets sit
# under their items.
#
# SHALLOW (VizFindXT): marks only TOP-LEVEL occurrences -- the "A" nested inside
# a sub-list [ "A", "B" ] is NOT marked -- and the "(count)" is what Find returns
# (top-level items: 4). DEEP (VizDeepFindXT): marks every occurrence at any depth
# and counts them all (6). The searched value can itself be a sub-list.
#
# Authored example (not extracted).

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A","B","A",[ "A", "B" ], "C","A","D","E", [ "A", "B" ], "A","B" ])

# Shallow: nested "A"s left unmarked; count = Find's 4 top-level items
? o1.VizFindXT("A")
#-->       [ "A", "B", "A", [ "A", "B" ], "C", "A", "D", "E",
#    "A" :  --^---------^-----------------------^------------
#
#           [ "A", "B" ], "A", "B" ]
#    "A" : ----------------^-------- (4)

? ""

# Deep: every "A" marked, including the two nested in sub-lists; count 6
? o1.VizDeepFindXT("A")
#-->       [ "A", "B", "A", [ "A", "B" ], "C", "A", "D", "E",
#    "A" :  --^---------^------^----------------^------------
#
#           [ "A", "B" ], "A", "B" ]
#    "A" : ----^-----------^-------- (6)

? ""

# The value can be a whole sub-list: marks each [ "A", "B" ] item (2 of them)
? o1.VizFindXT([ "A", "B" ])
#-->                [ "A", "B", "A", [ "A", "B" ], "C", "A", "D", "E",
#    [ "A", "B" ] :  -----------------^-------------------------------
#
#                     [ "A", "B" ], "A", "B" ]
#    [ "A", "B" ] : --^---------------------- (2)

pf()
# Executed in 0.01 second(s).
