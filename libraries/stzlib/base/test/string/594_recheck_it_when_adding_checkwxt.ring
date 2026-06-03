# Narrative
# --------
# #TODO Recheck it when adding CheckWXT()
#
# Extracted from stzStringTest.ring, block #594.

load "../../stzBase.ring"

pr()

? StzRaise([
	:Where	= "stzString.ring",
	:What 	= "Describes what happend",
	:Why  	= "Describes why it happened",
	:Todo 	= "Posposes an action to solve the error"
])

#--> Line ... in file stzString.ring:
#	  What : Describes what happend
#	  Why  : Describes why it happened
#	  Todo : Posposes an action to do
#

pf()
