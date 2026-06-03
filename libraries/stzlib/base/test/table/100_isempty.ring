# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #100.
#ERR Error (R14) : Calling Method without definition: erase

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.IsEmpty()
#--> FALSE

o1.Erase()

? o1.IsEmpty()
#--> TRUE

o1.Show()
#-->
#  ID    EMPLOYEE  SALARY
#  --- ---------- -------
#  NULL  NULL	     NULL
#  NULL  NULL	     NULL
#  NULL  NULL	     NULL

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.57 second(s) in Ring 1.17
