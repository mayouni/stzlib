# Narrative
# --------
# #narration : - operator never changes the object
#
# Extracted from stzlisttest.ring, block #580.

load "../../../stzBase.ring"


pr()

# When you write this:

o1 = new stzList([ "a", "b", "c", "d", "e" ])
o1 - These([ "b", "c" ])
? @@( o1.Content() )
#--> [ "a", "b", "c", "d", "e" ]

# And you get the hole list as a result, it's correct. Why?

# Because using (-) operator on o1 object does not modify the
# object itself. It just calculates the opeartion and returns
# the result in a normal new list.

# Check it by yourself by using ? command before the operation:

? @@( o1 - These([ "b", "c" ]) )
#--> [ "a", "d", "e" ]

# Again, the object itself has not been changed:

? @@( o1.Content() ) + NL
#--> [ "a", "b", "c", "d", "e" ]

# Now, what if you need to make the opeation and get a stzList
# object instead of a normal Ring list? Easy!

# Just use the Q() elevator to tell softanza that you want
# the output to be elevated to a stzList object, like this:

? ( o1 - TheseQ(["b", "c"]) ).Stztype()
#--> stzlist

# Of course, you can chain any other method supported by stzList:

? ( o1 - TheseQ([ "b", "c" ]) ).UppercaseQ().ToStzListOfStrings().Joined()
#--> "ADE"

# But the main object content again is not affected:
? @@( o1.Content() )
#--> [ "a", "b", "c", "d", "e" ]

pf()
# Executed in 0.03 second(s)
