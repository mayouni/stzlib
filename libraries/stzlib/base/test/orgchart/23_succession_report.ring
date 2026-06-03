# Narrative
# --------
# Succession report
#
# Extracted from stzorgcharttest.ring, block #23.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP Sales")

    ? @@NL( SuccessionReport() )
}
#--> #TODO Make more accurate sample
'
[
	[ "title", "Succession Risk Report" ],
	[ "date", "03/12/2025" ],
	[ "highriskcount", 0 ],
	[ "details", [  ] ]
]
'

pf()
