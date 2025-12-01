
load "../stzbase.ring"

/*---
*/
pr()

oOrg = new stzOrgChart("Softabank – Inherited Structure (Flawed)")
oOrg {

    AddExecutivePositionXT("ceo", "CEO")

    AddManagementPositionXT("vp_sales", "VP Sales & Customer Relations")
    AddManagementPositionXT("vp_eng",   "VP Engineering & Digital")
    AddManagementPositionXT("vp_ops",   "VP Operations & Treasury")
    AddManagementPositionXT("dir_risk", "Chief Risk Officer")     # Reports to CEO → BCEAO violation
    AddManagementPositionXT("dir_audit","Director Internal Audit")# Reports to CEO → BCEAO violation

    # 1. Create the missing Board
    AddExecutivePositionXT("board", "Board of Directors")

    # 2. Correct reporting lines for independence
    ReportsTo("ceo",       "board")   # CEO now reports to Board
    ReportsTo("dir_audit", "board")   # Independent audit
    ReportsTo("dir_risk",  "board")   # Independent risk

    ReportsTo("vp_sales",  "ceo")
    ReportsTo("vp_eng",    "ceo")
    ReportsTo("vp_ops",    "ceo")
    ReportsTo("dir_risk",  "ceo")   # Should report to Board
    ReportsTo("dir_audit", "ceo")   # Should report to Board

    # No Board of Directors at all → critical BCEAO failure

    # Staff and people
    AddPersonXT("p_ceo", "Jean-Baptiste Kouassi")
    AssignPerson("p_ceo", "ceo")

    SetPositionDepartment("vp_sales", "sales")
    SetPositionDepartment("vp_eng",   "engineering")
    SetPositionDepartment("vp_ops",   "operations")
    SetPositionDepartment("dir_risk", "risk")
    SetPositionDepartment("dir_audit","audit")

    SetEdgeLineType(:Ortho)
    View()

}

pf()
# Executed in 2.03 second(s) in Ring 1.24

