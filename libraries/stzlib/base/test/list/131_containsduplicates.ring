# Narrative
# --------
# The full vocabulary of DUPLICATES in Softanza, on one list.
#
# Softanza is deliberate about the difference between:
#   - a DUPLICATE OCCURRENCE (every 2nd+ appearance of an item), and
#   - a DUPLICATED ITEM      (the distinct value that repeats).
# NumberOfDuplicates counts occurrences (4 here); Duplicates lists the
# distinct repeated values ([ "A", "B", 2 ]). FindDuplicates returns the
# positions of the 2nd+ occurrences; FindDuplicatesXT widens that to ALL
# occurrences of any repeated item; the "Origins" forms return where each
# repeated item FIRST appeared. The mirror "NonDuplicated" family covers
# the items that appear exactly once.
#
# A key Softanza correctness point: "2" (string) and 2 (number) are kept
# DISTINCT -- the engine keys items by a type-aware stringification, not
# by Ring's coercing `=`. So position 3 ("2") is never grouped with the
# numeric 2 at positions 7-8.
#
# Extracted from stzlisttest.ring, block #131.

load "../../stzBase.ring"


pr()
	#NOTE // Let's precise the concepts of Duplicates/Duplications,
	# and DuplicateItems, as implemented semantically in Softanza

	o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])

	? o1.ContainsDuplicates() # Or ContainsDuplications() or ContainsduplicatedItems()
	#--> TRUE

	? o1.NumberOfDuplicates() # Or o1.NumberOfDuplicatedItems()
	#--> 4

	? @@( o1.DuplicatesZ() ) # Or DuplicateItemsZ() or DuplicationsZ()
	#--> [ [ "A", [ 4, 5 ] ], [ "B", [ 6 ] ], [ 2, [ 8 ] ] ]

	# ~> "A" is duplicated in positions 4 and 5, "B" is duplicated in position 6,
	# and 2 is duplicated in position 8

	# To get the list of duplicates (or duplicated items):

	? @@( o1.Duplicates() ) # Or o1.DuplicatedItems()
	#--> [ "A", "B", 2 ]

	# To find the positions where these items are duplicated, we say:

	? @@( o1.FindDuplicates() ) # of FindDuplications()
	#--> [ 4, 5, 6, 8 ]

	# --> Note that the first occurrences of "A", "B" and 2 are not counted
	# --> To get them with the positions of duplicates you can use:
	? @@( o1.FindDuplicatesXT() )
	#--> [ 1, 2, 4, 5, 6, 7, 8 ]

	# To get only the first occurrences of each duplicated item, use:

	? @@( o1.FindDuplicatesOrigins() )
	#--> [ 1, 2, 7 ]

	#NOTE // There is an other alternative long name intended for near-natural
	# lanaguage support in Softanza, not for using in normal programming:

	? @@( o1.FindFirstOccurrenceOfEachDuplicatedItem() )
	#--> [ 1, 2, 7 ]

	# What about items that are not duplicated:

	? o1.ContainsItemsNonDuplicated()
	#--> TRUE

	? o1.ContainsAtLeastOneNonDuplicatedItem()
	#--> TRUE

	? o1. ContainsNoDuplications()
	#--> FALSE

	? o1.ContainsNonDuplicatedItems()
	#--> TRUE

	? o1.NumberOfNonDuplicatedItems()
	#--> 2

	? @@( o1.FindNonDuplicatedItems() )
	#--> [ 3, 9 ]

	? @@( o1.NonDuplicatedItems() )
	#--> [ "2", "." ]

	? @@( o1.NonDuplicatedItemsZ() )
	#--> [ [ "2", 3 ], [ ".", 9 ] ]


pf()
# Executed in 0.01 second(s)
