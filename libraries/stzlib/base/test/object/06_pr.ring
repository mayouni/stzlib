# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #6.

load "../../stzBase.ring"


o1 = new Person
? attributes(o1) # A Ring function
#--> [ "name", "age", "job" ]

# Softanza functions

? HowManyAttributes(o1)
#--> 3

? HasAttribute(o1, "age")
#--> TRUE

? HasAttribute(o1, "nothing")
#--> 0

pf()

class Person
	name
	age
	job

# Executed in almost 0 second(s) in Ring 1.23
