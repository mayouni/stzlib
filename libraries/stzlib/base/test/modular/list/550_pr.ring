# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #550.

load "../../../stzBase.ring"


o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])

? o1.FindAllWXT('{ Q(@item).IsUppercase() }')
 #--> [3, 4, 6]

? o1.ItemsWXT('{ Q(@item).IsUppercase() }')
  #--> ["C#", "RING", "RUBY"]

pf()
# Executed in 0.25 second(s).
