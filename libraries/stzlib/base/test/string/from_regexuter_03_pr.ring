# Narrative
# --------
# pr()
#
# Extracted from stzregexutertest.ring, block #3.
#ERR Error (R3) : Calling Function without definition: multiplybyn

load "../../stzBase.ring"

pr()

# In Softanza, you can process calculations on numbers inside
# a string, and get that string updated with the new values!

o1 = new stzString("The total is 42 dollars and 13 cents.")
o1 {

	MultiplyByN(2)
	? Content()
	#--> The total is 84 dollars and 26 cents.

	DivideByN(2)
	? Content()
	#--> The total is 42 dollars and 13 cents.

	AddN(8)
	? Content()
	#--> The total is 50 dollars and 21 cents.

	RetrieveN(12)
	? Content() + NL
	#--> The total is 38 dollars and 9 cents.
}

# You can even make different claculation for each number.
# For that, you just use the eXTended form like this:

o1 = new stzString("The total is 42 dollars and 13 cents.")
o1 {

	MultiplyByNXT([2, 3]) # "42" multiplied by 2 and "13" by 3
	? Content()
	#--> The total is 84 dollars and 39 cents.

	DivideByNXT([ 2, 3 ])
	? Content()
	#--> The total is 42 dollars and 13 cents.

	AddNXT([ 8, 7 ])
	? Content()
	#--> The total is 50 dollars and 20 cents.

	RetrieveNXT([40, 10])
	? Content()
	#--> The total is 10 dollars and 10 cents.

}

pf()
# Executed in 0.12 second(s) in Ring 1.22
