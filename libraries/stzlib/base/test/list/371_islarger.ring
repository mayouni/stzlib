# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #371.

load "../../stzBase.ring"

pr()

? Q([1, 2, 3, 4, 5]).IsLarger(:Than = [8, 9])
#--> TRUE

# or if you want to precise:

? Q([1, 2, 3, 4, 5]).HasMoreItems(:Than = [8, 9])
#--> TRUE

#--

? Q([8, 9]).IsSmaller(:Than = [1, 2, 3, 4, 5])
#--> TRUE

# or if you want to precise:
? Q([8, 9]).HasLessItems(:Than = [1, 2, 3, 4, 5])
#--> TRUE

pf()
# Executed in almost 0 second(s).
