# Narrative
# --------
# Five spellings of "is X bounded by Y". IsBoundedBy accepts a single string bound
# (-> [c,c]) or an [open,close] pair. The XT forms take :In = host: IsBoundedByXT
# asks whether THIS substring is bounded by `bound` inside host; IsBoundOfXT asks
# whether THIS string is a bound of a substring inside host. All five are TRUE.
#
# Extracted from stzStringTest.ring, block #44.

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
