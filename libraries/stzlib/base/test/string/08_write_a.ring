# Narrative
# --------
# #todo Write a #narration
#
# Extracted from stzStringTest.ring, block #8.
#ERR panic: integer does not fit in destination type

load "../../stzBase.ring"


pr()

? @@( @N(3, ".") )
#--> [ ".", ".", "." ]

? @@( @NXT(3, ".", :InAList) )
#--> [ ".", ".", "." ]

? @@( @NXT(3, ".", :InAString) ) + NL
#--> "..."

? @@( Three(".") )
#--> [ ".", ".", "." ]

? @@( @3(".") ) + NL
#--> [ ".", ".", "." ]

#--

? Q([ ".", ".", ".", "Tunis" ]).StartsWith( @3(".") )
#--> TRUE

? Q("...Tunis").StartsWith("...")
#--> TRUE

? Q("...Tunis").StartsWithXT( @3(".") )
#--> TRUE

? Q("..Tunis..").EndsWithXT( @2(".") )
#--> TRUE

? Q("...Tunis..").StartsWithXTQ( @3(".") ).AndQ().EndsWithXT( @2(".") )
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22
