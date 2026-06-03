# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #435.

load "../../stzBase.ring"


StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFind("A")
}
#-->
#	 [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#	  --^--------------^---------^-------------------^------------

# WARNING: works only for list of chars
#TODO : Generalize it for list of strings and other types

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.20
