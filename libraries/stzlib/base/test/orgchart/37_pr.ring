# Narrative
# --------
# pr()
#
# Extracted from stzorgcharttest.ring, block #37.

load "../../stzBase.ring"


oOrg = new stzOrgChart("Softabank_OrgChart_2025")
oOrg {
	LoadFrom("../_data/bank_structure.stzorg")
	? @@NL( Summary() )

	View() #ERR // Split on deparmtmetn names with spaces creates empty nodes!
}

pf()
