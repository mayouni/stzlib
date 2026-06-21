# Narrative
# --------
# Compares the SIZE (item count) of two lists, regardless of element values.
#
# Q([1,2,3,4,5]).IsLarger(:Than = [8,9]) asks only "does the host hold more
# items than the other list?" -- 5 items vs 2, so TRUE. The values 8 and 9
# are larger numbers but that is irrelevant; this family measures cardinality,
# not magnitude. HasMoreItems is the explicit, self-documenting alias of
# IsLarger; IsSmaller / HasLessItems are the mirror pair. The named :Than
# argument keeps the comparison direction readable at the call site.
#
# Extracted from stzlisttest.ring, block #371.

load "../../stzBase.ring"

pr()

? Q([1, 2, 3, 4, 5]).IsLarger(:Than = [8, 9])
#--> TRUE

# or if you want to precise:

? Q([1, 2, 3, 4, 5]).HasMoreItems(:Than = [8, 9])
#--> TRUE

#--

? Q([8, 9]).IsSmaller(:Than = [1, 2, 3, 4, 5])
#--> TRUE

# or if you want to precise:
? Q([8, 9]).HasLessItems(:Than = [1, 2, 3, 4, 5])
#--> TRUE

pf()
# Executed in almost 0 second(s).