/*--- #TODO

pr()

o1 = new stzOrgChart("")
o1 {
	SetOutput("PNG") #ERR #TODDO
	AddNodeXT("ceo", "CEO")
	AddNodeXT("sales", "VP Sales")
	ReportsTo("sales", "ceo")
	View()
}

pf()

#----------------------------#
#  BASIC STRUCTURE CREATION  #
#----------------------------#

/*-- Tests adding positions, executive/management/staff levels, reporting lines, and basic DOT generation.

pr()

oOrg = new stzOrgChart("Basic_Hierarchy")
oOrg {

    SetLayout("TD")

    # Add executive position
    AddExecutivePositionXT("ceo", "CEO")

    # Add management positions
    AddManagementPositionXT("vp_sales", "VP Sales")
    AddManagementPositionXT("vp_eng", "VP Engineering")

    # Set reporting lines
    ReportsTo("vp_sales", "ceo")
    ReportsTo("vp_eng", "ceo")

    # Add staff positions with attributes
    AddStaffPositionXTT("sales_rep1", "Sales Rep 1", [:region = "North"])
    AddStaffPositionXTT("dev1", "Developer 1", [:skill = "Backend"])
    ReportsTo("sales_rep1", "vp_sales")
    ReportsTo("dev1", "vp_eng")

    # Verify positions
    ? @@NL( Positions() ) + NL
	#-->
	`
	[
		[
			[ "id", "ceo" ],
			[ "title", "CEO" ],
			[ "level", 0 ],
			[ "department", "" ],
			[ "reportsto", "" ],
			[ "incumbent", "" ],
			[ "isvacant", 1 ],
			[
				"attributes",
				[
					[ "level", "executive" ]
				]
			]
		],
		[
			[ "id", "vp_sales" ],
			[ "title", "VP Sales" ],
			[ "level", 0 ],
			[ "department", "" ],
			[ "reportsto", "ceo" ],
			[ "incumbent", "" ],
			[ "isvacant", 1 ],
			[
				"attributes",
				[
					[ "level", "management" ]
				]
			]
		],
		[
			[ "id", "vp_eng" ],
			[ "title", "VP Engineering" ],
			[ "level", 0 ],
			[ "department", "" ],
			[ "reportsto", "ceo" ],
			[ "incumbent", "" ],
			[ "isvacant", 1 ],
			[
				"attributes",
				[
					[ "level", "management" ]
				]
			]
		],
		[
			[ "id", "sales_rep1" ],
			[ "title", "Sales Rep 1" ],
			[ "level", 0 ],
			[ "department", "" ],
			[ "reportsto", "vp_sales" ],
			[ "incumbent", "" ],
			[ "isvacant", 1 ],
			[
				"attributes",
				[
					[ "region", "North" ],
					[ "level", "staff" ]
				]
			]
		],
		[
			[ "id", "dev1" ],
			[ "title", "Developer 1" ],
			[ "level", 0 ],
			[ "department", "" ],
			[ "reportsto", "vp_eng" ],
			[ "incumbent", "" ],
			[ "isvacant", 1 ],
			[
				"attributes",
				[
					[ "skill", "Backend" ],
					[ "level", "staff" ]
				]
			]
		]
	]
	`

    ? @@NL( Position("ceo") ) + NL
	#-->
	`
	[
		[ "id", "ceo" ],
		[ "title", "CEO" ],
		[ "level", 0 ],
		[ "department", "" ],
		[ "reportsto", "" ],
		[ "incumbent", "" ],
		[ "isvacant", 1 ],
		[
			"attributes",
			[
				[ "level", "executive" ]
			]
		]
	]
	`

    # View basic chart
//    ? Dot()

//    View() #TODO Check color
}
#-->
`
digraph "Basic_Hierarchy" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=1, ranksep=1, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#808080", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    ceo [label="CEO", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    vp_sales [label="VP Sales", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    vp_eng [label="VP Engineering", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    sales_rep1 [label="Sales Rep 1", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    dev1 [label="Developer 1", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]

    ceo -> vp_sales
    ceo -> vp_eng
    vp_sales -> sales_rep1
    vp_eng -> dev1

}
`

pf()
# Executed in 2.07 second(s) in Ring 1.24

#---------------------#
#  PEOPLE MANAGEMENT  #
#---------------------#

/*-- Tests adding people, assigning to positions, person data, vacancy status, and people listing.

pr()

oOrg = new stzOrgChart("People_Management")
oOrg {

    AddPosition("ceo")
    AddPosition("vp")
    AddPosition("cto")

    ReportsTo("vp", "ceo")
    ReportsTo("cto", "ceo")

    # Add people with data
    AddPersonXTT("p1", "John Doe", [:tenure = 5, :performance = "High"])
    AddPersonXT("p2", "Jane Smith")

    # Assign people to positions
    AssignPerson("p1", "ceo")
    AssignPerson("p2", "vp")

    # Verify assignments and data
    ? @@NL(People()) + NL
	#-->
	'
	[
		[
			[ "id", "p1" ],
			[ "name", "John Doe" ],
			[ "position", "ceo" ],
			[
				"data",
				[
					[ "tenure", 5 ],
					[ "performance", "High" ]
				]
			]
		],
		[
			[ "id", "p2" ],
			[ "name", "Jane Smith" ],
			[ "position", "vp" ],
			[ "data", [  ] ]
		]
	]
	'

    ? @@NL( PersonData("p1") ) + NL
	#-->
	'
	[
		[ "id", "p1" ],
		[ "name", "John Doe" ],
		[ "position", "ceo" ],
		[
			"data",
			[
				[ "tenure", 5 ],
				[ "performance", "High" ]
			]
		]
	]
	'

    ? @@(VacantPositions())
	#--> [ "cto" ]

    # View with nodes containing people amphasized with $aOrColors[:focus]
    //ViewPopulated() # Or ViewWithPeople() or ViewPeople()
    ViewVacant() # Or ViewVacancies()

}

pf()
# Executed in 2.23 second(s) in Ring 1.24

#-------------------------#
#  DEPARTMENT MANAGEMENT  #
#-------------------------#

/*-- Tests adding departments, assigning positions to departments,
# and department queries.

pr()

oOrg = new stzOrgChart("Department_Management")
oOrg {

    # Adding the positions and who reports to whom

    AddPositionXT(:ceo, "CEO")
    AddPositionXT(:sales_mgr, "Sales Manager")
    AddPositionXT(:eng_mgr, "Engineering Manager")

    ReportsTo(:sales_mgr, :ceo)
    ReportsTo(:eng_mgr, :ceo)

    # Adding departments and filling them with positions

    AddDepartmentXTT(:exec, "EXECUTIVE", [ :ceo ])
    AddDepartmentXTT(:sales, "SALES", [ :sales_mgr ])
    AddDepartmentXTT(:eng, "ENGINEERING", [ :eng_mgr ])

#TODO // Enhance the programming experience
# the fellowing 3 lines should be infered automatically
# from the two lines above so we don't need to write them

    # Set position departments
    SetPositionDepartment(:ceo, "EXECUTIVE")
    SetPositionDepartment(:sales_mgr, "SALES")
    SetPositionDepartment(:eng_mgr, "ENGINEERING")

    # Verify
    ? @@NL( Departments() ) + NL
	#-->
	`
	[
		[
			[ "id", "exec" ],
			[ "name", "EXECUTIVE" ],
			[
				"positions",
				[ "ceo" ]
			],
			[ "head", "" ]
		],
		[
			[ "id", "sales" ],
			[ "name", "SALES" ],
			[
				"positions",
				[ "sales_mgr" ]
			],
			[ "head", "" ]
		],
		[
			[ "id", "eng" ],
			[ "name", "ENGINEERING" ],
			[
				"positions",
				[ "eng_mgr" ]
			],
			[ "head", "" ]
		]
	]
	`

    ? @@NL( Department("SALES") )
   #--> [ ] #TODO Is ist correct?

    ViewDepartment(:Sales) #TODO // See why all nodes are white
}

pf()
# Executed in 2.22 second(s) in Ring 1.24

/*--- Highlighting path

pr()

oOrg = new stzOrgChart("Highlight_Test")
oOrg {
    AddExecutivePositionXT("ceo", "CEO")
    
    AddManagementPositionXT("vp_sales", "VP Sales")
    AddManagementPositionXT("vp_ops", "VP Ops")
    AddManagementPositionXT("vp_eng", "VP Eng")
    
    AddStaffPositionXT("sales1", "Sales Rep")
    AddStaffPositionXT("ops1", "Ops Staff")
    AddStaffPositionXT("dev1", "Developer")
    
    ReportsTo("vp_sales", "ceo")
    ReportsTo("vp_ops", "ceo")
    ReportsTo("vp_eng", "ceo")
    
    ReportsTo("sales1", "vp_sales")
    ReportsTo("ops1", "vp_ops")
    ReportsTo("dev1", "vp_eng")
    
    # Highlight just one path
//    HighlightPath("ops1", "ceo") #ERR  Depricated after refacoring
    View()
}

pf()

/*--- Complete examaple with validations and reports generation

pr()

oOrg = new stzOrgChart("Simple_Hierarchy")
oOrg {

    SetLayout(:LeftRight)
    SetEdgeLineType(:Curved)
    SetStrokeColor(:Invisible) #ERR // No effect

    #----------------#
    # LEVEL 1 – CEO  #
    #----------------#

    AddExecutivePositionXT("ceo", "CEO")

    #----------------#
    # LEVEL 2 – VPs  #
    #----------------#

    AddManagementPositionXT("vp_sales", "VP Sales")
    AddManagementPositionXT("vp_eng",   "VP Engineering")
    AddManagementPositionXT("vp_ops",   "VP Operations")

    ReportsTo("vp_sales", "ceo")
    ReportsTo("vp_eng",   "ceo")
    ReportsTo("vp_ops",   "ceo")

    #-----------------------#
    # LEVEL 3 – SALES TEAM  #
    #-----------------------#

    AddStaffPositionXT("sales_a", "Sales Rep A")
    AddStaffPositionXT("sales_b", "Sales Rep B")

    ReportsTo("sales_a", "vp_sales")
    ReportsTo("sales_b", "vp_sales")

    #-----------------------------#
    # LEVEL 3 – ENGINEERING TEAM  #
    #-----------------------------#

    AddStaffPositionXT("dev_a", "Developer A")
    AddStaffPositionXT("dev_b", "Developer B")
    AddStaffPositionXT("dev_c", "Developer C")
    AddStaffPositionXT("junior_b", "Junior B")

    ReportsTo("dev_a", "vp_eng")
    ReportsTo("dev_b", "vp_eng")
    ReportsTo("dev_c", "vp_eng")
    ReportsTo("junior_b", "dev_b")

    #----------------------------#
    # LEVEL 3 – OPERATIONS TEAM  #
    #----------------------------#

    AddStaffPositionXT("ops_a", "Ops Staff A")
    AddStaffPositionXT("ops_b", "Ops Staff B")

    ReportsTo("ops_a", "vp_ops")
    ReportsTo("ops_b", "vp_ops")

    #--------------------#
    # OPTIONAL COLORING  #
    #--------------------#

    SetNodeProperty("ceo", "department", "executive")
    SetNodeProperty("vp_sales", "department", "sales")
    SetNodeProperty("vp_eng", "department", "engineering")
    SetNodeProperty("vp_ops", "department", "operations")

    SetNodeProperty("sales_a", "department", "sales")
    SetNodeProperty("sales_b", "department", "sales")

    SetNodeProperty("dev_a", "department", "engineering")
    SetNodeProperty("dev_b", "department", "engineering")

    SetNodeProperty("ops_a", "department", "operations")
    SetNodeProperty("ops_b", "department", "operations")
	
	#----------------------------
	# ADD PEOPLE
	#----------------------------
	
	AddPersonXT("p_ceo", "Jean-Baptiste Kouassi")
	AssignPerson("p_ceo", "ceo")
	
	AddPersonXT("p_vp_sales", "Fatoumata Diarra")
	AssignPerson("p_vp_sales", "vp_sales")
	
	# Leave some positions vacant for demonstration
	
	#-----------------------------------#
	#  VALIDATIORS - stzOrgChart LEVEL  #
	#-----------------------------------#

	? "BCEAO BANKING GOVERNANCE VALIDATION"
	? "-----------------------------------" + NL
	
	? @@NL( ValidateXT(:BCEAO) ) + NL
	
	
	? "SPAN OF CONTROL VALIDATION"
	? "--------------------------" + NL
	
	? @@NL( ValidateXT(:SpanOfControl) ) + NL
	
	
	? "SEGREGATION OF DUTIES VALIDATION"
	? "--------------------------------" + NL
	
	? @@NL( ValidateXT(:SegregationOfDuties) ) + NL
	
	#----------------------------------#
	#  VALIDATIORS - stzdiagram LEVEL  #
	#----------------------------------#

	? "GDPR VALIDATION"
	? "---------------"
#ERR Stack Overflow 
# In method validatext() in file D:\GitHub\stzlib\libraries\stzlib\base\graph/stzdiagram.ring
# Called from line 392 In method _validatesingle() in file D:\GitHub\stzlib\libraries\stzlib\base\graph/stzorgchart.ring
# Called from line 1490 In method validatext() in file D:\GitHub\stzlib\libraries\stzlib\base\graph/stzdiagram.ring
# Called from line 392 In method _validatesingle()

	? ValidateXT(:GDPR) + NL #--> TRUE

	? "SOX VALIDATION"
	? "---------------"
	
	? @@NL( ValidateXT(:SOX) ) + NL #--> TRUE

	? "BANKING VALIDATION"
	? "------------------"
	
	? @@NL( ValidateXT(:BANKING) ) + NL #--> TRUE

	? "DAG VALIDATION"
	? "--------------"
	
	? @@NL( ValidateXT(:DAG) ) + NL #--> TRUE

	? "REACHABILITY VALIDATION"
	? "-----------------------"
	
	? @@NL( ValidateXT(:REACHABILITY) ) + NL #--> TRUE

	? "COMPLETENESS VALIDATION"
	? "-----------------------"
	
	? @@NL( ValidateXT(:COMPLETENESS) ) + NL #--> TRUE

	#-----------#
	#  REPROTS  #
	#-----------#

	? "ORGANIZATIONAL SUMMARY REPORT"
	? "-----------------------------" + NL
	
	? @@NL( GenerateReport(:Summary) ) + NL
	
	
	? "VACANCY REPORT"
	? "--------------" + NL
	
	? @@NL( GenerateReport(:Cacancies) ) + NL
	
	
	? "SUCCESSION RISK REPORT"
	? "----------------------" + NL
	
	? @@NL( GenerateReport(:Succession) ) + NL
	
	
	? "COMPLIANCE STATUS REPORT"
	? "------------------------" + NL
	
	? @@NL( GenerateReport(:Compliance) ) + NL
	
	
	? "SPAN OF CONTROL ANALYSIS"
	? "------------------------" + NL
	
	? @@NL( GenerateReport(:Span) ) + NL
	
	
	? "APPLYING ANALYSIS LAYERS"
	? "------------------------" + NL
	
	oRiskLayer = AddAnalysisLayer("Risk Assessment", "risk")
	? "✓ Risk analysis layer added"
	
	oSuccessionLayer = AddAnalysisLayer("Succession Planning", "succession")
	? "✓ Succession planning layer added"
	
	ApplyAllLayers()
	? "✓ All analysis layers applied" + NL

	
	? "SIMULATING REORGANIZATION"
	? "-------------------------" + NL
	
	aChanges = [
		[:type = "change_reporting", :subordinate = "dir_ops", :supervisor = "ceo"],
		[:type = "add_position", :id = "dir_digital", :title = "Director of Digital Banking"],
		[:type = "change_reporting", :subordinate = "dir_it", :supervisor = "dir_digital"]
	]
	
	? @@NL( SimulateReorganization(aChanges) ) + NL

	
	? "CREATING ORGANIZATIONAL SNAPSHOT"
	? "--------------------------------" + NL
	
	? @@NL( CreateSnapshot("Q4_2024") ) + NL #TODO // What's the effect, hwat added value?

	
	? "GENERATING VISUALIZATION"
	? "------------------------" + NL
	
	ColorByDepartment()
	? "✓ Color-coded by department"
	
	HighlightPath("ops_analyst1", "ceo") #ERR //No effect in the visual
	? "✓ Highlighted reporting path to board" + NL

	? "Opening visualization..."
	
	View()

}
pf()

#----------------------------#
# VALIDATION AND COMPLIANCE  #
#----------------------------#

/*-- Tests BCEAO governance, span of control, segregation of duties validations, and direct reports metrics.

pr()

oOrg = new stzOrgChart("Validation_Compliance")
oOrg {

    SetEdgeSpline("ortho") #TODO not effective

    AddExecutivePositionXT("board", "Board")
    AddExecutivePositionXT("ceo", "CEO")
    ReportsTo("ceo", "board")

    AddManagementPositionXT("dir_audit", "Dir Audit")
    ReportsTo("dir_audit", "board")  # Compliant

    AddManagementPositionXT("dir_ops", "Dir Ops")
    AddManagementPositionXT("dir_treasury", "Dir Treasury")
    ReportsTo("dir_ops", "ceo")  # Should not report to treasury for SOD
    ReportsTo("dir_treasury", "ceo")

    # Add multiple reports for span test
    for i=1 to 10
        AddStaffPositionXT("staff"+i, "Staff "+i)
        ReportsTo("staff"+i, "dir_ops")  # Excessive span
    next

    # Set departments for SOD
    SetPositionDepartment("dir_ops", "operations")
    SetPositionDepartment("dir_treasury", "treasury")

    # Validate
    ? @@NL( ValidateBCEAOGovernance() ) + NL #TODO// Abstract
	#-->
	'
	[
		[ "status", "fail" ],
		[ "domain", "BCEAO_governance" ],
		[ "issuecount", 1 ],
		[
			"issues",
			[
				"BCEAO-003: No dedicated Risk Management function"
			]
		]
	]
	'

    ? @@NL( ValidateSpanOfControl() ) + NL
	#-->
	'
	[
		[ "status", "fail" ],
		[ "domain", "span_of_control" ],
		[
			"issues",
			[
				"Excessive span: ",
				"dir_ops",
				" (",
				10,
				" reports)"
			]
		]
	]
'

    ? @@NL( ValidateSegregationOfDuties() ) + NL
	#-->
	'
	[
		[ "status", "pass" ],
		[ "domain", "segregation_of_duties" ],
		[ "issuecount", 0 ],
		[ "issues", [  ] ]
	]
	'


    # Metrics

    ? DirectReportsCount("dir_ops")
    #--> 10

    ? @@NL( DirectReports("dir_ops") )
	#-->
	'
	[
		"staff1",
		"staff2",
		"staff3",
		"staff4",
		"staff5",
		"staff6",
		"staff7",
		"staff8",
		"staff9",
		"staff10"
	]
	'
	
    View()

}

pf()
# Executed in 2.18 second(s) in Ring 1.24

#--------------------------#
# REPORTING AND ANALYTICS  #
#--------------------------#

/*-- Tests organizational metrics and all report types.

pr()

oOrg = new stzOrgChart("Reporting_Analytics")
oOrg {
    SetEdgeLineType("curved")
    AddExecutivePositionXT("ceo", "CEO")

    # Add positions with levels
    AddManagementPositionXT("mgr1", "Manager 1")
    ReportsTo("mgr1", "ceo")

    for i=1 to 5
        AddStaffPositionXT("staff"+i, "Staff "+i)
        ReportsTo("staff"+i, "mgr1")
    next

    # Leave some vacant
    AddPositionXT("vacant1", "Vacant Position")
    ReportsTo("vacant1", "ceo")

    # Add people to some
    AddPersonXT("p1", "Person 1")
    AssignPerson("p1", "ceo")

    # Metrics
    ? AverageSpanOfControl()  #--> 3
    ? VacancyRate() #--> 87.50

    ? @@Nl( PositionsByLevel() )
	#-->
	'
	[
		[ "executive", 1 ],
		[ "management", 1 ],
		[ "staff", 6 ]
	]
	'

    ? @@( SuccessionRisk() ) + NL
    #--> [ "ceo" ]

    # Reports
    ? @@Nl( GenerateReport("summary") )
	#-->
	'
	[
		[ "title", "Organizational Summary" ],
		[ "date", "25/11/2025" ],
		[
			"metrics",
			[
				[ "totalpositions", 8 ],
				[ "filledpositions", 1 ],
				[ "vacancyrate", 87.50 ],
				[ "avgspan", 3 ],
				[
					"levels",
					[
						[ "executive", 1 ],
						[ "management", 1 ],
						[ "staff", 6 ]
					]
				]
			]
		]
	]
	'

    ? @@Nl( GenerateReport("vacancies") )
	#-->
	'
	[
		[ "title", "Vacancy Report" ],
		[ "vacancycount", 7 ],
		[ "vacancyrate", 87.50 ],
		[
			"details",
			[
				[
					[ "position", "mgr1" ],
					[ "title", "Manager 1" ],
					[ "department", "" ],
					[ "level", "management" ]
				],
				[
					[ "position", "staff1" ],
					[ "title", "Staff 1" ],
					[ "department", "" ],
					[ "level", "staff" ]
				],
				[
					[ "position", "staff2" ],
					[ "title", "Staff 2" ],
					[ "department", "" ],
					[ "level", "staff" ]
				],
				[
					[ "position", "staff3" ],
					[ "title", "Staff 3" ],
					[ "department", "" ],
					[ "level", "staff" ]
				],
				[
					[ "position", "staff4" ],
					[ "title", "Staff 4" ],
					[ "department", "" ],
					[ "level", "staff" ]
				],
				[
					[ "position", "staff5" ],
					[ "title", "Staff 5" ],
					[ "department", "" ],
					[ "level", "staff" ]
				],
				[
					[ "position", "vacant1" ],
					[ "title", "Vacant Position" ],
					[ "department", "" ],
					[ "level", "staff" ]
				]
			]
		]
	]
	'

    ? @@Nl( GenerateReport("succession") )
	#-->
	'
	[
		[ "title", "Succession Risk Report" ],
		[ "date", "25/11/2025" ],
		[ "highriskcount", 1 ],
		[
			"details",
			[
				[
					[ "position", "ceo" ],
					[ "title", "CEO" ],
					[ "incumbent", "Person 1" ],
					[ "department", "" ],
					[ "risklevel", "high" ]
				]
			]
		]
	]
	'

    ? @@Nl( GenerateReport("compliance") )
	#-->
	'
	[
		[ "title", "Compliance Status Report" ],
		[ "date", "25/11/2025" ],
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

    ? @@Nl( GenerateReport("span") )
	#-->
	'
	[
		[ "title", "Span of Control Analysis" ],
		[ "date", "25/11/2025" ],
		[
			"details",
			[
				[
					[ "position", "ceo" ],
					[ "title", "CEO" ],
					[ "directreports", 1 ],
					[ "status", "underutilized" ]
				],
				[
					[ "position", "mgr1" ],
					[ "title", "Manager 1" ],
					[ "directreports", 5 ],
					[ "status", "optimal" ]
				]
			]
		]
	]
'
	View()
}

pf()
# Executed in 2.31 second(s) in Ring 1.24

#-------------------------#
# ORGANIZATIONAL CHANGES  #
#-------------------------#

/*-- Tests reassigning people, removing positions, changing reporting lines.

pr()

oOrg = new stzOrgChart("Org_Changes")
oOrg {

    AddPositionXT("pos1", "Position 1")
    AddPositionXT("pos2", "Position 2")
    AddPositionXT("pos3", "Position 3")
    ReportsTo("pos2", "pos1")
    ReportsTo("pos3", "pos1")

    AddPersonXT("p1", "Person 1")
    AssignPerson("p1", "pos1")

    # Reassign
    ReassignPerson("p1", "pos2")

    # Change reporting
    ChangeReportingLine("pos3", "pos2")

    # Remove position
    RemovePosition("pos1")

    # Verify
    ? @@Nl( Positions() )
	#-->
	'
	[
		[
			[ "id", "pos2" ],
			[ "title", "Position 2" ],
			[ "level", 0 ],
			[ "department", "" ],
			[ "reportsto", "pos1" ],
			[ "incumbent", "p1" ],
			[ "isvacant", 0 ],
			[ "attributes", [  ] ]
		],
		[
			[ "id", "pos3" ],
			[ "title", "Position 3" ],
			[ "level", 0 ],
			[ "department", "" ],
			[ "reportsto", "pos2" ],
			[ "incumbent", "" ],
			[ "isvacant", 1 ],
			[ "attributes", [  ] ]
		]
	]
'
    View()
}
#-->
`
[
	[
		[ "id", "pos2" ],
		[ "title", "Position 2" ],
		[ "level", 0 ],
		[ "department", "" ],
		[ "reportsto", "pos1" ],
		[ "incumbent", "p1" ],
		[ "isvacant", 0 ],
		[ "attributes", [  ] ]
	],
	[
		[ "id", "pos3" ],
		[ "title", "Position 3" ],
		[ "level", 0 ],
		[ "department", "" ],
		[ "reportsto", "pos2" ],
		[ "incumbent", "" ],
		[ "isvacant", 1 ],
		[ "attributes", [  ] ]
	]
]
`

pf()
# Executed in 2.27 second(s) in Ring 1.24

#---------------------------#
# SIMULATIONS AND SNAPSHOTS #
#---------------------------#

/*-- Tests simulating reorganizations and creating snapshots.

pr()

oOrg = new stzOrgChart("Simulations_Snapshots")
oOrg {

    AddPositionXT("ceo", "CEO")
    AddPositionXT("vp1", "VP1")
    AddPositionXT("vp2", "VP2")
    ReportsTo("vp1", "ceo")
    ReportsTo("vp2", "ceo")

    # Create snapshot
    ? @@NL( CreateSnapshot("Initial") ) #ERR Depricated after refactoring (see stzGraphSimulation)
	#-->
	'
	[
		[ "id", "Initial" ],
		[ "date", "25/11/2025" ],
		[
			"positions",
			[
				[
					[ "id", "ceo" ],
					[ "title", "CEO" ],
					[ "level", 0 ],
					[ "department", "" ],
					[ "reportsto", "" ],
					[ "incumbent", "" ],
					[ "isvacant", 1 ],
					[ "attributes", [  ] ]
				],
				[
					[ "id", "vp1" ],
					[ "title", "VP1" ],
					[ "level", 0 ],
					[ "department", "" ],
					[ "reportsto", "ceo" ],
					[ "incumbent", "" ],
					[ "isvacant", 1 ],
					[ "attributes", [  ] ]
				],
				[
					[ "id", "vp2" ],
					[ "title", "VP2" ],
					[ "level", 0 ],
					[ "department", "" ],
					[ "reportsto", "ceo" ],
					[ "incumbent", "" ],
					[ "isvacant", 1 ],
					[ "attributes", [  ] ]
				]
			]
		],
		[ "people", [  ] ],
		[ "departments", [  ] ]
	]
	'

    # Simulate changes
    aChanges = [
        [:type = "change_reporting", :subordinate = "vp2", :supervisor = "vp1"],
        [:type = "add_position", :id = "new_pos", :title = "New Position"],
        [:type = "remove_position", :position = "vp1"]
    ]

    ? @@NL( SimulateReorganization(aChanges) )
	#-->
	'
	[
		[
			"before",
			[
				[ "spanofcontrol", 2 ],
				[ "vacancyrate", 100 ]
			]
		],
		[
			"after",
			[
				[ "spanofcontrol", 0 ],
				[ "vacancyrate", 100 ]
			]
		],
		[
			"changes",
			[
				[
					[ "type", "change_reporting" ],
					[ "subordinate", "vp2" ],
					[ "supervisor", "vp1" ]
				],
				[
					[ "type", "add_position" ],
					[ "id", "new_pos" ],
					[ "title", "New Position" ]
				],
				[
					[ "type", "remove_position" ],
					[ "position", "vp1" ]
				]
			]
		]
	]
	'

    # View simulated
    ViewSimulatedChart()  #TODO// Add it. Note: SimulatedChart is in simulation class, need to capture
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#--------------------------#
#  VISUALIZATION FEATURES  #
#--------------------------#

/*-- Tests visualization options, branching, views, coloring, highlighting.

pr()

oOrg = new stzOrgChart("Visualization")
oOrg {

    AddExecutivePositionXT("ceo", "CEO")
    AddManagementPositionXT("vp1", "VP1")
    AddManagementPositionXT("vp2", "VP2")
    ReportsTo("vp1", "ceo")
    ReportsTo("vp2", "ceo")

    AddStaffPositionXT("staff1", "Staff1")
    AddStaffPositionXT("staff2", "Staff2")
    ReportsTo("staff1", "vp1")
    ReportsTo("staff2", "vp2")

    # Set departments for coloring
    SetPositionDepartment("vp1", "sales")
    SetPositionDepartment("vp2", "engineering")

    ColorByDepartment()

    # Highlight path
 //   HighlightPath("staff1", "ceo") #ERR Depricated after refactoring!

    # Different views
    ViewPopulated() # Same visual
    ViewVacant()     "Idem
    ViewByDepartment() #ERR Undefined after refactoring!
}

pf()

#-------------------------#
#  EDGE CASE: EMPTY CHART #
#-------------------------#

/*-- Tests behavior with no positions, people, or departments.

pr()

oOrg = new stzOrgChart("Empty_Chart")
oOrg {

    ? @@( Positions() ) # []
    ? @@( People() )   # []
    ? @@( Departments() ) # []
    ? AverageSpanOfControl()  # 0
    ? VacancyRate()  # 0
    ? @@NL( ValidateBCEAOGovernance() )  # fail, no board
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

    View() # Empty image

}

pf()
# Executed in 1.76 second(s) in Ring 1.24

#-----------------------------#
# EDGE CASE: SINGLE POSITION  #
#-----------------------------#

/*-- Tests chart with only one position.

pr()

oOrg = new stzOrgChart("Single_Position")
oOrg {

    AddExecutivePositionXT("ceo", "CEO")

    ? @@NL( Positions() ) + NL
	#-->
	`
	[
		[
			[ "id", "ceo" ],
			[ "title", "CEO" ],
			[ "level", 0 ],
			[ "department", "" ],
			[ "reportsto", "" ],
			[ "incumbent", "" ],
			[ "isvacant", 1 ],
			[
				"attributes",
				[
					[ "level", "executive" ]
				]
			]
		]
	]
	`

    ? DirectReportsCount("ceo")  #--> 0

    ? @@( VacantPositions() ) + NL  #--> ["ceo"]

    ? AverageSpanOfControl()  # 0

    ? @@NL( ValidateSpanOfControl() ) # pass
	#-->
	`
	[
		[ "status", "pass" ],
		[ "domain", "span_of_control" ],
		[ "issues", [  ] ]
	]
	`

    View()

}

pf()
# Executed in 1.99 second(s) in Ring 1.24

#---------------------------------#
# EDGE CASE: DUPLICATE POSITIONS  #
#---------------------------------#

/*-- Tests adding position with existing ID.

pr()

oOrg = new stzOrgChart("Duplicate_Positions")
oOrg {

    AddPositionXT("pos1", "Position 1")
    AddPositionXT("pos1", "Duplicate")  # Class appends, no check, so len=2, but IDs duplicate

    ? len(Positions())  # 2, but issue
    ? @@NL(Positions())
#-->
'
[
	[
		[ "id", "pos1" ],
		[ "title", "Position 1" ],
		[ "level", 0 ],
		[ "department", "" ],
		[ "reportsto", "" ],
		[ "incumbent", "" ],
		[ "isvacant", 1 ],
		[ "attributes", [  ] ]
	],
	[
		[ "id", "pos1" ],
		[ "title", "Duplicate" ],
		[ "level", 0 ],
		[ "department", "" ],
		[ "reportsto", "" ],
		[ "incumbent", "" ],
		[ "isvacant", 1 ],
		[ "attributes", [  ] ]
	]
]
'

}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#-------------------------------#
# EDGE CASE: INVALID REPORTING  #
#-------------------------------#

/*-- Tests reporting to non-existent supervisor.

pr()

oOrg = new stzOrgChart("Invalid_Reporting")
oOrg {

    AddPositionXT("sub", "Subordinate")
    ReportsTo("sub", "nonexistent")

    ? Position("sub")[:reportsTo]  # "nonexistent"
    ? Dot()  # May have error in graph
    View() #TODO // Contains just a Subordinate node, is it correct?
}
#-->
'
nonexistent
digraph "Invalid_Reporting" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=ortho, nodesep=1, ranksep=1, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    sub [label="Subordinate", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]
}
'

pf()
# Executed in 2.10 second(s) in Ring 1.24

#---------------------------------#
#  EDGE CASE: CYCLE IN HIERARCHY  #
#---------------------------------#

/*-- Tests creating a reporting cycle.

pr()

oOrg = new stzOrgChart("Cycle_Hierarchy")
oOrg {

    AddPositionXT("a", "A")
    AddPositionXT("b", "B")
    AddPositionXT("c", "C")

    ReportsTo("b", "a")
    ReportsTo("c", "b")
    ReportsTo("a", "c")  # Cycle

    ? Dot()  # Should render, but cycle present
    View()
}
#-->
`
digraph "Cycle_Hierarchy" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=1, ranksep=1, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#808080", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    a [label="A", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    b [label="B", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    c [label="C", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]

    a -> b
    b -> c
    c -> a

}
`

pf()
# Executed in 2.07 second(s) in Ring 1.24

#---------------------------------------#
#  EDGE CASE: REMOVE ASSIGNED POSITION  #
#---------------------------------------#

/*-- Tests removing position with assigned person.

pr()

oOrg = new stzOrgChart("Remove_Assigned")
oOrg {

    AddPositionXT("pos", "Position")
    AddPersonXT("p1", "Person 1")
    AssignPerson("p1", "pos")

    ? Position("pos")[:incumbent]  #--> "p1"

    RemovePosition("pos")

    ? @@(Positions()) + NL #--> []

    ? @@NL( PersonData("p1") )
	#-->
	'
	[
		[ "id", "p1" ],
		[ "name", "Person 1" ],
		[ "position", "" ],
		[ "data", [  ] ]
	]
	'
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#---------------------------------#
# EDGE CASE: INVALID ASSIGNMENTS  #
#---------------------------------#

/*-- Tests assigning invalid person or position.

pr()

oOrg = new stzOrgChart("Invalid_Assignments")
oOrg {

    AddPersonXT("p1", "Person 1")
    AssignPerson("p1", "nonpos")  # No effect

    AddPositionXT("pos", "Position")
    AssignPerson("nonp", "pos")  # No effect

    ? @@NL( PersonData("p1") ) + NL
	#-->
	'
	[
		[ "id", "p1" ],
		[ "name", "Person 1" ],
		[ "position", "nonpos" ], #TODO // Is it correct?
		[ "data", [  ] ]
	]
	'

    ? @@NL( Position("pos") ) # ""
	#-->
	'
	[
		[ "id", "pos" ],
		[ "title", "Position" ],
		[ "level", 0 ],
		[ "department", "" ],
		[ "reportsto", "" ],
		[ "incumbent", "nonp" ],
		[ "isvacant", 0 ],
		[ "attributes", [  ] ]
	]
	'
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#----------------------------#
# EDGE CASE: WIDE HIERARCHY  #
#----------------------------#

/*-- Tests manager with many direct reports.

pr()

oOrg = new stzOrgChart("Wide_Hierarchy")
oOrg {

    AddManagementPositionXT("mgr", "Manager")

    for i = 1 to 20
        cId = "staff" + i
        AddStaffPositionXT(cId, "Staff " + i)
        ReportsTo(cId, "mgr")
    next

    ? DirectReportsCount("mgr")  # 20
    ? @@NL( ValidateSpanOfControl() ) # fail
	#-->
	'
	[
		[ "status", "fail" ],
		[ "domain", "span_of_control" ],
		[
			"issues",
			[
				"Excessive span: ",
				"mgr",
				" (",
				20,
				" reports)"
			]
		]
	]
	'

}

pf()
# Executed in 0.10 second(s) in Ring 1.24

#----------------------------#
# EDGE CASE: DEEP HIERARCHY  #
#----------------------------#

/*-- Tests long chain of reports.

pr()

oOrg = new stzOrgChart("Deep_Hierarchy")
oOrg {

    AddPositionXT("top", "Top")

    cPrev = "top"
    for i = 1 to 15
        cId = "level" + i
        AddPositionXT(cId, "Level " + i)
        ReportsTo(cId, cPrev)
        cPrev = cId
    next

    ? Dot()
    View()

}
#-->
`
digraph "Deep_Hierarchy" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=1, ranksep=1, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#808080", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    top [label="Top", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level1 [label="Level 1", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level2 [label="Level 2", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level3 [label="Level 3", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level4 [label="Level 4", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level5 [label="Level 5", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level6 [label="Level 6", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level7 [label="Level 7", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level8 [label="Level 8", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level9 [label="Level 9", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level10 [label="Level 10", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level11 [label="Level 11", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level12 [label="Level 12", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level13 [label="Level 13", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level14 [label="Level 14", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    level15 [label="Level 15", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]

    top -> level1
    level1 -> level2
    level2 -> level3
    level3 -> level4
    level4 -> level5
    level5 -> level6
    level6 -> level7
    level7 -> level8
    level8 -> level9
    level9 -> level10
    level10 -> level11
    level11 -> level12
    level12 -> level13
    level13 -> level14
    level14 -> level15

}
`

pf()
# Executed in 2.15 second(s) in Ring 1.24

#-----------------------------#
# EDGE CASE: EMPTY DEPARTMENT #
#-----------------------------#

/*-- Tests department with no positions.

pr()

oOrg = new stzOrgChart("Empty_Department")
oOrg {

    AddDepartmentXTT("dept1", "Department 1", [])

    ? @@NL( Department("dept1") )
	#-->
	'
	[
		[ "id", "dept1" ],
		[ "name", "Department 1" ],
		[ "positions", [  ] ],
		[ "head", "" ]
	]
'

}
#-->
`
[
	[ "id", "dept1" ],
	[ "name", "Department 1" ],
	[ "positions", [  ] ],
	[ "head", "" ]
]
`
pf()
# Executed in 0.03 second(s) in Ring 1.24

#------------------------------#
# EDGE CASE: UNASSIGNED PEOPLE #
#------------------------------#

/*-- Tests people not assigned to positions.

pr()

oOrg = new stzOrgChart("Unassigned_People")
oOrg {

    AddPersonXT("p1", "Person 1")
    AddPersonXT("p2", "Person 2")

    ? @@NL( People() ) + NL 
	#-->
	'
	[
		[
			[ "id", "p1" ],
			[ "name", "Person 1" ],
			[ "position", "" ],
			[ "data", [  ] ]
		],
		[
			[ "id", "p2" ],
			[ "name", "Person 2" ],
			[ "position", "" ],
			[ "data", [  ] ]
		]
	]
	'
	
    ? VacancyRate()  #--> 0, no positions

}
#-->
`
[
	[
		[ "id", "p1" ],
		[ "name", "Person 1" ],
		[ "position", "" ],
		[ "data", [  ] ]
	],
	[
		[ "id", "p2" ],
		[ "name", "Person 2" ],
		[ "position", "" ],
		[ "data", [  ] ]
	]
]
`

pf()
# Executed in 0.03 second(s) in Ring 1.24

#--------------------------------#
# EDGE CASE: INVALID SIMULATION  #
#--------------------------------#

/*-- Tests simulation with unknown change type.

pr()

oOrg = new stzOrgChart("Invalid_Simulation")
oOrg {

    aChanges = [ [:type = "unknown", :param = "x"] ]
    ? @@NL( SimulateReorganization(aChanges) ) # Depricated! see stzGraphSimulation
	#-->
	'
	[
		[
			"before",
			[
				[ "spanofcontrol", 0 ],
				[ "vacancyrate", 0 ]
			]
		],
		[
			"after",
			[
				[ "spanofcontrol", 0 ],
				[ "vacancyrate", 0 ]
			]
		],
		[
			"changes",
			[
				[
					[ "type", "unknown" ],
					[ "param", "x" ]
				]
			]
		]
	]
	'

}

pf()

#---------------------------#
# EDGE CASE: EMPTY SNAPSHOT #
#---------------------------#

/*-- Tests snapshot of empty chart #ERR

pr()

oOrg = new stzOrgChart("Empty_Snapshot")
oOrg {

    ? @@NL( CreateSnapshot("empty_snap") ) #TODO// Moved to stzGraphSimulation!
	#-->
	'
	[
		[ "id", "empty_snap" ],
		[ "date", "25/11/2025" ], #TODO// Date needs ormalisation?
		[ "positions", [  ] ],
		[ "people", [  ] ],
		[ "departments", [  ] ]
	]
	'

}

pf()

#-------------------------------------#
# PARENT FEATURES: STZGRAPH TRAVERSAL #
#-------------------------------------#

/*-- Tests graph traversal methods from stzGraph.

pr()

oOrg = new stzOrgChart("Graph_Traversal")
oOrg {

    AddPositionXT("a", "A")
    AddPositionXT("b", "B")
    AddPositionXT("c", "C")
    AddPositionXT("d", "D")

    ReportsTo("b", "a")
    ReportsTo("c", "b")
    ReportsTo("d", "a")

    # Neighbors (outgoing)
    ? @@( Neighbors("a") ) # ["b", "d"]

    # Incoming
    ? @@( Incoming("b") ) # ["a"]

    # Path exists
    ? PathExists("a", "c")  # TRUE

    # All paths
    ? @@( FindAllPaths("a", "c") )  # [["a", "b", "c"]]

    # Shortest path
    ? @@( ShortestPath("a", "c") )  # ["a", "b", "c"]

    # Reachable
    ? @@( ReachableFrom("a") )  # ["a", "b", "d", "c"]

}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#--------------------------------------#
#  PARENT FEATURES: STZGRAPH ANALYSIS  #
#--------------------------------------#

/*-- Tests graph analysis methods from stzGraph.

pr()

oOrg = new stzOrgChart("Graph_Analysis")
oOrg {

    AddPositionXT("a", "A")
    AddPositionXT("b", "B")
    AddPositionXT("c", "C")
    AddPositionXT("d", "D")
    AddPositionXT("e", "E")

    ReportsTo("b", "a")
    ReportsTo("c", "b")
    ReportsTo("d", "c")
    ReportsTo("e", "a")  # Parallel branch

    # Cyclic check (no cycle)
    ? CyclicDependencies()  # FALSE

    # Add cycle
    ReportsTo("a", "d")  # Creates cycle a->b->c->d->a
    ? CyclicDependencies()  # TRUE

    # Remove cycle for further tests
    Disconnect("a", "d")
    ? CyclicDependencies()  #--> FALSE #ERR returned TRUE!

    # Connected components
    ? @@( ConnectedComponents() )  # [["a", "b", "c", "d", "e"]] if connected

    # Articulation points (removal increases components)
    ? @@( ArticulationPoints() ) #--> [ "a", "d" ] #TODO Correct?

    # Betweenness centrality
    ? BetweennessCentrality("b")  #--> 0.25 #TODO Correct?

    # Closeness centrality
    ? ClosenessCentrality("a")  #--> 0.57 #TODO Correct?

    # Diameter (longest shortest path)
    ? Diameter()  #--> 4 #TODO Correct?

    # Average path length
    ? AveragePathLength() #--> 2

    # Clustering coefficient
    ? ClusteringCoefficient("a")  #--> 0 Low since branches don't connect

}

pf()
# Executed in 0.05 second(s) in Ring 1.24

#---------------------------------------------#
#  PARENT FEATURES: STZDIAGRAM VISUALIZATION  #
#---------------------------------------------#

/*-- Tests diagram-specific features like shapes, clusters, validation.

#ERR Infinite call!
`
 Stack Overflow 
In method validatext() in file D:\GitHub\stzlib\libraries\stzlib\base\graph/stzdiagram.ring

Called from line 392 In method _validatesingle() in file D:\GitHub\stzlib\libraries\stzlib\base\graph/stzorgchart.ring

Called from line 1490 In method validatext() in file D:\GitHub\stzlib\libraries\stzlib\base\graph/stzdiagram.ring

Called from line 392 In method _validatesingle()
`

pr()

# It's wonderful: that means we can include processes inside orgcharts!!!
# Propose an interesting visual makeing that

oOrg = new stzOrgChart("Diagram_Features")
oOrg {

    SetLayout("leftright")

    # Use different shapes from stzDiagram
    AddCircleXTT(:start, "ON", [:color = "green"])

    AddBoxXTT(:process, "Process", [ :color = "blue" ])
    AddDiamondXT(:decision, "Decision")
    AddDoubleCircleXT(:end, "End")

    Connect(:start, :process)
    Connect(:process, :decision)
    ConnectXT(:decision, :end, "Yes")

    # Add cluster
    AddClusterXT(:group1, "Group 1", [ :process, :decision])

    # Validate diagram (from stzDiagram)
    ? ValidateXT(:DAG)  #--> TRUE

    # Set visual rule
    oRule = new stzVisualRule(:HighlightStart)
    oRule.When("type", :Equals = "start")
    oRule.ApplyColor("green")
    SetVisualRule(oRule)

    ApplyVisualRules()

    # View
    View()

}

pf()

#---------------------------------#
# PARENT FEATURES: STZGRAPH RULES #
#---------------------------------#


/*--

pr()

? Q([ "isgreaterthan", 15 ]).IsIsGreaterThanNamedParam()
#--> TRUE

pf()

/*--- Tests rule system from stzGraph #TODO Chekc mismatch after refactoring rules from stzGraph to stzGraphRules
*
oOrg = new stzOrgChart("Graph_Rules")
oOrg {

    AddPositionXTT("a", "A" , [ :value = 10 ])
    AddPositionXTT("b", "B" , [ :value = 20 ])
    AddPositionXTT("c", "C" , [ :value = 5 ])

    Connect("a", "b")
    Connect("b", "c")

    # Add visual rule
    oRule = new stzGraphRule("high_value")
    oRule.SetRuleType("visual")
    oRule.When("value", :IsGreaterThan, 15)
    oRule.Apply("color", "red") # Chaanged after refactoring! see commented method in stzGraph
    SetRule(oRule)

    # Add validation rule
    oValRule = new stzGraphRule("low_value_check")
    oValRule.SetRuleType("validation")
    oValRule.When("value", :IsLessThan, 10)
    oValRule.AddViolation("Value too low")
    SetRule(oValRule)

    # Apply
    ApplyRules()

    # Check affected
    ? @@( NodesAffectedByRules() )  + NL
	#--> [ "a", "b", "c" ]

    # Rules applied info
    ? @@NL( RulesApplied() )
	#-->
	'
	[
		[ "haseffects", 1 ],
		[
			"summary",
			"2 rule(s) defined, 5 element(s) affected"
		],
		[ "rules", [  ] ]
	]
'
}

pf()

#------------------------------------------#
# EDGE CASE: CYCLE DETECTION FROM STZGRAPH #
#------------------------------------------#

/*-- Tests cycle detection.

pr()

    oOrg = new stzOrgChart("Cycle_Detection")
    oOrg {
        AddPositionXT("a", "A")
        AddPositionXT("b", "B")
        AddPositionXT("c", "C")
        
        ReportsTo("b", "a")
        ReportsTo("c", "b")
        ReportsTo("a", "c")  # Creates cycle
        
        ? CyclicDependencies()  #--> TRUE
        
        # Fix: Use proper edge removal
        RemoveThisEdge("a", "c")  # Not Disconnect()
        ? CyclicDependencies()  #--> FALSE! #ERR returned TRUE!
    }

pf()

#----------------------#
# EXPORT/IMPORT SAMPLE #
#----------------------#

/*-- Tests exporting to .stzorg and importing back.

pr()

oOrg = new stzOrgChart("Export_Import_Test")
oOrg {
        AddExecutivePositionXT("ceo", "CEO")
        AddManagementPositionXT("vp_sales", "VP Sales")
        ReportsTo("vp_sales", "ceo")
   	view()     
        # Export
 //       WriteToStzOrgFile("test.stzorg")
}
    
# Import
oImported = new stzOrgChart("Imported")
oImported {
        ImportFromStzOrgFile("test.stzorg")
        View() #ERR Empty node!
}

pf()

#-------------------#
#  VISUAL ANALYSIS  #
#-------------------#
/*--

pr()

oOrg = new stzOrgChart("MyOrg Organizational Chart")
oOrg {

    SetTitleVisibility(TRUE)
    SetEdgeLineType("curved")
    AddExecutivePositionXT("ceo", "CEO")

    # Add positions with levels
    AddManagementPositionXT("hr_mgr", "HR Manager")
    ReportsTo("hr_mgr", "ceo")

    for i=1 to 3
        AddStaffPositionXT("staff_hr"+i, "Staff HR"+i)
        ReportsTo("staff_hr"+i, "hr_mgr")
    next

    AddManagementPositionXT("it_mgr", "IT Manager")
    ReportsTo("it_mgr", "ceo")

    for i=1 to 2
        AddStaffPositionXT("staff_it"+i, "Staff IT"+i)
        ReportsTo("staff_it"+i, "it_mgr")
    next
    AddStaffPositionXTT("staff_it3", "Staff IT3", [ :critical = TRUE ])
     ReportsTo("staff_it3", "it_mgr")

   # Leave some vacant
    AddPositionXT("vacant1", "Vacant Position 1")
    ReportsTo("vacant1", "ceo")

    AddPositionXTT("vacant2", "Vacant Position 2", [ :critical = TRUE, :tags = [ "urgent"] ])
    ReportsTo("vacant2", "ceo")

    # Add people to some
    AddPersonXT("p_ali", "Ali Daouda")
    AssignPerson("p_ali", "ceo")

    #--

    AddPersonXT("p_mamane", "Maman Touré")
    AssignPerson("p_mamane", "hr_mgr")

    AddPersonXT("p_aicha", "Aicha Mouddour")
    AssignPerson("p_aicha", "staff_hr1")

    AddPersonXT("p_hassane", "Mohamed Hassane")
    AssignPerson("p_hassane", "staff_hr3")

    #--

    AddPersonXT("p_alexis", "Alexis Mbayé")
    AssignPerson("p_alexis", "it_mgr")

    AddPersonXT("p_daouda", "Daouda Omarou")
    AssignPerson("p_daouda", "staff_it1")

    AddPersonXT("p_haroune", "Haroune Sani")
    AssignPerson("p_haroune", "staff_it2")


    ? ToMermaid()
}
#-->
`
graph TD
    ceo["CEO"]
    hr_mgr["HR Manager"]
    staff_hr1["Staff HR1"]
    staff_hr2["Staff HR2"]
    staff_hr3["Staff HR3"]
    it_mgr["IT Manager"]
    staff_it1["Staff IT1"]
    staff_it2["Staff IT2"]
    staff_it3["Staff IT3"]
    vacant1["Vacant Position 1"]
    vacant2["Vacant Position 2"]

    ceo --> hr_mgr
    hr_mgr --> staff_hr1
    hr_mgr --> staff_hr2
    hr_mgr --> staff_hr3
    ceo --> it_mgr
    it_mgr --> staff_it1
    it_mgr --> staff_it2
    it_mgr --> staff_it3
    ceo --> vacant1
    ceo --> vacant2
`

#NOTE Paste it in https://mermaid.live/

pf()

/*--- TESTING VARIOUS VISUAL ANLYTICS #TODO Use it to illustrate documentation

pr()

oOrg = new stzOrgChart("MyOrg")
oOrg {
    # Setup positions, people, etc...
    
    SetEdgeLineType("curved")
    AddExecutivePositionXT("ceo", "CEO")

    # Add positions with levels
    AddManagementPositionXT("hr_mgr", "HR Manager")
    ReportsTo("hr_mgr", "ceo")

    for i=1 to 3
        AddStaffPositionXT("staff_hr"+i, "Staff HR"+i)
        ReportsTo("staff_hr"+i, "hr_mgr")
    next

    AddManagementPositionXT("it_mgr", "IT Manager")
    ReportsTo("it_mgr", "ceo")

    for i=1 to 2
        AddStaffPositionXT("staff_it"+i, "Staff IT"+i)
        ReportsTo("staff_it"+i, "it_mgr")
    next
    AddStaffPositionXTT("staff_it3", "Staff IT3", [ :critical = TRUE ])
     ReportsTo("staff_it3", "it_mgr")

   # Leave some vacant
    AddPositionXT("vacant1", "Vacant Position 1")
    ReportsTo("vacant1", "ceo")

    AddPositionXTT("vacant2", "Vacant Position 2", [ :critical = TRUE, :tags = [ "urgent"] ])
    ReportsTo("vacant2", "ceo")

    # Add people to some
    AddPersonXT("p_ali", "Ali Daouda")
    AssignPerson("p_ali", "ceo")

    #--

    AddPersonXT("p_mamane", "Maman Touré")
    AssignPerson("p_mamane", "hr_mgr")

    AddPersonXT("p_aicha", "Aicha Mouddour")
    AssignPerson("p_aicha", "staff_hr1")

    AddPersonXT("p_hassane", "Mohamed Hassane")
    AssignPerson("p_hassane", "staff_hr3")

    #--

    AddPersonXT("p_alexis", "Alexis Mbayé")
    AssignPerson("p_alexis", "it_mgr")

    AddPersonXT("p_daouda", "Daouda Omarou")
    AssignPerson("p_daouda", "staff_it1")

    AddPersonXT("p_haroune", "Haroune Sani")
    AssignPerson("p_haroune", "staff_it2")

    #--

    AddDepartmentXTT("it", "Department IT", [ "it_mgr", "staff_it1", "staff_it2", "staff_it3" ])
    AddDepartmentXTT("hr", "Department HR", [ "hr_mgr", "staff_hr1", "staff_hr2", "staff_hr3" ])

    View()

    # View different analytics:

   ViewDepartment("it")   # Show IT department only
   ViewPath("ceo", "staff_hr2") # Show reporting path

   #-- POPULATED

   ViewPopulated()        # Show filled positions
   ViewVacant()           # Show empty positions


   #--- PERFRMANCE

   SetNodeProperty("ceo", "performance", 90)
   SetNodeProperty("hr_mgr", "performance", 40)
   SetNodeProperty("it_mgr", "performance", 40)

   ViewPerformant()       # Show high performers (≥75)
   ViewNonPerformant()    # Show low performers (<50)


    #--- RISK

    # Create positions without successors

    ? @@NL( SuccessionRisk() )
    ViewAtRisk()           # Show succession risks

    # Custom views
    ViewNodesWithProperty("critical", TRUE)
    ViewNodesWithTag("urgent")

}
#-->
`
[
	"ceo",
	"hr_mgr",
	"staff_hr1",
	"staff_hr3",
	"it_mgr",
	"staff_it1",
	"staff_it2"
]
`

pf()

#------------------------------------------#
# EXAMPLE : Bank Organizational Structure  #
#------------------------------------------#

/*---

pr()

oBank = new stzOrgChart("Regional Bank Governance")
oBank {
	SetSplines("ortho")
	SetTitleVisibility(TRUE)
	
	# Board level
	AddExecutivePositionXT("board", "Board of Directors")
	
	# Executive positions
	AddExecutivePositionXT("ceo", "Chief Executive Officer")
	AddExecutivePositionXT("cfo", "Chief Financial Officer")
	AddManagementPositionXT("cro", "Chief Risk Officer")
	AddManagementPositionXT("cao", "Chief Audit Officer")
	
	# Department heads
	AddManagementPositionXT("treasury_head", "Head of Treasury")
	AddManagementPositionXT("ops_head", "Head of Operations")
	AddManagementPositionXT("it_head", "Head of IT")
	
	# Staff positions
	AddStaffPositionXT("treasury_analyst", "Treasury Analyst")
	AddStaffPositionXT("ops_analyst", "Operations Analyst")
	
	# Define reporting structure
	ReportsTo("ceo", "board")
	ReportsTo("cfo", "ceo")
	ReportsTo("cro", "ceo")
	ReportsTo("cao", "board")  # Audit independence
	
	ReportsTo("treasury_head", "cfo")
	ReportsTo("ops_head", "ceo")
	ReportsTo("it_head", "ceo")
	
	ReportsTo("treasury_analyst", "treasury_head")
	ReportsTo("ops_analyst", "ops_head")
	
	# Assign departments
	SetPositionDepartment("treasury_head", "treasury")
	SetPositionDepartment("treasury_analyst", "treasury")
	SetPositionDepartment("ops_head", "operations")
	SetPositionDepartment("ops_analyst", "operations")
	SetPositionDepartment("cao", "audit")
	SetPositionDepartment("cro", "risk")
	SetPositionDepartment("it_head", "it")
	
	# Add people
	AddPersonXT("p1", "Sarah Johnson")
	AddPersonXT("p2", "Michael Chen")
	AddPersonXT("p3", "Emma Williams")
	AddPersonXT("p4", "David Kumar")
	AddPersonXT("p5", "Lisa Anderson")
	
	# Assign people to positions
	AssignPerson("p1", "ceo")
	AssignPerson("p2", "cfo")
	AssignPerson("p3", "cao")
	AssignPerson("p4", "treasury_head")
	AssignPerson("p5", "ops_head")
	
	# Analyze organization
	? "=== BANK ORGANIZATION ANALYSIS ===" + NL
	
	? @@NL( Explain() ) + NL

	
	# Validate BCEAO governance
	? NL + "=== BCEAO COMPLIANCE CHECK ===" + NL
	? @@NL( ValidateXT(:BCEAO) ) + NL
	
	# Check segregation of duties
	? NL + "=== SEGREGATION OF DUTIES CHECK ===" + NL
	? @@NL( ValidateXT(:SegregationOfDuties) ) + NL

	# Generate vacancy report
	? NL + "=== VACANCY REPORT ===" + NL
	? @@NL( ValidateXT(:Vacancy) )
	
	# View the chart
	View()
}
#-->
`
=== BANK ORGANIZATION ANALYSIS ===

[
	[ "type", "Organization Chart" ],
	[
		"structure",
		"Organization 'Regional Bank Governance' has 10 positions, 5 people, and 0 departments."
	],
	[
		"hierarchy",
		[
			"executive: 3 positions",
			"management: 5 positions",
			"staff: 2 positions",
			"Average span of control: 1.80"
		]
	],
	[
		"staffing",
		[
			"Vacancy rate: 50%",
			"Vacant positions: board, cro, it_head, treasury_analyst, ops_analyst"
		]
	],
	[
		"compliance",
		[
			"Found 1 compliance issues",
			"BCEAO: BCEAO-002: Audit reports to non-board position"
		]
	],
	[
		"risks",
		[
			"Succession risk: 5 positions without successor",
			"At-risk positions: ceo, cfo, cao, treasury_head, ops_head"
		]
	],
	[
		"efficiency",
		[
			"Span of control may be underutilized (< 3 reports average)",
			"HIGH vacancy rate - may impact operations"
		]
	]
]


=== BCEAO COMPLIANCE CHECK ===

[
	[ "status", "fail" ],
	[ "domain", "BCEAO_governance" ],
	[ "issuecount", 1 ],
	[
		"issues",
		[
			"BCEAO-002: Audit reports to non-board position"
		]
	]
]


=== SEGREGATION OF DUTIES CHECK ===

[
	[ "status", "pass" ],
	[ "domain", "segregation_of_duties" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ]
]


=== VACANCY REPORT ===

[
	[ "status", "fail" ],
	[ "domain", "vacancy" ],
	[ "issuecount", 5 ],
	[
		"issues",
		[ "Vacant positions: 5" ]
	],
	[
		"affectednodes",
		[
			"board",
			"cro",
			"it_head",
			"treasury_analyst",
			"ops_analyst"
		]
	]
]
`

pf()
# Executed in 2.12 second(s) in Ring 1.24

#---------------------------------------------------------------
# Example 4: Enhanced Validation - Defaults & XT Forms
# Demonstrates: Banking vs BCEAO validator distinction
#---------------------------------------------------------------

/*---

pr()

oBank = new stzOrgChart("International_Bank")
oBank {
	SetTheme("pro")
	SetTitleVisibility(TRUE)
	
	# Build structure
	AddExecutivePositionXT("board", "Board of Directors")
	AddExecutivePositionXT("ceo", "CEO")
	AddManagementPositionXT("cfo", "CFO")
	AddManagementPositionXT("cro", "Chief Risk Officer")
	AddManagementPositionXT("cto", "CTO")
	AddManagementPositionXT("treasury_head", "Treasury Head")
	AddManagementPositionXT("ops_head", "Operations Head")
	
	ReportsTo("ceo", "board")
	ReportsTo("cfo", "ceo")
	ReportsTo("cro", "ceo")
	ReportsTo("cto", "ceo")
	ReportsTo("treasury_head", "cfo")
	ReportsTo("ops_head", "ceo")  # Proper separation
	
	SetPositionDepartment("cro", "risk")
	SetPositionDepartment("treasury_head", "treasury")
	SetPositionDepartment("ops_head", "operations")
	SetPositionDepartment("cto", "it")
	
	# Assign people
	AddPersonXT("p1", "Alice Chen")
	AddPersonXT("p2", "Bob Kumar")
	AddPersonXT("p3", "Carol Martinez")
	AssignPerson("p1", "ceo")
	AssignPerson("p2", "cfo")
	AssignPerson("p3", "treasury_head")
	
	WriteStzOrg("softabank.stzorg")

	#-------------------------------------------------------
	# PART 1: Default Validators (No Parameters)
	#-------------------------------------------------------
	
	? BoxRound("DEFAULT VALIDATORS") + NL
	
	? "Default validators for OrgChart:"
	? @@NL( DefaultValidators() ) + NL
	
	? "Running IsValid() with defaults..."
	? "Result: " + IsValid() + NL  # Runs all 5 default validators
	
	? "Running Validate() with defaults (detailed)..."
	? @@NL( Validate() )  # Full report on all defaults
	
	#-------------------------------------------------------
	# PART 2: Single Validator XT Form
	#-------------------------------------------------------
	
	? NL + BoxRound("SINGLE VALIDATOR (XT FORM)") + NL
	
	? "IsValidXT(:SOC) - Span of Control:"
	? IsValidXT(:SOC) + NL
	
	? "ValidateXT(:Succession) - Detailed:"
	? @@NL( ValidateXT(:Succession) )
	
	#-------------------------------------------------------
	# PART 3: Multiple Validators XT Form
	#-------------------------------------------------------
	
	? NL + BoxRound("MULTIPLE VALIDATORS (XT FORM)") + NL
	
	? "IsValidXT([ :Banking, :BCEAO ]) - Boolean check:"
	? IsValidXT([ :Banking, :BCEAO ]) + NL
	
	? "ValidateXT([ :Banking, :BCEAO ]) - Detailed comparison:"
	aComparison = ValidateXT([ :Banking, :BCEAO ])
	? @@NL( aComparison )
	
	#-------------------------------------------------------
	# PART 4: Banking vs BCEAO Distinction
	#-------------------------------------------------------
	
	? NL + BoxRound("BANKING vs BCEAO - THE DISTINCTION") + NL
	
	? "═══ BANKING VALIDATOR ═══"
	? "Scope: Universal operational controls"
	? "Focus: Fraud prevention, dual control, IT security" + NL
	? @@NL( ValidateXT(:Banking) )
	
	
	? NL + "═══ BCEAO VALIDATOR ═══"
	? "Scope: West African banking zone regulations"
	? "Focus: Governance structure, board composition, audit independence" + NL
	? @@NL( ValidateXT(:BCEAO) )
	
	#-------------------------------------------------------
	# PART 5: Custom Validators
	#-------------------------------------------------------
	
	? NL + BoxRound("CUSTOM DEFAULT VALIDATORS") + NL
	
	? "Original defaults:"
	? @@NL( DefaultValidators() )
	
	? NL + "Setting custom defaults for BCEAO region compliance..."
	SetValidators([ :BCEAO, :Banking, :SOD, :SOC ])
	
	? "New validators at the object level:"
	? @@NL( Validators() )
	
	? NL + "Running IsValid() with new defaults:"
	? IsValid() + NL
	
	? "Full report with new defaults:"
	? @@NL( Validate() )
	
	#-------------------------------------------------------
	# PART 6: Practical Use - Regional Audit
	#-------------------------------------------------------
	
	? NL + BoxRound("PRACTICAL SCENARIO: REGIONAL AUDIT") + NL
	
	? "Scenario: Bank in BCEAO region needs both:"
	? "  1. Universal banking controls (fraud, dual control)"
	? "  2. BCEAO-specific governance compliance" + NL
	
	? "Quick compliance check:"
	if IsValidXT([ :Banking, :BCEAO ])
		? "✓ Compliant with both Banking and BCEAO standards"
	else
		? "✗ Non-compliant - running detailed analysis..."
		? @@NL( ValidateXT([ :Banking, :BCEAO ]) )
		
		? NL + "Audit Summary:"
		? "  Validators run: " + aAudit[:validatorsRun]
		? "  Failed: " + aAudit[:validatorsFailed]
		? "  Total issues: " + aAudit[:totalIssues]
		? "  Affected positions: " + len(aAudit[:affectedNodes])
	
		
		# Visual inspection
		? NL + "Generating visual report of non-compliant nodes..."
		ViewNonCompliant(:BCEAO)
	ok
}
#-->
`
╭────────────────────╮
│ DEFAULT VALIDATORS │
╰────────────────────╯

Default validators for OrgChart:
[
	"bceao",
	"sod",
	"soc",
	"vacancy",
	"succession"
]

Running IsValid() with defaults...
Result: 0

Running Validate() with defaults (detailed)...
[
	[ "status", "fail" ],
	[ "validatorsrun", 5 ],
	[ "validatorsfailed", 2 ],
	[ "totalissues", 10 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "BCEAO_governance" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "segregation_of_duties" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "fail" ],
				[ "domain", "vacancy" ],
				[ "issuecount", 4 ],
				[
					"issues",
					[ "Vacant positions: 4" ]
				],
				[
					"affectednodes",
					[
						"board",
						"cro",
						"cto",
						"ops_head"
					]
				]
			],
			[
				[ "status", "fail" ],
				[ "domain", "succession" ],
				[ "issuecount", 6 ],
				[
					"issues",
					[
						"No successor: ",
						"ceo",
						"No successor: ",
						"cfo",
						"No successor: ",
						"treasury_head"
					]
				],
				[
					"affectednodes",
					[ "ceo", "cfo", "treasury_head" ]
				]
			]
		]
	],
	[
		"affectednodes",
		[
			"board",
			"cro",
			"cto",
			"ops_head",
			"ceo",
			"cfo",
			"treasury_head"
		]
	]
]

╭────────────────────────────╮
│ SINGLE VALIDATOR (XT FORM) │
╰────────────────────────────╯

IsValidXT(:SOC) - Span of Control:
1

ValidateXT(:Succession) - Detailed:
[
	[ "status", "fail" ],
	[ "domain", "succession" ],
	[ "issuecount", 6 ],
	[
		"issues",
		[
			"No successor: ",
			"ceo",
			"No successor: ",
			"cfo",
			"No successor: ",
			"treasury_head"
		]
	],
	[
		"affectednodes",
		[ "ceo", "cfo", "treasury_head" ]
	]
]

╭───────────────────────────────╮
│ MULTIPLE VALIDATORS (XT FORM) │
╰───────────────────────────────╯

IsValidXT([ :Banking, :BCEAO ]) - Boolean check:
1

ValidateXT([ :Banking, :BCEAO ]) - Detailed comparison:
[
	[ "status", "pass" ],
	[ "validatorsrun", 2 ],
	[ "validatorsfailed", 0 ],
	[ "totalissues", 0 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "banking" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ],
				[ "affectednodes", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "BCEAO_governance" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			]
		]
	],
	[ "affectednodes", [  ] ]
]

╭────────────────────────────────────╮
│ BANKING vs BCEAO - THE DISTINCTION │
╰────────────────────────────────────╯

═══ BANKING VALIDATOR ═══
Scope: Universal operational controls
Focus: Fraud prevention, dual control, IT security

[
	[ "status", "pass" ],
	[ "domain", "banking" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ],
	[ "affectednodes", [  ] ]
]

═══ BCEAO VALIDATOR ═══
Scope: West African banking zone regulations
Focus: Governance structure, board composition, audit independence

[
	[ "status", "pass" ],
	[ "domain", "BCEAO_governance" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ]
]

╭───────────────────────────╮
│ CUSTOM DEFAULT VALIDATORS │
╰───────────────────────────╯

Original defaults:
[
	"bceao",
	"sod",
	"soc",
	"vacancy",
	"succession"
]

Setting custom defaults for BCEAO region compliance...
New validators at the object level:
[
	"bceao",
	"banking",
	"sod",
	"soc"
]

Running IsValid() with new defaults:
1

Full report with new defaults:
[
	[ "status", "pass" ],
	[ "validatorsrun", 4 ],
	[ "validatorsfailed", 0 ],
	[ "totalissues", 0 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "BCEAO_governance" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "banking" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ],
				[ "affectednodes", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "segregation_of_duties" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			]
		]
	],
	[ "affectednodes", [  ] ]
]

╭────────────────────────────────────╮
│ PRACTICAL SCENARIO: REGIONAL AUDIT │
╰────────────────────────────────────╯

Scenario: Bank in BCEAO region needs both:
  1. Universal banking controls (fraud, dual control)
  2. BCEAO-specific governance compliance

Quick compliance check:
✓ Compliant with both Banking and BCEAO standards
`

pf()
# Executed in 0.10 second(s) in Ring 1.24

#===========

pr()

# Load from file
oBank = new stzOrgChart("SOFTABANK")
oBank {
    LoadStzOrg("softabank.stzorg") #TODO //check why the last node is not imported
    LoadRuleBase("bceao_complete.stzrulz")
    
    # Or combine multiple sources
    LoadRuleBase("banking")   # Pre-built class
    LoadRuleBase(new stzSOXRuleBase())  # Direct object
    LoadRuleBase("custom_rules.stzrulz")  # File
    
    # Same API works
    ? IsValid()
    ? @@NL( Validate() )
    ? @@NL( ValidateXT(:bceao) )

    View() # Check why all nodes are white
}
#-->
`
0
[
	[ "status", "fail" ],
	[ "validatorsrun", 5 ],
	[ "validatorsfailed", 2 ],
	[ "totalissues", 10 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "BCEAO_governance" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "segregation_of_duties" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "fail" ],
				[ "domain", "vacancy" ],
				[ "issuecount", 4 ],
				[
					"issues",
					[ "Vacant positions: 4" ]
				],
				[
					"affectednodes",
					[
						"board",
						"cro",
						"cto",
						"security_manager"
					]
				]
			],
			[
				[ "status", "fail" ],
				[ "domain", "succession" ],
				[ "issuecount", 6 ],
				[
					"issues",
					[
						"No successor: ",
						"ceo",
						"No successor: ",
						"cfo",
						"No successor: ",
						"treasury_head"
					]
				],
				[
					"affectednodes",
					[ "ceo", "cfo", "treasury_head" ]
				]
			]
		]
	],
	[
		"affectednodes",
		[
			"board",
			"cro",
			"cto",
			"security_manager",
			"ceo",
			"cfo",
			"treasury_head"
		]
	]
]
[
	[ "status", "pass" ],
	[ "domain", "BCEAO_governance" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ]
]
`

pf()
# Executed in 2.27 second(s) in Ring 1.24

/*====

pr()

# Example 1: Programmatic simulation
oBank = new stzOrgChart("Regional_Bank")
oBank {
    # Build structure...
    LoadStzOrg("softabank.stzorg")

    # Create simulation
    oSim = CreateSimulation("treasury_restructure")
    oSim {
        SetDescription("Move treasury under CFO")
        MovePosition("treasury_head", "ceo", "cfo")
        AddPosition("risk_officer", "Risk Officer", "staff", "treasury_head")
        TrackSpanOfControl("cfo")
        TrackCompliance([:bceao, :banking])
    }
    
    # Run and view results
    aResults = oSim.Run()
    ? @@NL( aResults )
}
#-->
`
structure" ],
	[ "description", "Move treasury under CFO" ],
	[ "changecount", 2 ],
	[
		"before",
		[
			[
				[ "metric", "span_of_control" ],
				[ "position", "cfo" ],
				[ "value", 1 ]
			],
			[
				[ "metric", "compliance" ],
				[
					"value",
					[
						[ "status", "pass" ],
						[ "validatorsrun", 2 ],
						[ "validatorsfailed", 0 ],
						[ "totalissues", 0 ],
						[
							"results",
							[
								[
									[ "status", "pass" ],
									[ "domain", "BCEAO_governance" ],
									[ "issuecount", 0 ],
									[ "issues", [  ] ]
								],
								[
									[ "status", "pass" ],
									[ "domain", "banking" ],
									[ "issuecount", 0 ],
									[ "issues", [  ] ],
									[ "affectednodes", [  ] ]
								]
							]
						],
						[ "affectednodes", [  ] ]
					]
				]
			]
		]
	],
	[
		"after",
		[
			[
				[ "metric", "span_of_control" ],
				[ "position", "cfo" ],
				[ "value", 1 ]
			],
			[
				[ "metric", "compliance" ],
				[
					"value",
					[
						[ "status", "pass" ],
						[ "validatorsrun", 2 ],
						[ "validatorsfailed", 0 ],
						[ "totalissues", 0 ],
						[
							"results",
							[
								[
									[ "status", "pass" ],
									[ "domain", "BCEAO_governance" ],
									[ "issuecount", 0 ],
									[ "issues", [  ] ]
								],
								[
									[ "status", "pass" ],
									[ "domain", "banking" ],
									[ "issuecount", 0 ],
									[ "issues", [  ] ],
									[ "affectednodes", [  ] ]
								]
							]
						],
						[ "affectednodes", [  ] ]
					]
				]
			]
		]
	],
	[
		"deltas",
		[
			[
				[ "metric", "span_of_control" ],
				[ "before", 1 ],
				[ "after", 1 ],
				[ "delta", 0 ]
			]
		]
	]
]
`

pf()
# Executed in 0.10 second(s) in Ring 1.24


#==============================================#
#  USAGE OF All GRAPH Files Formats Together   #
#==============================================#

/*--- Example: Complete bank analysis workflow

pr()

oBank = new stzOrgChart("SOFTANKA")
oBank {
    # 1. Load structure
    LoadOrgChart("softabank.stzorg")
    
    # 2. Load visual theme
    LoadStyle("banking_corporate.stzstyl")
    
    # 3. Load compliance rules
    LoadRuleBase("bceao_complete.stzrulz")
 //   LoadRuleBase("bceao_governance.stzrulz")
    
    # 4. Validate
    ? "Compliance Status:"
    ? @@NL( Validate() )
    
    # 5. Run simulation
    ? NL + "Restructuring Simulation:"
    aResult = RunSimulation("restructure.stzsim")
    ? @@NL( aResult )
    
    # 6. Visualize
    View()  # Uses corporate_brand.stzstyl styling
}
#-->
'
Compliance Status:
[
	[ "status", "fail" ],
	[ "validatorsrun", 5 ],
	[ "validatorsfailed", 2 ],
	[ "totalissues", 10 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "BCEAO_governance" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "segregation_of_duties" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "fail" ],
				[ "domain", "vacancy" ],
				[ "issuecount", 4 ],
				[
					"issues",
					[ "Vacant positions: 4" ]
				],
				[
					"affectednodes",
					[
						"board",
						"cro",
						"cto",
						"security_manager"
					]
				]
			],
			[
				[ "status", "fail" ],
				[ "domain", "succession" ],
				[ "issuecount", 6 ],
				[
					"issues",
					[
						"No successor: ",
						"ceo",
						"No successor: ",
						"cfo",
						"No successor: ",
						"treasury_head"
					]
				],
				[
					"affectednodes",
					[ "ceo", "cfo", "treasury_head" ]
				]
			]
		]
	],
	[
		"affectednodes",
		[
			"board",
			"cro",
			"cto",
			"security_manager",
			"ceo",
			"cfo",
			"treasury_head"
		]
	]
]

Restructuring Simulation:
[
	[ "simulationid", "Treasury Restructure 2024" ],
	[
		"description",
		'"Consolidate treasury operations under CFO with enhanced risk oversight"'
	],
	[ "changecount", 0 ],
	[ "before", [  ] ],
	[ "after", [  ] ],
	[ "deltas", [  ] ]
]
'

pf()

/*--- Example: Multi-Source Graph

# Combine pure graph + workflow + rules

oSystem = new stzDiagram("Enterprise_System")
oSystem {
    # Import base network topology
    ImportGraf("supply.stzgraf") # Check errror!
    
    # Overlay workflow semantics
    ImportDiag("test_diagram.stzdiag")
    
    # Apply styling
    //LoadStyle("dark_mode.stzstyl") #TODO create file
    
    # Load rules from multiple domains
    LoadRuleBase("bceao_compliance.stzrulz")
    LoadRuleBase("sox_compliance.stzrulz") #TODO Add files before testing
    LoadRuleBase("gdpr_privacy.stzrulz")
    LoadRuleBase("custom_security.stzrulz")
    
    # Validate everything
? @@NL( ValidateXT(:sox) )
//    ? @@NL( ValidateXT([:sox, :gdpr, :security]) )
    
 //   ViewNonCompliant(:sox)  # Visual inspection

}

pf()

/*--- Example: Style Variants

# Same structure, multiple presentations

oOrg = new stzOrgChart("Bank")
oOrg {
    ImportOrg("bank_structure.stzorg")
    
    # Corporate presentation
    LoadStyle("banking_corporate.stzstyl")
    View() #TODO //See why nodes are white!

    #TODO Add these styles files before tresting
    
 /*   # Executive summary (minimal)
    LoadStyle("minimal.stzstyl")
    View()
    
    # Print version (grayscale)
    LoadStyle("print.stzstyl")
    View()
    
    # Accessibility (high contrast)
    LoadStyle("accessible.stzstyl")
    View()

}

/*--- Example: Scenario Comparison

pr()

# Compare multiple restructuring options

oBank = new stzOrgChart("Strategic_Planning")
oBank {
    ImportOrg("softabank.stzorg")
    LoadRuleBase("bceao_complete.stzrulz")
    
    # Run 3 scenarios : #TODO Create the 3 files before running
    aScenario1 = RunSimulation("option_b.stzsim")
    aScenario2 = RunSimulation("option_b.stzsim")
    aScenario3 = RunSimulation("option_c.stzsim")
    

    # Compare results
    ? "Scenario A compliance: " + aScenario1[:deltas][:compliance][:after][:status]
    ? "Scenario B compliance: " + aScenario2[:deltas][:compliance][:after][:status]
    ? "Scenario C compliance: " + aScenario3[:deltas][:compliance][:after][:status]
    
    # Choose best
    if aScenario1[:deltas][:compliance][:after][:status] = "pass"
        ? "Scenario A recommended - applying changes"
        # Actually apply scenario B changes permanently
    ok
}

pf()

#======================#
#  Format Cheat Sheet  #
#======================#

/*
#TODO Add the *.stzknow ffile format for stzKnowledgeGraph class
┌──────────────┬─────────────────────────────────────┬──────────────────┐
│ Format       │ Purpose                             │ Typical Use      │
├──────────────┼─────────────────────────────────────┼──────────────────┤
│ .stzgraf     │ Pure graph structure                │ Networks, DAGs   │
│ .stzdiag     │ Workflow/process diagrams           │ Business flows   │
│ .stzorg      │ Organizational charts               │ Company structure│
│ .stzrulz     │ Validation/inference rules          │ Compliance       │
│ .stzsim      │ What-if scenarios                   │ Restructuring    │
│ .stzstyl     │ Visual themes                       │ Branding         │
└──────────────┴─────────────────────────────────────┴──────────────────┘

All formats are:
  ✓ Human-readable text
  ✓ Version-controllable
  ✓ Composable
  ✓ Domain-agnostic (except .stzorg)
  ✓ Tool-independent
*/


