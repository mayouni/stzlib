# Narrative
# --------
# #internal
#
# Extracted from stzlisttest.ring, block #237.

load "../../stzBase.ring"


pr()

o1 = new stzList([ 10, [ :Tunis, :Paris ], "ONE," ])
? o1.StringifyAndReplaceQ(",", "*").Content()
#--> [ "10", '[ "tunis"* "paris" ]', "ONE*" ]

pf()
# Executed in 0.01 second(s)
