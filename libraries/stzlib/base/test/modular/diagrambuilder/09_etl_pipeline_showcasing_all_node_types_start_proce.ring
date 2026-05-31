# Narrative
# --------
# ETL pipeline showcasing all node types: start, process,
#
# Extracted from stzdiagrambuildertest.ring, block #9.

load "../../../stzBase.ring"

	decision, storage, data, and endpoint

pr()

oDataPipeline = new stzDiagramMaker("ETL Data Pipeline")
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
