# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #330.

load "../../stzBase.ring"

pr()

# Extending a list of numbers to a given position

o1 = new stzList([ 1, 2, 3 ])
o1.ExtendTo(5)
? @@( o1.Content() )
#--> [ 1, 2, 3, 0, 0 ]

# Extending a list of strings to a given position

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendTo(5)
? @@( o1.Content() )
#--> [ "A", "B", "C", "", "" ]


# Extending a list by a given item

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendToXT(5, :With = "♥")
? @@( o1.Content() )
#--> [ "A", "B", "C", "♥", "♥" ]

pf()
# Executed in almost 0 second(s).
