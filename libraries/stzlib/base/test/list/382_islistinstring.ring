# Narrative
# --------
# IsListInString() decides whether a wrapped string holds a Ring list literal.
#
# The current implementation is a minimal, eval-free heuristic: the trimmed
# content must start with '[' and end with ']'. That covers the CSV-parser
# use case (deciding whether a field value should be rebuilt into a Ring
# list). So '[ "A", "B", 3 ]' returns TRUE, while the short-form range
# notations (' 1 : 3 ', ' "A" : "C" ', ' "ا" : "ج" ') return FALSE -- the
# old monolithic version accepted those ranges via an eval-based check, but
# the slim checker in stzStringChecker.ring deliberately does not.
#
# Extracted from stzlisttest.ring, block #382.

load "../../stzBase.ring"

pr()

? Q(' [ "A", "B", 3 ] ').IsListInString()
#--> TRUE

? Q(' 1 : 3 ').IsListInString()
#--> FALSE

? Q(' "A" : "C" ').IsListInString()
#--> FALSE

? Q(' "ا" : "ج" ').IsListInString()
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.07 second(s) before
