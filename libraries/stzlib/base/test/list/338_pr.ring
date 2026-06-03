# Narrative
# --------
# pr()
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
