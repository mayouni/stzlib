# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #550.

load "../../stzBase.ring"

pr()

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])

? o1.FindAllWXT('{ IsUppercase(@item) }')
 #--> [3, 4, 6]

? o1.ItemsWXT('{ IsUppercase(@item) }')
  #--> ["C#", "RING", "RUBY"]

pf()
# Executed in 0.25 second(s).
