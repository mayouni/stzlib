# Narrative
# --------
# Trim: remove only the surrounding WHITESPACE, leaving inner content intact.
#
# The leading space and trailing spaces are stripped, but the heart run
# "♥♥♥" at both ends of the actual content stays -- Trim targets blanks, not
# arbitrary characters (contrast TrimChar, block #985). Codepoint-correct:
# the multibyte hearts are never byte-sliced.
#
# Repositioned from test/list (stzlisttest.ring, block #67): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

o1 = new stzString(" ♥♥♥123♥♥♥   ")
o1.Trim()
? o1.Content()
#--> "♥♥♥123♥♥♥"

pf()
# Executed in 0.03 second(s)
