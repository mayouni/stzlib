# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #708.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# Case sensisitivity is considered only for latin letters

? StzCharQ("9").IsLowercase()
#--> FALSE

? StzCharQ("9").IsUppercase()
#--> FALSE

? StzCharQ("ك").IsLowercase()
#--> FALSE

? StzCharQ("ك").IsUppercase()
#--> FALSE

? StringIsLowercase("120")
#--> FALSE

? StringIsLowercase("120m")
#--> TRUE

? StringIsUppercase("120M")
#--> TRUE

? StringIsLowercase("كلام")
#--> FALSE

pf()
# Executed in 0.09 second(s).
