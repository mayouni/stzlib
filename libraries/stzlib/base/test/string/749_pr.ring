# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #749.

load "../../stzBase.ring"


? StzStringQ("SOFTANZA IS AWSOME!").BoxedXT([
	:Line = :Solid,	# or :Dashed
		
	:AllCorners = :Round, # can also be :Rectangualr
	:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
		
	:TextAdjustedTo = :Center # or :Left or :Right or :Justified
])

#--> ╭─────────────────────┐
#    │ SOFTANZA IS AWSOME! │
#    └─────────────────────╯

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.20
