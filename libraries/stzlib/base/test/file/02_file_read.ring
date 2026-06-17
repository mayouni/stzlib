# Narrative
# --------
# READING FILES (pure intent)
#
# Intent: "I want to read this file."
# Extracted from stzfiletest.ring, block #2. Made portable: a local sandbox
# file replaces "../_data/tabdata.csv".
#
# FileReadQ returns a queryable reader -- no write methods, pure reading
# intent -- with rich content access (Content/Lines/FirstLine/LastLine/...).

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t02"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)
write(cSbx + "/data.csv",
    "tree_id;block_id;alive" + nl +
    "180683;348711;Alive" + nl +
    "200540;315986;Alive" + nl +
    "204026;218365;Dead")

oReader = FileReadQ(cSbx + "/data.csv")

? oReader.Content() + NL
#-->
'
tree_id;block_id;alive
180683;348711;Alive
200540;315986;Alive
204026;218365;Dead
'

? @@NL( oReader.Lines() ) + NL
#-->
'
[
	"tree_id;block_id;alive",
	"180683;348711;Alive",
	"200540;315986;Alive",
	"204026;218365;Dead"
]
'

? oReader.NumberOfLines()	#--> 4
? oReader.FirstLine()		#--> tree_id;block_id;alive
? oReader.LastLine()		#--> 204026;218365;Dead
? oReader.ContainsText("Dead")	#--> 1

oReader.Close()

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23
