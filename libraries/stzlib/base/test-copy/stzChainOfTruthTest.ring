load "../stzbase.ring"

/*---

profon()

	Q("Apple").IsA(:Fruit)
		? WhatIs(:Apple) #--> :Fruit
		? WhatIs(:Fruit) #--> :Undefined

Q(:Fruit).Is("the means by which flowering plants disseminate their seeds")
		? WhatIs(:Fruit) #--> the means by which flowering plants disseminate their seeds

	Q("Apple").IsA(:Company)
		? WhatIs(:Apple) #--> [ :Fruit, :Company ]

	Q("Steve Jobs").IsThe(:Owner).Of(:Apple)
		? WhoIs("Steve Jobs") #--> _('Steve Jobs").IsThe(:Owner).Of(:Apple)
		? WhatIs("Steve Jobs") #--> :Undefined

	Q(:Owner).IsA(:Person)
		? WhatIs("Steve Jobs") #--> :Person

 Q(:Person).AndQ(:Fruit).CanBeRelatedByQ(:Eats).AndAskedUsing(:What)
	Q(:Person).AndQ(:Company).CanBeRelatedByQ(:WorksAt).AndAskedUsingQ(:Where)_
	Q("Steve Jobs").Eats(:Apple)
	Q("Steve Jobs").WorksAt(:Apple)
		? What("Steve Jobs").Eats() 	#--> :Apple
		? Where("Steve Jobs").WorksAt() #--> :Apple

proff()

/*-----------------

profon()

? Q("Ring").Twice() # Works on any object
#--> [ "Ring", "Ring" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

if Q("SOFTANZA").
	  IsAMQ(:String).WhichIsQ().InUppercaseQ().
  	WhileQ().ContainingQ( TheLetters([ "F", :And = "Z" ]) ).
	  TheLetterQ("A").TwiceQ().
	  AndQ().HavingQ().ItsQM().FirstCharQ().EqualTo("S")

	? "It's me, Softanza!"
ok

proff()
# Executed in 0.02 second(s) in Ring 1.23

/*----------------- ok

pr()

# All these return 1:

? Q(1234).IsAQ(:Number).StzType()//WhichQ().IsEven()
? Q("ring").IsAQ(:String).WhichQ().IsLowercase()
? Q([]).IsAQ(:List).WhichQ().IsEmpty()
#TODO // an example for objects

pf()

/*----------------- ok

# All these are 0:

? _(1234).IsA(:String).Which(:IsEven)._
? _("ring").IsA(:Number).Which(:IsUppercase)._
? _("ring").IsA(:String).Which(:IsUppercase)._
#TODO // an example for objects

/*----------------- ERROR

# All these return 1:

? _("Ring").IsA(:String).Where('NumberOfChars() = 4')._
? _("Ring").IsA(:String).Having('FirstChar() = "R"')._
? _("Ring").IsA(:String).That('Contains("in")')._
? _("Ring").IsA(:String).Containing('in')._

/*----------------- ok
*/
# This returns 0:
/*
? _(1854).IsA(:String).Containing('in')._

/*----------------- ok

# All these return 1

? _("ring").IsA(:String)._
? _("f").IsA(:Letter)._

/*------------------- ok!

? _([]).IsA(:List)._	#--> TRUE
? _(12).IsA(:Number)._	#--> TRUE

? _("g").IsA(:Letter)._	#--> TRUE
? _([ :name = "mio", :age = 12 ]).IsA(:HashList)._	#--> TRUE
? _([ "Tunis", "Cairo", "Prag" ]).IsA(:ListOfStrings)._	#--> TRUE

o1 = new person { name = "ali" }
? _(:o1).IsAn(:Object)._ #--> ERRO: should return 1

class Person
	name

/*-----------------

# These return 1

? _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g"))._
? _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g")).Having('FirstChar() = "r"')._

/*----------------- ok

? _(8)._ 	# Returns 8
? _("ring")._ 	# Returns "ring"

/*----------------- ok

# All these return 1

? _(8).Is('DoubleOf(4)')._
? _("ring").Is('Lowercase()')._
? _("ring").Is(:Lowercase)._

/*----------------- ERRO

# These return 1
*/
? Q("ring").IsQ().InLowercaseQ().Containing("in")
? _("ring").Is('Lowercase()').Having('NumberOfchars() = 4')._

/*----------------- ERROR

? _("ring").Containing("in")._

/*----------------- ok

? _("ring").Is(:Lowercase).Is(:Even)._ #--> FALSE

/*-----------------

# All these return 1

? _(8).IsA(:Number).Which('IsDoubleOf(4)')._
? _(8).IsA(:Number).Which('IsEven()')._
? _(8).IsA(:Number).Which('IsEven')._


/*----------------- ERROR

# All these return 1

? _(9).IsNot('DoubleOf(4)')._
? _(9).IsA(:Number).Which('IsNotEven')._
? _(9).IsNotA(:Number).Which('IsEven')._

/*----------------- ERROR

? _("ring").IsNotA(:String)._	#--> FALSE
? _("ring").IsNotA(:String).Which('Contains("x")')._	#--> TRUE
? _("ring").IsNotA(:String).Which('Contains("i")')._	#--> FALSE

/*----------------- ERROR

# All these return 1

# Well, nothing prevents you from saying
? _("ring").Containing("i")._
# But, it's linguistically more elegant to say:
? _("ring").Contains("i")._
# or
? _("ring").IsContaining("i")._

/*----------------- ERROR


# All these are semantically equivalent and return 1

? _("ring").ContainingNo("x")._
? _("ring").IsContainingNo("x")._

? _("ring").ContainsNo("x")._	
? _("ring").DoesNotContain("x")._

/*-----------------

# All these return 1

? _("ring").ContainsNo("x").ContainsNo("y")._
? _("ring").ContainsNo("x").Nor("y")._
? _("ring").ContainsNeighther("x").Nor("y")._

/*-----------------

? _([]).IsNotA(:String)._	#--> FALSE
? _([]).IsNot(:AString)._	#--> FALSE

/*-----------------

? _([]).IsNor(:String).Nor(:Number).Nor(:Object)._

/*-----------------
*/


#? _("ring").ContainsNoOneOfThese([ "x", "y", "z" ])._
#? _("ring").ContainsEachOfThese([ "r", "i", "n", "g" ])._

#? ("This text").IsNeighther(:Arabic).Nor(:Cyrillic)
/*-----------------

_("G").IsThe(:Lowercase).Of("g")._

? _("G").IsAString().Which(:IsLetter)._

/*-----------------

? _("Ring").IsAString()//.Containing(TheLetter("G")).In('Lowercase()')
//? _("Ring").IsAString().Containing("in").Whaterver('StringCase()').ItHas()

/*-----------------
*/

//IsFunctionCall()
//ExtractFunctionParams()
	
	

