# Narrative
# --------
# TESTING HTML TABLES IN STZSTRING #TODO
#
# Extracted from stztabletest.ring, block #229.
#ERR Error (R14) : Calling Method without definition: containshtmltable

load "../../stzBase.ring"


pr()

cHtml = '..'

o1 = new stzString(cHtml)
? o1.ContainsHtmlTable()
#--> TRUE

? o1.NumberOfHtmlTables()
#--> 3

o1.HtmlToDataTablesQRT(:stzListOfTables).Show()

pf()
