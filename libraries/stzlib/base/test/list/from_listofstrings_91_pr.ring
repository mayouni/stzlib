# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #91.

load "../../stzBase.ring"


o1 = new stzList([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? @@( o1.FindDuplicationsOfItemCS("tunis", :CS = FALSE) )
#--> [ 2, 3, 5, 6, 8, 9, 13 ]
# Executed in 0.12 second(s)

? o1.ContainsDuplicatedString("regueb") #--> TRUE
#--> TRUE
# Executed in 0.06 second(s)

? o1.FindDuplicatedString("regueb")
#--> [10, 12]
# Executed in 0.07 second(s)

#--

? o1.NumberOfDuplicatedStrings()
#--> 2
# Executed in 0.25 second(s)

? o1.DuplicatedStrings()
#--> [ "tunis", "regueb" ]
# Executed in 0.24 second(s)

pf()

#----------------

pr()

o1 = new stzList([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? o1.NumberOfDuplicatesOfString("tunis")
#--> 6
#--> Executed in 0.17 second(s)

? o1.NumberOfDuplicatesOfString("regueb")
#--> 1
# Executed in 0.10 second(s)

? o1.StringIsDuplicatedNTimes("tunis", 6)	#--> TRUE
? o1.StringIsDuplicatedNTimes("regueb", 1)	#--> TRUE

? @@( o1.FindDuplicates() )
#--> [ 2, 3, 5, 6, 8, 9, 12 ]

? @@( o1.FindDuplicatesOfString("tunis") )
#--> [ 2, 3, 5, 6, 8, 9 ]

? @@( o1.FindDuplicatesOfString("regueb") )
#--> [ 12 ]

? @@( o1.FindDuplicatesXT() )
#--> [ "tunis" = [ 2, 3, 5, 6, 8, 9 ], [ "regueb" = [ 12 ] ]


pf()
