# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #55.

load "../../../stzBase.ring"


# Replacing the string by reference

	o1 = new stzString("R I N G")
	o1.Replace(" ", "-")
	# This modifies the string itself

	? o1.Content()
	#--> R-I-N-G

# Replacing the string by copy

	o1 = new stzString("R I N G")
	? o1.Copy().ReplaceQ(" ", "-").Content()
	#--> R-I-N-G

	# Hence, the copy is modified, but the original
	# string stays the same

	? o1.Content()
	#--> R I N G

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.18
