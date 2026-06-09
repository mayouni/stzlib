# Narrative
# --------
# o1 = new stzListOfStrings(  [ "Tunis", "gatufsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
#
# Extracted from stzlistofstringstest.ring, block #107.
#ERR Error (R14) : Calling Method without definition: findnthoccurrencecs

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings(  [ "Tunis", "gatufsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])

? o1.FindNthOccurrenceCS(2, "tunis", TRUE) #--> 5

? @@(o1.StringsContainingCS("tu", TRUE)) # Same as o1.FilterCS("tu", TRUE)
#--> [ "gatufsa","tunis","tunis","tuta" ]

? @@( o1.UniqueStringsContainingCS("tu", TRUE) )
#--> [ "gatufsa", "tunis", "tuta" ]

pf()
