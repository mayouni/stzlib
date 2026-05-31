# Narrative
# --------
# DOCUMENT CONVERSION
#
# Extracted from stzsystemcalldatatest.ring, block #19.

load "../../../stzBase.ring"

==========================================

pr()

# Markdown to HTML
new stzSystemCall(:Markdown2Html) {
	SetParam(:input, "README.md")
	SetParam(:output, "README.html")
	Run()
}

# Markdown to PDF
new stzSystemCall(:Markdown2Pdf) {
	SetParams([
		[:input, "report.md"],
		[:output, "report.pdf"]
	])
	Run()
}

pf()
