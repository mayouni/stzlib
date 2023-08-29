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

/*-----
*/
pron()

? Q("ring").SubStringInQ("I LOVE THE ring LANGUAGE!").Uppercased()
#--> I LOVE THE RING LANGUAGE!

? The("PYTHON").SubStringInQ("ring PYTHON ruby").Lowercased()
#--> ring python ruby

proff()
# Executed in 0.04 second(s)

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
