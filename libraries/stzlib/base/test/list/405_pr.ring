# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #405.

load "../../stzBase.ring"

pr()

#WARNING

# At a given point I decided to support = as an overloaded operator
# on Softanza objects so we can make equality check on them like
# in the code below:

	? Q("str") = "str"
	#--> TRUE
	
	? Q("str") = Q("str") = "str"
	#--> TRUE
	
	? Q(2+5) = 7
	#--> TRUE
	
	? Q(2+5) = Q(3+4) = 7
	#--> TRUE
	
	? Q(2+5) = Q(3+4) = Q(9-2) = 7
	#--> TRUE
	
	? Q(1:3) = Q(3:1) = [3, 1, 2]

# But after that, I was faced with several complications when I needed
# to write an = after an object just to assign a value to it, like:
#
# oTempObj = anyValue
#
# The problem happens when aTempObj is a Softanza object. In this case
# the = operator is no longer considered an assignment operator but
# fires the meaning we gave to it in the related Softanza class, which
# is not what I want.
#
# So, I decided to disqualify this feature and keep only the arithmetic
# opearors +, -, * and / as overloaded operators on Softanza objects.

pf()
