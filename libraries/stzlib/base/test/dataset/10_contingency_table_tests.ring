# Narrative
# --------
# Contingency Table Tests
#
# Extracted from stzdatasettest.ring, block #10.

load "../../stzBase.ring"

# Shows frequency distribution of two categorical variables for association analysis.

pr()

o4 = new stzDataSet([ "A", "B", "A", "C", "B", "A" ])
o5 = new stzDataSet([ "X", "Y", "X", "Z", "Y", "X" ])

aTable = o4.ContingencyTable(o5)

? @@(aTable)
#--> [[ " X", "Y", "Z " ], [[ " A", [3, 0, 0]], [ " B", [0, 2, 0]], [ " C", [0, 0, 1]]]]

pf()
# Executed in 0.0010 second(s) in Ring 1.24
