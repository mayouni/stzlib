# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #11.
#ERR Error (R14) : Calling Method without definition: interpolated

load "../../stzBase.ring"

pr()

# f-strings are a feature in Python for interpolating string
# content, by dynmalically evaluating variables inside it:

'
bestlang = "Python"
print(f"My best language is {bestlang}!")
#--> My best language is Python!
'

# the same syntax can be used in Ring with Softanza like this:

bestlang = "Ring"
print( f("My best language is {bestlang}!") )
#--> My best language is Ring!

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.20
