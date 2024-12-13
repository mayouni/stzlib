load "../max/stzmax.ring"

/*=====

profon()

? SubStringQ([ "♥♥", :In = "--♥♥--**--" ]).ComesBeforeSubString("**")
#--> _TRUE_

? SubStringQ("♥♥").InQ("--♥♥--**--").ComesBeforeSubString("**")
#--> _TRUE_

? Q("--♥♥--**--").SubStringQ("♥♥").ComesBeforeSubString("**")
#--> _TRUE_

#--

? SubStringQ([ "**", :In = "--♥♥--**--" ]).ComesAfterSubString("♥♥")
#--> _TRUE_

? SubStringQ("**").InQ("--♥♥--**--").ComesAfterSubString("♥♥")
#--> _TRUE_

? Q("--♥♥--**--").SubStringQ("**").ComesAfterSubString("♥♥")
#--> _TRUE_

#--

? SubStringQ("--").InQ("--♥♥--**--").ComesBetween("♥♥", :And = "**")
#--> _TRUE_

? SubStringQ("--").InQ("--♥♥--**--").ComesBetween("**", :And = "♥♥")
#--> _TRUE_

? SubStringQ([ "--", :In = "--♥♥--**--" ]).ComesBetweenSubStrings("♥♥", :And = "**")
#--> _TRUE_

? SubStringQ([ "--", :In = "--♥♥--**--" ]).ComesBetweenSubStrings("**", :And = "♥♥")
#--> _TRUE_

? Q("--♥♥--**--").SubStringQ("--").ComesbetweenSubStrings("♥♥", :And = "**")
#--> _TRUE_

proff()

#---

/*==== TODO
*/
? @.UppercaseSubString("ring").In("I LOVE THE ring LANGUAGE!")
#--> I LOVE THE RING LANGUAGE!

@1 '<~' { Move("ring").From("php ring ruby").ToEndOf("I do love ") }
@2 '<~' { Uppercase("ring").In(@1) }
@3 '<~' { Remove("do").From(@1) }

@1 '<~' { Move("ring").From("php ring ruby").ToEndOf("I do love ") }
@2 '<~' { Uppercase("ring").In('~>') & Remove("do").Form(@1) }

Show( v[@1, @2] )


@2.Show()

/*=============
*/
//? Q("Ring").InQ("I love RING!").IsInUppercase()
#--> _TRUE_
 
? The("PYTHON").SubStringInQ("ring PYTHON ruby").Lowercased()
#--> ring python ruby
 
? SubStringQ("Ring").InQ("Python Ring Ruby").BoundedBy(2Hearts())
#--> Python ♥♥Ring♥♥ Ruby
 
? TheWord("love").InQ("I love Ring!").ReplacedBy(AHeart())
#--> I ♥ Ring!
 
? Only("human").InQ([ "THE", "human", "LIFE" ]).IsInLowercase()
#--> _TRUE_
 
? Q("human").InQ([ "THE", "human", "LIFE" ]).Uppercased()
#--> [ "THE", "HUMAN", "LIFE" ]

? ItemsQ(["THE", "LIFE"]).InListQ([ "THE", "human", "LIFE" ]).AreBothInUppercase()
#--> _TRUE_ 

