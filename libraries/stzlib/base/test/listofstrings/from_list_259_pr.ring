# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #259.
#ERR Error (R14) : Calling Method without definition: howmanyduplicates

load "../../stzBase.ring"

pr()

o1 = new stzList([ 5, 7, 5, 5, 4, 7, 1 ])

#NOTE: the same code shown here can work as-is for stzListOfStrings!
# to test it just replace the line above with the following:
//o1 = new stzListOfStrings([ "5", "7", "5", "5", "4", "7", "1" ])

? o1.ContainsDuplicates()
#--> TRUE
# Executed in 0.03 second(s)

? o1.HowManyDuplicates() + NL
#--> 3
# Executed in 0.03 second(s)

? o1.FindDuplicates()
#--> [ 3, 4, 6 ]
# Executed in 0.03 second(s)

? o1.Duplicates() # Or DuplicatesItems()
#--> [5, 7]
# Executed in 0.03 second(s)

? o1.HowManyDuplicatedItems() + NL # Not the same as HowManyDuplicates()
#--> 2
# Executed in 0.04 second(s)

? o1.DuplicatedItems()
#--> [5, 7]
# Executed in 0.04 second(s)

? @@( o1.DuplicatedItemsZ() ) # Same as DuplicatesZ()
#--> [ [ 5, [ 3, 4 ] ], [ 7, [ 6 ] ] ]
#--> the item 5 is duplicated twice at position 3 and 4, and,
#    the item 7 is duplicated once at position 6.

# Executed in 0.06 second(s)

o1.RemoveDuplicates() # Same as RemoveDuplicatedItems()
# Executed in 0.03 second(s)

? @@( o1.Content() )
#--> [ 5, 7, 4, 1 ]

pf()
# Executed in 0.13 second(s)
