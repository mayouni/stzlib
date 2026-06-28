# Narrative
# --------
# VizFind on a NESTED list: shallow vs deep marking, and searching a sub-list.
#
# o1 holds "A" at four TOP-LEVEL slots (1,3,6,10) and twice more inside the two
# sub-lists [ "A", "B" ] (deep).
#
#  - VizFindXT (shallow): marks only the top-level "A"; the "(count)" equals what
#    Find returns -- the 4 top-level items.
#  - VizDeepFindXT (deep): marks every "A", nested ones too; "(count)" = 6.
#  - The searched value may itself be a sub-list: being WIDE, its match is
#    underlined across its whole footprint, not pinned to one caret.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A","B","A",[ "A", "B" ], "C","A","D","E", [ "A", "B" ], "A","B" ])

# Find reports the 4 top-level items; the shallow viz must agree
? @@( o1.FindAll("A") )
#--> [ 1, 3, 6, 10 ]

# SHALLOW -- nested "A"s left unmarked, (4)
? o1.VizFindXT("A")
#-->       [ "A", "B", "A", [ "A", "B" ], "C", "A", "D", "E",
#    "A" :  --^---------^-----------------------^------------
#
#           [ "A", "B" ], "A", "B" ]
#    "A" : ----------------^-------- (4)

? ""

# DEEP -- every "A" marked, including the two nested, (6)
? o1.VizDeepFindXT("A")
#-->       [ "A", "B", "A", [ "A", "B" ], "C", "A", "D", "E",
#    "A" :  --^---------^------^----------------^------------
#
#           [ "A", "B" ], "A", "B" ]
#    "A" : ----^-----------^-------- (6)

? ""

# A LIST value: each [ "A", "B" ] item is underlined across its full width, (2)
? o1.VizFindXT([ "A", "B" ])
#-->                [ "A", "B", "A", [ "A", "B" ], "C", "A", "D", "E",
#    [ "A", "B" ] :  ----------------^^^^^^^^^^^^---------------------
#
#                     [ "A", "B" ], "A", "B" ]
#    [ "A", "B" ] : -^^^^^^^^^^^^------------ (2)

pf()
# Executed in 0.01 second(s).
