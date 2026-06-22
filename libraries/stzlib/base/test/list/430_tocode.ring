# Narrative
# --------
# Turns a live list back into the literal Ring source code that would recreate it.
#
# ToCode() (aliased ComputableForm()) walks the list, including nested
# sublists, and emits a string that is valid Ring bracket-and-quote syntax:
# strings get their double quotes, numbers stay bare, nesting is preserved.
# The global @@(...) is the short-form sugar for the same operation, so
# @@( aList ) and StzListQ(aList).ToCode() produce identical computable text.
# This is the inverse of evaluating a literal: handy for round-tripping a
# value into code, logging, or building snippets programmatically.
#
# Extracted from stzlisttest.ring, block #430.

load "../../stzBase.ring"

pr()

? StzListQ([ "q", "r", [ 2, 1 ] ]).ToCode()
#--> [ "q", "r", [ 2, 1 ] ]

# Or you can use this alternative short form:

? @@( [ "q", "r", [ 2, 1 ] ] ) + NL # same as ComputableForm()
#--> [ "q", "r", [ 2, 1 ] ]

pf()
# Executed in almost 0 second(s).
