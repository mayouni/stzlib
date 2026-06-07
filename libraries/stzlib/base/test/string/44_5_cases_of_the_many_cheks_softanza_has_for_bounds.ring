# Narrative
# --------
# 5 cases of the many cheks Softanza has for bounds
#
# Extracted from stzStringTest.ring, block #44.
#ERR Error (R14) : Calling Method without definition: areboundsofxt

load "../../stzBase.ring"


pr()

# Case 1 : Checking if the string is bounded by ONE or TWO substrings

? Q("_world_").IsBoundedBy("_")
#--> TRUE

? Q("/world\").IsBoundedBy([ "/", "\" ])
#--> TRUE

# Case 3 : Checking if the string is bounded by one (or two)
# substrings INSIDE an other string

? Q("world").IsBoundedByXT( "_", :In = "_world_" )
#--> TRUE

? Q("world").IsBoundedByXT( ["/","\"], :In = "/world\" )
#--> TRUE

# Case 3 : Checking if a string (or two) is the bound of an other
# string inside a third string

? Q("_").IsBoundOfXT("world", :In = "Hello _world_ of Ring!")
#--> TRUE

? Q(["/","\"]).AreBoundsOfXT("world", :In = "Hello /world\ of Ring!")
#--> TRUE

pf()
# Executed in 0.12 second(s) in Ring 1.21
# Executed in 0.22 second(s) in Ring 1.19
