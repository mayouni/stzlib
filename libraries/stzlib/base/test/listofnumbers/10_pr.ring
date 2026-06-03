# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #10.

load "../../stzBase.ring"


o1 = new stzListOfNumbers([
	370, 4120.34, 493.12, 45, 370, 12.1, 7
])

decimals(3)

? o1.Justified()
#-->
# 	  370.000
#	 4120.340
#	  493.120
#	   45.000
#	  370.000
#	   12.100
#	    7.000

? o1.JustifiedUsing("0") # Or JustifiedXT()
#-->
#	0370.000
#	4120.340
#	0493.120
#	0045.000
#	0370.000
#	0012.100
#	0007.000

pf()
# Executed in 0.03 second(s)
