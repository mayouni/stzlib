#=====================================================
#  COMPLETE INTEGRATED VALIDATION SAMPLE
#  Demonstrates all secondary classes in action
#=====================================================

load "../stzbase.ring"

/*---

pr()

oChart = new stzOrgChart("Company")

oChart.AddExecutivePositionXT("ceo", "CEO")
oChart.AddManagementPositionXT("vp_sales", "VP Sales")
oChart.AddManagementPositionXT("vp_eng", "VP Engineering")

oChart.ReportsTo("vp_sales", "ceo")
oChart.ReportsTo("vp_eng", "ceo")

? oChart.Dot()  # Verify output
oChart.View()

pf()

/*--- WOW!
*/
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

    //ColorByDepartment()

    #-------#
    # VIEW  #
    #-------#

    View()
}


pf()

/*--- #TODO Fix edges
*/
pr()

oOrgChart = new stzOrgChart("Banque_Sahel_Compact")
oOrgChart {
    SetLayout("topdown")

    # LEVEL 1
    AddExecutivePositionXT("board", "Board")

    # LEVEL 2
    AddExecutivePositionXT("ceo", "CEO")
    ReportsTo("ceo", "board")

    AddManagementPositionXT("dceo", "D-CEO")
    AddManagementPositionXT("coo", "COO")
    AddManagementPositionXT("cfro", "CFRO")

    ReportsTo("dceo", "ceo")
    ReportsTo("coo", "ceo")
    ReportsTo("cfro", "ceo")

    AddManagementPositionXT("dir_audit", "Dir Audit")
    ReportsTo("dir_audit", "board")

    # LEVEL 3 – LEFT BLOCK
    AddManagementPositionXT("dir_ops", "Dir Ops")
    AddManagementPositionXT("dir_hr", "Dir HR")
    AddManagementPositionXT("dir_it", "Dir IT")
    AddManagementPositionXT("dir_digital", "Dir Digital")

    ReportsTo("dir_ops", "coo")
    ReportsTo("dir_hr", "dceo")
    ReportsTo("dir_it", "coo")
    ReportsTo("dir_digital", "coo")

    # LEVEL 3 – RIGHT BLOCK
    AddManagementPositionXT("dir_treasury", "Dir Treasury")
    AddManagementPositionXT("dir_risk", "Dir Risk")
    AddManagementPositionXT("dir_compliance", "Dir Compliance")

    ReportsTo("dir_treasury", "cfro")
    ReportsTo("dir_risk", "cfro")
    ReportsTo("dir_compliance", "cfro")

    # LEVEL 4 – STAFF
    AddStaffPositionXT("ops_mgr", "Ops Mgr")
    ReportsTo("ops_mgr", "dir_ops")

    AddStaffPositionXT("hr_mgr", "HR Mgr")
    ReportsTo("hr_mgr", "dir_hr")

    AddStaffPositionXT("it_mgr", "IT Mgr")
    AddStaffPositionXT("sys_analyst", "Sys Analyst")
    ReportsTo("it_mgr", "dir_it")
    ReportsTo("sys_analyst", "it_mgr")

    AddStaffPositionXT("cx_mgr", "CX Mgr")
    ReportsTo("cx_mgr", "dir_digital")

    AddStaffPositionXT("treasury_mgr", "Treas Mgr")
    AddStaffPositionXT("treasury_analyst", "Treas Analyst Sr")
    ReportsTo("treasury_mgr", "dir_treasury")
    ReportsTo("treasury_analyst", "treasury_mgr")

    AddStaffPositionXT("risk_mgr", "Risk Mgr")
    AddStaffPositionXT("risk_credit", "Credit Analyst")
    AddStaffPositionXT("risk_market", "Market Analyst")
    ReportsTo("risk_mgr", "dir_risk")
    ReportsTo("risk_credit", "risk_mgr")
    ReportsTo("risk_market", "risk_mgr")

    AddStaffPositionXT("comp_mgr", "Comp Mgr")
    ReportsTo("comp_mgr", "dir_compliance")

    AddStaffPositionXT("aud_s", "Aud Sr")
    AddStaffPositionXT("aud_j", "Aud Jr")
    ReportsTo("aud_s", "dir_audit")
    ReportsTo("aud_j", "aud_s")

    ColorByDepartment()
    View()
}


pf()

