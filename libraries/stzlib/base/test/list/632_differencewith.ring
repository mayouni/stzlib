# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #632.
#ERR Error (R14) : Calling Method without definition: commonitemswith

load "../../stzBase.ring"

pr()

o1 = new stzList([ "green", "red" ])

? @@( o1.DifferenceWith([ "b","x", "a", "f"]) ) # Or DifferentItemsWith()
# (fixed a stray ")" in the recorded output) -- symmetric difference
#--> [ "green", "red", "b", "x", "a", "f" ]

? @@( o1.CommonItemsWith([ "b","x", "a", "f"]) ) # or Intersection()
# []

? o1.ContainsSameItemsAs([ "red", "green" ])
#--> TRUE

? o1.ContainsSameItemsAs([ "a", "b", "c", "f" ])
#--> FALSE

pf()
#--> Executed in 0.02 second(s).
