# Narrative
# --------
# #qt Issue in replacing empty substrings
#
# Extracted from stzStringTest.ring, block #258.

load "../../stzBase.ring"


pr()

cStr = "Ring language"

cStr = substr(cStr, "ing", "uby")
? cStr
#--> Ruby language

# Replacing "" with 'any' is undefined behavior
# In Ring, substr(str, "", "any") raises an error:
# ? substr(cStr, "", "any")

str = "Ring Language"
try
	? substr(str, "", "any")
catch
	? "(expected Ring error: 'Bad parameter value!')"
done
#--> ring message: Bad paramater value!

pf()
