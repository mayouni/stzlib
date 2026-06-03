# Narrative
# --------
# List transformation and uppercase
#
# Extracted from stznaturalmarkuptest.ring, block #4.
#ERR Error (R14) : Calling Method without definition: run

load "../../stzBase.ring"


pr()

cMarkup = `
I made an {+other:list} and {fill-it-with ~1} {#1 ["one", "two", "three"]}.
Now {uppercase} them because LOUD IS BETTER!
Here they are: {?content}
`

oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> ["ONE", "TWO", "THREE"]

pf()
