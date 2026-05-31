# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #21.

load "../../../stzBase.ring"


# WAY 5: Creating a table by providing a hashtable where
# the column names are keys and rows are values
# (internally, stzTable content is hosted in this hashlist)

o1 = new stzTable([
 	:NAME   = [ "Ali", 	  "Dania", 	"Han" 	 ],
 	:JOB    = [ "Programmer", "Manager", 	"Doctor" ],
	:SALARY = [ 35000, 	  50000, 	62500    ]
])

o1.Show()
#-->  NAME          JOB   SALARY
#    ------ ------------ -------
#      Ali   Programmer    35000
#    Dania      Manager    50000
#      Han       Doctor    62500

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.47 second(s) in Ring 1.17
