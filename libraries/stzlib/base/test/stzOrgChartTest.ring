load "../stzbase.ring"

/*
This comprehensive test suite demonstrates:

stzOrgChart Features:
---------------------

	- Position management (executive/management/staff)
	- People assignment and reassignment
	- Department organization
	- Metrics (span, vacancy, succession)
	- Governance validation (BCEAO, SOD, SOC)
	- Visual focus modes
	- Reporting

Inherited from stzDiagram:
--------------------------

	- Themes and layouts
	- Visual rules
	- Clusters (departments)
	- Focus highlighting
	- Export formats

Inherited from stzGraph:
------------------------

	- Path finding
	- Connectivity analysis
	- Property queries
	- Graph metrics
	- Cycle detection
	- Rule engine

Each test includes clear output/visual descriptions
following Softanza conventions.
*/

#==================#
#  BASIC STRUCTURE #
#==================#

/*--- Creating positions and hierarchy

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp_eng, "VP Engineering")
    AddStaffXT(:@dev1, "Senior Dev")
    
    ReportsTo(:@vp_eng, :@ceo)
    ReportsTo(:@dev1, :@vp_eng)
    
    ? NodeCount() #--> 3
    ? EdgeCount() #--> 2
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Accessing position data

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

/*--- Direct reports

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP Sales")
    AddManagerXT(:@vp2, "VP Ops")
    
    ReportsTo(:@vp1, :@ceo)
    ReportsTo(:@vp2, :@ceo)
    
    ? @@( DirectReports(:@ceo) )
    #--> [ "@vp1", "@vp2" ]

    ? DirectReportsN(:@ceo)
    #--> 2
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#===============#
#  PEOPLE MGMT  #
#===============#

/*--- Adding and assigning people

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddPersonXT(:@p1, "Sarah Chen")
    Assign(:Person = :@p1, :ToPosition = :@ceo)
    
    ? Position(:@ceo)[:incumbent] #--> "@p1"
    ? Position(:@ceo)[:isVacant] #--> FALSE
    ? PersonData(:@p1)[:position] #--> "@ceo"

    View()
}

pf()
# Visual: CEO node now shows "CEO\nSarah Chen" in gold

#ERR The name of person is not displayed
#ERR node is showan in white

/*--- Vacancy tracking

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP Sales")
    AddStaffXT(:@dev1, "Developer")
    
    AddPersonXT(:@alice, "Alice")
    Assign(:@alice, :ToNode = :@ceo)
    
    ? @@( VacantPositions() )
    #--> ["vp1", "dev1"]

    ? VacancyRate()
    #--> 66.67
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Reassignment

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {

    AddStaffXT(:@dev1, "Developer 1")
    AddStaffXT(:@dev2, "Developer 2")

    AddPersonXT(:@bob, "Bob Marley")
    AssignPerson(:@bob, :ToPosition = :@dev1)
    
    ? Position(:@dev1)[:incumbent] #--> @bob
    ? Position(:@dev2)[:incumbent] #--> ""
    
    ReassignPerson(:@bob, :ToPosition = :@dev2)
    
    ? Position(:@dev1)[:incumbent] #--> ""
    ? Position(:@dev2)[:incumbent] #--> @bob
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#==============#
#  DEPARTMENTS #
#==============#

/*--- Department assignment
*/
pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT(:@vp_eng, "VP Engineering")
    AddStaffXT(:@dev1, "Developer")

    AddDepartmentXTT(:@eng_dept, "Engineering", [ :@vp_eng, :@dev1 ])

    SetPositionDepartment(:@vp_eng, :@eng_dept)
    SetPositionDepartment(:@dev1, :@eng_dept)
    
    ? NodeProperty(:@vp_eng, :@eng_dept) #--> "engineering"
}
#ERR Inexistant node key or/and property!
# In method nodeproperty()

pf()

