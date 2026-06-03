# Narrative
# --------
# #  Credit Card Masking  #
#
# Extracted from stzRegexTest.ring, block #49.

load "../../stzBase.ring"

#-----------------------#

pr()

cText = "Card numbers: 4111-1111-1111-1111 and 4111111111111111"

o1 = new stzRegex("")

# Validate card format

o1.SetPattern("(?:\d{4}[-\s]?){4}")

? o1.Match(cText)
#--> TRUE

# Mask card number (show only last 4)

o1.SetPattern("(\d{4}[-\s]?){3}(\d{4})")

if o1.Match(cText) and o1.HasGroups()
    captured = o1.Capture()
    ? captured[len(captured)]
ok
#--> 1111

pf()
# Executed in almost 0 second(s) in Ring 1.22s
