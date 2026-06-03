# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #151.

load "../../stzBase.ring"


o1 = new stzString("aaA...")

? o1.FindCS("a", :CaseSensitive) # Or :IsCaseSensitive or :CS or :IsCS
				 # or TRUE or TRUE or TRUE
#--> [1, 2]

? o1.FindCS("a", :CaseInSensitive) # Or :NotCaseSensitive or :NotCS
				   # or :IsNotCaseSensitive  or :IsNotCS
				   # or :CaseSensitive = FALSE
				   # or :CS = FALSE
				   # or FALSE
#--> [1, 2, 3]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.19
