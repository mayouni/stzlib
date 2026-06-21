# Narrative
# --------
# Demonstrates InfereType(), the global that reports the runtime type
# of any Ring value as a short type name.
#
# Both calls pass a string literal, so both infer the type "string" --
# the value of the content is irrelevant; "strings" is still just a
# string value, so its inferred type is "string" (not "strings").
# InfereType keys off the actual Ring data type, not the text payload.
#
# Extracted from stzlisttest.ring, block #342.

load "../../stzBase.ring"

pr()

? InfereType("string")
#--> string

? InfereType("strings")
#--> string

pf()
# Executed in 0.01 second(s).
