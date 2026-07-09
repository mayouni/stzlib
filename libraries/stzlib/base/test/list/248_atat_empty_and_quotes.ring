# Narrative
# --------
# How @@() renders a plain string back into Softanza source form,
# choosing the quote character that keeps the result unambiguous.
#
# @@() is the inverse of evaluation: it returns a textual, paste-able
# representation of any value. For strings it always wraps the content
# in quotes, and it picks the quote style intelligently: by default it
# uses double quotes, but when the content itself contains a double
# quote it switches to single quotes (and vice versa) so the embedded
# quote does not need escaping. Note that single- and double-quoted
# inputs are equivalent in Ring, so @@('') and @@("") both render as
# the canonical "" form. A bracketed string like "[1, 2, 3 ]" stays a
# quoted string (it is text, not a real list), confirming @@() reflects
# the actual value type rather than parsing the content.
#
# Extracted from stzlisttest.ring, block #248.

load "../../stzBase.ring"

pr()

? @@( "" )
#--> ""

? @@( '' )
#--> ""

? @@( '""' )
#--> '""'

? @@( "''" )
#--> "''"

? @@( "[1, 2, 3 ]" )
#--> "[1, 2, 3 ]"

? @@( '[1, 2, 3 ]' )
#--> "[1, 2, 3 ]"

? @@( '"[1, 2, 3]"' )
#--> '"[1, 2, 3]"'

? @@( "'[1, 2, 3]'" )
#--> "'[1, 2, 3]'"

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.03 second(s) in Ring 1.20