/*--- #TODO check layout of edges

oOrgChart = new stzOrgChart("Banque_Sahel")

oOrgChart {
	SetLayout("topdown")
	
	#----------------------------
	# BUILD ORGANIZATIONAL STRUCTURE
	#----------------------------
	
	# Board Level
	AddExecutivePositionXT("board", "Board of Directors")
	
	# Executive Level
	AddExecutivePositionXT("ceo", "Chief Executive Officer")
	AddManagementPositionXT("dg_adj", "Deputy General Manager")
	
	ReportsTo("ceo", "board")
	ReportsTo("dg_adj", "ceo")
	
	# Department Directors
	AddManagementPositionXT("dir_ops", "Director of Operations")
	AddManagementPositionXT("dir_treasury", "Director of Treasury")
	AddManagementPositionXT("dir_risk", "Director of Risk Management")
	AddManagementPositionXT("dir_audit", "Director of Internal Audit")
	AddManagementPositionXT("dir_compliance", "Director of Compliance")
	AddManagementPositionXT("dir_hr", "Director of Human Resources")
	AddManagementPositionXT("dir_it", "Director of IT")
	
	ReportsTo("dir_ops", "dg_adj")
	ReportsTo("dir_treasury", "dg_adj")
	ReportsTo("dir_risk", "ceo")
	ReportsTo("dir_audit", "board")  # BCEAO requirement
	ReportsTo("dir_compliance", "ceo")
	ReportsTo("dir_hr", "dg_adj")
	ReportsTo("dir_it", "dg_adj")
	
	# Operations Team
	AddStaffPositionXT("ops_mgr1", "Operations Manager - Retail")
	AddStaffPositionXT("ops_mgr2", "Operations Manager - Corporate")
	AddStaffPositionXT("ops_analyst1", "Operations Analyst")
	ReportsTo("ops_mgr1", "dir_ops")
	ReportsTo("ops_mgr2", "dir_ops")
	ReportsTo("ops_analyst1", "ops_mgr1")
	
	# Treasury Team
	AddStaffPositionXT("treasury_mgr", "Treasury Manager")
	AddStaffPositionXT("treasury_analyst", "Treasury Analyst")
	ReportsTo("treasury_mgr", "dir_treasury")
	ReportsTo("treasury_analyst", "treasury_mgr")
	
	# Risk Team
	AddStaffPositionXT("risk_mgr", "Risk Manager")
	AddStaffPositionXT("risk_analyst1", "Risk Analyst - Credit")
	AddStaffPositionXT("risk_analyst2", "Risk Analyst - Market")
	ReportsTo("risk_mgr", "dir_risk")
	ReportsTo("risk_analyst1", "risk_mgr")
	ReportsTo("risk_analyst2", "risk_mgr")
	
	# Audit Team
	AddStaffPositionXT("auditor1", "Senior Auditor")
	AddStaffPositionXT("auditor2", "Junior Auditor")
	ReportsTo("auditor1", "dir_audit")
	ReportsTo("auditor2", "dir_audit")
	
	# HR Team
	AddStaffPositionXT("hr_mgr", "HR Manager")
	ReportsTo("hr_mgr", "dir_hr")
	
	# IT Team
	AddStaffPositionXT("it_mgr", "IT Manager")
	AddStaffPositionXT("it_analyst", "Systems Analyst")
	ReportsTo("it_mgr", "dir_it")
	ReportsTo("it_analyst", "it_mgr")
	
	#----------------------------
	# SET DEPARTMENT PROPERTIES
	#----------------------------
	
	SetNodeProperty("board", "department", "board")
	SetNodeProperty("ceo", "department", "executive")
	SetNodeProperty("dg_adj", "department", "executive")
	
	SetNodeProperty("dir_ops", "department", "operations")
	SetNodeProperty("ops_mgr1", "department", "operations")
	SetNodeProperty("ops_mgr2", "department", "operations")
	SetNodeProperty("ops_analyst1", "department", "operations")
	
	SetNodeProperty("dir_treasury", "department", "treasury")
	SetNodeProperty("treasury_mgr", "department", "treasury")
	SetNodeProperty("treasury_analyst", "department", "treasury")
	
	SetNodeProperty("dir_risk", "department", "risk")
	SetNodeProperty("risk_mgr", "department", "risk")
	SetNodeProperty("risk_analyst1", "department", "risk")
	SetNodeProperty("risk_analyst2", "department", "risk")
	
	SetNodeProperty("dir_audit", "department", "audit")
	SetNodeProperty("auditor1", "department", "audit")
	SetNodeProperty("auditor2", "department", "audit")
	
	SetNodeProperty("dir_hr", "department", "hr")
	SetNodeProperty("hr_mgr", "department", "hr")
	
	SetNodeProperty("dir_it", "department", "it")
	SetNodeProperty("it_mgr", "department", "it")
	SetNodeProperty("it_analyst", "department", "it")
	
	#----------------------------
	# ADD PEOPLE
	#----------------------------
	
	AddPersonXT("p_ceo", "Jean-Baptiste Kouassi")
	AssignPerson("p_ceo", "ceo")
	
	AddPersonXT("p_dg_adj", "Fatoumata Diarra")
	AssignPerson("p_dg_adj", "dg_adj")
	
	AddPersonXT("p_dir_audit", "Aminata Diallo")
	AssignPerson("p_dir_audit", "dir_audit")
	
	AddPersonXT("p_dir_risk", "Mamadou Traoré")
	AssignPerson("p_dir_risk", "dir_risk")
	
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
