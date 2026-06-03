# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #371.

load "../../stzBase.ring"


#NOTE :
#	- RemoveNthItem(n) : Remove item at position n
#
#	- RemoveNthXT(n, pItem) : Remove nth occurrence of pItem
# 	  (you can also use RemoveNthOccurrence(n, pItem)
#
#	- RemoveThisNthItem(n, pItem) : remove nth item only if it
#	  is equal to pItem


o1 = new stzString("_ABC_DE_")

o1.RemoveFirstChar()
? o1.Content()
#--> ABC_DE_

o1.RemoveThisFirstCharCS("a", :CS = FALSE)
? o1.Content()
#--> BC_DE_

o1.RemoveNthChar(:Last) # Works when ChekParams() = TRUE (the default)
			# Otherwise use o1.RemoveLastChar() or
			# o1.RemoveNthChar(o1.NumberOfChars())
? o1.Content()
#--> BC_DE

o1.RemoveThisNthChar(3, "_")
? o1.Content()
#--> BCDE

pf()
# Executed in 0.01 second(s) in Ring 1.21