/*-------------

profon()

? Q("ring").InQ("I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? Q("ring").SubStringInQ("I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? The("ring").SubStringInQ("I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? TheQ("ring").SubStringInQ("I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? Q("ring").SubstringQ( :In = "I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? TheQ("ring").SubStringQ( :In = "I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? The("ring").SubStringQ( :In = "I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? SubStringQ("ring").InQ("I LOVE ring LANGUAGE!").Uppercased()
#--> I LOVE THE RING LANGUAGE!

? TheSubStringQ("ring").InQ("I LOVE ring LANGUAGE!").Uppercased()
#--> I LOVE THE RING LANGUAGE!

? SubStringQ([ "ring", :In = "I LOVE ring LANGUAGE!" ]).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? TheSubStringQ([ "ring", :In = "I LOVE ring LANGUAGE!" ]).Uppercased()
#--> I LOVE THE RING LANGUAGE!

proff()
# Executed in 0.16 second(s)

/*------------

profon()

? Q("I love Ring").Words()
#--> [ "I", "love", "Ring" ]

? Q("I love Ring").SubStringIsAWord("Ring")
#--> _TRUE_

proff()

/*------------

profon()

? Q("human").InQ("THE human LIFE").IsInLowercase()
#--> _TRUE_

? Q("HUMAN").InQ("the HUMAN life").IsInUppercase()
#--> _TRUE_

? The("PYTHON").SubStringInQ("ring PYTHON ruby").Lowercased()
#--> ring python ruby

? TheSubString([ "Ring", :In = "I love Ring language!" ]).BoundedBy(3Hearts())
#--> I love ♥♥♥Ring♥♥♥ language!

? TheSubString("Ring").InQ("I love Ring language!").BoundedBy(3Hearts())
#--> I love ♥♥♥Ring♥♥♥ language!

? TheWord("love").InQ("I love Ring").ReplacedBy(AHeart())
#--> I ♥ Ring

proff()
# Executed in 0.80 second(s)

/*------------
*/
profon()

? Only("human").InQ([ "THE", "human", "LIFE" ]).IsInLowercase()
#--> _TRUE_

? Q("human").InQ([ "THE", "human", "LIFE" ]).Uppercased()
#--> [ "THE", "HUMAN", "LIFE" ]

? Only("human").InQ([ "THE", "human", "LIFE" ]).IsInLowercase() # stzOnlyItem.ring
#--> _TRUE_

? Every(:String).InQ([ 10, "human", 20, "human", 30, "HUMAN" ]).IsInLowercase() # stzEveryItem.ring

? Every(:Number).InQ([ 10, "human", 20, "human", 30, "HUMAN" ]).IsMultipleOf(10) # stzEveryItem.ring

proff()

/*-----

? AChar( :In = "softanza" ).Uppercased()
? SomeChars( :In = "softanza" ).Uppercased()

? ASubString( :In = "softanza" ).Uppercased() + NL
#--> softaNZA

? SomeSubStrings( :In = "SOFTANZA" ).Lowercased()
#--> SOFTAnza


proff()
# Executed in 0.80 second(s)

/*-----
*/
profon()

o1 = new stzString("ring")

? o1.SubStringIn("I LOVE THE ring LANGUAGE!")
#--> ring

? @@( o1.SubStringIn("bla bla bla") )
#--> _NULL_

? o1.SubstringInQ("I LOVE THE ring LANGUAGE!").Uppercased()
#--> I LOVE THE RING LANGUAGE!

proff()
# Executed in 0.05 second(s)

/*-----

profon()

o1 = new stzString("I LOVE THE ring LANGUAGE!")

? o1.SubString("ring")
#--> ring

? @@( o1.SubString("python") )
#--> _NULL_

? o1.SubStringQ("ring").Uppercased()
#--> I LOVE THE RING LANGUAGE!

proff()

/*-----

profon()

o1 = new stzSubString("ring", :in = "I LOVE THE ring LANGUAGE!")

? o1.SubString()
#--> ring

? o1.String()
#--> I LOVE THE ring LANGUAGE!

? o1.CaseSensitive()
#--> _TRUE_

? o1.Uppercased()
#--> I LOVE THE RING LANGUAGE!

? o1.String()
#--> I LOVE THE ring LANGUAGE!

? o1.NumberOfChars()
#--> 4

proff()
# Executed in 0.05 second(s)

/*-----
*/
profon()

o1 = new stzSubString("ING", :in = "I love the RING language!")

? o1.Lowercased()
#--> I love the Ring language!

proff()
