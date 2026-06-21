# Narrative
# --------
# UNDERSTANDING THE ..ed() and ..Q() FUNCTION FORMS
#
# The three Softanza verb forms on one example (reverse):
#   - ItemsReversed() / ..ed() : returns the result, leaves the object as-is.
#   - Reverse()                : mutates the object in place, returns nothing.
#   - ReverseQ()  / ..Q()      : mutates AND returns the object, so calls chain
#                                 (here on to ToStzListOfStrings().Concatenated...).
# The list is built with the L() range function ("♥1":"♥3"), exercising the
# codepoint-aware range parser too.
#
# (The old "#ERR ... itemsreversed" header was stale -- ItemsReversed is
# defined and the test runs clean; verified to STOPPED!.)
#
# Extracted from stzlisttest.ring, block #69.

load "../../stzBase.ring"


pr()
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
# reversed and became [ "♥3", "♥2", "♥1" ]. Finally, the stzList object
# is transformed to a stzListOfStrings object so it can be concatenated
# and returned as a string containing "♥3~♥2~♥1".

pf()
# Executed in 0.94 second(s)
