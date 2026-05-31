# Narrative
# --------
# #NOTE: This is a draft note I made while refactoring the naming startegy
#
# Extracted from stzlisttest.ring, block #299.

load "../../../stzBase.ring"

# of some functions involving bounds and things inbetween.
# I left it here as a memory of the hard work made on this front...

# NAMING REFORM

..RemoveBetweenIB() : removes also bounds
#--> DONE

...Bounds  --> ...( [b1,b2] )	why? to be able to use ...( b ) if the 2 bounds are sale
...Between --> ...( b1, b2 )	why? because they are always 2 bounds
#--> DONE

...SubString --> ...Section

AddXT()
#--> DONE

FindXT()

InsertXT()

ReplaceXT()
#--> DONE

RemoveXT()
#--> DONE
