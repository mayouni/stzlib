# Narrative
# --------
# TRUTH IN RING
#
# Extracted from stzObjectTest.ring, block #3.

load "../../../stzBase.ring"

pr()

# In Ring a null string is FALSE

if ""
	? "TRUE"
else
	? "FALSE"
ok
#--> FALSE

# And a nom empty string is TRUE

if "Hello"
	? "TRUE"
else
	? "FALSE"
ok
#--> TRUE

# A empty list is also FALSE

if []
	? "TRUE"
else
	? "FALSE"
ok
#--> FALSE

# While a non empty list is TRUE

if ["Hello"]
	? "TRUE"
else
	? "FALSE"
ok
#--> TRUE

# An object is always TRUE
o1 = new Person

if o1
	? "TRUE"
else
	? "FALSE"
ok
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.24

class Person { name }
