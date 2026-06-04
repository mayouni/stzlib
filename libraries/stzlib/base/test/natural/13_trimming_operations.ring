# Narrative
# --------
# TRIMMING OPERATIONS
#
# Extracted from stznaturaltest.ring, block #13.

load "../../stzBase.ring"


pr()

o1 = Naturally("
    Make a string with '  spaced text  '
    Trim it and uppercase it
    Display the result
")
#--> SPACED TEXT

? ""
? o1.Code()
#-->
# oStr = StzStringQ("  spaced text  ")
# oStr.Trim()
# oStr.Uppercase()
# ? oStr.Content()

pf()
# Executed in 0.01 second(s) in Ring 1.24
