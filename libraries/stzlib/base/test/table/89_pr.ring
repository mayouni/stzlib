# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #89.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.AddCol( :JOB = [ "Pilot", "Designer", "Author", "thing", "bye" ] )
? o1.Show() # NOTE this is misspelled!

#--> ID    NAME   AGE        JOB
#    --- ------- ----- ---------
#    10    Imed    52      Pilot
#    20   Hatem    46   Designer
#    30   Karim    48     Author

o1.AddCol( :NATION = [ "Tunisia", "Egypt" ] )
o1.Show()
#--> ID    NAME   AGE        JOB    NATION
#    --- ------- ----- ---------- --------
#    10    Imed    52      Pilot   Tunisia
#    20   Hatem    46   Designer     Egypt
#    30   Karim    48     Author        ""

pf()
# Executed in 0.18 second(s)
