load "../stzlib.ring"

/*======

pron()

AddFuture(:Uppercase)
AddFuture(:Remove)

? Future()
#--> [ "uppercase", "remove" ]

proff()
# Executed in 0.01 second(s)

/*---

pron()

oStr = new stzString("ring")

AddFuture(:Uppercase) # or AddfutureAction()
AddFuture(:Replace = [ "I", "♥" ])

? @@(Future()) # Or FutureActions()
#--> [
#	[ "uppercase", [ ] ],
#	[ "replace", [ "I", "♥" ] ]
# ]

ExecuteActions( FutureActions(), oStr )
? oStr.Content()

proff()
# Executed in 0.02 second(s)

/*---

pron()

? BeforeQ("ringo").IsUppercasedFQ().
	RemoveFFQ("o").
	AndThenQ().ReturnIt()
#--> RING

? BeforeQ("ringo").IsUppercasedFQ().AndThenQ().SpacifiedFQ().
	RemoveFFQ(" o").
	BoundItWithQ([ "<< ", :and = " >>" ]).
	AndFinallyQ().ReturnIt()
#--> << R I N G O >>

? BeforeQ('').UppercasingFQ("ringo").
	RemoveFFQ("o").FromItQ().
	SpacifyItQ().
	AndThenQ().ReturnIt()
#--> R I N G

proff()
# Executed in 0.06 second(s)

/*=====

pron()

? Q("AnnIE").NumberOfVowels() # same as ? Q("AnnIE").VowelN()
#--> 3

? Q("AnnIE").Vowels()
#--> [ "A", "I", "E" ]

? Q("AnnIE").Vowel() # A random vowel from the string
#--> E

? Q("AnnIE").VowelN() # N ~> Number of...
#--> 3

proff()
# Executed in 0.07 second(s)

/*----

pron()

SetLastValue(3)

? Q("AnnIE").VowelNB() # ~> N: Number, B: Binary
#--> TRUE

SetLastValue(2)

? Q("AnnIE").VowelNB()
#--> FALSE

SetLastValue(["A", "I", "E"])
? Q("AnnIE").VowelsB()
#--> TRUE

proff()
# Executed in 0.07 second(s)

/*=====

pron()

QM("hi")
? MainObject().Content()
#--> "hi"

proff()
# Executed in 0.01 second(s)

/*======= #natural-coding #semantic-eloquence

pron()

? Q("ring").IsAString()
#--> TRUE

? Q("ring").IsStzString()
#--> TRUE

? Q("ring").IsAXT([ :Lowercase, :Latin, :String ])
#--> TRUE

? Q("ring").IsAXT([ :String ])
#--> TRUE

? Q("ring").IsA(:String)
#--> TRUE

? QM("ring").IsAXTQ([ :Lowercase, :Latin, :String ]).WhichQ().HasAQ().LengthQ().EqualTo(4)
#--> TRUE

? TheStringQM("ring").IsAQ([ :Lowercase, :Latin, :String ]).WithAQ().LengthQ().Of(4)
#--> TRUE

? TheWordQM("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WithAQ().LengthQ().OfXT(4, :Letters)
#--> TRUE

? TheWordQM("ring").IsAQ([ :Lowercase, :Latin, :Word ]).
  WithQ().ALengthQ().OfQ(4)._Q(:Letters).AndQ().OnlyQM(1).VowelNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LettersNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LowercaseBQ().LettersNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LettersNBQ().ThatAreQ().InLowercase()
#--> TRUE

? Q("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WhichQ().HasTheNumberQ(4).AsAQ().NumberOfCharsB()
#--> TRUE

? Q("ring").IsTheQ([ :Lowercase, :string ]).WhichIsQ().TheQ().ReverseOfB("gnir")
#--> TRUE

proff()
# Executed in 0.39 second(s)

/*-----------

pron()

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).ThatQ().AreNegative()
#--> TRUE

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).WhichQ().CanBeDividedBy(10)
#--> TRUE

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).ThatQ().AreNegativeQ().AndQ().DividableBy(10)
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*-----------

pron()

# Two misspelled forms of InLowercase()

? Q("ring").IsAQ(:String).InLowarcase() #--> TRUE
? Q("ring").IsAQ(:String).InLowercase() #--> TRUE

proff()
# Executed in 0.02 second(s)

/*------
*/
pron()

? Q("ring").IsAQ(:String).InLowercase() 		#--> TRUE
? Q("ring").IsAQ(:String).WhichIs().InLowercase()	#--> TRUE
? Q("ring").IsAQ(:String).Which().IsInLowercase()	#--> TRUE
? Q("ring").IsAQ(:String).Which().IsLowercase()		#--> TRUE

proff()
# Executed in 0.03 second(s)

/*======

pron()

? PluralToStzType("stzstrings")
#--> stzstring

proff()
# Executed in 0.01 second(s)

/*------

pron()

o1 = new stzListOfStrings([ "Ring", "Ruby" ])
? o1.FirstChar()
#--> "R"

o1 = new stzListOfStrings([ "Ring", "Bing" ])
? o1.LastChar()
#--> "g"

proff()
# Executed in 0.03 second(s)

/*------

pron()

? Q([ "Ring", :and = "Ruby" ]).AreBothQ(:strings).HavingQ().TheirQ().FirstCharQ().EqualTo("R")
#--> TRUE

? Q([ "Ring", :and = "ruby" ]).AreTwoQ(:strings).HavingQ().TheirQ().FirstCharCSQ(WhatEverCaseItHas).EqualTo(TheLetter("R"))
#-> TRUE

? Q([ "Ring", :and = "Bing" ]).
  AreBothQ(:strings).HavingMQ().TheirQ().FirstCharsQ().InUppercaseQ().AndQ().TheirQM().LastCharQ().EqualTo("g")
#-> TRUE

? Q([ "Ring", :and = "Bing" ]).
  AreBothQ(:strings).HavingMQ().TheirQ().FirstCharsQ().InUppercaseQ().AndQ().TheirQM().LastCharQ().EqualTo("g")
#-> TRUE

proff()
# Executed in 0.07 second(s)

/*------

pron()

? QM("ring").IsAQ(:String).
	InLowercaseQ().
	ContainingQ( TheLetter("i") ).
	HavingQ().TheQ().FirstCharQ().EqualToQ("r").
	AndQM().TheQ().Lastchar() = "g"
#--> TRUE

? QM("RING").IsAQ(:String).
	InUppercaseQ().
	ContainingQ( TheLetter("N") ).
	HavingQ().ItsQ().FirstCharQ().EqualToQ("R").
	AndQM().ItsQ().Lastchar() = "G"
#--> TRUE

proff()
# Executed in 0.05 second(s)

