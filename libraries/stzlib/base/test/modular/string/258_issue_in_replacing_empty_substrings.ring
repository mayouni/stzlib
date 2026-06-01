# Narrative
# --------
# #qt Issue in replacing empty substrings
#
# Extracted from stzStringTest.ring, block #258.

load "../../../stzBase.ring"


pr()

cStr = "Ring language"

cStr = substr(cStr, "ing", "uby")
? cStr
#--> Ruby language

# Replacing "" with 'any' is undefined behavior
# In Ring, substr(str, "", "any") raises an error:
# ? substr(cStr, "", "any")

str = "Ring Language"
? substr(str, "", "any")
#--> ring message: Bad paramater value!

pf()
