# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #689.

load "../../../stzBase.ring"


# We can adjust the ratio of QuitEquality by our selves (value between 0 and 1):

o1 = new stzString("mahmoud fayed")

? o1.IsQuietEqualTo("Mahmood al-feiyed")
#--> FALSE

? QuietEqualityRatio()
#--> 0.09 (default value)

# If we need a more permissive quiet-eqality check, then we set it at a weaker value:

SetQuietEqualityRatio(0.35)

? o1.IsQuietEqualTo("Mahmood al-feiyed")
#--> TRUE

pf()
# Executed in 0.01 second(s).
