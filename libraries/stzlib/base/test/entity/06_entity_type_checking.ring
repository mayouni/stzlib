# Narrative
# --------
# Entity type checking
#
# Extracted from stzentitytest.ring, block #6.

load "../../stzBase.ring"


pr()

o1 = new stzEntity([
	:name = "john",
	:type = "person",
	:age = 35,
	:job = "programmer"
])

? o1.IsOfType("person")
#--> 1

? o1.HasName("john")
#--> 1

? o1.Size()
#--> 5

o1.Show()
#-->
# Entity: john (Type: person)
#  age: 35
#  job: programmer
#  created: 06/10/2025 21:34:40

pf()
# Executed in almost 0 second(s) in Ring 1.24
