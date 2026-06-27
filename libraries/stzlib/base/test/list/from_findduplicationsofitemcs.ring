# Narrative
# --------
# The duplicate-finding API of stzList (it came from the list-of-strings
# tests, but every method works on a plain stzList of any item type).
#
# Vocabulary: the "duplicates" of an item are its 2nd-and-later occurrences
# (the first one is the original). So in this list "tunis" appears 7 times
# case-sensitively -> 6 duplicates; "regueb" appears twice -> 1 duplicate.
#  - ...OfString / ...OfItem  : ask about ONE specific value
#  - FindDuplicates()         : the duplicate POSITIONS across the whole list
#  - DuplicatedStrings()      : the distinct values that ARE duplicated
#  - the CS forms take a case dial (:CS = TRUE|FALSE), so "tunis" can match
#    "Tunis" at position 13.
#
# Extracted from stzlistofstringstest.ring, block #91.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

# --- asking about ONE value -------------------------------------------------

# case-insensitive: "Tunis" at 13 counts as a duplicate of "tunis"
? @@( o1.FindDuplicationsOfItemCS("tunis", :CS = FALSE) )
#--> [ 2, 3, 5, 6, 8, 9, 13 ]

? o1.ContainsDuplicatedString("regueb")
#--> TRUE

? @@( o1.FindDuplicatedString("regueb") )
#--> [ 10, 12 ]

? o1.NumberOfDuplicatesOfString("tunis")
#--> 6

? o1.NumberOfDuplicatesOfString("regueb")
#--> 1

? o1.StringIsDuplicatedNTimes("tunis", 6)
#--> TRUE

? o1.StringIsDuplicatedNTimes("regueb", 1)
#--> TRUE

? @@( o1.FindDuplicatesOfString("tunis") )
#--> [ 2, 3, 5, 6, 8, 9 ]

? @@( o1.FindDuplicatesOfString("regueb") )
#--> [ 12 ]

# --- asking about the WHOLE list --------------------------------------------

? o1.NumberOfDuplicatedStrings()
#--> 2

? @@( o1.DuplicatedStrings() )
#--> [ "tunis", "regueb" ]

# duplicate positions (2nd+ occurrences) across the list
? @@( o1.FindDuplicates() )
#--> [ 2, 3, 5, 6, 8, 9, 12 ]

# FindDuplicatesXT: positions of ALL occurrences of any duplicated item
# (the first occurrence included)
? @@( o1.FindDuplicatesXT() )
#--> [ 1, 2, 3, 5, 6, 8, 9, 10, 12 ]

# each duplicated value paired with its duplicate positions (the keyed view)
? @@( o1.DuplicatesZ() )
#--> [ [ "tunis", [ 2, 3, 5, 6, 8, 9 ] ], [ "regueb", [ 12 ] ] ]

pf()
