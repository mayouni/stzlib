# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #3.

load "../../stzBase.ring"


cCharSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
	   "0123456789" + "#!@~_" +
	   "abcdefghijklmnopqurstuvwxyz"
	  
	  

cPassword = ""

for i = 1 to 8
    cPassword += Q(cCharSet).ARandomChar()
next

? cPassword
#--> @3Ond72H
#--> 2z47AD@Z
#--> LrmaUo7Z

pf()
# Executed in 0.01 second(s) in Ring 1.23
