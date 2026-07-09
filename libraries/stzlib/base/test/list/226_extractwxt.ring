# Narrative
# --------
# ExtractW(condition): extract EVERY item matching a W-condition at once --
# returning all the matches and removing them from the list.
#
# The condition is a Softanza W-expression evaluated per item via @item.
# Here '{ NOT isNumber(@item) }' separates the non-numbers ("♥", "*", "_")
# out of a mixed list, leaving a clean numeric list behind -- a one-liner
# partition. The multibyte "♥" is handled correctly (codepoint-aware, not
# byte-sliced). W is the single performant + expressive conditional form;
# use WF when the predicate needs a real Ring function.
#
# Extracted from stzlisttest.ring, block #226.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", 3, "*", 4, "_" ])

? @@( o1.ExtractW('{ NOT isNumber(@item) }') )
#--> [ "♥", "*", "_" ]

? @@( o1.Content() )
#--> [ 1, 2, 3, 4 ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
