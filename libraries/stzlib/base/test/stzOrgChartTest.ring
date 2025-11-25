
load "../stzbase.ring"


#----------------------#
# BASIC STRUCTURE CREATION #
#----------------------#

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
    ? Positions()
    ? Position("ceo")

    # View basic chart
    ? Dot()
    View()
}

pf()

#----------------------#
# PEOPLE MANAGEMENT #
#----------------------#

/*-- Tests adding people, assigning to positions, person data, vacancy status, and people listing.

pr()

oOrg = new stzOrgChart("People_Management")
oOrg {

    AddPositionXT("ceo", "CEO")
    AddPositionXT("vp", "VP")

    # Add people with data
    AddPersonXTT("p1", "John Doe", [:tenure = 5, :performance = "High"])
    AddPersonXT("p2", "Jane Smith")

    # Assign people
    AssignPerson("p1", "ceo")
    AssignPerson("p2", "vp")

    # Verify assignments and data
    ? @@(People())
    ? PersonData("p1")
    ? @@(VacantPositions())  # Should be empty

    # View with people
    ViewWithPeople()
}

pf()

#----------------------#
# DEPARTMENT MANAGEMENT #
#----------------------#

/*-- Tests adding departments, assigning positions to departments, and department queries.

pr()

oOrg = new stzOrgChart("Department_Management")
oOrg {

    AddPositionXT("ceo", "CEO")
    AddPositionXT("sales_mgr", "Sales Manager")
    AddPositionXT("eng_mgr", "Engineering Manager")

    # Add departments with positions
    AddDepartmentXTT("sales", "Sales Dept", ["sales_mgr"])
    AddDepartmentXTT("eng", "Engineering Dept", ["eng_mgr"])

    # Set position departments
    SetPositionDepartment("ceo", "Executive")
    SetPositionDepartment("sales_mgr", "sales")

    # Verify
    ? Departments()
    ? Department("sales")

    ViewByDepartment()
}

pf()

#----------------------#
# ANALYSIS LAYERS #
#----------------------#

/*-- Tests adding and applying analysis layers of different types.

pr()

oOrg = new stzOrgChart("Analysis_Layers")
oOrg {

    AddPositionXT("ceo", "CEO")
    AddPositionXT("vp", "VP")
    ReportsTo("vp", "ceo")

    # Add layers
    oPerformance = AddAnalysisLayer("Performance", "performance")
    oRisk = AddAnalysisLayer("Risk", "risk")
    oCompliance = AddAnalysisLayer("Compliance", "compliance")
    oSuccession = AddAnalysisLayer("Succession", "succession")

    # Apply individually and all
    ApplyLayer("Performance")
    ApplyAllLayers()

    # View after layers applied
    View()
}

pf()

/*---

pr()

oOrg = new stzOrgChart("Simple_Hierarchy")
oOrg {

    SetLayout("TD")

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
	
	? "BCEAO BANKING GOVERNANCE VALIDATION"
	? "-----------------------------------" + NL
	
	? @@NL( ValidateBCEAOGovernance() ) + NL
	
	
	? "SPAN OF CONTROL VALIDATION"
	? "--------------------------" + NL
	
	? @@NL( ValidateSpanOfControl() ) + NL
	
	
	? "SEGREGATION OF DUTIES VALIDATION"
	? "--------------------------------" + NL
	
	? @@NL( ValidateSegregationOfDuties() ) + NL
	
	
	? "ORGANIZATIONAL SUMMARY REPORT"
	? "-----------------------------" + NL
	
	? @@NL( GenerateReport("summary") ) + NL
	
	
	? "VACANCY REPORT"
	? "--------------" + NL
	
	? @@NL( GenerateReport("vacancies") ) + NL
	
	
	? "SUCCESSION RISK REPORT"
	? "----------------------" + NL
	
	? @@NL( GenerateReport("succession") ) + NL
	
	
	? "COMPLIANCE STATUS REPORT"
	? "------------------------" + NL
	
	? @@NL( GenerateReport("compliance") ) + NL
	
	
	? "SPAN OF CONTROL ANALYSIS"
	? "------------------------" + NL
	
	? @@NL( GenerateReport("span") ) + NL
	
	
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
	
	? @@NL( CreateSnapshot("Q4_2024") ) + NL

	
	? "GENERATING VISUALIZATION"
	? "------------------------" + NL
	
	ColorByDepartment()
	? "✓ Color-coded by department"
	
	HighlightPath("ops_analyst1", "board")
	? "✓ Highlighted reporting path to board" + NL

	? "Opening visualization..."
	
	View()
}

pf()

#----------------------#
# VALIDATION AND COMPLIANCE #
#----------------------#

/*-- Tests BCEAO governance, span of control, segregation of duties validations, and direct reports metrics.

pr()

oOrg = new stzOrgChart("Validation_Compliance")
oOrg {

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
    ? ValidateBCEAOGovernance()
    ? ValidateSpanOfControl()
    ? ValidateSegregationOfDuties()

    # Metrics
    ? DirectReportsCount("dir_ops")
    ? DirectReports("dir_ops")

    View()
}

pf()

#----------------------#
# REPORTING AND ANALYTICS #
#----------------------#

/*-- Tests organizational metrics and all report types.

pr()

oOrg = new stzOrgChart("Reporting_Analytics")
oOrg {

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

}

pf()
# Executed in 0.08 second(s) in Ring 1.24

#----------------------#
# ORGANIZATIONAL CHANGES #
#----------------------#

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

pf()
# Executed in 1.59 second(s) in Ring 1.24

#----------------------#
# SIMULATIONS AND SNAPSHOTS #
#----------------------#

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
    ? @@NL( CreateSnapshot("Initial") )
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
    // SimulatedChart().View()  # Note: SimulatedChart is in simulation class, need to capture
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#----------------------#
# VISUALIZATION FEATURES #
#----------------------#

/*-- Tests visualization options, branching, views, coloring, highlighting.

pr()

oOrg = new stzOrgChart("Visualization")
oOrg {

    EnableCleanBranching(TRUE)

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
    HighlightPath("staff1", "ceo")

    # Different views
    ViewWithPeople()
    ViewVacancies()
    ViewByDepartment()
}

pf()

#----------------------#
# EDGE CASE: EMPTY CHART #
#----------------------#

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

    View()

}

pf()

#----------------------#
# EDGE CASE: SINGLE POSITION #
#----------------------#

/*-- Tests chart with only one position.

pr()

oOrg = new stzOrgChart("Single_Position")
oOrg {

    AddExecutivePositionXT("ceo", "CEO")

    ? Positions()
    ? DirectReportsCount("ceo")  # 0
    ? VacantPositions()  # ["ceo"]
    ? AverageSpanOfControl()  # 0
    ? ValidateSpanOfControl()  # pass

    View()

}

pf()

#----------------------#
# EDGE CASE: DUPLICATE POSITIONS #
#----------------------#

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

#----------------------#
# EDGE CASE: INVALID REPORTING #
#----------------------#

/*-- Tests reporting to non-existent supervisor.

pr()

oOrg = new stzOrgChart("Invalid_Reporting")
oOrg {

    AddPositionXT("sub", "Subordinate")
    ReportsTo("sub", "nonexistent")

    ? Position("sub")[:reportsTo]  # "nonexistent"
    ? Dot()  # May have error in graph

}

pf()

#----------------------#
# EDGE CASE: CYCLE IN HIERARCHY #
#----------------------#

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

pf()

#----------------------#
# EDGE CASE: REMOVE ASSIGNED POSITION #
#----------------------#

/*-- Tests removing position with assigned person.

pr()

oOrg = new stzOrgChart("Remove_Assigned")
oOrg {

    AddPositionXT("pos", "Position")
    AddPersonXT("p1", "Person 1")
    AssignPerson("p1", "pos")

    ? Position("pos")[:incumbent]  # "p1"

    RemovePosition("pos")

    ? Positions()  # []
    ? PersonData("p1")[:position]  # ""

}

pf()

#----------------------#
# EDGE CASE: INVALID ASSIGNMENTS #
#----------------------#

/*-- Tests assigning invalid person or position.

pr()

oOrg = new stzOrgChart("Invalid_Assignments")
oOrg {

    AddPersonXT("p1", "Person 1")
    AssignPerson("p1", "nonpos")  # No effect

    AddPositionXT("pos", "Position")
    AssignPerson("nonp", "pos")  # No effect

    ? PersonData("p1")[:position]  # ""
    ? Position("pos")[:incumbent]  # ""

}

pf()

#----------------------#
# EDGE CASE: WIDE HIERARCHY #
#----------------------#

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
    ? ValidateSpanOfControl()  # fail

}

pf()

#----------------------#
# EDGE CASE: DEEP HIERARCHY #
#----------------------#

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

}

pf()

#----------------------#
# EDGE CASE: SPECIAL CHARACTERS #
#----------------------#

/*-- Tests IDs and titles with special chars.

pr()

oOrg = new stzOrgChart("Special_Characters")
oOrg {

    AddPositionXT("pos-1@", "Pos \"1\" \n Newline")
    AddPositionXT("pos2", "Pos 2")

    ReportsTo("pos2", "pos-1@")

    ? Dot()  # Check quoting in DOT

}

pf()

#----------------------#
# EDGE CASE: EMPTY DEPARTMENT #
#----------------------#

/*-- Tests department with no positions.

pr()

oOrg = new stzOrgChart("Empty_Department")
oOrg {

    AddDepartmentXTT("dept1", "Department 1", [])

    ? Department("dept1")[:positions]  # []

}

pf()

#----------------------#
# EDGE CASE: UNASSIGNED PEOPLE #
#----------------------#

/*-- Tests people not assigned to positions.

pr()

oOrg = new stzOrgChart("Unassigned_People")
oOrg {

    AddPersonXT("p1", "Person 1")
    AddPersonXT("p2", "Person 2")

    ? People()
    ? VacancyRate()  # 0, no positions

}

pf()

#----------------------#
# EDGE CASE: INVALID LAYER #
#----------------------#

/*-- Tests unknown analysis layer type.

pr()

oOrg = new stzOrgChart("Invalid_Layer")
oOrg {

    AddAnalysisLayer("test", "unknown")
    ApplyLayer("test")  # No effect

}

pf()

#----------------------#
# EDGE CASE: INVALID SIMULATION #
#----------------------#

/*-- Tests simulation with unknown change type.

pr()

oOrg = new stzOrgChart("Invalid_Simulation")
oOrg {

    aChanges = [ [:type = "unknown", :param = "x"] ]
    ? SimulateReorganization(aChanges)

}

pf()

#----------------------#
# EDGE CASE: EMPTY SNAPSHOT #
#----------------------#

/*-- Tests snapshot of empty chart.

pr()

oOrg = new stzOrgChart("Empty_Snapshot")
oOrg {

    ? CreateSnapshot("empty_snap")

}

pf()

#----------------------#
# PARENT FEATURES: STZGRAPH TRAVERSAL #
#----------------------#

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

#----------------------#
# PARENT FEATURES: STZGRAPH ANALYSIS #
#----------------------#

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
    ? CyclicDependencies()  # FALSE

    # Connected components
    ? @@( ConnectedComponents() )  # [["a", "b", "c", "d", "e"]] if connected

    # Articulation points (removal increases components)
    ? @@( ArticulationPoints() ) # e.g. ["a", "b", "c"]

    # Betweenness centrality
    ? BetweennessCentrality("b")  # High for b

    # Closeness centrality
    ? ClosenessCentrality("a")  # High for root

    # Diameter (longest shortest path)
    ? Diameter()  # 3 (a to d)

    # Average path length
    ? AveragePathLength()

    # Clustering coefficient
    ? ClusteringCoefficient("a")  # Low since branches don't connect

}

pf()

#----------------------#
# PARENT FEATURES: STZDIAGRAM VISUALIZATION #
#----------------------#

/*-- Tests diagram-specific features like shapes, clusters, validation.

pr()

oOrg = new stzOrgChart("Diagram_Features")
oOrg {

    SetTheme("dark")
    SetLayout("leftright")

    # Use different shapes from stzDiagram
    AddCircle("start", "Start")
    AddBoxXT("process", "Process", "blue")
    AddDiamond("decision", "Decision")
    AddDoubleCircle("end", "End")

    Connect("start", "process")
    Connect("process", "decision")
    ConnectXT("decision", "end", "Yes")

    # Add cluster
    AddCluster("group1", "Group 1", ["process", "decision"], "lightblue")

    # Validate diagram (from stzDiagram)
    ? Validate("dag")  # [:status = "pass", ...]

    # Set visual rule
    oRule = new stzVisualRule("highlight_start")
    oRule.WhenPropertyEquals("type", "start")
    oRule.ApplyColor("green")
    SetVisualRule(oRule)

    ApplyVisualRules()

    # View
    View()

}

pf()

#----------------------#
# PARENT FEATURES: STZGRAPH RULES #
#----------------------#

/*-- Tests rule system from stzGraph.

pr()

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
    oRule.WhenPropertyGreaterThan("value", 15)
    oRule.Apply("color", "red")
    SetRule(oRule)

    # Add validation rule
    oValRule = new stzGraphRule("low_value_check")
    oValRule.SetRuleType("validation")
    oValRule.WhenPropertyLessThan("value", 10)
    oValRule.AddViolation("Value too low")
    SetRule(oValRule)

    # Apply
    ApplyRules()

    # Check affected
    ? @@( NodesAffectedByRules() )  # ["b", "c"] depending on rules

    # Rules applied info
    ? @@( RulesApplied() )

}

pf()

#----------------------#
# EDGE CASE: CYCLE DETECTION FROM STZGRAPH #
#----------------------#

/*-- Tests cycle detection.

pr()

oOrg = new stzOrgChart("Cycle_Detection")
oOrg {

    AddPositionXT("a", "A")
    AddPositionXT("b", "B")
    AddPositionXT("c", "C")

    ReportsTo("b", "a")
    ReportsTo("c", "b")
    ReportsTo("a", "c")  # Cycle

    ? CyclicDependencies()  # TRUE

    # Remove cycle
    Disconnect("a", "c")
    ? CyclicDependencies()  # FALSE

}

pf()

#----------------------#
# EXPORT/IMPORT SAMPLE #
#----------------------#

/*-- Tests exporting to .stzorg and importing back.
*/
pr()

oOrg = new stzOrgChart("Export_Import_Test")
oOrg {

    AddExecutivePositionXT("ceo", "CEO")
    AddManagementPositionXT("vp_sales", "VP Sales")
    ReportsTo("vp_sales", "ceo")

view()
/*
    # Export
    ? ToStzOrg()
    WriteToStzOrgFile("test.stzorg")

    # Verify export
    SaveFile("test.stzorg")
*/
}
pf()

/*
# Import to new chart
oOrgChart = new stzOrgChart("Imported_Org")
oOrgChart {
	Import("test.stzorg")
	View()
}

pf()
