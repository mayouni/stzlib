# Narrative
# --------
# Subtracting a conditionally-selected slice from a mixed list.
#
# o1.ItemsW('NOT isNumber(This[@i])') selects every non-number item,
# yielding [ "A", "B", "C", "D" ]. Wrapping it in These() turns that
# selection into a removable operand, and o1 - These(...) subtracts
# those items from the original list. What remains is the numeric
# residue [ 1, 2, 3, 4, 5 ]. The idiom shows how ItemsW (a predicate
# filter using the @i row index and This row accessor) composes with
# list subtraction to express "keep everything except what matches".
#
# Extracted from stzlisttest.ring, block #426.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])

? o1 - These( o1.ItemsW('NOT isNumber(This[@i])') )
#             \_______________ ________________/
#                             V
#                   [ "A", "B", "C", "D" ]

#--> [ 1, 2, 3, 4, 5 ]

pf()
# Executed in 0.05 second(s).
