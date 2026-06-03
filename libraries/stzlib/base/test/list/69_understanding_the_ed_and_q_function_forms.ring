# Narrative
# --------
# UNDERSTANDING THE ..ed() and ..Q() FUNCTION FORMS
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
# reversed and became [ "♥1", "♥2", "♥3" ]. Finally, the stzList object
# is transformed to a stzListOfStrings object so it can be concatenated
# and returned as a string containing "♥3~♥2~♥1".

pf()
# Executed in 0.94 second(s)
