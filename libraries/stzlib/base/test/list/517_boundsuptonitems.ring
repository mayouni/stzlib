# Narrative
# --------
# Demonstrates BoundsUpToNItems(n): the first n and last n items of a list.
#
# Softanza treats the two ends of a list as its "bounds." With n = 1 the
# bound is just the single opening and closing item, returned flattened as
# [ "{", "}" ]. With n > 1 each side becomes its own sub-list, so n = 2
# yields [ [ "{", "<" ], [ ">", "}" ] ] -- the leading pair and the
# trailing pair. This is handy for inspecting wrappers/delimiters that
# bracket a payload without manually slicing both extremities.
#
# Extracted from stzlisttest.ring, block #517.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "{", "<", "A", "B", "C", ">", "}" ])

? @@( o1.BoundsUpToNItems(1) ) + NL
#--> [ "{", "}" ]

? @@( o1.BoundsUpToNItems(2) )
#--> [ [ "{", "<" ], [ ">", "}" ] ]

pf()
# Executed in almost 0 second(s).
