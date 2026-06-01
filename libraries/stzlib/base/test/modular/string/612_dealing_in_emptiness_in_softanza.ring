# Narrative
# --------
# #narration DEALING IN EMPTINESS IN SOFTANZA
#
# Extracted from stzStringTest.ring, block #612.

load "../../../stzBase.ring"


# Read documentaion here:
# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/doc/narrations/stz-narration-stzstring-emptiness.md#emptiness-in-strings-clear-rules-the-softanza-way

pr()

# Rule 1 - Emptiness is uncountable:
# We can not cout its occurrences inside any string, beeing empty or not

	? Q("").Count('')
	#--> 0
	
	? Q("text").Count('') + NL
	#--> 0  
	
# Rule 2 - Emptiness is unfindable (since it is uncountable ~> Rule 1)

	? @@( Q("").Find('') )
	#--> [ ]
	
	? @@( Q("text").Find('') ) + NL
	#--> [ ]

# Rule 3 - Emptiness is uncontainable in both directions

#~> An empty string contains nothing, being an empty string or not,
#~> and a non empty string does not contain any empty one
#~> (which is completely coherent with Rule 1)

	? Q("").Contains('') 
	#--> FALSE
	
	? Q("").Contains('text')
	#--> FALSE
	
	? Q("text").Contains('') + NL
	#--> FALSE

# Rule 4 - Emptiness is irreplaçable in both directions

	? @@( Q("").ReplaceQ('', '').Content() )
	#--> ""
	
	? @@( Q("").ReplaceQ('any', '').Content() )
	#--> ""
	
	? @@( Q("").ReplaceQ('', 'any').Content() )
	#--> ""
	
	? @@( Q("text").ReplaceQ('', "").Content() )
	#--> text
	
	? @@( Q("text").ReplaceQ('', "X").Content() ) + NL
	#--> text

# Rule 5 - Emptiness is irremovalbe in both directions

	? @@( Q("").RemoveQ('').Content() )
	#--> ""

	? @@( Q("").RemoveQ('text').Content() )
	#--> ""

	? @@( Q("text").RemoveQ('').Content() )
	#--> "text"

pf()
# Executed in 0.02 second(s) in Ring 1.22
