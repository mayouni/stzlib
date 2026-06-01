# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #83.

load "../../../stzBase.ring"


pr()

o1 = new stzString("okay one pepsi two three ")

# Declaring a condition in a string

cMyConditionIsVerified = '
	Q(This[@i]).ContainsAnyOfThese( Q("vwto").Chars() )
'

# Using the condition to find the words verifying it (using FindW())
# after the string is splitted (using Split())
? cMyConditionIsVerified

? o1.SplitQ(" ").FindWhere(cMyConditionIsVerified) # Or .FindW() for short!
#--> [ 1, 2, 4, 5 ]

# Getting the words themselves using ItemsW()

? o1.SplitQ(" ").ItemsWhere(cMyConditionIsVerified)
#--> [ "okay", "one", "two", "three" ]

# In general, any function in Softanza, like Find() and Items() here,
# can be used as they are, or exented with the W() letter, so we can
# instruct them to do their job upon a given condition.

pf()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.24 second(s) in Ring 1.19
