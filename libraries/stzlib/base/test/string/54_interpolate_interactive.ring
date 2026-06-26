# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #54.
#
# INTERACTIVE -- this block reads from the keyboard (GetString()) and so cannot
# be auto-run / asserted in the narrated suite. It demonstrates Interpolate():
# a "{name}" placeholder is filled from the variable `fname` in scope. Kept in
# print form for reference; run it by hand to see "It's nice to meet you <name>!".

load "../../stzBase.ring"

pr()

put "What's your First name?"

fname = GetString()
# Enter Mahmoud at the keyboard...

print( Interpolate("It's nice to meet you {fname}!") )
#--> It's nice to meet you Mahmoud!

pf()
