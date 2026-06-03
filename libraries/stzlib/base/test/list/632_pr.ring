# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #632.

load "../../stzBase.ring"


o1 = new stzList([ "green", "red" ])

? o1.DifferenceWith([ "b","x", "a", "f"]) # Or DifferentItemsWith()
#--> [ "green", "red", "b","x", "a", "f"])

? @@( o1.CommonItemsWith([ "b","x", "a", "f"]) ) # or Intersection()
# []

? o1.ContainsSameItemsAs([ "red", "green" ])
#--> TRUE

? o1.ContainsSameItemsAs([ "a", "b", "c", "f" ])
#--> FALSE

pf()
#--> Executed in 0.02 second(s).
