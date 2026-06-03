# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #88.
#ERR Error (R14) : Calling Method without definition: addcol

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.AddCol( :JOB = [ "Pilot", "Designer", "Author" ] )
? o1.Show()

#--> ID    NAME   AGE        JOB
#    --- ------- ----- ---------
#    10    Imed    52      Pilot
#    20   Hatem    46   Designer
#    30   Karim    48     Author

o1.RemoveCol(:JOB)
o1.Show()
#--> ID    NAME   AGE
#    --- ------- ----
#    10    Imed    52
#    20   Hatem    46
#    30   Karim    48

pf()
# Executed in 0.13 second(s)
