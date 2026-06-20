# Narrative
# --------
# The (-) operator NEVER changes the object -- it computes and returns.
#
# `o1 - These([...])` returns the reduced list but leaves o1 intact (so a
# later o1.Content() is unchanged). Add the Q() elevator -- TheseQ([...]) --
# and the result comes back as a chainable stzList object, on which you can
# keep working: here UppercaseQ -> ToStzListOfStrings -> Joined builds
# "ADE", all without ever touching the original o1.
#
# Extracted from stzlisttest.ring, block #580.

load "../../stzBase.ring"

pr()

# When you write this:

o1 = new stzList([ "a", "b", "c", "d", "e" ])
o1 - These([ "b", "c" ])
? @@( o1.Content() )
#--> [ "a", "b", "c", "d", "e" ]

# And you get the whole list as a result, it's correct. Why?
# Because using (-) on o1 does not modify the object itself; it just
# computes the operation and returns the result in a new list.

? @@( o1 - These([ "b", "c" ]) )
#--> [ "a", "d", "e" ]

# Again, the object itself has not been changed:

? @@( o1.Content() ) + NL
#--> [ "a", "b", "c", "d", "e" ]

# To get a stzList object back instead of a raw list, use the Q() elevator
# (TheseQ here) -- then chain any stzList method:

? ( o1 - TheseQ(["b", "c"]) ).Stztype()
#--> stzlist

? ( o1 - TheseQ([ "b", "c" ]) ).UppercaseQ().ToStzListOfStrings().Joined()
#--> "ADE"

# But the main object content again is not affected:
? @@( o1.Content() )
#--> [ "a", "b", "c", "d", "e" ]

pf()
# Executed in 0.03 second(s)
