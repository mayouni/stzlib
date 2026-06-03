# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #482.

load "../../stzBase.ring"


# Inverting (or turning) chars and strings
#NOTE: In the mean time, Softanza uses Invert()
# and Turn() as alternatives, but this should
# change in the future to cope with their exact
# meaning in Unicode!

? StzCharQ("L").IsInvertible() # Or IsTurnable()
#--> TRUE

? StzCharQ("L").Inverted() # Or Turned()
#--> ⅂

? Q("LIFE").Inverted()
#--> EFIL

? Q("LIFE").Turned() # Or CharsInverted()
#--> ƎℲI⅂

pf()
# Executed in 0.07 second(s).
