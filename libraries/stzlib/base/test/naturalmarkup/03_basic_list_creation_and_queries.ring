# Narrative
# --------
# Basic list creation and queries
#
# Extracted from stznaturalmarkuptest.ring, block #3.
#ERR Error (R14) : Calling Method without definition: run

load "../../stzBase.ring"


pr()

cMarkup = `
Create a {+fruits:list ~1} and fill it with {#1 ["banana", "apple", "cherry"]}.
{?how-many} item we've just added?
{Show} them on the screen.
Thanks a lot!
 `

oNML = new stzNaturalMarkup(cMarkup)
oNML.Run()

#--> fruits
#--> 3

pf()
