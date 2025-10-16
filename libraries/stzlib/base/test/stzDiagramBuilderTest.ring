load "../stzbase.ring"

/*===================================================
#  stzDiagramBuilder - Comprehensive Feature Showcase
#  Demonstrating all capabilities: themes, layouts,
#  node types, colors, clusters, and configurations
#===================================================*/

#-----------------#
#  EXAMPLE 1: BASIC FLOW
#-----------------#

/*--- Simple process flow with theme and layout

pr()

oDiagBuilder = new stzDiagramBuilder("Order Processing")
oDiagBuilder {
	SetTheme(:Vibrant)
	SetLayout(:LeftRight)

	AddNodeXT(:ID = "start", :Label = "Start Order", :Type = :Start)
	WithColor(:Success)

	AddNodeXT("verify", "Verify Payment", :Process)
	WithColor(:Primary)

	AddNodeXT("decision", "Payment OK?", :Decision)
	WithColor(:warning)

	AddNodeXT("ship", "Ship Order", :Process)
	WithColor(:primary)

	AddNodeXT("end", "Order Complete", :Endpoint)
	WithColor(:success)

	ConnectXT("start", :To = "verify", :With = "Step 1")
	ConnectXT("verify", :To = "decision", :With = "Check")
	ConnectXT("decision", :To = "ship", :With = "Yes")
	ConnectXT("ship", :To = "end", :With = "Complete")

	Render("example1_basic_flow.svg")
}

pf()

#-----------------#
#  EXAMPLE 2: STATE MACHINE - LIGHT THEME
#-----------------#

/*--- State machine demonstrating all state transitions
	with light color palette

pr()

oStateLight = new stzDiagramBuilder("State Machine - Light Theme")
oStateLight {
	SetTheme(:Light)
	SetLayout(:TopDown)
	SetFont(:default)

	AddNodeXT(:ID = "idle", :Label = "Idle", :Type = :State)
	WithColor(:neutral)

	AddNodeXT("running", "Running", :State)
	WithColor(:success)

	AddNodeXT("paused", "Paused", :State)
	WithColor(:warning)

	AddNodeXT("stopped", "Stopped", :State)
	WithColor(:danger)

	ConnectXT("idle", :To = "running", :With = "start()")
	ConnectXT("running", :To = "paused", :With = "pause()")
	ConnectXT("paused", :To = "running", :With = "resume()")
	ConnectXT("running", :To = "stopped", :With = "stop()")
	ConnectXT("paused", :To = "stopped", :With = "stop()")
	ConnectXT("stopped", :To = "idle", :With = "reset()")

	Render("example2_state_light.svg")
}

pf()

#-----------------#
#  EXAMPLE 3: STATE MACHINE - DARK THEME
#-----------------#

/*--- Same state machine with dark professional theme
	showing theme portability

pr()

oStateDark = new stzDiagramBuilder("State Machine - Dark Theme")
oStateDark {
	SetTheme(:Dark)
	SetLayout(:TopDown)

	AddNodeXT("idle", "Idle", :State)
	WithColor(:neutral)

	AddNodeXT("running", "Running", :State)
	WithColor(:success)

	AddNodeXT("paused", "Paused", :State)
	WithColor(:warning)

	AddNodeXT("stopped", "Stopped", :State)
	WithColor(:danger)

	ConnectXT("idle", :To = "running", :With = "start()")
	ConnectXT("running", :To = "paused", :With = "pause()")
	ConnectXT("paused", :To = "running", :With = "resume()")
	ConnectXT("running", :To = "stopped", :With = "stop()")
	ConnectXT("paused", :To = "stopped", :With = "stop()")
	ConnectXT("stopped", :To = "idle", :With = "reset()")

	Render("example3_state_dark.svg")
}

pf()

#-----------------#
#  EXAMPLE 4: DATABASE ARCHITECTURE
#-----------------#

/*--- Multi-tier database architecture with storage nodes
	demonstrating data flow patterns

pr()

oDatabase = new stzDiagramBuilder("Database Architecture")
oDatabase {
	SetTheme(:Professional)
	SetLayout(:LeftRight)
	SetFont(:monospace)

	AddNodeXT("app", "Application", :Process)
	WithColor(:primary)

	AddNodeXT("cache", "Redis Cache", :Storage)
	WithColor(:info)

	AddNodeXT("db", "PostgreSQL", :Storage)
	WithColor(:success)

	AddNodeXT("backup", "Backup Store", :Storage)
	WithColor(:warning)

	AddNodeXT("archive", "Archive", :Data)
	WithColor(:neutral)

	ConnectXT("app", :To = "cache", :With = "Read/Write")
	ConnectXT("app", :To = "db", :With = "Query")
	ConnectXT("db", :To = "backup", :With = "Sync")
	ConnectXT("backup", :To = "archive", :With = "Archive")

	Render("example4_database.svg")
}

pf()

#-----------------#
#  EXAMPLE 5: EVENT-DRIVEN SYSTEM
#-----------------#

/*--- Event emitter publishing to multiple subscribers
	with organic layout for non-hierarchical systems

pr()

oEventSystem = new stzDiagramBuilder("Event-Driven System")
oEventSystem {
	SetTheme(:Vibrant)
	SetLayout(:Organic)

	AddNodeXT("event", "Event Emitter", :Event)
	WithColor(:primary)

	AddNodeXT("subscriber1", "Subscriber 1", :Process)
	WithColor(:success)

	AddNodeXT("subscriber2", "Subscriber 2", :Process)
	WithColor(:info)

	AddNodeXT("subscriber3", "Subscriber 3", :Process)
	WithColor(:warning)

	AddNodeXT("logger", "Logger", :Data)
	WithColor(:neutral)

	ConnectXT("event", :To = "subscriber1", :With = "on_update")
	ConnectXT("event", :To = "subscriber2", :With = "on_update")
	ConnectXT("event", :To = "subscriber3", :With = "on_update")
	ConnectXT("subscriber1", :To = "logger", :With = "log")
	ConnectXT("subscriber2", :To = "logger", :With = "log")
	ConnectXT("subscriber3", :To = "logger", :With = "log")

	Render("example5_events.svg")
}

pf()

#-----------------#
#  EXAMPLE 6: COMPLEX DECISION TREE
#-----------------#

/*--- Multi-level decision logic for user authentication
	demonstrating diamond nodes and conditional flow

pr()

oDecisionTree = new stzDiagramBuilder("User Authentication Flow")
oDecisionTree {
	SetTheme(:Vibrant)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "start", :Label = "", :Type = :Start)
	WithColor(:success)

	AddNodeXT("input", "Enter Credentials", :Process)
	WithColor(:primary)

	AddNodeXT("check_user", "User Exists?", :Decision)
	WithColor(:warning)

	AddNodeXT("check_pass", "Password Valid?", :Decision)
	WithColor(:warning)

	AddNodeXT("check_2fa", "2FA Enabled?", :Decision)
	WithColor(:warning)

	AddNodeXT("send_2fa", "Send 2FA Code", :Process)
	WithColor(:info)

	AddNodeXT("verify_2fa", "Code Valid?", :Decision)
	WithColor(:warning)

	AddNodeXT("success", "Login Success", :Endpoint)
	WithColor(:success)

	AddNodeXT("error", "Login Failed", :Endpoint)
	WithColor(:danger)

	ConnectXT("start", :To = "input", :With = "")
	ConnectXT("input", :To = "check_user", :With = "")
	ConnectXT("check_user", :To = "check_pass", :With = "Yes")
	ConnectXT("check_user", :To = "error", :With = "No")
	ConnectXT("check_pass", :To = "check_2fa", :With = "Yes")
	ConnectXT("check_pass", :To = "error", :With = "No")
	ConnectXT("check_2fa", :To = "send_2fa", :With = "Yes")
	ConnectXT("check_2fa", :To = "success", :With = "No")
	ConnectXT("send_2fa", :To = "verify_2fa", :With = "")
	ConnectXT("verify_2fa", :To = "success", :With = "Yes")
	ConnectXT("verify_2fa", :To = "error", :With = "No")

	Render("example6_decision_tree.svg")
}

pf()

#-----------------#
#  EXAMPLE 7: MICROSERVICES WITH CLUSTERS
#-----------------#

/*--- Microservices architecture using clusters to group
	related services by domain

pr()

oMicroservices = new stzDiagramBuilder("Microservices Architecture")
oMicroservices {
	SetTheme(:Dark)
	SetLayout(:LeftRight)
	SetBackgroundColor("#1e1e1e")

	AddNodeXT("gateway", "API Gateway", :Process)
	WithColor(:primary)

	AddNodeXT("user_svc", "User Service", :Process)
	WithColor(:success)

	AddNodeXT("user_db", "User DB", :Storage)
	WithColor(:success)

	AddNodeXT("order_svc", "Order Service", :Process)
	WithColor(:info)

	AddNodeXT("order_db", "Order DB", :Storage)
	WithColor(:info)

	AddNodeXT("pay_svc", "Payment Service", :Process)
	WithColor(:warning)

	AddNodeXT("pay_db", "Payment DB", :Storage)
	WithColor(:warning)

	AddNodeXT("queue", "Message Queue", :Data)
	WithColor(:danger)

	ConnectXT("gateway", :To = "user_svc", :With = "route")
	ConnectXT("gateway", :To = "order_svc", :With = "route")
	ConnectXT("gateway", :To = "pay_svc", :With = "route")

	ConnectXT("user_svc", :To = "user_db", :With = "")
	ConnectXT("order_svc", :To = "order_db", :With = "")
	ConnectXT("pay_svc", :To = "pay_db", :With = "")

	ConnectXT("order_svc", :To = "queue", :With = "publish")
	ConnectXT("pay_svc", :To = "queue", :With = "publish")
	ConnectXT("queue", :To = "user_svc", :With = "subscribe")

	AddClusterXT(:ID = "users", :Label = "User Domain", :Nodes = ["user_svc", "user_db"], :Color = "lightgreen")
	AddClusterXT(:ID = "orders", :Label = "Order Domain", :Nodes = ["order_svc", "order_db"], :Color = "lightblue")
	AddClusterXT(:ID = "payments", :Label = "Payment Domain", :Nodes = ["pay_svc", "pay_db"], :Color = "lightyellow")

	Render("example7_microservices.svg")
}

pf()

#-----------------#
#  EXAMPLE 8: DATA PIPELINE
#-----------------#

/*--- ETL pipeline showcasing all node types: start, process,
	decision, storage, data, and endpoint

pr()

oDataPipeline = new stzDiagramBuilder("ETL Data Pipeline")
oDataPipeline {
	SetTheme(:Professional)
	SetLayout(:LeftRight)

	AddNodeXT(:ID = "source", :Label = "", :Type = :Start)
	WithColor(:primary)

	AddNodeXT("extract", "Extract Data", :Process)
	WithColor(:primary)

	AddNodeXT("validate", "Valid Format?", :Decision)
	WithColor(:warning)

	AddNodeXT("transform", "Transform", :Process)
	WithColor(:info)

	AddNodeXT("enrich", "Enrich Data", :Process)
	WithColor(:info)

	AddNodeXT("store", "Data Warehouse", :Storage)
	WithColor(:success)

	AddNodeXT("report", "Generate Report", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "notify", :Label = "", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT("error_log", "Error Log", :Data)
	WithColor(:danger)

	ConnectXT("source", :To = "extract", :With = "")
	ConnectXT("extract", :To = "validate", :With = "")
	ConnectXT("validate", :To = "transform", :With = "Valid")
	ConnectXT("validate", :To = "error_log", :With = "Invalid")
	ConnectXT("transform", :To = "enrich", :With = "")
	ConnectXT("enrich", :To = "store", :With = "")
	ConnectXT("store", :To = "report", :With = "")
	ConnectXT("report", :To = "notify", :With = "")

	Render("example8_data_pipeline.svg")
}

pf()

#-----------------#
#  EXAMPLE 9: LAYOUT COMPARISON - TOPDOWN
#-----------------#

/*--- Linear process flow using TopDown layout
	ideal for sequential step-by-step processes

pr()

oLayoutTopDown = new stzDiagramBuilder("Process Flow - Top Down")
oLayoutTopDown {
	SetTheme(:Vibrant)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "s1", :Label = "Start", :Type = :Start)
	WithColor(:success)

	AddNodeXT("a1", "Step A", :Process)
	WithColor(:primary)

	AddNodeXT("a2", "Step B", :Process)
	WithColor(:primary)

	AddNodeXT("a3", "Step C", :Process)
	WithColor(:primary)

	AddNodeXT(:ID = "e1", :Label = "End", :Type = :Endpoint)
	WithColor(:success)

	ConnectXT("s1", :To = "a1", :With = "")
	ConnectXT("a1", :To = "a2", :With = "")
	ConnectXT("a2", :To = "a3", :With = "")
	ConnectXT("a3", :To = "e1", :With = "")

	Render("example9_layout_topdown.svg")
}

pf()

#-----------------#
#  EXAMPLE 10: LAYOUT COMPARISON - LEFTRIGHT
#-----------------#

/*--- Same process flow using LeftRight layout
	better for wide screen presentation

pr()

oLayoutLeftRight = new stzDiagramBuilder("Process Flow - Left Right")
oLayoutLeftRight {
	SetTheme(:Vibrant)
	SetLayout(:LeftRight)

	AddNodeXT(:ID = "s1", :Label = "Start", :Type = :Start)
	WithColor(:success)

	AddNodeXT("a1", "Step A", :Process)
	WithColor(:primary)

	AddNodeXT("a2", "Step B", :Process)
	WithColor(:primary)

	AddNodeXT("a3", "Step C", :Process)
	WithColor(:primary)

	AddNodeXT(:ID = "e1", :Label = "End", :Type = :Endpoint)
	WithColor(:success)

	ConnectXT("s1", :To = "a1", :With = "")
	ConnectXT("a1", :To = "a2", :With = "")
	ConnectXT("a2", :To = "a3", :With = "")
	ConnectXT("a3", :To = "e1", :With = "")

	Render("example10_layout_leftright.svg")
}

pf()

#-----------------#
#  EXAMPLE 11: TRADITIONAL ORGANIZATION CHART
#-----------------#

/*--- Hierarchical organization with CEO, directors, managers,
	and individual contributors showing reporting structure

pr()

oOrgChart = new stzDiagramBuilder("Company Organization Chart")
oOrgChart {
	SetTheme(:Professional)
	SetLayout(:TopDown)
	SetBackgroundColor("white")

	AddNodeXT(:ID = "ceo", :Label = "CEO\nJohn Smith", :Type = :Process)
	WithColor(:primary)

	AddNodeXT("cto", "CTO\nAlice Johnson", :Process)
	WithColor(:info)

	AddNodeXT("cfo", "CFO\nBob Williams", :Process)
	WithColor(:warning)

	AddNodeXT("coo", "COO\nCarol Davis", :Process)
	WithColor(:success)

	AddNodeXT("dev_lead", "Dev Lead\nEric Brown", :Process)
	WithColor(:primary)

	AddNodeXT("devops_lead", "DevOps Lead\nFiona Green", :Process)
	WithColor(:primary)

	AddNodeXT("finance_lead", "Finance Lead\nGeorge White", :Process)
	WithColor(:warning)

	AddNodeXT("senior_dev1", "Senior Dev\nHenry Black", :Process)
	WithColor(:neutral)

	AddNodeXT("senior_dev2", "Senior Dev\nIsabel Lopez", :Process)
	WithColor(:neutral)

	AddNodeXT("junior_dev1", "Junior Dev\nJack Miller", :Process)
	WithColor(:neutral)

	AddNodeXT("junior_dev2", "Junior Dev\nKate Taylor", :Process)
	WithColor(:neutral)

	ConnectXT("ceo", :To = "cto", :With = "Reports")
	ConnectXT("ceo", :To = "cfo", :With = "Reports")
	ConnectXT("ceo", :To = "coo", :With = "Reports")

	ConnectXT("cto", :To = "dev_lead", :With = "")
	ConnectXT("cto", :To = "devops_lead", :With = "")

	ConnectXT("cfo", :To = "finance_lead", :With = "")

	ConnectXT("dev_lead", :To = "senior_dev1", :With = "")
	ConnectXT("dev_lead", :To = "senior_dev2", :With = "")

	ConnectXT("senior_dev1", :To = "junior_dev1", :With = "Mentors")
	ConnectXT("senior_dev2", :To = "junior_dev2", :With = "Mentors")

	Render("example11_orgchart_traditional.svg")
}

pf()

#-----------------#
#  EXAMPLE 12: MATRIX ORGANIZATION
#-----------------#

/*--- Cross-functional matrix organization showing both
	functional and product line hierarchies

pr()

oMatrixOrg = new stzDiagramBuilder("Matrix Organization Structure")
oMatrixOrg {
	SetTheme(:Vibrant)
	SetLayout(:LeftRight)

	AddNodeXT("product_dir", "Product Director", :Process)
	WithColor(:primary)

	AddNodeXT("product_pm1", "PM - Mobile", :Process)
	WithColor(:info)

	AddNodeXT("product_pm2", "PM - Web", :Process)
	WithColor(:info)

	AddNodeXT("product_pm3", "PM - API", :Process)
	WithColor(:info)

	AddNodeXT("eng_dir", "Engineering Director", :Process)
	WithColor(:success)

	AddNodeXT("eng_mobile", "Mobile Team", :Process)
	WithColor(:neutral)

	AddNodeXT("eng_web", "Web Team", :Process)
	WithColor(:neutral)

	AddNodeXT("eng_api", "API Team", :Process)
	WithColor(:neutral)

	ConnectXT("product_dir", :To = "product_pm1", :With = "")
	ConnectXT("product_dir", :To = "product_pm2", :With = "")
	ConnectXT("product_dir", :To = "product_pm3", :With = "")

	ConnectXT("eng_dir", :To = "eng_mobile", :With = "")
	ConnectXT("eng_dir", :To = "eng_web", :With = "")
	ConnectXT("eng_dir", :To = "eng_api", :With = "")

	ConnectXT("product_pm1", :To = "eng_mobile", :With = "Collaborate")
	ConnectXT("product_pm2", :To = "eng_web", :With = "Collaborate")
	ConnectXT("product_pm3", :To = "eng_api", :With = "Collaborate")

	Render("example12_matrix_org.svg")
}

pf()

#-----------------#
#  EXAMPLE 13: LEAN STARTUP ORGANIZATION
#-----------------#

/*--- Flat organizational structure for startups
	showing organic collaboration patterns

pr()

oStartupOrg = new stzDiagramBuilder("Lean Startup - Flat Structure")
oStartupOrg {
	SetTheme(:Vibrant)
	SetLayout(:Organic)

	AddNodeXT("founder", "Founder/CEO", :Event)
	WithColor(:primary)

	AddNodeXT("dev1", "Full-Stack Dev", :Process)
	WithColor(:success)

	AddNodeXT("dev2", "Full-Stack Dev", :Process)
	WithColor(:success)

	AddNodeXT("design", "Designer/UX", :Process)
	WithColor(:info)

	AddNodeXT("marketing", "Marketing", :Process)
	WithColor(:warning)

	AddNodeXT("sales", "Sales", :Process)
	WithColor(:warning)

	AddNodeXT("ops", "Operations", :Process)
	WithColor(:neutral)

	ConnectXT("founder", :To = "dev1", :With = "")
	ConnectXT("founder", :To = "dev2", :With = "")
	ConnectXT("founder", :To = "design", :With = "")
	ConnectXT("founder", :To = "marketing", :With = "")
	ConnectXT("founder", :To = "sales", :With = "")
	ConnectXT("founder", :To = "ops", :With = "")

	ConnectXT("dev1", :To = "design", :With = "")
	ConnectXT("dev1", :To = "marketing", :With = "")
	ConnectXT("design", :To = "marketing", :With = "")
	ConnectXT("marketing", :To = "sales", :With = "")

	Render("example13_startup_org.svg")
}

pf()

#-----------------#
#  EXAMPLE 14: E-COMMERCE ORDER WORKFLOW
#-----------------#

/*--- Complete order processing workflow from receipt to completion
	with inventory, payment, and shipping stages

pr()

oOrderWorkflow = new stzDiagramBuilder("Order Processing Workflow")
oOrderWorkflow {
	SetTheme(:Professional)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "order_received", :Label = "Order Received", :Type = :Start)
	WithColor(:success)

	AddNodeXT("validate", "Validate Order", :Process)
	WithColor(:primary)

	AddNodeXT("valid", "Valid?", :Decision)
	WithColor(:warning)

	AddNodeXT("reserve_inventory", "Reserve Inventory", :Process)
	WithColor(:info)

	AddNodeXT("inventory_ok", "Stock Available?", :Decision)
	WithColor(:warning)

	AddNodeXT("process_payment", "Process Payment", :Process)
	WithColor(:primary)

	AddNodeXT("payment_ok", "Payment Success?", :Decision)
	WithColor(:warning)

	AddNodeXT("generate_label", "Generate Shipping Label", :Process)
	WithColor(:info)

	AddNodeXT("pack_item", "Pack Item", :Process)
	WithColor(:info)

	AddNodeXT("ship_item", "Ship Item", :Process)
	WithColor(:success)

	AddNodeXT("send_notification", "Send Notification", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "completed", :Label = "Order Completed", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT("refund", "Process Refund", :Process)
	WithColor(:danger)

	AddNodeXT(:ID = "cancelled", :Label = "Order Cancelled", :Type = :Endpoint)
	WithColor(:danger)

	AddNodeXT("inventory_log", "Update Inventory Log", :Data)
	WithColor(:neutral)

	ConnectXT("order_received", :To = "validate", :With = "")
	ConnectXT("validate", :To = "valid", :With = "")
	ConnectXT("valid", :To = "reserve_inventory", :With = "Yes")
	ConnectXT("valid", :To = "cancelled", :With = "No")

	ConnectXT("reserve_inventory", :To = "inventory_ok", :With = "")
	ConnectXT("inventory_ok", :To = "process_payment", :With = "Yes")
	ConnectXT("inventory_ok", :To = "refund", :With = "No")

	ConnectXT("process_payment", :To = "payment_ok", :With = "")
	ConnectXT("payment_ok", :To = "generate_label", :With = "Yes")
	ConnectXT("payment_ok", :To = "refund", :With = "No")

	ConnectXT("generate_label", :To = "pack_item", :With = "")
	ConnectXT("pack_item", :To = "ship_item", :With = "")
	ConnectXT("ship_item", :To = "send_notification", :With = "")
	ConnectXT("send_notification", :To = "completed", :With = "")

	ConnectXT("refund", :To = "inventory_log", :With = "")
	ConnectXT("inventory_log", :To = "cancelled", :With = "")

	Render("example14_order_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 15: LOAN APPROVAL WORKFLOW
#-----------------#

/*--- Banking workflow with comprehensive validation stages

pr()

oLoanWorkflow = new stzDiagramBuilder("Loan Application Workflow")
oLoanWorkflow {
	SetTheme(:Professional)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "apply", :Label = "Loan Application", :Type = :Start)
	WithColor(:success)

	AddNodeXT("doc_collect", "Collect Documents", :Process)
	WithColor(:primary)

	AddNodeXT("doc_verify", "Documents Complete?", :Decision)
	WithColor(:warning)

	AddNodeXT("credit_check", "Credit Check", :Process)
	WithColor(:info)

	AddNodeXT("credit_ok", "Good Credit?", :Decision)
	WithColor(:warning)

	AddNodeXT("income_verify", "Verify Income", :Process)
	WithColor(:info)

	AddNodeXT("income_ok", "Sufficient Income?", :Decision)
	WithColor(:warning)

	AddNodeXT("property_appraisal", "Property Appraisal", :Process)
	WithColor(:info)

	AddNodeXT("appraisal_ok", "Appraisal OK?", :Decision)
	WithColor(:warning)

	AddNodeXT("underwriting", "Underwriting Review", :Process)
	WithColor(:primary)

	AddNodeXT("underwrite_ok", "Approved?", :Decision)
	WithColor(:warning)

	AddNodeXT("legal_prep", "Legal Preparation", :Process)
	WithColor(:info)

	AddNodeXT("closing", "Loan Closing", :Process)
	WithColor(:success)

	AddNodeXT(:ID = "funded", :Label = "Loan Funded", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT(:ID = "denied", :Label = "Application Denied", :Type = :Endpoint)
	WithColor(:danger)

	AddNodeXT("request_more_docs", "Request More Documents", :Data)
	WithColor(:warning)

	ConnectXT("apply", :To = "doc_collect", :With = "")
	ConnectXT("doc_collect", :To = "doc_verify", :With = "")
	ConnectXT("doc_verify", :To = "credit_check", :With = "Yes")
	ConnectXT("doc_verify", :To = "request_more_docs", :With = "No")
	ConnectXT("request_more_docs", :To = "doc_collect", :With = "")

	ConnectXT("credit_check", :To = "credit_ok", :With = "")
	ConnectXT("credit_ok", :To = "income_verify", :With = "Yes")
	ConnectXT("credit_ok", :To = "denied", :With = "No")

	ConnectXT("income_verify", :To = "income_ok", :With = "")
	ConnectXT("income_ok", :To = "property_appraisal", :With = "Yes")
	ConnectXT("income_ok", :To = "denied", :With = "No")

	ConnectXT("property_appraisal", :To = "appraisal_ok", :With = "")
	ConnectXT("appraisal_ok", :To = "underwriting", :With = "Yes")
	ConnectXT("appraisal_ok", :To = "denied", :With = "No")

	ConnectXT("underwriting", :To = "underwrite_ok", :With = "")
	ConnectXT("underwrite_ok", :To = "legal_prep", :With = "Yes")
	ConnectXT("underwrite_ok", :To = "denied", :With = "No")

	ConnectXT("legal_prep", :To = "closing", :With = "")
	ConnectXT("closing", :To = "funded", :With = "")

	Render("example15_loan_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 16: INSURANCE CLAIMS WORKFLOW
#-----------------#

/*--- Insurance claims processing with fraud detection,
	damage estimation, and payment authorization
*/
pr()

