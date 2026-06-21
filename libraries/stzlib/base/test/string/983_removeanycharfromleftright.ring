# Narrative
# --------
# RemoveAnyCharFromLeft / RemoveAnyCharFromRight: strip the whole LEADING
# or TRAILING run of a given character.
#
# These are targeted, one-sided trims: unlike a blanket Trim, they remove
# only the named char and only from one end. The multibyte heart "♥" is
# handled codepoint-correctly (the engine never byte-slices UTF-8), so
# the three leading hearts vanish in one call and the three trailing ones
# in the next, leaving "123".
#
# Repositioned from test/list (stzlisttest.ring, block #66): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

o1 = new stzString("♥♥♥123♥♥♥")

o1.RemoveAnyCharFromLeft("♥")
? o1.Content()
#--> 123♥♥♥

o1.RemoveAnyCharFromRight("♥")
? o1.Content()
#--> 123

pf()
# Executed in 0.02 second(s)
