load "stzlib.ring"

/*================

pron()

# Usecase 1: Dividing the string into 3 equal parts
? Q("RingRingRing") / 3
# --> [ "Ring", "Ring", "Ring" ]


# Usecase 2: Splitting the string using a given char (or substring)
? Q("Ring;Python;Ruby") / ";"
# --> [ "Ring", "Python", "Ruby" ]


# Usecase 3: Splitting the string on each char verifying a condition
? Q("Ring:Python;Ruby") / W('Q(@Char).IsNotLetter()')
#--> [ "Ring", "Python", "Ruby" ]


# Usecase 4: Sharing the string equally between three stakeholders
? Q("RingRubyJava") / [ "Qute", "Nice", "Good" ]
# --> [ [ "Qute", "Ring" ], [ "Nice", "Ruby" ], [ "Good", "Java" ] ]


# Usecase 5: Specifying how mutch char we should give to every stakeholder
? Q("IAmRingDeveloper") / [
        :Subject = 1,
        :Verb = 2,
        :Noun1 = 4,
        :Noun2 = :RemainingChars
]
#--> [ :Subject = "I", :Verb = "Am", :Noun1 = "Ring", :Noun2 = "Developer" ]

proff()

/*============

pron()

? @@S([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

proff()

/*================

pron()

o1 = new stzList([
	"*", '"*"', "*4", [ "A", "B" , "'C'"], 12
])

? o1.ToCode()
#--> [ "*", '"*"', "*4", [ "A", "B", "'C'" ], 12 ]

proff()

/*------------------
*/
pron()

//new stzString(:o1 = "str1")

new stzNamedString(:oMyStr = "hi!")
new stzNamedPair(:oMyPair = [ "X", "Y" ])

o1 = new stzList([
	"*", '"*"', oMystr, "*4", [ "A", "B" , oMyPair, "'C'"], 12
])

? o1.ToCode()
#--> [ "*", '"*"', "*4", [ "A", "B", "'C'" ], 12 ]

proff()

/*------------------
*/
pron()

o1 = new stzList([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.ToCode()

proff()

/*--------------

pron()

o1 = new stzList([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? @@S("*") + NL

? @@S(o1.Content()) + NL

? o1.NumberOfOccurrence('"*"')

proff()

/*----------
*/
pron()

o1 = new stzList([
	"*", "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.NumberOfDuplicates()
#--> 2

? @@S( o1.FindDuplicates() )
#--> [10, 15]

? @@S( o1.Duplicates() )
#--> ["*", 4]

? @@S( o1.DuplicatesZ() )
#--> [ "*" = 10, "4" = 15 ]

proff()
# Executed in 0.25 second(s)

/*-----------

pron()

o1 = new stzString("*4*34")

? o1.NumberOfDuplicates()
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

proff()
# Executed in 0.28 second(s)

/*----------

pron()
? "Please wait..."
o1 = new stzString("ring php ringoria")
? o1.NumberOfDuplicates()
#--> 15

? o1.Duplicates()
#--> [
#	"p", " ", "r", "ri", "rin",
#	"ring", "i", "in", "ing", "n", 
#	"ng", "g", "r", "ri","i"
# ]

proff()
# Executed in 3.33 second(s)

/*----------

pron()

o1 = new stzString("RINGORIALAND")
? o1.ContainsDuplicates()
#--> TRUE

# The number of duplicates is 5:
? o1.NumberOfDuplicates()
#--> 5

# But, if we check their positions we get only 4 positions!
? @@S( o1.FindDuplicates() )
#--> [ 6, 7, 10, 11 ]

# The dupicates are effectively 5:
? @@S( o1.Duplicates() )
#--> [ "R", "RI", "I", "A", "N" ]

# To find an explication let's use the DuplicatesAndTheirPositions()
# function, or use its short form DuplicatesZ()
? @@S( o1.DuplicatesZ() )
#--> [ [ "R", 6 ], [ "RI", 6 ], [ "I", 7 ], [ "A", 10 ], [ "N", 11 ] ]

# Hence we see that position 6 corresponds to two duplicated substrings: "R" and "RI"                                                                                                                             

proff()
# Executed in 1.57 second(s)