/*--- Creating department clusters

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT("vp_eng", "VP Engineering")
    AddStaffXT("dev1", "Dev 1")
    AddStaffXT("dev2", "Dev 2")
    
    AddDepartmentXTT("eng_dept", "Engineering", ["vp_eng", "dev1", "dev2"])
    
    ReportsTo("dev1", "vp_eng")
    ReportsTo("dev2", "vp_eng")

    ? @@NL( Departments() )

    View()
}
#-->
'
[
	[
		[ "id", "eng_dept" ],
		[ "name", "Engineering" ],
		[
			"positions",
			[ "vp_eng", "dev1", "dev2" ]
		],
		[ "head", "" ]
	]
]
'

pf()
# Visual: Engineering positions grouped in shaded cluster box

#==========#
#  METRICS #
#==========#

/*--- Span of control

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP 1")
    AddManagerXT("vp2", "VP 2")
    AddStaffXT("staff1", "Staff 1")
    AddStaffXT("staff2", "Staff 2")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("vp2", "ceo")
    ReportsTo("staff1", "vp1")
    ReportsTo("staff2", "vp1")
    
    ? AverageSpanOfControl() #--> 2.0
}

pf()

/*--- Position hierarchy analysis

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")

    AddManagerXT("vp1", "VP 1")
    AddManagerXT("vp2", "VP 2")

    AddStaffXT("s1", "Staff 1")
    AddStaffXT("s2", "Staff 2")
    AddStaffXT("s3", "Staff 3")

    ? @@NL( PositionsByLevel() ) + NL
	#-->
	'
	[
		[
			"executive",
			[ "ceo" ]
		],
		[
			"management",
			[ "vp1", "vp2" ]
		],
		[
			"staff",
			[ "s1", "s2", "s3" ]
		]
	]
	'

    ? @@NL( PositionsByLevelN() )
	#-->
	'
	[
		[ "executive", 1 ],
		[ "management", 2 ],
		[ "staff", 3 ]
	]
	'

}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Succession risk

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    
    AddPersonXT("p1", "Alice")
    AddPersonXT("p2", "Bob")
    AssignPerson("p1", "ceo")
    AssignPerson("p2", "vp1")
    
    ? @@( SuccessionRisk() ) #--> ["ceo", "vp1"]
    
    SetNodeProperty("vp1", "successor", "some_person")
    
    ? @@( SuccessionRisk() ) #--> ["ceo"] #ERROR returned [ "ceo", "vp1" ]
}

pf()

#==============#
#  VALIDATION  #
#==============#

/*--- Span of control validation

pr()

oOrg = new stzOrgChart("WideOrg")
oOrg {
    AddExecutiveXT("boss", "Boss")

    for i = 1 to 12
        AddStaffXT("s" + i, "Staff " + i)
        ReportsTo("s" + i, "boss")
    end
    
    ? @@NL( ValidateXT(:SpanOfControl) )

}
#-->
'
[
	[ "status", "fail" ],
	[ "domain", "span_of_control" ],
	[
		"issues",
		[ "Excessive span: boss (12 reports)" ]
	]
]
'

pf()

/*--- Segregation of duties

pr()

oOrg = new stzOrgChart("BankOrg")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("treasury", "Treasury")
    AddManagerXT("ops", "Operations")
    
    SetPositionDepartment("treasury", "treasury")
    SetPositionDepartment("ops", "operations")
    
    ReportsTo("treasury", "ceo")
    ReportsTo("ops", "treasury")  # VIOLATION
    
    ? @@NL( ValidateXT(:SegregationOfDuties) )
}
#-->
'
[
	[ "status", "fail" ],
	[ "domain", "segregation_of_duties" ],
	[ "issuecount", 1 ],
	[
		"issues",
		[ "SOD-001: Operations reports through Treasury" ]
	]
]
'

pf()

/*--- BCEAO governance

pr()

oOrg = new stzOrgChart("BankOrg")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("audit", "Audit")
    SetPositionDepartment("audit", "audit")
    ReportsTo("audit", "ceo")
    
    ? @@NL( ValidateXT(:BCEAO) )
}
#-->
'
[
	[ "status", "fail" ],
	[ "domain", "BCEAO_governance" ],
	[ "issuecount", 2 ],
	[
		"issues",
		[
			"BCEAO-001: No Board of Directors found",
			"BCEAO-003: No dedicated Risk Management function"
		]
	]
]
'

pf()

/*--- Multiple validators

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    ReportsTo("vp1", "ceo")
    
    ? @@NL( ValidateXT(["soc", "vacancy"]) )
 
}
#-->
'
[
	[ "status", "fail" ],
	[ "validatorsrun", 2 ],
	[ "validatorsfailed", 1 ],
	[ "totalissues", 2 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "fail" ],
				[ "domain", "vacancy" ],
				[ "issuecount", 2 ],
				[
					"issues",
					[ "Vacant positions: 2" ]
				],
				[
					"affectednodes",
					[ "ceo", "vp1" ]
				]
			]
		]
	],
	[
		"affectednodes",
		[ "ceo", "vp1" ]
	]
]
'

pf()

#=================#
#  VISUALIZATION  #
#=================#

/*--- Theme and layout

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    SetTheme("vibrant")
    SetLayout(:LeftRight)
    SetEdgeLineStyle(:Curved) #ERR no effect!
    
    ? Theme() #--> "vibrant"
    ? Layout() #--> "leftright"
    ? Splines() #--> "curved"
    
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp_eng, "VP Engineering")
    AddStaffXT(:@dev1, "Developer 1")
    AddStaffXT(:@dev2, "Developer 2")

    ReportsTo(:@vp_eng, :@ceo)
    ReportsTo(:@dev1, :@vp_eng)
    ReportsTo(:@dev2, :@vp_eng)

    # View() displays horizontal tree with curved edges
    #ERR // Theme is not applied, Splines are not curved!
}

pf()
# Executed in 0.04 second(s) in Ring 1.24

/*--- Focus on vacant positions

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {

    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP 1")
    ReportsTo(:@vp1, :@ceo)

    AddPersonXT(:@alice, "Alice")
    AssignPerson(:@alice, :@ceo)

    ViewVacant()  # vp1 highlighted in magenta, ceo in gold
}

pf()

/*--- Focus on populated positions

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {

    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP 1")
    ReportsTo(:@vp1, :@ceo)

    AddPersonXT(:@alice, "Alice")
    AssignPerson(:@alice, :@ceo)
    
    ViewNonVacant()  # ceo highlighted in magenta, vp1 in white
}

pf()

/*--- Validation-driven visualization

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP 1")
    SubordinateOf("vp1", "ceo") # Or ReportsTo

    ViewXT(:vacancy)  # Validates and highlights vacant positions
}

pf()

/*--- View succession risk

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddPersonXT("p1", "Alice")
    AssignPerson("p1", "ceo")
    
    ? @@NL( ValidateXT(:Succession) )

    ViewAtRisk()  # CEO highlighted (no successor designated)
}
#-->
'
[
	[ "status", "fail" ],
	[ "domain", "succession" ],
	[ "issuecount", 1 ],
	[
		"issues",
		[ "No successor: ceo" ]
	],
	[
		"affectednodes",
		[ "ceo" ]
	]
]
'

pf()

#=============#
#  REPORTING  #
#=============#

/*--- Summary report

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP")
    AddStaffXT(:@dev1, "Dev")
    
    ? @@NL( SummaryReport() )
}
#-->
'
[
	[ "title", "Organizational Summary" ],
	[ "date", "03/12/2025" ],
	[
		"metrics",
		[
			[ "totalpositions", 3 ],
			[ "filledpositions", 0 ],
			[ "vacancyrate", 100 ],
			[ "avgspan", 0 ],
			[
				"levels",
				[
					[
						"executive",
						[ "ceo" ]
					],
					[
						"management",
						[ "vp1" ]
					],
					[
						"staff",
						[ "dev1" ]
					]
				]
			]
		]
	]
]
'

pf()

/*--- Vacancy report

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP Sales")
    
    ? @@NL(Vacant()) #--> [ "ceo", "vp1" ]

    ? @@NL( VacancyReport() )
}
#-->
'
[ "ceo", "vp1" ]
[
	[ "title", "Vacancy Report" ],
	[ "vacancycount", 2 ],
	[ "vacancyrate", 100 ],
	[
		"details",
		[
			[
				[ "position", "ceo" ],
				[ "title", "CEO" ],
				[ "department", "" ],
				[ "level", "staff" ]
			],
			[
				[ "position", "vp1" ],
				[ "title", "VP Sales" ],
				[ "department", "" ],
				[ "level", "staff" ]
			]
		]
	]
]
'

pf()

/*--- Succession report

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

/*--- Succession report

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP Sales")
    ReportsTo("vp1", "ceo")

    ? @@NL( ComplianceReport() )
}
#-->
'
[
	[ "title", "Compliance Status Report" ],
	[ "date", "03/12/2025" ],
	[
		"checks",
		[
			[
				[ "status", "fail" ],
				[ "domain", "BCEAO_governance" ],
				[ "issuecount", 2 ],
				[
					"issues",
					[
						"BCEAO-001: No Board of Directors found",
						"BCEAO-003: No dedicated Risk Management function"
					]
				]
			],
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "segregation_of_duties" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			]
		]
	],
	[ "overallstatus", "non-compliant" ],
	[ "failedchecks", 1 ]
]
'

pf()

/*--- Succession report

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

/*--- Path finding

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    AddStaffXT("dev1", "Dev")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("dev1", "vp1")
    
    ? @@( PathBetween("ceo", "dev1") ) #--> ["ceo", "vp1", "dev1"]
    ? ShortestPathLength("ceo", "dev1") #--> 2
}

pf()

/*--- Reachability

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP 1")
    AddManagerXT("vp2", "VP 2")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("vp2", "ceo")
    
    ? @@( ReachableFrom("ceo") ) #--> ["ceo", "vp1", "vp2"]
}

pf()

/*--- Connectivity

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    ReportsTo("vp1", "ceo")
    
    ? IsConnected() #--> TRUE
    ? CyclicDependencies() #--> FALSE
}

pf()

/*--- Property queries

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT("vp1", "VP Eng")
    AddManagerXT("vp2", "VP Sales")
    AddStaffXT("dev1", "Dev")
    
    SetPositionDepartment("vp1", "engineering")
    SetPositionDepartment("dev1", "engineering")
    SetPositionDepartment("vp2", "sales")
    
    ? @@( NodesByProperty("department", "engineering") )
    #--> ["vp1", "dev1"]
}

pf()

/*--- Property range queries

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT(:@mgr, "IT Manager")

    AddStaffXT(:@dev1, "Developer 1")
    AddStaffXT(:@dev2, "Developer 2")
    AddStaffXT(:@dev3, "Developer 3")
    
    ReportsTo(:@dev1, :@mgr)
    ReportsTo(:@dev2, :@mgr)
    ReportsTo(:@dev3, :@mgr)

    SetNodeProperty(:@dev1, "performance", 85)
    SetNodeProperty(:@dev2, "performance", 65)
    SetNodeProperty(:@dev3, "performance", 92)
    
    acHigh = NodesWithPropertyXT("performance", :Between = [80, 100])
    ? @@( acHigh ) #--> ["dev1", "dev3"]

    ViewPerformant()
}

pf()

/*--- Graph metrics

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    AddStaffXT("dev1", "Dev")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("dev1", "vp1")
    
    ? NodeDensity() #--> 33.33
    ? Diameter() #--> 2
    ? AveragePathLength() #--> 1.33
}

pf()

#============================================#
#  VISUAL RULES (inherited from stzDiagram)  #
#============================================#

/*--- Color high performers

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT("mgr", "Manager")
    AddStaffXT("dev1", "Dev 1")
    AddStaffXT("dev2", "Dev 2")
    
    ReportsTo("dev1", "mgr")
    ReportsTo("dev2", "mgr")

    SetNodeProperty("dev1", "performance", 85)
    SetNodeProperty("dev2", "performance", 65)
    
    oRule = new stzGraphRule("highlight_high")
    oRule {
        SetRuleType("visual")
        When("performance", "greaterthan", 80)
        Then("color", "set", "gold")
    }
    
    SetRule(oRule)
    ApplyVisualRules() #ERR has no effect!
    
    ? @@( NodesAffectedByRules() ) #--> ["dev1"]
    #ERR returned all the nodes! [ "mgr", "dev1", "dev2" ]
    View() // #ERR Must show dev1 in gold, dev2 in default color
}

pf()

#==========================#
#  ORGANIZATIONAL CHANGES  #
#==========================#

/*--- Reporting line changes

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP 1")
    AddManagerXT("vp2", "VP 2")
    AddStaffXT("dev1", "Dev")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("vp2", "ceo")
    ReportsTo("dev1", "vp1")
    
    ? @@( DirectReports("vp1") ) #--> ["dev1"]
    ? @@( DirectReports("vp2") ) #--> []
    
    ChangeReportingLine("dev1", "vp2")
    
    ? @@( DirectReports("vp1") ) #--> []
    ? @@( DirectReports("vp2") ) #--> ["dev1"]
}

pf()

/*--- Position removal

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    AddPersonXT("p1", "Alice")
    AssignPerson("p1", "vp1")
    
    ? NodeCount() #--> 2
    ? len(People()) #--> 1
    
    RemovePosition("vp1")
    
    ? NodeCount() #--> 1
    ? @@( PersonData("p1")[:position] ) #--> ""
}

pf()

#=================#
#  EXPORT/IMPORT  #
#=================#

/*--- Export to .stzorg

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddPersonXT("p1", "Alice")
    AssignPerson("p1", "ceo")
    
    cFormat = ToStzOrg()
    # Returns formatted .stzorg text
    
    WriteToStzOrgFile("txtfiles/test.stzorg")
    ? read("txtfiles/test.stzorg")
}
#-->
'
orgchart "TechCo"

positions
    ceo
        title: CEO
        level: executive
        department: 
        reportsTo: 

people
    p1
        name: Alice

assignments
    p1 -> ceo

departments
'

pf()

/*--- Import from .stzorg

pr()

oOrg = new stzOrgChart("Imported")
oOrg {
    ? read("txtfiles/test.stzorg")
    ImportFromStzOrgFile("txtfiles/test.stzorg")
    
    ? NodeCount() #--> 1
    ? len(People()) #--> 1
}
#-->
'
orgchart "TechCo"

positions
    ceo
        title: CEO
        level: executive
        department: 
        reportsTo: 

people
    p1
        name: Alice

assignments
    p1 -> ceo

departments'

pf()

/*---

pr()

oOrg = new stzOrgChart("Softabank OrgChart 2025")
oOrg {
	LoadFrom("txtfiles/bank_structure.stzorg")
	? @@NL( Summary() )

	View() #ERR // Split on deparmtmetn names with spaces creates empty nodes!
}

pf()

/*--- Export to DOT

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    ReportsTo("vp1", "ceo")
    
    cDot = Dot()
    # Returns Graphviz DOT format
    
    WriteToDotFile("txtfiles/test.dot")
    ? read("txtfiles/test.dot")
}
#-->
'
digraph "TechCo" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=1, ranksep=1, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#808080", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    ceo [label="CEO", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    vp1 [label="VP", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]

    ceo -> vp1

}
'

pf()

#===================#
#  EXPLAIN FEATURE  #
#===================#

/*--- Natural language analysis

pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    AddStaffXT("dev1", "Dev")
    
    ? @@NL( Explain() )
}
#-->
`
[
	[ "type", "Organization Chart" ],
	[
		"structure",
		"Organization 'TechCo' has 3 positions, 0 people, and 0 departments."
	],
	[
		"hierarchy",
		[
			"executive: 1 positions",
			"management: 1 positions",
			"staff: 1 positions",
			"Average span of control: 0"
		]
	],
	[
		"staffing",
		[
			"Vacancy rate: 100%",
			"Vacant positions: ceo, vp1, dev1"
		]
	],
	[
		"compliance",
		[
			"Found 2 compliance issues",
			"BCEAO: BCEAO-001: No Board of Directors found; BCEAO-003: No dedicated Risk Management function"
		]
	],
	[
		"risks",
		[ "No succession risks identified" ]
	],
	[
		"efficiency",
		[
			"Span of control may be underutilized (< 3 reports average)",
			"HIGH vacancy rate - may impact operations"
		]
	]
]
`

pf()


