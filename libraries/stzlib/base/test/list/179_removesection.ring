# Narrative
# --------
# RemoveSection(n1, n2) vs RemoveRange(start, count): two ways to delete a
# contiguous run of items.
#
# RemoveSection takes the END positions (remove items 3..5); RemoveRange
# takes a START and a COUNT (remove 3 items from position 3). On this list
# both delete the three "_" placeholders, leaving [ "1","2","3","4" ]. Both
# mutate the list in place.
#
# (The extracted file had two pr()/pf() blocks joined by a stray "*----"
# separator -- merged here into one runnable script.)
#
# Extracted from stzlisttest.ring, block #179.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "2", "_", "_", "_", "3", "4" ])
o1.RemoveSection(3, 5)
? @@( o1.Content() )
#--> [ "1", "2", "3", "4" ]

o1 = new stzList([ "1", "2", "_", "_", "_", "3", "4" ])
o1.RemoveRange(3, 3)
? @@( o1.Content() )
#--> [ "1", "2", "3", "4" ]

pf()
# Executed in 0.03 second(s)
