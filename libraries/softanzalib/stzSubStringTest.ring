load "stzlib.ring"

/*==== TODO

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

pron()

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
*/
pron()

? Q("I love Ring").Words()
#--> [ "I", "love", "Ring" ]

? Q("I love Ring").SubStringIsAWord("Ring")
#--> TRUE

proff()

/*------------
*/
pron()

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
pron()

o1 = new stzString("ring")

? o1.SubStringIn("I LOVE THE ring LANGUAGE!")
#--> ring

? @@( o1.SubStringIn("bla bla bla") )
#--> NULL

? o1.SubstringInQ("I LOVE THE ring LANGUAGE!").Uppercased()
#--> I LOVE THE RING LANGUAGE!

proff()
# Executed in 0.05 second(s)

/*-----

pron()

o1 = new stzString("I LOVE THE ring LANGUAGE!")

? o1.SubString("ring")
#--> ring

? @@( o1.SubString("python") )
#--> NULL

? o1.SubStringQ("ring").Uppercased()
#--> I LOVE THE RING LANGUAGE!

proff()

/*-----

pron()

o1 = new stzSubString("ring", :in = "I LOVE THE ring LANGUAGE!")

? o1.SubString()
#--> ring

? o1.String()
#--> I LOVE THE ring LANGUAGE!

? o1.CaseSensitive()
#--> TRUE

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
pron()

o1 = new stzSubString("ING", :in = "I love the RING language!")

? o1.Lowercased()
#--> I love the Ring language!

proff()