oClaimsWorkflow = new stzDiagramBuilder("Insurance Claims Workflow")
oClaimsWorkflow {
	SetTheme(:Dark)
	SetLayout(:TopDown)
	SetNodeStrokeColor(:Gray)
	SetEdgeColor(:Gray)

	AddNodeXT(:ID = "claim_filed", :Label = "Claim Filed", :Type = :Start)
	WithColor(:primary)

	AddNodeXT("claim_intake", "Claim Intake", :Process)
	WithColor(:primary)

	AddNodeXT("assign_adjuster", "Assign Adjuster", :Process)
	WithColor(:info)

	AddNodeXT("field_inspection", "Field Inspection", :Process)
	WithColor(:info)

	AddNodeXT("documentation", "Gather Documentation", :Process)
	WithColor(:info)

	AddNodeXT("fraud_check", "Fraud Review", :Process)
	WithColor(:warning)

	AddNodeXT("fraud_flag", "Fraud Detected?", :Decision)
	WithColor(:warning)

	AddNodeXT("estimate_damage", "Estimate Damage", :Process)
	WithColor(:info)

	AddNodeXT("estimate_ok", "Estimate Approved?", :Decision)
	WithColor(:warning)

	AddNodeXT("reserve_funds", "Reserve Funds", :Data)
	WithColor(:neutral)

	AddNodeXT("authorize_repair", "Authorize Repair/Payout", :Process)
	WithColor(:success)

	AddNodeXT("payment_processed", "Process Payment", :Process)
	WithColor(:success)

	AddNodeXT(:ID = "claim_closed", :Label = "Claim Closed", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT(:ID = "claim_denied", :Label = "Claim Denied", :Type = :Endpoint)
	WithColor(:danger)

	AddNodeXT("investigation", "Fraud Investigation", :Data)
	WithColor(:danger)

	ConnectXT("claim_filed", :To = "claim_intake", :With = "")
	ConnectXT("claim_intake", :To = "assign_adjuster", :With = "")
	ConnectXT("assign_adjuster", :To = "field_inspection", :With = "")
	ConnectXT("field_inspection", :To = "documentation", :With = "")
	ConnectXT("documentation", :To = "fraud_check", :With = "")
	ConnectXT("fraud_check", :To = "fraud_flag", :With = "")

	ConnectXT("fraud_flag", :To = "estimate_damage", :With = "No")
	ConnectXT("fraud_flag", :To = "investigation", :With = "Yes")
	ConnectXT("investigation", :To = "claim_denied", :With = "")

	ConnectXT("estimate_damage", :To = "estimate_ok", :With = "")
	ConnectXT("estimate_ok", :To = "reserve_funds", :With = "Yes")
	ConnectXT("estimate_ok", :To = "claim_denied", :With = "No")

	ConnectXT("reserve_funds", :To = "authorize_repair", :With = "")
	ConnectXT("authorize_repair", :To = "payment_processed", :With = "")
	ConnectXT("payment_processed", :To = "claim_closed", :With = "")

	Render("example16_claims_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 17: EMPLOYEE LEAVE REQUEST WORKFLOW
#-----------------#

/*--- HR workflow for employee leave approval
	with balance checking and multi-level approval
*/
pr()

oLeaveWorkflow = new stzDiagramBuilder("Leave Request Workflow")
oLeaveWorkflow {
	SetTheme(:Vibrant)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "request", :Label = "Leave Request Submitted", :Type = :Start)
	WithColor(:success)

	AddNodeXT("check_balance", "Check Leave Balance", :Process)
	WithColor(:primary)

	AddNodeXT("balance_ok", "Sufficient Balance?", :Decision)
	WithColor(:warning)

	AddNodeXT("manager_review", "Manager Review", :Process)
	WithColor(:info)

	AddNodeXT("manager_approve", "Manager Approves?", :Decision)
	WithColor(:warning)

	AddNodeXT("hr_review", "HR Review", :Process)
	WithColor(:info)

	AddNodeXT("hr_approve", "HR Approves?", :Decision)
	WithColor(:warning)

	AddNodeXT("block_calendar", "Block Calendar", :Process)
	WithColor(:neutral)

	AddNodeXT("notify_team", "Notify Team", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "approved_leave", :Label = "Leave Approved", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT(:ID = "rejected", :Label = "Request Rejected", :Type = :Endpoint)
	WithColor(:danger)

	AddNodeXT("notify_rejection", "Notify Rejection", :Data)
	WithColor(:warning)

	ConnectXT("request", :To = "check_balance", :With = "")
	ConnectXT("check_balance", :To = "balance_ok", :With = "")
	ConnectXT("balance_ok", :To = "manager_review", :With = "Yes")
	ConnectXT("balance_ok", :To = "rejected", :With = "No")

	ConnectXT("manager_review", :To = "manager_approve", :With = "")
	ConnectXT("manager_approve", :To = "hr_review", :With = "Yes")
	ConnectXT("manager_approve", :To = "notify_rejection", :With = "No")

	ConnectXT("hr_review", :To = "hr_approve", :With = "")
	ConnectXT("hr_approve", :To = "block_calendar", :With = "Yes")
	ConnectXT("hr_approve", :To = "notify_rejection", :With = "No")

	ConnectXT("block_calendar", :To = "notify_team", :With = "")
	ConnectXT("notify_team", :To = "approved_leave", :With = "")
	ConnectXT("notify_rejection", :To = "rejected", :With = "")

	Render("example17_leave_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 18: CONTENT PUBLISHING WORKFLOW
#-----------------#

/*--- Editorial pipeline with review, fact-checking,
	SEO optimization, and publication scheduling
*/
pr()

oPublishWorkflow = new stzDiagramBuilder("Editorial Publishing Pipeline")
oPublishWorkflow {
	SetTheme(:Professional)
	SetLayout(:TopDown)
	SetEdgeColor("gray")
	SetNodeStrokeColor("gray")

	AddNodeXT(:ID = "idea", :Label = "Content Idea", :Type = :Start)
	WithColor(:primary)

	AddNodeXT("research", "Research", :Process)
	WithColor(:primary)

	AddNodeXT("draft", "Write Draft", :Process)
	WithColor(:primary)

	AddNodeXT("editor_review", "Editor Review", :Process)
	WithColor(:info)

	AddNodeXT("editor_ok", "Editor Approves?", :Decision)
	WithColor(:warning)

	AddNodeXT("fact_check", "Fact Check", :Process)
	WithColor(:info)

	AddNodeXT("facts_ok", "Facts Verified?", :Decision)
	WithColor(:warning)

	AddNodeXT("design", "Design/Layout", :Process)
	WithColor(:neutral)

	AddNodeXT("seo_review", "SEO Review", :Process)
	WithColor(:info)

	AddNodeXT("seo_ok", "SEO Optimized?", :Decision)
	WithColor(:warning)

	AddNodeXT("schedule", "Schedule Publication", :Process)
	WithColor(:success)

	AddNodeXT("publish", "Publish", :Process)
	WithColor(:success)

	AddNodeXT("promote", "Promote on Social", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "live", :Label = "Content Live", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT("revisions", "Request Revisions", :Data)
	WithColor(:warning)

	ConnectXT("idea", :To = "research", :With = "")
	ConnectXT("research", :To = "draft", :With = "")
	ConnectXT("draft", :To = "editor_review", :With = "")
	ConnectXT("editor_review", :To = "editor_ok", :With = "")
	ConnectXT("editor_ok", :To = "fact_check", :With = "Yes")
	ConnectXT("editor_ok", :To = "revisions", :With = "No")
	ConnectXT("revisions", :To = "draft", :With = "")

	ConnectXT("fact_check", :To = "facts_ok", :With = "")
	ConnectXT("facts_ok", :To = "design", :With = "Yes")
	ConnectXT("facts_ok", :To = "revisions", :With = "No")

	ConnectXT("design", :To = "seo_review", :With = "")
	ConnectXT("seo_review", :To = "seo_ok", :With = "")
	ConnectXT("seo_ok", :To = "schedule", :With = "Yes")
	ConnectXT("seo_ok", :To = "revisions", :With = "No")

	ConnectXT("schedule", :To = "publish", :With = "")
	ConnectXT("publish", :To = "promote", :With = "")
	ConnectXT("promote", :To = "live", :With = "")

	Render("example18_publishing_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 19: RECRUITMENT & HIRING WORKFLOW
#-----------------#

/*--- Complete hiring pipeline from job requisition through onboarding
	with multiple screening stages and background checks
*/	
pr()

oRecruitmentWorkflow = new stzDiagramBuilder("Recruitment Process")
oRecruitmentWorkflow {
	SetTheme(:Vibrant)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "job_req", :Label = "Job Requisition", :Type = :Start)
	WithColor(:success)

	AddNodeXT("post_job", "Post Job Opening", :Process)
	WithColor(:primary)

	AddNodeXT("receive_apps", "Receive Applications", :Data)
	WithColor(:neutral)

	AddNodeXT("resume_screen", "Resume Screening", :Process)
	WithColor(:info)

	AddNodeXT("passes_screen", "Passes Initial Screen?", :Decision)
	WithColor(:warning)

	AddNodeXT("phone_interview", "Phone Interview", :Process)
	WithColor(:primary)

	AddNodeXT("phone_ok", "Advance to Technical?", :Decision)
	WithColor(:warning)

	AddNodeXT("technical_test", "Technical Assessment", :Process)
	WithColor(:info)

	AddNodeXT("technical_ok", "Passes Assessment?", :Decision)
	WithColor(:warning)

	AddNodeXT("on_site", "On-Site Interview", :Process)
	WithColor(:primary)

	AddNodeXT("team_feedback", "Team Feedback", :Data)
	WithColor(:neutral)

	AddNodeXT("on_site_ok", "Team Approves?", :Decision)
	WithColor(:warning)

	AddNodeXT("offer_prep", "Prepare Offer", :Process)
	WithColor(:success)

	AddNodeXT("offer_sent", "Send Offer", :Process)
	WithColor(:success)

	AddNodeXT("offer_accepted", "Offer Accepted?", :Decision)
	WithColor(:warning)

	AddNodeXT("background_check", "Background Check", :Process)
	WithColor(:info)

	AddNodeXT("check_ok", "Check Clear?", :Decision)
	WithColor(:warning)

	AddNodeXT("onboarding", "Onboarding", :Process)
	WithColor(:success)

	AddNodeXT(:ID = "hired", :Label = "Employee Onboarded", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT(:ID = "rejected", :Label = "Candidate Rejected", :Type = :Endpoint)
	WithColor(:danger)

	ConnectXT("job_req", :To = "post_job", :With = "")
	ConnectXT("post_job", :To = "receive_apps", :With = "")
	ConnectXT("receive_apps", :To = "resume_screen", :With = "")
	ConnectXT("resume_screen", :To = "passes_screen", :With = "")
	ConnectXT("passes_screen", :To = "phone_interview", :With = "Yes")
	ConnectXT("passes_screen", :To = "rejected", :With = "No")

	ConnectXT("phone_interview", :To = "phone_ok", :With = "")
	ConnectXT("phone_ok", :To = "technical_test", :With = "Yes")
	ConnectXT("phone_ok", :To = "rejected", :With = "No")

	ConnectXT("technical_test", :To = "technical_ok", :With = "")
	ConnectXT("technical_ok", :To = "on_site", :With = "Yes")
	ConnectXT("technical_ok", :To = "rejected", :With = "No")

	ConnectXT("on_site", :To = "team_feedback", :With = "")
	ConnectXT("team_feedback", :To = "on_site_ok", :With = "")
	ConnectXT("on_site_ok", :To = "offer_prep", :With = "Yes")
	ConnectXT("on_site_ok", :To = "rejected", :With = "No")

	ConnectXT("offer_prep", :To = "offer_sent", :With = "")
	ConnectXT("offer_sent", :To = "offer_accepted", :With = "")
	ConnectXT("offer_accepted", :To = "background_check", :With = "Yes")
	ConnectXT("offer_accepted", :To = "rejected", :With = "No")

	ConnectXT("background_check", :To = "check_ok", :With = "")
	ConnectXT("check_ok", :To = "onboarding", :With = "Yes")
	ConnectXT("check_ok", :To = "rejected", :With = "No")

	ConnectXT("onboarding", :To = "hired", :With = "")

	Render("example19_recruitment_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 20: CUSTOMER SUPPORT WORKFLOW
#-----------------#

/*--- Support ticket lifecycle with categorization, routing,
	investigation, escalation, and satisfaction tracking
*/
pr()

oSupportWorkflow = new stzDiagramBuilder("Customer Support Workflow")
oSupportWorkflow {
	SetTheme(:Professional)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "ticket_opened", :Label = "Ticket Opened", :Type = :Start)
	WithColor(:success)

	AddNodeXT("categorize", "Categorize Issue", :Process)
	WithColor(:primary)

	AddNodeXT("priority", "Assess Priority", :Decision)
	WithColor(:warning)

	AddNodeXT("assign_agent", "Assign to Agent", :Process)
	WithColor(:info)

	AddNodeXT("agent_investigate", "Agent Investigates", :Process)
	WithColor(:primary)

	AddNodeXT("troubleshoot_ok", "Issue Resolved?", :Decision)
	WithColor(:warning)

	AddNodeXT("escalate", "Escalate to Specialist", :Process)
	WithColor(:info)

	AddNodeXT("send_solution", "Send Solution", :Process)
	WithColor(:success)

	AddNodeXT("customer_confirm", "Customer Confirms Fix?", :Decision)
	WithColor(:warning)

	AddNodeXT("satisfaction", "Satisfaction Survey", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "closed", :Label = "Ticket Closed", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT("reopen", "Reopen Ticket", :Data)
	WithColor(:warning)

	ConnectXT("ticket_opened", :To = "categorize", :With = "")
	ConnectXT("categorize", :To = "priority", :With = "")
	ConnectXT("priority", :To = "assign_agent", :With = "")
	ConnectXT("assign_agent", :To = "agent_investigate", :With = "")
	ConnectXT("agent_investigate", :To = "troubleshoot_ok", :With = "")
	ConnectXT("troubleshoot_ok", :To = "send_solution", :With = "Yes")
	ConnectXT("troubleshoot_ok", :To = "escalate", :With = "No")
	ConnectXT("escalate", :To = "send_solution", :With = "")
	ConnectXT("send_solution", :To = "customer_confirm", :With = "")
	ConnectXT("customer_confirm", :To = "satisfaction", :With = "Yes")
	ConnectXT("customer_confirm", :To = "reopen", :With = "No")
	ConnectXT("reopen", :To = "agent_investigate", :With = "")
	ConnectXT("satisfaction", :To = "closed", :With = "")

	Render("example20_support_workflow.svg")
}

pf()

#-----------------#
#  SUMMARY
#-----------------#

/*--- All 20 comprehensive examples generated with full
	documentation of features and use cases

pr()

? ""
? "============================================================"
? "  stzDiagramBuilder - Complete Feature Showcase"
? "============================================================"
? ""
? "LAYOUT EXAMPLES (1-10):"
? "  1. Basic Flow Diagram"
? "  2. State Machine - Light Theme"
? "  3. State Machine - Dark Theme"
? "  4. Database Architecture"
? "  5. Event-Driven System"
? "  6. Complex Decision Tree"
? "  7. Microservices with Clusters"
? "  8. ETL Data Pipeline"
? "  9. Process Flow - TopDown Layout"
? " 10. Process Flow - LeftRight Layout"
? ""
? "ORGANIZATION CHARTS (11-13):"
? " 11. Traditional Hierarchy (CEO, Directors, Managers)"
? " 12. Matrix Organization (Cross-Functional)"
? " 13. Lean Startup (Flat Structure)"
? ""
? "BUSINESS WORKFLOWS (14-20):"
? " 14. E-Commerce Order Processing"
? " 15. Banking Loan Approval"
? " 16. Insurance Claims Processing"
? " 17. Employee Leave Request"
? " 18. Editorial Publishing Pipeline"
? " 19. Recruitment & Hiring Process"
? " 20. Customer Support Tickets"
? ""
? "KEY FEATURES DEMONSTRATED:"
? "  ✓ Multiple Themes: Light, Dark, Vibrant, Professional"
? "  ✓ Multiple Layouts: TopDown, LeftRight, Organic"
? "  ✓ All Node Types: Start, Process, Decision, Storage, Data, Endpoint, Event"
? "  ✓ Semantic Colors: Primary, Success, Warning, Danger, Info, Neutral"
? "  ✓ Clusters: Domain grouping for microservices"
? "  ✓ Complex Workflows: Multi-stage with loops and decisions"
? "  ✓ Real-World Use Cases: Business processes ready to use"
? ""
? "============================================================"
? ""

pf()
