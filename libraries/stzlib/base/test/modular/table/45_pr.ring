# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #45.

load "../../../stzBase.ring"


# Special syntax to enable the SQL syntax in Ring

o1 = new stzTable([])
? IsStzObject(o1)
#--> TRUE

o1.@([
	:COL2 = :INT,
	:COL3 = VARCHAR(30)
])

o1.Show()
#--> 	COL2   COL3
#	----- -----
#	  ""     ''   

pf()
# Executed in 0.08 second(s)
