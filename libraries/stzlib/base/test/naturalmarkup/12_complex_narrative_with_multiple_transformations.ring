# Narrative
# --------
# Complex narrative with multiple transformations
#
# Extracted from stznaturalmarkuptest.ring, block #12.

load "../../stzBase.ring"

pr()

	cMarkup = '
	Yesterday I made a {+fruits:list ~1} with {#1 ["banana", "apple", "cherry"]}.
	What did I call them? {?name}
	How many are there? {?count}
	
	Actually, let me make an {+other:list} and {fill-it-with ~1} the same items as in {#1 fruits:list..content}.
	Now {uppercase} that {other:list} because LOUD FRUITS ARE BETTER!
	Here they are: {show-0it}
	
	Wait...
	What if I {^joinXT ~2} the {#1 other:list} I made above using {#2 " | "} as a separator?
	What type is that? {?type}
	Beautiful: {show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> fruits
#--> 3
#--> ["BANANA", "APPLE", "CHERRY"]
#--> STRING
#--> BANANA | APPLE | CHERRY

proff()

pf()
