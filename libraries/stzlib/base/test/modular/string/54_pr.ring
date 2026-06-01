# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #54.

load "../../../stzBase.ring"


put "What's your First name?"

fname = GetString()
# Enter Mahmoud in the keyboard...

print( Interpolate("It's nice to meet you {fname}!") )
#--> It's nice to meet you Mahmoud!

pf()
# Executed in 1.54 second(s).
#NOTE Most time is taken by the Ring GetString() function
# because it depends of your typing speed and the time you took
# before you start typing!

#~> Clarified by Mahmoud in this Google Group post:
# https://groups.google.com/g/ring-lang/c/spaMUfhUtgU/m/G7xHeO0kAAAJ
