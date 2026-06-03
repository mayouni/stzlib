# Narrative
# --------
# EXAMPLE 13: Reuse Same Object
#
# Extracted from stzsystemcalldatatest.ring, block #13.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:CopyFile)

# First copy
Sy {
	SetParams([[:source, "a.txt"], [:dest, "b.txt"]])
	Run()
	? "Copy 1: " + Succeeded()
}

# Reset and second copy
Sy {
	Reset()
	SetParams([[:source, "c.txt"], [:dest, "d.txt"]])
	Run()
	? "Copy 2: " + Succeeded()
}

pf()
