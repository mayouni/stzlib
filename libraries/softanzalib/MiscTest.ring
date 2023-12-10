load "stzlib.ring"

/*------------------------------------------------------------------------*/
/*   This file contains test samples not classified in the test files     */
/*   related to each Softanza class apart.                                */
/*------------------------------------------------------------------------*/

/*================= UNDERSTANDING THE ..ed() and ..Q() FUNCTION FORMS
*/
pron()
# In softanza the ..ed() form returns the expected result
# from the function without altering the object content:

o1 = new stzList(L(' "♥1" : "♥3" '))
? @@( o1.ItemsReversed() )
#--> Returns [ "♥3", "♥2", "♥1" ]
# But the object content itself is left as-is:
? @@( o1.Content() )
#--> [ "♥1", "♥2", "♥3" ]

# Using the function directly (without ..ed()) will definetly alter
# the object content, without returning anything:
o1.Reverse() # The items are reversed but nothing is returned
# Let's see the object content:
? @@( o1.Content() )
#--> [ "♥3", "♥2", "♥1" ]

# If you want to alter the object and then return it to continue
# working on it, then use the ...Q() form like this:
o1 = new stzList(L(' "♥1" : "♥3" '))
? o1.ReverseQ().ToStzListOfStrings().ConcatenatedUsing("~")
# returns a string containing "♥3~♥2~♥1"

#--> Initially the object contained [ "♥1", "♥2", "♥3" ]. It's then
# reversed and became [ "♥1", "♥2", "♥3" ]. Finally, the stzList object
# is transformed to a stzListOfStrings object so it can be concatenated
# and returned as a string containing "♥3~♥2~♥1".

proff()
# Executed in 0.94 second(s)

/*-----------------------

o1 = new stzList(1:3)
? o1.Reversed()
#--> [ 3, 2, 1 ]

/*============ REVRSING ITEMS IN PAIRS AND, MORE GENERALLY, IN LISTS

# The same code you write for reversing items inside a list of pairs:

o1 = new stzListOfPairs([ [ "A1", "A2" ], [ "B1", "B2" ], ["C1", "C2" ] ])
o1.ReverseItemsInPairs()
? @@( o1.Content() )
#--> [ [ "A2", "A1" ], [ "B2", "B1" ], [ "C2", "C1" ] ]

# will work for reversing items in any list of lists:

o1 = new stzListOfLists([ [ "A1", "A2", "A3" ], [ "B1", "B2" ], ["C1", "C2" ] ])
o1.ReverseItemsInLists()
? @@( o1.Content() )
#--> [ [ "A2", "A1" ], [ "B2", "B1" ], [ "C2", "C1" ] ]

# This is a not a casual, but general feature you will find it anywhere
# in Softanza: you go from specific to more general, or from general to more
# specific using nearly the same code and the same semantics.
# PS: CONSISTENCY is one of the 7 design goals of SoftanzaLib.

