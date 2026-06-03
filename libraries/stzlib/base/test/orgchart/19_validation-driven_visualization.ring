# Narrative
# --------
# Validation-driven visualization
#
# Extracted from stzorgcharttest.ring, block #19.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP 1")
    SubordinateOf("vp1", "ceo") # Or ReportsTo

    ViewXT(:vacancy)  # Validates and highlights vacant positions
}

pf()
