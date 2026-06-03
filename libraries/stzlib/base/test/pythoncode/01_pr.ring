# Narrative
# --------
# pr()
#
# Extracted from stzpythoncodeTest.ring, block #1.

load "../../stzBase.ring"

pr()

# Python code  
Py() { @('res = 2 + 3') Run() ? Result() }  #--> 5

# R code  
R() { @('res = 2 + 3') Run() ? Result() }   #--> 5

pf()
# Executed in 0.87 second(s) in Ring 1.24
