# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #16.
#ERR panic: integer does not fit in destination type

load "../../stzBase.ring"

pr()

? Q([ "a", "b", "c" ]).ToNumberW('{ @number = len(@list) }') # Or ToNumberXT()
#--> 3

? Q([ "a", "b", "c" ]).ToNumberW('{
	@number = QRT(@list, :stzListOfChars).UnicodesQRT(:stzListOfNumbers).Sum()
}')
#--> 294

# In fact:
? QRT(["a", "b", "c"], :stzListOfChars).Unicodes() #--> [97, 98, 99]

? Q([ "Me", "and", "You!" ]).ToNumberW('{ @number += len(@item) }')
#--> 9

# In fact:
? Q([ "Me", "and", "You!" ]).Yield('len(@item)')
#--> [2, 3, 4]

pf()
# Executed in 0.21 second(s)
