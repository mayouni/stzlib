# Narrative
# --------
# W() wraps a textual condition into a small :Where DSL pair.
#
# Softanza lets you express filters and conditional list operations
# as plain strings like ' isString(@item) and isLower(@item) ',
# where @item stands for the current element. The W() helper does
# not evaluate the condition; it simply packages the string into a
# two-element list of the form [ "where", "<condition>" ]. Higher
# level methods (Find, Filter, etc.) later recognize this :Where
# marker and apply the engine-backed condition to each item.
#
# Extracted from stzlisttest.ring, block #338.

load "../../stzBase.ring"

pr()

# The W() small function take a string (containing a condition)
# and returns a list of the form :Where = ...

? W(' isString(@item) and isLower(@item) ')
#--> [ "where", " isString(@item) and isLower(@item) " ]

pf()
# Executed in almost 0 second(s).
