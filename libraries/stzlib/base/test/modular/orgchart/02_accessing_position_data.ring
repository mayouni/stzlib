# Narrative
# --------
# Accessing position data
#
# Extracted from stzorgcharttest.ring, block #2.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    
    ? @@NL( Position(:@ceo) )
}
#-->
'
[
	[ "id", "@ceo" ],
	[ "title", "CEO" ],
	[ "level", "executive" ]
]
'
#TODO Shoule we return the other properties with NULL?

pf()
# Executed in 0.03 second(s) in Ring 1.24
