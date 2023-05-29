load "stzlib.ring"

/*============

pron()

o1 = new stzString("abCDE")

? o1.First2Chars()
#--> [ "a", "b" ]

? o1.First2CharsAsString()
#--> "ab"

? o1.Last3Chars()
#--> [ "C", "D", "E" ]

? o1.Last3CharsAsString()
#--> "CDE"

? o1.Next3Chars(:StartingAt = 3)
#--> [ "C", "D", "E" ]

? o1.Next3CharsAsString(:StartingAt = 3)
#--> "CDE"

proff()
# Executed in 0.07 second(s)

/*=========

pron()

? List2Code([ [ 6, 8 ], [ 16, 18 ] ]) # Ring standard function
#--> "[
#	[
#		6,
#		8
#	],
#	[
#		16,
#		18
#	]
# ]"

? ListToCode([ [ 6, 8 ], [ 16, 18 ] ]) # Softanza function
#--> "[ [ 6, 8 ], [ 16, 18 ] ]"

#--

? List2Code([ "A", '"B"', "'C'" ]) # Ring standard function
#--> [
#	"A",
#	""+char(34)+"B"+char(34)+"",
#	"'C'"
# ]

? ListToCode([ "A", '"B"', "'C'" ]) # Softanza function
#--> [ "A", '"B"', "'C'" ]

proff()

/*=========
*/

pron()

o1 = new stzListOfStrings([ "--**-*", "*---*", "--*-***" ])
o1.RemoveSubString("*")
? @@( o1.Content() )
#--> [ "---", "---", "---" ]

proff()
# Executed in 0.05 second(s)

/*=========

*/
pron()

o1 = new stzString("aaA...")

? o1.FindCS("a", :CaseSensitive) # Or :IsCaseSensitive or :CS or :IsCS
				 # or :CaseSensitive = TRUE or :CS = TRUE or TRUE
#--> [1, 2]

? o1.FindCS("a", :CaseInSensitive) # Or :NotCaseSensitive or :NotCS
				   # or :IsNotCaseSensitive  or :IsNotCS
				   # or :CaseSensitive = FALSE
				   # or :CS = FALSE
				   # or FALSE
#--> [1, 2, 3]

proff()

/*=========

*/
pron()

o1 = new stzString("---<<...>>---<<...>>---")
? @@( o1.FindBetweenAsSections("...", "<<", ">>") )
#--> [ [ 6, 8 ], [ 16, 18 ] ]

? @@( o1.FindBoundedBy("...", '"') )

proff()

/*=========

*/
pron()

o1 = new stzString(' this code:   txt1  =   "    withspaces    " and txt2  =  "nospaces"  ')
o1.SimplifyExcept( o1.FindAnyBoundedByAsSections('"') )

? o1.Content()

#--> 'this code: txt1 = "    withspaces    " and txt2 = "nospaces"'

proff()
# Executed in 0.08 second(s)

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

pron()

new stzNamedString(:oMyStr = "hi!")
new stzNamedList(:oMyList = [ "X", "Y" ])

? @[:oMyStr].Content()
#--> "hi!"

? Obj(:oMyStr)
#--> @[:omystr]

proff()
# Executed in 0.05 second(s)

/*------------------

pron()

o1 = new Friend { Name = "Mahmoud" Job = "Programmer" }

new stzNamedObject( :oFriend = o1 )

? @@( @C[:oFriend] )
#--> [ :name = "Mahmoud", :job = "Programmer" ]

proff()
# Executed in 0.06 second(s)

class Friend
	Name Job

/*------------------
*/

pron()

new stzNamedObject(
	:oMahmoud = 'new Friend { Name = "Mahmoud" Job = "Programmer" }'
)

ShowHL( @C[:oMahmoud] )
#--> [ :name = "Mahmoud", :job = "Programmer" ]

/*
new stzNamedObjects([
	:oSalem  = 'new Friend { Name = "Salem" Job = "Author" }',
	:oKarl   = 'new Friend { Name = "Karl" Job = "Farmer" }',
	:oKarim	 = 'new Friend { Name = "Karim" Job = "Painter" }'
])
*/


proff()
# Executed in 0.06 second(s)

class Friend
	Name Job

/*------------------

pron()

new stzNamedString( :oMyStr = "hi!" )
new stzNamedList( :oMyList = [ "X", "Y" ] )


o1 = new stzList([
	"*", '"*"', Obj(:oMystr), "*4", [ "A", "B" , Obj(:oMyList), "'C'"], 12
])

? o1.ToCode()
#--> [ "*", '"*"', @[:omystr], "*4", [ "A", "B", @[:omylist], "'C'" ], 12, @[:omyfriend] ]

? @@( [ "1", @C[:oMyStr], "2", @C[:oMyList], "3" ] )
#--> [ "1", "hi!", "2", [ "X", "Y" ], "3" ]

proff()
# Executed in 0.12 second(s)


/*------------------

//? o1.FindNext( Obje(:oMyStr), :StartingAt = 1)

//? o1.Find( Obj(:oMystr) )

proff()

/*------------------

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

