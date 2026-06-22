# Narrative
# --------
# Edge-case behavior of ListContains() and IsListOfStrings() with NULL
# values and empty lists.
#
# An empty list contains nothing, so ListContains([], NULL) is FALSE; but
# a list holding a NULL element does contain that NULL, so
# ListContains([NULL], NULL) is TRUE. In Softanza, NULL ("") counts as a
# string, so IsListOfStrings() rejects the empty list (no strings to
# qualify it) yet accepts [NULL, NULL, NULL] because every element is the
# empty string. These pairs pin down how the global helpers treat the
# void value versus the empty container.
#
# Extracted from stzlisttest.ring, block #432.

load "../../stzBase.ring"

pr()

? ListContains([], NULL)
#--> FALSE

? ListContains([NULL], NULL)
#--> TRUE

? IsListOfStrings([])
#--> FALSE

? IsListOfStrings([ NULL, NULL, NULL])
#--> TRUE

pf()
# Executed in 0.01 second(s).
