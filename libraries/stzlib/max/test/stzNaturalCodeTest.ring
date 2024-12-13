load "../stzmax.ring"

/*======

profon

AddFuture(:Uppercase)
AddFuture(:Remove)

? Future()
#--> [ "uppercase", "remove" ]

proff()
# Executed in 0.01 second(s)

/*---

profon

oStr = new stzString("ring")

AddFuture(:Uppercase) # or AddfutureAction()
AddFuture(:Replace = [ "I", "♥" ])

? @@(Future()) + NL # Or FutureActions()
#--> [
#	[ "uppercase", [ ] ],
#	[ "replace", [ "I", "♥" ] ]
# ]

ExecuteActions( Future(), :on = oStr )
? oStr.Content()
#--> R♥NG

proff()
# Executed in 0.02 second(s)

/*---

profon

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

profon

? Q("AnnIE").NumberOfVowels() # same as ? Q("AnnIE").VowelN()
#--> 3

? Q("AnnIE").Vowels()
#--> [ "A", "I", "E" ]

? Q("AnnIE").Vowel() # A random vowel from the string
#--> E

? Q("AnnIE").VowelN() # N ~> Number of...
#--> 3

proff()
# Executed in 0.04 second(s) on Ring 1.21
# Executed in 0.07 second(s) on Ring 1.20

/*----

profon

SetLastValue(3)

? Q("AnnIE").VowelNB() # ~> N: Number, B: Binary
#--> _TRUE_

SetLastValue(2)

? Q("AnnIE").VowelNB()
#--> _FALSE_

SetLastValue(["A", "I", "E"])
? Q("AnnIE").VowelsB()
#--> _TRUE_

proff()
# Executed in 0.03 second(s) on Ring 1.21
# Executed in 0.07 second(s) on Ring 1.20

/*=====

profon

QM("hi")
? MainObject().Content()
#--> "hi"

proff()
# Executed in 0.01 second(s)

/*======= #natural-coding #semantic-eloquence

profon

? Q("ring").IsAString()
#--> _TRUE_

? Q("ring").IsStzString()
#--> _TRUE_

//? Q("ring").IsAXT([ :Lowercase, :Latin, :String ])
#--> _TRUE_

//? Q("ring").IsAXT([ :String ])
#--> _TRUE_

? Q("ring").IsA(:String)
#--> _TRUE_

//? QM("ring").IsAXTQ([ :Lowercase, :Latin, :String ]).WhichQ().HasAQ().LengthQ().EqualTo(4)
#--> _TRUE_

//? TheStringQM("ring").IsAQ([ :Lowercase, :Latin, :String ]).WithAQ().LengthQ().Of(4)
#--> _TRUE_

//? TheWordQM("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WithAQ().LengthQ().OfXT(4, :Letters)
#--> _TRUE_

//? TheWordQM("ring").IsAQ([ :Lowercase, :Latin, :Word ]).
//  WithQ().ALengthQ().OfQ(4)._Q(:Letters).AndQ().OnlyQM(1).VowelNB()
#--> _TRUE_

? TheWordQ("ring").HasNQ(4).LettersNB()
#--> _TRUE_

? TheWordQ("ring").HasNQ(4).LowercaseBQ().LettersNB()
#--> _TRUE_

? TheWordQ("ring").HasNQ(4).LettersNBQ().ThatAreQ().InLowercase()
#--> _TRUE_

//? Q("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WhichQ().HasTheNumberQ(4).AsAQ().NumberOfCharsB()
#--> _TRUE_

? Q("ring").IsTheQ([ :Lowercase, :string ]).WhichIsQ().TheQ().ReverseOfB("gnir")
#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*-----------

profon

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).ThatQ().AreNegative()
#--> _TRUE_

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).WhichQ().CanBeDividedBy(10)
#--> _TRUE_

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).ThatQ().AreNegativeQ().AndQ().DividableBy(10)
#--> _TRUE_

proff()
# Executed in 0.03 second(s)

/*-----------

profon

# Two misspelled forms of InLowercase()

? Q("ring").IsAQ(:String).InLowarcase() #--> _TRUE_
? Q("ring").IsAQ(:String).InLowercase() #--> _TRUE_

proff()
# Executed in 0.02 second(s)

/*------

profon

? Q("ring").IsAQ(:String).InLowercase() 		#--> _TRUE_
? Q("ring").IsAQ(:String).WhichIs().InLowercase()	#--> _TRUE_
? Q("ring").IsAQ(:String).Which().IsInLowercase()	#--> _TRUE_
? Q("ring").IsAQ(:String).Which().IsLowercase()		#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*======

profon

? PluralToStzType("stzstrings")
#--> stzstring

proff()
# Executed in 0.01 second(s)

/*------

profon

o1 = new stzListOfStrings([ "Ring", "Ruby" ])
? o1.FirstChar()
#--> "R"

o1 = new stzListOfStrings([ "Ring", "Bing" ])
? o1.LastChar()
#--> "g"

proff()
# Executed in 0.03 second(s)

/*------

profon

? Q([ "Ring", :and = "Ruby" ]).AreBothQ(:strings).HavingQ().TheirQ().FirstCharQ().EqualTo("R")
#--> _TRUE_

? Q([ "Ring", :and = "ruby" ]).AreTwoQ(:strings).HavingQ().TheirQ().FirstCharCSQ(WhatEverCaseItHas).EqualTo(TheLetter("R"))
#-> _TRUE_

? Q([ "Ring", :and = "Bing" ]).
  AreBothQ(:strings).HavingMQ().TheirQ().FirstCharsQ().InUppercaseQ().AndQ().TheirQM().LastCharQ().EqualTo("g")
#-> _TRUE_

? Q([ "Ring", :and = "Bing" ]).
  AreBothQ(:strings).HavingMQ().TheirQ().FirstCharsQ().InUppercaseQ().AndQ().TheirQM().LastCharQ().EqualTo("g")
#-> _TRUE_

proff()
# Executed in 0.07 second(s)

/*------
*/

 profon

 ? QM("ring").IsAQ(:String).
	InLowercaseQ().
	ContainingQ( TheLetter("i") ).
	HavingQ().TheQ().FirstCharQ().EqualToQ("r").
	AndQM().TheQ().Lastchar() = "g"

	#--> _TRUE_

 ? QM("RING").IsAQ(:String).
	InUppercaseQ().
	ContainingQ( TheLetter("N") ).
	HavingQ().ItsQ().FirstCharQ().EqualToQ("R").
	AndQM().ItsQ().Lastchar() = "G"

	#--> _TRUE_

 proff()
 # Executed in 0.05 second(s)

