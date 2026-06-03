# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #307.

load "../../stzBase.ring"

pr()

o1 = new stzString(
"MahmoudBertAhmedMansourIlirGalMajdi"
)

o1.SpacifyTheseSubStrings([
	"Mahmoud", "Bert", "Ahmed", "Mansour", "Ilir", "Gal", "Majdi" ])

? o1.Content()
#--> Mahmoud Bert Ahmed Mansour Ilir Gal Majdi

pf()
# Executed in 0.06 second(s)
