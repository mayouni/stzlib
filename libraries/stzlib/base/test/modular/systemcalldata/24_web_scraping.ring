# Narrative
# --------
# WEB SCRAPING
#
# Extracted from stzsystemcalldatatest.ring, block #24.

load "../../../stzBase.ring"

==========================================

pr()

# Download page
Sy = new stzSystemCall(:CurlGet)
Sy {
	SetParam(:url, "https://example.com")
	Run()
	cHtml = Output()
	write("page.html", cHtml)
}

# POST data
new stzSystemCall(:CurlPost) {
	SetParams([
		[:url, "https://api.example.com/data"],
		[:data, "key=value"]
	])
	Run()
	? Output()
}

pf()
