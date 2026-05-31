# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #49.

load "../../../stzBase.ring"


StzDecimals(3) # Change the program round and memorises it

o1 = new stzNumber([ 981.123456701, :round = 5 ])

? o1.Round()
#--> 5

? o1.NumericValue() # Sensitive to current on the program round, 3.
#--> 981.123

? o1.StringValue() # Rounded to the what is specified at the object level, 5.
#--> 981.12346

pf()
# Executed in 0.03 second(s)
