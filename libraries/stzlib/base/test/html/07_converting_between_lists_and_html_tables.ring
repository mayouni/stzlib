# Narrative
# --------
# CONVERTING BETWEEN LISTS AND HTML TABLES
#
# Extracted from stzHtmlTest.ring, block #7.
#ERR Error (R3) : Calling Function without definition: listtohtmlxt

load "../../stzBase.ring"


pr()

aData = [
	[ "Name", [ "Alice", "Bob", "Charlie" ] ],
	[ "Age",  [ "25", "30", "35" ] ]
]

cTableHtml = ListToHtmlTable(aData)
? cTableHtml
#--> <table class="data"><thead><tr><th>Name</th><th>Age</th></tr></thead><tbody><tr><td>Alice</td><td>25</td></tr><tr><td>Bob</td><td>30</td></tr><tr><td>Charlie</td><td>35</td></tr></tbody></table>

? IsHtmlTable(cTableHtml)    #--> TRUE

aBack = HtmlTableToList(cTableHtml)
? @@(aBack)                   #--> [ [ "Name", [ "Alice", "Bob", "Charlie" ] ], [ "Age", [ "25", "30", "35" ] ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
