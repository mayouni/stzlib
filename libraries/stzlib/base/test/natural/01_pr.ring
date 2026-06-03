# Narrative
# --------
# pr()
#
# Extracted from stznaturaltest.ring, block #1.

load "../../stzBase.ring"


o1 = Naturally("
    Create {number} with {100} inside
    Increment it
    Show it
")
#--> 101

? o1.Code()
? @@NL( o1.Tokens() )

pf()
# Executed in 0.01 second(s) in Ring 1.24