#============================================#
#  Complete Workflow + OrgChart Example      #
#  Linking process performance to org       #
#============================================#

/*--

pr()

# Step 1: Build Organization
oBank = new stzOrgChart("Regional_Bank")
oBank {
    SetTheme("pro")
    
    # Positions
    AddManagementPositionXT("loan_manager", "Loan Manager")
    AddStaffPositionXT("clerk_pos", "Loan Clerk")
    AddStaffPositionXT("analyst_pos", "Credit Analyst")
    
    ReportsTo("clerk_pos", "loan_manager")
    ReportsTo("analyst_pos", "loan_manager")
    
    # People
    AddPersonXT("p_alice", "Alice Johnson")
    AddPersonXT("p_bob", "Bob Smith")
    AddPersonXT("p_carol", "Carol Davis")
    
    AssignPerson("p_alice", "clerk_pos")
    AssignPerson("p_bob", "analyst_pos")
    AssignPerson("p_carol", "loan_manager")
}

# Step 2: Build Workflow
oLoanFlow = new stzWorkflow("Loan_Approval_Process")
oLoanFlow {
    SetWorkflowType("sequential")
    SetTheme("pro")
    
    # Define steps
    AddStepXT("receive", "Receive Application")
    SetStepDuration("receive", 1)
    
    AddStepXT("verify", "Verify Documents")
    SetStepDuration("verify", 4)
    SetStepSLA("verify", 6)
    
    AddStepXT("credit_check", "Credit Check")
    SetStepDuration("credit_check", 2)
    SetStepSLA("credit_check", 3)
    
    AddStepXT("decide", "Approval Decision")
    SetStepDuration("decide", 1)
    
    AddStepXT("approve", "Approve Loan")
    SetStepDuration("approve", 1)
    
    # Connect flow
    ConnectSteps("receive", "verify")
    ConnectSteps("verify", "credit_check")
    ConnectSteps("credit_check", "decide")
    ConnectSteps("decide", "approve")
    
    # Define actors
    AddActor("clerk_1", "Alice Johnson", "clerk")
    AddActor("analyst_1", "Bob Smith", "analyst")
    AddActor("manager_1", "Carol Davis", "manager")
    
    # Assign steps to actors
    AssignStepTo("receive", "clerk_1")
    AssignStepTo("verify", "clerk_1")
    AssignStepTo("credit_check", "analyst_1")
    AssignStepTo("decide", "manager_1")
    AssignStepTo("approve", "manager_1")
    
    # Link to org chart
    LinkOrgChart(oBank)
    MapRoleToPosition("clerk", "clerk_pos")
    MapRoleToPosition("analyst", "analyst_pos")
    MapRoleToPosition("manager", "loan_manager")
}

#  ANALYSIS 1: Performance Validation
#====================================

? BoxRound("WORKFLOW PERFORMANCE ANALYSIS")

# Check SLA compliance
? "SLA Status:"
aSLA = oLoanFlow.ValidateSLA()
? @@NL( aSLA )

if aSLA[:status] = "fail"
    ? NL + "Violations found:"
    for cIssue in aSLA[:issues]
        ? "  • " + cIssue
    end
    
    # Visual inspection
    oLoanFlow.ViewSLAViolations()
ok

# Identify bottlenecks
? NL + "Bottleneck Analysis:"
aBottlenecks = oLoanFlow.Bottlenecks()
? @@NL( aBottlenecks )

if len(aBottlenecks) > 0
    oLoanFlow.ViewBottlenecks()
ok

# Critical path
? NL + "Critical Path:"
aCritical = oLoanFlow.CriticalPath()
? "  Duration: " + aCritical[:duration] + " hours"
? "  Path: " + @@( aCritical[:path] )

oLoanFlow.ViewCriticalPath()

#  ANALYSIS 2: Org-Workflow Linking 
#================================== 

? NL + BoxRound("ORG CHART ↔ WORKFLOW LINKING")

# Workload by position
aWorkload = oLoanFlow.WorkloadByPosition()
? "Workload Distribution:"
for aLoad in aWorkload
    ? "  " + aLoad[:position] + ":"
    ? "    Steps: " + aLoad[:stepCount]
    ? "    Total hours: " + aLoad[:totalDuration]
end

# Find overloaded positions
? NL + "Overload Detection:"
for aLoad in aWorkload
    if aLoad[:stepCount] > 3
        ? "  ⚠ " + aLoad[:position] + " handles " + aLoad[:stepCount] + " steps"
        
        # Get person in that position
        aPos = oBank.Position(aLoad[:position])
        if aPos[:incumbent] != ""
            aPerson = oBank.PersonData(aPos[:incumbent])
            ? "    Assigned to: " + aPerson[:name]
        ok
    ok
end

#  ANALYSIS 3: Cross-Domain Rules 
#================================

? NL + BoxRound("CROSS-DOMAIN VALIDATION")

# Load workflow rules
oLoanFlow.LoadRuleBase(new stzBPMRuleBase())
oLoanFlow.LoadRuleBase(new stzSLARuleBase())

# Validate
? @@NL( oLoanFlow.Validate() )

#  SIMULATION: Process Optimization
#==================================

? NL + BoxRound("SIMULATION: OPTIMIZE VERIFY STEP")

oSim = new stzWorkflowSimulation("optimize_verify")
oSim {
    SetGraph(oLoanFlow)
    SetDescription("Reduce verify step from 4h to 2h via automation")
    
    # Change
    OptimizeStep("verify", 2)
    
    # Track metrics
    TrackMetric("total_duration", [])
    TrackMetric("critical_path", [])
    TrackMetric("sla_violations", [])
}

? "Simulation Results:"
? @@NL( oSim.Run() )

#  VISUAL COMPARISON
#===================

? NL + BoxRound("VISUAL ANALYSIS")

oLoanFlow.ViewByRole("clerk") 	#TODO// Check why focus coloor is not displayed!
oLoanFlow.ViewByRole("analyst")
oLoanFlow.ViewByRole("manager")

# Org chart with workflow overlay
? NL + "Organization with process workload:"
oBank {
    # Highlight positions involved in critical path
    acCriticalPositions = []
    for cStepId in aCritical[:path]
        cPos = oLoanFlow.GetPositionForStep(cStepId)
        if cPos != "" and ring_find(acCriticalPositions, cPos) = 0
            acCriticalPositions + cPos
        ok
    end
    
    ApplyFocusTo(acCriticalPositions)
    SetSubtitle("Positions on Critical Path")
    View()
}

#  EXPORT FOR DOCUMENTATION
#==========================

? NL + BoxRound("EXPORT & DOCUMENTATION")

# Export workflow
oLoanFlow.WriteToFile("loan_process.stzflow")
? "Workflow exported to loan_process.stzflow"

# Export org chart
oBank.WriteToStzOrgFile("bank_structure.stzorg")
? "Org chart exported to bank_structure.stzorg"

# Generate reports
? NL + "Performance Report:"
? "  Total process time: " + oLoanFlow.TotalDuration() + "h"
? "  Critical path: " + aCritical[:duration] + "h"
? "  SLA violations: " + len(oLoanFlow.SLAViolations())
? "  Bottlenecks: " + len(oLoanFlow.Bottlenecks())
? "  Positions involved: " + len(aWorkload)

#  ADVANCED: State Machine Workflow
#==================================

? NL + BoxRound("STATE MACHINE EXAMPLE")

oStateMachine = new stzWorkflow("Order_Lifecycle")
oStateMachine {
    SetWorkflowType("statemachine")
    
    # States
    AddStateXTT("draft", "Draft", [:isInitial = TRUE])
    AddState("submitted")
    AddState("approved")
    AddState("rejected")
    AddState("processing")
    AddState("shipped")
    AddStateXTT("delivered", "Delivered", [:isFinal = TRUE])
    AddStateXTT("cancelled", "Cancelled", [:isFinal = TRUE])
    
    # Transitions
    AddTransition("draft", "submitted", "submit")
    AddTransitionXT("submitted", "approved", "approve", "amount < 1000")
    AddTransitionXT("submitted", "rejected", "reject", "invalid")
    AddTransition("approved", "processing", "start_processing")
    AddTransition("processing", "shipped", "ship")
    AddTransition("shipped", "delivered", "confirm_delivery")
    AddTransition("draft", "cancelled", "cancel")
    AddTransition("submitted", "cancelled", "cancel")
    
    # Validate
    aValidation = ValidateXT(:Reachability)
    ? "State machine reachability: " + aValidation[:status]
    
    View()
}

pf()

#-->
`
╭───────────────────────────────╮
│ WORKFLOW PERFORMANCE ANALYSIS │
╰───────────────────────────────╯
SLA Status:
[
	[ "status", "pass" ],
	[ "domain", "sla" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ],
	[ "affectednodes", [  ] ]
]

Bottleneck Analysis:
[ ]

Critical Path:
  Duration: 9 hours
  Path: [ "receive", "verify", "credit_check", "decide", "approve" ]

╭──────────────────────────────╮
│ ORG CHART ↔ WORKFLOW LINKING │
╰──────────────────────────────╯
Workload Distribution:
  clerk_pos:
    Steps: 2
    Total hours: 5
  analyst_pos:
    Steps: 1
    Total hours: 2
  loan_manager:
    Steps: 2
    Total hours: 2

Overload Detection:

╭─────────────────────────╮
│ CROSS-DOMAIN VALIDATION │
╰─────────────────────────╯
[
	[ "status", "pass" ],
	[ "validatorsrun", 5 ],
	[ "validatorsfailed", 0 ],
	[ "totalissues", 0 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "deadlock" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "reachability" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ],
				[ "affectednodes", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "completeness" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ],
				[ "affectednodes", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "sla" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ],
				[ "affectednodes", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "bottleneck" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ],
				[ "affectednodes", [  ] ]
			]
		]
	],
	[ "affectednodes", [  ] ]
]

╭──────────────────────────────────╮
│ SIMULATION: OPTIMIZE VERIFY STEP │
╰──────────────────────────────────╯
Simulation Results:
[
	[ "simulationid", "optimize_verify" ],
	[
		"description",
		"Reduce verify step from 4h to 2h via automation"
	],
	[ "changecount", 1 ],
	[ "before", [  ] ],
	[ "after", [  ] ],
	[ "deltas", [  ] ]
]

╭─────────────────╮
│ VISUAL ANALYSIS │
╰─────────────────╯

Organization with process workload:

╭────────────────────────╮
│ EXPORT & DOCUMENTATION │
╰────────────────────────╯
Workflow exported to loan_process.stzflow
Org chart exported to bank_structure.stzorg

Performance Report:
  Total process time: 9h
  Critical path: 9h
  SLA violations: 0
  Bottlenecks: 0
  Positions involved: 3

╭───────────────────────╮
│ STATE MACHINE EXAMPLE │
╰───────────────────────╯
State machine reachability: pass
`
