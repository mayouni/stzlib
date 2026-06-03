# Narrative
# --------
# Multi-tier database architecture with storage nodes
#
# Extracted from stzdiagrambuildertest.ring, block #5.
#ERR Error (R24) : Using uninitialized variable: demonstrating

load "../../stzBase.ring"

	demonstrating data flow patterns

pr()

oDatabase = new stzDiagramMaker("Database Architecture")
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
