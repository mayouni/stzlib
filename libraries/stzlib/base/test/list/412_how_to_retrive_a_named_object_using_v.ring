# Narrative
# --------
# Shows how to fetch a previously created named object by its name using v().
#
# When you build an object with the named-constructor + Q form, like
# StzNamedStringQ(:mystr = "Hello!") or StzNamedListQ(:mylst = 1:3), Softanza
# registers it under the symbol you gave (:mystr, :mylst). The global v()
# helper then resolves that symbol back to the live object, so v(:mystr)
# returns the named string and v(:mylst) returns the named list. From there
# you call ordinary methods such as .Content() to read the stored value --
# "Hello!" for the string and [ 1, 2, 3 ] for the 1:3 range list. This gives
# a lightweight name-based registry without threading the variable through
# every call site.
#
# Extracted from stzlisttest.ring, block #412.

load "../../stzBase.ring"


pr()

o1 = StzNamedStringQ(:mystr = "Hello!")

? v(:mystr).Content()
#--> "Hello!"

o2 = StzNamedListQ(:mylst = 1:3 )
? v(:mylst).Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.02 second(s).
