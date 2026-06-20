# Narrative
# --------
# TypesXT(): each item paired with its type name.
#
# Where Types() returns just the type of every item, TypesXT ("extended")
# zips each ITEM together with its type -- handy for inspecting a mixed
# list at a glance: "AB" is a STRING, 12 a NUMBER, ["A","B"] a LIST.
#
# Extracted from stzlisttest.ring, block #334.

load "../../stzBase.ring"

pr()

? @@( Q([ "AB", 12, ["A", "B"] ]).TypesXT() )
#--> [ [ "AB", "STRING" ], [ 12, "NUMBER" ], [ [ "A", "B" ], "LIST" ] ]

pf()
# Executed in almost 0 second(s)
