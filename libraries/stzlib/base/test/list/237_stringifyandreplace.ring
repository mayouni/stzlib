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

# NOTE (not an error -- the method works): Stringify... was historically used
# as a solution for finding anything in a Ring list. Since that is now native in
# the Zig engine, the related Stringify* methods are candidates for removal in a
# later cleanup.

pf()
# Executed in 0.01 second(s)
