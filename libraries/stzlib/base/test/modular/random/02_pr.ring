# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #2.

load "../../../stzBase.ring"


# Full ranomisation of the positions of all the items

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.Randomize() # Full shuffle
? @@( o1.Content() )
#--> [ "D", 4, "A", 3, "C", 2, 1, "B" ]

# Randomising the positions of only numbers

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeNumbers()
? @@( o1.Content() )
#--> [ 4, 1, 2, 3, "A", "B", "C", "D" ]

# Randomising the positions of only items in a section

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeSection(5, 8) # Partial shuffle
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, "D", "A", "C", "B" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
