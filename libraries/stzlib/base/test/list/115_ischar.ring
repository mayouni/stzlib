# Narrative
# --------
# IsChar() answers whether a value qualifies as a single character.
#
# A value passes when it is a one-codepoint string -- "A", the Arabic
# letter "م", or the heart symbol "♥" all return TRUE, confirming the
# check is Unicode-aware and counts codepoints, not bytes. Multi-character
# strings like "Hi" return FALSE. For numbers, IsChar accepts only a small
# non-negative integer in the valid single-character range (6 -> TRUE),
# while a float (12.5), a negative (-7), and an out-of-range integer (14)
# all return FALSE. This makes IsChar the single-character guard used
# before any per-character operation in Softanza's list and string APIs.
#
# Extracted from stzlisttest.ring, block #115.

load "../../stzBase.ring"

pr()

? IsChar(12.5)
#--> FALSE

? IsChar(-7)
#--> FALSE

? IsChar(14)
#--> FALSE

? IsChar(6)
#--> TRUE

? IsChar("A")
#--> TRUE

? IsChar("م")
#--> TRUE

? IsChar("♥")
#--> TRUE

? IsChar("Hi")
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.21
