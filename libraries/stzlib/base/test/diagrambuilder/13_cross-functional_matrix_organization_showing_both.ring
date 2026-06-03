# Narrative
# --------
# Cross-functional matrix organization showing both
#
# Extracted from stzdiagrambuildertest.ring, block #13.
#ERR Error (R24) : Using uninitialized variable: functional

load "../../stzBase.ring"

	functional and product line hierarchies

pr()

oMatrixOrg = new stzDiagramMaker("Matrix Organization Structure")
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
