# Narrative
# --------
# Succession report
#
# Extracted from stzorgcharttest.ring, block #25.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP Sales")
    ReportsTo("vp1", "ceo")

    ? @@NL( SpanOfControlReport() )
}
#--> #TODO Make more accurate example
'
[
	[ "title", "Span of Control Analysis" ],
	[ "date", "03/12/2025" ],
	[
		"details",
		[
			[
				[ "position", "ceo" ],
				[ "title", "CEO" ],
				[ "directreports", 1 ],
				[ "status", "underutilized" ]
			]
		]
	]
]
'

pf()

#============================================#
#  GRAPH FEATURES (inherited from stzGraph)  #
#============================================#
